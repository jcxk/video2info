#!/usr/bin/env bash
# video2info installer:
#   curl -fsSL https://raw.githubusercontent.com/jcxk/video2info/main/install.sh | bash
# Options (env): PREFIX=~/.local  VIDEO2INFO_REF=main  VIDEO2INFO_SRC=<url or file:// of bin/video2info>
set -euo pipefail

PREFIX=${PREFIX:-$HOME/.local}
REF=${VIDEO2INFO_REF:-main}
SRC=${VIDEO2INFO_SRC:-https://raw.githubusercontent.com/jcxk/video2info/$REF/bin/video2info}
DEST=$PREFIX/bin/video2info

say()  { printf '\033[1m==>\033[0m %s\n' "$*"; }
fail() { printf '\033[31merror:\033[0m %s\n' "$*" >&2; exit 1; }

command -v curl >/dev/null || fail "curl is required"
tmp=$(mktemp "${TMPDIR:-/tmp}/video2info.XXXXXX")
trap 'rm -f "$tmp"' EXIT

say "downloading $SRC"
curl -fsSL "$SRC" -o "$tmp" || fail "download failed: $SRC"
head -n1 "$tmp" | grep -q '^#!/usr/bin/env bash' && grep -q 'video2info' "$tmp" || fail "that file is not the video2info script"
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
  say "ready: video2info \"https://www.youtube.com/watch?v=...\""
else
  printf '\n\033[33mvideo2info is installed, but it will not run until the missing tools above are installed.\033[0m\n'
fi
