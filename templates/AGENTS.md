# {project_name}

> {one_line_description}

## Documentation Map

| Directory | Contents |
|-----------|----------|
| [CLAUDE.md](CLAUDE.md) | How to work in this repo — rules, patterns, commands |
| [ARCHITECTURE.md](ARCHITECTURE.md) | System design, components, data flow, tech stack |
| [SCAFFOLDING.md](SCAFFOLDING.md) | Folder structure, naming, conventions, common tasks |
| [WORKFLOW.md](WORKFLOW.md) | Issue routing — how agents pick up and complete Linear issues |
| [docs/product-specs/](docs/product-specs/) | What we're building — product requirements and MVP spec |
| [docs/design-docs/](docs/design-docs/) | Why we chose each design — decision records and core beliefs |
| [docs/exec-plans/](docs/exec-plans/) | How we're building it — phases, milestones, tech debt |
| [docs/generated/](docs/generated/) | Auto-generated docs (schema, API references) |
| [docs/references/](docs/references/) | LLM context files for external tools and libraries |

## Domain Docs

| Doc | What it covers |
|-----|---------------|
| [docs/DESIGN.md](docs/DESIGN.md) | Visual design, UI/UX, component patterns |
| [docs/FRONTEND.md](docs/FRONTEND.md) | Frontend architecture, state, routing |
| [docs/PRODUCT_SENSE.md](docs/PRODUCT_SENSE.md) | Market research, competitors, validation |
| [docs/QUALITY_SCORE.md](docs/QUALITY_SCORE.md) | Quality grades per domain, test coverage targets |
| [docs/RELIABILITY.md](docs/RELIABILITY.md) | Monitoring, alerting, incident response |
| [docs/SECURITY.md](docs/SECURITY.md) | Auth, trust boundaries, threat model |
| [docs/PLANS.md](docs/PLANS.md) | Roadmap overview — points to exec-plans/ |

## Quick Start

```bash
git clone {repo_url} && cd {project_name}
{install_command}
{dev_command}
{test_command}
```

## How Work Gets Done

1. Read [CLAUDE.md](CLAUDE.md) for rules and patterns
2. Read [WORKFLOW.md](WORKFLOW.md) for issue routing
3. Pick a **Todo** issue from Linear
4. Follow WORKFLOW.md state routing to implement, test, PR, merge
5. Pick next issue

See [docs/design-docs/core-beliefs.md](docs/design-docs/core-beliefs.md) for guiding principles.

## Working Agreements

- **Testing:** {framework} — `{test_command}` — tests in `{test_dir}/`
- **Naming:** {convention}
- **Commits:** `{ISSUE-ID}: brief description`
- **Dependencies:** Locked in `{lockfile}`. Add with `{add_command}`.
- **One task at a time.** Finish and merge before starting next.

## Architecture Layers

```
Types -> Config -> Repo -> Service -> Runtime -> UI
```

Dependencies flow forward only. Cross-cutting concerns enter through Providers.
See [ARCHITECTURE.md](ARCHITECTURE.md) for full details.
