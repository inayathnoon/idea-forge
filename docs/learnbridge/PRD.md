# PRD: LearnBridge — App-First Learning Companion

## Overview

LearnBridge is a web app that teaches CBSE 5th grade algebra to children (ages 10–11) studying alone after school. It delivers illustrated step-by-step walkthroughs and adaptive quizzes. When a child genuinely exhausts every retry path — not just takes a while, but fails every level — the app alerts the parent on WhatsApp with the specific topic and a coaching script they can use. The child gets structure and help. The parent stays in the loop without being physically present. No other product does this for Class 5.

---

## Problem

Children studying CBSE 5th grade algebra alone after school have nowhere to turn when they get stuck. The available tools either give them the answer (Photomath), assume self-motivation (Khan Academy), or require the parent to be present. Parents aren't disengaged — they're at work. When the child hits a wall and no one is available, the session ends unresolved. The concept goes unlearned. Over time: tuition dependency, eroded confidence, or learned helplessness with math.

---

## Target Users

**Primary — The child (10–11 years, CBSE Class 5)**
Studying independently on a browser, likely on a shared laptop or tablet at home after school. Motivated enough to sit down and try, but drops off when stuck for too long. Not looking for "more school" — needs a calm, clear, guided experience.

**Secondary — The working parent**
Has a WhatsApp phone. Wants to help but is unavailable during the child's study window. Willing to check in via WhatsApp. Not a math teacher — needs specific, actionable coaching prompts, not generic advice.

---

## Solution

LearnBridge works in two layers:

**Layer 1 (child):** Illustrated walkthroughs break each algebra subsection into steps. After each walkthrough, the child takes an adaptive quiz that starts at Level 3 (mid-difficulty). Correct answers advance toward completion. Wrong answers trigger a structured fallback — show easier levels, explain, retry. The child is never just told "wrong, try again" — every failure has a path.

**Layer 2 (parent):** When the child exhausts every retry path in a subsection (fails L3 retry OR fails L4 retry after the full fallback sequence), the app sends a WhatsApp message to the parent. The message names the exact topic the child is stuck on and includes a pre-written coaching guide: specific things to say and ask to help the child through that concept. Not generic encouragement — targeted guidance.

The differentiation is not the quiz engine or the content. It's the loop: detect a real wall → tell the right person → give them the words to help.

---

## MVP Features

### 1. Illustrated Step-by-Step Walkthroughs
**Priority:** High

Each CBSE 5th algebra subsection is broken into illustrated steps. Static images with transitions where helpful. No video. Each step introduces one concept piece; the child advances manually. Covers ~3–4 algebra chapters (the NCERT Class 5 math chapters that introduce algebraic thinking — patterns, unknowns, simple equations).

**Why in MVP:** This is the content delivery mechanism. Without it there's nothing to assess. Content quality here determines week-1 retention.

---

### 2. Adaptive Quiz Engine + Stuck Detection
**Priority:** High

4-level question system per subsection (1 = easiest, 4 = hardest). Every child starts at L3.

```
L3 pass → L4 → pass → STAGE COMPLETE
               fail → explain + retry L4 → pass → STAGE COMPLETE
                                            fail → NUDGE PARENT

L3 fail → show L1 → show L2 → explain L3 → retry L3
                                             pass → L4 → (same as above)
                                             fail → NUDGE PARENT
```

Stuck detection is embedded in level progression — not time-based. A child who is slow but progressing does not trigger an alert. A child who has failed every available path does.

**Why in MVP:** This is the core mechanic. It's what makes alerts meaningful rather than noisy.

---

### 3. Parent WhatsApp Alert
**Priority:** High

When the stuck condition is met, a WhatsApp Business API message is sent to the parent's registered number. Message includes:
- The child's name
- The exact subsection they're stuck on
- A link to the progress dashboard
- The coaching guide for that subsection (inline in the message or as a follow-up message)

Alert is fire-and-forget for MVP — no resolution state, no read receipt handling, no two-way loop back into the app.

**Why in MVP:** This is the product's core differentiator. If the alert doesn't work reliably, nothing else matters.

---

### 4. Subsection-Specific Coaching Prompts (via WhatsApp)
**Priority:** High

Each subsection in scope has a pre-written coaching guide. When the parent receives the alert, they get the guide for the exact subsection the child is stuck on — not a generic "try explaining with objects" tip.

Example: For "finding the value of X in a simple equation," the parent gets: "Ask them: if I gave you 3 apples and now you have 7, how many did you have before? That's the same as 3 + X = 7. Let them say the number out loud."

**Why in MVP:** Generic nudges don't help a non-teacher parent. Specificity is the value.

---

### 5. Progress Dashboard
**Priority:** Medium

Web dashboard on the same app showing:
- Sessions completed
- Quiz scores per topic over time
- Which subsections triggered a stuck alert

Accessible to both child and parent via the shared account login. Link to dashboard is included in every WhatsApp alert.

**Why in MVP:** Gives the parent context when they tap the WhatsApp link. Without it, the alert is a dead end.

---

### 6. Subscription + Auth
**Priority:** Medium

Monthly subscription. Single shared account per family — one login used by both child (for learning) and parent (for dashboard). Signup collects:
- Parent email
- Parent WhatsApp number (used for alerts)
- Child's name and class (for content targeting)

**Onboarding flow:**
1. Parent signs up on the web app, enters email + WhatsApp number + child's name
2. A WhatsApp verification message is sent immediately — parent replies to confirm the number
3. Child uses the same login on their device (no separate child account setup)
4. First session begins with a walkthrough of the first algebra topic

Pricing: ₹299–499/month. Free trial for first 7 days, no credit card required at signup.

**Why in MVP:** Revenue and the alert system both depend on capturing the parent's WhatsApp number at signup. This is load-bearing auth.

---

## Success Metrics

| Metric | What it tells us |
|---|---|
| % of sessions completed without parent alert | Are children progressing independently? |
| Quiz score improvement per topic across attempts | Is learning happening? |
| Parent WhatsApp response rate + response time | Is the alert useful? Are parents acting on it? |
| Week-4 subscription retention rate | Is the product worth paying for month 2? |
| Average sessions per week per child | Is the habit forming? |

---

## Out of Scope (v1)

| What | Why |
|---|---|
| Resolution state (parent marks resolved, child unlocks next stage) | Two-way loop adds complexity. Validate the alert is useful before adding state management. |
| AI-generated coaching prompts | Pre-written guides are sufficient and more reliable for MVP. AI adds hallucination risk at a sensitive age group. |
| Other subjects (science, English, etc.) | Scope is CBSE 5th algebra only. Nail one before expanding. |
| Other grades (Class 4, Class 6) | Same reason. Depth before breadth. |
| Native mobile app | Web-first. Mobile browser is sufficient for the child. WhatsApp handles the parent channel. |
| Separate parent account | Single shared account is simpler to build and sufficient for MVP. |
| Time-based stuck detection | Replaced by level-progression-based detection. More accurate, fewer false positives. |

---

## Constraints

- **Solo founder, no external budget.** Every feature must be buildable alone. No outsourcing, no team.
- **Web for child, WhatsApp for parent.** No native apps at launch.
- **CBSE 5th grade algebra only at launch.** ~3–4 chapters, finite and buildable.
- **WhatsApp Business API template approval is a pre-build dependency.** Must apply before writing code — approval can take days to weeks. This is not optional.
- **Free tier WhatsApp API limit: 1,000 conversations/month.** Sufficient for early users; upgrade when volume demands it.
