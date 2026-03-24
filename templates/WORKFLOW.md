---
# WORKFLOW.md Configuration
# This frontmatter is read by Claude Code harness to route issues and manage state.
#
# See bottom of file for instructions on how to fill these values.

tracker:
  kind: linear
  # Linear project identifier (e.g., "INO" for https://linear.app/team/INO)
  # AUTO-FILLED by build-orchestrator from Linear project created in Step 8
  project_key: {LINEAR_PROJECT_KEY}

  # Available issue statuses in your Linear project
  active_states:
    - Todo           # New work, not started
    - In Progress    # Actively being worked on
    - Merging        # PR created, waiting for review/merge
    - Rework         # Reviewer feedback received, needs fixes
  terminal_states:
    - Done           # Completed and merged
    - Cancelled      # Not doing this
    - Duplicate      # Already covered by another issue

workspace:
  # Where local clones are checked out for development
  root: ~/workspaces

hooks:
  # Auto-run after repo is cloned (install dependencies)
  # Intelligently detects framework from package.json / requirements.txt / go.mod
  after_create: "npm install || pip install -r requirements.txt || go mod download || true"

agent:
  # Max conversation turns before Claude Code requires user input
  max_turns: 20

---

# {project_name} — Workflow

> How Claude Code builds this project, issue by issue

## Setup

This file tells Claude Code how to work on issues in this project:
1. **Tracker**: Linear (your issue tracker)
2. **States**: Todo → In Progress → Merging → Done
3. **Rules**: Read docs first, follow conventions, test before merging

## How to use this file

When Claude Code picks up a Linear issue:
1. It reads this file's frontmatter (the YAML above)
2. It finds your current issue's state
3. It follows the section below that matches your state

**You don't need to read this whole file.** Just pick up an issue and follow the routing instructions.

### After build-orchestrator creates the Linear project

Update the frontmatter above:
- Replace `{LINEAR_PROJECT_KEY}` with your project key (e.g., "INO" if your project URL is linear.app/team/INO)
- Verify `active_states` and `terminal_states` match what you see in Linear
  - Open Linear → Settings → Project → Workflows to see your state names
  - Common: Todo, In Progress, In Review, Done (yours may vary)



# {{issue.identifier}}: {{issue.title}}

You are working on issue **{{issue.identifier}}** in a project built by IdeaForge.

## Your context

Read these files before doing anything:
- `AGENTS.md` — project map, conventions, and working agreements
- `docs/PRD.md` — what we're building and why
- `docs/ARCHITECTURE.md` — system design and tech stack
- `docs/BUILD_PLAN.md` — phases and milestones
- `SCAFFOLDING.md` — folder structure, naming, dependencies, testing conventions

## User context

The user is a **data scientist** — fluent in Python and SQL, understands logic and data pipelines, but is NOT a software engineer.

Rules for every interaction:
- **Define before you use.** Any software engineering term must be explained before being used.
- **Use data science analogies.** A backend = a Python script running on a server; a schema = table column definitions; a framework = a library like pandas; infrastructure = the compute environment.
- **Never present bare technical options.** Explain the concept, give options with plain descriptions, then ask.
- **One decision at a time.** Don't stack multiple choices.

## Status routing

Check the current issue state and follow the matching section below.

---

### When state = Todo

This is the first time this issue is being picked up.

**If SCAFFOLDING.md status shows "not yet complete":**
Go through scaffolding decisions one at a time with the user (folder structure, entry points, config, module conventions, file naming, dependencies, environment, testing). Write each decision to SCAFFOLDING.md as you go. Wait for user confirmation on each category before moving on.

**If SCAFFOLDING.md is complete but no project files exist yet:**
Read SCAFFOLDING.md completely. Create every file and folder described — folder structure with .gitkeep, config files, entry points with minimal content. Confirm each section with the user as you create it.

**If this is a normal implementation task:**
1. Check prerequisites — are blocking tasks complete? If not, stop and report the blocker.
2. Read the task description carefully.
3. Plan your approach — describe what you'll do in plain terms before writing code.
4. Move issue to **In Progress** when you start implementing.

---

### When state = In Progress

You are implementing. Follow these rules:

1. **Scope.** Only implement what the task describes. No scope creep.
2. **Conventions.** Follow SCAFFOLDING.md for naming, structure, and patterns.
3. **Architecture.** Follow ARCHITECTURE.md for component responsibilities.
4. **Tests.** Write tests alongside implementation (test file naming from SCAFFOLDING.md).
5. **Commit.** When done, commit with message: `{{issue.identifier}}: brief description`.

**Before marking complete, verify:**
- [ ] Feature works as described in the task
- [ ] Tests pass
- [ ] Code follows SCAFFOLDING.md conventions
- [ ] No regressions in existing functionality

When all checks pass:
- Push to a branch named `{{issue.identifier | slugify}}`
- Create a pull request
- Move issue to **Merging**
- Add a Linear comment summarizing what was implemented

---

### When state = Merging

The implementation is done and a PR exists. Your job is to get it merged.

1. **Check CI.** Are tests passing? If not, fix failures and push.
2. **Check PR feedback.** Treat all reviewer comments as blocking. Address each one.
3. **Validate against PRD.** Does this task satisfy the PRD requirements it's supposed to address?
4. **Validate against Architecture.** Are component responsibilities correct? No wrong-layer logic?

If everything passes:
- Merge the PR
- Move issue to **Done**
- Add a Linear comment: "Merged. Tests passing. PRD requirements met."

If tests fail or review has issues:
- Fix the problems, push, and stay in **Merging**

---

### When state = Rework

The task was sent back for changes. Read the Linear comments to understand what needs fixing.

1. Read all comments on this issue — find the specific feedback.
2. Address each piece of feedback.
3. Push fixes to the existing branch/PR.
4. Move back to **Merging** when addressed.

---

## Completion gates

Before any issue moves to Done, these must ALL be true:
- [ ] Implementation matches task description
- [ ] Tests pass locally
- [ ] PR merged (or committed to main if no PR workflow)
- [ ] Linear comment documents what was done

## Workpad

Use a single persistent Linear comment as your workpad — update it as you progress rather than creating multiple comments. This is your source of truth for progress on this issue.

## Escape hatch

If you hit a genuine blocker (missing credentials, broken dependency, unclear requirement):
1. Add a Linear comment describing the blocker precisely
2. Move issue to **Rework**
3. Stop — do not guess or work around auth/tool issues
