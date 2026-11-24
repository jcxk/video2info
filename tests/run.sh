#!/usr/bin/env bash
# Critical offline tests for bin/video2info. No network: yap and whisper-cli are stubbed.
# Needs: ffmpeg, tesseract, poppler (pdfinfo, pdftotext), jq.  Covers md (default), pdf and txt.    Run: make   (or: bash tests/run.sh)
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
BIN=$PWD/bin/video2info FIX=$PWD/tests/fixtures
T=$(mktemp -d "${TMPDIR:-/tmp}/video2info-test.XXXXXX"); trap 'rm -rf "$T"' EXIT
pass=0 failed=0
ok()   { pass=$((pass + 1)); printf '  \033[32m✓\033[0m %s\n' "$1"; }
fail() { failed=$((failed + 1)); printf '  \033[31m✗\033[0m %s\n%s\n' "$1" "${2:-}" | sed '2,$s/^/      /'; }
# expect_err "name" "message part" args... — command must exit non-zero and print the message
expect_err() {
  local name=$1 msg=$2 out; shift 2
  if out=$("$BIN" "$@" 2>&1); then fail "$name" "exited 0"
  elif [[ $out == *"$msg"* ]]; then ok "$name"
  else fail "$name" "$out"; fi
}
has() { grep -qF -- "$2" "$1" && ok "$3" || fail "$3" "missing '$2' in $(basename "$1")"; }

echo "CLI"
[[ $("$BIN" --version) =~ ^video2info\ [0-9]+\.[0-9]+\.[0-9]+$ ]] && ok "--version" || fail "--version"
"$BIN" --help >/dev/null && ok "--help exits 0" || fail "--help exits 0"
expect_err "unknown option"        "unknown option"        --nope
expect_err "--crop leaves nothing" "leaves almost nothing" --crop left=95%,right=5% x.mp4
expect_err "--crop bad side"       "unknown side"          --crop foo=1 x.mp4
expect_err "missing file"          "no such file"          nope.mp4
expect_err "two URLs"              "only one URL"          https://a.example https://b.example
expect_err "unknown format"        "unknown format"        -f docx x.mp4

