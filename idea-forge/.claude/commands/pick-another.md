# /pick-another — Pick Another Direction to Build

Shows all 10 directions from a previous exploration, marks which have been built, recommends what to build next, and kicks off the pipeline if the user agrees.

---

## Step 1 — Find the idea to pull directions from

1. Read `memory/session.md` — if `idea:` is set, use that idea's slug.
2. Otherwise read `memory/ideas_store.json` — use the most recently updated idea.
3. Find the matching exploration folder: `idea_storage/{slug}-*/overview.txt`
   - If multiple folders exist for the same slug, use the most recent one.
   - If no folder exists, tell the user: "No direction exploration found for this idea. Run `/new-idea` to start fresh." Stop.

---

## Step 2 — Build the direction list

Read `idea_storage/{slug}-{timestamp}/directions.txt` for the full descriptions.
Read `idea_storage/{slug}-{timestamp}/overview.txt` for which direction was selected (marked `← SELECTED`).

For each of the 10 directions, determine its status:

| Status | Condition |
|---|---|
| `[built]` | A corresponding idea exists in `memory/ideas_store.json` with `stage: reviewed` or `stage: built` and matches this direction's name/concept |
| `[in progress]` | A corresponding idea exists in `ideas_store.json` but is still incomplete |
| `[explored]` | Was selected in this exploration session but not found in ideas_store (e.g. abandoned mid-pipeline) |
| _(unmarked)_ | Never touched |

The currently active idea counts as `[in progress]` or `[built]` depending on its stage and docs.

---

## Step 3 — Show the list

Display all 10 directions. Use status markers inline. Show full descriptions for unmarked and `[explored]` ones; brief one-liners for `[built]`/`[in progress]` ones.

Format:

```
Directions explored for: {idea.full_name}

 1. [built]       Direct-to-Consumer B2C Subscription
 2.               B2B School License
                  Sell to CBSE schools. Teachers get stuck alerts instead of parents.
                  School admin dashboard shows class-wide patterns. Per-school subscription.
 3. [in progress] WhatsApp-Native Parent Alerts
 4.               AI Tutor (No Parent Loop)
                  ...
...
10.               Parenting Confidence Platform
                  ...

Top 3 from original exploration: #1, #3, #4
```

---

## Step 4 — Recommend one

Pick the best next direction to build using this priority:
1. A top-3 direction that is unmarked (never explored)
2. An `[explored]` direction from the top 3 that never made it to `[built]`
3. Any unmarked direction that is highest-potential (use judgment based on descriptions)

State the recommendation clearly:

```
Recommended next: Direction {N} — {name}
{One sentence on why — differentiation from what's already been built, or strategic fit}
```

---

## Step 5 — Ask

> Want to build Direction {N} — {name}? Or pick a different one?

Wait for the user's answer.

- If they confirm the recommendation → use that direction.
- If they name a different number → use that direction.
- If they say no / not now → stop gracefully.

---

## Step 6 — Kick off the pipeline

Run the full `agents/idea-capturer-1.md` flow, but **pre-seed the idea** with the chosen direction's description from `directions.txt` as the raw input. Skip the elaboration step — the direction is already defined.

From there the pipeline continues normally:
```
idea-capturer-1 → project-manager → idea-explorer-2 → strategist-3 → [gate] → researcher-4 → ...
```
