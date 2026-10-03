import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../mockData/career_dna/career_dna_level_meta.dart';
import '../../../models/career_dna.dart';
import '../../../models/user.dart';
import '../../../state/app_state.dart';
import '../../../theme/breakpoints.dart';
import '../../../theme/colors.dart';
import '../../../theme/shadows.dart';
import '../../../theme/spacing.dart';
import '../../../theme/text_styles.dart';
import '../../../utils/no_orphan.dart';
import '../../../utils/scroll_to_top_registry.dart';
import '../../../widgets/responsive_body.dart';

// Alternating horizontal position per node (center/right/center-left/left/
// center-right) — the zigzag is what reads as "a path to walk," per the
// Duolingo-style reference, without needing a literal drawn connector line.
const _pathXAlign = [0.0, 0.55, -0.2, -0.55, 0.2];

/// Landing / level-map screen — the tab root for the 6th branch
/// (`/tabs/career-dna`). A Duolingo-style path: a header banner naming only
/// the ONE level currently being worked on (not a repeated list of every
/// level's own title), then a vertical zigzag of 5 circular nodes standing
/// in for the old flat list of level cards.
class CareerDnaLandingScreen extends StatefulWidget {
  const CareerDnaLandingScreen({super.key});

  @override
  State<CareerDnaLandingScreen> createState() => _CareerDnaLandingScreenState();
}

