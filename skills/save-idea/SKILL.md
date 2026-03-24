---
name: save-idea
description: Saves structured idea to memory/ideas_store.json. Use when idea agent has produced a structured spec and needs to persist it.
metadata:
  inputs: []
  outputs:
    - memory/ideas_store.json
  side_effects:
    - writes file
  called_by:
    - idea-capturer
---

# Save Idea

Read `memory/ideas_store.json` (create it with `{ "ideas": [] }` if it doesn't exist). Append the new idea object to the `ideas` array. Write the file back.

## Schema

```json
{
  "name": "project-slug",
  "full_name": "Human Readable Name",
  "problem": "...",
  "solution": "...",
  "target_users": "...",
  "mvp_features": [ { "title": "", "description": "", "priority": "high|medium|low" } ],
  "success_metrics": [],
  "constraints": "",
  "repo_topics": []
}
```

Do NOT include `tech_stack` — that is decided later during scaffolding.
