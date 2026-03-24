# BUILD_PLAN Specification

Build Plan — phases of work from day 1 to launch.

## Required Sections

1. **Overview** (1 paragraph)
   - Total timeline
   - Key milestones
   - Definition of "done"

2. **Phase Breakdown** (typically 3-5 phases)
   - **Phase name** & timeline
   - What ships at end of phase
   - What gets built
   - Who builds it (if team exists)
   - Validation step before moving to next phase

3. **Dependencies & Blockers** (list)
   - What must be done first?
   - What could block progress?
   - Mitigation for each blocker

4. **Risks** (3-5 risks)
   - What could go wrong?
   - How likely? (high/medium/low)
   - Impact if it happens?
   - Mitigation plan

5. **Success Criteria per Phase** (measurable)
   - How do we know phase 1 is done?
   - Not "implement auth" but "auth is working, 3 test users can login and out"

6. **Resource Needs** (brief)
   - Team composition needed
   - Time commitment per person
   - Tools or services to procure

## Quality Criteria

- ✅ Each phase ships something real
- ✅ Vertical slices over horizontal layers (feature works end-to-end)
- ✅ Risks are specific, not generic ("tech debt" is not a risk)
- ✅ Someone could start phase 1 tomorrow
- ✅ Phases are sequential with clear hand-offs
- ✅ "Done" is defined for each phase

## Common Pitfalls

- ❌ Phases that don't ship anything
- ❌ Blocker list without mitigation
- ❌ Timeline that assumes everything goes perfectly
- ❌ Risks that are opinions not actual risks
- ❌ "Technical debt" as phase (do work properly first time)
- ❌ Assuming phase 1 takes 2 weeks when it might take 3
