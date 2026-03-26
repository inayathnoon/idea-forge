# Decision: MVP Scope — Veettukkar

## What's In and Why

The MVP scope was set to prove one thing: **can the platform reliably connect a homeowner with a nearby daily-wage worker in Ernakulam district?** Everything in Phase 1 serves that proof.

### What's In (Phase 1)

| Feature | Why It's In |
|---------|-------------|
| Phone OTP auth | Workers won't have email; this is the only viable auth model |
| Worker profile (6 categories) | Supply side of the marketplace; without it, nothing to match |
| Available Today toggle | Urgency signal; directly increases fill rate for same-day requests |
| Job posting by homeowner | Demand side; primary trigger for the entire flow |
| Geohash matching + notifications | Core value: makes the connection that WhatsApp groups can't |
| Accept / Decline flow | Closes the loop; homeowner gets worker contact |
| Post-job ratings | Trust moat; primary differentiator vs. informal referrals |
| Malayalam-first UI | Worker adoption; non-negotiable for semi-literate users |
| WhatsApp notification fallback | Fill rate insurance; blue-collar workers respond to WhatsApp more than push |
| Aadhaar verification | Trust signal for homeowners; required for meaningful adoption in this demographic |

### What's Deliberately Excluded from v1

| Excluded Feature | Why Excluded |
|-----------------|--------------|
| iOS app | ~95% of target demographic is Android |
| In-app payments | KYC + regulatory overhead; cash model works and is trusted |
| Multi-district | Cold-start must be solved in one district first |
| Job categories beyond 6 | Stay focused; validate model before expanding supply |
| Background checks beyond Aadhaar | Too slow and expensive for v1 scale |
| Worker-to-homeowner public ratings | Added in v2 after trust in the system is established |
| AI/ML matching | Proximity + rating ranking is sufficient; no complexity needed |
| Admin dashboard | Solo founder handles moderation manually in v1 |
| Subscription plans | Revenue model deferred to v2 |

## Geographic Scope

**Launch:** Ernakulam district only.

**Why Ernakulam:**
- Highest construction activity in Kerala (1,300+ RERA projects statewide concentrated here)
- Dense migrant worker population in areas like Aluva, Perumbavoor, Edapally
- Urban Company's only strong Kerala footprint — can undercut on worker-friendliness
- High digital literacy (Kochi metro)

**Expansion sequence (post-PMF):**
1. Ernakulam ✓
2. Thiruvananthapuram
3. Kozhikode
4. Thrissur
5. Remaining 10 districts

Each new district requires: 20+ verified workers per skill category before app opens to homeowners there.

## Cold-Start Strategy

The platform requires workers before homeowners (no supply = bad homeowner experience = churn). Before the app goes live publicly:

1. **In-person recruitment:** Visit 3–5 construction sites in Aluva/Perumbavoor with printed registration cards and WhatsApp onboarding flow
2. **Kudumbashree network:** Kerala's 300,000-member Kudumbashree women's self-help groups are connected to domestic and cleaning worker pools — reach out via district coordinators
3. **Hello Nariyal directory:** The Coconut Development Board's 1,924 registered climbers are a ready supply list; contact them directly
4. **Minimum threshold:** 30+ verified workers across all 6 categories before first homeowner onboarding begins
