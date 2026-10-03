# Prompt: Blend Naukri's apply flow + Internshala's card polish, restyle detail/applications/profile pages, reorder tabs, move resume into onboarding, kill the home "complete your profile" card

## Goal
Job/internship cards get a persistent Apply CTA (Naukri) drawn in Internshala's cleaner
visual style. Applying opens a short pre-apply questions sheet (Naukri). Landing shows
a FOMO notification prompt (Naukri). Job detail page gets applicant-count + similar-roles
(Naukri) while keeping the existing "Prep for this role" section. Bottom tabs reorder to
Home / Applications / Upskill / [renamed Sessions] / Profile. Skill boosts move off Home
onto the Upskill page. Applications page and Profile page restyle to match Naukri
(status cards; sectioned info cards instead of a settings-style list). Resume upload
moves into onboarding (Naukri-simple). The "Complete your profile" card is removed from
Home entirely — onboarding now collects everything that card used to nag about.
Copywriting everywhere gets tightened to Naukri's short, plain style. Landing page copy
leads unambiguously with JTBD #1 (find a job/internship); Upskill (JTBD #2) lives only
in its own tab, not on the landing screen.

## Reference research (grounded — verified live except where noted "per user")
- **Naukri job card** (live, mobile web, naukri.com/jobs-in-india): company name +
  ⭐ rating inline ("Hdfc Bank ⭐3.8"), location with pin icon, experience range with
  briefcase icon ("8-13 Yrs" — full-time jobs show experience range, not a duration),
  skills as a single plain comma-separated line ("Java · Cloud · Spring Boot ·
  Microservices" — not individual chips), a small red "New" badge for recent postings,
  footer row = "View details" (blue text link, left) + "Apply" (light-blue outlined
  pill button, right) — both always visible, no need to open the card first.
- **Naukri apply flow** (per user, since it's login-gated and I couldn't reach it
  directly): tapping "Apply" opens a **bottom sheet styled like a chat/conversational
  flow** — 2-3 quick things: screening questions written by the company itself, then a
  free-text "personal note" box to the recruiter, then a "Send"/submit action. Framed
  as "just take a couple of minutes."
- **Naukri FOMO notification prompt** (per user, seen on their own visit): on landing,
  a message close to "You missed out on 60 jobs last week! Turn on notifications" —
  creates urgency, drives immediate notification opt-in.
- **Naukri job detail page hierarchy** (general knowledge, well-documented UI): role
  title, company, **applicant count** ("X people applied"), job description, then a
  **"Similar jobs"** section near the bottom.
- **Naukri profile page** (general knowledge): information shown in **separate cards
  per category** (e.g. resume headline, key skills, employment, education, personal
  details) rather than one long settings-style list or form — each card shows a
  compact summary with an edit affordance, and secondary/optional info has explicit
  "+ Add details so recruiters know you better"-style prompts instead of being asked
  upfront.
- **Naukri applications page** (general knowledge): status-tagged cards, one per
  application, compact.
- **Internshala** (verified earlier this session): card visual polish — thumbnail
  image, generous but not loose spacing, clean type hierarchy; landing copy pattern
  (2-line JTBD headline, stat-line social proof instead of a logo wall).

## Current codebase state — read these before touching anything, several changed this
## session already
- `lib/widgets/opportunity_row.dart` — current job card: thumbnail, title, subtitle
  (company · type), one meta line (location · stipend · duration, comma-joined),
  match/deadline badges, bookmark icon. **No Apply button on the card today.**
- `lib/screens/college/opportunity_detail_screen.dart` — already restyled this session
  (header icons: back/bookmark/chat; stacked meta rows; "Actively hiring" pill; "Prep
  for this role" section at the bottom using `PrepCourseCard`). Has `_showApplyGateSheet`
  (profile-incomplete gate) and `_showSuccessSheet` (post-apply confirmation) already.
- `lib/models/opportunity.dart` — fields: id, title, company, type, location, workMode,
  stipend, duration, category, image, about, requirements, prepCourses, deadline. **No
  rating, applicantCount, or screeningQuestions fields yet.**
- `lib/mockData/mock_applications.dart` — `createApplication(opportunityId)` builds an
  `Application` with a starter timeline/message. This is the function any new apply
  flow should still call at the end.
- `lib/models/application.dart` — `Application` has no field for a submitted note or
  screening-question answers yet.
- `lib/screens/tabs/tabs_scaffold.dart` — current tab order (fixed earlier this
  session): Home, Explore (compass icon, courses), Applications, Sessions, Profile —
  Explore sits right after Home. **This prompt changes both the order and one label.**
- `lib/router.dart` — shell branches: `/tabs` (Home), `/tabs/explore` (courses,
  `CoursesExploreScreen`), `/tabs/browse` (Applications, `ApplicationsTrackerScreen`),
  `/tabs/sessions` (`SessionsScreen`), `/tabs/profile` (`ProfileScreen`).
- `lib/widgets/skill_story_strip.dart` — "Skill boosts" horizontal story strip,
  currently rendered at the top of `lib/screens/college/college_feed_screen.dart`
  (Home). **Moves to the Upskill page (`courses_explore_screen.dart`) per this prompt.**
- `lib/widgets/profile_progress_card.dart` + `lib/models/profile_readiness.dart` — the
  "Complete your profile"/"Boost your profile" card and its 4-item checklist (basic
  info, resume, **photo**, goals), currently shown on Home whenever
  `profileProgressPercent < 100`. **Removed from Home entirely per this prompt.**
- `lib/screens/shared/profile_screen.dart` — currently a single card of navigation
  rows (Edit Profile, My Resume, Saved, My Sessions, Notifications, Support). **Becomes
  sectioned info cards per this prompt.**
- `lib/screens/shared/applications_tracker_screen.dart` — application list +
  `_MomentumBanner` (added this session — "Let's boost your odds" + Upskill sheet, keep
  this, it's unrelated to the redesign).
- `lib/screens/school/courses_explore_screen.dart` — existing course-browsing screen
  (search, category chips, `ContentCard` list) — already the target of the college
  Explore/Upskill tab (`/tabs/explore` → `CoursesExploreScreen`, wired this session).
- `lib/screens/onboarding/landing_screen.dart`, `lib/screens/onboarding/
  micro_profile_screen.dart`, `lib/screens/college/goals_screen.dart` — the 3-screen
  onboarding built this session (landing/auth → prefill+manual profile → goals).
  **Resume upload needs to become a 4th step for college users, before landing on
  `/tabs`.**
- `lib/screens/college/resume_screen.dart` — already has a working, simple PDF-upload
  flow (`_pickPdf` → mock-parse → review → save). This is very close to what Naukri
  does already — **reuse this screen as the new onboarding step rather than building a
  new one.**
- `lib/screens/college/resume_builder_quiz_screen.dart` — the longer guided
  quiz-builder alternative to `resume_screen.dart`. Not part of onboarding (stays
  reachable later from Profile, per this prompt's Section 8).

## Section 1 — Job/internship card: Naukri's Apply CTA in Internshala's visual style
Edit `opportunity_row.dart`:
- Keep the thumbnail image, title, and company/type subtitle as-is (Internshala-style
  polish, already good).
- Add a persistent **footer row** to every card: "View details" (text link, tap → same
  as tapping the card today) on the left, **"Apply" pill button** on the right. Use the
  existing `PillButton` (small/secondary variant) or a compact custom pill matching the
  card's density — don't reuse the full-height `PillButton` meant for screen-bottom bars.
- Wire the card's "Apply" button to the **same apply logic** already in
  `opportunity_detail_screen.dart` (`_apply`/`_showApplyGateSheet`) plus the new
  pre-apply questions sheet (Section 2) — refactor that logic out of
  `opportunity_detail_screen.dart` into a shared function/controller (e.g.
  `lib/services/apply_flow.dart`) so the card and the detail page call the exact same
  code, not two copies that can drift.
- Decision point: keep the existing match%/deadline badge row as-is (already fixed
  this session to only alarm-color genuinely urgent deadlines) — don't remove it, just
  add the new footer row below it.

## Section 2 — Pre-apply screening questions sheet (new)
New bottom sheet, opened by tapping "Apply" from either the card or the detail page:
- Title framed like Naukri's — short, low-pressure ("Just a couple of things first").
- 2-3 screening questions, chat/conversational in tone (per user: "a bottom drawer of
  an ai chat"). Add `List<String> screeningQuestions` to `Opportunity` (mock data —
  write 2-3 plausible ones per opportunity in `mock_opportunities.dart`, e.g. "Are you
  willing to relocate?", "When can you start?").
- **Each question shows quick-answer badges/chips** (per user: "they all have like
  little answer badges/search suggest things built in") — tappable suggested-answer
  pills below the question (e.g. "Yes" / "No" / "Immediately" / "2 weeks notice"),
  matching the chat-quick-reply pattern rather than a bare text field for every
  question. Fill the exact suggestions per question in mock data too — add
  `List<String> screeningQuestionOptions` alongside (or a
  `List<(String question, List<String> options)>` pair) so each question carries its
  own tappable options, not one generic Yes/No set reused everywhere. Tapping a badge
  fills the answer (like the existing `AppChip` selection pattern already used
  throughout this app — reuse it here, don't invent a new chip widget); still allow
  typing a custom answer if none of the badges fit (small "or type your own" fallback
  underneath, consistent with `AutocompleteField`'s "typed text is always accepted"
  philosophy from this session's onboarding work).
- A "Note to recruiter (optional)" multi-line text field.
- "Send Application" button — on tap, calls the same `createApplication()` +
  success-sheet flow already wired, extended to also stash the note/answers on the
  `Application` (add `String? note` and `Map<String, String>? screeningAnswers` to
  `Application`, or skip persisting them at all for v1 if that's simpler — **decision
  point, note which you picked**, since nothing currently reads them back anywhere).
- This sheet only ever shows *after* the existing apply-gate passes (profile complete)
  — don't duplicate the gate check inside it.

## Section 3 — FOMO notification prompt
Show once, on first arrival at Home (`college_feed_screen.dart`) after onboarding
completes — not on the landing/auth screen, since our landing screen doesn't have a
signed-in user yet to compute a real "missed opportunities" number. Content: "You
missed N new [internships/jobs] this week — turn on notifications so you don't miss
the next one." N = a plausible number derived from `mockOpportunities` (e.g. count
posted in the last 7 days per `deadline`/a new `postedAt` field, or just a fixed
plausible mock number — **decision point**). CTA "Turn on" calls the real browser
`Notification.requestPermission()` (this is genuinely available on web, not purely
mocked) with a "Not now" dismiss; store a `SharedPreferences` flag so it never shows
twice. Implement as a dismissible banner card at the top of the Home feed (matches this
app's existing card idiom) rather than a native browser permission-prompt look-alike,
since faking a browser chrome prompt would be misleading UI.

## Section 4 — Job detail page hierarchy
Edit `opportunity_detail_screen.dart`:
- Add an applicant-count line near the title (e.g. "128 applied" — add
  `int applicantCount` to `Opportunity`, mock plausible numbers per posting).
- Add a **"Similar roles"** horizontal section after Requirements/Work mode and before
  "Prep for this role" — reuse `OpportunityRow` cards (or a compact variant), filtered
  by matching `category` (or `type`), excluding the current opportunity, capped at
  4-5 cards, horizontally scrollable (matches this app's existing horizontal-scroll
  pattern from `SkillStoryStrip`/`CoursesExploreScreen`'s category chips).
- Keep "Prep for this role" exactly as it is (explicit ask — don't touch it).
- Final order top-to-bottom: hero + title/company/applicant-count → meta rows → About
  the role → Requirements → Work mode → Similar roles → Prep for this role → Apply bar.

## Section 5 — Bottom tab reorder + rename
Edit `tabs_scaffold.dart` and `router.dart`:
- New order: **Home, Applications, Upskill, [renamed Sessions], Profile.**
- "Explore" → rename to **"Upskill"** — keep the same route (`/tabs/explore` →
  `CoursesExploreScreen`) and reuse the AI-sparkle-style icon Internshala uses for its
  certification-courses nav item if this codebase has an equivalent Ionicon available
  (check `flutter_vector_icons`'s Ionicons for something like `flash`/`sparkles`-
  adjacent — recall from earlier this session that literal `sparkles` doesn't exist in
  this bundled font version, `flash_outline`/`flash` was the established substitute;
  reuse that same substitution here for consistency rather than re-deciding it).
- "Sessions" needs a clearer label — **decision point**, pick one and note it: e.g.
  "Mentorship", "Bookings", or "Prep Sessions" (whichever most plainly describes what
  `SessionsScreen` actually shows — check that screen's content before naming it).
- Apply the same visual reordering technique already used this session in
  `tabs_scaffold.dart` (the `items` list's *display* order is independent of each
  route's `branchIndex` — just reorder the list, branch indices stay put).

## Section 6 — Move Skill boosts off Home
Remove `const SkillStoryStrip()` from `college_feed_screen.dart`'s ListView. Add it to
the top of `courses_explore_screen.dart` (the Upskill page), above the existing search
bar and category chips.

## Section 7 — Applications page restyle
Edit `applications_tracker_screen.dart`'s card layout to read more like Naukri's
applications list: keep the existing `StatusBadge`, tighten the card's internal spacing
and type hierarchy to match the new job-card footer style from Section 1 for visual
consistency across the app (same corner radius, same border treatment already
established this session). Keep `_MomentumBanner` (Upskill sheet) — unrelated,
already correct.

## Section 8 — Profile page → sectioned info cards
Rewrite `profile_screen.dart`: instead of one card of plain navigation rows, show
**separate cards**, each summarizing one category with its actual data inline (not
just a label), tap-to-edit:
- **Resume** card: filename/status ("Resume · PDF ready" or "No resume yet — required
  to apply"), tap → `resume_screen.dart` (now also reachable outside onboarding, same
  screen doubles as editor already per earlier session work).
- **Key skills** card: first 3-4 skills from `resume.skills` + "+N more", "+ Add
  skills" prompt if empty, tap → resume editor.
- **Basic details** card: name, city, college/course/year or class/board — compact
  summary, tap → `/profile-edit`.
- **Goals & roles** card: goal + role chips summary, tap → `/college/goals`.
- Secondary/optional items (profile photo, portfolio link) get an explicit **"+ Add
  details so recruiters know you better"** style prompt card at the bottom — matches
  Naukri's own secondary-detail nudge copy, and is the ONLY place profile photo upload
  should still be offered (see Section 12).
- Keep "My Sessions", "Notifications", "Saved", "Support & Help", and "Log out" as
  plain nav rows below the info cards — those aren't profile *data*, no need to
  card-ify them.

## Section 9 — Copywriting pass (Naukri-short, everywhere)
Go through user-facing strings app-wide and tighten to Naukri's plain, short register
— no clever/warm framing where a shorter direct sentence works. Concrete examples to
fix (not exhaustive — apply the same bar everywhere you touch copy in this pass):
- `profile_progress_card.dart` — N/A, being removed from Home (Section 12), but if any
  of its copy patterns get reused on the Profile page cards (Section 8), tighten there.
- `applications_tracker_screen.dart`'s `_MomentumBanner` subtitle ("A few haven't gone
  your way yet — that's normal. A quick mock interview or a focused course usually
  moves the needle.") → shorten, e.g. "A mock interview or a quick course usually
  helps."
- Landing screen (Section 10) headline/subhead — already short, keep as the bar for
  the rest of the app.
- Do **not** rewrite copy you don't otherwise touch in this pass "just because" — scope
  this to screens actually being edited for the other sections above, not a blanket
  find-replace across untouched files.

## Section 10 — Landing page: lead only with JTBD #1
`landing_screen.dart` already has a 2-line JTBD headline ("Find your next internship
or job" / "Real openings, matched to you.") and a stat banner. Confirm/keep it that
way — **do not** add any course/upskill mention to this screen; Upskill (JTBD #2) is
reachable only via its own tab post-onboarding, never competing for attention on the
landing screen. No other change needed here unless the stat-banner copy needs
Naukri-style tightening per Section 9's bar.

## Section 11 — Resume upload becomes an onboarding step (Naukri-simple)
Add a 4th onboarding screen for **college segment only** (school segment doesn't build
a resume, unaffected), between the existing goals screen and `/tabs`:
- Reuse `resume_screen.dart` as-is — it already has the simple "upload a PDF, get a
  mock-parsed review, save" flow, which is functionally equivalent to what Naukri does
  (upload resume, done). Change its routing: when reached as part of onboarding
  (`_postOnboarding == false`), finishing it (save or skip) should go to `/tabs`
  instead of wherever it currently lands non-onboarding users — check `_afterSave`/
  `_skipForNow` in `resume_screen.dart`, they already have `_postOnboarding` branches
  from earlier session work, just confirm the destination is `/tabs`.
- Update `goals_screen.dart`'s `_finish()` (currently routes straight to `/tabs` on
  finish, per this session's earlier "remove resume from onboarding" fix) to instead
  route to `/college/resume` for the non-`_postOnboarding` case — **this reverses that
  earlier fix's routing, on purpose, now that resume upload is short/simple/Naukri-
  style rather than the old long guided-quiz builder that originally justified pulling
  it out.** Say explicitly in your summary that you're doing this so it's not read as
  an accidental regression of that earlier work.
- Update `nav.dart`'s `routeForUser` to add the resume-upload step to the college path
  (`user.goal == null → /college/goals`, then `!hasResume → /college/resume`, then
  `/tabs`) — check `hasResume` via the existing `profile_readiness.dart` extension.

## Section 12 — Remove "Complete your profile" card from Home entirely
- Remove `ProfileProgressCard` usage from `college_feed_screen.dart` completely (not
  conditionally — never show it on Home again). Since onboarding now collects basic
  info + resume + goals (Section 11), the card's job is done before the user ever
  reaches Home for the first time.
- Remove the `photo` item from `profile_readiness.dart`'s `profileChecklist` entirely
  (drop the list entry — don't just hide it, since nothing should count photo toward
  "profile complete" anymore per the explicit ask). Recompute
  `profileCompletedCount`/`profileTotalCount`/`profileProgressPercent` naturally follow
  since they derive from the list length.
- `ProfileProgressCard` itself and the remaining 3-item checklist can still live on the
  Profile page (Section 8) for the edge case of a partial/incomplete signup (e.g. a
  returning user whose onboarding didn't fully finish) — **decision point**: keep a
  slim version there, or drop the checklist concept entirely now that onboarding is
  comprehensive. Recommendation: keep a minimal version on Profile only, since
  `verifyOtp`'s "returning" path can still resolve to an incomplete profile in edge
  cases.

## Non-goals
Skill-story quiz mechanics, the calendar "Add to Calendar" sheet, the Upskill sheet on
Applications (`_MomentumBanner`), the PDF resume *export* (different from resume
*upload*), school-segment screens (aptitude, counseling) — none of this touches those.

## After implementing
`flutter analyze` clean → `flutter build web --no-tree-shake-icons` → verify live at a
mobile viewport: job card Apply button opens the screening-questions sheet and
completes an application end-to-end; FOMO banner shows once on first Home visit and
never again after dismiss/allow; job detail page shows applicant count + similar roles
+ unchanged prep section; bottom tabs read Home/Applications/Upskill/[renamed]/Profile
in that order with Skill boosts now living on the Upskill page and gone from Home;
Applications and Profile pages render with no overflow; a fresh college signup goes
through landing → profile → goals → resume upload → Home with **no** "Complete your
profile" card anywhere on Home.

## Final step — design-system audit
Once every section above is implemented and verified, do a pass over everything
touched (new/edited screens and widgets from Sections 1-12) and check it against this
app's existing design system rather than trusting each screen's one-off choices:
- **Colors** — every color used should trace back to `lib/theme/colors.dart`
  (`AppColors.*`). Flag and fix any raw hex/`Color(0x...)` literal that snuck in
  instead of an existing token, and any new *semantic* color need (e.g. the new
  applicant-count text, quick-answer badges, FOMO banner) that doesn't cleanly map to
  an existing token — reuse the closest existing one rather than inventing a new shade.
- **Spacing** — every padding/gap should use `AppSpacing.*`, not a bare number. Check
  the new screening-questions sheet, FOMO banner, and profile cards specifically for
  spacing consistent with this session's established rhythm (tight within a field
  group, generous between distinct sections — the same fix already applied to
  `profile_edit_screen.dart` and `micro_profile_screen.dart` earlier this session via
  `FieldLabel`/section-gap conventions).
- **Typography** — every text style should come from `AppTextStyles`/`AppFontWeight`,
  not ad-hoc `fontSize`/`fontWeight` values invented per screen, unless there's already
  local precedent for a one-off size override (common in this codebase for hero
  headlines) — match the nearest existing precedent rather than picking a new number.
- **Component reuse** — the new quick-answer badges should turn out to literally be
  `AppChip`; the new job-card Apply button, FOMO banner CTA, and "Send Application"
  button should be `PillButton` with an existing `PillVariant`; new cards (profile
  sections, similar-roles) should reuse existing card conventions (`AppRadius.xl`,
  `AppColors.border` 1px border — the pattern already standardized on this session over
  the old `boxShadow`-based cards) rather than reintroducing shadows or a new corner
  radius. If the audit finds a place where a new one-off widget was built instead of
  reusing/extending an existing one (`FieldLabel`, `PrepCourseCard`,
  `AutocompleteField`, `StatusBadge`, etc.), consolidate it into the existing widget
  rather than leaving two parallel implementations.
- **Icons** — confirm every new `Ionicons.*` reference actually exists in the bundled
  `flutter_vector_icons` font version before shipping (grep the installed package's
  `ionicons.dart`, the same check already applied throughout this session — this
  project has already hit and worked around at least one icon that doesn't exist in
  this bundle, `sparkles`).
- Report what the audit found and fixed (or confirm nothing was off) as part of your
  summary — don't silently fix and skip mentioning it, and don't skip the audit even
  if everything *felt* consistent while building it screen-by-screen.
