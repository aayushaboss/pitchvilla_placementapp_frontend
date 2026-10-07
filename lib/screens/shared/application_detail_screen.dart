import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../mockData/mock_application_insights.dart';
import '../../mockData/mock_applications.dart';
import '../../mockData/mock_opportunities.dart';
import '../../models/application.dart';
import '../../models/opportunity.dart';
import '../../models/opportunity_match.dart';
import '../../models/user.dart';
import '../../services/apply_flow.dart';
import '../../state/app_state.dart';
import '../../theme/breakpoints.dart';
import '../../theme/colors.dart';
import '../../theme/shadows.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../utils/no_orphan.dart';
import '../../utils/relative_time.dart';
import '../../widgets/badges.dart';
import '../../widgets/company_mark.dart';
import '../../widgets/insight_donut_card.dart';
import '../../widgets/not_found_view.dart';
import '../../widgets/opportunity_carousel_section.dart';
import '../../widgets/responsive_body.dart';

const _terminalStatuses = {'Offer', 'Rejected'};

// Shadow-clip clearance for the "How you compare" carousel, sized for
// InsightDonutCard's AppShadows.soft (offset 0,2 / blurRadius 5) — see the
// comment at its use site for why this differs from AppShadows.cardBuffer.
const _softBufferTop = 3.0;
const _softBufferBottom = 7.0;

/// Post-apply "what happens next" screen: a status timeline (à la
/// LinkedIn/Naukri application tracking) plus a company-bot message thread
/// (à la Naukri Chat / Internshala's interview scheduler) so every applicant
/// can see exactly where their application stands and what's scheduled next.
class ApplicationDetailScreen extends StatelessWidget {
  final String id;
  const ApplicationDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final app = getApplicationById(id);
    final topInset = MediaQuery.of(context).padding.top;
    final user = context.watch<AppState>().user;
    final isTablet = AppBreakpoints.of(context) == AppBreakpoint.tablet;

    if (app == null) {
      return const NotFoundView(
        title: 'Application not found',
        message: "This application may have been removed, or the link you followed is out of date.",
      );
    }

