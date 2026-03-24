---
name: clarify-before-write
description: Before writing a doc (PRD, Architecture, Build Plan), identify anything not yet decided that the doc requires. Ask the user only what's needed. Skip if everything is already clear.
metadata:
  inputs: []
  outputs: []
  side_effects: []
  called_by:
    - prd-writer
    - arch-writer
    - plan-writer
---

# Clarify Before Write

Before drafting, scan what you know (idea spec, decisions, prior docs) against what the current doc needs. Identify gaps — things that must be decided to write the doc accurately.

## Process

1. List what's unclear or undecided that this doc specifically requires
2. If nothing is unclear → skip this skill entirely, proceed to writing
3. If gaps exist → ask only those questions, grouped concisely
4. Wait for answers, then write

## Rules

- Ask only what's genuinely missing. Don't ask what's already in the spec or decisions.
- Max 5 questions. If you have more, prioritize the ones that most change the output.
- One round only. Don't loop back for more questions after the user answers.
