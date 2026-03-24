# /advance — Run the Next Step

No prompts. No confirmations. Just runs the next agent in the pipeline.

## How it works

### Step 1 — Resolve which idea to advance

1. Read `memory/session.md` — if it has an `idea:` field and `status: active`, that is the active idea. Use it. Skip to Step 2.
2. Otherwise read `memory/ideas_store.json` and collect all ideas that are **incomplete** (missing at least one doc).
   - **0 incomplete** → tell the user all ideas are fully built and stop.
   - **1 incomplete** → use it. Skip to Step 2.
   - **2+ incomplete** → show a numbered list and ask which to advance:

```
Multiple ideas in progress — which one?

1. {idea.full_name} — Stage {N}, missing: {doc list}
2. {idea.full_name} — Stage {N}, missing: {doc list}
```

Wait for the user's answer, then proceed with the chosen idea.

### Step 1b — Save Checkpoint (Recovery)

Before running the agent, save a checkpoint so you can recover if something fails:

```bash
python3 harness/checkpoint.py save {current_stage}
```

This saves the current `ideas_store.json` state. If the agent fails, you can rollback with:
```bash
python3 harness/checkpoint.py rollback {checkpoint_name}
```

### Step 2 — Determine the next stage

Read `memory/ideas_store.json` and check which docs exist in `docs/{idea.name}/`:

| Docs present | Next stage |
|---|---|
| No `RESEARCH.md` | Stage 4 — Researcher |
| `RESEARCH.md`, no `PRD.md` | Stage 5 — PRD Writer |
| `PRD.md`, no `ARCHITECTURE.md` | Stage 6 — Arch Writer |
| `ARCHITECTURE.md`, no `BUILD_PLAN.md` | Stage 7 — Plan Writer |
| All docs present | Stage 8 — Build Orchestrator |
| All docs + repo pushed | Nothing left — tell the user |

### Step 2 — Announce and run

Print exactly one line:

```
→ Advancing to Stage {N}: {agent name}
```

Then immediately follow the agent file in full — no further confirmation.

---

## Agent files

- Stage 4: `agents/researcher-4.md`
- Stage 5: `agents/prd-writer-5.md`
- Stage 6: `agents/arch-writer-6.md`
- Stage 7: `agents/plan-writer-7.md`
- Stage 8: `agents/build-orchestrator-8.md`

### Step 3 — Auto-trigger Cross-Cutting Agents

After the main agent completes, check for cross-cutting agents that should run automatically:

```bash
python3 harness/trigger-cross-cutting.py {from_stage} {to_stage}
```

This will output which cross-cutting agents (currently: `project-manager`) should be triggered. Run them in the order specified.

**project-manager** is called after most stage transitions to capture key decisions made during that stage in `docs/design-docs/`. Follow `agents/project-manager.md` to document the stage's architectural choices, trade-offs, and rationale.

### Step 4 — Collect Feedback

After the agent completes, collect feedback on its output:

```bash
python3 harness/feedback.py {stage_name}
```

This prompts you for:
- **Rating:** thumbs up/down/neutral
- **What worked:** positive notes
- **What needs work:** improvement notes
- **Suggestions:** specific ideas to try next time

Feedback is logged in `memory/feedback.json` and helps refine the playbook and agents over time.

Then update `memory/session.md` to reflect the new completed stage.