    void back() {
      if (context.canPop()) {
        context.pop();
      } else {
        // Reached here via an auto-submitted application (context.go, which
        // clears the stack) rather than a push from the tracker — nothing to
        // pop back to, so land on the job feed instead of a dead-end tap.
        context.go('/tabs');
      }
    }

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go('/tabs');
      },
      child: Scaffold(
      backgroundColor: AppColors.offWhite,
      body: ResponsiveBody(maxWidth: isTablet ? 1224 : AppBreakpoints.maxContentWidth, child: Column(
        children: [
          Container(
            color: AppColors.white,
            padding: EdgeInsets.fromLTRB(AppSpacing.xl, topInset + AppSpacing.sm, AppSpacing.xl, AppSpacing.lg),
            child: Row(
              children: [
                GestureDetector(
                  onTap: back,
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: AppColors.offWhite, shape: BoxShape.circle),
                    child: const Icon(Ionicons.chevron_back, size: 22, color: AppColors.ink),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                CompanyMark(company: app.opportunity.company, size: 44),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(app.opportunity.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.body.copyWith(color: AppColors.ink, fontWeight: AppFontWeight.semibold, fontSize: 14)),
                      Text(app.opportunity.company, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.caption.copyWith(color: AppColors.gray500, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xxxl),
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppRadius.xl), boxShadow: AppShadows.soft),
                  child: _Timeline(app: app),
                ),
                const SizedBox(height: AppSpacing.xl),
                _InsightsSection(app: app, user: user),
                // Screening answers/note were captured at apply-time but
                // never shown back anywhere — a student who typed a careful
                // answer had no way to confirm it was actually captured.
                if ((app.screeningAnswers?.isNotEmpty ?? false) || (app.note?.trim().isNotEmpty ?? false)) ...[
                  const SizedBox(height: AppSpacing.xl),
                  Text('Your answers', style: AppTextStyles.h3.copyWith(color: AppColors.ink, fontWeight: AppFontWeight.bold)),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppRadius.xl), boxShadow: AppShadows.soft),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final entry in (app.screeningAnswers ?? const {}).entries)
                          Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(entry.key, style: AppTextStyles.caption.copyWith(color: AppColors.gray500, fontSize: 12, fontWeight: AppFontWeight.medium)),
                                Padding(
                                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                                  child: Text(entry.value, style: AppTextStyles.body.copyWith(color: AppColors.ink, fontSize: 14)),
                                ),
                              ],
                            ),
                          ),
                        if (app.note?.trim().isNotEmpty ?? false) ...[
                          Text('Note to recruiter', style: AppTextStyles.caption.copyWith(color: AppColors.gray500, fontSize: 12, fontWeight: AppFontWeight.medium)),
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.xs),
                            child: Text(app.note!.trim(), style: AppTextStyles.body.copyWith(color: AppColors.ink, fontSize: 14)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                if (app.messages.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  Text('Updates', style: AppTextStyles.h3.copyWith(color: AppColors.ink, fontWeight: AppFontWeight.bold)),
                  const SizedBox(height: AppSpacing.md),
                  // Newest first — the most recent update (often the one with
                  // the actual interview time/venue) used to sit at the very
                  // bottom of a chronological list, which meant scrolling
                  // past everything else just to see what mattered most.
                  ...(List.of(app.messages)..sort((a, b) => b.at.compareTo(a.at))).map((m) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _MessageBubble(message: m, company: app.opportunity.company),
                      )),
                ],
                if (app.status == 'Rejected') ...[
                  const SizedBox(height: AppSpacing.sm),
                  const _RejectionRecoveryCard(),
                ],
                // However this application turns out, the page shouldn't
                // be a dead end — give the reader somewhere to go next
                // instead of just a status feed with nothing below it. No
                // manual top gap here — CarouselSectionHeading already
                // supplies a divider + AppSpacing.xl clearance above it.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: -AppSpacing.xl),
                  child: _SuggestedForYou(app: app, user: user),
                ),
              ],
            ),
          ),
        ],
      )),
      ),
    );
  }
}

/// Similar-role suggestions so the application page never dead-ends,
/// whether the app is still in review or already closed out — reuses the
/// same carousel shell as the Home feed's "topic" rows, not a bespoke look.
class _SuggestedForYou extends StatefulWidget {
  final Application app;
  final User? user;
  const _SuggestedForYou({required this.app, required this.user});

  @override
  State<_SuggestedForYou> createState() => _SuggestedForYouState();
}

class _SuggestedForYouState extends State<_SuggestedForYou> {
  @override
  Widget build(BuildContext context) {
    final app = widget.app;
    final user = widget.user;
    final current = getOpportunityById(app.opportunityId);
    final appliedIds = listApplications().map((a) => a.opportunityId).toSet();
    final pool = mockOpportunities.where((o) => o.id != app.opportunityId && !appliedIds.contains(o.id));
    // Same category first choice — falls back to same type (Internship vs
    // Full-time) if the original posting can't be found or nothing shares
    // its category, so this never comes up empty.
    var suggestions = current != null ? pool.where((o) => o.category == current.category).toList() : <Opportunity>[];
    if (suggestions.isEmpty) {
      suggestions = pool.where((o) => o.type == app.opportunity.type).toList();
    }
    // Score each job once (not twice per comparison): the pool is the whole
    // 1,000-job catalogue and this runs on every rebuild.
    final scores = {for (final o in suggestions) o.id: o.matchScoreFor(user)};
    suggestions.sort((a, b) => scores[b.id]!.compareTo(scores[a.id]!));
    final shown = suggestions.take(8).toList();
    if (shown.isEmpty) return const SizedBox.shrink();

    return OpportunityCarouselSection(
      title: 'Suggested for you',
      opportunities: shown,
      matchLabel: (o) => o.matchLabelFor(user),
      isApplied: (o) => isOpportunityApplied(o.id),
      onTapCard: (o) => context.push('/opportunity/${o.id}'),
      onApply: (o) => startApplyFlow(context, o, onApplied: () => setState(() {})),
    );
  }
}

