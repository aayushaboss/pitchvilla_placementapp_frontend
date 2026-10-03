# Prompt: Redesign onboarding + job detail page to match Internshala's flow

## Goal
Collapse the current 4-screen pre-app onboarding (value slides → segment → phone/OTP →
micro-profile → goals) into **max 3 screens**, matching Internshala's pattern: one combined
value-prop + auth screen, one prefill + manual-details screen, one optional
preferences screen. Also restyle the job/company detail page to match Internshala's.

Reference (verified live on internshala.com mobile, 2026-08-18):
- Landing screen: header (hamburger + logo + search pill) → hero photo → headline
  "India's #1 platform" (bold) / "For fresher jobs, internships and courses" (2 lines,
  one keyword underlined) → "Continue with Google" (white pill, Google icon) →
  "Continue with Email" (dark blue pill, envelope icon) → "By continuing, you agree to
  our T&C." → dark banner "10K+ Openings daily" pinned above the bottom tab bar.
- A signup variant shows "3,00,000+ companies hiring on Internshala" as the trust line
  instead of a logo strip — the "X companies hire through us" proof is a **number**, not
  actual logos. Use this pattern (a stat line), not a horizontal logo carousel.
- Job/internship cards elsewhere on the site: title, company, location, salary range,
  duration (internships only), a type tag ("Job"/"Internship"), "View details" link,
  and an "Actively hiring" pill badge on some cards.
