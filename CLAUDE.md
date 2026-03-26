# IdeaForge — Project Architecture

## Architecture: Command → Agents → Skills

```
.claude/commands/  → Slash commands (/new-idea)
agents/            → Agent personas (idea-capturer-1, idea-explorer-2, strategist-3, researcher-4, prd-writer-5, arch-writer-6, plan-writer-7, build-orchestrator-8, symphony-executor-9, project-manager)
skills/            → Reusable capabilities agents use (elaborate, ask-questions, etc.)
```

Flow: **Command** invokes **Agents** in sequence → Agents use **Skills**

## What This Project Does
IdeaForge turns raw ideas into structured docs (PRD, Architecture, Build Plan, Decisions), creates a GitHub repo with harness-engineered docs, seeds Linear with tasks, and executes them autonomously via the Symphony pattern. Claude IS the agent.

## Commands

| Command | How to run | What it does |
|---|---|---|
| new-idea | `/new-idea` | Full pipeline: idea → planner → review → prd → architect → build-plan |
| existing-idea | `/existing-idea` | Resume an idea at stage 4+ (skips stages 1–3) |
| pause-play | `/pause-play` | PAUSE: snapshot session state. PLAY: resume from last snapshot |
| advance | `/advance` | Run the next agent in the pipeline — no prompts, no confirmations |
| pick-another | `/pick-another` | Show all 10 directions, mark built ones, recommend what to build next |

## Agents

| Agent | Path | Role |
|---|---|---|
| Idea Capturer | agents/idea-capturer-1.md | Captures and structures the raw idea |
| Idea Explorer | agents/idea-explorer-2.md | Explores directions, picks top 3, selects closest |
| Strategist | agents/strategist-3.md | Stress-tests the idea across 4 dimensions |
| Researcher | agents/researcher-4.md | Writes docs/{idea.name}/RESEARCH.md (competitors, market, validation) |
| PRD Writer | agents/prd-writer-5.md | Writes docs/{idea.name}/PRD.md |
| Arch Writer | agents/arch-writer-6.md | Writes docs/{idea.name}/ARCHITECTURE.md |
| Plan Writer | agents/plan-writer-7.md | Writes docs/{idea.name}/BUILD_PLAN.md |
| Build Orchestrator | agents/build-orchestrator-8.md | Creates GitHub repo, pushes harness docs, seeds Linear |
| Symphony Executor | agents/symphony-executor-9.md | Picks up Linear issues one by one, implements, tests, PRs, merges |
| Project Manager | agents/project-manager.md | Captures key decisions incrementally after each stage |

## Pipeline Flow
```
/new-idea
  → idea-capturer-1 → project-manager
  → idea-explorer-2 → project-manager
  → strategist-3 → project-manager
  → [gate: user approves]
  → researcher-4 → prd-writer-5 → arch-writer-6 → plan-writer-7
  → project-manager (final)
  → build-orchestrator-8 (GitHub repo + harness docs + Linear project)
  → symphony-executor-9 (picks up Linear issues, implements, merges — loops until done)
```

## Memory
- `memory/ideas_store.json` — All ideas + stages
- `idea_storage/{slug}-{timestamp}/` — Planner explorations
- `docs/{idea.name}/` — All docs for that idea (DECISIONS, RESEARCH, PRD, ARCHITECTURE, BUILD_PLAN)
- Stage flow: `structured` → `reviewed` → `built` → `executing`

## Harness Engineering

Generated repos follow OpenAI's harness engineering pattern:
- `CLAUDE.md` — harness: rules, patterns, commands (pushed to every repo)
- `AGENTS.md` — short table of contents (~100 lines), not an encyclopedia
- `docs/` — structured knowledge base with progressive disclosure
- `docs/design-docs/core-beliefs.md` — golden principles that prevent drift
- Architecture layers enforced mechanically (Types → Config → Repo → Service → Runtime → UI)

## Symphony Execution

After build-orchestrator creates the repo and seeds Linear:
- Symphony Executor (`agents/symphony-executor-9.md`) takes over
- Picks up Todo issues from Linear, implements them end-to-end
- Creates PRs, handles feedback, merges, loops until queue is empty
- Escalates blockers by marking issues as Rework

## When adding new components
1. **Skill** — Add `skills/<name>/SKILL.md`
2. **Agent** — Add `agents/<name>.md`, reference skills
3. **Command** — Add `commands/<name>` + `.claude/commands/<name>.md` for slash command
