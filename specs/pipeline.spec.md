# Pipeline Specification

IdeaForge Pipeline — the formal specification of stages, transitions, gates, and invariants.

## Stage Definitions

| # | Name | Agent | Input | Output | Invariants |
|---|------|-------|-------|--------|-----------|
| 1 | Raw → Captured | idea-capturer-1 | Raw idea (text) | memory/ideas_store.json with stage=captured | Idea has name, problem, solution, target_users |
| 2 | Captured → Explored | idea-explorer-2 | Structured idea | idea_storage/{slug}-{timestamp}/ with 10 directions | 3 directions selected, user chose one |
| 3 | Explored → Reviewed | strategist-3 | Direction + spec | review verdict in ideas_store.json | Verdict is approved, revise, or reject |
| 4 | Reviewed → Researched | researcher-4 | Approved idea | docs/PRODUCT_SENSE.md | Market research findings documented |
| 5 | Researched → PRD Written | prd-writer-5 | Research + idea | docs/product-specs/mvp.md | MVP features defined, success metrics set |
| 6 | PRD → Architecture | arch-writer-6 | PRD + stack | ARCHITECTURE.md | Components, data flow, tech choices justified |
| 7 | Architecture → Plan Written | plan-writer-7 | PRD + architecture | docs/exec-plans/active/mvp-build-plan.md | Phases defined, risks identified |
| 8 | Plan → Built | build-orchestrator-8 | All docs | GitHub repo + docs pushed | Repo created, all docs in place, stage=built |
| 9 | Cross-cutting | project-manager | All outputs | docs/design-docs/DECISIONS.md | Decision log current through all stages |

## State Machine

```
raw ──[idea-capturer-1]──> captured
                              │
                     [idea-explorer-2]
                              │
                          explored
                              │
                         [strategist-3]
                              │
         ┌────────────────── reviewed ─────────────────┐
         │                     │                       │
      (revise)          (approved)                   (reject)
         │                     │                       │
         └──> captured     researched              (terminal)
                              │
                      [researcher-4]
                              │
                          prd_written ◄──────┐
                              │              │
                        [prd-writer-5]       │
                              │              │
                          prd_written
                              │
                        [arch-writer-6]
                              │
                          arch_written
                              │
                        [plan-writer-7]
                              │
                          plan_written
                              │
                      [build-orchestrator-8]
                              │
                           built
```

## Gated States

### `reviewed` State

**Gate condition**: Review verdict

```json
{
  "field": "review.verdict",
  "routes": {
    "approved": "researched",    // Proceed to research
    "revise": "captured",        // Go back to stage 1
    "reject": null               // Terminate (user can restart)
  }
}
```

## Artifacts Required per Stage

| Stage | Required Artifacts | Optional |
|-------|-------------------|----------|
| 1 | ideas_store.json entry | — |
| 2 | idea_storage/{slug}-{timestamp}/overview.txt, selected.txt | explorations/ |
| 3 | review.verdict in ideas_store.json | review scores |
| 4 | docs/PRODUCT_SENSE.md | competitor analysis |
| 5 | docs/product-specs/mvp.md | user stories, wireframes |
| 6 | ARCHITECTURE.md | diagrams, deployment guide |
| 7 | docs/exec-plans/active/mvp-build-plan.md | risk register |
| 8 | GitHub repo, all docs pushed | CI/CD workflows |
| 9 | docs/design-docs/DECISIONS.md | linked decision docs |

## Invariants (Always True)

1. **Monotonic progress**: Stage number never decreases (except revise from stage 3)
2. **Artifact completeness**: If stage ≥ N, all artifacts for stages 1..N exist
3. **No orphaned docs**: Every doc in docs/ is referenced in ideas_store.json
4. **Logging continuity**: Every transition logged to pipeline_log.json
5. **State snapshots**: Snapshots exist before each agent run

## Cross-Cutting Concerns

- **Logging**: log-run skill called before and after each agent
- **Snapshots**: snapshot-state skill creates backup before each stage
- **Consistency**: consistency-checker validates invariants periodically
- **Decisions**: project-manager documents key decisions after each stage
- **Transitions**: transition-state skill validates state changes

## Rollback Capability

Each snapshot has format: `memory/snapshots/{stage}-{timestamp}/`

```bash
# Restore to previous stage
cp -r memory/snapshots/{stage}-{timestamp}/* .
transition-state --to-state "{previous_state}"
```

## Running the Pipeline

**Start from raw**:
```bash
/new-idea
```

**Resume from stage 4+**:
```bash
/existing-idea
```

**Skip to next stage**:
```bash
/advance
```

**Check system health**:
```bash
consistency-checker
```
