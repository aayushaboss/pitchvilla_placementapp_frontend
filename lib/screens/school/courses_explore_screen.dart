import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../mockData/mock_courses.dart';
import '../../models/course.dart';
import '../../models/user.dart';
import '../../state/app_state.dart';
import '../../theme/breakpoints.dart';
import '../../theme/colors.dart';
import '../../theme/shadows.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../utils/no_orphan.dart';
import '../../utils/group_by_category.dart';
import '../../utils/recent_course_searches_prefs_key.dart';
import '../../utils/scroll_to_top_registry.dart';
import '../../widgets/auto_carousel.dart';
import '../../widgets/category_tab_bar.dart';
import '../../widgets/content_card.dart';
import '../../widgets/course_carousel_section.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/pill_input.dart';
import '../../widgets/responsive_body.dart';
import 'course_filter_screen.dart';

const _maxRecentCourseSearches = 5;

const _categories = ['Counseling', 'Technology', 'Design', 'Finance', 'Science', 'Placement'];

// Shown in place of Recent searches until the browser has any history, so the
// suggestion area is never empty. Every term matches a real course title or
// category (the search matches either), so a tap always lands on results.
const _popularSearches = ['Technology', 'Design', 'Finance', 'Interview', 'Resume', 'Data'];

// aptitudeResults (the real source for "Recommended for you") is only ever
// populated via the school-only /school/aptitude flow — for college this
// carousel was silently dead every time, since `clusters` was always
// empty. College has no aptitude test, but it does have `user.roles`
// (interested-roles, set at onboarding) — mapped here to the nearest
// course cluster so college gets an equivalent, if coarser, signal
// instead of just never seeing this section.
const _roleToClusterFallback = {
  'Software': 'Technology & Computer Science',
  'Data': 'Technology & Computer Science',
  'Product': 'Technology & Computer Science',
  'Research': 'Technology & Computer Science',
  'Design': 'Design & Creative',
  'Operations': 'Commerce & Finance',
  'Sales': 'Commerce & Finance',
  'Consulting': 'Commerce & Finance',
  'HR': 'Humanities & Law',
};

/// Mirrors frontend/src/screens/CoursesExplore.tsx (CoursesExplore).
/// School user's "Explore" tab — also the college "Courses" tab.
///
/// Naukri-style browse-by-topic, matching how the Home feed's job listings
/// are organized: one horizontally-scrolling carousel per category instead
/// of a single flat list gated behind a category-filter chip row. A typed
/// search still collapses to a flat ranked list, same as everywhere else a
/// search box sits above sectioned content.
class CoursesExploreScreen extends StatefulWidget {
  const CoursesExploreScreen({super.key});

  @override
  State<CoursesExploreScreen> createState() => _CoursesExploreScreenState();
}

class _CoursesExploreScreenState extends State<CoursesExploreScreen> {
  final _searchController = TextEditingController();
  // Lets a typed search be saved to Recent searches when the user simply taps
  // away - most people on a phone never press the keyboard's Done key, and
  // history used to be saved only on that key.
  final _searchFocus = FocusNode();
  final _scrollController = ScrollController();
  // This screen is mounted at branch 1 for school (Browse tab) and branch 3
  // for college (Courses tab) — see BrowseTabScreen/TabsScaffold, which pick
  // the same branch index the same way. Remembered so dispose() unregisters
  // the exact branch this instance registered, not whichever segment the
  // user happens to be on by the time dispose runs.
  int? _registeredBranchIndex;

  CourseFilterSelection _filter = const CourseFilterSelection();
  List<String> _recentSearches = [];
  // Desktop-only tabs+grid state (see _desktopCourseTabsGrid) — mobile/
  // tablet never read this, so it can't affect the carousel-stack view.
  String? _selectedCourseTab;

  Future<void> _openFilter() async {
    final result = await context.push<CourseFilterSelection>('/school/course-filter', extra: _filter);
    if (result != null) setState(() => _filter = result);
  }

