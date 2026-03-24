# IdeaForge

> Turn raw ideas into GitHub repos + Linear projects — using Claude as the agent. No API keys for LLMs.

## Architecture: Command → Agents → Skills

```
.claude/commands/  → Slash commands (/new-idea, /advance, etc.)
agents/            → Agent personas (idea-capturer-1 through build-orchestrator-8, project-manager)
skills/            → Reusable capabilities agents use (elaborate, ask-questions, etc.)
```

Flow: **Command** invokes **Agents** in sequence → Agents use **Skills**

## How It Works

Claude IS the agent. Invoke the pipeline via slash commands:

```
/new-idea       → Full pipeline: capture → explore → review → research → PRD → architecture → build plan → GitHub repo
/existing-idea  → Resume an idea at stage 4+ (skips stages 1-3)
/advance        → Run the next agent — no prompts, no confirmations
/pause-play     → Snapshot or resume session state
/pick-another   → Show all 10 explored directions, pick next to build
/status         → Check pipeline progress
```

## Setup

```bash
# 1. Clone
git clone https://github.com/YOUR_USERNAME/idea-forge
cd idea-forge

# 2. MCP: Connect GitHub + Linear in Claude Code settings
# See .mcp.json for configuration

# 3. Open in Claude Code
claude .
```

## Pipeline Flow

```
/new-idea
  → idea-capturer-1 → project-manager
  → idea-explorer-2 → project-manager
  → strategist-3 → project-manager
  → [gate: user approves]
  → researcher-4 → prd-writer-5 → arch-writer-6 → plan-writer-7
  → project-manager (final)
  → build-orchestrator-8
```

## Project Structure

```
idea-forge/
├── .claude/commands/       # Slash commands (/new-idea, /advance, etc.)
├── agents/                 # Agent personas (numbered 1-8 + project-manager)
├── skills/                 # Reusable SKILL.md folders
├── specs/                  # Output specs (PRD, Architecture, Build Plan, Decisions)
├── templates/              # Doc templates for generated repos
├── harness/                # Validation scripts and pipeline metadata
├── memory/
│   └── ideas_store.json    # All ideas + stages
├── idea_storage/           # Planner explorations per idea
├── docs/{idea}/            # Generated docs (PRD, Architecture, Build Plan, etc.)
└── CLAUDE.md               # Claude Code project rules
```

## Adding New Components

1. **Skill** — Add `skills/<name>/SKILL.md`
2. **Agent** — Add `agents/<name>.md`, reference skills
3. **Command** — Add `.claude/commands/<name>.md` for slash command

## No LLM API Key Needed

Claude Code runs on its own subscription. IdeaForge uses Claude as the reasoning layer — skills handle memory I/O, GitHub MCP handles repo creation. Clean separation.
