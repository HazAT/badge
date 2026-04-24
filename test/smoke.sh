#!/usr/bin/env bash
# Smoke tests for badge.
#
# Runs every CLI flag combination against real fixture icons in an isolated
# tmp dir, so nothing in assets/ gets mutated. This is the project's
# de-facto integration test — there is no other test suite.
#
# Usage (from anywhere):
#   bundle install
#   test/smoke.sh                       # run all tests, clean up after
#   KEEP_ARTIFACTS=1 test/smoke.sh      # keep output images for eyeballing
#   make smoke                          # equivalent, via the Makefile
#
# Requires: ruby, bundler, imagemagick (either `magick` or `convert`),
#           rsvg-convert (for shield rendering).
#
# Exit codes: 0 = all passed, 1 = failures, 2 = missing dependency.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$SCRIPT_DIR/.." && pwd)"
BADGE="$REPO/bin/badge"
WORK="$(mktemp -d -t badge-smoke-XXXXXX)"
OUTDIR="$WORK/outputs"
mkdir -p "$OUTDIR"

cleanup () {
  if [ -z "${KEEP_ARTIFACTS:-}" ]; then
    rm -rf "$WORK"
  else
    echo
    echo "Artifacts kept in: $OUTDIR"
  fi
}
trap cleanup EXIT

# --- dependency checks --------------------------------------------------------

if command -v magick >/dev/null 2>&1; then
  IM=magick
elif command -v convert >/dev/null 2>&1; then
  IM=convert
else
  echo "✗ imagemagick not found (need either 'magick' or 'convert')" >&2
  exit 2
fi

for tool in ruby bundle rsvg-convert; do
  command -v "$tool" >/dev/null 2>&1 || { echo "✗ $tool not found in PATH" >&2; exit 2; }
done

export BUNDLE_GEMFILE="$REPO/Gemfile"
if ! (cd "$REPO" && bundle check >/dev/null 2>&1); then
  echo "✗ bundler dependencies not installed — run 'bundle install' first" >&2
  exit 2
fi

# --- helpers ------------------------------------------------------------------

PASS=0
FAIL=0
FAILURES=()

bytes () { wc -c < "$1" | tr -d ' '; }

ok ()  { PASS=$((PASS + 1));   printf "  \033[32m✓\033[0m  %s\n" "$1"; }
bad () { FAIL=$((FAIL + 1)); FAILURES+=("$1")
         printf "  \033[31m✗\033[0m  %s\n       %s\n" "$1" "${2:-}"; }

# run_case <label> <fixture-in-assets> <target-basename> <expected-file-substring> -- <badge-flags>
run_case () {
  local label="$1"; shift
  local fixture="$1"; shift
  local target_name="$1"; shift
  local expected="$1"; shift
  local target="$WORK/$target_name"

  cp "$REPO/assets/$fixture" "$target"
  local before; before=$(bytes "$target")

  local out rc
  out=$(cd "$WORK" && bundle exec "$BADGE" "$@" --glob "/$target_name" 2>&1)
  rc=$?
  local after; after=$(bytes "$target" 2>/dev/null || echo 0)
  local info; info=$(file --brief "$target")

  if   [ "$rc" -ne 0 ];                        then bad "$label" "exit=$rc"
  elif ! echo "$out"  | grep -q 'Badged';      then bad "$label" "no 'Badged' in output"
  elif [ "$before" = "$after" ];               then bad "$label" "bytes unchanged"
  elif ! echo "$info" | grep -q "$expected";   then bad "$label" "format drift: $info"
  else
    ok "$label"
    cp "$target" "$OUTDIR/$(echo "$label" | tr -c '[:alnum:].' '_').${target_name##*.}"
  fi
  rm -f "$target"
}

# run_case_abs <label> <absolute-src> <ext> <expected-file-substring> -- <badge-flags>
run_case_abs () {
  local label="$1"; shift
  local src="$1"; shift
  local ext="$1"; shift
  local expected="$1"; shift
  local target="$WORK/out.$ext"

  cp "$src" "$target"
  local before; before=$(bytes "$target")

  local out rc
  out=$(cd "$WORK" && bundle exec "$BADGE" "$@" --glob "/out.$ext" 2>&1)
  rc=$?
  local after; after=$(bytes "$target" 2>/dev/null || echo 0)
  local info; info=$(file --brief "$target")

  if   [ "$rc" -ne 0 ];                      then bad "$label" "exit=$rc"
  elif ! echo "$out"  | grep -q 'Badged';    then bad "$label" "no 'Badged' in output"
  elif [ "$before" = "$after" ];             then bad "$label" "bytes unchanged"
  elif ! echo "$info" | grep -q "$expected"; then bad "$label" "format drift: $info"
  else
    ok "$label"
    cp "$target" "$OUTDIR/$(echo "$label" | tr -c '[:alnum:].' '_').$ext"
  fi
  rm -f "$target"
}

# run_unit <label> <ruby-script>
#   ruby script must print a line starting with 'PASS' on success
run_unit () {
  local label="$1"; shift
  local script="$1"; shift

  local out rc
  out=$(cd "$REPO" && bundle exec ruby -Ilib -e "$script" 2>&1)
  rc=$?
  if [ "$rc" -eq 0 ] && echo "$out" | grep -q '^PASS'; then
    ok "$label — $(echo "$out" | grep '^PASS' | tail -1)"
  else
    bad "$label" "$(echo "$out" | tail -5)"
  fi
}

