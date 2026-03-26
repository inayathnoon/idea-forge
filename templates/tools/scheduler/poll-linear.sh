#!/bin/bash

# Linear Polling Scheduler
# Checks for Todo issues and triggers Symphony Executor
# Usage: bash tools/scheduler/poll-linear.sh
# Env: LINEAR_API_KEY, PROJECT_ID, PROJECT_KEY, REPO_PATH, LOCK_FILE (optional)

set -uo pipefail

LINEAR_API_KEY="${LINEAR_API_KEY:-}"
PROJECT_ID="${PROJECT_ID:-}"
PROJECT_KEY="${PROJECT_KEY:-}"
REPO_PATH="${REPO_PATH:-.}"
LOCK_FILE="${LOCK_FILE:-/tmp/symphony-executor.lock}"

# Validation
if [ -z "$LINEAR_API_KEY" ]; then
  echo "LINEAR_API_KEY not set" >&2
  exit 1
fi

if [ -z "$PROJECT_ID" ]; then
  echo "PROJECT_ID not set (run bootstrap first)" >&2
  exit 1
fi

# Check lock file — prevent concurrent executors
if [ -f "$LOCK_FILE" ]; then
  LOCK_PID=$(cat "$LOCK_FILE" 2>/dev/null || echo "")
  if [ -n "$LOCK_PID" ] && kill -0 "$LOCK_PID" 2>/dev/null; then
    echo "Executor already running (PID $LOCK_PID). Skipping."
    exit 0
  else
    # Stale lock — clean up
    rm -f "$LOCK_FILE"
  fi
fi

# Query Linear for Todo issues using project ID (not team key)
QUERY='{
  issues(
    filter: {
      project: { id: { eq: "'"$PROJECT_ID"'" } }
      state: { name: { eq: "Todo" } }
    }
    first: 1
    orderBy: createdAt
  ) {
    nodes {
      id
      identifier
      title
      priority
      state { id name }
    }
    pageInfo { hasNextPage }
  }
}'

echo "Querying Linear for Todo issues in project $PROJECT_ID..."

RESPONSE=$(curl -s -X POST https://api.linear.app/graphql \
  -H "Authorization: Bearer $LINEAR_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"query\": $(echo "$QUERY" | jq -Rs .)}")

# Check for errors
if echo "$RESPONSE" | jq -e '.errors' >/dev/null 2>&1; then
  ERROR=$(echo "$RESPONSE" | jq -r '.errors[0].message // .errors[0]')
  echo "Linear API error: $ERROR" >&2
  exit 1
fi

# Parse response
ISSUE_COUNT=$(echo "$RESPONSE" | jq '.data.issues.nodes | length')

if [ "$ISSUE_COUNT" -eq 0 ]; then
  echo "No Todo issues. Queue is empty."
  exit 0
fi

# Extract first issue
ISSUE_ID=$(echo "$RESPONSE" | jq -r '.data.issues.nodes[0].id')
ISSUE_IDENTIFIER=$(echo "$RESPONSE" | jq -r '.data.issues.nodes[0].identifier')
ISSUE_TITLE=$(echo "$RESPONSE" | jq -r '.data.issues.nodes[0].title')

echo "Found issue: $ISSUE_IDENTIFIER — $ISSUE_TITLE"

# Write lock file
PID=$$
echo "$PID" > "$LOCK_FILE"
trap "rm -f '$LOCK_FILE'" EXIT

# Update repo
echo "Updating repository..."
cd "$REPO_PATH"
git pull origin main --rebase --quiet || true

# Trigger executor
echo "Triggering Symphony Executor..."

if ! command -v claude &>/dev/null; then
  echo "Claude CLI not found" >&2
  exit 1
fi

EXEC_LOG=$(mktemp)
claude --print "Read and follow .claude/commands/execute.md exactly. The next issue to pick up is: $ISSUE_IDENTIFIER — $ISSUE_TITLE (project: $PROJECT_KEY). Start from Step 1." 2>&1 | tee "$EXEC_LOG"
EXEC_EXIT=$?

if [ $EXEC_EXIT -ne 0 ]; then
  echo "Executor failed for $ISSUE_IDENTIFIER (exit code $EXEC_EXIT)" >&2

  # Look up the Rework state ID for this team
  REWORK_QUERY='{ workflowStates(filter: { name: { eq: "Rework" } }) { nodes { id name } } }'
  REWORK_RESPONSE=$(curl -s -X POST https://api.linear.app/graphql \
    -H "Authorization: Bearer $LINEAR_API_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"query\": $(echo "$REWORK_QUERY" | jq -Rs .)}")
  REWORK_STATE_ID=$(echo "$REWORK_RESPONSE" | jq -r '.data.workflowStates.nodes[0].id // empty')

  # Move issue to Rework if state exists
  if [ -n "$REWORK_STATE_ID" ]; then
    MOVE_MUTATION='mutation { issueUpdate(id: "'"$ISSUE_ID"'", input: { stateId: "'"$REWORK_STATE_ID"'" }) { success } }'
    curl -s -X POST https://api.linear.app/graphql \
      -H "Authorization: Bearer $LINEAR_API_KEY" \
      -H "Content-Type: application/json" \
      -d "{\"query\": $(echo "$MOVE_MUTATION" | jq -Rs .)}" >/dev/null 2>&1 || true
  fi

  # Post failure comment to Linear
  LOG_TAIL=$(tail -20 "$EXEC_LOG" | sed 's/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g')
  COMMENT_BODY="## Scheduler: Executor Failed\\n\\n**Issue:** $ISSUE_IDENTIFIER — $ISSUE_TITLE\\n**Exit code:** $EXEC_EXIT\\n**Tail of log:**\\n\`\`\`\\n$LOG_TAIL\\n\`\`\`\\n\\nThis issue needs manual attention."
  COMMENT_MUTATION='mutation { commentCreate(input: { issueId: "'"$ISSUE_ID"'", body: "'"$COMMENT_BODY"'" }) { success } }'

  curl -s -X POST https://api.linear.app/graphql \
    -H "Authorization: Bearer $LINEAR_API_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"query\": $(echo "$COMMENT_MUTATION" | jq -Rs .)}" >/dev/null 2>&1 || true

  rm -f "$EXEC_LOG"
  exit 1
fi

rm -f "$EXEC_LOG"
echo "Executor completed for $ISSUE_IDENTIFIER"
