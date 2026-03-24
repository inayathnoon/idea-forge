#!/usr/bin/env bash
# harness/validate-ideas-store.sh
# Validates memory/ideas_store.json against schema on every read/write
# Catches data corruption before it propagates through the pipeline
# Usage: validate-ideas-store.sh [--verbose] [--fix]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
IDEAS_STORE="$PROJECT_ROOT/memory/ideas_store.json"
VERBOSE=false
FIX_MODE=false

if [ "$1" == "--verbose" ]; then
  VERBOSE=true
fi

if [ "$2" == "--fix" ]; then
  FIX_MODE=true
fi

if [ ! -f "$IDEAS_STORE" ]; then
  echo "❌ Ideas store not found: $IDEAS_STORE"
  exit 1
fi

ERRORS=0
WARNINGS=0

echo "==== Ideas Store Validation ===="
echo ""

# 1. Validate JSON structure
echo "🔍 Validating JSON structure..."
if ! jq empty "$IDEAS_STORE" 2>/dev/null; then
  echo "❌ Invalid JSON: $IDEAS_STORE cannot be parsed"
  ERRORS=$((ERRORS + 1))
  exit 1
fi
echo "  ✅ JSON is valid"
echo ""

# 2. Check root structure
echo "📋 Checking root structure..."
root_type=$(jq -r 'type' "$IDEAS_STORE")
if [ "$root_type" != "object" ]; then
  echo "❌ Root must be an object, got: $root_type"
  ERRORS=$((ERRORS + 1))
fi

ideas_exists=$(jq 'has("ideas")' "$IDEAS_STORE")
if [ "$ideas_exists" != "true" ]; then
  echo "❌ Missing 'ideas' field in root"
  ERRORS=$((ERRORS + 1))
else
  ideas_type=$(jq -r '.ideas | type' "$IDEAS_STORE")
  if [ "$ideas_type" != "array" ]; then
    echo "❌ 'ideas' field must be an array, got: $ideas_type"
    ERRORS=$((ERRORS + 1))
  else
    idea_count=$(jq '.ideas | length' "$IDEAS_STORE")
    echo "  ✅ Root structure valid, found $idea_count ideas"
  fi
fi
echo ""

# 3. Validate each idea object
echo "🧠 Validating idea objects..."

REQUIRED_FIELDS=("name" "full_name" "problem" "solution" "target_users" "tech_stack" "mvp_features")

jq -c '.ideas[] | {name: .name, idx: input_line_number}' "$IDEAS_STORE" 2>/dev/null | while read -r idea_obj; do
  # Extract name safely
  idea_name=$(echo "$idea_obj" | jq -r '.name // "unknown"')

  # Check required fields using jq from the original file
  missing_fields=""
  for field in "${REQUIRED_FIELDS[@]}"; do
    has_field=$(jq --arg name "$idea_name" ".ideas[] | select(.name == \$name) | has(\"$field\")" "$IDEAS_STORE" 2>/dev/null || echo "false")
    if [ "$has_field" != "true" ]; then
      missing_fields="$missing_fields $field"
    fi
  done

  if [ -n "$missing_fields" ]; then
    echo "❌ Idea '$idea_name' missing fields:$missing_fields"
    ERRORS=$((ERRORS + 1))
  elif [ "$VERBOSE" = true ]; then
    echo "  ✅ Idea '$idea_name' has all required fields"
  fi

  # Check stage field if present
  stage=$(jq --arg name "$idea_name" ".ideas[] | select(.name == \$name) | .stage // \"unknown\"" "$IDEAS_STORE" 2>/dev/null)
  if [ -n "$stage" ] && [ "$stage" != "\"unknown\"" ]; then
    stage_clean=$(echo "$stage" | tr -d '"')
    valid_stages=("raw" "structured" "explored" "reviewed" "researched" "prd_written" "arch_written" "plan_written" "built")
    stage_valid=false
    for valid_stage in "${valid_stages[@]}"; do
      if [ "$stage_clean" = "$valid_stage" ]; then
        stage_valid=true
        break
      fi
    done
    if [ "$stage_valid" = false ]; then
      echo "⚠️  Idea '$idea_name' has invalid stage: $stage_clean"
      WARNINGS=$((WARNINGS + 1))
    fi
  fi
done

# 4. Check for duplicate names
echo ""
echo "🔑 Checking for duplicate idea names..."
duplicate_count=$(jq '[.ideas[].name] | group_by(.) | map(select(length > 1)) | length' "$IDEAS_STORE")
if [ "$duplicate_count" -gt 0 ]; then
  echo "❌ Found $duplicate_count duplicate idea names"
  ERRORS=$((ERRORS + 1))
else
  echo "  ✅ No duplicate idea names"
fi

# 5. Check for orphaned ideas (no stage set)
echo ""
echo "📍 Checking for incomplete ideas..."
orphaned=$(jq '[.ideas[] | select(.stage == null or .stage == "") | .name] | length' "$IDEAS_STORE")
if [ "$orphaned" -gt 0 ]; then
  echo "⚠️  $orphaned ideas have no stage set (may be incomplete)"
  WARNINGS=$((WARNINGS + 1))
  if [ "$VERBOSE" = true ]; then
    jq -r '.ideas[] | select(.stage == null or .stage == "") | "  - \(.name)"' "$IDEAS_STORE"
  fi
fi

# 6. Check file size
echo ""
echo "📦 Checking file size..."
file_size=$(stat -f%z "$IDEAS_STORE" 2>/dev/null || stat -c%s "$IDEAS_STORE" 2>/dev/null || echo "0")
if [ "$file_size" -lt 100 ]; then
  echo "⚠️  Ideas store file is suspiciously small ($file_size bytes)"
  WARNINGS=$((WARNINGS + 1))
elif [ "$VERBOSE" = true ]; then
  echo "  ✅ File size: $file_size bytes"
fi

# 7. Check last modified time
echo ""
echo "⏰ Checking file freshness..."
last_modified=$(stat -f%Sm -t "%Y-%m-%d %H:%M:%S" "$IDEAS_STORE" 2>/dev/null || stat -c%y "$IDEAS_STORE" 2>/dev/null | cut -d' ' -f1-2 || echo "unknown")
echo "  Last modified: $last_modified"

# Summary
echo ""
echo "==== Validation Summary ===="
if [ "$ERRORS" -gt 0 ]; then
  echo "❌ Found $ERRORS critical errors"
  exit 1
else
  idea_count=$(jq '.ideas | length' "$IDEAS_STORE")
  echo "✅ Ideas store is valid ($idea_count ideas)"
  if [ "$WARNINGS" -gt 0 ]; then
    echo "⚠️  ($WARNINGS warnings)"
  fi
fi