# --- tests --------------------------------------------------------------------

version=$(grep 'VERSION' "$REPO/lib/badge/base.rb" | head -1 | cut -d '"' -f 2)
echo
echo "badge $version smoke tests"
echo

echo "─── A. CLI flag matrix (existing behavior) ───────────────────────────"
run_case "default (light badge)"         icon175x175.png         out.png PNG
run_case "--dark"                        icon175x175.png         out.png PNG  --dark
run_case "--alpha"                       icon175x175.png         out.png PNG  --alpha
run_case "--alpha --dark"                icon175x175.png         out.png PNG  --alpha --dark
run_case "--grayscale"                   icon175x175.png         out.png PNG  --grayscale
run_case "shield aspect-fill"            icon175x175.png         out.png PNG  --shield "1.2-2031-orange" --no_badge
run_case "shield --shield_no_resize"     icon175x175.png         out.png PNG  --shield "1.2-2031-orange" --no_badge --shield_no_resize
run_case "shield + dark"                 icon175x175.png         out.png PNG  --shield "Version-0.0.3-blue" --dark
run_case "shield + geometry + scale"     icon175x175.png         out.png PNG  --shield "Version-0.0.3-blue" --dark --shield_geometry "+0+25%" --shield_scale 0.75
run_case "grayscale + shield + dark"     icon175x175.png         out.png PNG  --grayscale --shield "Version-0.0.3-blue" --dark
run_case "fitrack default"               icon175x175_fitrack.png out.png PNG
run_case "fitrack --dark"                icon175x175_fitrack.png out.png PNG  --dark
run_case "fitrack shield + geometry"     icon175x175_fitrack.png out.png PNG  --shield "Version-0.0.3-blue" --dark --shield_geometry "+0+25%" --shield_scale 0.75

echo
echo "─── B. Input format preservation (webp/jpg) ──────────────────────────"
"$IM" "$REPO/assets/icon175x175.png" "$WORK/src.webp"
"$IM" "$REPO/assets/icon175x175.png" "$WORK/src.jpg"
run_case_abs "WEBP + shield"             "$WORK/src.webp" webp "Web/P"  --shield "smoke-0.1-orange" --no_badge
run_case_abs "WEBP + default badge"      "$WORK/src.webp" webp "Web/P"
run_case_abs "WEBP + dark badge"         "$WORK/src.webp" webp "Web/P" --dark
run_case_abs "JPG + shield"              "$WORK/src.jpg"  jpg  "JPEG"   --shield "smoke-0.1-blue" --no_badge

echo
echo "─── C. Shield URL construction ───────────────────────────────────────"
# Single-quoted heredoc preserves Ruby's #{} interpolation.
run_unit "shield_base_url overrides host" 'require "badge"; require "badge/runner"
captured = nil
MiniMagick::Image.define_singleton_method(:open) { |u| captured = u; raise "stop" }
begin
  Badge::Runner.new.send(:load_shield, "v1-green", "style=flat", "https://shields.internal")
rescue
end
expected = "https://shields.internal/badge/v1-green.svg?style=flat"
puts(captured == expected ? "PASS: #{captured}" : "FAIL: got #{captured.inspect}, want #{expected.inspect}")'

run_unit "default shield URL unchanged" 'require "badge"; require "badge/runner"
captured = nil
MiniMagick::Image.define_singleton_method(:open) { |u| captured = u; raise "stop" }
begin
  Badge::Runner.new.send(:load_shield, "v1-green", nil)
rescue
end
expected = "https://img.shields.io/badge/v1-green.svg"
puts(captured == expected ? "PASS: #{captured}" : "FAIL: got #{captured.inspect}, want #{expected.inspect}")'

echo
echo "─── D. IconCatalog single-size detection ────────────────────────────"
CAT="$WORK/fake-project/Icon.appiconset"
mkdir -p "$CAT"
cp "$REPO/assets/icon175x175.png" "$CAT/AppIcon-1024.png"
cat > "$CAT/Contents.json" <<'JSON'
{
  "images": [
    { "filename": "AppIcon-1024.png", "idiom": "universal", "platform": "ios", "size": "1024x1024" }
  ],
  "info": { "author": "xcode", "version": 1 }
}
JSON
before=$(bytes "$CAT/AppIcon-1024.png")
out=$(cd "$WORK/fake-project" && bundle exec "$BADGE" --shield "catalog-1.0-green" --no_badge 2>&1)
rc=$?
after=$(bytes "$CAT/AppIcon-1024.png")
if [ "$rc" -eq 0 ] && echo "$out" | grep -q 'Badged' && [ "$before" != "$after" ]; then
  ok "IconCatalog autodetect (single-size)"
  cp "$CAT/AppIcon-1024.png" "$OUTDIR/catalog-single-size.png"
else
  bad "IconCatalog autodetect (single-size)" "$(echo "$out" | tail -3)"
fi

# --- summary ------------------------------------------------------------------

echo
echo "─── Summary ──────────────────────────────────────────────────────────"
echo "  passed: $PASS"
echo "  failed: $FAIL"

if [ "$FAIL" -gt 0 ]; then
  echo
  echo "Failures:"
  for f in "${FAILURES[@]}"; do echo "  - $f"; done
  exit 1
fi