- Company/job detail page (from user's own screenshot): header row = back arrow +
  "About company" title + bookmark icon + comment/chat icon (right-aligned). Body:
  "About us" heading + paragraph describing the company. Then "Openings" heading +
  a horizontally-scrollable row of cards, each: "Actively hiring" pill, job title
  (bold), company name (gray, below title), divider, then meta rows **stacked one per
  line** (not comma-joined) — location (pin icon), salary (₹ icon), duration (calendar
  icon) — then a footer row: type tag chip (left) + "View details ›" link (right, blue).
  Page-dot indicator below the card row shows how many openings are scrollable.

## Current codebase (do not guess file names — these are the real ones)
- `lib/screens/onboarding/value_slides_screen.dart` — current 2-slide PageView landing
  screen (Skip / Next / Get Started / "I already have an account"). **Replace entirely.**
- `lib/screens/onboarding/segment_screen.dart` — "What stage are you at?" school/UG/PG
  picker, calls `AppState.setPendingSegment()` then pushes `/auth/login`. **Fold into
  the new flow** (see Segment handling below) rather than keeping as its own screen.
- `lib/screens/auth/login_screen.dart` + `lib/screens/auth/otp_screen.dart` — phone
  number + OTP flow. **Keep as the "Continue with Email" fallback path** (there's no
  real backend, so treat "Continue with Google" as a **mocked instant sign-in**, and
  "Continue with Email" as routing into the existing phone/OTP screens unchanged).
- `lib/screens/onboarding/micro_profile_screen.dart` — one-question-per-page PageView
  collecting name/city/college/course/year (college) or name/city/class/board (school).
  **Replace with the merged prefill+manual screen** described below.
- `lib/screens/college/goals_screen.dart` — goal (internship/job/both) + role chips,
  currently the last onboarding step, already fixed this session to land on `/tabs`
  directly on finish. **Keep this screen close to as-is** — it already matches
  Internshala's "areas of interest" step reasonably well — just reposition it as the
  optional Screen 3 (see decision point below).
- `lib/state/app_state.dart` — `AppState` with `_pendingSegment`, `setPendingSegment()`,
  `updateProfile()`, `_makeNewUser()`. **Needs a new mock method** for "Google sign-in"
  (see below).
- `lib/models/user.dart` — `User` model (id, identifier, name, city, segment,
  currentClass, board, college, course, year, fieldOfStudy, goal, roles, photoUrl,
  resume, aptitudeResults, onboardingComplete, aptitudeSkipped).
- `lib/router.dart` — routes: `/onboarding`, `/onboarding/segment`,
  `/onboarding/profile`, `/auth/login`, `/auth/otp`, `/college/goals`, `/tabs`.
  **Will need new/renamed routes** for the 3-screen flow.
- `lib/screens/college/opportunity_detail_screen.dart` — current single-opportunity
  detail page (hero image, About the role, Requirements, Work mode, Prep courses,
  bottom Apply bar). **Restyle per the decision point below.**
- `lib/models/opportunity.dart` — `Opportunity` model has `about` (currently used as
  the *role* description, not a company description) and no company-level fields yet.

## Screen 1 — Landing / Value prop + Auth
Replace `value_slides_screen.dart` entirely (delete the 2-slide carousel). New single
screen:
- Hero image (reuse one of the existing Unsplash URLs already in `_slides`, or pick one).
- Headline, max 2 lines, JTBD-direct: e.g. "Find your next internship or job" / "Real
  openings, matched to you." (Do NOT reuse the current abstract "Future-Ready Skills"
  copy — it doesn't state the job-to-be-done.)
- "Continue with Google" button (primary, white bg, Google "G" icon — `Ionicons.logo_google`
  already used elsewhere in this codebase for the calendar sheet).
- "Continue with Email" button (secondary) → routes to the existing `/auth/login` flow
  unchanged.
- Small print: "By continuing, you agree to our T&C." (reuse existing copy tone).
- Bottom stat line instead of a logo strip: "10,000+ opportunities · 500+ companies
  hiring" (or similar single-line stat) — pull the opportunity count from
  `mockOpportunities.length` so it's not a hardcoded lie, and hardcode a plausible
  company count.
- **Segment handling decision**: this screen has no room for a segment question and
  Internshala doesn't ask one. Two options — pick one and note which you picked in your
  summary:
  (a) Ask segment as the very first field at the top of Screen 2's manual section
      (recommended — keeps Screen 1 a pure 2-button auth screen, matches Internshala
      exactly), or
  (b) Keep `segment_screen.dart` as a lightweight interstitial between Screen 1 and
      Screen 2, shown only once.
  Recommendation: (a). `AppState.setPendingSegment()` / `_pendingSegment` machinery
  already exists — repurpose it to be set from Screen 2 instead of a dedicated screen.

## Mock "Google sign-in" prefill mechanism
There's no real Google OAuth in this app (prototype). Add a mock in `AppState`:
```dart
Future<void> mockGoogleSignIn() async {
  // fabricate a plausible profile the way real Google OAuth would hand one back
  // e.g. name: 'Aayusha Pagare', city: 'Pune', identifier: a fake email
  // set _user to a new User with these fields populated, onboardingComplete: false
}
```
Tapping "Continue with Google" on Screen 1 calls this, then navigates straight to
Screen 2 with the fabricated name/city/email already in state — **no OTP step for the
Google path** (matches real Google sign-in — instant, no verification code).
"Continue with Email" keeps the real phone/OTP flow, and lands on Screen 2 afterward
too, just without prefilled name/city (those become blank on that path — reasonable,
since email/phone alone doesn't hand back a name or city).

## Screen 2 — Prefill (top) + manual details (bottom), one screen
Replace `micro_profile_screen.dart`'s multi-page-per-question pattern with a **single
scrollable screen**, two sections:
- **Top**: a progress indicator bar (reuse the `LinearProgressIndicator` +
  `TweenAnimationBuilder` pattern already in `micro_profile_screen.dart`) showing
  e.g. 50% — computed as (fields already filled) / (total fields), not hardcoded.
  Below it, the prefilled fields shown as **already-filled** `PillInput`s (or plain
  read-only rows with an edit affordance) for Name, City — whatever
  `mockGoogleSignIn()` populated. If the user came via "Continue with Email" instead,
  these fields are empty and the user fills them normally (same UI, just not
  pre-filled).
- **Bottom**: manual-only fields, using the *existing* input widgets already in this
  codebase (`AppChip` grids, `SearchableSelect` for city/college/course — see
  `mock_profile_options.dart` and `widgets/searchable_select.dart`, already built and
  used by `micro_profile_screen.dart` — reuse them directly, don't rebuild):
  - Segment choice (if you picked option (a) above) — 3 `AppChip`s or the existing
    `_SegmentCard` style from `segment_screen.dart`.
  - College segment: college (SearchableSelect), course (SearchableSelect + groups),
    year (chip grid) — same options already defined in `micro_profile_screen.dart`.
  - School segment: class (chip grid), board (chip grid) — same as today.
  - Experience level (fresher / intern experience / 1-2 yrs / 2+ yrs) — this
    currently lives in `resume_builder_quiz_screen.dart`'s `_ExperienceStep`; pull the
    same `_experienceOptions` list here instead if you want it this early, OR leave
    experience for later (resume flow) — **decision point, pick one and note it**.
- Single "Continue" button at the bottom, disabled until all *required* fields
  (segment-appropriate ones) are filled — mirrors the existing `_canContinue` validation
  pattern from `micro_profile_screen.dart`, just evaluated across one screen instead of
  per-page.
- On submit: same `AppState.updateProfile()` call `micro_profile_screen.dart` already
  makes, same routing split (school → `/tabs` with `onboardingComplete: true`,
  `aptitudeSkipped: true`; college → next screen).

## Screen 3 — Preferences (college only, optional per your "max 3")
Reposition existing `goals_screen.dart` as this step, unchanged in content (goal +
role chips) — it already does the right job and already routes to `/tabs` on finish
(fixed earlier this session to skip the old resume-during-onboarding step). School
segment has no Screen 3 — already goes straight to `/tabs` from Screen 2.

If you want literally 2 screens instead of 3, fold goal + top 4-6 role chips into
Screen 2's bottom section and delete this step — **decision point**, note which you
chose.

## Routing changes (`router.dart`)
- Remove `/onboarding` (value slides) as a distinct route from the old carousel;
  point it at the new Screen 1 widget (keep the path `/onboarding` so nothing else
  linking to it breaks — grep for `context.go('/onboarding')` / `context.push` first,
  there are several call sites e.g. `profile_screen.dart`'s logout).
- Remove `/onboarding/segment` route entirely if you picked segment option (a).
- Rename/repoint `/onboarding/profile` to the new merged Screen 2.
- `/college/goals` stays as-is (Screen 3), already correct.
- `/auth/login`, `/auth/otp` stay as-is (unchanged fallback path).

## Job/company detail page — decision point
Your screenshot shows a **company profile page** (multiple openings from one company,
horizontally scrollable) — this is a different shape than the current
`opportunity_detail_screen.dart` (single opportunity, full detail). Two paths:
(a) **Restyle only** — keep `opportunity_detail_screen.dart` as a single-opportunity
    page, but adopt Internshala's visual language: header icons (back, bookmark, chat
    — chat can be a no-op or route to the mock interview booking), meta rows stacked
    one-per-line instead of the current comma-joined `_MetaItem` row, "Actively hiring"
    style pill near the title. Smaller change, no new data model needed.
(b) **Build the real thing** — add a `Company` concept (name, about, list of
    opportunity IDs — derivable from grouping existing `mockOpportunities` by
    `company` field, no new model strictly required, just a `companiesFrom
    (List<Opportunity>)` helper), a new route `/company/:name`, and a horizontally
    scrollable openings carousel using something close to the existing
    `OpportunityRow`/`PrepCourseCard` card patterns but reshaped to match the
    screenshot (stacked meta, footer tag+link, page dots).
Recommendation: (a) first (much smaller, ships fast, addresses "job details page"
literally), with (b) as a possible follow-up if you specifically want the
multi-opening-per-company browsing pattern. **Pick one and say so before starting.**

## Explicit non-goals (don't touch)
- Bottom tab bar structure (Home/Explore/Applications/Sessions/Profile) — unrelated.
- Resume-building flow — already moved out of onboarding this session, stays that way.
- Apply-gate logic in `opportunity_detail_screen.dart` (`_showApplyGateSheet`) — unrelated.
- School segment's separate aptitude quiz flow — unrelated to this redesign.

## After implementing
- `flutter analyze` clean.
- `flutter build web --no-tree-shake-icons`, verify live in the Browser pane at a
  mobile viewport (375×667 or 390×844) for: Screen 1 copy fits without scrolling,
  Screen 2's prefilled vs manual sections both render correctly for both the Google
  path and the Email path, Screen 3 (if kept) still routes to `/tabs` on finish, and
  the restyled job detail page renders with no overflow.
