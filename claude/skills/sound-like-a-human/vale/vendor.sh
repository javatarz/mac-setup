#!/bin/bash
# Vendor the third-party Vale packages into styles/. Fetches a pinned release from GitHub and
# replaces that package's folders, so an update is one command plus a reviewable `git diff`.
# Nothing else fetches packages: vale.ini has no `Packages =` line, and Vale never touches the network.
#
# Usage:
#   vendor.sh                    re-vendor every package at the pins below
#   vendor.sh ai-tells           re-vendor one package at its pin (ai-tells, voices, std, en_GB)
#   vendor.sh ai-tells v1.38.0   vendor a different tag (then edit the pin below and review the diff)
set -euo pipefail

AI_TELLS_TAG="v1.37.0"    # github.com/tbhb/vale-ai-tells, MIT
VOICES_TAG="v0.2.0"       # github.com/jdkato/voices, MIT (Voices, Direct, Human styles)
STD_TAG="v0.2.1"          # github.com/vale-cli/Std, MIT (Direct.Length extends Std.Readability.SentenceLength)
EN_GB_COMMIT="e7f163f"    # github.com/LibreOffice/dictionaries, en/en_GB.dic and .aff (LGPL, see README_en_GB.txt)

here="$(cd "$(dirname "$0")" && pwd)"
styles="$here/styles"
tmp="$(mktemp -d)"
trap 'rm -rf "${tmp:?}"' EXIT

fetch() { curl -fsSL --retry 2 -o "$2" "$1" || { echo "ERROR: could not download $1" >&2; echo "  fix: check the tag exists and you are online, then re-run vendor.sh" >&2; exit 1; }; }

stamp() { printf 'Vendored by vale/vendor.sh. Do not edit: re-run vendor.sh instead.\nSource: %s\nVersion: %s\n' "$2" "$3" > "$1"; }

vendor_ai_tells() {
  local tag="${1:-$AI_TELLS_TAG}" repo=tbhb/vale-ai-tells
  fetch "https://github.com/$repo/releases/download/$tag/ai-tells.zip" "$tmp/ai-tells.zip"
  unzip -q "$tmp/ai-tells.zip" -d "$tmp/ai-tells"
  rm -rf "${styles:?}/ai-tells"
  cp -R "$tmp/ai-tells/ai-tells/styles/ai-tells" "$styles/ai-tells"
  fetch "https://raw.githubusercontent.com/$repo/$tag/LICENSE" "$styles/ai-tells/LICENSE"
  stamp "$styles/ai-tells/VENDORED" "https://github.com/$repo" "$tag"
  echo "ai-tells $tag: $(find "$styles/ai-tells" -name '*.yml' | wc -l | tr -d ' ') rules"
}

vendor_voices() {
  local tag="${1:-$VOICES_TAG}" repo=jdkato/voices s
  fetch "https://github.com/$repo/releases/download/$tag/Voices.zip" "$tmp/Voices.zip"
  unzip -q "$tmp/Voices.zip" -d "$tmp/voices"
  # Only the three styles the skill uses. Claude, Coach, GenZ and Simple stay behind.
  for s in Voices Direct Human; do
    rm -rf "${styles:?}/${s:?}"
    cp -R "$tmp/voices/Voices/styles/$s" "$styles/$s"
    cp "$tmp/voices/Voices/LICENSE" "$tmp/voices/Voices/NOTICE" "$styles/$s/"
    stamp "$styles/$s/VENDORED" "https://github.com/$repo" "$tag"
  done
  echo "Voices $tag: Voices, Direct, Human"
}

vendor_std() {
  local tag="${1:-$STD_TAG}" repo=vale-cli/Std
  fetch "https://github.com/$repo/releases/download/$tag/Std.zip" "$tmp/Std.zip"
  unzip -q "$tmp/Std.zip" -d "$tmp/std"
  rm -rf "${styles:?}/Std"
  cp -R "$tmp/std/Std" "$styles/Std"
  stamp "$styles/Std/VENDORED" "https://github.com/$repo" "$tag"
  echo "Std $tag"
}

vendor_en_gb() {
  local ref="${1:-$EN_GB_COMMIT}" f dir="$styles/config/dictionaries"
  mkdir -p "$dir"
  for f in en_GB.dic en_GB.aff README_en_GB.txt; do
    fetch "https://raw.githubusercontent.com/LibreOffice/dictionaries/$ref/en/$f" "$dir/$f"
  done
  stamp "$dir/VENDORED_en_GB" "https://github.com/LibreOffice/dictionaries (en/en_GB.*)" "$ref"
  echo "en_GB $ref"
}

case "${1:-all}" in
  ai-tells) vendor_ai_tells "${2:-}" ;;
  voices)   vendor_voices "${2:-}" ;;
  std)      vendor_std "${2:-}" ;;
  en_GB)    vendor_en_gb "${2:-}" ;;
  all)      vendor_ai_tells; vendor_voices; vendor_std; vendor_en_gb ;;
  *) echo "usage: vendor.sh [ai-tells|voices|std|en_GB [tag]]" >&2; exit 2 ;;
esac
