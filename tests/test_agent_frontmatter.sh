#!/usr/bin/env bash
# tests/test_agent_frontmatter.sh
# Unit test: every agent .md has valid frontmatter

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
AGENTS_DIR="$PROJECT_ROOT/agents"

PASS=0
FAIL=0

echo "==== Agent Frontmatter Tests ===="
echo

for agent_file in "$AGENTS_DIR"/*.md; do
  [ -f "$agent_file" ] || continue
  agent_name=$(basename "$agent_file" .md)

  echo -n "  $agent_name ... "

  # Check required fields in frontmatter
  if grep -q "^name:" "$agent_file" && \
     grep -q "^description:" "$agent_file" && \
     grep -q "^stage:" "$agent_file"; then
    echo "✓"
    ((PASS++))
  else
    echo "✗"
    ((FAIL++))
  fi
done

echo
echo "==== Summary ===="
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo

exit $FAIL
