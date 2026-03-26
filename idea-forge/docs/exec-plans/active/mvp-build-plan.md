# Build Plan: Veettukkar — Kerala's Home Services Marketplace

> **Pilot scope:** Ernakulam district only. All of Phase 1 is built for this single district.
> **Platform:** Android only (React Native / Expo).
> **Stack:** Firebase + Cloud Functions + Twilio WhatsApp + DigiLocker.

---

## Phase 1 — Vertical Slice MVP
**Goal:** A homeowner can post a job, a nearby worker gets notified, accepts, and both rate each other after the job. The full loop works end-to-end in Ernakulam district with real users.

### What's in Phase 1

**P1-A: Project Setup & Core Infrastructure**
- [ ] Initialise React Native app with Expo (TypeScript, Expo Router)
- [ ] Configure Firebase project (Firestore, Auth, Functions, Storage, FCM)
- [ ] Set up i18n with i18next — Malayalam, Hindi, English locale files (initial strings)
- [ ] Configure Firestore security rules (users can only read/write their own docs; jobs readable by all authenticated users)
- [ ] Set up Cloud Functions project (Node.js 20, TypeScript)
- [ ] Configure Geohash library (geofire-common) for proximity queries
- [ ] Set up Expo EAS Build profile for Android

**P1-B: Authentication**
- [ ] Phone OTP login screen (Firebase Auth phone provider)
- [ ] OTP entry and verification screen
- [ ] Role selection screen after first login (Homeowner / Worker)
- [ ] Malayalam + English UI for all auth screens

**P1-C: Worker Profile**
- [ ] Worker registration form: name, skills (multi-select from 6 categories), location (GPS auto + manual area), day rate, half-day rate, optional photo
- [ ] Photo upload to Firebase Storage (auto-resize to 200×200 via Cloud Function trigger)
- [ ] Worker profile view screen (own profile + read-only view for homeowners)
- [ ] "Available Today" toggle on worker home screen

**P1-D: Job Posting (Homeowner)**
- [ ] Job post form: skill category (dropdown), date (date picker), duration (half-day / full-day), location (GPS pin + area label), optional description, "Urgent" toggle
- [ ] Homeowner home screen: list of posted jobs with status indicators
- [ ] Job detail screen showing status (open → confirmed → completed)

**P1-E: Job Matching & Notifications (Cloud Functions)**
- [ ] `onJobCreated` Cloud Function: geohash worker query (10km radius, matching skill), rank + select top 20, write to notifications_queue, send FCM push
- [ ] `onJobAccepted` Cloud Function: update job status, notify homeowner with worker details, expire other notifications for this job
- [ ] `expireOldJobs` scheduled function (hourly): mark jobs as expired past date + 24h
- [ ] `resetAvailableToday` scheduled function (midnight IST): reset worker availability flags

**P1-F: Worker Job Feed**
- [ ] Worker home screen: list of open nearby jobs matching their skills
- [ ] Job card: skill, date, duration, neighbourhood, urgent badge, homeowner rating (not name)
- [ ] Accept / Decline flow
- [ ] "My Jobs" tab: accepted + completed job history

**P1-G: Post-Job Rating**
- [ ] `promptRatings` Cloud Function (daily 8pm): send FCM + WhatsApp prompt to homeowner for completed jobs without rating
- [ ] Rating screen (homeowner → worker): 1–5 stars + optional comment
- [ ] `onRatingCreated` Cloud Function: recalculate worker's ratingAvg + ratingCount
- [ ] Rating display on worker profile and job cards

**P1-H: WhatsApp Notification Fallback**
- [ ] Twilio WhatsApp API integration in Cloud Functions
- [ ] Job alert WhatsApp template (pre-approved): job summary + deep link
- [ ] Rating reminder WhatsApp template
- [ ] Worker phone numbers passed to Twilio only; never stored client-side

**P1-I: Aadhaar Verification**
- [ ] DigiLocker API integration in `verifyAadhaar` Cloud Function
- [ ] "Get Verified" screen in worker profile
- [ ] Aadhaar OTP flow (initiate → enter OTP → confirm)
- [ ] "Verified ✓" badge displayed on profile and job cards
- [ ] Aadhaar number never stored; only `aadhaarVerified: true` boolean

**P1-J: Job History & Basic Settings**
- [ ] Homeowner job history list
- [ ] Worker completed jobs list with earned ratings
- [ ] Language preference toggle (Malayalam / English / Hindi) in settings
- [ ] Log out

### Definition of Done

Phase 1 is complete when:
1. A test homeowner in Ernakulam can post a job and receive a confirmation from a test worker within 5 minutes
2. A test worker receives both a push notification AND a WhatsApp message for a matching job
3. Both sides can rate each other after job date passes
4. Worker profile shows verified badge after completing Aadhaar OTP flow
5. App APK installs and runs correctly on a low-end Android device (2GB RAM, Android 10)
6. All primary UI strings are displayed in Malayalam by default

### Estimated Scope
**Large** — 10 subsystems across app + Cloud Functions + 2 external API integrations. Expect 6–8 weeks of focused solo-founder build with AI-agent assistance.

