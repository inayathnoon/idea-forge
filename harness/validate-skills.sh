#!/usr/bin/env bash
# harness/validate-skills.sh
# Structural validation for skills: frontmatter, no orphans, bidirectional references
# Usage: validate-skills.sh [--verbose]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_DIR="$PROJECT_ROOT/skills"
AGENTS_DIR="$PROJECT_ROOT/agents"
VERBOSE=false

if [ "$1" == "--verbose" ]; then
  VERBOSE=true
fi

if [ ! -d "$SKILLS_DIR" ]; then
  echo "❌ Skills directory not found: $SKILLS_DIR"
  exit 1
fi

ERRORS=0
WARNINGS=0

echo "==== Skill Structural Validation ===="
echo ""

# 1. Count skills
SKILL_COUNT=$(find "$SKILLS_DIR" -name "SKILL.md" | wc -l)
echo "📚 Found $SKILL_COUNT skills"
echo ""

# 2. Validate each skill's frontmatter
echo "🏷️  Validating frontmatter..."
find "$SKILLS_DIR" -name "SKILL.md" | sort | while read -r skill_file; do
  skill_name=$(basename "$(dirname "$skill_file")")

  # Check YAML frontmatter exists
  if ! grep -q "^---$" "$skill_file"; then
    echo "❌ $skill_name: Missing frontmatter delimiters"
    ERRORS=$((ERRORS + 1))
    return
  fi

  # Extract frontmatter fields
  name=$(sed -n 's/^name: //p' "$skill_file" | head -1)
  description=$(sed -n 's/^description: //p' "$skill_file" | head -1)

  # Validate required fields
  if [ -z "$name" ]; then
    echo "❌ $skill_name: Missing 'name' field"
    ERRORS=$((ERRORS + 1))
  fi

  if [ -z "$description" ]; then
    echo "❌ $skill_name: Missing 'description' field"
    ERRORS=$((ERRORS + 1))
  fi

  # Check metadata section
  if grep -q "^metadata:" "$skill_file"; then
    if [ "$VERBOSE" = true ]; then
      echo "  ✅ $skill_name (has metadata)"
    fi
  else
    echo "⚠️  $skill_name: No 'metadata' section"
    WARNINGS=$((WARNINGS + 1))
  fi
done

# 3. Check for orphaned skills (not referenced by any agent)
echo ""
echo "🔗 Checking for orphaned skills..."
find "$SKILLS_DIR" -name "SKILL.md" | while read -r skill_file; do
  skill_name=$(basename "$(dirname "$skill_file")")

  # Search all agents for reference to this skill
  referenced=$(grep -r "skills/$skill_name" "$AGENTS_DIR" 2>/dev/null | wc -l || echo 0)

  if [ "$referenced" -eq 0 ]; then
    echo "⚠️  $skill_name: Not referenced by any agent (orphaned?)"
    WARNINGS=$((WARNINGS + 1))
  elif [ "$VERBOSE" = true ]; then
    echo "  ✅ $skill_name is referenced"
  fi
done

# 4. Validate called_by metadata (agent references skill, and skill says called by agent)
echo ""
echo "🔄 Checking bidirectional references..."
find "$SKILLS_DIR" -name "SKILL.md" | while read -r skill_file; do
  skill_name=$(basename "$(dirname "$skill_file")")

  # Extract called_by field
  called_by=$(sed -n 's/^    - //p' "$skill_file" | grep -A 50 "called_by:" | head -20 || echo "")

  if [ -z "$called_by" ]; then
    echo "⚠️  $skill_name: No 'called_by' metadata"
  fi
done

# 5. Check for skill naming convention (kebab-case)
echo ""
echo "📝 Checking naming conventions..."
find "$SKILLS_DIR" -type d -mindepth 1 -maxdepth 1 | while read -r skill_dir; do
  skill_name=$(basename "$skill_dir")

  # Check if name matches kebab-case pattern
  if ! [[ "$skill_name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    echo "⚠️  Skill '$skill_name' doesn't follow kebab-case convention"
    WARNINGS=$((WARNINGS + 1))
  elif [ "$VERBOSE" = true ]; then
    echo "  ✅ $skill_name follows naming convention"
  fi
done

# 6. Validate skill file structure (has ## sections)
echo ""
echo "📖 Validating skill documentation structure..."
find "$SKILLS_DIR" -name "SKILL.md" | while read -r skill_file; do
  skill_name=$(basename "$(dirname "$skill_file")")

  # Check for expected sections
  has_purpose=$(grep -c "^## Purpose" "$skill_file" || echo 0)
  has_inputs=$(grep -c "^## Inputs" "$skill_file" || echo 0)
  has_outputs=$(grep -c "^## Output" "$skill_file" || echo 0)

  if [ "$has_purpose" -eq 0 ]; then
    echo "⚠️  $skill_name: Missing '## Purpose' section"
    WARNINGS=$((WARNINGS + 1))
  fi

  if [ "$has_inputs" -eq 0 ]; then
    echo "⚠️  $skill_name: Missing '## Inputs' section"
    WARNINGS=$((WARNINGS + 1))
  fi

  if [ "$has_outputs" -eq 0 ]; then
    echo "⚠️  $skill_name: Missing '## Output' section"
    WARNINGS=$((WARNINGS + 1))
  fi

  if [ "$has_purpose" -gt 0 ] && [ "$has_inputs" -gt 0 ] && [ "$has_outputs" -gt 0 ] && [ "$VERBOSE" = true ]; then
    echo "  ✅ $skill_name has all required sections"
  fi
done

# Summary
echo ""
echo "==== Validation Summary ===="
if [ "$ERRORS" -gt 0 ]; then
  echo "❌ Found $ERRORS critical errors"
  exit 1
else
  echo "✅ All $SKILL_COUNT skills are structurally valid"
  if [ "$WARNINGS" -gt 0 ]; then
    echo "⚠️  ($WARNINGS warnings)"
  fi
fi
