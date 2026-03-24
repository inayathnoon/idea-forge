# {project_name}

> {one-line description}

## Documentation Map

| Directory | Contents |
|-----------|----------|
| [ARCHITECTURE.md](ARCHITECTURE.md) | System design, components, data flow, tech stack |
| [docs/product-specs/](docs/product-specs/) | What we're building — features and product requirements |
| [docs/design-docs/](docs/design-docs/) | Why we chose each architecture/design decision |
| [docs/exec-plans/](docs/exec-plans/) | How we're building it — phases, milestones, tech debt |
| [docs/generated/](docs/generated/) | Auto-generated docs (schema, API references, etc.) |
| [docs/references/](docs/references/) | LLM context files for external tools |

## Key Docs for Your Role

**Building features?** Start with [ARCHITECTURE.md](ARCHITECTURE.md) + [docs/product-specs/](docs/product-specs/)

**Making decisions?** See [docs/design-docs/](docs/design-docs/) + [docs/DESIGN.md](docs/DESIGN.md) / [docs/FRONTEND.md](docs/FRONTEND.md) / etc.

**DevOps/SRE?** Read [docs/RELIABILITY.md](docs/RELIABILITY.md) + [docs/SECURITY.md](docs/SECURITY.md)

## Workflow & Setup

This project uses **[WORKFLOW.md](WORKFLOW.md)** — agent-driven issue execution with status-based routing (Todo → In Progress → Merging → Done).

**Quick setup:**
```bash
git clone {repo_url} && cd {project_name}
{install_command}
{dev_command}          # Start dev server
{test_command}         # Run tests
```

## Working Agreements

- **Testing:** {framework} — run with `{test_command}`. Tests in `{test_dir}/`.
- **Naming:** {convention}
- **Commits:** `{ISSUE-ID}: brief description`
- **Dependencies:** Locked in `{lockfile}`. Add with `{add_command}`.

See [SCAFFOLDING.md](SCAFFOLDING.md) for detailed project structure and conventions.

## Core Philosophy

- Docs are truth. Code follows.
- Every decision is documented.
- One task at a time. Finish before starting next.
- Tests aren't optional.
- Plain English first.

See [docs/design-docs/core-beliefs.md](docs/design-docs/core-beliefs.md) for full principles.
