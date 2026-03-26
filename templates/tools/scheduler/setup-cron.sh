#!/bin/bash

# Cron Setup for Symphony Scheduler
# Usage: bash tools/scheduler/setup-cron.sh <repo-path> <project-key>
# Note: Requires LINEAR_API_KEY and PROJECT_ID in environment or .env

set -uo pipefail

REPO_PATH="${1:-.}"
PROJECT_KEY="${2:-}"

if [ -z "$PROJECT_KEY" ]; then
  echo "❌ Usage: bash tools/scheduler/setup-cron.sh <repo-path> <project-key>"
  exit 1
fi

# Validation
if [ -z "$LINEAR_API_KEY" ]; then
  echo "❌ ERROR: LINEAR_API_KEY environment variable not set"
  echo "   Set it in your shell: export LINEAR_API_KEY='your-key'"
  exit 1
fi

if ! command -v claude &>/dev/null; then
  echo "❌ ERROR: claude CLI not found"
  echo "   Install: npm install -g @anthropic-ai/claude-code"
  exit 1
fi

# Resolve repo path
REPO_PATH="$(cd "$REPO_PATH" && pwd)"
SCHEDULER_SCRIPT="$REPO_PATH/tools/scheduler/poll-linear.sh"

if [ ! -f "$SCHEDULER_SCRIPT" ]; then
  echo "❌ ERROR: Scheduler script not found at $SCHEDULER_SCRIPT"
  exit 1
fi

# Check for existing cron entry
CRON_PATTERN="poll-linear.sh"
EXISTING=$(crontab -l 2>/dev/null | grep "$CRON_PATTERN" || true)

if [ -n "$EXISTING" ]; then
  echo "⚠️  Cron entry already exists. Updating..."
  # Remove old entry
  (crontab -l 2>/dev/null | grep -v "$CRON_PATTERN") | crontab - 2>/dev/null || true
fi

# Ensure .env file exists with required vars
ENV_FILE="$REPO_PATH/.env"
if [ ! -f "$ENV_FILE" ]; then
  echo "LINEAR_API_KEY=$LINEAR_API_KEY" > "$ENV_FILE"
  echo "PROJECT_KEY=$PROJECT_KEY" >> "$ENV_FILE"
  echo "REPO_PATH=$REPO_PATH" >> "$ENV_FILE"
  chmod 600 "$ENV_FILE"
  echo "Created $ENV_FILE (chmod 600)"
else
  echo "Using existing $ENV_FILE"
fi

# Ensure log directory exists
LOG_DIR="$HOME/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/symphony-scheduler.log"

# Create cron entry: run every 5 minutes, source .env for secrets
CRON_ENTRY="*/5 * * * * . $ENV_FILE && bash $SCHEDULER_SCRIPT >> $LOG_FILE 2>&1"

# Add to crontab
(crontab -l 2>/dev/null; echo "$CRON_ENTRY") | crontab - 2>/dev/null

echo "✅ Cron job configured"
echo ""
echo "📋 Schedule:"
echo "   Every 5 minutes"
echo ""
echo "🗂️  Paths:"
echo "   Repository: $REPO_PATH"
echo "   Scheduler: $SCHEDULER_SCRIPT"
echo "   Env file: $ENV_FILE"
echo "   Log: $LOG_FILE"
echo ""
echo "📊 Monitor with: bash $REPO_PATH/tools/scheduler/status.sh"
echo "View logs with: tail -f $LOG_FILE"
