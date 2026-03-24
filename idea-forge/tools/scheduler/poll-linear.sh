#!/bin/bash

# Symphony Executor Polling Scheduler
# Checks Linear for Todo issues and triggers Symphony Executor
# Usage: LINEAR_API_KEY=xxx PROJECT_KEY=yyy REPO_PATH=zzz bash poll-linear.sh

set -e

# Configuration
LINEAR_API_KEY="${LINEAR_API_KEY}"
PROJECT_KEY="${PROJECT_KEY}"
REPO_PATH="${REPO_PATH:-.}"
LOCK_FILE="${LOCK_FILE:-/tmp/symphony-executor.lock}"
LOG_FILE="${LOG_FILE:-/var/log/symphony-scheduler.log}"

# Validation
if [[ -z "$LINEAR_API_KEY" ]]; then
  echo "[$(date)] ERROR: LINEAR_API_KEY not set" | tee -a "$LOG_FILE"
  exit 1
fi

if [[ -z "$PROJECT_KEY" ]]; then
  echo "[$(date)] ERROR: PROJECT_KEY not set" | tee -a "$LOG_FILE"
  exit 1
fi

if [[ ! -d "$REPO_PATH" ]]; then
  echo "[$(date)] ERROR: REPO_PATH does not exist: $REPO_PATH" | tee -a "$LOG_FILE"
  exit 1
fi

# Check lock file
if [[ -f "$LOCK_FILE" ]]; then
  PID=$(cat "$LOCK_FILE" 2>/dev/null || echo "")
  if [[ -n "$PID" ]] && kill -0 "$PID" 2>/dev/null; then
    echo "[$(date)] INFO: Executor already running (PID $PID), skipping" | tee -a "$LOG_FILE"
    exit 0
  else
    # Stale lock, clean it up
    echo "[$(date)] INFO: Removing stale lock file (PID $PID no longer alive)" | tee -a "$LOG_FILE"
    rm -f "$LOCK_FILE"
  fi
fi

# Query Linear GraphQL API for Todo issues
echo "[$(date)] INFO: Querying Linear for Todo issues in project $PROJECT_KEY" | tee -a "$LOG_FILE"

QUERY='{
  issues(
    filter: {
      project: { key: { eq: "'$PROJECT_KEY'" } }
      state: { name: { eq: "Todo" } }
    }
    first: 1
  ) {
    nodes {
      id
      identifier
      title
      state {
        name
      }
    }
  }
}'

RESPONSE=$(curl -s -X POST https://api.linear.app/graphql \
  -H "Authorization: Bearer $LINEAR_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"query\": $(echo "$QUERY" | jq -Rs .)}")

# Parse response with python3
TODO_COUNT=$(echo "$RESPONSE" | python3 << 'PYTHON_EOF'
import json
import sys
try:
    data = json.load(sys.stdin)
    if 'errors' in data and data['errors']:
        print(f"API_ERROR: {data['errors'][0]['message']}", file=sys.stderr)
        sys.exit(1)
    nodes = data.get('data', {}).get('issues', {}).get('nodes', [])
    print(len(nodes))
except json.JSONDecodeError as e:
    print(f"JSON_ERROR: {str(e)}", file=sys.stderr)
    sys.exit(1)
PYTHON_EOF
)

if [[ $? -ne 0 ]]; then
  echo "[$(date)] ERROR: Failed to parse Linear API response" | tee -a "$LOG_FILE"
  echo "Response: $RESPONSE" | tee -a "$LOG_FILE"
  exit 1
fi

# If no Todo issues, exit cleanly
if [[ "$TODO_COUNT" -eq 0 ]]; then
  echo "[$(date)] INFO: No Todo issues found, exiting" | tee -a "$LOG_FILE"
  exit 0
fi

# Get first issue details
ISSUE_ID=$(echo "$RESPONSE" | python3 -c "import json, sys; data = json.load(sys.stdin); print(data.get('data', {}).get('issues', {}).get('nodes', [{}])[0].get('identifier', 'UNKNOWN'))")
ISSUE_TITLE=$(echo "$RESPONSE" | python3 -c "import json, sys; data = json.load(sys.stdin); print(data.get('data', {}).get('issues', {}).get('nodes', [{}])[0].get('title', 'UNKNOWN'))")

echo "[$(date)] INFO: Found Todo issue: $ISSUE_ID — $ISSUE_TITLE" | tee -a "$LOG_FILE"

# Write lock file with current PID
echo $$ > "$LOCK_FILE"
echo "[$(date)] INFO: Lock file created (PID $$)" | tee -a "$LOG_FILE"

# Git pull latest
echo "[$(date)] INFO: Pulling latest from origin/main" | tee -a "$LOG_FILE"
cd "$REPO_PATH"
git pull origin main --rebase 2>&1 | tee -a "$LOG_FILE" || {
  echo "[$(date)] ERROR: Git pull failed" | tee -a "$LOG_FILE"
  rm -f "$LOCK_FILE"
  exit 1
}

# Trigger executor
echo "[$(date)] INFO: Triggering Symphony Executor for $ISSUE_ID" | tee -a "$LOG_FILE"
claude --print "Read agents/symphony-executor-9.md and follow its instructions. Pick up next Todo from project ${PROJECT_KEY}." >> "$LOG_FILE" 2>&1 || {
  echo "[$(date)] ERROR: Failed to trigger executor" | tee -a "$LOG_FILE"
  rm -f "$LOCK_FILE"
  exit 1
}

# Cleanup lock file
rm -f "$LOCK_FILE"
echo "[$(date)] INFO: Lock file removed, executor run complete" | tee -a "$LOG_FILE"

exit 0