# fake speech engines: 3 lines at 1 s (slide 1), 17 s and 65.2 s (slide 2, which starts at ~16 s)
mkdir -p "$T/stub"
cat >"$T/stub/yap" <<'EOF'
#!/usr/bin/env bash
while (($#)); do [[ $1 == -o ]] && out=$2; shift; done
printf '%s' '{"metadata":{"locale":"en-US"},"segments":[{"start":1.0,"end":3,"text":"Welcome to the talk."},{"start":17.0,"end":20,"text":"Now about Cargo."},{"start":65.2,"end":70,"text":"Thanks for watching."}]}' >"$out"
EOF
cat >"$T/stub/whisper-cli" <<'EOF'
#!/usr/bin/env bash
while (($#)); do [[ $1 == -of ]] && of=$2; shift; done
printf '%s' '{"transcription":[{"offsets":{"from":1000},"text":" Welcome to the talk."},{"offsets":{"from":17000},"text":" Now about Cargo."},{"offsets":{"from":65200},"text":" Thanks for watching."}]}' >"$of.json"
EOF
chmod +x "$T/stub/yap" "$T/stub/whisper-cli"; : >"$T/model.bin"
run() { PATH="$T/stub:$PATH" VIDEO2INFO_WHISPER_MODEL=$T/model.bin "$BIN" "$@"; }

echo "Test video: a1 → a2 (bullet build) → blank → b → a2 again (revisit)"
ffmpeg -nostdin -loglevel error \
  -loop 1 -t 6 -i "$FIX/a1.png" -loop 1 -t 6 -i "$FIX/a2.png" -f lavfi -t 4 -i color=white:s=1280x720 \
  -loop 1 -t 6 -i "$FIX/b.png" -loop 1 -t 6 -i "$FIX/a2.png" -f lavfi -t 28 -i anullsrc=r=16000:cl=mono \
  -filter_complex "$(for i in 0 1 2 3 4; do printf '[%d]fps=5,scale=1280:720,setsar=1,format=yuv420p[v%d];' $i $i; done)[v0][v1][v2][v3][v4]concat=n=5:v=1:a=0[v]" \
  -map '[v]' -map 5:a -c:v mpeg4 -q:v 3 -c:a aac -shortest "$T/talk.mp4" || fail "build test video"

echo "PDF (--format pdf)"
if run "$T/talk.mp4" -f pdf -d "$T/pdf" >"$T/pdf.log" 2>&1; then
  pdf=$T/pdf/01_talk.pdf
  pages=$(pdfinfo "$pdf" 2>/dev/null | awk '/^Pages:/ {print $2}')
  [[ $pages == 2 ]] && ok "2 pages (build merged, blank and revisit dropped)" || fail "2 pages" "got ${pages:-none}"
  pdftotext -f 1 -l 1 "$pdf" "$T/p1.txt"; pdftotext -f 2 -l 2 "$pdf" "$T/p2.txt"
  has "$T/p1.txt" "Lifetimes prevent" "page 1 is the complete build (searchable text)"
  has "$T/p2.txt" "Cargo Package Manager" "page 2 is the next slide"
  [[ ! -e $T/pdf/Combined.pdf ]] && ok "no combined file for one video" || fail "no combined file for one video"
else
  fail "pdf run" "$(cat "$T/pdf.log")"
fi

echo "Markdown (default format)"
if VIDEO2INFO_STT=yap run "$T/talk.mp4" -d "$T/md" >"$T/md.log" 2>&1; then
  md=$T/md/01_talk.md
  [[ $(grep -c '^## \[' "$md") == 2 ]] && ok "2 slide sections" || fail "2 slide sections" "$(grep '^## ' "$md")"
  # section of a line = the last "## [" heading above it
  sec() { awk -v s="$2" 'index($0, "## [") == 1 {h = $0} index($0, s) {print h; exit}' "$1"; }
  [[ $(sec "$md" "Lifetimes prevent") == *"Slide 1" ]] && ok "slide 1 has its OCR text" || fail "slide 1 has its OCR text"
  [[ $(sec "$md" "[00:01] Welcome") == *"Slide 1" ]] && ok "00:01 speech under slide 1" || fail "00:01 speech under slide 1" "$(sec "$md" "[00:01]")"
  [[ $(sec "$md" "[00:17] Now about Cargo") == *"Slide 2" ]] && ok "00:17 speech under slide 2" || fail "00:17 speech under slide 2" "$(sec "$md" "[00:17]")"
  [[ $(sec "$md" "[01:05] Thanks") == *"Slide 2" ]] && ok "01:05 speech under the last slide" || fail "01:05 speech under the last slide"
  [[ -s $T/md/01_talk_assets/slide-01.jpg && -s $T/md/01_talk_assets/slide-02.jpg ]] && has "$md" "](01_talk_assets/slide-02.jpg)" "slide images saved and linked" \
    || fail "slide images saved and linked"
  [[ ! -e $T/md/01_talk.pdf && ! -e $T/md/01_talk.txt ]] && ok "md only by default" || fail "md only by default"
else
  fail "md run" "$(cat "$T/md.log")"
fi

echo "Transcript text (--format txt, both engines)"
for engine in yap whisper; do
  d=$T/txt-$engine
  if VIDEO2INFO_STT=$engine run "$T/talk.mp4" -f txt -d "$d" >"$T/$engine.log" 2>&1; then
    f=$d/01_talk.txt
    has "$f" "Title: talk.mp4" "$engine: header"
    has "$f" "Welcome to the talk. Now about Cargo. Thanks for watching." "$engine: full text"
    has "$f" "[00:01] Welcome to the talk." "$engine: first timestamp"
    has "$f" "[01:05] Thanks for watching." "$engine: mm:ss timestamp"
  else
    fail "$engine txt run" "$(cat "$T/$engine.log")"
  fi
done
has "$T/txt-whisper/01_talk.txt" "whisper.cpp model.bin" "whisper: source in Language line"

echo; printf '%d passed, %d failed\n' "$pass" "$failed"
((failed == 0))
