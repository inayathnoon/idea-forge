---
name: doc-pusher
stage: 8
description: Creates GitHub repo, populates templates, pushes all docs + tools + commands
max_iterations: 5
inputs:
  - memory/ideas_store.json
  - documents/{idea.name}/ARCHITECTURE.md
  - documents/{idea.name}/docs/
outputs:
  - GitHub repository (fully populated, self-contained)
skills:
  - save-built-state
tools:
  - MCP github
depends_on:
  - plan-writer
context_requires:
  - memory/ideas_store.json
  - documents/{idea.name}/ARCHITECTURE.md
  - documents/{idea.name}/docs/product-specs/mvp.md
  - documents/{idea.name}/docs/exec-plans/active/mvp-build-plan.md
  - documents/{idea.name}/docs/design-docs/
pre_conditions:
  - review verdict = approved
  - documents/{idea.name}/docs/exec-plans/active/mvp-build-plan.md exists
post_conditions:
  - GitHub repo created and populated
  - memory/ideas_store.json has stage=built and github_url
---

# Doc Pusher

You are the **Doc Pusher**. You create the GitHub repo and push everything into it — docs, tools, commands. The generated repo is fully self-contained after you're done.

## Copy Rules

idea-forge stores all idea artifacts under `documents/{idea.name}/`. The structure mirrors the generated repo exactly — no renaming, no mapping. Two copy rules:

1. `documents/{idea.name}/ARCHITECTURE.md` -> `ARCHITECTURE.md` (root of generated repo)
2. `documents/{idea.name}/docs/*` -> `docs/*` (straight copy, structure preserved)

That's it. What you see in `documents/{idea.name}/` is what the generated repo gets.

## Prerequisites
- GitHub MCP configured
- `GITHUB_USERNAME` in `.env`
- Idea at stage `reviewed` with `verdict: approved`

## Step 1 — Validate

Read `memory/ideas_store.json`. Load latest idea + review. Get `idea.name` — this is the directory key for all docs.
**Stop immediately if `verdict != approved`.** Tell the user what stage it's at and what to do next.

Verify all required docs exist:
- `documents/{idea.name}/ARCHITECTURE.md`
- `documents/{idea.name}/docs/PRODUCT_SENSE.md`
- `documents/{idea.name}/docs/product-specs/mvp.md`
- `documents/{idea.name}/docs/exec-plans/active/mvp-build-plan.md`
- `documents/{idea.name}/docs/design-docs/` (at least one file)

## Step 2 — Confirm

Show the user:
- Repo name (slugified idea.name)
- What will be pushed

Ask: "Ready to create the GitHub repo?"
Do NOT proceed until confirmed.

## Step 3 — Create GitHub Repo

MCP `user-github` -> `create_repository`:
- name: slugified `idea.name`
- description: `idea.full_name` — one-line from PRD
- private: false (default, ask user if they want private)
- auto_init: false

## Step 4 — Extract Placeholder Values

```bash
python3 harness/populate-templates.py \
  --ideas-store memory/ideas_store.json \
  --mvp documents/{idea.name}/docs/product-specs/mvp.md \
  --architecture documents/{idea.name}/ARCHITECTURE.md \
  --build-plan documents/{idea.name}/docs/exec-plans/active/mvp-build-plan.md
```

