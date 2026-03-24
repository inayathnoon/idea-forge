# Scaffolding — {project_name}

> Project structure, conventions, and how to work on this codebase

## Folder Structure

{folder_structure}

## File Naming Conventions

- **Components**: `{convention}`
- **Tests**: `{test_dir}`
- **Imports**: Relative from project root

See [ARCHITECTURE.md](ARCHITECTURE.md) for rationale.

## Entry Points

- **Development**: `{dev_command}`
- **Tests**: `{test_command}`
- **Build**: `{build_command}` (if applicable)

## Configuration Files

- **Dependencies**: `{lockfile}`
- **Environment**: `.env.local` (copy from `.env.example`)
- **Build/Runtime**: See [ARCHITECTURE.md](ARCHITECTURE.md) for tech stack

## Patterns & Conventions

{patterns}

## Working Agreements

This team follows these rules:
1. **One issue at a time** — finish the current task before picking up a new one
2. **Branch per issue** — create a branch named `{ISSUE-ID}-brief-name`
3. **Tests first** — write tests alongside implementation
4. **Commit message**: `{ISSUE-ID}: brief description`
5. **Dependency updates**: Use `{add_command}` to add, commit lockfile

## Common Tasks

**Start dev server:**
```bash
{dev_command}
```

**Run tests:**
```bash
{test_command}
```

**Add a dependency:**
```bash
{add_command} {package_name}
```

**Create a branch:**
```bash
git checkout -b {ISSUE-ID}-feature-name
```

## Design Rationale

This structure is organized around:
- **Linear issues drive work** — one issue = one focused task
- **WORKFLOW.md defines how to work** — read it to understand status routing (Todo → In Progress → Merging → Done)
- **Docs are truth** — keep ARCHITECTURE.md, PRODUCT_SENSE.md, and design-docs/ up-to-date as you build

See [WORKFLOW.md](WORKFLOW.md) and [AGENTS.md](AGENTS.md) for the full context.
