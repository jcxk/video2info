#!/usr/bin/env bash
# yt-slides installer:
#   curl -fsSL https://raw.githubusercontent.com/jcxk/yt-slides/main/install.sh | bash
# Options (env): PREFIX=~/.local  YT_SLIDES_REF=main  YT_SLIDES_SRC=<url or file:// of bin/yt-slides>
set -euo pipefail

PREFIX=${PREFIX:-$HOME/.local}
REF=${YT_SLIDES_REF:-main}
SRC=${YT_SLIDES_SRC:-https://raw.githubusercontent.com/jcxk/yt-slides/$REF/bin/yt-slides}
DEST=$PREFIX/bin/yt-slides

say()  { printf '\033[1m==>\033[0m %s\n' "$*"; }
fail() { printf '\033[31merror:\033[0m %s\n' "$*" >&2; exit 1; }

command -v curl >/dev/null || fail "curl is required"
tmp=$(mktemp "${TMPDIR:-/tmp}/yt-slides.XXXXXX")
trap 'rm -f "$tmp"' EXIT

say "downloading $SRC"
curl -fsSL "$SRC" -o "$tmp" || fail "download failed: $SRC"
head -n1 "$tmp" | grep -q '^#!/usr/bin/env bash' && grep -q 'yt-slides' "$tmp" || fail "that file is not the yt-slides script"
bash -n "$tmp" || fail "downloaded script has syntax errors"

mkdir -p "$PREFIX/bin"
install -m 755 "$tmp" "$DEST"
say "installed $DEST"

case ":$PATH:" in
  *":$PREFIX/bin:"*) ;;
  *) printf '\033[33mnote:\033[0m %s is not on your PATH. Add this to your shell profile:\n  export PATH="%s:$PATH"\n' \
       "$PREFIX/bin" "$PREFIX/bin" ;;
esac

say "checking dependencies"
if "$DEST" --check; then
  say "ready: yt-slides \"https://www.youtube.com/watch?v=...\""
else
  printf '\n\033[33myt-slides is installed, but it will not run until the missing tools above are installed.\033[0m\n'
fi
