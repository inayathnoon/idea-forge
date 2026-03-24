#!/bin/bash

# Symphony Scheduler Status Dashboard
# Shows scheduler and executor health
# Usage: bash status.sh

set -e

LOCK_FILE="${LOCK_FILE:-/tmp/symphony-executor.lock}"
LOG_FILE="${LOG_FILE:-/var/log/symphony-scheduler.log}"

echo "═══════════════════════════════════════════════════════════════"
echo "Symphony Scheduler Status"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Check cron job status
echo "📅 Cron Job Status:"
if crontab -l 2>/dev/null | grep -q "symphony-scheduler"; then
  echo "   ✅ Active (configured)"
  CRON_LINE=$(crontab -l 2>/dev/null | grep "symphony-scheduler" | head -1)
  echo "   Schedule: ${CRON_LINE:0:50}..."
else
  echo "   ❌ Not configured"
  echo "   Run: bash tools/scheduler/setup-cron.sh <repo-path> <project-key>"
fi

echo ""

# Check executor status
echo "🚀 Executor Status:"
if [[ -f "$LOCK_FILE" ]]; then
  PID=$(cat "$LOCK_FILE" 2>/dev/null || echo "")
  if [[ -n "$PID" ]] && kill -0 "$PID" 2>/dev/null; then
    echo "   🟢 Running (PID $PID)"
    # Show process details
    ps -p "$PID" -o etime,cmd 2>/dev/null | tail -1 | sed 's/^/      /'
  else
    echo "   ⚠️  Stale lock file detected (PID $PID no longer alive)"
    echo "   Lock file: $LOCK_FILE"
    echo "   Auto-cleanup will occur on next scheduler run"
  fi
else
  echo "   🔵 Idle (no executor running)"
fi

echo ""

# Check log file
echo "📝 Recent Logs:"
if [[ -f "$LOG_FILE" ]]; then
  LOG_SIZE=$(du -h "$LOG_FILE" | cut -f1)
  echo "   Log file: $LOG_FILE ($LOG_SIZE)"
  echo "   Last 15 lines:"
  echo ""
  tail -15 "$LOG_FILE" | sed 's/^/      /'
else
  echo "   ⚠️  Log file not found: $LOG_FILE"
  echo "   Scheduler has not run yet, or log path is different"
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Summary
echo "💡 Quick actions:"
echo "   tail -f $LOG_FILE          — Watch logs in real-time"
echo "   crontab -e                 — Edit cron schedule"
echo "   rm $LOCK_FILE              — Manually clear stale lock"
echo ""

exit 0
