#!/usr/bin/env python3
"""
Checkpoint and rollback system for pipeline recovery.

Saves snapshots of the ideas_store.json and document states at each stage,
allowing recovery if an agent fails or needs to restart.

Usage:
  # Save a checkpoint before running an agent
  python3 harness/checkpoint.py save <stage_name>

  # List saved checkpoints
  python3 harness/checkpoint.py list

  # Rollback to a specific checkpoint
  python3 harness/checkpoint.py rollback <checkpoint_name>

  # Show details of a checkpoint
  python3 harness/checkpoint.py show <checkpoint_name>

Example:
  python3 harness/checkpoint.py save captured
  # Saves: .claude/.checkpoints/captured_2026-03-24_14-30-45.json

  python3 harness/checkpoint.py rollback captured_2026-03-24_14-30-45
  # Restores ideas_store.json from that checkpoint
"""

import json
import sys
import os
from pathlib import Path
from datetime import datetime
import shutil


CHECKPOINT_DIR = Path(".claude/.checkpoints")


def ensure_checkpoint_dir():
    """Create checkpoint directory if it doesn't exist."""
    CHECKPOINT_DIR.mkdir(parents=True, exist_ok=True)


def save_checkpoint(stage_name):
    """Save a checkpoint of the current state."""
    ensure_checkpoint_dir()

    ideas_store = Path("memory/ideas_store.json")
    if not ideas_store.exists():
        print("ERROR: memory/ideas_store.json not found", file=sys.stderr)
        return False

    # Create timestamped checkpoint file
    timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    checkpoint_name = f"{stage_name}_{timestamp}"
    checkpoint_path = CHECKPOINT_DIR / f"{checkpoint_name}.json"

    # Read current state
    with open(ideas_store) as f:
        state = json.load(f)

    # Save checkpoint
    checkpoint_data = {
        "stage": stage_name,
        "timestamp": datetime.now().isoformat(),
        "checkpoint_name": checkpoint_name,
        "ideas_store": state,
    }

    with open(checkpoint_path, "w") as f:
        json.dump(checkpoint_data, f, indent=2)

    print(f"✅ Checkpoint saved: {checkpoint_name}")
    print(f"   Path: {checkpoint_path}")
    return True


def list_checkpoints():
    """List all available checkpoints."""
    ensure_checkpoint_dir()

    checkpoints = sorted(CHECKPOINT_DIR.glob("*.json"))
    if not checkpoints:
        print("No checkpoints found")
        return True

    print("Available checkpoints:\n")
    for cp in checkpoints:
        with open(cp) as f:
            data = json.load(f)
        timestamp = data.get("timestamp", "unknown")
        stage = data.get("stage", "unknown")
        print(f"  {data['checkpoint_name']}")
        print(f"    Stage: {stage}")
        print(f"    Time: {timestamp}\n")

    return True


def show_checkpoint(checkpoint_name):
    """Show details of a specific checkpoint."""
    ensure_checkpoint_dir()

    checkpoint_path = CHECKPOINT_DIR / f"{checkpoint_name}.json"
    if not checkpoint_path.exists():
        print(f"ERROR: Checkpoint not found: {checkpoint_name}", file=sys.stderr)
        return False

    with open(checkpoint_path) as f:
        data = json.load(f)

    print(f"Checkpoint: {checkpoint_name}\n")
    print(f"Stage: {data.get('stage')}")
    print(f"Timestamp: {data.get('timestamp')}\n")

    ideas = data.get("ideas_store", {}).get("ideas", [])
    if ideas:
        latest = ideas[-1]
        print(f"Latest idea: {latest.get('full_name')}")
        print(f"Stage: {latest.get('stage')}")
        print(f"Created: {latest.get('created_at')}")
        print(f"Updated: {latest.get('updated_at')}")

    return True


def rollback_checkpoint(checkpoint_name):
    """Rollback to a specific checkpoint."""
    ensure_checkpoint_dir()

    checkpoint_path = CHECKPOINT_DIR / f"{checkpoint_name}.json"
    if not checkpoint_path.exists():
        print(f"ERROR: Checkpoint not found: {checkpoint_name}", file=sys.stderr)
        return False

    with open(checkpoint_path) as f:
        data = json.load(f)

    ideas_store = Path("memory/ideas_store.json")

    # Backup current state before rollback
    if ideas_store.exists():
        backup_path = CHECKPOINT_DIR / f"backup_before_rollback_{datetime.now().strftime('%Y-%m-%d_%H-%M-%S')}.json"
        shutil.copy(ideas_store, backup_path)
        print(f"Current state backed up to: {backup_path}")

    # Restore from checkpoint
    with open(ideas_store, "w") as f:
        json.dump(data["ideas_store"], f, indent=2)

    print(f"✅ Rolled back to: {checkpoint_name}")
    print(f"   ideas_store.json restored")
    return True


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 harness/checkpoint.py <command> [args]")
        print("Commands:")
        print("  save <stage>          Save a checkpoint before running an agent")
        print("  list                  List all checkpoints")
        print("  show <checkpoint>     Show checkpoint details")
        print("  rollback <checkpoint> Rollback to a checkpoint")
        sys.exit(1)

    command = sys.argv[1]

    if command == "save":
        if len(sys.argv) < 3:
            print("ERROR: stage name required", file=sys.stderr)
            sys.exit(1)
        stage_name = sys.argv[2]
        success = save_checkpoint(stage_name)
        sys.exit(0 if success else 1)

    elif command == "list":
        success = list_checkpoints()
        sys.exit(0 if success else 1)

    elif command == "show":
        if len(sys.argv) < 3:
            print("ERROR: checkpoint name required", file=sys.stderr)
            sys.exit(1)
        checkpoint_name = sys.argv[2]
        success = show_checkpoint(checkpoint_name)
        sys.exit(0 if success else 1)

    elif command == "rollback":
        if len(sys.argv) < 3:
            print("ERROR: checkpoint name required", file=sys.stderr)
            sys.exit(1)
        checkpoint_name = sys.argv[2]
        success = rollback_checkpoint(checkpoint_name)
        sys.exit(0 if success else 1)

    else:
        print(f"ERROR: Unknown command: {command}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
