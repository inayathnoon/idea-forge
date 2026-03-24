---
name: save-built-state
description: Updates memory/ideas_store.json with stage=built and github_url. Use after the build orchestrator has created the GitHub repo.
metadata:
  inputs: []
  outputs:
    - memory/ideas_store.json
  side_effects:
    - writes file
  called_by:
    - build-orchestrator
---

# Save Built State

Read `memory/ideas_store.json`, update the latest idea with:

- `stage`: `"built"`
- `github_url`: repo URL
- `updated_at`: current ISO timestamp

Write the updated JSON back.
