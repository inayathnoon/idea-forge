# Decision: Tech Choices — Veettukkar

## Summary

All major technology decisions for Veettukkar v1. Each decision includes what was chosen, what was seriously considered, and why.

---

## Decision: Firebase over Supabase

- **What we decided:** Firebase (Firestore + Cloud Functions + Auth + FCM + Storage) as the entire backend platform
- **Alternatives considered:** Supabase (PostgreSQL + Edge Functions + Realtime), custom Node.js + PostgreSQL on Railway/Fly.io
- **Why this path:** Firestore's real-time listeners are a native primitive — both homeowner and worker get live job status updates without polling. FCM is in the same ecosystem. Phone Auth is zero-config. Cloud Functions scale to zero — zero infra cost when idle. For a solo founder, "no server to manage" is load-bearing.
- **Trade-off accepted:** Firestore's NoSQL model requires denormalisation (e.g., `ratingAvg` stored redundantly on the user doc). Cannot do arbitrary SQL joins. Acceptable at v1 scale.

## Decision: React Native (Expo) over Flutter

- **What we decided:** React Native with Expo managed workflow, TypeScript
- **Alternatives considered:** Flutter (Dart), bare React Native (no Expo)
- **Why this path:** Firebase's React Native SDK is mature and well-tested. TypeScript across both app and Cloud Functions = one language for the full stack. Expo's OTA update capability means bug fixes don't require Play Store review. Solo founder benefit: familiar JS/TS ecosystem, fewer paradigm switches.
- **Trade-off accepted:** Flutter has marginally better performance on sub-1GB RAM devices. If this becomes a real issue at v2, Flutter migration is an option.

## Decision: Android-Only MVP

- **What we decided:** Android only. No iOS in v1.
- **Alternatives considered:** Cross-platform launch (both iOS and Android from day 1)
- **Why this path:** Kerala's daily-wage worker demographic is ~95% Android. Homeowners are also predominantly Android. Building and testing on both platforms doubles QA effort and App Store review latency. iOS added post-PMF.
- **Trade-off accepted:** Some homeowners may be on iPhone and unable to use the app. This is acceptable for the Ernakulam pilot; revisited for v2.

## Decision: Geohash Proximity Queries (not PostGIS)

- **What we decided:** Geohash-based proximity using `geofire-common` library
- **Alternatives considered:** PostGIS (requires PostgreSQL), ElasticSearch geo queries, Google Maps Distance Matrix API
- **Why this path:** Firestore does not support native geospatial queries. Geohash prefix matching is the standard Firestore workaround — widely documented, works reliably for "workers within 10km" queries without a separate database.
- **Trade-off accepted:** Geohash queries cover a rectangular area, not a circle. Slight over-fetch requires client-side distance filtering. Negligible at v1 scale.

## Decision: DigiLocker for Aadhaar Verification (not third-party KYC)

- **What we decided:** DigiLocker API (India government) for Aadhaar OTP verification
- **Alternatives considered:** Digio, IDfy, CAMS KRA (paid third-party KYC vendors), manual document upload
- **Why this path:** DigiLocker is free, government-backed, and workers already have Aadhaar. Third-party KYC vendors charge ₹5–25 per verification and require business agreements that slow down launch. Aadhaar number is never stored — only the verified boolean.
- **Trade-off accepted:** DigiLocker API can be slow and occasionally down. Verification is incentivised (better ranking), not mandatory — so API downtime doesn't block workers from using the platform.

## Decision: Twilio WhatsApp API (not direct Meta WABA)

- **What we decided:** Twilio as the WhatsApp Business API wrapper for v1
- **Alternatives considered:** Meta's direct Cloud API for WABA, Gupshup, Interakt
- **Why this path:** Twilio provides sandbox testing without requiring Meta Business verification upfront. Faster to get started. Switch to direct WABA once volume justifies it.
- **Trade-off accepted:** Twilio adds a cost margin over direct WABA. Acceptable at v1 message volume.

## Decision: No In-App Payments in v1

- **What we decided:** Cash payment model; no UPI/digital payments in v1
- **Alternatives considered:** UPI integration (Razorpay, Cashfree), wallet model
- **Why this path:** Payment integration requires KYC, GST registration, payment gateway agreements, and RBI compliance — all of which are months of work before the first booking. Cash is familiar and trusted for this demographic. No payment processing = no regulatory overhead in v1.
- **Trade-off accepted:** No transactional revenue in v1. Revenue model (commission on bookings) is a v2 decision.
