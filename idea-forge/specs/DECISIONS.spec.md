# DECISIONS Specification

Decision Document — why the product is shaped the way it is.

## Required Sections

1. **Origin** (1 paragraph)
   - Where did the idea come from?
   - What problem does it solve?
   - How did we land on this specific direction?

2. **Direction Decision** (1-2 paragraphs)
   - What were the alternatives explored?
   - Why did we pick this direction?
   - What were we rejecting (and why)?

3. **Review Insights** (1-2 paragraphs)
   - What was the review verdict?
   - Key feedback
   - How did it shape the idea?

4. **Research Decisions** (1-2 paragraphs if applicable)
   - What did market research reveal?
   - Did we pivot based on research?
   - Competitors that influenced scope

5. **Feature Decisions** (per major feature)
   - **Feature**: X
   - **Why it's in MVP**: {reason}
   - **Why not Y instead**: {alternative rejected and why}

6. **Tech Stack Decisions** (per major choice)
   - **Choice**: React for frontend
   - **Why**: Matches user's existing skills in JavaScript, large ecosystem, fast to iterate
   - **Alternative rejected**: Angular — heavier, steeper learning curve
   - **When we might revisit**: If performance becomes critical or hiring becomes a blocker

7. **Phase Sequencing Rationale**
   - **Phase 1**: Why this before that?
   - **Phase 2**: What unblocks this?
   - Why not parallel?

## Quality Criteria

- ✅ Written for someone joining 6 months from now
- ✅ Every major decision has an alternative considered
- ✅ Trade-offs are explicit, not hidden
- ✅ Decisions link to constraints and research
- ✅ No post-hoc justification ("we're so glad we picked X" with no reasoning)
- ✅ Honest about uncertain bets

## Common Pitfalls

- ❌ "We picked X because it's industry standard" (not a reason)
- ❌ Decisions without alternatives
- ❌ Treating decisions as immutable (they're not)
- ❌ Vague ("we wanted it simple" — what does simple mean?)
- ❌ Forgetting to document why something was *not* chosen
