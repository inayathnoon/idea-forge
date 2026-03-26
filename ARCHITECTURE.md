# Architecture: Veettukkar — Kerala's Home Services Marketplace

## System Overview

```
┌────────────────────────────────────────────────────────────┐
│                    MOBILE APP (React Native)                │
│  ┌──────────────┐          ┌──────────────────────────┐    │
│  │  Homeowner   │          │       Worker             │    │
│  │  Post Job    │          │   Browse / Accept Job    │    │
│  │  View Match  │          │   Manage Profile         │    │
│  │  Rate Worker │          │   Available Today Toggle │    │
│  └──────┬───────┘          └────────────┬─────────────┘    │
│         │                               │                   │
└─────────┼───────────────────────────────┼───────────────────┘
          │           HTTPS / REST        │
          ▼                               ▼
┌─────────────────────────────────────────────────────────────┐
│                   FIREBASE PLATFORM                         │
│                                                             │
│  ┌──────────────────┐   ┌────────────────────────────────┐  │
│  │  Firebase Auth   │   │        Firestore (DB)          │  │
│  │  Phone OTP       │   │  users / jobs / ratings        │  │
│  └──────────────────┘   │  notifications_queue           │  │
│                          └────────────────────────────────┘  │
│  ┌──────────────────┐   ┌────────────────────────────────┐  │
│  │  Cloud Functions │   │     Firebase Storage           │  │
│  │  (Node.js)       │   │     Profile photos             │  │
│  │  job-match       │   └────────────────────────────────┘  │
│  │  notify-workers  │                                        │
│  │  job-expire      │   ┌────────────────────────────────┐  │
│  │  rating-prompt   │   │    FCM (Push Notifications)    │  │
│  └──────────────────┘   └────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
          │
          ▼
┌──────────────────────────┐
│  WhatsApp Business API   │
│  (Twilio / WABA)         │
│  Job alert fallback      │
│  Rating reminder         │
└──────────────────────────┘
          │
          ▼
┌──────────────────────────┐
│  DigiLocker API          │
│  Aadhaar OTP Verify      │
│  Worker identity check   │
└──────────────────────────┘
```

Veettukkar is a serverless mobile application built entirely on Firebase. The React Native app communicates with Firestore directly (with security rules) and triggers Cloud Functions for business logic that requires coordination (job matching, notifications, expiry). External services — WhatsApp Business API and DigiLocker — are called from Cloud Functions only, never from the client.

---

## Components

### 1. React Native Mobile App
**Responsibility:** All user-facing UI — homeowner job posting, worker profile management, job browsing, accept/decline, ratings, history.

**Technology:** React Native with Expo
- **Why Expo:** Managed workflow simplifies Android builds, OTA updates, and push notification setup. No native code to maintain for v1.
- **Why React Native over Flutter:** Larger ecosystem for Firebase integration, more JS-native tooling, faster to iterate on UI with TypeScript. Solo founder advantage: fewer new paradigms to learn.
- **Language:** TypeScript throughout.
- **Malayalam/Hindi i18n:** `i18next` with `react-i18next`. Language files are JSON; stored in `/locales/`. Language preference stored in Firestore user doc and local AsyncStorage.
- **App size target:** < 15MB APK. Enforced by avoiding heavy native modules.

### 2. Firebase Auth
**Responsibility:** Phone number + OTP authentication for both user types.

**Technology:** Firebase Authentication (Phone provider)
- **Why:** First-class phone OTP with automatic SMS delivery, reCAPTCHA protection, zero backend code required. Firebase handles rate limiting.
- **Flow:** User enters phone → Firebase sends OTP → user enters OTP → Firebase issues JWT → all Firestore reads/writes are JWT-authenticated.

### 3. Firestore (Cloud Firestore)
**Responsibility:** Primary database. Stores all persistent state: users, jobs, ratings, notification queue.

