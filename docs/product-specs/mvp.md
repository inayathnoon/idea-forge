# MVP Spec: Veettukkar — Kerala's Home Services Marketplace

## Overview

Veettukkar is a Malayalam-first mobile app that connects Kerala homeowners with verified local daily-wage workers — coconut tree climbers, house painters, cleaners, cement construction workers, plumbers, and electricians. Homeowners post a job; nearby workers are notified and accept. Payment stays in cash, as it always has been. The app handles matching, trust, and reliability — the three things informal WhatsApp-based hiring cannot.

---

## Problem

Homeowners in Kerala struggle to find reliable daily-wage workers on short notice. The current method — asking neighbours, posting in WhatsApp groups, relying on personal contacts — is slow, inconsistent, and breaks down completely for homeowners new to an area or looking for a niche worker type (like a coconut tree climber).

Workers suffer the flip side: their income is capped by their personal network. A skilled plumber in Thrissur may have zero jobs on Tuesday and four conflicting enquiries on Wednesday — all because there is no mechanism that distributes demand evenly across available supply.

The specific pain:
- **For homeowners:** "I need a plumber tomorrow morning — my usual contact isn't picking up and I don't know who else to call."
- **For workers:** "I'm free today but nobody in my contact list needs work today."

This is not a technology gap — it's a discovery gap. The labour and the demand exist. What's missing is the routing layer.

---

## Target Users

**Primary — Homeowners in Kerala**
Families who own homes and regularly need occasional skilled/semi-skilled household work. This includes new homeowners who haven't built a local network yet, NRI families with homes maintained by relatives, and urban professionals with limited time to manage informal referral chains. They book via smartphone. They're used to WhatsApp but frustrated by its limits for this use case.

**Secondary — Daily-Wage Workers in Kerala**
Skilled and semi-skilled workers across 6 categories who work by the day or half-day for cash:
- Coconut tree climbers
- House painters
- Cleaners (household)
- Cement construction workers / masons
- Plumbers
- Electricians

This includes both local Keralite workers and the ~2.5 million interstate migrant workers (from Odisha, West Bengal, Bihar, Chhattisgarh) who form the backbone of Kerala's construction and home maintenance workforce. They use Android smartphones. Most are on WhatsApp daily. Malayalam or Hindi is their primary language.

---

## Solution

Veettukkar is a demand-driven job-request marketplace:

1. **Homeowner posts a job** — skill category, date, duration (half-day or full-day), location, and an optional note. Urgent jobs can be flagged.
2. **Nearby workers are notified** — workers within ~10km who have that skill and are free on that date get a push notification (and optionally a WhatsApp message as fallback).
3. **Worker accepts** — first accepted match is confirmed. Homeowner gets the worker's phone number.
4. **Job happens, cash is paid** — exactly as before. No in-app payment.
5. **Both sides rate each other** — ratings accumulate into a trust profile that is the primary differentiator over WhatsApp groups.

The "available today" toggle lets workers signal same-day availability, surfacing them first for urgent requests.

**Key differentiator vs. WhatsApp groups:** Persistent, portable ratings. A worker's 4.8-star rating from 47 jobs is visible to every homeowner on Veettukkar. It is the one thing a WhatsApp group can never replicate.

---

## MVP Features

### 1. Phone OTP Authentication (Priority: High)
Register and log in with phone number + SMS OTP only. No email, no password. One flow for both workers and homeowners — role is selected at registration.

*Why in MVP:* Workers on basic Android phones won't have email. Phone number is the universal identity in this demographic. Firebase Auth makes this trivial to implement.

### 2. Worker Profile (Priority: High)
Workers set up: name, phone (pre-filled from auth), skill categories (one or more of 6), location (district + area/neighbourhood), day rate and half-day rate, and an optional profile photo. Workers see their own aggregate rating after their first completed job.

A **Verified badge** is shown on profiles of workers who have completed Aadhaar verification (see feature 9). Newly onboarded unverified workers show "Registered on Veettukkar" as a lighter trust signal.

*Why in MVP:* This is the supply-side of the marketplace. Without worker profiles, there is nothing to match against.

### 3. Available Today Toggle (Priority: High)
Workers can flag themselves as available today with a single tap. This bumps them to the top of relevant match results for same-day and urgent job posts. The toggle auto-resets at midnight.

*Why in MVP:* Same-day requests are the highest-urgency use case. Workers who are available right now should be surface-ranked above workers who are available next week. This is a direct response to the strategist review's urgency dimension.

### 4. Job Posting by Homeowner (Priority: High)
Homeowner posts: skill category (dropdown of 6), date, duration (half-day / full-day), location (GPS pin or typed area name), and an optional short description (e.g., "need to paint one bedroom, walls only"). Optional "Urgent" toggle for same-day/next-day needs.

*Why in MVP:* This is the demand-side trigger. The entire matching flow starts here.

### 5. Nearby Worker Matching (Priority: High)
When a job is posted, workers within ~10km matching the skill and date are identified. Ranking order: (1) verified workers with "available today" flag, (2) verified workers, (3) unverified workers — each group sorted by rating descending, then distance ascending.

Workers receive a push notification with job summary. They can view the homeowner's posting and accept or decline.

*Why in MVP:* This is the core matching engine. Without this, the app is just two separate listing pages.

