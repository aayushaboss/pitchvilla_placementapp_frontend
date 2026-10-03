import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../mockData/course_fields.dart';
import '../../mockData/mock_profile_options.dart';
import '../../mockData/related_roles.dart';
import '../../models/user.dart';
import '../../state/app_state.dart';
import '../../theme/breakpoints.dart';
import '../../theme/colors.dart';
import '../../theme/shadows.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../utils/no_orphan.dart';
import '../../widgets/app_chip.dart';
import '../../widgets/back_chevron.dart';
import '../../widgets/pill_button.dart';
import '../../widgets/pill_input.dart';
import '../../widgets/responsive_body.dart';

class _GoalOption {
  final String key;
  final String title;
  final String sub;
  final IconData icon;
  const _GoalOption({required this.key, required this.title, required this.sub, required this.icon});
}

// Single words only, on purpose — three equal-width cards leaves each
// title/subtitle very little horizontal room, and a multi-word phrase
// ("Start your career") almost always wraps to an orphaned single word on
// its own line. One word each guarantees it never happens, regardless of
// screen width.
const _goals = [
  _GoalOption(key: 'internship', title: 'Internship', sub: 'Learn', icon: Ionicons.book_outline),
  _GoalOption(key: 'job', title: 'Full-time', sub: 'Grow', icon: Ionicons.briefcase_outline),
  _GoalOption(key: 'both', title: 'Both', sub: 'Flexible', icon: Ionicons.layers_outline),
];

/// Equal cards: reserve 2 lines for title + subtitle at full type size (no scale-down).
const _goalTitleHeight = 14.0 * 1.25 * 2;
const _goalSubHeight = 13.0 * 1.3 * 2;
const _goalCardHeight = AppSpacing.lg * 2 +
    44 +
    AppSpacing.sm +
    _goalTitleHeight +
    AppSpacing.xs +
    _goalSubHeight;