**Technology:** Cloud Firestore (NoSQL document store)
- **Why over PostgreSQL/Supabase:** Real-time listeners are native to Firestore — job status updates (pending → confirmed) push to both homeowner and worker without polling. For a marketplace where both sides need live status, this is the right primitive.
- **Why over Realtime Database:** Firestore's richer query model (compound indexes, collection groups) handles the geo-proximity worker query pattern better.

**Collections:**

```
users/{uid}
  - role: "homeowner" | "worker"
  - name, phone, language
  - location: { district, area, geohash, lat, lng }  ← worker only
  - skills: string[]                                  ← worker only
  - dayRate, halfDayRate                              ← worker only
  - availableToday: boolean                           ← worker only
  - availableTodayResetAt: timestamp                  ← worker only
  - aadhaarVerified: boolean                          ← worker only
  - ratingAvg: number, ratingCount: number            ← worker only
  - photoURL: string

jobs/{jobId}
  - homeownerId: string
  - skill: string
  - date: timestamp
  - duration: "half" | "full"
  - locationText: string
  - locationGeo: { geohash, lat, lng }
  - urgent: boolean
  - description: string
  - status: "open" | "confirmed" | "completed" | "expired"
  - acceptedWorkerId?: string
  - acceptedAt?: timestamp
  - createdAt: timestamp
  - expiresAt: timestamp   ← 24h after job date if not confirmed

ratings/{ratingId}
  - jobId, fromUid, toUid
  - stars: 1–5
  - comment?: string      ← homeowner→worker only in v1
  - createdAt: timestamp

notifications_queue/{notifId}
  - workerId, jobId, type: "job_alert" | "rating_prompt"
  - sentAt, channel: "fcm" | "whatsapp"
  - status: "pending" | "sent" | "failed"
```

### 4. Cloud Functions (Node.js)
**Responsibility:** Server-side business logic that requires coordination or external API calls.

**Technology:** Firebase Cloud Functions v2 (Node.js 20, TypeScript)
- **Why:** Zero server management. Functions scale to zero when idle — perfect for a Kerala-focused v1 with low baseline traffic.

**Functions:**

| Function | Trigger | What it does |
|----------|---------|--------------|
| `onJobCreated` | Firestore onCreate (jobs/) | Queries workers within 10km by skill + date; creates notification_queue entries; calls FCM + WhatsApp API |
| `onJobAccepted` | Firestore onUpdate (jobs/ status→confirmed) | Sends confirmation to homeowner (FCM + WhatsApp); marks all other notifications for this job as expired |
| `expireOldJobs` | Scheduled (hourly) | Marks jobs as expired if past date + 24h with no acceptance |
| `promptRatings` | Scheduled (daily at 8pm) | Sends rating prompts for jobs completed today that have no rating yet |
| `resetAvailableToday` | Scheduled (midnight IST) | Resets `availableToday: false` for all workers |
| `onRatingCreated` | Firestore onCreate (ratings/) | Recalculates worker's `ratingAvg` and `ratingCount` on the user doc |
| `verifyAadhaar` | HTTPS callable | Calls DigiLocker API to verify Aadhaar OTP; sets `aadhaarVerified: true` on worker profile |

### 5. Firebase Storage
**Responsibility:** Worker profile photos.

**Technology:** Firebase Storage (Cloud Storage)
- **Why:** Direct client upload with Firebase security rules (authenticated users only). No backend upload endpoint needed.
- Profile photos are resized to 200×200px via a Cloud Function trigger before being served — avoids sending full-resolution photos on low-bandwidth connections.

### 6. FCM (Firebase Cloud Messaging)
**Responsibility:** Push notifications to the React Native app for job alerts, job confirmations, and rating prompts.

**Technology:** Firebase Cloud Messaging
- **Why:** Native to Firebase; free; handles Android notification delivery reliably.
- FCM tokens are stored on the user doc and refreshed on each app launch.

### 7. WhatsApp Business API (via Twilio or direct WABA)
**Responsibility:** Job alert fallback and rating reminders for workers who don't reliably engage with push notifications.