/// Renders exactly the milestones this application has actually passed
/// through, plus one pending step if it's still open — so a two-step
/// walk-in company (Applied → Interview → done) and a five-round
/// enterprise pipeline both render correctly without forcing either
/// into a one-size-fits-all stage list.
class _Timeline extends StatelessWidget {
  final Application app;
  const _Timeline({required this.app});

  @override
  Widget build(BuildContext context) {
    final events = app.timeline;
    final isOpen = !_terminalStatuses.contains(app.status);
    final isRejected = app.status == 'Rejected';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(events.length + (isOpen ? 1 : 0), (i) {
        final isPending = i == events.length;
        final isLast = i == events.length - (isOpen ? 0 : 1);
        final event = isPending ? null : events[i];
        final isRejectedNode = !isPending && isRejected && i == events.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isPending
                          ? AppColors.offWhite
                          : isRejectedNode
                              ? AppColors.gray400
                              : AppColors.brand,
                      shape: BoxShape.circle,
                      border: Border.all(color: isPending ? AppColors.border : Colors.transparent, width: 1.5),
                    ),
                    child: isPending
                        ? null
                        : Icon(isRejectedNode ? Ionicons.close : Ionicons.checkmark, size: 13, color: isRejectedNode ? AppColors.white : AppColors.ink),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(width: 2, color: isPending ? AppColors.border : AppColors.brand),
                    ),
                ],
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPending ? 'Awaiting next update' : applicationStatusLabel(event!.status),
                        style: AppTextStyles.body.copyWith(
                          color: isPending ? AppColors.gray400 : AppColors.ink,
                          fontWeight: AppFontWeight.medium,
                          fontSize: 14,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Text(
                          isPending ? "We'll notify you here the moment there's news." : '${event!.title} • ${relativeTimeLabel(event.at)}',
                          style: AppTextStyles.caption.copyWith(color: AppColors.gray500, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ApplicationMessage message;
  final String company;
  const _MessageBubble({required this.message, required this.company});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: AppColors.offWhite, shape: BoxShape.circle),
          child: const Icon(Ionicons.business, size: 16, color: AppColors.ink),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(AppRadius.lg),
                    bottomLeft: Radius.circular(AppRadius.lg),
                    bottomRight: Radius.circular(AppRadius.lg),
                  ),
                  boxShadow: AppShadows.soft,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.text,
                      style: AppTextStyles.body.copyWith(color: AppColors.ink, fontSize: 14, height: 21 / 14),
                    ),
                    if (message.interview != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      _InterviewCard(details: message.interview!),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs, left: AppSpacing.xs),
                child: Text(relativeTimeLabel(message.at), style: AppTextStyles.caption.copyWith(color: AppColors.gray400, fontSize: 12)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InterviewCard extends StatelessWidget {
  final InterviewDetails details;
  const _InterviewCard({required this.details});

  @override
  Widget build(BuildContext context) {
    final isOnline = details.mode.toLowerCase() == 'online';
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Ionicons.calendar, size: 16, color: AppColors.ink),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(details.round, style: AppTextStyles.body.copyWith(color: AppColors.ink, fontWeight: AppFontWeight.medium, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _InterviewRow(icon: Ionicons.time_outline, label: '${details.dateLabel} • ${details.timeLabel}'),
          const SizedBox(height: AppSpacing.sm),
          _InterviewRow(icon: isOnline ? Ionicons.videocam_outline : Ionicons.business_outline, label: details.mode),
          const SizedBox(height: AppSpacing.sm),
          _InterviewRow(icon: Ionicons.location_outline, label: details.location),
        ],
      ),
    );
  }
}

class _InterviewRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InterviewRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.ink),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.ink, fontSize: 12, fontWeight: AppFontWeight.medium))),
      ],
    );
  }
}

