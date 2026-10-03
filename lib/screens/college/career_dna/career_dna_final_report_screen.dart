import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../../models/career_dna.dart';
import '../../../models/user.dart';
import '../../../services/career_dna_report_pdf.dart';
import '../../../state/app_state.dart';
import '../../../theme/breakpoints.dart';
import '../../../theme/colors.dart';
import '../../../theme/shadows.dart';
import '../../../theme/spacing.dart';
import '../../../theme/text_styles.dart';
import '../../../utils/career_dna_trait_summary.dart';
import '../../../utils/no_orphan.dart';
import '../../../widgets/back_chevron.dart';
import '../../../widgets/badges.dart';
import '../../../widgets/career_dna_trait_summary_card.dart';
import '../../../widgets/pill_button.dart';
import '../../../widgets/responsive_body.dart';

const _confidenceLabels = {
  'high': 'High confidence',
  'moderate': 'Moderate confidence',
  'exploratory': 'Exploratory',
};

/// The final combined "Career DNA" synthesis — reachable only once all 5
/// levels are complete. Career DNA has no paywall: the full ranked
/// breakdown, roles, strengths/development areas and roadmap always render
/// once Level 5 is done — no locked/teaser state any more.
class CareerDnaFinalReportScreen extends StatelessWidget {
  const CareerDnaFinalReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().user;
    final profile = user?.careerDnaOrEmpty ?? const CareerDnaProfile();
    final topInset = MediaQuery.of(context).padding.top;
    final isTablet = AppBreakpoints.of(context) == AppBreakpoint.tablet;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: ResponsiveBody(
        maxWidth: isTablet ? 1224 : AppBreakpoints.maxContentWidth,
        child: ListView(
          padding: EdgeInsets.fromLTRB(AppSpacing.xl, topInset + AppSpacing.sm, AppSpacing.xl, AppSpacing.xxxl),
          children: [
            BackChevron(color: AppColors.ink, fallbackRoute: '/tabs/career-dna'),
            const SizedBox(height: AppSpacing.lg),
            if (!profile.allLevelsComplete)
              _NotDoneYetCard(completed: profile.completedLevelCount)
            else if (profile.level5 == null)
              const _StillBuildingCard()
            else
              _SynthesisContent(result: profile.level5!),
          ],
        ),
      ),
    );
  }
}

class _NotDoneYetCard extends StatelessWidget {
  final int completed;
  const _NotDoneYetCard({required this.completed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxxl),
      child: Center(
        child: Column(
          children: [
            const Icon(Ionicons.hourglass_outline, size: 36, color: AppColors.gray400),
            const SizedBox(height: AppSpacing.md),
            Text('$completed of 5 levels complete', style: AppTextStyles.h3.copyWith(color: AppColors.ink, fontWeight: AppFontWeight.semibold)),
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(noOrphan('Finish every level to see your combined results.'), style: AppTextStyles.body.copyWith(color: AppColors.gray500, fontSize: 12)),
            ),
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.lg),
              child: PillButton(label: 'Back to levels', full: false, onPressed: () => context.go('/tabs/career-dna')),
            ),
          ],
        ),
      ),
    );
  }
}

class _StillBuildingCard extends StatelessWidget {
  const _StillBuildingCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxxl),
      child: Center(
        child: Column(
          children: [
            const Icon(Ionicons.construct_outline, size: 36, color: AppColors.gray400),
            const SizedBox(height: AppSpacing.md),
            Text(noOrphan("We're still putting your combined synthesis together."), textAlign: TextAlign.center, style: AppTextStyles.body.copyWith(color: AppColors.gray500)),
          ],
        ),
      ),
    );
  }
}

class _SynthesisContent extends StatefulWidget {
  final CareerDnaLevel5Result result;
  const _SynthesisContent({required this.result});

  @override
  State<_SynthesisContent> createState() => _SynthesisContentState();
}

class _SynthesisContentState extends State<_SynthesisContent> {
  bool _downloading = false;

