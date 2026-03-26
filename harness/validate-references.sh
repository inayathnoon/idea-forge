#!/usr/bin/env bash
# harness/validate-references.sh
# Verify all ## References links in docs resolve to actual files
# Usage: validate-references.sh [docs-dir]

set -e

DOCS_DIR="${1:-docs}"
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BROKEN=0
CHECKED=0

echo "==== Reference Validation ===="
echo ""

# Find all markdown files
for md_file in $(find "$DOCS_DIR" -name "*.md" 2>/dev/null || true); do
  # Extract ## References section
  if grep -q "^## References" "$md_file"; then
    CHECKED=$((CHECKED + 1))

    # Extract all markdown links from References section
    while IFS= read -r line; do
      if [[ $line =~ \]\(([^)]+)\) ]]; then
        REF="${BASH_REMATCH[1]}"

        # Resolve relative path
        REF_DIR=$(dirname "$md_file")
        if [[ "$REF" == /* ]]; then
          # Absolute path from project root
          FULL_PATH="$PROJECT_ROOT${REF}"
        elif [[ "$REF" == ../* ]]; then
          # Relative path
          FULL_PATH="$REF_DIR/$REF"
        else
          # Relative to same directory
          FULL_PATH="$REF_DIR/$REF"
        fi

        # Normalize path
        FULL_PATH="$(cd "$(dirname "$FULL_PATH")" && pwd)/$(basename "$FULL_PATH")" 2>/dev/null || true

        if [ ! -e "$FULL_PATH" ]; then
          echo "❌ $md_file: Broken reference → [$REF]"
          echo "   Expected file: $FULL_PATH"
          BROKEN=$((BROKEN + 1))
        fi
      fi
    done < <(awk '/^## References/,/^##[^#]/' "$md_file" | grep -E '\]\(')
  fi
done

echo ""
echo "==== Summary ===="
echo "Checked: $CHECKED files"
echo "Broken: $BROKEN references"
echo ""

if [ $BROKEN -eq 0 ]; then
  echo "✅ All references valid"
  exit 0
else
  echo "❌ Found $BROKEN broken references"
  exit 1
fi
