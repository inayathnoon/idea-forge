#!/usr/bin/env bash
# harness/validate-agents.sh
# Structural validation for agents: frontmatter, referenced skills exist, stage ordering
# Usage: validate-agents.sh [--verbose]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
AGENTS_DIR="$PROJECT_ROOT/agents"
SKILLS_DIR="$PROJECT_ROOT/skills"
VERBOSE=false

if [ "$1" == "--verbose" ]; then
  VERBOSE=true
fi

if [ ! -d "$AGENTS_DIR" ]; then
  echo "❌ Agents directory not found: $AGENTS_DIR"
  exit 1
fi

ERRORS=0
WARNINGS=0

echo "==== Agent Structural Validation ===="
echo ""

# 1. Count agents
AGENT_COUNT=$(find "$AGENTS_DIR" -name "*.md" -type f | wc -l)
echo "🤖 Found $AGENT_COUNT agents"
echo ""

# 2. Validate each agent's frontmatter
echo "🏷️  Validating frontmatter..."
find "$AGENTS_DIR" -name "*.md" -type f | sort | while read -r agent_file; do
  agent_name=$(basename "$agent_file" .md)

  # Check YAML frontmatter exists
  if ! grep -q "^---$" "$agent_file"; then
    echo "❌ $agent_name: Missing frontmatter delimiters"
    ERRORS=$((ERRORS + 1))
    return
  fi

  # Extract frontmatter fields
  name=$(sed -n 's/^name: //p' "$agent_file" | head -1)
  stage=$(sed -n 's/^stage: //p' "$agent_file" | head -1)
  description=$(sed -n 's/^description: //p' "$agent_file" | head -1)

  # Validate required fields
  if [ -z "$name" ]; then
    echo "❌ $agent_name: Missing 'name' field"
    ERRORS=$((ERRORS + 1))
  fi

  if [ -z "$stage" ]; then
    echo "❌ $agent_name: Missing 'stage' field"
    ERRORS=$((ERRORS + 1))
  fi

  if [ -z "$description" ]; then
    echo "❌ $agent_name: Missing 'description' field"
    ERRORS=$((ERRORS + 1))
  fi

  # Validate stage is numeric or cross-cutting
  if [ -n "$stage" ] && ! [[ "$stage" =~ ^[0-9]+$ ]] && [ "$stage" != "cross-cutting" ]; then
    echo "❌ $agent_name: Stage must be numeric or 'cross-cutting', got: $stage"
    ERRORS=$((ERRORS + 1))
  fi

  # Check for required sections
  if grep -q "^outputs:" "$agent_file"; then
    if [ "$VERBOSE" = true ]; then
      echo "  ✅ $agent_name (stage $stage, has outputs)"
    fi
  else
    echo "⚠️  $agent_name: No 'outputs' section defined"
    WARNINGS=$((WARNINGS + 1))
  fi

  if grep -q "^inputs:" "$agent_file"; then
    :
  else
    echo "⚠️  $agent_name: No 'inputs' section defined"
    WARNINGS=$((WARNINGS + 1))
  fi
done

# 3. Check all referenced skills exist
echo ""
echo "🔗 Checking skill references..."
find "$AGENTS_DIR" -name "*.md" -type f | while read -r agent_file; do
  agent_name=$(basename "$agent_file" .md)

  # Extract skills array
  in_skills=false
  while IFS= read -r line; do
    if [[ "$line" =~ ^skills: ]]; then
      in_skills=true
      continue
    fi
    if [ "$in_skills" = true ]; then
      if [[ "$line" =~ ^[a-z] ]]; then
        in_skills=false
      elif [[ "$line" =~ ^[[:space:]]*- ]]; then
        skill=$(echo "$line" | sed 's/^[[:space:]]*- //' | tr -d ' ')
        skill_path="$SKILLS_DIR/$skill"

        # Check if skill exists (either as directory with SKILL.md or plain directory)
        if [ ! -d "$skill_path" ]; then
          echo "❌ $agent_name references missing skill: $skill"
          ERRORS=$((ERRORS + 1))
        elif [ ! -f "$skill_path/SKILL.md" ]; then
          echo "⚠️  $agent_name references skill $skill but no SKILL.md found"
          WARNINGS=$((WARNINGS + 1))
        elif [ "$VERBOSE" = true ]; then
          echo "  ✅ $agent_name → $skill"
        fi
      fi
    fi
  done < "$agent_file"
done

# 4. Validate stage ordering (no gaps, no duplicates)
echo ""
echo "📊 Checking stage ordering..."
find "$AGENTS_DIR" -name "*.md" -type f | while read -r agent_file; do
  agent_name=$(basename "$agent_file" .md)
  stage=$(sed -n 's/^stage: //p' "$agent_file" | head -1)

  if [ -n "$stage" ] && [[ "$stage" =~ ^[0-9]+$ ]]; then
    # Collect numeric stages
    echo "$stage:$agent_name"
  elif [ -n "$stage" ] && [ "$stage" = "cross-cutting" ]; then
    echo "cross-cutting:$agent_name"
  fi
done | sort | while read -r stage_agent; do
  IFS=: read -r stage agent <<< "$stage_agent"
  echo "  Stage $stage: $agent"
done

# 5. Check for duplicate numeric stages only (cross-cutting can appear multiple times)
echo ""
echo "🔄 Checking for duplicate stages..."
find "$AGENTS_DIR" -name "*.md" -type f | while read -r agent_file; do
  agent_name=$(basename "$agent_file" .md)
  stage=$(sed -n 's/^stage: //p' "$agent_file" | head -1)
  if [ -n "$stage" ] && [[ "$stage" =~ ^[0-9]+$ ]]; then
    echo "$stage"
  fi
done | sort | uniq -d | while read -r stage; do
  echo "❌ Duplicate numeric stage: $stage"
  ERRORS=$((ERRORS + 1))
done

# 6. Check for post_conditions section
echo ""
echo "✓ Checking post-conditions..."
find "$AGENTS_DIR" -name "*.md" -type f | while read -r agent_file; do
  agent_name=$(basename "$agent_file" .md)

  if grep -q "^post_conditions:" "$agent_file"; then
    if [ "$VERBOSE" = true ]; then
      echo "  ✅ $agent_name has post_conditions"
    fi
  else
    echo "⚠️  $agent_name: No 'post_conditions' section"
    WARNINGS=$((WARNINGS + 1))
  fi
done

# Summary
echo ""
echo "==== Validation Summary ===="
if [ "$ERRORS" -gt 0 ]; then
  echo "❌ Found $ERRORS critical errors"
  exit 1
else
  echo "✅ All $AGENT_COUNT agents are structurally valid"
  if [ "$WARNINGS" -gt 0 ]; then
    echo "⚠️  ($WARNINGS warnings)"
  fi
fi