  Future<void> _downloadCombined(User user) async {
    if (_downloading) return;
    setState(() => _downloading = true);
    try {
      final bytes = await buildCareerDnaReportPdf(user);
      final name = (user.name?.trim().isNotEmpty ?? false) ? user.name! : 'career_quiz';
      final safeName = name.replaceAll(RegExp(r'[^\w\s-]'), '').trim().replaceAll(RegExp(r'\s+'), '_');
      await Printing.sharePdf(
        bytes: bytes,
        filename: '${safeName.isEmpty ? 'career_quiz' : safeName}_combined_report.pdf',
      );
    } catch (e) {
      debugPrint('Career Quiz combined report PDF generation failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text("Couldn't generate the PDF"),
          duration: Duration(seconds: 4),
          persist: false,
        ));
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final user = context.watch<AppState>().user;
    final isTablet = AppBreakpoints.of(context) == AppBreakpoint.tablet;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CareerDnaTraitSummaryCard(data: buildLevel5TraitSummary(result)),
        const SizedBox(height: AppSpacing.xl),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(color: AppColors.brand, borderRadius: BorderRadius.circular(AppRadius.xl)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('YOUR FINAL RESULT', style: AppTextStyles.label.copyWith(color: AppColors.ink, fontSize: 12, letterSpacing: 1.4)),
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(result.topDirections.first.name, style: AppTextStyles.h1.copyWith(color: AppColors.ink, fontSize: 26, fontWeight: AppFontWeight.semibold)),
              ),
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(_confidenceLabels[result.confidenceTier] ?? '', style: AppTextStyles.bodyLg.copyWith(color: AppColors.inkA70)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.lg),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isTablet ? 400 : double.infinity),
              child: PillButton(
                label: 'Download Combined PDF',
                variant: PillVariant.secondary,
                icon: Ionicons.download_outline,
                loading: _downloading,
                onPressed: user == null ? null : () => _downloadCombined(user),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Top Career Directions', style: AppTextStyles.h3.copyWith(color: AppColors.ink, fontWeight: AppFontWeight.bold)),
        const SizedBox(height: AppSpacing.md),
        for (final d in result.topDirections)
          Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: AppShadows.card),
            child: Row(
              children: [
                Expanded(child: Text(d.name, style: AppTextStyles.bodyLg.copyWith(color: AppColors.ink, fontWeight: AppFontWeight.medium))),
                Text('${d.fitPercent}%', style: AppTextStyles.h3.copyWith(color: AppColors.ink, fontWeight: AppFontWeight.bold)),
              ],
            ),
          ),
        Text('Top Job Roles', style: AppTextStyles.h3.copyWith(color: AppColors.ink, fontWeight: AppFontWeight.bold)),
        const SizedBox(height: AppSpacing.md),
        Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: result.topRoles.map((r) => AppTag(label: '${r.name} · ${r.fitPercent}%')).toList()),
        const SizedBox(height: AppSpacing.xl),
        Text('Your Career Strengths', style: AppTextStyles.h3.copyWith(color: AppColors.ink, fontWeight: AppFontWeight.bold)),
        const SizedBox(height: AppSpacing.md),
        Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: result.careerStrengths.map((s) => AppTag(label: s)).toList()),
        const SizedBox(height: AppSpacing.xl),
        Text('Growth Opportunities', style: AppTextStyles.h3.copyWith(color: AppColors.ink, fontWeight: AppFontWeight.bold)),
        const SizedBox(height: AppSpacing.md),
        Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: result.developmentAreas.map((s) => AppTag(label: s, color: AppColors.gray500, bg: AppColors.offWhite)).toList()),
        const SizedBox(height: AppSpacing.xl),
        Text('Your Roadmap', style: AppTextStyles.h3.copyWith(color: AppColors.ink, fontWeight: AppFontWeight.bold)),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: AppShadows.soft),
          child: Column(
            children: [
              for (var i = 0; i < result.nextSteps.length; i++)
                Padding(
                  padding: EdgeInsets.only(bottom: i == result.nextSteps.length - 1 ? 0 : AppSpacing.md),
                  child: Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: AppColors.offWhite, shape: BoxShape.circle),
                        child: Text('${i + 1}', style: AppTextStyles.caption.copyWith(color: AppColors.ink, fontWeight: AppFontWeight.bold)),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: Text(result.nextSteps[i], style: AppTextStyles.body.copyWith(color: AppColors.ink, fontSize: 12))),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isTablet ? 400 : double.infinity),
            child: PillButton(
              label: 'Retake Level 5',
              variant: PillVariant.secondary,
              icon: Ionicons.refresh_outline,
              onPressed: () => context.push('/college/career-dna/level/5/intro'),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: Center(
            child: GestureDetector(
              onTap: () => context.go('/tabs/career-dna'),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Text(
                  'Back to Career Quiz',
                  style: AppTextStyles.body.copyWith(color: AppColors.ink, fontSize: 14, fontWeight: AppFontWeight.semibold),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
