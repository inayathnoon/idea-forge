#!/bin/bash

# Project Bootstrap
# Runs automatically on first session. Handles: deps, GitHub auth, Linear auth,
# Linear project creation, scheduler setup.
# Usage: bash tools/bootstrap/setup.sh

set -uo pipefail

BOOTSTRAP_LOCK=".bootstrap.done"

# If already bootstrapped, exit silently (idempotent)
if [ -f "$BOOTSTRAP_LOCK" ]; then
  exit 0
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

PASS=0
FAIL=0

pass() { echo -e "  ${GREEN}✓${NC} $1"; PASS=$((PASS + 1)); }
fail() { echo -e "  ${RED}✗${NC} $1"; FAIL=$((FAIL + 1)); }
info() { echo -e "  ${YELLOW}→${NC} $1"; }

echo ""
echo -e "${BOLD}Project Bootstrap${NC}"
echo "=========================================="
echo ""

# ─── Step 1: Prerequisites ───────────────────────────────────────────

echo -e "${BOLD}1. Checking prerequisites${NC}"

if command -v node &>/dev/null; then
  pass "Node.js $(node --version)"
else
  fail "Node.js not found"
  info "Install: https://nodejs.org or 'brew install node'"
fi

if command -v npm &>/dev/null; then
  pass "npm $(npm --version)"
else
  fail "npm not found"
fi

if command -v git &>/dev/null; then
  pass "git $(git --version | cut -d' ' -f3)"
else
  fail "git not found"
fi

if command -v claude &>/dev/null; then
  pass "Claude CLI installed"
else
  fail "Claude CLI not found"
  info "Install: npm install -g @anthropic-ai/claude-code"
fi

echo ""

# ─── Step 2: GitHub CLI ──────────────────────────────────────────────

echo -e "${BOLD}2. GitHub CLI${NC}"

if command -v gh &>/dev/null; then
  pass "gh CLI installed ($(gh --version | head -1 | cut -d' ' -f3))"

  if gh auth status &>/dev/null 2>&1; then
    GH_USER=$(gh api user -q .login 2>/dev/null || echo "unknown")
    pass "Authenticated as $GH_USER"
  else
    info "Not authenticated. Opening browser login..."
    echo ""
    gh auth login --web --git-protocol https
    if gh auth status &>/dev/null 2>&1; then
      GH_USER=$(gh api user -q .login 2>/dev/null || echo "unknown")
      pass "Authenticated as $GH_USER"
    else
      fail "GitHub authentication failed"
      info "Try manually: gh auth login"
    fi
  fi
else
  fail "gh CLI not found"
  info "Install: brew install gh"
fi

echo ""

# ─── Step 3: Linear API Key ──────────────────────────────────────────

echo -e "${BOLD}3. Linear API Key${NC}"

ENV_FILE=".env"
LINEAR_KEY=""

# Check existing .env
if [ -f "$ENV_FILE" ] && grep -q "LINEAR_API_KEY=" "$ENV_FILE" 2>/dev/null; then
  EXISTING_KEY=$(grep "LINEAR_API_KEY=" "$ENV_FILE" | head -1 | cut -d'=' -f2 | tr -d '"' | tr -d "'")
  if [ -n "$EXISTING_KEY" ] && [ "$EXISTING_KEY" != "your-linear-api-key-here" ]; then
    LINEAR_KEY="$EXISTING_KEY"
    pass "LINEAR_API_KEY found in .env"
  fi
fi

# Check environment variable
if [ -z "$LINEAR_KEY" ] && [ -n "${LINEAR_API_KEY:-}" ]; then
  LINEAR_KEY="$LINEAR_API_KEY"
  pass "LINEAR_API_KEY found in environment"
fi

if [ -z "$LINEAR_KEY" ]; then
  if [ -t 0 ]; then
    # Interactive terminal — prompt for key
    info "Linear API key not found."
    echo ""
    echo "    To get your key:"
    echo "    1. Go to https://linear.app/settings/api"
    echo "    2. Click 'Create key' (label: $(basename "$(pwd)"))"
    echo "    3. Copy the key"
    echo ""
    read -rp "    Paste your Linear API key (or press Enter to skip): " LINEAR_KEY
  else
    # Non-interactive (scheduler, hook, CI) — skip silently
    fail "Linear API key not configured (non-interactive session)"
    info "Run 'bash tools/bootstrap/setup.sh' in a terminal to configure"
    LINEAR_KEY=""
  fi

  if [ -n "$LINEAR_KEY" ]; then
    if [ -f "$ENV_FILE" ]; then
      if grep -q "LINEAR_API_KEY=" "$ENV_FILE"; then
        sed -i '' "s|LINEAR_API_KEY=.*|LINEAR_API_KEY=$LINEAR_KEY|" "$ENV_FILE"
      else
        echo "LINEAR_API_KEY=$LINEAR_KEY" >> "$ENV_FILE"
      fi
    else
      echo "LINEAR_API_KEY=$LINEAR_KEY" > "$ENV_FILE"
    fi
    chmod 600 "$ENV_FILE"

    VALIDATE=$(curl -s -o /dev/null -w "%{http_code}" \
      -H "Authorization: Bearer $LINEAR_KEY" \
      https://api.linear.app/graphql \
      -d '{"query": "{ viewer { id } }"}')

    if [ "$VALIDATE" = "200" ]; then
      pass "Linear API key validated and saved to .env"
    else
      fail "Linear API key saved but validation failed (HTTP $VALIDATE)"
      info "Check the key at https://linear.app/settings/api"
      LINEAR_KEY=""
    fi
  else
    fail "Linear API key not configured"
    info "You can add it later and re-run: bash tools/bootstrap/setup.sh"
  fi
