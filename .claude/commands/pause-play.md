# /pause-play — Pause or Resume a Session

Saves where you are at the end of a session, and briefs you back at the start of the next one.

## Auto-detect mode

- Read `memory/session.md`
- If it exists and `status: paused` → **PLAY mode**
- Otherwise → **PAUSE mode**

---

## PAUSE mode

Run at the end of a session to snapshot state.

**Tip:** Before pausing, create a checkpoint as a backup:
```bash
python3 harness/checkpoint.py save {current_stage}
```

This allows recovery if something fails when you resume.

### Step 1 — Gather state
- Read `memory/ideas_store.json` — active idea, stage, name
- Check which docs exist in `docs/{idea.name}/`
- Review the current conversation — identify what was done, what was discussed, what was left open

### Step 2 — Write `memory/session.md`

```
status: paused
paused_at: {YYYY-MM-DD HH:MM}
idea: {idea.name}
stage: {current stage N of 8}

## What was done this session
- {concise bullet per meaningful action — files created, decisions made, changes}

## Open questions
- {anything unresolved or deferred mid-session}

## Docs state
DECISIONS.md {✅/missing} | RESEARCH.md {✅/missing} | PRD.md {✅/missing} | ARCHITECTURE.md {✅/missing} | BUILD_PLAN.md {✅/missing}

## Next 3 actions
1. {most important — be specific, e.g. "Answer 4 arch questions then draft ARCHITECTURE.md"}
2. {second priority}
3. {third priority}
```

### Step 3 — Append to `memory/session-log.md`

Append a one-paragraph summary of this session to the log (create file if missing). Format:

```
## Session {YYYY-MM-DD}
{2–4 sentences: what idea, what stage, what was done, what's next}
```

### Step 4 — Confirm to user

Show the session snapshot and say:
> Session paused. Open `/pause-play` next time to resume.

---

## PLAY mode

Run at the start of a new session to resume.

### Step 1 — Resolve which idea to resume

Read `memory/session.md` (already confirmed to exist and be `status: paused`).

- If `session.md` has an `idea:` field → use it. Skip to Step 2.
- If `session.md` has no `idea:` field → fall back to `memory/ideas_store.json` and collect all incomplete ideas (missing at least one doc):
  - **0 incomplete** → tell the user all ideas are fully built and stop.
  - **1 incomplete** → use it. Skip to Step 2.
  - **2+ incomplete** → show a numbered list and ask which to resume:

```
Multiple ideas in progress — which one do you want to resume?

1. {idea.full_name} — Stage {N}, missing: {doc list}
2. {idea.full_name} — Stage {N}, missing: {doc list}
```

Wait for the user's answer, then proceed with the chosen idea.

### Step 2 — Verify current state
- Re-check which docs actually exist in `docs/{idea.name}/`
- Re-read `memory/ideas_store.json` to confirm stage

### Step 3 — Brief the user

Show this summary:

```
Last session: {paused_at}

Idea:   {idea} — Stage {N} of 8
Docs:   DECISIONS.md {✅/missing} | RESEARCH.md {✅/missing} | PRD.md {✅/missing} | ARCHITECTURE.md {✅/missing} | BUILD_PLAN.md {✅/missing}

What was done:
{bullets from session.md}

Open questions:
{bullets from session.md — empty if none}

Next 3 actions:
1. {action 1}
2. {action 2}
3. {action 3}
```

### Step 4 — Update `memory/session.md`

Set `status: active` to prevent re-triggering PLAY mode on the next `/pause-play` call.

### Step 5 — Ask

> Ready to continue with action 1, or do you want to start somewhere else?

Wait for the user's answer, then proceed.
