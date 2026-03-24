---
name: generate-idea-index
description: Creates auto-generated docs/{idea}/INDEX.md with status, timestamps, and links to all idea documents
metadata:
  inputs:
    - idea_slug: string (e.g., "learnbridge")
    - docs_dir: string (absolute path to docs/{idea}/)
  outputs:
    - index_file: string (path to created INDEX.md)
    - summary: object (idea status, last updated, doc count)
  side_effects:
    - Creates docs/{idea}/INDEX.md if missing
    - Overwrites existing INDEX.md (idempotent)
  called_by:
    - build-orchestrator (stage 8)
    - project-manager (finalization)
---

# Generate Idea Index Skill

Create an auto-generated INDEX.md file for each idea that catalogs all documents, status, and metadata.

## Purpose

- **Discovery**: Users can quickly find all docs for an idea from a single entry point
- **Status tracking**: See at a glance what stage the idea is at and when it was last updated
- **Artifact inventory**: Ensures no docs are orphaned (not linked in INDEX)
- **Pipeline auditing**: INDEX.md serves as the "source of truth" for what exists

## Inputs Required

| Field | Type | Example | Notes |
|-------|------|---------|-------|
| `idea_slug` | string | `learnbridge` | Used to find docs/{idea} directory |
| `docs_dir` | string | `/Users/noon/Work/idea-forge/docs/learnbridge` | Absolute path to docs directory |

## Output Format

```markdown
---
idea: learnbridge
created_at: 2026-03-20T10:30:00Z
updated_at: 2026-03-24T14:15:30Z
status: prd_written
completion: 55%
---

# LearnBridge — Document Index

One-line summary from the idea.

## Status

- **Current Stage**: PRD Written (stage 5 of 9)
- **Last Updated**: 2026-03-24 2:15 PM
- **Progress**: ████████░░ 55% (5/9 stages complete)

## Documents

| Document | Status | Updated | Description |
|----------|--------|---------|-------------|
| [DECISIONS.md](DECISIONS.md) | ✅ Complete | 2026-03-24 | Key decisions from all stages |
| [PRD.md](PRD.md) | ✅ Complete | 2026-03-24 | Product requirements |
| [ARCHITECTURE.md](ARCHITECTURE.md) | ⏳ Pending | — | System design (stage 6) |
| [BUILD_PLAN.md](BUILD_PLAN.md) | ⏳ Pending | — | Build phases (stage 7) |
| [RESEARCH.md](RESEARCH.md) | ✅ Complete | 2026-03-22 | Market & competitors |

## Stage Breakdown

### ✅ Completed Stages

- **Stage 1**: Idea Captured (2026-03-20)
- **Stage 2**: Direction Explored (2026-03-20)
- **Stage 3**: Reviewed (2026-03-21)
- **Stage 4**: Researched (2026-03-22)
- **Stage 5**: PRD Written (2026-03-24)

### ⏳ Pending Stages

- **Stage 6**: Architecture (ready to start)
- **Stage 7**: Build Plan
- **Stage 8**: Build Orchestration
- **Stage 9**: Project Management

## Quick Links

- **Edit PRD**: `docs/learnbridge/PRD.md`
- **View Decisions**: `docs/learnbridge/DECISIONS.md`
- **GitHub Repo**: (not yet created)

## Metadata

- **Author**: Claude Code / IdeaForge
- **Generated**: 2026-03-24T14:15:30Z
- **Template Version**: 1.0
```

## Implementation Notes

**File Detection:**
- Scan `docs/{idea}/` for: `PRD.md`, `ARCHITECTURE.md`, `BUILD_PLAN.md`, `RESEARCH.md`, `DECISIONS.md`
- Mark each with status based on file existence: ✅ Complete, ⏳ Pending, ❌ Missing
- Record modification time for "Updated" field

**Stage Mapping:**
- Read from `memory/ideas_store.json` to get current stage for the idea
- Map current stage to progress percentage (stage N out of 9 = N/9 * 100%)
- Show completed stages in green, pending in yellow

**Progress Bar:**
- Use `█` (filled) and `░` (empty) for visual progress
- Formula: `█` = completed_stages, `░` = 9 - completed_stages

**Idempotency:**
- Always regenerate the entire INDEX.md (don't append/merge)
- Deterministic output — same input always produces same output
- Safe to run multiple times without side effects

## Example Usage

```bash
# From build-orchestrator after all docs written
generate-idea-index \
  --idea-slug "learnbridge" \
  --docs-dir "/Users/noon/Work/idea-forge/docs/learnbridge"
```

Returns:
```json
{
  "index_file": "/Users/noon/Work/idea-forge/docs/learnbridge/INDEX.md",
  "summary": {
    "idea": "learnbridge",
    "status": "prd_written",
    "stage_number": 5,
    "completion_percent": 55,
    "last_updated": "2026-03-24T14:15:30Z",
    "document_count": 5,
    "documents": ["PRD.md", "DECISIONS.md", "RESEARCH.md"]
  }
}
```

## Error Handling

**If docs directory doesn't exist:**
- Create it first (fail if parent doesn't exist)
- Create INDEX.md with "No documents yet" placeholder

**If docs/ is empty:**
- Still create INDEX.md with empty stage list
- Show "No stages completed yet" state

**If ideas_store.json is missing idea:**
- Infer stage from document existence
- Show "stage unknown" in progress section

