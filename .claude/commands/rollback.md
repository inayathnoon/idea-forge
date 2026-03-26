# /rollback — Restore a Previous Checkpoint

List saved checkpoints and restore one. Replaces the old `/pause-play` command.

## Process

### 1. List Checkpoints
```bash
python3 harness/checkpoint.py list
```

Shows all saved checkpoints with stage name and timestamp.

### 2. User Picks
If the user specifies a checkpoint name, restore it directly. Otherwise show the list and ask which one to restore.

### 3. Restore
```bash
python3 harness/checkpoint.py rollback {checkpoint_name}
```

This:
- Backs up the current `memory/ideas_store.json` before overwriting
- Restores `ideas_store.json` from the checkpoint
- Tells the user what stage they're now at

### 4. Next Steps
After rollback, suggest:
- `/status` to verify the restored state
- `/advance` to re-run from the restored stage
