# /advance — Run the Next Pipeline Stage

Run the next agent in the pipeline for the current idea. Handles checkpointing, cross-cutting agents, and feedback automatically.

## Process

### 1. Read Current State
```bash
python3 harness/status.py
```
Get the current idea and stage from `memory/ideas_store.json`. Identify the next transition from `harness/pipeline.json`.

If the pipeline is complete (stage = `built`), stop and tell the user.

### 2. Auto-Checkpoint
Save a checkpoint before running the agent so we can rollback if something goes wrong:
```bash
python3 harness/checkpoint.py save {current_stage}
```

### 3. Run the Next Agent
Read `harness/pipeline.json` to find the next transition. Load the agent file from `agents/{agent_name}.md` and follow its instructions exactly.

The agent sequence:
| From | To | Agent |
|------|----|-------|
| raw | captured | idea-capturer-1 |
| captured | explored | idea-explorer-2 |
| explored | reviewed | strategist-3 |
| reviewed | researched | researcher-4 |
| researched | prd_written | prd-writer-5 |
| prd_written | arch_written | arch-writer-6 |
| arch_written | plan_written | plan-writer-7 |
| plan_written | built | doc-pusher-8 |

**Gate check**: If current stage is `reviewed`, check `review.verdict`:
- `approved` → proceed to researcher-4
- `revise` → loop back to idea-capturer-1
- `reject` → stop, tell user

### 4. Trigger Cross-Cutting Agents
After the agent completes, check if any cross-cutting agents should run:
```bash
python3 harness/trigger-cross-cutting.py {from_stage} {to_stage}
```
If project-manager is listed, follow `agents/project-manager.md` to capture decisions.

### 5. Collect Feedback
Ask the user how the agent did:
```bash
python3 harness/feedback.py {to_stage}
```
This saves ratings and notes to `memory/feedback.json` for future improvements.

### 6. Report
Show what happened and what's next:
```
Stage complete: {from_stage} -> {to_stage}
Agent: {agent_name}
Checkpoint: {checkpoint_name}

Next: /advance to run {next_agent}
```
