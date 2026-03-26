# Decision: Direction Selection — Veettukkar

## 10 Directions Explored

| # | Direction | Core Bet |
|---|-----------|----------|
| 1 | Hyperlocal Job Board | Supply-driven listing; homeowners browse and contact workers |
| 2 | Job-Request Marketplace ★ | Homeowners post jobs; nearby workers notified and accept |
| 3 | WhatsApp-Native Bot | Zero-install; bot routes requests to workers via WhatsApp |
| 4 | Cooperative Platform | Workers join co-ops; platform books through co-op admins |
| 5 | Subscription Crew | Homeowners subscribe for recurring hours of home help |
| 6 | Day-Labour Exchange | Workers toggle "available now"; homeowners see live board |
| 7 | Skill Certification + Profile | Workers earn micro-certifications; trust-score hiring |
| 8 | Community Referral Network | Vouches from homeowners become digital reputation |
| 9 | Agency-as-a-Platform | Platform as licensed labour agency; takes commission |
| 10 | Emergency Services Fast-Lane | Priority routing + premium rates for urgent jobs |

## Why Direction 2 — Job-Request Marketplace

- **What we decided:** Build a demand-driven marketplace. Homeowners post jobs; workers receive push notifications and accept.
- **Alternatives seriously considered:**
  - Direction 6 (Day-Labour Exchange): Strong on urgency, but requires workers to open the app daily to signal availability — a behaviour change that's hard to bootstrap.
  - Direction 10 (Emergency Fast-Lane): High willingness-to-pay but narrow TAM; hard to build daily-use habit on emergencies.
  - Direction 3 (WhatsApp Bot): Zero install friction but routing logic is opaque, ratings are impossible to implement, and it doesn't scale.
- **Why this path:** Direction 2 is the minimum viable intervention that breaks the word-of-mouth bottleneck without requiring behaviour change. Workers only need to respond to notifications, not actively maintain an "available" status. Homeowners post exactly when they need someone.
- **Trade-off accepted:** Workers who don't respond to notifications reduce fill rate. We'll mitigate with "available today" badge and notification nudges.

## Incorporated Hybrid: "Available Today" Toggle

Workers can mark themselves as available today. This surfaces them at the top of relevant matches for same-day or urgent requests — borrowing the urgency value of Direction 6 without requiring it as the primary interaction model.

## What This Direction Locks In

- App-based (not WhatsApp-bot) — enables ratings, history, profiles
- Demand-side posting is the primary flow (homeowner initiates)
- Cash payment preserved; platform handles only matching
- Six fixed skill categories for MVP (expandable later)
