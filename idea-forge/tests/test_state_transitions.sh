#!/usr/bin/env bash
# tests/test_state_transitions.sh
# Unit test: verify the pipeline state machine

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PIPELINE="$PROJECT_ROOT/harness/pipeline.json"

PASS=0
FAIL=0

echo "==== State Machine Tests ===="
echo

# Test 1: All states exist
echo -n "  All states defined ... "
STATES_COUNT=$(jq '.states | keys | length' "$PIPELINE")
if [ "$STATES_COUNT" -gt 0 ]; then
  echo "✓ ($STATES_COUNT states)"
  ((PASS++))
else
  echo "✗"
  ((FAIL++))
fi

# Test 2: All transitions reference valid states
echo -n "  All transitions reference valid states ... "
INVALID=0
for from_state in $(jq -r '.transitions[].from' "$PIPELINE" | sort -u); do
  if ! jq -e ".states[\"$from_state\"]" "$PIPELINE" >/dev/null 2>&1; then
    INVALID=$((INVALID + 1))
  fi
done
for to_state in $(jq -r '.transitions[].to' "$PIPELINE" | sort -u); do
  if ! jq -e ".states[\"$to_state\"]" "$PIPELINE" >/dev/null 2>&1; then
    INVALID=$((INVALID + 1))
  fi
done
if [ $INVALID -eq 0 ]; then
  echo "✓"
  ((PASS++))
else
  echo "✗ ($INVALID invalid)"
  ((FAIL++))
fi

# Test 3: Gate states are valid
echo -n "  All gate targets are valid ... "
INVALID=0
for gate_state in $(jq -r '.states[] | select(.gate) | .gate | keys[]' "$PIPELINE" 2>/dev/null | sort -u); do
  if [ "$gate_state" != "field" ]; then
    target=$(jq -r ".states[] | select(.gate) | .gate[\"$gate_state\"]" "$PIPELINE" 2>/dev/null)
    if [ -n "$target" ] && [ "$target" != "null" ]; then
      if ! jq -e ".states[\"$target\"]" "$PIPELINE" >/dev/null 2>&1; then
        INVALID=$((INVALID + 1))
      fi
    fi
  fi
done
if [ $INVALID -eq 0 ]; then
  echo "✓"
  ((PASS++))
else
  echo "✗ ($INVALID invalid)"
  ((FAIL++))
fi

echo
echo "==== Summary ===="
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo

exit $FAIL
