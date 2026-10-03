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
import '../../utils/no_orphan.dart';
import '../../widgets/brand.dart';
import '../../widgets/pill_button.dart';
import '../../widgets/responsive_body.dart';

const _heroImage = 'assets/images/landing-hero.png';

/// Single landing + auth screen — replaces the old value-slides carousel,
/// segment picker, and the first half of the old profile quiz all at once.
/// One hero, a 2-line JTBD headline, Google/Email auth, and a stat line
/// instead of a logo strip — value prop, auth, and social proof in one
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
        // Hero sits outside ResponsiveBody, not wrapped along with
        // everything else — ResponsiveBody's own doc comment says a
        // genuine full-bleed banner should wrap only its scrollable
        // content in it, leaving the banner outside; this screen was
        // doing the opposite; the hero got pillarboxed to the same
        // capped width as the text/buttons below it on any browser
        // ≥600px, breaking the "immersive, edge-to-edge" intent the
        // comment right below describes.
        body: Column(
          children: [
            // Bleeds under the status bar on purpose — an immersive,
            // edge-to-edge hero instead of a photo inset with margins on
            // every side, with a scrim fading it straight into the panel
            // below so there's no hard seam between "photo" and "content".
            SizedBox(
              height: screenHeight * 0.46,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(_heroImage, fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppColors.white],
                        stops: [0.6, 1.0],
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
                      child: const Wordmark(size: 16),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ResponsiveBody(maxWidth: isTablet ? 1224 : AppBreakpoints.maxContentWidth, child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, 0),
                color: AppColors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Manual break at a natural word boundary — letting this
                    // wrap on its own risks an orphaned word alone on its own
                    // line at most screen widths.
                    Text(
                      'Your future job\nis looking for you too.',
                      // Deliberate exception to the app-wide "cap at semibold"
                      // rule — the one marketing headline that reads thick/bold.
                      style: AppTextStyles.h1.copyWith(color: AppColors.ink, fontSize: 30, fontWeight: AppFontWeight.extrabold, height: 34 / 30),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: Text(
                        noOrphan('Internships and jobs curated just for you.'),
                        style: AppTextStyles.bodyLg.copyWith(color: AppColors.gray500, fontSize: 16),
                      ),
                    ),
                    // Centered in the remaining space below the subtitle
                    // (equal slack above and below) instead of anchored
                    // right beneath it with all the leftover room pushed to
                    // the very bottom of the screen.
                    const Spacer(),
                    PillButton(
                      label: 'Continue with Google',
                      // Google's "G" has its own yellow segment, which
                      // vanishes against the yellow CTA — a white badge
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
                        // Padding lives inside the tap target now, not just
                        // around it — this was the one other action on the
                        // screen sized to its own text line, next to two
                        // full 44px pill buttons.
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.md),
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
                    const Spacer(),
                  ],
                ),
              )),
            ),
            // Stat bar removed for now — left as empty space at the bottom
            // of the brand panel (via the Spacer above) rather than filled
            // with a placeholder.
            SizedBox(height: bottomInset + AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
