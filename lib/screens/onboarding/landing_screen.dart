import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../nav.dart';
import '../../state/app_state.dart';
import '../../theme/breakpoints.dart';
import '../../theme/colors.dart';
import '../../theme/shadows.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/brand.dart';
import '../../widgets/pill_button.dart';
import '../../widgets/responsive_body.dart';

const _heroImage = 'assets/images/landing-hero.png';

/// Single landing + auth screen — replaces the old value-slides carousel,
/// segment picker, and the first half of the old profile quiz all at once.
/// One hero, a 2-line headline, two proof points (10,000+ startups, 50+
/// unicorns), Google/Phone auth and a "Powered by Pitchvilla" line, all on one
/// screen instead of three.
///
/// Full-bleed hero blending into the content below via a gradient scrim,
/// instead of a photo floating as a rounded card on a flat color field —
/// the "card pasted onto a background with a big empty gap under it" read
/// as unfinished rather than designed.
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  bool _googleLoading = false;

  Future<void> _continueWithGoogle() async {
    if (_googleLoading) return;
    setState(() => _googleLoading = true);
    HapticFeedback.mediumImpact();
    try {
      final appState = context.read<AppState>();
      final user = await appState.mockGoogleSignIn();
      if (!mounted) return;
      context.go(routeForUser(user));
    } catch (_) {
      // No failure path existed here at all — mockGoogleSignIn was assumed
      // to always succeed. Once real auth lands this is where a genuine
      // failure (network, cancelled consent, etc.) needs to land somewhere
      // visible instead of the loading state just quietly resetting.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("That didn't go through — let's try again."),
          action: SnackBarAction(label: 'Retry', textColor: AppColors.brand, onPressed: _continueWithGoogle),
          duration: const Duration(seconds: 4),
          // See sessions_screen.dart's own note on `persist`.
          persist: false,
        ),
      );
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  // No `mode` query param — LoginScreen's own default (startOnEmail: false,
  // per router.dart) is the phone field, so this lands there directly
  // instead of on email.
  void _continueWithPhone() {
    // Without this, tapping Phone right after Google (before the mock
    // sign-in's 500ms resolves) let the delayed Google callback fire once
    // this screen is still mounted underneath the just-pushed login
    // screen, forcibly navigating away from whatever the user is now
    // doing there.
    if (_googleLoading) return;
    context.push('/auth/login');
  }

  void _goToReturningLogin() => context.push('/auth/login?returning=1');

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = AppBreakpoints.of(context) == AppBreakpoint.tablet;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.white,
        // Hero sits outside ResponsiveBody so it stays a true full-bleed banner
        // on wide browsers; only the content below is width-capped.
        body: Column(
          children: [
            // Shorter than before (it was 46% of the screen) so the headline, the
            // proof points, both sign-in buttons and the "Powered by" line all
            // fit on one phone screen without crowding.
            SizedBox(
              height: (screenHeight * 0.40).clamp(200.0, 380.0),
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(_heroImage, fit: BoxFit.cover, alignment: const Alignment(0, -0.35)),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppColors.white],
                        stops: [0.55, 1.0],
                      ),
                    ),
                  ),
                  // Covers the 1-2px antialiasing seam where the photo's last
                  // row meets the white panel below it.
                  const Positioned(left: 0, right: 0, bottom: 0, height: 2, child: ColoredBox(color: AppColors.white)),
                  // Logo lives on a white pill so it stays legible over the photo.
                  Positioned(
                    top: topInset + AppSpacing.md,
                    left: AppSpacing.xl,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        boxShadow: AppShadows.soft,
                      ),
                      child: const Wordmark(size: 18),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ResponsiveBody(
                maxWidth: isTablet ? 1224 : AppBreakpoints.maxContentWidth,
                // Scrolls only if a very small screen cannot fit everything;
                // otherwise the content fills the height and "Powered by" sits
                // at the bottom.
                child: CustomScrollView(
                  physics: const ClampingScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, bottomInset + AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "INDIA'S STARTUP TALENT NETWORK",
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.gray500,
                                fontSize: 11,
                                letterSpacing: 1.4,
                                fontWeight: AppFontWeight.semibold,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: AppSpacing.sm),
                              child: Text(
                                // Manual break at a natural word boundary so no
                                // word is orphaned on its own line.
                                "Get hired by India's\ntop startups",
                                // Deliberate exception to the app-wide "cap at
                                // semibold" rule: the one marketing headline.
                                style: AppTextStyles.h1.copyWith(color: AppColors.ink, fontSize: 30, fontWeight: AppFontWeight.extrabold, height: 34 / 30),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: AppSpacing.sm),
                              child: Text(
                                'Internships and full-time jobs.',
                                style: AppTextStyles.bodyLg.copyWith(color: AppColors.gray500, fontSize: 16),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            const _ProofCard(),
                            const Spacer(),
                            const SizedBox(height: AppSpacing.lg),
                            PillButton(
                              label: 'Continue with Google',
                              // Google's "G" has its own yellow segment, which
                              // vanishes against the yellow CTA: a white badge
                              // behind it keeps the mark legible.
                              iconWidget: Container(
                                decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                                padding: const EdgeInsets.all(AppSpacing.xs),
                                child: SvgPicture.asset('assets/icons/google.svg'),
                              ),
                              loading: _googleLoading,
                              onPressed: _continueWithGoogle,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: AppSpacing.md),
                              child: PillButton(
                                label: 'Continue with Phone Number',
                                variant: PillVariant.secondary,
                                icon: Ionicons.call_outline,
                                disabled: _googleLoading,
                                onPressed: _continueWithPhone,
                              ),
                            ),
                            Center(
                              child: GestureDetector(
                                onTap: _goToReturningLogin,
                                // Padding lives inside the tap target, not just
                                // around it, so it is a full-size touch target.
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.md),
                                  child: Text.rich(
                                    TextSpan(
                                      style: AppTextStyles.body.copyWith(color: AppColors.gray500, fontSize: 14, fontWeight: AppFontWeight.medium),
                                      children: [
                                        const TextSpan(text: 'Already have an account? '),
                                        TextSpan(
                                          text: 'Log in',
                                          style: AppTextStyles.body.copyWith(
                                            color: AppColors.ink,
                                            fontSize: 14,
                                            fontWeight: AppFontWeight.semibold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Center(
                              child: Text.rich(
                                TextSpan(
                                  style: AppTextStyles.caption.copyWith(color: AppColors.gray400, fontSize: 12),
                                  children: [
                                    const TextSpan(text: 'Powered by '),
                                    TextSpan(
                                      text: 'Pitchvilla',
                                      style: AppTextStyles.caption.copyWith(color: AppColors.gray500, fontSize: 12, fontWeight: AppFontWeight.semibold),
                                    ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The two proof points, side by side on a soft card: big numerals, small
/// spaced-out labels. White-dominant (no yellow wash), numbers carry the weight.
class _ProofCard extends StatelessWidget {
  const _ProofCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md + 2),
      decoration: BoxDecoration(color: AppColors.offWhite, borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: const IntrinsicHeight(
        child: Row(
          children: [
            Expanded(child: _Stat(value: '10,000+', label: 'STARTUPS')),
            VerticalDivider(width: 1, thickness: 1, color: AppColors.gray100),
            Expanded(child: _Stat(value: '50+', label: 'UNICORNS')),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Never wraps: shrinks a touch on a very narrow screen instead.
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            maxLines: 1,
            softWrap: false,
            style: AppTextStyles.h1.copyWith(color: AppColors.ink, fontSize: 28, fontWeight: AppFontWeight.extrabold, height: 1.1),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.gray500, fontSize: 11, letterSpacing: 1.4, fontWeight: AppFontWeight.semibold),
        ),
      ],
    );
  }
}
