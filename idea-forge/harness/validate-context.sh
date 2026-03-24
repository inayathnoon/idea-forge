#!/usr/bin/env bash
# harness/validate-context.sh
# Verify that all agent context_requires files either exist or are produced by prior stages
# Usage: validate-context.sh [--verbose]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
AGENTS_DIR="$PROJECT_ROOT/agents"
VERBOSE=false

if [ "$1" == "--verbose" ]; then
  VERBOSE=true
fi

ERRORS=0
WARNINGS=0

echo "==== Context Dependency Validation ===="
echo ""

# Stage outputs mapping
get_stage_outputs() {
  local stage=$1
  case $stage in
    1) echo "memory/ideas_store.json" ;;
    2) echo "idea_storage/{slug}-{timestamp}/" ;;
    3) echo "memory/ideas_store.json" ;;
    4) echo "docs/PRODUCT_SENSE.md" ;;
    5) echo "docs/product-specs/mvp.md docs/product-specs/index.md" ;;
    6) echo "ARCHITECTURE.md" ;;
    7) echo "docs/exec-plans/active/mvp-build-plan.md" ;;
    8) echo "GitHub repository" ;;
    *) echo "" ;;
  esac
}

echo "🔗 Checking context dependencies for each agent..."
echo ""

find "$AGENTS_DIR" -name "*.md" -type f | sort | while read -r agent_file; do
  agent_name=$(basename "$agent_file" .md)
  stage=$(sed -n 's/^stage: //p' "$agent_file" | head -1)

  # Skip cross-cutting agents
  if [ "$stage" = "cross-cutting" ]; then
    continue
  fi

  # Extract context_requires
  in_context=false
  context_files=""
  while IFS= read -r line; do
    if [[ "$line" =~ ^context_requires: ]]; then
      in_context=true
      continue
    fi
    if [ "$in_context" = true ]; then
      if [[ "$line" =~ ^[a-z] ]]; then
        in_context=false
      elif [[ "$line" =~ ^[[:space:]]*- ]]; then
        file=$(echo "$line" | sed 's/^[[:space:]]*- //' | tr -d ' ')
        context_files="$context_files $file"
      fi
    fi
  done < "$agent_file"

  if [ -z "$context_files" ]; then
    if [ "$VERBOSE" = true ]; then
      echo "  ✅ $agent_name (stage $stage): no context required"
    fi
    continue
  fi

  # Check each context file
  missing_context=""
  for ctx_file in $context_files; do
    # Normalize path patterns
    ctx_file_normalized=$(echo "$ctx_file" | sed 's/{slug}-{timestamp}.*/{slug}-{timestamp}\//' | sed 's/{idea\.name}\/.*/{idea.name}\//')

    # Check if file exists
    if [ ! -f "$PROJECT_ROOT/$ctx_file" ] && [ ! -d "$PROJECT_ROOT/$ctx_file" ]; then
      # Check if this is produced by an earlier stage
      produced=false
      for prev_stage in $(seq 1 $((stage - 1))); do
        stage_outputs=$(get_stage_outputs "$prev_stage")
        if [ -n "$stage_outputs" ]; then
          for output in $stage_outputs; do
            if [[ "$ctx_file_normalized" == *"$output"* ]] || [[ "$output" == *"$ctx_file_normalized"* ]]; then
              produced=true
              break
            fi
          done
        fi
      done

      if [ "$produced" = false ]; then
        missing_context="$missing_context $ctx_file"
      fi
    fi
  done

  if [ -n "$missing_context" ]; then
    echo "❌ $agent_name (stage $stage) requires missing context:$missing_context"
    ERRORS=$((ERRORS + 1))
  elif [ "$VERBOSE" = true ]; then
    echo "  ✅ $agent_name (stage $stage): all context available"
  fi
done

# Summary
echo ""
echo "==== Validation Summary ===="
if [ "$ERRORS" -gt 0 ]; then
  echo "❌ Found $ERRORS context dependency errors"
  exit 1
else
  echo "✅ All context dependencies are satisfied"
  if [ "$WARNINGS" -gt 0 ]; then
    echo "⚠️  ($WARNINGS warnings)"
  fi
fi