/// Mirrors frontend/app/college/goals.tsx (Goals).
class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  String _goal = '';
  List<String> _selectedRoles = [];
  final _searchController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    final user = appState.user;
    // Only default on first-time onboarding — a post-onboarding revisit to
    // edit goals should never silently override a choice the user already
    // made and saved. Previously this screen didn't hydrate _goal/roles
    // from the saved user at all on that path, leaving both blank — which
    // meant tapping Continue/Save without touching anything would silently
    // overwrite a real saved goal/roles with an empty one. Hydrate instead.
    if (user?.onboardingComplete == true) {
      _goal = user?.goal ?? '';
      _selectedRoles = List.of(user?.roles ?? const <String>[]);
      return;
    }
    // Postgrads are more often job-hunting than internship-hunting, and
    // vice versa for undergrads — a reasonable starting point, not a
    // restriction; still a single tap to change either way.
    final segment = user?.segment;
    if (segment == Segment.pg) {
      _goal = 'job';
    } else if (segment == Segment.ug) {
      _goal = 'internship';
    }
    // Pre-select roles matching the course/field they just entered on the
    // previous screen — turns this from a cold "pick from scratch" chip
    // list into "confirm or adjust," using data the flow already
    // collected one screen earlier rather than asking again. Only a
    // starting point (still a single tap each to remove/add), and only
    // for first-time onboarding — same reasoning as the goal default
    // above, a post-onboarding edit should never override a choice
    // someone already made and saved.
    final suggested = rolesByField[courseFieldFor(user?.course)];
    if (suggested != null && suggested.isNotEmpty) {
      _selectedRoles = suggested.take(2).toList();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleRole(String r) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedRoles = _selectedRoles.contains(r)
          ? _selectedRoles.where((x) => x != r).toList()
          : [..._selectedRoles, r];
    });
  }

  bool get _valid => _goal.isNotEmpty && _selectedRoles.isNotEmpty;

  bool get _postOnboarding => context.read<AppState>().user?.onboardingComplete == true;

  Future<void> _finish() async {
    if (!_valid) return;
    setState(() => _loading = true);
    try {
      final appState = context.read<AppState>();
      final wasPostOnboarding = _postOnboarding;
      // TODO: replace with real API call (local mock)
      await appState.updateProfile((current) => current.copyWith(
            goal: _goal,
            roles: _selectedRoles,
            // Goals is now the true last onboarding step — resume-building
            // (and, before that, career preferences) both used to sit
            // between here and Home; both are optional Profile-tab
            // sections now instead of forced onboarding steps. Only set
            // here, not unconditionally, so a post-onboarding edit (Profile
            // → "Goals & roles") can't accidentally re-flip an
            // already-true flag — it's already true by then regardless.
            onboardingComplete: wasPostOnboarding ? null : true,
          ));
      if (!mounted) return;
      if (wasPostOnboarding) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/tabs');
        }
      } else {
        // Goals is the true last onboarding step for this segment — see
        // onboarding_complete_screen.dart for why this doesn't go
        // straight to /tabs any more.
        context.go('/onboarding/complete');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final isTablet = AppBreakpoints.of(context) == AppBreakpoint.tablet;
    final course = context.watch<AppState>().user?.course;
    final suggestedRoles = rolesByField[courseFieldFor(course)] ?? mockAllRoles;
    final query = _searchController.text.trim().toLowerCase();
    // Each pick pulls in its related roles too, so the list grows with
    // relevant suggestions instead of staying static after the first tap.
    final relatedToSelected = _selectedRoles.expand((r) => relatedRoles[r] ?? const <String>[]);
    // Default view stays scoped to the student's field so it doesn't feel
    // like a generic checklist; searching (or an already-picked role from
    // outside that set) opens it back up to everything.
    final filtered = query.isEmpty
        ? {...suggestedRoles, ..._selectedRoles, ...relatedToSelected}.toList()
        : mockAllRoles.where((r) => r.toLowerCase().contains(query)).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: ResponsiveBody(maxWidth: isTablet ? 1224 : AppBreakpoints.maxContentWidth, child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(AppSpacing.xl, topInset + AppSpacing.lg, AppSpacing.xl, AppSpacing.xl),
                children: [
                  BackChevron(color: AppColors.ink, fallbackRoute: _postOnboarding ? '/tabs' : '/onboarding/profile'),
                  // No "STEP 2 OF 2" label here any more — it undercounted
                  // the real flow (Login/OTP/Profile already happened by
                  // the time someone reaches this screen), which read as
                  // either a bug or a bait-and-switch. Nothing else in the
                  // flow has a comparable global step count to be
                  // consistent with, so removing it beats a misleading one.
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.lg),
                    child: Text(
                      'What are you\nlooking for?',
                      style: AppTextStyles.h1.copyWith(color: AppColors.ink),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    child: Text(
                      noOrphan("We'll curate opportunities just for you."),
                      style: AppTextStyles.bodyLg.copyWith(color: AppColors.gray500),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xl),
                    child: Row(
                      children: _goals.map((g) {
                        final selected = _goal == g.key;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: g == _goals.last ? 0 : AppSpacing.md),
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                setState(() => _goal = g.key);
                              },
                              child: SizedBox(
                                height: _goalCardHeight,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.lg),
                                  decoration: BoxDecoration(
                                    color: selected ? AppColors.white : AppColors.offWhite,
                                    borderRadius: BorderRadius.circular(AppRadius.xl),
                                    border: Border.all(
                                      color: selected ? AppColors.brand : Colors.transparent,
                                      width: 2,
                                    ),
                                    boxShadow: selected ? null : AppShadows.soft,
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(color: selected ? AppColors.offWhite : AppColors.white, shape: BoxShape.circle),
                                        child: Icon(g.icon, size: 20, color: selected ? AppColors.ink : AppColors.gray500),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                                        child: SizedBox(
                                          height: _goalTitleHeight,
                                          width: double.infinity,
                                          child: Text(
                                            g.title,
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTextStyles.body.copyWith(
                                              color: AppColors.ink,
                                              fontWeight: selected ? AppFontWeight.semibold : AppFontWeight.medium,
                                              height: 1.25,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                                        child: SizedBox(
                                          height: _goalSubHeight,
                                          width: double.infinity,
                                          child: Text(
                                            g.sub,
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTextStyles.label.copyWith(
                                              color: selected ? AppColors.gray500 : AppColors.gray400,
                                              fontWeight: AppFontWeight.medium,
                                              height: 1.3,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.xs),
                    child: Text(
                      'Interested roles / industries',
                      style: AppTextStyles.bodyLg.copyWith(color: AppColors.ink, fontWeight: AppFontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Text(
                      query.isEmpty ? 'Picked to match your degree — search for more.' : 'Showing all matches for "$query".',
                      style: AppTextStyles.caption.copyWith(color: AppColors.gray500),
                    ),
                  ),
                  // Suggestions render above the search field, not below —
                  // below, the keyboard covers them the moment the field is
                  // focused (same fix as AutocompleteField for college/
                  // course: the thing you're picking from has to stay in
                  // view while the keyboard is up).
                  Wrap(
                    alignment: WrapAlignment.start,
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: filtered
                        .map(
                          (r) => AppChip(
                            label: r,
                            selected: _selectedRoles.contains(r),
                            showCheck: true,
                            onPressed: () => _toggleRole(r),
                          ),
                        )
                        .toList(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    child: PillInput(
                      controller: _searchController,
                      placeholder: 'Search roles…',
                      icon: Ionicons.search_outline,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, bottomInset + AppSpacing.md),
              decoration: const BoxDecoration(color: AppColors.white, border: Border(top: BorderSide(color: AppColors.border, width: 1))),
              child: PillButton(label: _postOnboarding ? 'Save' : 'Continue', onPressed: _finish, loading: _loading, disabled: !_valid),
            ),
          ],
        )),
      ),
    );
  }
}
