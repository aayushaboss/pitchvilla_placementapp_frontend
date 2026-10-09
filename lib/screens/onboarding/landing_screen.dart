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
import '../../widgets/pill_button.dart';
import '../../widgets/responsive_body.dart';

const _logoImage = 'assets/images/jobsvilla-logo.png';
const _photoImage = 'assets/images/landing-photo.webp';

// The photo file is 1920x1080 with a white margin around the picture itself, and the
// picture has its own rounded bottom corners. These crop to just the picture, a little
// inside its edge, so the margin and baked-in corners never show.
// Smallest page height (before the status bar and home indicator) that still leaves the
// photo about 150px: the logo, headline and buttons need roughly 470 of the rest.
const _minPageHeight = 630.0;

// From this width the page switches to two panes (a landscape tablet or a laptop window).
const _splitBreakpoint = 900.0;

// ...and from this width (a tablet) when the window is squarish or short.
const _splitMinWidth = 700.0;

// The one-column layout needs about this much height to give the photo a decent size.
const _columnMinHeight = 760.0;

// Smallest page height of the tablet column (bigger logo and headline than the phone), so the
// photo is still about 250px and the page scrolls instead of squeezing it.
const _minTabletColumnHeight = 810.0;

const _photoFullWidth = 1920.0;
const _photoFullHeight = 1080.0;
const _photoCropLeft = 254.0;
const _photoCropWidth = 1412.0;
const _photoCropHeight = 1068.0;

