# /existing-idea — Resume an Existing Idea

Continue an idea that's already been captured, explored, and reviewed (stages 1-3 done). Useful when you have a clear idea and want to skip the exploration phase.

## Process

### 1. Check Ideas Store
Read `memory/ideas_store.json`. List all ideas with their current stage.

If no ideas exist, tell the user to run `/new-idea` first.

### 2. Select Idea
If multiple ideas exist, show them and ask the user to pick one.

### 3. Validate Stage
The idea must be at stage `reviewed` with `verdict: approved` (or later). If not:
- Stage < reviewed: Tell user to run `/advance` to complete earlier stages
- Verdict != approved: Tell user the idea was not approved

### 4. Resume Pipeline
Run `/advance` from the current stage. This picks up wherever the idea left off:
- `reviewed` → researcher-4
- `researched` → prd-writer-5
- `prd_written` → arch-writer-6
- `arch_written` → plan-writer-7
- `plan_written` → doc-pusher-8

Each step follows the `/advance` flow (checkpoint → agent → cross-cutting → feedback).
