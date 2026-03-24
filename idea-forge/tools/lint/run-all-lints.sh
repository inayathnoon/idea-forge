#!/bin/bash

# Custom Linters Entry Point
# Runs all project-specific linters with remediation guidance
# Usage: bash tools/lint/run-all-lints.sh [src_dir]

set -uo pipefail

SRC="${1:-src}"
FAILED=0
LINTER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "Running Custom Linters"
echo "=========================================="
echo ""

# Architecture lint
echo "--- Architecture Layer Lint ---"
if [ -f "$LINTER_DIR/architecture-lint.js" ]; then
  node "$LINTER_DIR/architecture-lint.js" "$SRC"
  if [ $? -ne 0 ]; then FAILED=1; fi
else
  echo "WARNING: architecture-lint.js not found"
fi
echo ""

# Naming/size lint
echo "--- Naming & Size Lint ---"
if [ -f "$LINTER_DIR/naming-lint.js" ]; then
  node "$LINTER_DIR/naming-lint.js" "$SRC"
  if [ $? -ne 0 ]; then FAILED=1; fi
else
  echo "WARNING: naming-lint.js not found"
fi
echo ""

# Standard linters (if configured)
if command -v eslint &>/dev/null; then
  echo "--- ESLint ---"
  eslint "$SRC" --max-warnings 0 || FAILED=1
  echo ""
fi

if command -v ruff &>/dev/null; then
  echo "--- Ruff (Python) ---"
  ruff check "$SRC" || FAILED=1
  echo ""
fi

# Summary
echo "=========================================="
echo "Lint Summary"
echo "=========================================="
if [ $FAILED -eq 0 ]; then
  echo "✅ PASS: All linters passed."
  exit 0
else
  echo "❌ FAIL: See above for details and remediation instructions."
  exit 1
fi