**Technology:** Twilio WhatsApp API (or Meta's Cloud API for WABA)
- **Why Twilio first:** Faster to sandbox test; no Meta Business verification required to start. Switch to direct WABA when volume justifies it.
- Messages are templated (required by WhatsApp Business rules). Templates are pre-approved.
- Called from Cloud Functions only — worker phone numbers never leave the server.

### 8. DigiLocker API
**Responsibility:** Aadhaar-based identity verification for workers.

**Technology:** DigiLocker REST API (India government)
- **Why DigiLocker over third-party KYC:** Free, government-backed, Aadhaar-linked. Workers already have Aadhaar; DigiLocker lets them share it without uploading a scan.
- Flow: Worker taps "Get Verified" → Cloud Function initiates Aadhaar OTP flow via DigiLocker → worker enters OTP → DigiLocker confirms identity → Cloud Function sets `aadhaarVerified: true`.
- Aadhaar number itself is **never stored** in Firestore. Only the verified boolean and a DigiLocker transaction reference.

---

## Data Flow

### Flow 1 — Homeowner Posts a Job

```
1. Homeowner fills job form (skill, date, duration, location, urgent?)
2. App reverse-geocodes GPS to district + area name
3. App computes geohash for location
4. Job document written to Firestore jobs/ collection (status: "open")
5. Cloud Function onJobCreated fires:
   a. Queries users/ where:
      - role = "worker"
      - skills contains requested skill
      - geohash within ~10km (Geohash proximity query)
      - (if future date) no conflicting confirmed job on that date
   b. Ranks results: availableToday desc, aadhaarVerified desc, ratingAvg desc, distance asc
   c. Top 20 workers → creates notifications_queue entries
   d. Sends FCM push to each worker
   e. Sends WhatsApp message to each worker (via Twilio) as fallback
6. Homeowner sees "Job posted — workers are being notified"
```

### Flow 2 — Worker Accepts a Job

```
1. Worker receives push notification / WhatsApp message
2. Worker opens app → sees job summary
3. Worker taps "Accept"
4. App updates job document: status = "confirmed", acceptedWorkerId = workerId
5. Cloud Function onJobAccepted fires:
   a. Reads homeowner doc → gets FCM token + phone
   b. Sends FCM + WhatsApp confirmation to homeowner with worker name, rating, phone
   c. Sets all other notifications_queue entries for this job to expired
6. Homeowner sees: "Confirmed — [Worker name], ⭐4.8 (47 jobs), +91 XXXXX"
```

### Flow 3 — Post-Job Rating

```
1. Daily scheduled function (8pm IST) finds jobs where:
   - date = today or earlier, status = "confirmed"
   - no rating from homeowner yet
2. Sends rating prompt: FCM + WhatsApp to homeowner
3. Homeowner taps link → opens rate screen
4. Homeowner selects stars + optional comment → submits
5. Rating document created in ratings/
6. Cloud Function onRatingCreated:
   a. Aggregates all ratings for worker
   b. Updates ratingAvg and ratingCount on worker's user doc
```

---

## Tech Stack

| Layer | Choice | Rationale |
|-------|--------|-----------|
| Language | TypeScript | Type safety across app + Cloud Functions; single language for full stack |
| Mobile framework | React Native (Expo) | Fast iteration, managed builds, Firebase SDK, i18n support; Android-first |
| Database | Cloud Firestore | Real-time listeners native; geo-proximity queries; scales to zero when idle |
| Auth | Firebase Auth (Phone OTP) | Zero-code OTP; handles SMS delivery, rate limiting, JWT issuing |
| Server-side logic | Cloud Functions v2 (Node.js) | Serverless; no infrastructure to manage; triggered by Firestore events + schedules |
| File storage | Firebase Storage | Direct client upload with security rules; no upload endpoint needed |
| Push notifications | FCM | Native Firebase; free; reliable Android delivery |
| WhatsApp notifications | Twilio WhatsApp API | Job alert fallback for workers; rating reminders; templated messages |
| Identity verification | DigiLocker API | Free government Aadhaar verification; no KYC vendor needed |
| Geo queries | Geohash (geofire-common) | Standard approach for Firestore proximity queries; no PostGIS needed |
| i18n | i18next + react-i18next | Battle-tested; JSON locale files; Malayalam + Hindi + English |

---

## Key Design Decisions

### Decision: Firebase over Supabase
- **What we chose:** Firebase (Firestore + Functions + Auth + FCM)
- **Why:** Firestore's real-time listeners are a natural fit for a job marketplace where both sides need live status. FCM and Firebase Auth are already in the same ecosystem — no glue code. Supabase (PostgreSQL + row-level security) is excellent but requires an always-on server for WebSocket subscriptions, adding operational cost and complexity for a solo founder.
- **Trade-off:** Firestore's NoSQL model requires denormalisation (e.g., ratingAvg stored on user doc). Acceptable for v1 scale. Migrating to PostgreSQL post-scale is a known path.

### Decision: React Native (Expo) over Flutter
- **What we chose:** React Native with Expo managed workflow
- **Why:** Firebase's React Native SDK is mature and well-documented. TypeScript across app + Cloud Functions = one language for the whole stack. Expo's OTA updates mean bug fixes don't require a Play Store review cycle.
- **Trade-off:** Flutter has better performance on very low-end devices. If sub-1GB RAM device support becomes critical, this decision should be revisited.

### Decision: Geohash proximity queries over PostGIS
- **What we chose:** Geohash-based proximity queries using the `geofire-common` library
- **Why:** Firestore does not support native geospatial queries. Geohash prefix matching is the standard workaround — it enables "workers within 10km" queries without a separate geo database.
- **Trade-off:** Geohash queries require client-side distance filtering (the geohash covers a rectangular area, not a circle). The slight over-fetch is negligible at v1 scale.

### Decision: Cash payment model (no in-app payments in v1)
- **What we chose:** No payment processing. Workers receive cash at end of day as always.
- **Why:** UPI/digital payment integration requires KYC, GST registration, payment gateway onboarding, and RBI compliance — all of which are months of work before the first job is booked. Cash is familiar, trusted, and immediate for this demographic.
- **Trade-off:** Platform has no transactional revenue in v1. Commission model is a v2 decision once marketplace density is proven.

### Decision: Aadhaar verification via DigiLocker (not third-party KYC)
- **What we chose:** DigiLocker's free government API for Aadhaar OTP verification
- **Why:** Third-party KYC vendors (Digio, IDfy, CAMS KRA) charge ₹5–25 per verification and require business agreements. DigiLocker is free, government-backed, and workers already have Aadhaar. Aadhaar number is never stored.
- **Trade-off:** DigiLocker API can be slow and occasionally down. Verification is incentivised, not mandatory — so failures don't block workers from using the platform.

---

## What We're NOT Designing (v1)

| Concern | Deferred Reason |
|---------|----------------|
| iOS app | Android-only. Kerala daily-wage worker demographic is ~95% Android. |
| In-app payments / UPI | KYC, GST, payment gateway complexity. Revenue model is v2. |
| PostgreSQL / relational DB | Firestore's real-time model is sufficient at v1 scale. Migrate if needed. |
| Admin dashboard / moderation tools | Solo founder handles disputes manually. Dashboard added when team exists. |
| AI-based matching / dynamic pricing | Proximity + rating ranking is sufficient. No ML complexity in v1. |
| CI/CD pipeline | Manual Expo builds + Firebase deploy via CLI. Automated pipeline added in v2. |
| Multi-region Firebase | Kerala is the only geography. Single Firebase region (asia-south1, Mumbai). |
| Caching layer (Redis etc.) | Firestore's built-in caching is sufficient for v1 read patterns. |
