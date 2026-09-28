#!/usr/bin/env bash
# Build upload zips for claude.ai / Cowork (plugin upload in the Claude app).
# Output: dist/papc-core.zip, dist/product-studio.zip  (plugin root at zip root)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$ROOT/dist"
for p in papc-core product-studio; do
  rm -f "$ROOT/dist/$p.zip"
  (cd "$ROOT/plugins/$p" && zip -qr -X "$ROOT/dist/$p.zip" . -x '*.DS_Store' -x '__pycache__/*' -x '*.pyc')
  echo "dist/$p.zip  $(du -h "$ROOT/dist/$p.zip" | cut -f1)"
done
