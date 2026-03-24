#!/bin/bash

# Symphony Scheduler — Cron Setup
# Sets up 5-minute polling job to auto-trigger executor
# Usage: bash setup-cron.sh <repo-path> <project-key>

set -e

# Parse arguments
if [[ $# -lt 2 ]]; then
  echo "Usage: bash setup-cron.sh <repo-path> <project-key>"
  echo ""
  echo "Example:"
  echo "  bash setup-cron.sh /Users/noon/Work/idea-forge INO"
  exit 1
fi

REPO_PATH="$1"
PROJECT_KEY="$2"

# Validation
if [[ ! -d "$REPO_PATH" ]]; then
  echo "ERROR: Repo path does not exist: $REPO_PATH"
  exit 1
fi

if [[ -z "$LINEAR_API_KEY" ]]; then
  echo "ERROR: LINEAR_API_KEY environment variable not set"
  echo "Set it: export LINEAR_API_KEY=your_api_key"
  exit 1
fi

# Check prerequisites
if ! command -v claude &>/dev/null; then
  echo "ERROR: Claude CLI not found. Install it first: https://claude.com/claude-code"
  exit 1
fi

SCHEDULER_SCRIPT="$REPO_PATH/tools/scheduler/poll-linear.sh"
if [[ ! -f "$SCHEDULER_SCRIPT" ]]; then
  echo "ERROR: Scheduler script not found: $SCHEDULER_SCRIPT"
  exit 1
fi

# Make scheduler executable
chmod +x "$SCHEDULER_SCRIPT"
echo "✓ Scheduler script is executable"

# Create log directory if it doesn't exist
LOG_FILE="/var/log/symphony-scheduler.log"
if [[ ! -f "$LOG_FILE" ]]; then
  echo "[$(date)] Symphony Scheduler initialized" > "$LOG_FILE" 2>/dev/null || {
    echo "WARNING: Cannot write to $LOG_FILE, using /tmp instead"
    LOG_FILE="/tmp/symphony-scheduler.log"
    echo "[$(date)] Symphony Scheduler initialized" > "$LOG_FILE"
  }
fi

# Build cron command
CRON_COMMAND="*/5 * * * * LINEAR_API_KEY=$LINEAR_API_KEY PROJECT_KEY=$PROJECT_KEY REPO_PATH=$REPO_PATH bash $SCHEDULER_SCRIPT >> $LOG_FILE 2>&1"

# Check if cron entry already exists
if crontab -l 2>/dev/null | grep -q "symphony-scheduler"; then
  echo "INFO: Existing cron entry found, updating..."
  # Remove old entry and add new one
  (crontab -l 2>/dev/null | grep -v "symphony-scheduler" || true; echo "$CRON_COMMAND") | crontab -
  echo "✓ Cron entry updated"
else
  echo "INFO: Creating new cron entry..."
  # Add new entry
  (crontab -l 2>/dev/null || true; echo "$CRON_COMMAND") | crontab -
  echo "✓ Cron entry created"
fi

# Confirmation
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ Symphony Scheduler Installed"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "📋 Configuration:"
echo "   Repo Path:        $REPO_PATH"
echo "   Project Key:      $PROJECT_KEY"
echo "   Schedule:         Every 5 minutes (*/5 * * * *)"
echo "   Log File:         $LOG_FILE"
echo "   Scheduler Script: $SCHEDULER_SCRIPT"
echo ""
echo "🔧 How to manage:"
echo "   View cron jobs:        crontab -l"
echo "   Edit cron jobs:        crontab -e"
echo "   Check scheduler status: bash $REPO_PATH/tools/scheduler/status.sh"
echo "   View logs:             tail -f $LOG_FILE"
echo ""
echo "⚠️  Next steps:"
echo "   1. The scheduler will check Linear every 5 minutes"
echo "   2. When Todo issues are found, executor auto-starts"
echo "   3. Monitor logs to verify it's working"
echo ""

exit 0
