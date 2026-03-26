#!/bin/bash

# Garbage Collection Scanner
# Detects dead code, duplicates, convention violations, unused dependencies
# Usage: bash tools/gc/run-gc.sh [src-dir]

set -uo pipefail

SRC_DIR="${1:-.}"
EXIT_CODE=0

# Color codes
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

echo "=========================================="
echo "Garbage Collection Scan"
echo "=========================================="
echo ""

# Section 1: Convention Violations
echo "📋 Checking convention violations..."
VIOLATION_COUNT=0

if [ -f "tools/lint/run-all-lints.sh" ]; then
  LINT_OUTPUT=$(bash tools/lint/run-all-lints.sh "$SRC_DIR" 2>&1 || true)
  VIOLATION_COUNT=$(echo "$LINT_OUTPUT" | grep -c "VIOLATION:" || true)

  if [ $VIOLATION_COUNT -gt 0 ]; then
    echo -e "${RED}✗${NC} Found $VIOLATION_COUNT convention violations"
    EXIT_CODE=2
  else
    echo -e "${GREEN}✓${NC} No convention violations"
  fi
else
  echo "⚠️  Linter not found"
fi
echo ""

# Section 2: Unused Dependencies (Node)
echo "📋 Checking for unused dependencies..."
UNUSED_DEPS=0

if [ -f "package.json" ] && command -v npx &>/dev/null; then
  # Check if depcheck is available
  DEPCHECK_OUTPUT=$(npx depcheck --json 2>/dev/null || echo "{}")

  # Count unused dependencies
  UNUSED_DEPS=$(echo "$DEPCHECK_OUTPUT" | grep -o '"dependencies"' | wc -l || true)

  if [ $UNUSED_DEPS -gt 0 ]; then
    echo -e "${RED}✗${NC} Found $UNUSED_DEPS unused dependencies"
    EXIT_CODE=2
  else
    echo -e "${GREEN}✓${NC} No unused dependencies detected"
  fi
else
  echo "ℹ️  No package.json or npx available"
fi
echo ""

# Section 3: File-level imports
echo "📋 Scanning for orphaned files..."
ORPHAN_COUNT=0

find "$SRC_DIR" -type f \( -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" \) ! -path "*node_modules*" ! -path "*.test.*" 2>/dev/null | while read -r file; do
  # Skip index files and tests
  if [[ "$file" =~ (index\.(js|ts|jsx|tsx)|\.test\.|\.spec\.) ]]; then
    continue
  fi

  # Check if this file is imported anywhere else
  BASENAME=$(basename "$file")
  FILENAME="${BASENAME%.*}"

  # Simple heuristic: files that are never imported might be dead code
  if ! grep -r "from.*$FILENAME\|import.*$FILENAME\|require.*$FILENAME" "$SRC_DIR" --exclude-dir=node_modules --exclude="*.test.js" --exclude="*.test.ts" >/dev/null 2>&1; then
    # Could be a dead file, but only if not an entry point
    if [[ ! "$file" =~ (index\.|main\.|app\.) ]]; then
      echo "ORPHAN: $file (no imports found)"
      ORPHAN_COUNT=$((ORPHAN_COUNT + 1))
    fi
  fi
done

if [ $ORPHAN_COUNT -gt 0 ]; then
  echo -e "${YELLOW}⚠️${NC}  Found $ORPHAN_COUNT potentially orphaned files"
  EXIT_CODE=2
else
  echo -e "${GREEN}✓${NC} No obviously orphaned files"
fi
echo ""

# Section 4: Summary
echo "=========================================="
TOTAL=$((VIOLATION_COUNT + UNUSED_DEPS + ORPHAN_COUNT))

if [ $TOTAL -eq 0 ]; then
  echo -e "${GREEN}✅ Codebase is clean${NC}"
else
  echo -e "${RED}❌ Found $TOTAL issues to address${NC}"
  echo ""
  echo "Run entropy management to:"
  echo "  1. Fix convention violations"
  echo "  2. Remove unused dependencies"
  echo "  3. Review and delete orphaned files"
fi
echo "=========================================="

exit $EXIT_CODE
