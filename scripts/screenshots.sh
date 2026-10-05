#!/usr/bin/env bash
# Regenerates docs/screenshots on a booted iOS simulator (macOS only).
#
# Usage: scripts/screenshots.sh ["iPhone 17"]
set -euo pipefail

DEVICE="${1:-iPhone 17}"

flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/screenshots_test.dart \
  -d "$DEVICE"

# Half resolution is plenty for the README and keeps the repository small.
for file in docs/screenshots/*.png; do
  sips --resampleWidth 603 "$file" >/dev/null
done