### 6. Job Notification & Accept/Decline (Priority: High)
Workers receive push notifications for jobs matching their skill and proximity. Notification includes: skill requested, date, duration, rough location (neighbourhood, not exact address), and rate (homeowner's expected rate if provided). Worker taps to view full details and accept or decline.

On acceptance, the homeowner receives the worker's name, rating, and phone number. The job is marked Confirmed. Other notified workers no longer see the job as open.

*Why in MVP:* Real-time notification and accept flow is the live beating heart of the product. Without it, the app is passive.

### 7. Post-Job Ratings (Priority: High)
After the job date passes, both sides are prompted to rate. Homeowner rates worker (1–5 stars + optional short comment, max 140 chars). Worker rates homeowner (1–5 stars, no public comment in v1). Ratings are visible on the rated party's profile.

A job is only considered complete (and rating-eligible) once the date has passed and either party submits a rating or 48 hours elapse.

*Why in MVP:* Ratings are the entire trust moat. They are the primary reason to use Veettukkar over a WhatsApp group. Every completed job that doesn't generate a rating is a missed trust-building opportunity. This ships in v1 or the product has no long-term network effect.

### 8. Malayalam-First UI (Priority: High)
All UI text defaults to Malayalam. Worker-facing screens also support Hindi (for migrant workers). English toggle available. Language preference is saved to profile.

*Why in MVP:* Worker adoption lives or dies on this. A daily-wage migrant mason in Ernakulam who can't read English won't install an English-only app. Malayalam support is not a localisation afterthought — it is a first-class launch requirement.

### 9. Aadhaar-Based Worker Verification (Priority: High)
Workers can optionally complete Aadhaar verification via DigiLocker or a basic Aadhaar OTP flow. Verified workers get a "Verified" badge on their profile, ranked higher in search, and are trusted more by homeowners.

Verification is not mandatory for workers to join or accept jobs in v1. It is incentivised (better ranking, homeowner trust) rather than gated. This avoids blocking supply before the network has density.

*Why in MVP:* Research surfaced that homeowner trust — especially for migrant workers — is the single biggest adoption barrier. Visible Aadhaar verification converts a nameless "migrant worker" into a person with a verified identity. This is not optional.

### 10. Job History (Priority: Medium)
Both homeowners and workers can see their past jobs — dates, skill categories, ratings received. For workers, this also shows total jobs completed and overall rating trajectory.

*Why in MVP:* Workers need to see their track record to feel invested in the platform. Homeowners need to see their booking history to trust it with repeat use. Without history, the app feels ephemeral.

### 11. WhatsApp Notification Fallback (Priority: Medium)
For workers who don't reliably open push notifications, job alerts are also sent as WhatsApp messages (via WhatsApp Business API or Twilio). Message includes job summary with a deep link to accept. This bridges the gap for migrant workers who use WhatsApp far more actively than app notifications.

*Why in MVP:* Research showed that blue-collar workers in India respond far more reliably to WhatsApp than to push notifications. Fill rate depends on workers seeing and responding to job notifications. A WhatsApp fallback doubles notification reach at minimal cost.

---

## Success Metrics

| Metric | Definition | Target (Day 90) |
|--------|-----------|-----------------|
| Job fill rate | % of posted jobs accepted within 24h | ≥ 70% |
| Worker jobs/month | Avg completed jobs per active worker per month | ≥ 6 |
| Homeowner repeat rate | % of homeowners who post a 2nd job within 30 days | ≥ 40% |
| Day-30 retention | % of registered users (both types) active on day 30 | ≥ 35% |
| Rating completion | % of completed jobs where homeowner submits rating | ≥ 60% |
| Worker verification | % of active workers who complete Aadhaar verification | ≥ 50% |

---

## Out of Scope (v1)

| What | Why Deferred |
|------|-------------|
| In-app payments / digital wage transfer | Adds KYC, tax compliance, and UPI integration complexity. Cash model is familiar and trusted. Revisit post-PMF. |
| Worker subscription model or recurring bookings | Predictability is valuable but adds scheduling complexity. v1 is one-time job requests only. |
| Multi-district expansion beyond Ernakulam | Cold-start requires density. Launch in one district, prove fill rate, then expand. |
| Job category expansion (gardeners, cooks, etc.) | Six categories are sufficient to validate the model. Don't dilute supply before density is proven. |
| Background check beyond Aadhaar | More thorough background checks (police verification, etc.) add time and cost. Aadhaar is sufficient for v1 trust signal. |
| Worker rating of homeowners (public) | Worker-to-homeowner ratings are recorded but not publicly visible in v1. Added in v2 after trust in the system is established. |
| AI-based matching or dynamic pricing | Manual matching by proximity + rating is sufficient for MVP scale. |
| iOS app | Android-only for MVP. Kerala's daily-wage worker demographic is almost entirely Android. |

---

## Constraints

- **Solo founder with AI-agent-assisted build.** No team, no external budget.
- **Kerala-only MVP** — single state, single language (Malayalam primary, Hindi secondary), single geography.
- **Android-only** — workers use Android; homeowners likely also predominantly Android in Kerala. iOS added post-PMF.
- **Cash payment model preserved** — no payment processing in v1.
- **Workers may use low-end Android phones** — app must be lightweight (target < 15MB APK), function well on 3G/4G, and not require >2GB RAM.
- **No team for moderation** — dispute resolution in v1 is minimal (flag job/worker, manual review by founder). Scales only after team exists.
