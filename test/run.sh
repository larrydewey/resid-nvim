#!/bin/sh
# Headless checks: filetype, syntax, a reindent fixed point, the error
# format, and the language server end to end when residc is installed.
set -eu
here=$(cd "$(dirname "$0")/.." && pwd)
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cp "$here/test/sample.resid" "$work/sample.resid"
printf '/// A helper.\npub Int helper() { return 1; }\n' > "$work/util.resid"
touch "$work/resid.toml"
cd "$work"
if nvim --headless --clean --cmd "set rtp^=$here" \
     -c "runtime! plugin/resid.lua" -c 'edit sample.resid' -c "luafile $here/test/checks.lua"; then
  echo "resid-nvim: all checks passed"
else
  echo "resid-nvim: tests failed"
  exit 1
fi
