# /status — Check Pipeline Status

Show the current state of the idea pipeline.

## Process

### 1. Run Status Script
```bash
python3 harness/status.py
```

This displays:
- Current idea name and full name
- Current pipeline stage and progress
- Review verdict (if at reviewed stage)
- Next step and which agent runs
- Required artifacts for next stage
- Timestamps

### 2. Check Documents
If the idea is at stage 4+, verify the expected documents exist in `documents/{idea.name}/`:
- `documents/{idea.name}/docs/PRODUCT_SENSE.md` (stage 4+)
- `documents/{idea.name}/docs/product-specs/mvp.md` (stage 5+)
- `documents/{idea.name}/ARCHITECTURE.md` (stage 6+)
- `documents/{idea.name}/docs/exec-plans/active/mvp-build-plan.md` (stage 7+)
- `documents/{idea.name}/docs/design-docs/` (cross-cutting, check for files)

Report which documents exist and which are missing.

### 3. Show Available Commands
Based on the current stage, suggest what the user can do next:
- `/advance` — run the next agent
- `/rollback` — restore a previous checkpoint
- `/pick-another` — try a different direction (if at stage 3+)
