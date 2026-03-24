# {project_name}

> {one_line_description}

## How to work in this repo

This repo follows **harness engineering** principles: humans steer, agents execute. Every line of code is agent-generated. The repo itself is the system of record — if it's not in the repo, it doesn't exist.

## Map (start here)

Read [AGENTS.md](AGENTS.md) first. It is the table of contents for the entire project — short, stable, and points to everything else.

## Key docs (progressive disclosure)

| What you need | Where to look |
|---------------|---------------|
| Project map & conventions | [AGENTS.md](AGENTS.md) |
| System design & components | [ARCHITECTURE.md](ARCHITECTURE.md) |
| Product requirements | [docs/product-specs/mvp.md](docs/product-specs/mvp.md) |
| Build phases & milestones | [docs/exec-plans/active/](docs/exec-plans/active/) |
| Design decisions & rationale | [docs/design-docs/](docs/design-docs/) |
| Project structure & naming | [SCAFFOLDING.md](SCAFFOLDING.md) |
| Issue workflow & routing | [WORKFLOW.md](WORKFLOW.md) |
| Quality gates & metrics | [docs/QUALITY_SCORE.md](docs/QUALITY_SCORE.md) |
| Security model | [docs/SECURITY.md](docs/SECURITY.md) |
| Reliability & monitoring | [docs/RELIABILITY.md](docs/RELIABILITY.md) |

## Working rules

1. **Docs are truth.** If the code and docs disagree, fix the code.
2. **One task at a time.** Pick one Linear issue, finish it, merge it, then pick the next.
3. **Tests are not optional.** Every implementation has a paired test requirement.
4. **Follow WORKFLOW.md.** It defines how issues move through states (Todo -> In Progress -> Merging -> Done).
5. **Follow SCAFFOLDING.md.** It defines naming, folder structure, and conventions.
6. **Follow ARCHITECTURE.md.** It defines component boundaries — don't put logic in the wrong layer.
7. **Commit messages:** `{ISSUE-ID}: brief description`
8. **Branch per issue:** `{ISSUE-ID}-brief-name`

## Architecture enforcement

This project uses layered domain architecture with strict boundaries:
- Code can only depend "forward" through layers (Types -> Config -> Repo -> Service -> Runtime -> UI)
- Cross-cutting concerns (auth, telemetry, feature flags) enter through a single explicit interface
- These constraints are enforced by linters and structural tests — violations break CI

See [ARCHITECTURE.md](ARCHITECTURE.md) for the full layer map.

## Agent legibility

Everything an agent needs must be in-repo:
- **No tribal knowledge.** If a decision was made in conversation, write it to [docs/design-docs/](docs/design-docs/).
- **No external-only docs.** If context lives in Google Docs or Slack, copy the relevant parts into [docs/references/](docs/references/).
- **Errors teach.** Custom linter messages include remediation instructions so agents can self-correct.

## Symphony execution

This repo is designed for autonomous agent execution via the Symphony pattern:

1. **Linear is the work queue.** All tasks live as Linear issues.
2. **WORKFLOW.md is the routing table.** It tells the agent what to do for each issue state.
3. **One issue at a time.** Agent picks up a Todo issue, implements it end-to-end, merges, moves to Done.
4. **Feedback loops.** Agent validates its own work: runs tests, checks CI, reads PR feedback, iterates.
5. **Human escalation.** If the agent hits a genuine blocker, it marks the issue as Rework and stops.

### To start the execution loop

```
Read WORKFLOW.md -> Pick next Todo issue from Linear -> Follow WORKFLOW.md routing -> Implement -> Test -> PR -> Merge -> Pick next
```

## Entropy management

Agent-generated code drifts. To prevent decay:
- **Golden principles** in [docs/design-docs/core-beliefs.md](docs/design-docs/core-beliefs.md) define what "correct" looks like
- **Quality scores** in [docs/QUALITY_SCORE.md](docs/QUALITY_SCORE.md) track gaps per domain
- **Tech debt** in [docs/exec-plans/tech-debt-tracker.md](docs/exec-plans/tech-debt-tracker.md) is tracked and paid down continuously
- Run cleanup tasks regularly: scan for pattern deviations, update quality grades, open refactoring PRs

## Commands

| Command | What it does |
|---------|-------------|
| `{dev_command}` | Start dev server |
| `{test_command}` | Run tests |
| `{build_command}` | Build for production |
| `{add_command} {package}` | Add a dependency |
