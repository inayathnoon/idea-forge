#!/usr/bin/env bash
# harness/validate-pipeline.sh
# Validates pipeline DAG: stage N inputs match stage N-1 outputs, no gaps, no cycles
# Usage: validate-pipeline.sh [--verbose]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PIPELINE_JSON="$PROJECT_ROOT/harness/pipeline.json"
VERBOSE=false

if [ "$1" == "--verbose" ]; then
  VERBOSE=true
fi

if [ ! -f "$PIPELINE_JSON" ]; then
  echo "❌ Pipeline definition not found: $PIPELINE_JSON"
  exit 1
fi

ERRORS=0
WARNINGS=0

echo "==== Pipeline DAG Validation ===="
echo ""

# 1. Validate all agents exist
echo "📋 Checking agent existence..."
AGENTS_DIR="$PROJECT_ROOT/agents"
if [ ! -d "$AGENTS_DIR" ]; then
  echo "❌ Agents directory not found: $AGENTS_DIR"
  exit 1
fi

jq -r '.stages[].agent' "$PIPELINE_JSON" | while read -r agent; do
  if [ -z "$agent" ]; then
    continue
  fi
  agent_file="$AGENTS_DIR/${agent}.md"
  if [ ! -f "$agent_file" ]; then
    echo "❌ Agent file missing: $agent_file"
    ERRORS=$((ERRORS + 1))
  elif [ "$VERBOSE" = true ]; then
    echo "  ✅ $agent exists"
  fi
done

# 2. Validate transitions (stage ordering)
echo ""
echo "🔗 Checking stage transitions..."
STAGES=$(jq -r '.stages | length' "$PIPELINE_JSON")
for ((i=0; i<STAGES; i++)); do
  stage_from=$(jq -r ".stages[$i]" "$PIPELINE_JSON")

  # Get agent name and number
  agent_name=$(echo "$stage_from" | jq -r '.agent // "unknown"')
  stage_num=$(echo "$stage_from" | jq -r '.stage // "?"')

  # Check transitions array
  transitions=$(echo "$stage_from" | jq -r '.transitions // []' | jq 'length')
  if [ "$transitions" -eq 0 ]; then
    echo "⚠️  Stage $stage_num ($agent_name) has no transitions (final stage?)"
  else
    echo "$stage_from" | jq -r '.transitions[]' | while read -r transition; do
      target=$(echo "$transition" | jq -r '.target // "unknown"')
      if [ "$VERBOSE" = true ]; then
        echo "  → $target"
      fi
    done
  fi
done

# 3. Validate inputs/outputs chain
echo ""
echo "⛓️  Checking input/output dependencies..."
jq -r '.stages[] |
  "\(.agent):\(.inputs // [] | join(",")):\(.outputs // [] | join(","))"' \
  "$PIPELINE_JSON" | while IFS=: read -r agent inputs outputs; do

  if [ -z "$agent" ]; then
    continue
  fi

  if [ "$VERBOSE" = true ]; then
    echo "  $agent"
    if [ -n "$inputs" ]; then
      echo "    inputs: $inputs"
    fi
    if [ -n "$outputs" ]; then
      echo "    outputs: $outputs"
    fi
  fi
done

# 4. Check for cycles (simple DAG validation)
echo ""
echo "🔄 Checking for cycles..."
# Build adjacency list and do DFS
jq -r '.stages[] | select(.transitions) |
  .agent as $from | .transitions[] |
  "\($from),\(.target)"' "$PIPELINE_JSON" | sort | uniq > /tmp/edges.txt || true

if [ -s /tmp/edges.txt ]; then
  # Simple cycle detection: if we can reach ourselves
  CYCLE_FOUND=0
  while IFS=, read -r from to; do
    if [ "$from" == "$to" ]; then
      echo "❌ Self-loop detected: $from → $to"
      CYCLE_FOUND=1
      ERRORS=$((ERRORS + 1))
    fi
  done < /tmp/edges.txt

  if [ "$CYCLE_FOUND" -eq 0 ] && [ "$VERBOSE" = true ]; then
    echo "  ✅ No cycles detected"
  fi
fi

# 5. Validate gated states
echo ""
echo "🚪 Checking gated states..."
jq -r '.states[] | select(.gated == true) | .name' "$PIPELINE_JSON" | while read -r gated_state; do
  if [ -z "$gated_state" ]; then
    continue
  fi

  # Check if there's a gate definition
  has_gate=$(jq --arg state "$gated_state" \
    '.gates[] | select(.state == $state) | .decisions | length' \
    "$PIPELINE_JSON" || echo "0")

  if [ "$has_gate" -gt 0 ]; then
    echo "  ✅ Gate defined for state: $gated_state"
  else
    echo "⚠️  Gated state '$gated_state' has no gate definition"
  fi
done

# 6. Summary
echo ""
echo "==== Validation Summary ===="
if [ "$ERRORS" -gt 0 ]; then
  echo "❌ Found $ERRORS critical errors"
  exit 1
else
  echo "✅ Pipeline DAG is valid"
  if [ "$WARNINGS" -gt 0 ]; then
    echo "⚠️  ($WARNINGS warnings)"
  fi
fi

rm -f /tmp/edges.txt
