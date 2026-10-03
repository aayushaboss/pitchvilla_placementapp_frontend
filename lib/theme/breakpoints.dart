import 'package:flutter/widgets.dart';

/// Screen-width breakpoints — mobile (<600) / tablet (>=600), a 2-tier
/// split. Mobile+tablet only (no web/desktop target) — this app is still
/// fundamentally phone-first (built and pixel-checked at ~375px;
/// [ResponsiveBody] caps wider screens at [maxContentWidth] rather than
/// letting a full-width layout stretch edge-to-edge), so [spacing]/
/// [fontSize] below give a gentle upscale at the tablet breakpoint rather
/// than a full fluid-scaling redesign — use them where a screen already
/// branches on width (see applications_tracker_screen.dart's/
/// saved_screen.dart's/courses_explore_screen.dart's/
/// opportunity_list_screen.dart's own 1-vs-2-column split), not as a
/// blanket replacement for every fixed value in the app.
///
/// This used to be a 3-tier mobile/tablet/desktop split — desktop (>=992)
/// was the tier that gave the app a wider web layout (persistent top nav
/// bar, a permanent sidebar filter panel, 1224px-wide content columns).
/// Now that there's no web/desktop target, that tier's wider, richer
/// treatment (the 1224px caps, sort/filter-chip polish, etc.) has simply
/// moved down onto `tablet` — a big tablet still gets the nicer wide
/// layout, it just starts at 600px instead of 992px. The two components
/// that were genuinely web/mouse-shaped rather than just "wider" (the top
/// nav bar and the persistent sidebar) were removed outright rather than
/// carried over — see tabs_scaffold.dart/college_feed_screen.dart.
enum AppBreakpoint { mobile, tablet }

class AppBreakpoints {
  AppBreakpoints._();

  /// Material's own tablet threshold. Below this, [ResponsiveBody] (see
  /// widgets/responsive_body.dart) is a complete no-op — nothing here can
  /// regress the phone sizes this app was actually tested at.
  static const double tablet = 600;

  /// Cap for single-column screens once past [tablet] — sized around a
  /// comfortable "large phone" reading width rather than letting inputs
  /// and buttons (tuned at ~375px) stretch edge-to-edge on a full tablet.
  static const double maxContentWidth = 520;

  static AppBreakpoint of(BuildContext context) => forWidth(MediaQuery.sizeOf(context).width);

  static AppBreakpoint forWidth(double width) {
    if (width >= tablet) return AppBreakpoint.tablet;
    return AppBreakpoint.mobile;
  }

  /// Scales an [AppSpacing] value up a notch on tablet — mobile unchanged,
  /// tablet +50% (carried over from this tier's old "desktop" multiplier,
  /// since tablet now gets that same wider treatment). Use at a screen's
  /// own outer margins/section gaps once it already has breakpoint-aware
  /// layout; not intended for every SizedBox in the app.
  static double spacing(BuildContext context, double base) {
    switch (of(context)) {
      case AppBreakpoint.tablet:
        return base * 1.5;
      case AppBreakpoint.mobile:
        return base;
    }
  }

  /// Scales a font size up modestly on tablet — mobile unchanged, tablet
  /// +15% (carried over from this tier's old "desktop" multiplier).
  /// Deliberately gentler than [spacing]: body text shouldn't grow as fast
  /// as whitespace does.
  static double fontSize(BuildContext context, double base) {
    switch (of(context)) {
      case AppBreakpoint.tablet:
        return base * 1.15;
      case AppBreakpoint.mobile:
        return base;
    }
  }
}
