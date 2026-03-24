# Architecture: LearnBridge — App-First Learning Companion

## System Overview

```
                        ┌─────────────────────────────┐
                        │        Vercel (Next.js)      │
                        │                              │
  Child (browser) ──────│  /learn   Quiz + Walkthrough │
  Parent (browser) ─────│  /dashboard  Progress view  │
                        │  /api/alerts/send            │────► Meta WhatsApp Cloud API
                        │  /api/whatsapp/webhook  ◄───│──── WhatsApp inbound
                        └────────────┬────────────────┘
                                     │
                                     ▼
                        ┌─────────────────────────────┐
                        │          Supabase            │
                        │  Auth │ PostgreSQL │ Storage  │
                        └─────────────────────────────┘
```

One Next.js app on Vercel covers both the child's learning interface and the parent's dashboard. API routes handle WhatsApp webhooks. Supabase is the single data store — auth, content, session state, and alerts. Subscription and payment are post-MVP.

---

## Components

### 1. Child Learning Interface
**Responsibility:** Deliver walkthroughs and run the adaptive quiz.
**Routes:** `/learn`, `/learn/[topicSlug]/[subsectionSlug]`
**Tech:** React (Next.js App Router), client-side quiz state machine
- Fetches walkthrough steps and questions from Supabase on load
- Runs 4-level progression logic entirely in client state
- Persists each answer to `question_attempts` in Supabase as it happens
- When stuck condition is met, calls `/api/alerts/send` — does not handle WhatsApp directly

### 2. Parent Dashboard
**Responsibility:** Show progress, scores, and alert history to the parent.
**Routes:** `/dashboard`
**Tech:** Next.js Server Components (data fetched server-side)
- Read-only view of sessions, scores, and which subsections triggered alerts
- Accessible with the same family login as the child's account
- Direct link in every WhatsApp alert lands here

### 3. Auth
**Responsibility:** Family account registration and login.
**Tech:** Supabase Auth (email/password)
- Single shared account per family — one Supabase user, one set of credentials
- Signup flow collects: parent email, WhatsApp number, child name
- WhatsApp number verified at signup via `/api/whatsapp/webhook`
- No OAuth for v1 — email/password only

### 4. WhatsApp Alert Service
**Responsibility:** Send stuck alerts and coaching guides to the parent via WhatsApp.
**Route:** `POST /api/alerts/send`, `POST /api/whatsapp/webhook`
**Tech:** Next.js API Route → Meta Cloud API (HTTP)
- `/api/alerts/send`: receives stuck trigger from client, looks up coaching guide for subsection, formats and sends WhatsApp template message
- `/api/whatsapp/webhook`: receives incoming WhatsApp messages (used only for number verification during signup — parent replies to confirm)
- Alert is fire-and-forget for v1: sends message, logs to `alerts_sent`, no resolution state

### 5. Content Store
**Responsibility:** Store walkthroughs, quiz questions, and coaching guides.
**Tech:** Supabase PostgreSQL, seeded from JSON files in `/content/` in the repo
- All content lives in the DB at runtime
- JSON files in the repo are the source of truth for v1 — edited there, re-seeded to deploy changes
- No CMS UI for v1

---

## Data Model

```sql
families
  id, email, whatsapp_number, whatsapp_verified (bool),
  child_name, created_at

topics
  id, title, slug, order

subsections
  id, topic_id, title, slug, order,
  walkthrough_steps (jsonb),   -- array of {image_url, caption}
  coaching_guide (text)        -- pre-written parent coaching script

questions
  id, subsection_id, level (1|2|3|4),
  content (text), options (jsonb), correct_answer (text),
  explanation (text)           -- shown after wrong answer

sessions
  id, family_id, subsection_id,
  started_at, completed_at,
  outcome (completed|stuck|abandoned)

question_attempts
  id, session_id, question_id, level_attempted,
  answer_given, correct (bool), attempted_at

alerts_sent
  id, family_id, session_id, subsection_id,
  sent_at, meta_message_id
```

---

## Data Flow

### Child takes a quiz
```
1. Child opens subsection → Next.js fetches subsection + questions from Supabase
2. Quiz starts → session row created in Supabase (outcome: null)
3. Child answers question → question_attempt row written immediately
4. Client evaluates progression logic:
     - Correct at L4 → session.outcome = completed → done
     - Fails all paths → session.outcome = stuck → POST /api/alerts/send
5. /api/alerts/send:
     - Fetches coaching_guide for subsection
     - Sends WhatsApp template message via Meta Cloud API
     - Writes to alerts_sent
```

