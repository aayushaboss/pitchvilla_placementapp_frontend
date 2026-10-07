import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/repositories.dart';
import '../../models/opportunity.dart';
import '../../models/opportunity_match.dart';
import '../../models/user.dart';
import '../../services/apply_flow.dart';
import '../../state/app_state.dart';
import '../../theme/breakpoints.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/back_chevron.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/opportunity_meta.dart';
import '../../widgets/opportunity_row.dart';
import '../../widgets/responsive_body.dart';

/// The "View all" destination for a single carousel section on the browse
/// feed — same flat vertical list the feed used before it was split into
/// topics, just scoped to one category (or, with [category] null, sorted
/// purely by match — the "based on your profile" section's full list).
class OpportunityListScreen extends StatefulWidget {
  final String title;
  final String? category;

  /// Explicit opportunity IDs, in order — how a notification like "3 new
  /// internships match your goals" opens this screen scoped to exactly the
  /// roles it promised, instead of the generic profile-matched feed
  /// ([category] null) or a whole category. Takes priority over [category]
  /// when both are set.
  final List<String>? ids;

  /// Free-text search — the Home search bar's destination. Matches title /
  /// company / category / location via [filterOpportunities]. Takes priority
  /// over [category] when both are set (but not over [ids]).
  final String? query;

  const OpportunityListScreen({super.key, required this.title, this.category, this.ids, this.query});

  @override
  State<OpportunityListScreen> createState() => _OpportunityListScreenState();
}

class _OpportunityListScreenState extends State<OpportunityListScreen> {
  // Already-applied openings stay in the list with a disabled "Applied ✓"
  // button rather than being filtered out. Loaded once per screen visit —
  // if the signed-in user's roles/resume change while this screen is still
  // open, the match-score sort below won't re-run until it's reopened;
  // an acceptable tradeoff for this pass (see AsyncValueView's own note on
  // not re-running its loader reactively).
  Future<List<Opportunity>> _load(User? user) async {
    final repo = context.read<Repositories>().opportunities;
    if (widget.ids != null) {
      return widget.ids!.map(repo.getOpportunityById).whereType<Opportunity>().toList();
    }
    final hasQuery = widget.query != null && widget.query!.trim().isNotEmpty;
    final results = await repo.listOpportunities(
      query: hasQuery ? widget.query : null,
      categories: (hasQuery || widget.category == null) ? null : [widget.category!],
    );
    results.sort((a, b) => b.matchScoreFor(user).compareTo(a.matchScoreFor(user)));
    return results;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.user;
    final hasQuery = widget.query != null && widget.query!.trim().isNotEmpty;

    // 2 columns from tablet width up — a plain wider single-column cap (the
    // ResponsiveBody default) would just leave a card stretched thin down
    // the middle of the screen instead of actually using the extra room.
    final isTablet = AppBreakpoints.of(context) == AppBreakpoint.tablet;
    final columns = MediaQuery.sizeOf(context).width >= AppBreakpoints.tablet ? 2 : 1;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: ResponsiveBody(maxWidth: isTablet ? 1200 : 720, child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
              child: Row(
                children: [
                  BackChevron(color: AppColors.ink, fallbackRoute: '/tabs'),
                  Expanded(
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyLg.copyWith(color: AppColors.ink, fontWeight: AppFontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xxl),
                ],
              ),
            ),
            Expanded(
              child: AsyncValueView<List<Opportunity>>(
                loader: () => _load(user),
                isEmpty: (results) => results.isEmpty,
                emptyBuilder: (context) => Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: EmptyState(
                      icon: hasQuery ? Ionicons.search_outline : Ionicons.briefcase_outline,
                      title: hasQuery ? 'No matches found' : 'No openings here right now',
                      subtitle: hasQuery
                          ? 'Try a different search term.'
                          : 'Check back soon — new opportunities are added regularly.',
                    ),
                  ),
                ),
                builder: (context, results) => ListView.separated(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xxxl),
                      // One row per `columns` cards, not one row per card —
                      // OpportunityRow sizes to its own content height
                      // (mainAxisSize.min), so a fixed-extent GridView risked
                      // either clipping the taller cards or leaving visible
                      // gaps under the shorter ones. A Row of Expanded cards
                      // just takes each row's natural tallest height instead.
                      itemCount: (results.length / columns).ceil(),
                      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
                      itemBuilder: (context, rowIndex) {
                        final start = rowIndex * columns;
                        final rowItems = results.skip(start).take(columns).toList();
                        Widget cardFor(Opportunity o) => OpportunityRow(
                              tag: o.type,
                              title: o.title,
                              subtitle: o.company,
                              meta: opportunityMeta(o),
                              matchLabel: o.matchLabelFor(user),
                              deadlineLabel: o.deadlineLabel,
                              deadlineUrgent: o.deadlineIsUrgent,
                              saved: appState.isOpportunitySaved(o.id),
                              applied: context.read<Repositories>().applications.isOpportunityApplied(o.id),
                              onToggleSave: () => appState.toggleSavedOpportunity(o.id),
                              onTap: () => context.push('/opportunity/${o.id}'),
                              onApply: () => startApplyFlow(context, o, onApplied: () => setState(() {})),
                            );
                        if (columns == 1) return cardFor(rowItems.first);
                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (var i = 0; i < columns; i++) ...[
                                if (i > 0) const SizedBox(width: AppSpacing.lg),
                                Expanded(child: i < rowItems.length ? cardFor(rowItems[i]) : const SizedBox()),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
              ),
            ),
            // Only for the notification-scoped case: this screen is a dead
            // end otherwise (it's a push, not a tab), so a direct way back
            // to the feed matters more here than on the category views,
            // which the tab bar and back-chevron already cover well.
            if (widget.ids != null)
              Padding(
                padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, MediaQuery.of(context).padding.bottom + AppSpacing.md),
                child: Center(
                  child: GestureDetector(
                    onTap: () => context.go('/tabs'),
                    child: Text(
                      'Back to home',
                      style: AppTextStyles.body.copyWith(color: AppColors.ink, fontSize: 14, fontWeight: AppFontWeight.semibold),
                    ),
                  ),
                ),
              ),
          ],
        ),
      )),
    );
  }
}
