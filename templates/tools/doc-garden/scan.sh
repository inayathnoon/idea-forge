#!/bin/bash

# Doc-Gardening Scanner
# Detects stale documentation: broken file references, placeholders, TODOs
# Usage: bash tools/doc-garden/scan.sh [docs-dir] [src-dir]

set -uo pipefail

DOCS_DIR="${1:-.}"
SRC_DIR="${2:-.}"
TEMP_REPORT=$(mktemp)
EXIT_CODE=0

# Color codes
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

{
  echo "=========================================="
  echo "Doc-Gardening Scan Report"
  echo "=========================================="
  echo ""

  # Section 1: Stale file references
  echo "📋 Scanning for stale file references..."
  STALE_COUNT=0

  while IFS= read -r md_file; do
    # Extract paths from backticks: `path/to/file.ts`
    while IFS= read -r ref; do
      # Remove backticks
      ref_clean="${ref#\`}"
      ref_clean="${ref_clean%\`}"

      # Skip URLs and anchors
      if [[ "$ref_clean" =~ ^http ]] || [[ "$ref_clean" =~ ^# ]] || [[ "$ref_clean" =~ ^// ]]; then
        continue
      fi

      # Skip very short refs
      if [ ${#ref_clean} -lt 3 ]; then
        continue
      fi

      # Check if file/dir exists
      if ! [ -f "$ref_clean" ] && ! [ -d "$ref_clean" ]; then
        echo "STALE: $(basename "$md_file") references '$ref_clean' — not found"
        ((STALE_COUNT++))
        EXIT_CODE=2
      fi
    done < <(grep -oE '\`[a-zA-Z0-9_/.=-]+\.(ts|js|py|json|yaml|yml|toml|sh|md)\`' "$md_file" 2>/dev/null || true)

    # Extract paths from markdown links: [text](path)
    while IFS= read -r ref; do
      # Remove parentheses and brackets
      ref_clean="${ref#\[}"
      ref_clean="${ref_clean%\]}"
      ref_clean="${ref_clean#(}"
      ref_clean="${ref_clean%)}"

      # Skip URLs and anchors
      if [[ "$ref_clean" =~ ^http ]] || [[ "$ref_clean" =~ ^# ]] || [[ "$ref_clean" =~ ^// ]]; then
        continue
      fi

      # Skip very short refs
      if [ ${#ref_clean} -lt 3 ]; then
        continue
      fi

      # Check if file/dir exists
      if ! [ -f "$ref_clean" ] && ! [ -d "$ref_clean" ]; then
        echo "STALE: $(basename "$md_file") references '$ref_clean' — not found"
        ((STALE_COUNT++))
        EXIT_CODE=2
      fi
    done < <(grep -oE '\]\([a-zA-Z0-9_/.=-]+\)' "$md_file" 2>/dev/null || true)
  done < <(find "$DOCS_DIR" -name "*.md" -type f ! -path "*/node_modules/*" ! -path "*/.git/*" 2>/dev/null || true)

  if [ $STALE_COUNT -eq 0 ]; then
    echo -e "${GREEN}✓${NC} No stale file references found"
  else
    echo -e "${RED}✗${NC} Found $STALE_COUNT stale file references"
  fi
  echo ""

  # Section 2: Unfilled placeholders (template variables like {project_name})
  echo "📋 Scanning for placeholders..."
  PLACEHOLDER_COUNT=0

  while IFS= read -r md_file; do
    # Skip frontmatter (YAML between --- markers) and code blocks
    MATCHES=$(grep -n '{[a-z_][a-z_]*}' "$md_file" 2>/dev/null | grep -v '^\s*#' | grep -v 'LINEAR_' | grep -v 'ISSUE-ID' | grep -v '```' | head -5 || true)
    if [ -n "$MATCHES" ]; then
      echo "PLACEHOLDER: $(basename "$md_file")"
      echo "$MATCHES" | sed 's/^/  /'
      PLACEHOLDER_COUNT=$((PLACEHOLDER_COUNT + $(echo "$MATCHES" | wc -l)))
      EXIT_CODE=2
    fi
  done < <(find "$DOCS_DIR" -name "*.md" -type f ! -path "*/node_modules/*" ! -path "*/.git/*" 2>/dev/null || true)

  if [ $PLACEHOLDER_COUNT -eq 0 ]; then
    echo -e "${GREEN}✓${NC} No unfilled placeholders found"
  else
    echo -e "${RED}✗${NC} Found $PLACEHOLDER_COUNT unfilled placeholders"
  fi
  echo ""

  # Section 3: TODO/TBD/FIXME markers
  echo "📋 Scanning for TODO/TBD/FIXME markers..."
  TODO_COUNT=0

  while IFS= read -r md_file; do
    MATCHES=$(grep -n -i 'TODO\|TBD\|FIXME' "$md_file" 2>/dev/null | head -5 || true)
    if [ -n "$MATCHES" ]; then
      echo "TODO: $(basename "$md_file")"
      echo "$MATCHES" | sed 's/^/  /'
      TODO_COUNT=$((TODO_COUNT + $(echo "$MATCHES" | wc -l)))
      EXIT_CODE=2
    fi
  done < <(find "$DOCS_DIR" -name "*.md" -type f ! -path "*/node_modules/*" ! -path "*/.git/*" 2>/dev/null || true)

  if [ $TODO_COUNT -eq 0 ]; then
    echo -e "${GREEN}✓${NC} No TODO/TBD/FIXME markers found"
  else
    echo -e "${RED}✗${NC} Found $TODO_COUNT TODO/TBD/FIXME markers"
  fi
  echo ""

  # Summary
  echo "=========================================="
  TOTAL=$((STALE_COUNT + PLACEHOLDER_COUNT + TODO_COUNT))
  if [ $TOTAL -eq 0 ]; then
    echo -e "${GREEN}✅ Documentation is clean${NC}"
  else
    echo -e "${RED}❌ Found $TOTAL issues to address${NC}"
  fi
  echo "=========================================="

}

exit $EXIT_CODE
