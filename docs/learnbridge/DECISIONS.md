# Decisions: LearnBridge — App-First Learning Companion

## Origin

Started as a specific, personal observation: a solo founder noticed that CBSE 5th grade children studying algebra alone after school hit walls and had no real-time support. Parents weren't disengaged — they were at work. The gap wasn't motivation, it was availability.

The raw idea was: "detect when a child is stuck, then tell the parent." This shaped into a two-sided product — a child learning app + parent alert system — with a focus on coaching prompts, not just notifications.

---

## Why This and Not Something Else

10 directions were explored. Three were shortlisted:

1. **B2C Subscription with iOS parent app** — closest to the original vision, cleanest monetization
2. **WhatsApp-Native Parent Alerts** — no iOS install, higher reach in India ← **chosen**
3. **AI Tutor (No Parent Loop)** — AI helps child directly, eliminates parent dependency

**Direction 3 (WhatsApp) was chosen** over Direction 1 (B2C with iOS) for three reasons the founder stated: simpler MVP to build, easier to test early on, and easier for parents to adopt since they already have WhatsApp — no install required.

---

## Key Decisions

### Decision: Parent notification channel — WhatsApp over iOS
- **What we decided:** Use WhatsApp Business API to send stuck alerts and coaching prompts to parents instead of a native iOS app
- **Alternatives considered:** Native iOS app with push notifications (APNs)
- **Why this path:** Three reasons from the founder: (1) easier MVP — no iOS app to build at launch, (2) easier early testing — fewer moving parts to validate the core loop, (3) easier adoption — parents already have WhatsApp, zero install friction.
- **Trade-off accepted:** Less control over the parent UX than a native app. WhatsApp Business API has message template restrictions.

### Decision: Primary user is the child, secondary is the parent
- **What we decided:** The child-facing web app is the core product. The parent channel (WhatsApp) is a support layer.
- **Alternatives considered:** Making the parent dashboard the primary product (parenting confidence angle)
- **Why this path:** Value is delivered when the child learns. The parent is a support mechanism, not the primary learner. Building for the child first keeps the product focused.
- **Trade-off accepted:** The child web app must work well standalone — the WhatsApp integration can't carry the product if the child-facing experience is weak.

### Decision: Illustrated walkthroughs over animated video
- **What we decided:** Content is illustrated step-by-step walkthroughs (static, with transitions where helpful) — no animated video production for MVP.
- **Alternatives considered:** Animated explainer videos (outsourced or AI-generated); text-only walkthroughs
- **Why this path:** Founder's intent was always illustrated content, not full video. Illustrations are buildable solo, don't require a production pipeline, and can include lightweight transitions for clarity without becoming a video project.
- **Trade-off accepted:** Less engaging than polished animation. Acceptable for MVP — validate the detection + alert loop first, improve content quality later.

---

## Review Insights

Scores (Clarity / Feasibility / Differentiation / Completeness): **8 / 6 / 7 / 6**

**What the review surfaced:**
- Feasibility risk was animated video content — resolved: switched to illustrated walkthroughs, a solo-buildable format.
- Differentiation lives entirely in the stuck-detection + parent coaching loop. The content delivery alone (walkthroughs + quizzes) is commodity. The alert system must work well.
- Completeness gaps remain: detection thresholds (time-on-task duration, wrong answer count) are undefined; onboarding flow (how parent links WhatsApp to child account) is unspecified; post-alert resolution state is missing.

**Verdict:** Approved with conditions. Core loop is solid. Open questions deferred to PRD stage.

---

### Decision: Single shared account for child and parent
- **What we decided:** One account, one login — shared between child and parent. Signup collects parent email + parent WhatsApp number. The child uses it on their device for learning. The parent uses the same login to access the progress dashboard (via the WhatsApp link or directly). No separate parent account, no separate auth.
- **Alternatives considered:** Separate parent account with its own login; token/magic-link access for parents
- **Why this path:** Simplest possible architecture. One account means one auth flow, one session model, no linking logic between accounts. Intentional trade-off for MVP speed.
- **Trade-off accepted:** Child can also access the parent dashboard view. Acceptable at this stage — the audience is a family unit, not adversarial users.

