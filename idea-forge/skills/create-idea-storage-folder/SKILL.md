---
name: create-idea-storage-folder
description: Creates idea_storage folder with overview, directions, and 3 direction subfolders. Use when planner has top 3 directions ready and needs to persist them for the user.
metadata:
  inputs: []
  outputs:
    - idea_storage/{slug}-{timestamp}/
  side_effects:
    - creates folder and direction files
  called_by:
    - idea-explorer
---

# Create Idea Storage Folder

Create a folder in `idea_storage/` with this structure:

```
idea_storage/{slug}-{timestamp}/
  overview.txt           # The whole thing: original, 10 directions, top 3, selected
  original.txt           # User's elaborated idea
  directions.txt         # All 10 directions
  selection.txt          # Why these top 3
  selected.txt           # Which is selected (default: closest)
  direction-1-{slug}/
    idea.txt             # Explains this direction
    status.txt           # "selected" | "exploring" | "parked"
  direction-2-{slug}/
    idea.txt
    status.txt
  direction-3-{slug}/
    idea.txt
    status.txt
```

## Rules

- Slug = lowercase, hyphens
- Timestamp = YYYYMMDD or YYYYMMDD-HHMM
- Closest direction gets `status: selected`; others get `status: exploring`
