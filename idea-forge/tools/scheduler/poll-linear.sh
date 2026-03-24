#!/bin/bash

# Linear Polling Scheduler
# Checks for Todo issues and triggers Symphony Executor
# Usage: bash tools/scheduler/poll-linear.sh
# Env: LINEAR_API_KEY, PROJECT_KEY, REPO_PATH, LOCK_FILE (optional)

set -uo pipefail

LINEAR_API_KEY="${LINEAR_API_KEY:-}"
PROJECT_KEY="${PROJECT_KEY:-}"
REPO_PATH="${REPO_PATH:-.}"
LOCK_FILE="${LOCK_FILE:-/tmp/symphony-executor.lock}"

# Validation
if [ -z "$LINEAR_API_KEY" ]; then
  echo "❌ LINEAR_API_KEY not set" >&2
  exit 1
fi

if [ -z "$PROJECT_KEY" ]; then
  echo "❌ PROJECT_KEY not set" >&2
  exit 1
fi

# Check lock file — prevent concurrent executors
if [ -f "$LOCK_FILE" ]; then
  LOCK_PID=$(cat "$LOCK_FILE" 2>/dev/null || echo "")
  if [ -n "$LOCK_PID" ] && kill -0 "$LOCK_PID" 2>/dev/null; then
    echo "⏳ Executor already running (PID $LOCK_PID). Skipping."
    exit 0
  else
    # Stale lock — clean up
    rm -f "$LOCK_FILE"
  fi
fi

# Query Linear for Todo issues
QUERY='{
  issues(
    filter: {
      project: { key: { eq: "'$PROJECT_KEY'" } }
      state: { name: { eq: "Todo" } }
    }
    first: 1
    orderBy: createdAt
  ) {
    nodes {
      id
      identifier
      title
      priority { name }
    }
    pageInfo { hasNextPage }
  }
}'

echo "🔍 Querying Linear for Todo issues in $PROJECT_KEY..."

RESPONSE=$(curl -s -X POST https://api.linear.app/graphql \
  -H "Authorization: Bearer $LINEAR_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"query\": $(echo "$QUERY" | jq -Rs .)}")

# Check for errors
if echo "$RESPONSE" | jq -e '.errors' >/dev/null 2>&1; then
  ERROR=$(echo "$RESPONSE" | jq -r '.errors[0].message // .errors[0]')
  echo "❌ Linear API error: $ERROR" >&2
  exit 1
fi

# Parse response
ISSUE_COUNT=$(echo "$RESPONSE" | jq '.data.issues.nodes | length')

if [ "$ISSUE_COUNT" -eq 0 ]; then
  echo "✅ No Todo issues. Queue is empty."
  exit 0
fi

# Extract first issue
ISSUE_ID=$(echo "$RESPONSE" | jq -r '.data.issues.nodes[0].id')
ISSUE_IDENTIFIER=$(echo "$RESPONSE" | jq -r '.data.issues.nodes[0].identifier')
ISSUE_TITLE=$(echo "$RESPONSE" | jq -r '.data.issues.nodes[0].title')

echo "📋 Found issue: $ISSUE_IDENTIFIER — $ISSUE_TITLE"

# Write lock file
PID=$$
echo "$PID" > "$LOCK_FILE"
trap "rm -f '$LOCK_FILE'" EXIT

# Update repo
echo "🔄 Updating repository..."
cd "$REPO_PATH"
git pull origin main --rebase --quiet || true

# Trigger executor
echo "🚀 Triggering Symphony Executor..."

if command -v claude &>/dev/null; then
  claude --print "You are the Symphony Executor. Read agents/symphony-executor-9.md and follow its instructions exactly. Next issue to pick up: $ISSUE_IDENTIFIER — $ISSUE_TITLE. Project key: $PROJECT_KEY"
else
  echo "❌ Claude CLI not found" >&2
  exit 1
fi

echo "✅ Executor triggered for $ISSUE_IDENTIFIER"
