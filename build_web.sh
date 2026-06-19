#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${PROJECT_DIR}/build/web"

if command -v godot4 >/dev/null 2>&1; then
  GODOT_BIN="godot4"
elif command -v godot >/dev/null 2>&1; then
  GODOT_BIN="godot"
else
  echo "Godot CLI was not found. Install Godot 4 and export templates, then retry." >&2
  exit 127
fi

mkdir -p "${OUTPUT_DIR}"
"${GODOT_BIN}" --headless --path "${PROJECT_DIR}" --export-release "Web" "${OUTPUT_DIR}/index.html"

echo "Web build ready at ${OUTPUT_DIR}"