class _CareerDnaLandingScreenState extends State<CareerDnaLandingScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Branch index 5 (Career Quiz) — see router.dart's StatefulShellRoute.
    ScrollToTopRegistry.register(5, () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() {
    ScrollToTopRegistry.unregister(5);
    _scrollController.dispose();
    super.dispose();
  }

  void _openLevel(BuildContext context, int level, bool unlocked, bool completed) {
    if (!unlocked) {
      HapticFeedback.selectionClick();
      return;
    }
    HapticFeedback.selectionClick();
    // A completed level's node opens straight to its report — routing
    // through the intro screen again would only ever offer "Start Level N"
    // there, reading as an invitation to retake it rather than review what
    // was already earned. (A genuine retake is still one tap away from the
    // report screen itself.) Level 5 is the one exception — its result is
    // a cross-test synthesis, not a per-level report, so it has its own
    // dedicated final-report screen instead of the generic /report route.
    if (completed && level == 5) {
      context.push('/college/career-dna/final-report');
      return;
    }
    context.push(completed ? '/college/career-dna/level/$level/report' : '/college/career-dna/level/$level/intro');
  }

  bool _isLevelComplete(CareerDnaProfile p, int level) {
    switch (level) {
      case 1:
        return p.level1 != null;
      case 2:
        return p.level2 != null;
      case 3:
        return p.level3 != null;
      case 4:
        return p.level4 != null;
      case 5:
        return p.level5 != null;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().user;

    // This whole feature is college-only. The tab is already hidden for a
    // school account (tabs_scaffold.dart), but nothing else stops a stale
    // deep link from reaching this route directly — bounce back to Home
    // rather than rendering a screen built for a segment that has no
    // Career DNA data at all.
    if (user?.segment == Segment.school) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/tabs');
      });
      return const SizedBox.shrink();
    }

    final profile = user?.careerDnaOrEmpty ?? const CareerDnaProfile();
    final topInset = MediaQuery.of(context).padding.top;
    final allComplete = profile.allLevelsComplete;
    // The one level the header banner names — the first not-yet-completed
    // one (which, by sequential unlocking, is always the unlocked one to
    // work on next). Mirrors Duolingo's own "just the current unit" header,
    // rather than repeating every level's full title on screen at once.
    final currentMeta = allComplete ? null : careerDnaLevelMeta.firstWhere((m) => !_isLevelComplete(profile, m.level));
    // A modest widen only, not the 1200/900 other tabs got — this screen's
    // content is one linear zigzag path (see _pathXAlign above), not
    // independent listings, so there's nothing to tab or grid here; this
    // just stops it sitting razor-thin in a sea of white space at desktop.
    final isTablet = AppBreakpoints.of(context) == AppBreakpoint.tablet;

    return Scaffold(
      backgroundColor: AppColors.white,
      // A single ListView, not a fixed header + separately-scrolling
      // Expanded below it — per direct feedback reversing an earlier
      // "keep the header pinned" decision, which left too little room for
      // the path once TopNavBar also started taking space above it at
      // desktop. The header is still deliberately NOT wrapped in
      // ResponsiveBody (same full-bleed pattern as profile_screen.dart's
      // header) so it spans true full width regardless of window size; the
      // path content right below it gets its own ResponsiveBody cap
      // instead, same as before.
      body: ListView(
        controller: _scrollController,
        padding: EdgeInsets.zero,
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
            ),
            // Only the background bleeds full-bleed — the text inside stays
            // aligned to the exact same horizontal padding as the content
            // below it (same ResponsiveBody maxWidth), so it doesn't read
            // as pinned to the true screen edge while everything else sits
            // inset in a narrower centered column.
            child: ResponsiveBody(
              maxWidth: isTablet ? 1224 : AppBreakpoints.maxContentWidth,
              child: Padding(
                padding: EdgeInsets.fromLTRB(AppSpacing.xl, topInset + AppSpacing.lg, AppSpacing.xl, AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // The heading always reads "Career Quiz", regardless of
                    // which level is current — per direct feedback that
                    // swapping the heading itself to the current level's own
                    // title read as confusing copy. The line beneath names
                    // the current level instead. (No separate eyebrow label
                    // above this any more — it used to duplicate the same
                    // "Career Quiz" text twice in a row.)
                    Text('Career Quiz', style: AppTextStyles.h1.copyWith(color: AppColors.ink, fontSize: 26, fontWeight: AppFontWeight.semibold)),
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: Text(
                        noOrphan(currentMeta != null ? 'Level ${currentMeta.level} · ${currentMeta.title}' : 'All 5 levels complete!'),
                        style: AppTextStyles.bodyLg.copyWith(color: AppColors.gray500, fontSize: 14),
                      ),
                    ),
                    // Small trust line — deliberately lighter/smaller than
                    // the subtitle above (size alone does the differentiation
                    // here, both share gray500) so it reads as secondary
                    // credibility copy, not competing with the level name.
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: Text(
                        noOrphan('Approved by 100+ Psychologists, Researchers, PhDs and Business Leaders.'),
                        style: AppTextStyles.caption.copyWith(color: AppColors.inkA70, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ResponsiveBody(
            maxWidth: isTablet ? 1224 : AppBreakpoints.maxContentWidth,
            child: Padding(
              // Generous vertical rhythm between nodes (xxxl, not the old
              // list's tight md gaps) is what makes this read as "spacious"
              // rather than a dense list — the zigzag alignment does the rest.
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // What taking the quiz actually does for the student — the
                  // free test's result rides along with their resume for
                  // recruiters to see. Same message as the Home promo card.
                  Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.xxxl),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.offWhite,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      children: [
                        const Icon(Ionicons.eye_outline, size: 16, color: AppColors.gray500),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            noOrphan('Free 10-min test, attached to your resume for recruiters.'),
                            style: AppTextStyles.caption.copyWith(color: AppColors.ink, fontSize: 12, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                  for (final meta in careerDnaLevelMeta)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
                      child: _PathNode(
                        meta: meta,
                        xAlign: _pathXAlign[(meta.level - 1) % _pathXAlign.length],
                        unlocked: user?.isCareerDnaLevelUnlocked(meta.level) ?? (meta.level == 1),
                        completed: _isLevelComplete(profile, meta.level),
                        isCurrent: currentMeta?.level == meta.level,
                        onTap: () => _openLevel(
                          context,
                          meta.level,
                          user?.isCareerDnaLevelUnlocked(meta.level) ?? (meta.level == 1),
                          _isLevelComplete(profile, meta.level),
                        ),
                      ),
                    ),
                  if (allComplete)
                    GestureDetector(
                      onTap: () => context.push('/college/career-dna/final-report'),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(color: AppColors.brand, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: AppShadows.card),
                        child: Row(
                          children: [
                            const Icon(Ionicons.star, size: 22, color: AppColors.ink),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('See your full results', style: AppTextStyles.bodyLg.copyWith(color: AppColors.ink, fontWeight: AppFontWeight.semibold)),
                                  Padding(
                                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                                    child: Text('Every level, combined into one result.', style: AppTextStyles.caption.copyWith(color: AppColors.inkA70)),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Ionicons.chevron_forward, size: 18, color: AppColors.inkA70),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            ),
          ],
        ),
    );
  }
}

class _PathNode extends StatelessWidget {
  final CareerDnaLevelMeta meta;
  final double xAlign;
  final bool unlocked;
  final bool completed;
  final bool isCurrent;
  final VoidCallback onTap;

  const _PathNode({
    required this.meta,
    required this.xAlign,
    required this.unlocked,
    required this.completed,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final locked = !unlocked;
    final size = isCurrent ? 68.0 : 56.0;

    Widget circle = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: completed ? AppColors.success : (locked ? AppColors.gray100 : AppColors.brand),
        shape: BoxShape.circle,
        boxShadow: locked ? null : AppShadows.card,
      ),
      child: Icon(
        completed ? Ionicons.checkmark : (locked ? Ionicons.lock_closed : Ionicons.star),
        size: isCurrent ? 30 : 24,
        color: locked ? AppColors.gray400 : (completed ? AppColors.white : AppColors.ink),
      ),
    );

    // Current level's node gets a lighter ring around it (target-style,
    // matching the reference) so it visually reads as "you are here"
    // without needing a separate label every time.
    if (isCurrent) {
      circle = Container(
        width: size + 14,
        height: size + 14,
        alignment: Alignment.center,
        decoration: const BoxDecoration(color: AppColors.offWhite, shape: BoxShape.circle),
        child: circle,
      );
    }

    return Align(
      alignment: Alignment(xAlign, 0),
      child: GestureDetector(
        onTap: onTap,
        child: Opacity(
          opacity: locked ? 0.5 : 1.0,
          child: Column(
            children: [
              if (isCurrent)
                Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(color: AppColors.brand, borderRadius: BorderRadius.circular(AppRadius.pill)),
                  child: Text('START', style: AppTextStyles.label.copyWith(color: AppColors.ink, fontSize: 12, fontWeight: AppFontWeight.bold, letterSpacing: 0.6)),
                ),
              circle,
              // Shows the level's title beneath its number on every node
              // (not just the current one) — per direct feedback that
              // tapping a completed level jumped straight to its report
              // with no way to first see which level that was. A fixed
              // width keeps this from overflowing the screen edge at the
              // zigzag's more off-center x positions.
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: SizedBox(
                  width: 128,
                  child: Column(
                    children: [
                      // Tap-to-reveal info icon, same trigger/idiom already
                      // used for the match-% explanation elsewhere in this
                      // app (Tooltip + triggerMode.tap, not the default
                      // long-press) — lets a student preview what a test is
                      // about before opening it, for every node regardless
                      // of lock state. Nested inside the node's own outer
                      // GestureDetector; Flutter's gesture arena lets this
                      // inner tap win, so it never also opens the level.
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Level ${meta.level}',
                            style: AppTextStyles.caption.copyWith(color: AppColors.ink, fontSize: 12, fontWeight: AppFontWeight.semibold),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Tooltip(
                            message: meta.whatThisMeasures,
                            triggerMode: TooltipTriggerMode.tap,
                            child: const Icon(Ionicons.information_circle_outline, size: 13, color: AppColors.gray400),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Text(
                          meta.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption.copyWith(color: AppColors.gray500, fontSize: 12, height: 1.25),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
