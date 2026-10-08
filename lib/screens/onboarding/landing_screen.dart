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
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/brand.dart';
import '../../widgets/pill_button.dart';
import '../../widgets/responsive_body.dart';

const _heroImage = 'assets/images/landing-hero.png';

/// The first screen after the splash: a large photo with just the logo on it, the
/// headline, one small label line for the proof points (10,000+ startups, 50+
/// unicorns), then the sign-in buttons. The network tagline and "Powered by
/// Pitchvilla" are the quietest text at the bottom. Nothing else.
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with SingleTickerProviderStateMixin {
  bool _googleLoading = false;

  // One controller drives the whole entrance: logo, badges, job card, headline
  // and buttons each fade and rise during their own slice of it.
  late final AnimationController _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..forward();

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

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
    // Half the screen, but never so tall that the buttons and footer get pushed off a short one.
    final heroHeight = (screenHeight * 0.50).clamp(230.0, 470.0).clamp(0.0, (screenHeight - 370).clamp(200.0, 470.0));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Column(
          children: [
            // Full-bleed photo with rounded bottom corners, outside ResponsiveBody so it
            // stays edge to edge on wide browsers. Just the logo on it: nothing else
            // competes with the photo.
            SizedBox(
              height: heroHeight,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(_heroImage, fit: BoxFit.cover, alignment: const Alignment(0, -0.4)),
                    Positioned(
                      top: topInset + AppSpacing.md,
                      left: AppSpacing.lg,
                      child: _Reveal(
                        animation: _intro,
                        from: 0.0,
                        to: 0.45,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppRadius.pill)),
                          child: const Wordmark(size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ResponsiveBody(
                maxWidth: AppBreakpoints.maxContentWidth,
                // Scrolls only if a very small screen cannot fit everything.
                child: CustomScrollView(
                  physics: const ClampingScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, bottomInset + AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tier 1, the only loud text on the screen.
                            _Reveal(
                              animation: _intro,
                              from: 0.25,
                              to: 0.65,
                              child: Text(
                                // Manual break at a natural word boundary so no word is
                                // orphaned on its own line.
                                "Get hired by India's\ntop startups",
                                // Deliberate exception to the app-wide "cap at semibold"
                                // rule: the one marketing headline.
                                style: AppTextStyles.h1.copyWith(color: AppColors.ink, fontSize: 32, fontWeight: AppFontWeight.extrabold, height: 36 / 32),
                              ),
                            ),
                            // The numbers sit directly under the headline as a small label line
                            // (bold numerals, tiny caps labels): clearly secondary to it.
                            _Reveal(
                              animation: _intro,
                              from: 0.35,
                              to: 0.75,
                              child: const Padding(
                                padding: EdgeInsets.only(top: AppSpacing.md),
                                child: _ProofLine(),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            const Spacer(),
                            _Reveal(
                              animation: _intro,
                              from: 0.45,
                              to: 0.85,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  PillButton(
                                    label: 'Continue with Google',
                                    // Google's "G" has its own yellow segment, which vanishes
                                    // against the yellow CTA: a white badge keeps it legible.
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
                                      // Padding lives inside the tap target, so it is a
                                      // full-size touch target.
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.md),
                                        child: Text.rich(
                                          TextSpan(
                                            style: AppTextStyles.body.copyWith(color: AppColors.gray500, fontSize: 14, fontWeight: AppFontWeight.medium),
                                            children: [
                                              const TextSpan(text: 'Already have an account? '),
                                              TextSpan(
                                                text: 'Log in',
                                                style: AppTextStyles.body.copyWith(color: AppColors.ink, fontSize: 14, fontWeight: AppFontWeight.semibold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Quietest text on the page: one line, one colour, one weight, so it
                                  // reads as a footer rather than a second block of copy.
                                  const Padding(
                                    padding: EdgeInsets.only(top: AppSpacing.xs),
                                    child: _FooterLine(),
                                  ),
                                ],
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

/// Fades and rises into place during part of the intro animation.
class _Reveal extends StatelessWidget {
  final Animation<double> animation;
  final double from;
  final double to;
  final Widget child;

  const _Reveal({required this.animation, required this.from, required this.to, required this.child});

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: animation, curve: Interval(from, to, curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: curved,
      child: AnimatedBuilder(
        animation: curved,
        builder: (context, child) => Transform.translate(offset: Offset(0, (1 - curved.value) * 14), child: child),
        child: child,
      ),
    );
  }
}

/// "India's Startup Talent Network · Powered by Pitchvilla": a single quiet line.
class _FooterLine extends StatelessWidget {
  const _FooterLine();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          "India's Startup Talent Network  ·  Powered by Pitchvilla",
          maxLines: 1,
          style: AppTextStyles.caption.copyWith(color: AppColors.gray400, fontSize: 11),
        ),
      ),
    );
  }
}

/// "10,000+ STARTUPS   50+ UNICORNS" as a small label line: bold numerals, tiny
/// spaced-out caps labels. Deliberately small and light so it never rivals the headline.
class _ProofLine extends StatelessWidget {
  const _ProofLine();

  @override
  Widget build(BuildContext context) {
    TextSpan stat(String value, String label) => TextSpan(
          children: [
            TextSpan(text: value, style: AppTextStyles.body.copyWith(color: AppColors.ink, fontSize: 14, fontWeight: AppFontWeight.bold)),
            TextSpan(text: '  $label', style: AppTextStyles.caption.copyWith(color: AppColors.gray500, fontSize: 11, letterSpacing: 1.2, fontWeight: AppFontWeight.medium)),
          ],
        );
    return Align(
      alignment: Alignment.centerLeft,
      child: Text.rich(
        TextSpan(children: [
          stat('10,000+', 'STARTUPS'),
          TextSpan(text: '      ', style: AppTextStyles.caption.copyWith(fontSize: 11)),
          stat('50+', 'UNICORNS'),
        ]),
        maxLines: 1,
      ),
    );
  }
}
