# Decision: Review Insights — Veettukkar

## Review Verdict: APPROVED (7.75/10)

| Dimension | Score | Key Finding |
|-----------|-------|-------------|
| Clarity | 8/10 | Problem is specific and concrete; cold-start strategy is the gap |
| Market Viability | 7/10 | Real market, real gap; monetisation deferred but valid |
| Feasibility | 9/10 | Standard mobile stack; Malayalam localisation is the main added complexity |
| User Validation | 7/10 | Problem is real but validation is assumption-driven, not tested |

## What the Review Surfaced

### Strengths That Confirmed the Direction
- Kerala's informal daily-wage labour market is large and under-served by existing apps (Urban Company focuses on premium metro services).
- Cash payment preservation removes the biggest trust and regulatory hurdle from v1.
- Phone OTP is exactly right for this audience — workers on basic Android phones won't have email.
- Ratings as the key differentiator over WhatsApp groups is sharp and real.

### Weaknesses That Changed the Design

**Cold-Start Strategy Added:**
The review flagged that supply-side cold-start is unaddressed. Decision: the build plan will include a geographic pilot scope (one district) and an in-person worker onboarding phase before the app launches publicly.

**"Available Today" Toggle Added to MVP:**
Merged from Direction 6 — lets workers signal same-day availability, addressing urgency use cases within the Job-Request Marketplace model without a product-mode change.

**"Urgent" Tag for Job Posts Added:**
Homeowners can mark a job as urgent (same-day need). This surfaces urgency intent to workers and helps them prioritise notifications.

### Risks Named by Review

| Risk | Mitigation |
|------|------------|
| Cold-start: no workers at launch | In-person outreach to ~30 workers in one neighbourhood before app launch |
| WhatsApp groups already exist | Ratings/trust must be made the visible value prop — put rating counts on every worker card |
| Sparse rural areas won't have worker density | Start in Ernakulam or Thiruvananthapuram (urban density) for pilot |
| Workers may not respond to notifications | "Available today" toggle creates a lighter commitment signal |

## Key Decisions Made During Review

### Decision: District-First Pilot
- **What we decided:** Launch exclusively in one Kerala district (Ernakulam preferred — high urban density + tech literacy).
- **Why:** Worker density per skill category determines fill rate. Thin geographic coverage = low fill rate = bad homeowner experience.
- **Trade-off:** Slower initial growth. Acceptable — better a working product in one district than a broken one statewide.

### Decision: Ratings Are the Moat
- **What we decided:** Ratings are not just a feature — they are the primary reason to use Veettukkar over WhatsApp groups.
- **Why:** WhatsApp groups can coordinate a job. They cannot record, persist, or surface worker reputation.
- **Trade-off:** Ratings only accrue after jobs — takes time. We'll show "Verified by Veettukkar" on newly onboarded workers to bridge the trust gap early.