### Parent receives alert and checks dashboard
```
1. WhatsApp message arrives on parent's phone
   "Aarav is stuck on: Simple Equations. Here's how to help: [coaching guide]
    See his progress: https://learnbridge.app/dashboard"
2. Parent taps link → lands on /dashboard (login if needed)
3. Dashboard shows: session history, stuck subsections, quiz score trend
```

### Family signup + WhatsApp verification
```
1. Parent fills signup form (email, password, WhatsApp number, child name)
2. Supabase Auth creates user → families row created
3. POST /api/whatsapp/verify → sends "Reply YES to confirm your WhatsApp" message
4. Parent replies YES → Meta webhook → POST /api/whatsapp/webhook
5. families.whatsapp_verified = true → alerts are now live
```

---

## Tech Stack

| Layer | Choice | Rationale |
|---|---|---|
| Language | TypeScript | Specified. Type safety across client + API routes. |
| Framework | Next.js 14 (App Router) | React + API routes in one Vercel deploy. No separate backend needed. |
| Database | PostgreSQL via Supabase | Specified. Handles auth, content, and session state. |
| Auth | Supabase Auth | Built into Supabase. Email/password sufficient for v1. |
| Hosting | Vercel | Specified. Zero-config Next.js deploy. |
| WhatsApp | Meta Cloud API (direct) | No third-party markup. Free within conversation windows. |
| Content | Supabase DB + JSON seed files | Finite content, no CMS needed for v1. |

---

## Key Design Decisions

**1. Next.js over bare React**
- Chosen: Next.js 14 App Router
- Why: API routes on Vercel replace a separate backend. WhatsApp webhooks and alert sending live in `/api/` — one deploy, no extra infra.
- Trade-off: Slightly more framework overhead than bare React. Not a real concern at this scale.

**2. Meta Cloud API (direct) over Twilio / 360dialog**
- Chosen: Meta's WhatsApp Cloud API
- Why: Free API calls within the 24-hour conversation window. No third-party cost layer. For a solo founder at <1,000 users, this is the right call.
- Trade-off: Longer setup. Must register a dedicated phone number through Meta Business Manager and get template messages approved. Start this before writing code — approval takes 1–3 weeks.

**3. Client-side quiz logic with per-answer DB persistence**
- Chosen: 4-level progression state runs in React; each answer is written to Supabase immediately
- Why: No round-trip required per answer (quiz feels instant). Persistence means a browser refresh doesn't reset progress. Stuck condition triggers an API call only when all paths are exhausted.
- Trade-off: Progression logic lives in client code. Fine for v1 — it's not sensitive logic.

**4. Content in Supabase, seeded from JSON**
- Chosen: Questions, walkthroughs, and coaching guides stored in DB; JSON files in `/content/` are source of truth
- Why: DB enables query patterns (e.g. fetch L3 questions for subsection). JSON seed files make content editable in the repo without a CMS.
- Trade-off: Content deploys require a re-seed script. Acceptable for ~20–30 subsections.

**5. Single Supabase user per family**
- Chosen: One auth account shared by child and parent
- Why: PRD decision. Dramatically simplifies onboarding — parent signs up, child just uses the same login. No child account setup flow.
- Trade-off: No per-user event attribution. The parent and child share a session identity. Acceptable for v1.

---

## What We're NOT Designing (v1)

- **Two-way WhatsApp loop** — parent can't reply to mark the child's stuck state as resolved. One-way alerts only.
- **CMS for content editing** — JSON files in the repo, re-seed to update. No admin UI.
- **Separate child and parent accounts** — single shared family account.
- **Real-time session sync** — parent dashboard is not live-updating. Supabase Realtime not used in v1.
- **AI-generated coaching prompts** — all coaching guides are pre-written per subsection.
- **SMS fallback** — WhatsApp only. No SMS if WhatsApp fails.
- **Offline support** — browser + internet required.
- **Multi-device conflict handling** — if child opens quiz on two devices, no conflict resolution.
- **Admin dashboard** — no internal tooling for v1. Query Supabase directly.
- **Subscription and payment** — no Razorpay integration at MVP. Access is open. Add payment gating post-MVP once the core loop is validated.
