# IdeaForge Playbook

Persistent strategy memory: lessons learned, prompt tweaks that work, failure modes and mitigations.

## Lessons Learned

### What Works Well

1. **Stage 1 (Idea Capturer)**
   - Asking questions before structuring is critical — prevents assuming the idea
   - Definition of MVP and out-of-scope upfront prevents scope creep later
   - Success rate: Higher when user has concrete problem + specific users in mind

2. **Stage 2 (Idea Explorer)**
   - Generating 10 directions then filtering to 3 prevents local optima
   - User choice is critical — forcing a direction leads to friction later
   - Success rate: Higher when diverse angles explored (technical, business, UX)

3. **Stage 3 (Strategist)**
   - Stress-testing on 4 dimensions catches major flaws early
   - Gate decisions (approved/revise/reject) force clarity
   - Success rate: ~70% pass on first attempt, 25% revise and resubmit

4. **Stage 4 (Researcher)**
   - Market research prevents building in a vacuum
   - Competitor analysis informs scope cuts and feature choices
   - Success rate: High, mostly limited by web search limitations

5. **Stages 5-8 (Writers)**
   - Specs make output consistent and reviewable
   - Clarifying questions before writing prevents rewrites
   - Success rate: High when input specs are clear

### What Fails

1. **Vague problem statements** → Stage 1 struggles, request clarification upfront
2. **Missing target users** → Direction exploration becomes unfocused
3. **Scope creep** → Happens if MVP definition is unclear; catch at stage 1
4. **Insufficient research** → Gaps appear at stage 4; allocate time
5. **Architecture too complex** → Happens if PRD doesn't prioritize; enforce MVP first

## Prompt Tweaks That Work

### Effective Context Setting

- ✅ "This product is for solo founders" — grounds decisions
- ✅ "MVP means minimum viable, not feature-rich" — prevents over-scoping
- ✅ "Vertical slices over horizontal layers" — frames phasing correctly
- ✅ "Define before you use" — prevents SDE jargon confusion

### Effective Question Framing

- ✅ "What's the one thing this must do?" — clarifies priority
- ✅ "Who would pay for this?" — tests viability
- ✅ "What's the problem you solved?" — anchors to need
- ❌ "What are other features?" — leads to bloat

### Effective Output Formatting

- ✅ Specs with required sections force completeness
- ✅ Decision documents with alternatives prevent post-hoc justification
- ✅ Acceptance criteria in features prevent ambiguity
- ❌ "Nice to have" in PRD → Creeps into MVP

## Common Failure Modes

### "The Pivot"
**Symptom**: Stage 3 verdict is "revise", sent back to stage 1
**Root cause**: Problem statement wasn't concrete enough
**Mitigation**: Stage 1 agent asks deeper questions; verify with user before capturing

### "The Feature Creep"
**Symptom**: Stage 5 PRD has 15 MVP features
**Root cause**: MVP definition unclear or scope not enforced
**Mitigation**: PRD spec enforces "5-8 features max"; revisit with user if more proposed

### "The Architecture Surprise"
**Symptom**: Stage 6 discovers tech stack decisions from stage 5 don't support design
**Root cause**: PRD and architecture specs weren't aligned
**Mitigation**: Arch writer queries PRD for ambiguities before designing

### "The Research Gap"
**Symptom**: Stage 5 discovers competitors with same idea
**Root cause**: Stage 4 research was too shallow
**Mitigation**: Stage 4 allocates time to deep research; flag if < 3 competitors found

### "The Stalled Researcher"
**Symptom**: Agent 4 spins trying to find research
**Root cause**: Topic is too niche or too recent
**Mitigation**: Set stage 4 max_iterations to 5; fallback to "limited competitors" finding

## Maintenance

### Regular Tasks

- **After each idea completion**: Document lessons in this playbook
- **Monthly**: Review failure modes, update mitigations
- **Quarterly**: Audit agent prompts for effectiveness

### When to Update Playbook

- Failed idea reaches stage 7+ → Document root cause and mitigation
- Same failure mode happens twice → Strengthen prevention
- New prompt tweak significantly improves output quality → Document it
- Agent is regularly hitting iteration cap → Revise scope or agent logic

## Ideas in Progress

Track ideas that are in flight, their current stage, and any known issues.

## Success Metrics (by stage)

| Stage | Success Definition | Current Rate |
|-------|-------------------|--------------|
| 1 | Structured spec that user approves in ≤3 iterations | 90% |
| 2 | User chooses one of 3 directions without ambiguity | 95% |
| 3 | Verdict issued (approved/revise/reject) | 100% |
| 4 | Research findings inform scope/features | 80% |
| 5 | PRD written without major revision | 85% |
| 6 | Architecture justified all tech choices | 90% |
| 7 | Build plan is realistic (teams finish within timeline) | 70% |
| 8 | Repo created and docs pushed cleanly | 100% |

## Next Improvements

- [ ] Add automated playbook pruning (remove ideas >90 days old)
- [ ] Track stage-by-stage timing to improve estimates
- [ ] Create stage-specific troubleshooting guides
- [ ] Log prompt iterations that improve quality