  // Mirrors search_screen.dart's own recent-searches mechanism exactly —
  // same load/save/cap-at-5/dedupe shape, just against this screen's own
  // prefs key since Courses previously had no recent-searches at all.
  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _recentSearches = prefs.getStringList(recentCourseSearchesPrefsKey) ?? []);
  }

  Future<void> _saveRecentSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final updated = [trimmed, ..._recentSearches.where((s) => s.toLowerCase() != trimmed.toLowerCase())].take(_maxRecentCourseSearches).toList();
    await prefs.setStringList(recentCourseSearchesPrefsKey, updated);
    if (!mounted) return;
    setState(() => _recentSearches = updated);
  }

  Future<void> _clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(recentCourseSearchesPrefsKey);
    if (!mounted) return;
    setState(() => _recentSearches = []);
  }

  void _selectSearch(String query) {
    setState(() {
      _searchController.text = query;
      _searchController.selection = TextSelection.collapsed(offset: query.length);
    });
    _saveRecentSearch(query);
  }

  @override
  void initState() {
    super.initState();
    final isSchool = context.read<AppState>().user?.segment == Segment.school;
    _registeredBranchIndex = isSchool ? 1 : 3;
    ScrollToTopRegistry.register(_registeredBranchIndex!, () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
    _loadRecentSearches();
    _searchFocus.addListener(() {
      if (!_searchFocus.hasFocus) _saveRecentSearch(_searchController.text);
    });
  }

  @override
  void dispose() {
    if (_registeredBranchIndex != null) ScrollToTopRegistry.unregister(_registeredBranchIndex!);
    _searchController.dispose();
    _searchFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // The title, credibility carousel, and search+filter row used to be
  // fixed siblings above the results — outside any scrollable, they never
  // moved no matter how far the results below were scrolled. Folded into
  // the same ListView as the results instead (as leading items), mirroring
  // how college_feed_screen.dart/school_home_screen.dart already solved
  // this identical problem: "they're just the first few items of the one
  // scrollable list, so they scroll away with everything else." No new
  // scroll-direction-tracking code needed — scrolling back up naturally
  // brings them back the same way it brings back any earlier list content.
  List<Widget> _headerItems(double topInset, bool isFiltering, bool isSchool, bool isTablet) => [
        Padding(
          // isTablet adds AppSpacing.xl on top — sits directly under
          // TopNavBar's 64px bar with nothing else providing clearance.
          padding: EdgeInsets.fromLTRB(AppSpacing.xl, topInset + AppSpacing.sm + (isTablet ? AppSpacing.xl : 0), AppSpacing.xl, 0),
          child: Text('Courses', textAlign: TextAlign.left, style: AppTextStyles.h1.copyWith(color: AppColors.ink)),
        ),
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.md),
          child: AutoCarousel(
            // Same size and cadence as Home's promo cards (college_feed_screen.dart)
            // so these trust cards read as part of the same family.
            height: 112,
            interval: const Duration(seconds: 8),
            // "NEP 2020" (the National Education Policy) reads as K-12
            // curriculum framing — fine for a school-stage audience, but
            // this screen is shared with college/placement-stage students
            // who saw the exact same badge unchanged. College gets a
            // placement-relevant equivalent instead.
            cards: isSchool
                ? const [
                    _CredibilityCard(
                      icon: Ionicons.school,
                      title: 'NEP 2020 Aligned',
                      caption: 'Courses mapped to the National Education Policy 2020.',
                    ),
                    _CredibilityCard(
                      icon: Ionicons.ribbon,
                      title: 'Skill India Certified',
                      caption: "Content aligned with Skill India's competency framework.",
                    ),
                    _CredibilityCard(
                      icon: Ionicons.shield_checkmark,
                      title: 'NSDC Approved',
                      caption: 'Backed by the National Skill Development Corporation.',
                    ),
                  ]
                : const [
                    _CredibilityCard(
                      icon: Ionicons.ribbon,
                      title: 'Industry-recognized certification',
                      caption: 'Certificates recruiters actually look for.',
                    ),
                    _CredibilityCard(
                      icon: Ionicons.shield_checkmark,
                      title: 'Skill India Certified',
                      caption: "Content aligned with Skill India's competency framework.",
                    ),
                    _CredibilityCard(
                      icon: Ionicons.briefcase,
                      title: 'Built for placement season',
                      caption: 'Interview, resume, and aptitude prep included.',
                    ),
                  ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: PillInput(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  placeholder: 'Search courses',
                  onChanged: (_) => setState(() {}),
                  onSubmitted: _saveRecentSearch,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              GestureDetector(
                onTap: _openFilter,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      // Plain circle, no border, offWhite fill in both states —
                      // matches every other standalone icon-only button in the
                      // app (header search/bell, the opportunity-detail
                      // bookmark/chat buttons). "Active" is signaled the same
                      // way the bookmark button does it — swap to the filled
                      // glyph + ink tint — rather than inverting the whole
                      // button's fill, which no other icon button here does.
                      decoration: const BoxDecoration(color: AppColors.offWhite, shape: BoxShape.circle),
                      child: Icon(
                        isFiltering ? Ionicons.options : Ionicons.options_outline,
                        size: 20,
                        color: AppColors.ink,
                      ),
                    ),
                    // Same permanent brand dot as Home's filter icon — a
                    // standing reminder that Courses is scoped to the
                    // user's own picks, not a one-time nudge. (11, 12), not
                    // Home's (9, 10): this button is 44px, not 40px — see
                    // home_header.dart's own note that (11, 12) was this
                    // exact ratio's value before that icon shrank to 40px.
                    Positioned(
                      top: 11,
                      right: 12,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: AppColors.brand,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.offWhite, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ];

  Widget _resultCard(Course c) {
    return ContentCard(
      icon: categoryIcons[c.category],
      tag: c.category,
      title: c.title,
      meta: [c.duration, '${c.modules} modules'],
      linkLabel: 'View syllabus',
      onTap: () {
        // Opening a result is the clearest signal the search was useful.
        _saveRecentSearch(_searchController.text);
        context.push('/course/${c.id}');
      },
    );
  }

  // 1-column or 2-column-at-tablet-width rendering for one list of cards —
  // shared between the flat (ungrouped) case and each category group below,
  // so both lay out identically.
  List<Widget> _cardsFor(List<Course> items, int columns) {
    if (columns == 1) {
      return items.map((c) => Padding(padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.lg), child: _resultCard(c))).toList();
    }
    return [
      for (var row = 0; row < (items.length / columns).ceil(); row++)
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.lg),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < columns; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.md),
                  Expanded(child: row * columns + i < items.length ? _resultCard(items[row * columns + i]) : const SizedBox()),
                ],
              ],
            ),
          ),
        ),
    ];
  }

  Widget _categoryHeading(String category, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.sm),
      child: Text('$category ($count)', style: AppTextStyles.body.copyWith(color: AppColors.ink, fontWeight: AppFontWeight.bold, fontSize: 16)),
    );
  }

  // Groups by category (in the exact order the categories were selected in
  // the filter, matching what the picker itself shows) whenever more than
  // one is active — an active multi-category filter is exactly the case
  // that used to interleave, e.g., Technology/Design/Science cards with no
  // way to browse just one category's cards in one continuous run. A single
  // category, or none, renders flat as before — a one-item group heading
  // would be redundant noise.
  List<Widget> _resultWidgets(List<Course> results, int columns) {
    if (_filter.categories.length > 1) {
      final grouped = groupByCategory<Course>(results, (c) => c.category, order: _filter.categories);
      return [
        for (final entry in grouped.entries) ...[
          _categoryHeading(entry.key, entry.value.length),
          ..._cardsFor(entry.value, columns),
        ],
      ];
    }
    return _cardsFor(results, columns);
  }

  // Desktop-only replacement for the carousel-per-category stack below —
  // same real category list + real per-category counts (filterCourses is
  // the exact function each carousel already used), just tabs + one shared
  // grid instead of separate horizontal lanes. Mobile/tablet never call
  // this — the carousel stack is completely unchanged for them.
  Widget _desktopCourseTabsGrid(BuildContext context, List<Course> recommended) {
    final topics = <(String key, String label, List<Course> items)>[
      if (recommended.isNotEmpty) ('recommended', 'Recommended for you', recommended),
      for (final category in _categories) (category, category, filterCourses(category)),
    ].where((t) => t.$3.isNotEmpty).toList();
    if (topics.isEmpty) return const SizedBox.shrink();
    final selectedKey = topics.any((t) => t.$1 == _selectedCourseTab) ? _selectedCourseTab! : topics.first.$1;
    final selected = topics.firstWhere((t) => t.$1 == selectedKey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 0),
          child: CategoryTabBar(
            tabs: [for (final t in topics) CategoryTab(key: t.$1, label: t.$2, count: t.$3.length)],
            selected: selectedKey,
            onSelected: (key) => setState(() => _selectedCourseTab = key),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.lg),
          // 2 columns — matches Applications' own card grid, per direct
          // feedback that its layout should be the reference for this one
          // too, now that ContentCard's title truncates at 1 line the same
          // way _ApplicationCard's does instead of wrapping awkwardly.
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _cardsFor(selected.$3, 2)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final query = _searchController.text.trim().toLowerCase();
    final isSearching = query.isNotEmpty;

    final user = context.watch<AppState>().user;
    final isSchool = user?.segment == Segment.school;
    final aptitudeClusters = user?.aptitudeResults?.matches.map((m) => m.cluster).toList() ?? const <String>[];
    // College fallback — see _roleToClusterFallback's own comment.
    final roleClusters = (user?.roles ?? const <String>[]).map((r) => _roleToClusterFallback[r]).whereType<String>().toSet().toList();
    final clusters = aptitudeClusters.isNotEmpty ? aptitudeClusters : roleClusters;
    final recommended = clusters.isNotEmpty ? recommendedCourses(clusters) : const <Course>[];

    final isFiltering = !_filter.isEmpty;
    // Search and the active filter now combine (AND) instead of being
    // mutually exclusive modes — filterCoursesAdvanced already supports a
    // query alongside its facets (Round V), so both narrow the same result
    // set together.
    final hasQuery = isSearching || isFiltering;
    final results = hasQuery
        ? filterCoursesAdvanced(categories: _filter.categories, durationBuckets: _filter.durationBuckets, query: isSearching ? query : null)
        : const <Course>[];
    final width = MediaQuery.sizeOf(context).width;
    final isTablet = AppBreakpoints.of(context) == AppBreakpoint.tablet;
    // 2 at desktop — matches Applications' own card grid (see
    // _desktopCourseTabsGrid's identical comment above).
    final columns = width >= AppBreakpoints.tablet ? 2 : (width >= AppBreakpoints.tablet ? 2 : 1);

    String emptyMessage() {
      if (isSearching && isFiltering) return 'No courses match "$query" with these filters.';
      if (isSearching) return 'No courses match "$query".';
      return 'No courses match these filters.';
    }

    // Every state below renders as exactly one ListView — the previous
    // isFiltering branch used to nest a second, independently-scrolling
    // ListView inside a fixed "N courses found" row; that's flattened here
    // too, so there's never more than one scrollable region on this screen.
    late final List<Widget> bodyItems;
    if (hasQuery) {
      bodyItems = [
        ..._headerItems(topInset, isFiltering, isSchool, isTablet),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.sm),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${results.length} ${results.length == 1 ? 'course' : 'courses'} found',
                  style: AppTextStyles.body.copyWith(color: AppColors.gray500, fontSize: 12, fontWeight: AppFontWeight.medium),
                ),
              ),
              if (isSearching)
                GestureDetector(
                  onTap: () => setState(_searchController.clear),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.xs),
                    child: Text('Clear search', style: AppTextStyles.body.copyWith(color: AppColors.ink, fontSize: 12, fontWeight: AppFontWeight.semibold)),
                  ),
                ),
              if (isFiltering)
                GestureDetector(
                  onTap: () => setState(() => _filter = const CourseFilterSelection()),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.xs),
                    child: Text('Clear filters', style: AppTextStyles.body.copyWith(color: AppColors.ink, fontSize: 12, fontWeight: AppFontWeight.semibold)),
                  ),
                ),
            ],
          ),
        ),
        if (results.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl).copyWith(top: AppSpacing.xxxl),
            child: EmptyState(icon: Ionicons.search_outline, title: 'No courses found', subtitle: emptyMessage()),
          )
        else
          ..._resultWidgets(results, columns),
      ];
    } else {
      final recentSearchWidgets = [
        // Recent searches — same "quick re-run a past search" convenience
        // the opportunity Search screen already offers, only shown once
        // there's actually something to show and before any query/filter
        // is active.
        if (_recentSearches.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent searches', style: AppTextStyles.body.copyWith(color: AppColors.ink, fontWeight: AppFontWeight.bold, fontSize: 16)),
                GestureDetector(
                  onTap: _clearRecentSearches,
                  child: Text('Clear', style: AppTextStyles.caption.copyWith(color: AppColors.ink, fontSize: 12, fontWeight: AppFontWeight.semibold)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _recentSearches.map((s) => _RecentSearchChip(label: s, onTap: () => _selectSearch(s))).toList(),
            ),
          ),
        ] else ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.md),
            child: Text('Popular searches', style: AppTextStyles.body.copyWith(color: AppColors.ink, fontWeight: AppFontWeight.bold, fontSize: 16)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _popularSearches.map((s) => _RecentSearchChip(label: s, onTap: () => _selectSearch(s))).toList(),
            ),
          ),
        ],
      ];
      if (isTablet) {
        bodyItems = [
          ..._headerItems(topInset, isFiltering, isSchool, isTablet),
          ...recentSearchWidgets,
          // Desktop-only: category tabs + one shared grid, replacing the
          // carousel-per-category stack below. Mobile/tablet never reach
          // this branch.
          _desktopCourseTabsGrid(context, recommended),
        ];
      } else {
        final carousels = [
          if (recommended.isNotEmpty) CourseCarouselSection(title: 'Recommended for you', courses: recommended),
          for (final category in _categories) CourseCarouselSection(title: category, courses: filterCourses(category)),
        ];
        bodyItems = [
          ..._headerItems(topInset, isFiltering, isSchool, isTablet),
          ...recentSearchWidgets,
          // No manual inter-carousel gap needed — CarouselSectionHeading
          // already supplies a divider + AppSpacing.xl clearance above each
          // one, including the first.
          ...carousels,
        ];
      }
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: ResponsiveBody(maxWidth: isTablet ? 1224 : (hasQuery ? 720 : AppBreakpoints.maxContentWidth), child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
        children: bodyItems,
      )),
    );
  }
}