fi

echo ""

# ─── Step 4: Linear Project ──────────────────────────────────────────

echo -e "${BOLD}4. Linear Project${NC}"

# Check if WORKFLOW.md already has a real project key
WORKFLOW_FILE="WORKFLOW.md"
CURRENT_KEY=""
if [ -f "$WORKFLOW_FILE" ]; then
  CURRENT_KEY=$(grep "project_key:" "$WORKFLOW_FILE" | head -1 | sed 's/.*project_key: *//' | tr -d ' ')
fi

if [ -n "$CURRENT_KEY" ] && [ "$CURRENT_KEY" != "{LINEAR_PROJECT_KEY}" ]; then
  pass "Linear project already configured ($CURRENT_KEY)"
  PROJECT_KEY="$CURRENT_KEY"
else
  if [ -n "$LINEAR_KEY" ]; then
    info "Creating Linear project..."

    # Read project name from mvp.md or fall back to directory name
    PROJECT_NAME=$(basename "$(pwd)")
    PROJECT_DESC=""
    if [ -f "docs/product-specs/mvp.md" ]; then
      # Try to extract name from first heading
      MVP_NAME=$(grep -m1 "^# " "docs/product-specs/mvp.md" | sed 's/^# //')
      if [ -n "$MVP_NAME" ]; then
        PROJECT_NAME="$MVP_NAME"
      fi
      # Try to extract description from first non-heading, non-empty line
      PROJECT_DESC=$(grep -m1 "^> " "docs/product-specs/mvp.md" | sed 's/^> //' || true)
    fi

    # Get the user's default team
    TEAM_RESPONSE=$(curl -s -X POST https://api.linear.app/graphql \
      -H "Authorization: Bearer $LINEAR_KEY" \
      -H "Content-Type: application/json" \
      -d '{"query": "{ teams(first: 1) { nodes { id name key } } }"}')

    TEAM_ID=$(echo "$TEAM_RESPONSE" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
    TEAM_KEY=$(echo "$TEAM_RESPONSE" | grep -o '"key":"[^"]*"' | head -1 | cut -d'"' -f4)

    if [ -z "$TEAM_ID" ]; then
      fail "Could not find a Linear team"
      info "Create a team at https://linear.app first"
    else
      # Create the project
      CREATE_QUERY='mutation { projectCreate(input: { name: "'"$PROJECT_NAME"'", description: "'"$PROJECT_DESC"'", teamIds: ["'"$TEAM_ID"'"] }) { success project { id slugId } } }'

      CREATE_RESPONSE=$(curl -s -X POST https://api.linear.app/graphql \
        -H "Authorization: Bearer $LINEAR_KEY" \
        -H "Content-Type: application/json" \
        -d "{\"query\": $(echo "$CREATE_QUERY" | jq -Rs .)}")

      PROJECT_SUCCESS=$(echo "$CREATE_RESPONSE" | grep -o '"success":true' || true)
      PROJECT_SLUG=$(echo "$CREATE_RESPONSE" | grep -o '"slugId":"[^"]*"' | head -1 | cut -d'"' -f4)
      PROJECT_REAL_ID=$(echo "$CREATE_RESPONSE" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

      if [ -n "$PROJECT_SUCCESS" ]; then
        PROJECT_KEY="$TEAM_KEY"
        PROJECT_ID="$PROJECT_REAL_ID"

        # Update WORKFLOW.md with project key, project ID, and team ID
        sed -i '' "s|project_key: {LINEAR_PROJECT_KEY}|project_key: $PROJECT_KEY|" "$WORKFLOW_FILE"
        sed -i '' "s|project_id: {LINEAR_PROJECT_ID}|project_id: $PROJECT_ID|" "$WORKFLOW_FILE"
        sed -i '' "s|team_id: {LINEAR_TEAM_ID}|team_id: $TEAM_ID|" "$WORKFLOW_FILE"

        # Verify values were written
        if grep -q "{LINEAR_PROJECT_KEY}" "$WORKFLOW_FILE" 2>/dev/null; then
          fail "WORKFLOW.md still has unfilled placeholders after sed"
          info "Check WORKFLOW.md format — sed patterns may not match"
        fi

        # Save to .env for scheduler — PROJECT_ID is the real Linear project UUID
        if grep -q "PROJECT_KEY=" "$ENV_FILE" 2>/dev/null; then
          sed -i '' "s|PROJECT_KEY=.*|PROJECT_KEY=$PROJECT_KEY|" "$ENV_FILE"
        else
          echo "PROJECT_KEY=$PROJECT_KEY" >> "$ENV_FILE"
        fi
        if grep -q "PROJECT_ID=" "$ENV_FILE" 2>/dev/null; then
          sed -i '' "s|PROJECT_ID=.*|PROJECT_ID=$PROJECT_ID|" "$ENV_FILE"
        else
          echo "PROJECT_ID=$PROJECT_ID" >> "$ENV_FILE"
        fi

        pass "Created Linear project '$PROJECT_NAME' ($PROJECT_KEY, id: $PROJECT_ID)"
      else
        ERROR=$(echo "$CREATE_RESPONSE" | grep -o '"message":"[^"]*"' | head -1 | cut -d'"' -f4)
        fail "Failed to create Linear project: ${ERROR:-unknown error}"
        info "You can create it manually via /seed"
      fi
    fi
  else
    info "Skipping Linear project (no API key)"
  fi
fi

echo ""

# ─── Step 5: Install Dependencies ────────────────────────────────────

echo -e "${BOLD}5. Installing dependencies${NC}"

if [ -f "package.json" ]; then
  if [ -d "node_modules" ]; then
    pass "node_modules exists"
  else
    info "Running npm install..."
    if npm install --silent 2>/dev/null; then
      pass "Dependencies installed"
    else
      fail "npm install failed"
      info "Try manually: npm install"
    fi
  fi
else
  info "No package.json yet (created during scaffolding)"
fi

echo ""

# ─── Step 6: Scheduler ───────────────────────────────────────────────

echo -e "${BOLD}6. Auto-execution scheduler${NC}"

if [ -n "${PROJECT_KEY:-}" ] && [ -n "$LINEAR_KEY" ]; then
  # Save REPO_PATH to .env
  REPO_PATH="$(pwd)"
  if grep -q "REPO_PATH=" "$ENV_FILE" 2>/dev/null; then
    sed -i '' "s|REPO_PATH=.*|REPO_PATH=$REPO_PATH|" "$ENV_FILE"
  else
    echo "REPO_PATH=$REPO_PATH" >> "$ENV_FILE"
  fi

  SCHEDULER_SCRIPT="$REPO_PATH/tools/scheduler/poll-linear.sh"
  CRON_PATTERN="poll-linear.sh"
  EXISTING_CRON=$(crontab -l 2>/dev/null | grep "$CRON_PATTERN" || true)

  if [ -n "$EXISTING_CRON" ]; then
    pass "Scheduler already configured"
  else
    LOG_DIR="$HOME/logs"
    mkdir -p "$LOG_DIR"
    LOG_FILE="$LOG_DIR/symphony-scheduler.log"

    CRON_ENTRY="*/5 * * * * . $REPO_PATH/.env && bash $SCHEDULER_SCRIPT >> $LOG_FILE 2>&1"
    (crontab -l 2>/dev/null; echo "$CRON_ENTRY") | crontab - 2>/dev/null

    if crontab -l 2>/dev/null | grep -q "$CRON_PATTERN"; then
      pass "Scheduler installed (polls every 5 min)"
      info "Logs: tail -f $LOG_FILE"
      info "Status: bash tools/scheduler/status.sh"
    else
      fail "Could not install cron job"
      info "Set up manually: bash tools/scheduler/setup-cron.sh . $PROJECT_KEY"
    fi
  fi
else
  info "Skipping scheduler (needs Linear project + API key)"
  info "Run 'bash tools/bootstrap/setup.sh' again after configuring Linear"
fi

echo ""

# ─── Step 7: Security ────────────────────────────────────────────────

echo -e "${BOLD}7. Security${NC}"

if [ -f ".gitignore" ]; then
  if grep -q "\.env" .gitignore 2>/dev/null; then
    pass ".env in .gitignore"
  else
    echo ".env" >> .gitignore
    pass "Added .env to .gitignore"
  fi
  if grep -q "\.bootstrap\.done" .gitignore 2>/dev/null; then
    pass ".bootstrap.done in .gitignore"
  else
    echo ".bootstrap.done" >> .gitignore
    pass "Added .bootstrap.done to .gitignore"
  fi
else
  printf ".env\n.bootstrap.done\nnode_modules/\n*.log\n" > .gitignore
  pass "Created .gitignore"
fi

echo ""

# ─── Summary ─────────────────────────────────────────────────────────

echo "=========================================="
TOTAL=$((PASS + FAIL))

if [ $FAIL -eq 0 ]; then
  date -u '+%Y-%m-%dT%H:%M:%SZ' > "$BOOTSTRAP_LOCK"
  echo -e "${GREEN}All $PASS checks passed. Ready to build.${NC}"
  echo ""
  echo "Next:"
  echo "  /seed    — seed Phase 1 issues to Linear"
  echo "  /review  — review completed work"
  echo ""
  echo "Execution is automatic — the scheduler picks up Todo issues every 5 min."
else
  echo -e "${YELLOW}$PASS passed, $FAIL need attention.${NC}"
  echo ""
  echo "Fix the issues above, then re-run:"
  echo "  bash tools/bootstrap/setup.sh"
fi
echo "=========================================="
