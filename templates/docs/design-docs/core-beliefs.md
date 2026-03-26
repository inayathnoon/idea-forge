# Core Beliefs

Principles and working philosophy that guide this project. These are foundational — they override local preferences.

## Agent-First Principles (Harness Engineering)

- **Humans steer, agents execute.** Humans define intent, design environments, and build feedback loops. Agents write the code.
- **The repo is the system of record.** If it's not in the repo, it doesn't exist. No tribal knowledge, no external-only docs.
- **Give agents a map, not a manual.** AGENTS.md is a short table of contents (~100 lines). Deeper context lives in docs/ with progressive disclosure.
- **Agent legibility over human aesthetics.** Code doesn't need to match human style preferences. It needs to be correct, testable, and legible to the next agent run.
- **Enforce boundaries, allow autonomy within.** Strict architectural layers and dependency directions are enforced mechanically. Within those boundaries, agents have freedom in how solutions are expressed.
- **Errors are feedback, not failures.** When the agent struggles, the fix is: what capability is missing? Make it legible and enforceable.

## Execution Principles

- **Docs are the source of truth.** If the code and docs disagree, fix the code.
- **One task at a time.** Pick one issue, finish it, merge it, then pick the next.
- **Tests are not optional.** Every implementation task has a paired test requirement.
- **Corrections are cheap, waiting is expensive.** Ship fast, fix forward. Test flakes get follow-up runs, not blocking gates.
- **Entropy is inevitable.** Agent-generated code drifts. Golden principles + recurring cleanup tasks keep the codebase coherent.

## Quality Principles

- **Validate at boundaries, trust internally.** Parse data shapes at system boundaries (API inputs, external data). Trust typed internal code.
- **Prefer boring technology.** Composable, stable, well-documented tools are easier for agents to model. "Boring" is a feature.
- **Reimplement over wrapping.** Sometimes it's cheaper to build a small, well-tested internal version than to fight opaque upstream behavior.
- **Pay down tech debt continuously.** Small, frequent cleanup beats painful quarterly refactors.

## Adding a belief

Only add new core beliefs if they're truly foundational — these guide all major decisions. Minor guidelines go in SCAFFOLDING.md or domain-specific docs.