/// Plain tappable chip for a past Courses search — same visual language as
/// search_screen.dart's own `_SearchChip`, kept as a separate small widget
/// here rather than importing that screen's private class.
class _RecentSearchChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _RecentSearchChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(color: AppColors.offWhite, borderRadius: BorderRadius.circular(AppRadius.pill)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Ionicons.time_outline, size: 14, color: AppColors.gray500),
            const SizedBox(width: AppSpacing.sm),
            Text(label, style: AppTextStyles.body.copyWith(color: AppColors.ink, fontSize: 12, fontWeight: AppFontWeight.medium)),
          ],
        ),
      ),
    );
  }
}

/// One trust-badge card in the credibility carousel above the search bar.
/// Deliberately the same design as Home's promo cards ("Get recruiters to
/// notice you"): solid brand fill, bold ink title, softer ink caption, and a
/// large filled glyph on the right. Not tappable — a claim like "NEP 2020
/// Aligned" has nowhere to navigate.
class _CredibilityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String caption;
  const _CredibilityCard({required this.icon, required this.title, required this.caption});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(color: AppColors.brand, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: AppShadows.card),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  noOrphan(title),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h3.copyWith(color: AppColors.ink, fontSize: 16, fontWeight: AppFontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    noOrphan(caption),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(color: AppColors.inkA70, fontSize: 12, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, size: 32, color: AppColors.ink),
        ],
      ),
    );
  }
}