---

## Phase 2 — Pilot Quality & Ernakulam Density
**Goal:** Fix issues from real-user pilot, onboard 30+ verified workers across all 6 skill categories in Ernakulam, hit 70% job fill rate.

### What's in Phase 2
- [ ] Worker onboarding improvements (guided registration flow, in-app tutorial)
- [ ] Homeowner onboarding improvements (what happens after posting, what to expect)
- [ ] Job cancellation flow (homeowner cancels confirmed job; worker notified; reason captured)
- [ ] Worker "no-show" reporting by homeowner (flags worker account for review)
- [ ] Admin simple view: list of recent jobs + flagged workers (Firestore-backed, web-based)
- [ ] Worker-to-homeowner rating (currently recorded but not shown) — display in v2 after trust established
- [ ] Search / browse workers by skill (homeowner-initiated, not just job-post flow)
- [ ] Push notification reliability improvements (retry logic in Cloud Functions)
- [ ] Performance profiling on low-end Android devices; bundle size optimisation

### Definition of Done
- 30+ verified workers across all 6 categories active in Ernakulam
- 70%+ job fill rate over a rolling 7-day window
- No open P1-severity bugs after 2 weeks of real-user traffic

---

## Phase 3+ — Expansion and Monetisation
**Goal:** Expand to 3+ districts; introduce commission-based revenue model.

### What's Parked for Later
- Multi-district expansion (Thiruvananthapuram, Kozhikode) — district-by-district after Ernakulam PMF
- iOS app — after Android user base established
- In-app UPI payments + commission model — after platform density proven
- Subscription plans for homeowners (priority matching)
- Advanced matching (time-of-day, worker preferred distance, blacklist)
- ML-based demand forecasting for worker recruitment
- Recruiter dashboard for labour contractors who onboard multiple workers

---

## Milestones

| Milestone | Deliverable | Phase |
|-----------|-------------|-------|
| M1: App boots | Firebase connected, auth works, locale loads in Malayalam | 1 |
| M2: Worker can register | Full worker profile, photo, location, skills stored | 1 |
| M3: Job post → notification | Homeowner posts job, worker receives FCM + WhatsApp | 1 |
| M4: Accept → confirm | Worker accepts, homeowner gets worker phone number | 1 |
| M5: Ratings loop | Post-job rating prompt, stars stored, ratingAvg updated | 1 |
| M6: Aadhaar verify | Worker completes Aadhaar OTP, verified badge shows | 1 |
| M7: Full loop on real device | End-to-end test on low-end Android (2GB RAM) | 1 |
| M8: 30 workers onboarded | Ernakulam pilot with real workers across all 6 categories | 2 |
| M9: 70% fill rate | Rolling 7-day fill rate ≥ 70% in Ernakulam | 2 |

---

## Dependencies

**Must be set up before building starts:**
- Firebase project created with Blaze plan (required for Cloud Functions + external API calls)
- Twilio account with WhatsApp Sandbox enabled (later: approved WhatsApp Business number)
- DigiLocker API developer access (apply at api.digilocker.gov.in — takes 1–2 weeks approval)
- Expo EAS account for Android builds
- Google Play Developer account for APK distribution
- WhatsApp message templates submitted for approval (2–5 business days for Meta review)

**Content / data needed before launch:**
- 6 skill category names + icons in Malayalam and English
- UI string translations for Malayalam (all screens) — can be done in parallel with build
- Worker recruitment: minimum 5 workers per skill category in Ernakulam before soft launch

---

## Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| DigiLocker API approval takes >2 weeks | Medium | Medium | Build all other features first; Aadhaar verify is last to integrate |
| WhatsApp template rejection by Meta | Medium | High | Submit templates early; prepare SMS fallback (Firebase Extensions) |
| Low-end Android performance issues | Medium | High | Test on Redmi 9A (1GB RAM, Android 10) from day 1 of build |
| Cold-start: workers don't install app | High | High | In-person onboarding at construction sites; WhatsApp-first registration flow |
| Geohash proximity queries return incorrect results | Low | High | Unit-test geofire-common queries with known coordinates; review index limits |
| Firebase Cloud Functions cold-start latency | Low | Medium | Use Functions v2 (min instances = 1 for onJobCreated); acceptable for v1 |
| Urban Company expands to Ernakulam during pilot | Low | Medium | Our worker categories (coconut climbers, migrant masons) are outside their model |

---

## First Task

**Set up Firebase project and connect to Expo app.**

Specifically:
1. Create Firebase project named `veettukkar-prod`
2. Enable Firestore, Auth (Phone provider), Functions, Storage, FCM
3. Create Expo app: `npx create-expo-app veettukkar --template expo-template-blank-typescript`
4. Install `@react-native-firebase/app`, `@react-native-firebase/auth`, `@react-native-firebase/firestore`
5. Add `google-services.json` to Android config
6. Verify: app boots, Firebase connects, phone OTP sends to a test number

This is the smallest step that proves the stack works end-to-end before anything else is built.
