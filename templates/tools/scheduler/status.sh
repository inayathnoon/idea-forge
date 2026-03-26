#!/bin/bash

# Scheduler Status Dashboard
# Shows cron status, executor status, and recent logs
# Usage: bash tools/scheduler/status.sh

set -uo pipefail

LOCK_FILE="/tmp/symphony-executor.lock"
LOG_FILE="$HOME/logs/symphony-scheduler.log"

echo "════════════════════════════════════════════════════════════"
echo "Symphony Scheduler Status"
echo "════════════════════════════════════════════════════════════"
echo ""

# Check cron status
echo "📅 Cron Job Status"
echo "─────────────────────────────────────────────────────────────"

if crontab -l 2>/dev/null | grep -q "poll-linear.sh"; then
  echo "✅ Cron job installed"
  echo ""
  echo "Next runs (per crontab):"
  crontab -l 2>/dev/null | grep "poll-linear.sh" | sed 's/^/   /'
else
  echo "❌ Cron job not installed"
  echo "   Setup: bash tools/scheduler/setup-cron.sh . <PROJECT_KEY>"
fi
echo ""

# Check executor lock
echo "🚀 Executor Status"
echo "─────────────────────────────────────────────────────────────"

if [ -f "$LOCK_FILE" ]; then
  LOCK_PID=$(cat "$LOCK_FILE" 2>/dev/null || echo "")
  if [ -n "$LOCK_PID" ] && kill -0 "$LOCK_PID" 2>/dev/null; then
    echo "✅ Executor running (PID $LOCK_PID)"
  else
    echo "⚠️  Stale lock file (PID $LOCK_PID not running)"
    echo "   Will be cleaned up on next scheduler run"
  fi
else
  echo "✅ Executor idle (ready to run)"
fi
echo ""

# Show recent logs
echo "📋 Recent Scheduler Activity (last 15 lines)"
echo "─────────────────────────────────────────────────────────────"

if [ -f "$LOG_FILE" ]; then
  tail -15 "$LOG_FILE" | sed 's/^/   /'
else
  echo "   No logs yet. Waiting for first scheduler run..."
fi
echo ""

echo "════════════════════════════════════════════════════════════"
echo "Commands:"
echo "  • Setup: bash tools/scheduler/setup-cron.sh . <PROJECT_KEY>"
echo "  • View logs: tail -f $LOG_FILE"
echo "  • Trigger manually: . .env && bash tools/scheduler/poll-linear.sh"
echo "════════════════════════════════════════════════════════════"