/// Reframes a rejection as a redirect rather than a dead end: one company's
/// decision, then two concrete next actions using features the app already
/// has (matched feed, mock-interview booking) — not a rejection counter.
class _RejectionRecoveryCard extends StatelessWidget {
  const _RejectionRecoveryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: AppColors.offWhite, borderRadius: BorderRadius.circular(AppRadius.xl)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                child: const Icon(Ionicons.compass_outline, size: 18, color: AppColors.ink),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text('This one didn\'t work out', style: AppTextStyles.body.copyWith(color: AppColors.ink, fontWeight: AppFontWeight.medium, fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            "This company's call doesn't reflect your fit elsewhere — here's where to go next.",
            style: AppTextStyles.caption.copyWith(color: AppColors.gray500, fontSize: 12, height: 18 / 12.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _RecoveryAction(
                  icon: Ionicons.search_outline,
                  label: 'Similar roles',
                  onTap: () => context.go('/tabs'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _RecoveryAction(
                  icon: Ionicons.rocket_outline,
                  label: 'Mock interview',
                  onTap: () => context.push('/booking?kind=placement'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecoveryAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _RecoveryAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.sm),
          child: Column(
            children: [
              Icon(icon, size: 18, color: AppColors.ink),
              const SizedBox(height: AppSpacing.xs),
              Text(label, textAlign: TextAlign.center, style: AppTextStyles.caption.copyWith(color: AppColors.ink, fontSize: 12, fontWeight: AppFontWeight.medium)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Naukri-style "how this application compares" block — a summary
/// checklist ("N out of ${insights.length}") for a glance, then the full donut carousel for
/// anyone who wants the breakdown. Useful precisely because it still shows
/// up on a rejection: seeing *why* is more actionable than just the no.
class _InsightsSection extends StatelessWidget {
  final Application app;
  final User? user;
  const _InsightsSection({required this.app, required this.user});

  @override
  Widget build(BuildContext context) {
    final insights = applicationInsightsFor(app, user);
    final matchedCount = insights.where((i) => i.matched).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppRadius.xl), boxShadow: AppShadows.soft),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: AppColors.offWhite, shape: BoxShape.circle),
                    child: const Icon(Ionicons.bulb_outline, size: 18, color: AppColors.ink),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      noOrphan('Application insights'),
                      style: AppTextStyles.h3.copyWith(color: AppColors.ink, fontWeight: AppFontWeight.bold),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
                child: Text(
                  '$matchedCount out of ${insights.length}',
                  style: AppTextStyles.caption.copyWith(color: AppColors.gray400, fontSize: 12, fontWeight: AppFontWeight.medium),
                ),
              ),
              Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.sm,
                children: insights.map((i) {
                  return SizedBox(
                    width: 140,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          i.matched ? Ionicons.checkmark_circle : Ionicons.close_circle_outline,
                          size: 16,
                          color: i.matched ? AppColors.success : AppColors.gray400,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            i.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption.copyWith(color: AppColors.ink, fontSize: 12, fontWeight: AppFontWeight.medium),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('How you compare', style: AppTextStyles.h3.copyWith(color: AppColors.ink, fontWeight: AppFontWeight.bold)),
        const SizedBox(height: AppSpacing.md),
        // InsightDonutCard uses AppShadows.soft (matching the rest of this
        // screen), not the wider AppShadows.card blur that cardBuffer is
        // sized for — so this carousel needs only soft's own small
        // clearance (blurRadius ∓ offsetY = 3 / 7) instead of the shared
        // 16px buffer, or it'd be over-padded for a shadow it no longer draws.
        // Bumped 168->192 for the 8pt spacing-grid pass — InsightDonutCard's
        // own internal AppSpacing paddings grew enough that 168 left almost
        // no slack for its 3-line legend/description case.
        SizedBox(
          height: 192 + _softBufferTop + _softBufferBottom,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(0, _softBufferTop, 0, _softBufferBottom),
            scrollDirection: Axis.horizontal,
            itemCount: insights.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, i) => InsightDonutCard(insight: insights[i]),
          ),
        ),
      ],
    );
  }
}