/// The first screen after the splash. From top to bottom: the logo, the headline with
/// one small line of proof points under it, a wide photo that melts into the white page
/// at its top edge, then the sign-in buttons. The network tagline and "Powered by
/// Pitchvilla" are the quietest text, at the very bottom.
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

  /// The headline and the proof line under it. [size] is the headline font size.
  Widget _headlineBlock({required double size}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The only loud text on the screen.
        _Reveal(
          animation: _intro,
          from: 0.15,
          to: 0.55,
          child: Text(
            // Manual break at a natural word boundary so no word is orphaned on its own line.
            "Get hired by India's\ntop startups",
            // Deliberate exception to the app-wide "cap at semibold" rule: the one marketing headline.
            style: AppTextStyles.h1.copyWith(color: AppColors.ink, fontSize: size, fontWeight: AppFontWeight.extrabold, height: 1.12),
          ),
        ),
        // Small label line (bold numerals, tiny caps labels): clearly secondary to the headline.
        _Reveal(
          animation: _intro,
          from: 0.3,
          to: 0.7,
          child: Padding(
            padding: EdgeInsets.only(top: size >= 40 ? AppSpacing.lg : AppSpacing.md),
            child: _ProofLine(scale: size >= 40 ? 1.15 : 1),
          ),
        ),
      ],
    );
  }

  /// Google, phone, "Log in" and the footer line.
  Widget _signInBlock({required double bottomPadding}) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: _Reveal(
        animation: _intro,
        from: 0.45,
        to: 0.9,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PillButton(
              label: 'Continue with Google',
              // Google's "G" has its own yellow segment, which vanishes against the yellow
              // CTA: a white badge keeps it legible.
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
                // Padding lives inside the tap target, so it is a full-size touch target.
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
            // Quietest text on the page: one line, one colour, one weight.
            const Padding(
              padding: EdgeInsets.only(top: AppSpacing.xs),
              child: _FooterLine(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logo(double height) => _Reveal(
        animation: _intro,
        from: 0.0,
        to: 0.4,
        child: Image.asset(_logoImage, height: height, semanticLabel: 'Jobsvilla'),
      );

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final screen = MediaQuery.sizeOf(context);
    final width = screen.width;
    // Two panes whenever the window is wide, or on a tablet-sized window that is at least as
    // wide as it is tall or not tall enough for the column: the one-column layout would
    // squeeze the photo into a thin strip.
    final split = width >= _splitBreakpoint ||
        (width >= _splitMinWidth && (width / screen.height >= 0.9 || screen.height < _columnMinHeight));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.white,
        // Wide screens (a landscape tablet, a laptop browser) get two panes: text and
        // buttons on the left, the photo as a rounded card on the right. Phones and
        // portrait tablets get one column with the photo between text and buttons.
        body: split ? _splitLayout(topInset, bottomInset) : _columnLayout(topInset, bottomInset, width),
      ),
    );
  }

  /// One column: logo, headline, photo (takes the spare height), buttons.
  Widget _columnLayout(double topInset, double bottomInset, double width) {
    final tablet = width >= AppBreakpoints.tablet;
    return ResponsiveBody(
      // A wider column on a portrait tablet, but the buttons stay a comfortable width.
      maxWidth: tablet ? 680 : AppBreakpoints.maxContentWidth,
      // The page fills the screen (the photo takes the spare height). Only on a very short
      // screen does it grow past it and scroll. A plain sized box rather than a
      // SliverFillRemaining, which sizes itself from its content's natural height and would
      // blow the photo up to its full pixel size.
      child: LayoutBuilder(
        builder: (context, constraints) {
          final minHeight = (tablet ? _minTabletColumnHeight : _minPageHeight) + topInset + bottomInset;
          final pageHeight = constraints.maxHeight < minHeight ? minHeight : constraints.maxHeight;
          final gutter = tablet ? AppSpacing.xl : AppSpacing.lg;
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: SizedBox(
              height: pageHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(gutter, topInset + (tablet ? AppSpacing.xl : AppSpacing.lg), gutter, 0),
                    child: _logo(tablet ? 56 : 44),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(gutter, tablet ? AppSpacing.xxl : AppSpacing.xl, gutter, 0),
                    child: _headlineBlock(size: tablet ? 44 : 32),
                  ),
                  // The photo takes whatever height is left between the text and the buttons,
                  // so nothing is pushed off a short screen.
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: AppSpacing.md, bottom: tablet ? AppSpacing.xl : AppSpacing.lg),
                      child: _Reveal(
                        animation: _intro,
                        from: 0.2,
                        to: 0.8,
                        child: const _HeroPhoto(fadeTop: true),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: gutter),
                    // Centred and capped, so the buttons do not stretch across a tablet.
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: _signInBlock(bottomPadding: bottomInset + (tablet ? AppSpacing.xl : AppSpacing.md)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Two panes: text and buttons on the left, the photo as a rounded card on the right.
  Widget _splitLayout(double topInset, double bottomInset) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // On a narrower window the text pane gets the larger share and the margins shrink, so the
        // buttons never get squeezed.
        final narrow = constraints.maxWidth < _splitBreakpoint;
        final margin = narrow ? AppSpacing.lg : AppSpacing.xxl;
        // Scrolls (instead of overflowing) only if the window is very short.
        final height = constraints.maxHeight < 620 ? 620.0 : constraints.maxHeight;
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: SizedBox(
            height: height,
            child: Padding(
              padding: EdgeInsets.fromLTRB(margin, topInset + AppSpacing.xl, margin, bottomInset + AppSpacing.xl),
              child: Row(
                children: [
                  Expanded(
                    flex: narrow ? 6 : 5,
                    child: Center(
                      child: LayoutBuilder(
                        builder: (context, box) {
                          final w = box.maxWidth < 520 ? box.maxWidth : 520.0;
                          return SizedBox(
                            width: w,
                            child: SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _logo(60),
                                  const SizedBox(height: AppSpacing.xxl),
                                  // "Get hired by India's" is about 9.7 times the font size wide, so
                                  // this keeps it on one line at any pane width.
                                  _headlineBlock(size: (w / 10.2).clamp(32.0, 50.0)),
                                  const SizedBox(height: AppSpacing.xxl),
                                  _signInBlock(bottomPadding: 0),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: margin),
                  Expanded(
                    flex: narrow ? 5 : 6,
                    child: Center(
                      child: LayoutBuilder(
                        builder: (context, box) {
                          // A card about as wide as it is tall, never taller than the pane.
                          final w = box.maxWidth < 760 ? box.maxWidth : 760.0;
                          final h = (w / 1.1) < box.maxHeight ? w / 1.1 : box.maxHeight;
                          return SizedBox(
                            width: w,
                            height: h,
                            child: _Reveal(
                              animation: _intro,
                              from: 0.2,
                              to: 0.8,
                              child: const _HeroPhoto(radius: 36, alignment: Alignment(0.45, 0)),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The team photo, cropped to the picture itself and scaled to fill whatever box it is
/// given. In the one-column layout its top edge fades into the white page (so it never
/// looks like a pasted rectangle under the headline) and only the bottom corners are
/// rounded; in the two-pane layout it is a plain rounded card.
class _HeroPhoto extends StatelessWidget {
  final bool fadeTop;
  final double radius;

  /// Where the crop sits when the box is a different shape from the photo. Leans right
  /// of centre, where the faces are.
  final Alignment alignment;

  const _HeroPhoto({this.fadeTop = false, this.radius = 36, this.alignment = const Alignment(0.3, 0)});

  @override
  Widget build(BuildContext context) {
    Widget photo = SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        alignment: alignment,
        child: SizedBox(
          width: _photoCropWidth,
          height: _photoCropHeight,
          child: ClipRect(
            child: Transform.translate(
              offset: const Offset(-_photoCropLeft, 0),
              child: OverflowBox(
                alignment: Alignment.topLeft,
                minWidth: _photoFullWidth,
                maxWidth: _photoFullWidth,
                minHeight: _photoFullHeight,
                maxHeight: _photoFullHeight,
                child: Image.asset(
                  _photoImage,
                  width: _photoFullWidth,
                  height: _photoFullHeight,
                  fit: BoxFit.fill,
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (fadeTop) {
      photo = ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (rect) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00FFFFFF), Color(0xFFFFFFFF)],
          stops: [0.0, 0.32],
        ).createShader(rect),
        child: photo,
      );
    }
    return ClipRRect(
      borderRadius: fadeTop ? BorderRadius.vertical(bottom: Radius.circular(radius)) : BorderRadius.circular(radius),
      child: photo,
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
  final double scale;
  const _ProofLine({this.scale = 1});

  @override
  Widget build(BuildContext context) {
    TextSpan stat(String value, String label) => TextSpan(
          children: [
            TextSpan(text: value, style: AppTextStyles.body.copyWith(color: AppColors.ink, fontSize: 14 * scale, fontWeight: AppFontWeight.bold)),
            TextSpan(text: '  $label', style: AppTextStyles.caption.copyWith(color: AppColors.gray500, fontSize: 11 * scale, letterSpacing: 1.2, fontWeight: AppFontWeight.medium)),
          ],
        );
    return Align(
      alignment: Alignment.centerLeft,
      child: Text.rich(
        TextSpan(children: [
          stat('10,000+', 'STARTUPS'),
          TextSpan(text: '      ', style: AppTextStyles.caption.copyWith(fontSize: 11 * scale)),
          stat('50+', 'UNICORNS'),
        ]),
        maxLines: 1,
      ),
    );
  }
}
