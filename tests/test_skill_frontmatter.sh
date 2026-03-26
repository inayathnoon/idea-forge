#!/usr/bin/env bash
# tests/test_skill_frontmatter.sh
# Unit test: every skill SKILL.md has valid frontmatter

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_DIR="$PROJECT_ROOT/skills"

PASS=0
FAIL=0

echo "==== Skill Frontmatter Tests ===="
echo

for skill_file in "$SKILLS_DIR"/*/SKILL.md; do
  [ -f "$skill_file" ] || continue
  skill_dir=$(dirname "$skill_file")
  skill_name=$(basename "$skill_dir")

  echo -n "  $skill_name ... "

  # Check required fields in frontmatter
  if grep -q "^name:" "$skill_file" && \
     grep -q "^description:" "$skill_file" && \
     grep -q "^metadata:" "$skill_file"; then
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