### Decision: WhatsApp alert includes a link to the progress dashboard
- **What we decided:** The WhatsApp stuck alert includes a URL to the progress dashboard. Parent taps it, logs in with the shared account credentials, sees the child's sessions, quiz scores, and what triggered the alert.
- **Alternatives considered:** Text-only alert; separate parent app
- **Why this path:** Gives the parent useful context without any extra platform. The dashboard is part of the same web app — no separate build needed.
- **Trade-off accepted:** Parent must remember the account password to use the link. Acceptable friction for MVP.

### Decision: WhatsApp Business API free tier for MVP
- **What we decided:** Use the free tier of WhatsApp Business API (Meta gives 1000 free conversations/month). No cost for early testing and initial users.
- **Alternatives considered:** Paid WhatsApp API from day one; SMS fallback
- **Why this path:** Free tier is sufficient to validate the alert loop with early users. Upgrade to paid when volume demands it.
- **Trade-off accepted:** 1000 conversations/month cap. Acceptable for MVP scale.

---

### Decision: Adaptive quiz engine is the stuck-detection mechanism (replaces time-based detection)
- **What we decided:** Stuck detection is not time-based. It's embedded in the adaptive quiz level progression. Parent is nudged only when the child exhausts all retry paths within a subsection.
- **Alternatives considered:** Time-on-task threshold + consecutive wrong answer count (original spec)
- **Why this path:** More intentional than time-based detection. A child who is slow but progressing should not trigger an alert. A child who has genuinely hit a wall — failed at every level including retries — should. This model is accurate and avoids false positives.
- **Trade-off accepted:** More complex quiz state machine to implement. Worth it for detection accuracy.

**Full quiz path per subsection (4 levels, 1 = easiest):**
```
START at L3

L3 pass → L4 → pass → STAGE COMPLETE
               fail → explain + retry L4 → pass → STAGE COMPLETE
                                            fail → NUDGE PARENT

L3 fail → show L1 → show L2 → explain L3 → retry L3
                                             pass → L4 → pass → STAGE COMPLETE
                                                         fail → explain + retry L4 → pass → STAGE COMPLETE
                                                                                      fail → NUDGE PARENT
                                             fail → NUDGE PARENT
```

### Decision: Coaching prompt is a subsection-specific step-by-step guide
- **What we decided:** Each subsection has a pre-written coaching guide. When the child is stuck on a specific subsection, the parent receives the coaching guide for exactly that subsection via WhatsApp — not a generic tip.
- **Alternatives considered:** Generic "try explaining with objects" tips; AI-generated per-question prompts
- **Why this path:** Topic-specific guidance is far more useful to a non-teacher parent. A parent who knows what to say for "finding the value of X" is actually helpful. A generic nudge is not.
- **Trade-off accepted:** Coaching guides must be written for every subsection in MVP scope (~3–4 chapters, multiple subsections each). This is content work, but finite and doable solo.

### Decision: WhatsApp nudge is fire-and-forget for MVP
- **What we decided:** No resolution state. Once the nudge is sent, the app doesn't track whether the parent responded or the child resumed. The loop ends at the WhatsApp send.
- **Alternatives considered:** Resolution state (parent marks resolved, child app unlocks next stage)
- **Why this path:** Simpler to build. Enough for MVP — validate that the alert is useful before adding two-way state management.
- **Trade-off accepted:** No feedback loop from parent back into the app. Can't measure "did the parent coaching actually help?"  Add in v2.

---

## Architecture Decisions

### Decision: Next.js over bare React
- **What we decided:** Use Next.js 14 (App Router) as the framework, not Vite + React.
- **Alternatives considered:** Vite + React (frontend only) + separate Express/Fastify backend on Railway or Render
- **Why this path:** Next.js API routes on Vercel replace a dedicated backend entirely. WhatsApp webhooks, Razorpay webhooks, and the alert-sending endpoint all live in `/api/` in the same repo. One deploy, zero extra infra. Solo-founder-friendly.
- **Trade-off accepted:** Next.js adds more framework overhead than bare React. Not meaningful at this scale.