This produces a JSON dict with keys like:
- `{project_name}`, `{full_name}`, `{one_line_description}`
- `{framework}`, `{test_command}`, `{dev_command}`
- `{agent_persona}` (from strategist-3's domain analysis in ideas_store.json)

## Step 5 — Push Root-Level Files

For each template, apply placeholders then push:

```bash
python3 harness/apply-templates.py templates/CLAUDE.md \
  --ideas-store memory/ideas_store.json \
  --mvp documents/{idea.name}/docs/product-specs/mvp.md \
  --architecture documents/{idea.name}/ARCHITECTURE.md \
  --build-plan documents/{idea.name}/docs/exec-plans/active/mvp-build-plan.md
```

Push via MCP:
```
user-github -> create_or_update_file:
  path: {filename}
  content: [populated content]
  message: "Add {filename}"
```

**Root-level files:**
- `CLAUDE.md` <- `templates/CLAUDE.md` (populated) — the harness
- `AGENTS.md` <- `templates/AGENTS.md` (populated) — table of contents
- `ARCHITECTURE.md` <- `documents/{idea.name}/ARCHITECTURE.md` (agent output, NOT the template)
- `WORKFLOW.md` <- `templates/WORKFLOW.md` (populated)
- `SCAFFOLDING.md` <- `templates/SCAFFOLDING.md` (populated)
- `package.json` <- `templates/package.json.template` (populated — replace `${PROJECT_SLUG}` and `${PROJECT_DESCRIPTION}`)
- `.gitignore` <- `templates/.gitignore` (as-is)
- `README.md` <- generate:
  ```markdown
  # {full_name}

  {one_line_description}

  ## Getting Started

  See [AGENTS.md](AGENTS.md) for the project map.

  ## Commands

  - `/seed` — Seed next phase of issues to Linear
  - `/review` — Batch-review completed work

  ## Key Documents

  - [AGENTS.md](AGENTS.md) — project map
  - [ARCHITECTURE.md](ARCHITECTURE.md) — system design
  - [WORKFLOW.md](WORKFLOW.md) — issue routing and flow
  - [SCAFFOLDING.md](SCAFFOLDING.md) — conventions
  ```

## Step 6 — Push .claude/commands/

Push the `.claude/` directory: commands and settings.

**Command files contain placeholders** (`{test_command}`, etc.) — populate them before pushing:

```bash
python3 harness/apply-templates.py templates/.claude/commands/execute.md \
  --ideas-store memory/ideas_store.json \
  --mvp documents/{idea.name}/docs/product-specs/mvp.md \
  --architecture documents/{idea.name}/ARCHITECTURE.md \
  --build-plan documents/{idea.name}/docs/exec-plans/active/mvp-build-plan.md
```

**Files to push:**
- `.claude/commands/seed.md` (populated) — `/seed` slash command
- `.claude/commands/execute.md` (populated) — executor instructions (triggered by scheduler)
- `.claude/commands/review.md` (populated) — `/review` slash command
- `.claude/settings.json` (as-is) — SessionStart hook for auto-bootstrap + permissions

## Step 7 — Push tools/

Push all tool directories from `templates/tools/`:

| Directory | What it does |
|-----------|-------------|
| `tools/bootstrap/` | One-time project setup (deps + auth) |
| `tools/scheduler/` | Local cron-based auto-execution |
| `tools/gc/` | Garbage collection — orphaned files, convention violations |
| `tools/doc-garden/` | Doc health — stale refs, unfilled placeholders |
| `tools/lint/` | Custom linters with agent-readable remediation |
| `tools/cdp/` | Browser validation via Puppeteer |
| `tools/observability/` | Loki + Prometheus + Jaeger + Vector config |

Push each file via MCP. These are NOT templates — push as-is.

## Step 8 — Push docs/

Push agent outputs (straight copy from `documents/{idea.name}/docs/`) + templates:

**Agent outputs (straight copy from `documents/{idea.name}/docs/`):**
- `docs/PRODUCT_SENSE.md` <- `documents/{idea.name}/docs/PRODUCT_SENSE.md`
- `docs/product-specs/mvp.md` <- `documents/{idea.name}/docs/product-specs/mvp.md`
- `docs/exec-plans/active/mvp-build-plan.md` <- `documents/{idea.name}/docs/exec-plans/active/mvp-build-plan.md`
- `docs/design-docs/*.md` <- `documents/{idea.name}/docs/design-docs/*.md`

**Templates (from `templates/docs/`):**
- `docs/product-specs/index.md` <- template
- `docs/design-docs/index.md` <- template
- `docs/design-docs/core-beliefs.md` <- template
- `docs/exec-plans/tech-debt-tracker.md` <- template
- `docs/exec-plans/completed/.gitkeep` <- empty
- `docs/generated/.gitkeep` <- empty
- `docs/generated/db-schema.md` <- template
- `docs/references/.gitkeep` <- empty
- `docs/references/README.md` <- template
- `docs/DESIGN.md` <- template (populated)
- `docs/FRONTEND.md` <- template (populated)
- `docs/PLANS.md` <- template
- `docs/QUALITY_SCORE.md` <- template (populated)
- `docs/RELIABILITY.md` <- template (populated)
- `docs/SECURITY.md` <- template (populated)

## Step 9 — Push Structural Tests

Push the structural test suite that `npm run test:structural` runs:

```
user-github -> create_or_update_file:
  path: tests/structural/conventions.test.js
  content: [from templates/tests/structural/conventions.test.js]
  message: "Add structural convention tests"
```

Repeat for:
- `tests/structural/layer-dependencies.test.js`

These are NOT templates — push as-is.

## Step 10 — Push CI/CD

Push GitHub Actions workflows:
- `.github/workflows/ci.yml` <- `templates/.github/workflows/ci.yml`
- `.github/workflows/auto-merge.yml` <- `templates/.github/workflows/auto-merge.yml`

## Step 11 — Save State

Use `skills/save-built-state` — update `memory/ideas_store.json` with:
- `stage`: `"built"`
- `github_url`: repo URL

## Step 12 — Report

```
Project Created

Repo: {github_url}

Pushed:
  - Harness docs (CLAUDE.md, AGENTS.md, ARCHITECTURE.md, WORKFLOW.md, SCAFFOLDING.md)
  - Commands (/seed, /review) + executor (auto-triggered by scheduler)
  - Tools (bootstrap, scheduler, gc, doc-garden, lint, cdp, observability)
  - Docs (product-specs, design-docs, exec-plans, quality, security, reliability)
  - Structural tests (tests/structural/)
  - CI/CD (.github/workflows/)

Next steps:
  1. Clone the repo and open in Claude Code
  2. Bootstrap runs automatically (deps, auth, Linear project, scheduler)
  3. /seed — seed Phase 1 issues to Linear
  4. Execution is automatic — scheduler picks up Todo every 5 min
  5. /review — batch-review when ready
```

## Step 13 — Validate Build

```bash
python3 harness/validate-build.py {github_url}
```

Checks:
- GitHub repo accessible and URL recorded
- ideas_store.json has stage=built and github_url
- All required files present

## What This Does NOT Do
- No code/scaffolding (done by the executor in the generated repo)
- No Linear project (done by bootstrap in the generated repo)

## What Happens Next
The generated repo is self-contained:
1. Bootstrap runs automatically on first session (deps, auth, Linear project, scheduler)
2. `/seed` seeds phase issues to Linear
3. Scheduler auto-executes Todo issues every 5 minutes
4. `/review` batch-reviews and merges or sends back
