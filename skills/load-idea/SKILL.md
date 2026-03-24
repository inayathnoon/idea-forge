---
name: load-idea
description: Loads the latest idea from memory/ideas_store.json. Use when review or build agent needs to read structured idea and optional review data.
metadata:
  inputs:
    - memory/ideas_store.json
  outputs: []
  side_effects: []
  called_by:
    - strategist
---

# Load Idea

Read `memory/ideas_store.json`. Load the latest idea (last in `ideas` array).

For Review/Build agents: also load the `review` field if present.

Stop if no ideas exist — tell user to run Idea Agent first.