### Decision: Meta Cloud API (direct) over Twilio or 360dialog
- **What we decided:** Use Meta's WhatsApp Cloud API directly — no third-party aggregator.
- **Alternatives considered:** Twilio for WhatsApp (~$0.005/message + WhatsApp fees), 360dialog (popular in India), WATI
- **Why this path:** Meta Cloud API has no per-message cost within the 24-hour conversation window. At <1,000 users, the free tier covers all usage. Avoiding an aggregator layer eliminates one cost center and one dependency.
- **Trade-off accepted:** Longer setup. Requires Meta Business Manager account, phone number registration, and WhatsApp message template approval — which can take 1–3 weeks. Must be started before writing code. This is the most time-sensitive pre-build dependency in the project.

### Decision: Client-side quiz engine with per-answer Supabase persistence
- **What we decided:** The 4-level progression state machine runs entirely in React client state. Each answer is written to Supabase (`question_attempts`) as it happens.
- **Alternatives considered:** Server-side quiz state (API call per answer to determine next question); full server-side state machine
- **Why this path:** No round-trip required per answer — the quiz feels instant. Persistence on each answer means a browser refresh doesn't reset the child's progress mid-quiz.
- **Trade-off accepted:** Progression logic lives in client code rather than a server-authoritative source. Not a concern for v1.

### Decision: Content stored in Supabase, seeded from JSON files in the repo
- **What we decided:** Walkthroughs, quiz questions (L1–L4), and coaching guides live in Supabase tables. JSON files in `/content/` are the source of truth and are used to seed the database.
- **Alternatives considered:** Headless CMS (Contentful, Sanity); flat markdown files served at build time; hardcoded in React components
- **Why this path:** DB storage enables query patterns (e.g. fetch all L3 questions for a subsection). JSON seed files keep content editable in the repo without a CMS subscription or admin UI build.
- **Trade-off accepted:** Content updates require a re-seed script run. Acceptable for ~20–30 subsections at launch. A CMS is a v2 concern.

### Decision: Subscription and payment deferred to post-MVP
- **What we decided:** No payment integration in the MVP build. Access is open — anyone who signs up can use the product. Razorpay (India-standard for UPI/cards/subscriptions) is the planned choice for when payment is added.
- **Alternatives considered:** Including Razorpay in the initial build
- **Why this path:** Validate the core loop first (child learns, parent gets alerted, coaching is useful). Adding a paywall before validating the product creates friction that slows learning about whether the product works at all.
- **Trade-off accepted:** No revenue during MVP. Acceptable — the goal at this stage is validation, not monetisation.

---

## Build Plan Decisions

### Decision: Vertical slice first — one subsection end-to-end before full content
- **What we decided:** Phase 1 builds one complete subsection (walkthrough + quiz + alert) working end-to-end. Full curriculum content comes in Phase 2.
- **Alternatives considered:** Building all content first, then the tech; building the tech horizontally (all DB, then all UI, then alerts)
- **Why this path:** The core hypothesis is the alert loop — "child gets stuck → parent gets a useful prompt". That needs to be validated with real users before investing in full content production. A vertical slice tests the hypothesis with minimal build time.
- **Trade-off accepted:** Phase 1 is not launchable to the public (one subsection isn't a product). It's a validation tool.

### Decision: WhatsApp template submission is the first action — before any code
- **What we decided:** Meta template approval (1–3 weeks) is the longest-lead-time dependency. It must be submitted before writing any code.
- **Alternatives considered:** Using Twilio from the start (faster setup, same API surface)
- **Why this path:** The eventual plan is Meta Cloud API (free). Starting with Twilio to unblock development is listed as a fallback, not the plan. Submitting templates first avoids paying Twilio unnecessarily.
- **Trade-off accepted:** If Meta approval is slow, it delays M2 and M5 unless the Twilio fallback is activated.

---

## Open Questions

- [ ] **WhatsApp template approval** — Two templates needed (number verification + stuck alert). Have these been submitted to Meta?
- [ ] **WhatsApp number for alerts** — A dedicated phone number must be registered with Meta. Is this number acquired?
- [ ] **Coaching guide content** — Pre-written coaching guides required for every subsection. Is the Phase 1 subsection's guide written?
- [ ] **Illustrated walkthrough assets** — Static images per walkthrough step. Placeholder images are acceptable for Phase 1; final illustrations needed before Phase 2 launch.
