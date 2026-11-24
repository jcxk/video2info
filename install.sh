#!/usr/bin/env bash
# minVid2slides installer:
#   curl -fsSL https://raw.githubusercontent.com/jcxk/minVid2slides/main/install.sh | bash
# Options (env): PREFIX=~/.local  MINVID2SLIDES_REF=main  MINVID2SLIDES_SRC=<url or file:// of bin/minVid2slides>
set -euo pipefail

PREFIX=${PREFIX:-$HOME/.local}
REF=${MINVID2SLIDES_REF:-main}
SRC=${MINVID2SLIDES_SRC:-https://raw.githubusercontent.com/jcxk/minVid2slides/$REF/bin/minVid2slides}
DEST=$PREFIX/bin/minVid2slides

say()  { printf '\033[1m==>\033[0m %s\n' "$*"; }
fail() { printf '\033[31merror:\033[0m %s\n' "$*" >&2; exit 1; }

command -v curl >/dev/null || fail "curl is required"
tmp=$(mktemp "${TMPDIR:-/tmp}/minVid2slides.XXXXXX")
trap 'rm -f "$tmp"' EXIT

say "downloading $SRC"
curl -fsSL "$SRC" -o "$tmp" || fail "download failed: $SRC"
head -n1 "$tmp" | grep -q '^#!/usr/bin/env bash' && grep -q 'minVid2slides' "$tmp" || fail "that file is not the minVid2slides script"
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
  say "ready: minVid2slides \"https://www.youtube.com/watch?v=...\""
else
  printf '\n\033[33mminVid2slides is installed, but it will not run until the missing tools above are installed.\033[0m\n'
fi
