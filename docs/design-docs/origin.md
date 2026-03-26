# Decision: Origin — Veettukkar

## Origin

The idea started as a practical observation about the informal labour market in Kerala: homeowners regularly need skilled daily-wage workers — coconut tree climbers, painters, cleaners, cement construction workers, plumbers, electricians — but have no reliable way to find them beyond personal contacts and word-of-mouth. Workers, meanwhile, are limited to the jobs their personal network feeds them, leaving earning potential largely to chance.

The raw idea: build an app that connects these two sides. Kerala-specific because the labour types, language (Malayalam), and cash-based wage conventions are very regional.

## What We Decided to Build

A lightweight mobile app — initially called **Veettukkar** (Malayalam for "house helpers") — that acts as a hyperlocal marketplace for daily-wage home services in Kerala.

- **What we decided:** Build a job-posting + worker-matching app, Malayalam-first, with phone OTP auth. No payment processing in v1; cash model preserved.
- **Alternatives considered:** (1) WhatsApp-based matching bot — rejected because it requires a central number and doesn't scale; (2) Aggregator listing site — rejected because it's passive, not real-time; (3) Full gig-economy with in-app payments — deferred to v2 because it adds KYC, tax, and trust complexity before users are established.
- **Why this path:** The simplest intervention that breaks the word-of-mouth bottleneck. Workers get more job visibility; homeowners get faster, more reliable access. Cash payment remains familiar to both parties.
- **Trade-off accepted:** No monetisation at launch. Revenue model (subscription or commission) is a v2 decision.

## Key Decision: Target Worker Categories

- **What we decided:** Six specific categories — coconut tree climbers, house painters, cleaners, cement construction workers, plumbers, electricians.
- **Why:** These are the most commonly hired daily-wage workers for Kerala homes. Each has distinct skill signals and safety considerations (especially coconut climbing).
- **Trade-off:** Excluding gardeners, cooks, domestic helpers — to keep MVP scope tight.

## Key Decision: Malayalam-First UI

- **What we decided:** Malayalam as default UI language, English as secondary.
- **Why:** Most daily-wage workers in Kerala are more comfortable in Malayalam. English-only would kill worker adoption.
- **Trade-off:** Adds localisation work upfront.

## Key Decision: Phone OTP Authentication (No Email)

- **What we decided:** Register and log in with phone number + SMS OTP only.
- **Why:** Workers use basic Android phones. Email-based auth creates friction and dropout. Every worker in Kerala has a mobile number.
- **Trade-off:** Account recovery is phone-tied; if someone loses their number, recovery is manual.

## Open Questions

- [ ] Should homeowners be able to browse worker profiles directly (supply-side listing) or only post jobs and wait for matches (demand-side)?
- [ ] Do workers set their availability proactively, or just respond to job notifications?
- [ ] What verification (if any) before a worker can accept paid jobs? Aadhaar-linked, self-declared, or community-vouched?
- [ ] Monetisation model for v2: platform commission per job, worker subscription, or homeowner subscription?
