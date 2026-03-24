# Build Plan: LearnBridge — App-First Learning Companion

## Phase 1 — Core Loop (Vertical Slice)

**Goal:** One complete user journey working end-to-end. Child opens a walkthrough, takes the quiz, exhausts all retry paths, and the parent receives a WhatsApp alert with a coaching guide. Nothing more.

### What's in Phase 1

**Setup**
- [ ] Create Next.js 14 project (App Router, TypeScript)
- [ ] Create Supabase project, connect to Next.js
- [ ] Deploy skeleton to Vercel (set up CI from GitHub)

**Database**
- [ ] Write and run DB schema migration (families, subsections, questions, sessions, question_attempts, alerts_sent)
- [ ] Write seed script + JSON seed file for 1 complete subsection (walkthrough steps, L1–L4 questions, coaching guide)

**Auth + Signup**
- [ ] Signup form: parent email, password, WhatsApp number, child name
- [ ] Supabase Auth integration (email/password)
- [ ] WhatsApp number verification: send verification message via Meta Cloud API on signup
- [ ] `/api/whatsapp/webhook`: receive parent's reply, mark `whatsapp_verified = true`

**Walkthrough Viewer**
- [ ] `/learn/[subsectionSlug]` route
- [ ] Step-by-step viewer: fetch walkthrough steps from Supabase, advance manually
- [ ] "Start Quiz" button at end of walkthrough

**Quiz Engine**
- [ ] Client-side 4-level state machine (all 6 progression paths from PRD)
- [ ] Per-answer persistence to `question_attempts` via Supabase
- [ ] Explanation display on wrong answer
- [ ] Session row created on start, outcome written on complete or stuck

**WhatsApp Alert**
- [ ] `/api/alerts/send`: look up coaching guide for subsection, send Meta Cloud API template message
- [ ] Write to `alerts_sent` on send
- [ ] Alert includes: child name, subsection name, coaching guide, dashboard link

### Definition of Done
Phase 1 is complete when: a parent receives a WhatsApp message naming the exact subsection their child is stuck on, with the coaching guide inline, triggered by the child exhausting all retry paths in the quiz — running live on a Vercel staging URL.

### Estimated Scope
**Medium.** The quiz state machine has real complexity (6 paths, 4 levels). The WhatsApp webhook verification flow has moving parts. Content for 1 subsection is finite and manageable. Overall: 2–4 focused solo-founder weeks depending on Meta approval timing.

---

## Phase 2 — Full Content + Navigation + Dashboard

**Goal:** The full CBSE 5th algebra curriculum is accessible. Parents have a useful dashboard. The product is ready for real users.

- [ ] Seed all subsections: 3–4 chapters × all subsections per chapter (walkthroughs + L1–L4 questions + coaching guides)
- [ ] Topic and subsection navigation: `/learn` index showing chapters and subsections, progress indicators
- [ ] Session completion tracking: mark subsections as complete, show progress to child
- [ ] Progress dashboard (`/dashboard`): sessions completed, quiz scores per subsection over time, alert history
- [ ] Login page and protected routes (redirect unauthenticated users)
- [ ] Basic responsive layout for child (tablet-friendly, since children likely use shared devices)

### Definition of Done
Phase 2 is complete when: a child can navigate the full algebra curriculum, complete subsections, and a parent can open the dashboard link from any WhatsApp alert and see useful progress information.

---

## Phase 3+ — Future

Not building in MVP. Revisit after Phase 2 is validated with real users.

- **Subscription + payment** — Razorpay integration, monthly subscription, 7-day free trial
- **Two-way WhatsApp loop** — parent marks issue resolved, child unlocks next stage
- **AI coaching prompts** — dynamic coaching guides instead of pre-written
- **CMS for content** — in-app content editing without re-seeding
- **Other subjects / grades** — expand beyond CBSE 5th algebra
- **Native mobile app** — iOS/Android for child
- **Admin dashboard** — usage analytics, alert monitoring
- **SMS fallback** — if WhatsApp delivery fails

---

## Milestones

| Milestone | Deliverable | Phase |
|---|---|---|
| M1 | DB schema live, seed script runs for 1 subsection | 1 |
| M2 | Auth working, WhatsApp number verified on signup | 1 |
| M3 | Walkthrough viewer renders content from DB | 1 |
| M4 | Quiz engine: all 4 levels + all 6 paths working | 1 |
| M5 | **Core loop end-to-end: stuck child → parent WhatsApp alert** | 1 |
| M6 | Full content seeded (all subsections, questions, coaching guides) | 2 |
| M7 | Topic/subsection navigation + completion tracking | 2 |
| M8 | Progress dashboard live | 2 |

---

## Dependencies

Must be in place before writing code:

- [ ] **Meta Business Manager account** — required to access WhatsApp Cloud API
- [ ] **WhatsApp Business phone number** — dedicated number registered with Meta
- [ ] **WhatsApp message templates submitted for approval** — two templates needed:
  1. Number verification: "Reply YES to confirm your WhatsApp for LearnBridge alerts"
  2. Stuck alert: "Hi [parent name], [child name] is stuck on [subsection]. Here's how to help: [coaching guide]. See progress: [link]"
  Submit these before writing any code. Approval can take 1–3 weeks and blocks M2 and M5.
- [ ] **1 complete subsection of content ready** — walkthrough steps (with image placeholders acceptable for Phase 1), L1–L4 questions, coaching guide. Required before M3.
- [ ] **Supabase project created** — free tier is sufficient for Phase 1
- [ ] **Vercel account connected to GitHub repo** — deploy early, even with a blank page

---

## Risks

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| WhatsApp template approval delayed by Meta | High | High | Submit templates before writing any code. If Meta delays past 2 weeks, temporarily use Twilio for WhatsApp (same API surface, swappable) to unblock development. |
| Content production bottleneck | Medium | High | Walkthroughs + questions + coaching guides is significant writing work. Start with 1 subsection for Phase 1 (just enough to prove the loop). Build remaining content in parallel during Phase 1 development. |
| Meta Cloud API webhook setup complexity | Medium | Medium | Meta requires a publicly accessible HTTPS URL to verify the webhook. Use ngrok for local development. Deploy to Vercel early (even a blank page) so the webhook URL is live for integration testing. |
| Quiz state machine edge cases | Low | Medium | The 6-path state machine has subtlety. Write plain unit tests for the progression logic (no UI) before building the React component. This catches path bugs before they hide behind UI state. |
| Walkthrough illustration quality | Low | Medium | "Illustrated" content sets a quality bar. If illustrations aren't ready, use placeholder images in Phase 1 — the quiz engine and alert system can be built and validated independently of illustration quality. |

---

## First Task

**Submit WhatsApp message templates to Meta for approval.**

Do this before opening a code editor. Go to Meta Business Manager → WhatsApp → Message Templates. Submit both templates (number verification + stuck alert). This is the longest lead-time item in the entire project and it cannot be parallelised with anything that depends on it.

Once submitted, while waiting for approval:

**First build task:** Create the Next.js project, create the Supabase project, write the DB schema migration (`families`, `subsections`, `questions`, `sessions`, `question_attempts`, `alerts_sent`), and write the JSON seed file for 1 subsection.
