#!/usr/bin/env bash
# tests/test_pipeline_integrity.sh
# End-to-end harness test: validates pipeline.json structure and safe-run.sh behavior

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PIPELINE="$PROJECT_ROOT/harness/pipeline.json"
SAFE_RUN="$PROJECT_ROOT/harness/safe-run.sh"

PASS=0
FAIL=0

echo "==== Pipeline Integrity Tests ===="
echo

# Test 1: pipeline.json exists
echo -n "  pipeline.json exists ... "
if [ -f "$PIPELINE" ]; then
  echo "✓"
  ((PASS++))
else
  echo "✗"
  ((FAIL++))
fi

# Test 2: pipeline.json is valid JSON
echo -n "  pipeline.json is valid JSON ... "
if jq empty "$PIPELINE" 2>/dev/null; then
  echo "✓"
  ((PASS++))
else
  echo "✗"
  ((FAIL++))
fi

# Test 3: safe-run.sh exists and is executable
echo -n "  safe-run.sh exists and is executable ... "
if [ -x "$SAFE_RUN" ]; then
  echo "✓"
  ((PASS++))
else
  echo "✗"
  ((FAIL++))
fi

# Test 4: pipeline.json has required keys
echo -n "  pipeline.json has required keys ... "
if jq -e '.["$schema"] and .title and .states and .transitions' "$PIPELINE" >/dev/null 2>&1; then
  echo "✓"
  ((PASS++))
else
  echo "✗"
  ((FAIL++))
fi

# Test 5: All agents referenced exist
echo -n "  All referenced agents exist ... "
MISSING=0
for agent in $(jq -r '.transitions[].agent' "$PIPELINE" | sort -u); do
  if [ ! -f "$PROJECT_ROOT/agents/${agent}.md" ]; then
    MISSING=$((MISSING + 1))
  fi
done
if [ $MISSING -eq 0 ]; then
  echo "✓"
  ((PASS++))
else
  echo "✗ ($MISSING missing)"
  ((FAIL++))
fi

echo
echo "==== Summary ===="
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo

exit $FAIL
