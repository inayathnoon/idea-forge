# /status — Check Pipeline Status

Show the current stage and progress of the active idea through the IdeaForge pipeline.

## What it does

Reads `memory/ideas_store.json` and `harness/pipeline.json`, then displays:
- Current idea name and repository
- Current stage (raw → captured → explored → reviewed → researched → built)
- Progress through pipeline (e.g., "5/9")
- Next stage and required agent
- Review verdict (if in reviewed stage)
- Timestamps (created, last updated)

## Usage

```
python3 harness/status.py [memory/ideas_store.json]
```

## Example output

```
============================================================
  IdeaForge Pipeline Status
============================================================

📌 Idea: LearnBridge — App-First Learning Companion
   Slug: learnbridge
   Repo: https://github.com/inayathnoon/learnbridge

📊 Stage Progress: 9/9
   Current: BUILT
   GitHub repo created, all docs and conductor system pushed

✅ Pipeline Complete!

📅 Created: 2026-03-01T11:12:02Z
   Updated: 2026-03-02T13:21:00Z

============================================================
```

## Return codes

- `0`: Status displayed successfully
- `1`: ideas_store.json not found or empty

## See also

- `/new-idea` — Start a new idea
- `/existing-idea` — Resume an idea at stage 4+
- `/advance` — Run the next agent
- `/pick-another` — Pick a direction to build
