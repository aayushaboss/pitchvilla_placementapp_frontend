import 'package:flutter/material.dart';

/// Pitchvilla design tokens. The app is WHITE-DOMINANT: white, [offWhite], gray
/// and ink carry the layout, and [brand] yellow is a scarce signal.
///
/// Yellow budget — [brand] may appear ONLY as:
///  1. a primary-CTA fill (and the thin stroke on the secondary CTA),
///  2. a solid highlight card for a deliberate feature moment (Results top
///     match, Career-DNA final result, Home promo / counseling cards),
///  3. a small signal: 2px selected-state stroke, tab underline, focus
///     border, unread dot, progress fill, level node, avatar circle,
///     success-check circle, the logo dot. (The bottom-nav active tab is NOT
///     yellow: filled icon + ink semibold label.)
/// Never as a page/header/banner fill, a pale wash, a tag, or a selected-chip
/// fill (a solid yellow pill reads as a CTA). It is also a LIGHT color, so it
/// is never text or icon color on white — use [ink] (or [gray500] for
/// decorative glyphs).
class AppColors {
  AppColors._();

  // brand
  static const brand = Color(0xFFFFCC00);
  static const brandPressed = Color(0xFFF2BF00);
  // Deep warm neutral for dark surfaces that need to stay on-palette (skill
  // story backgrounds) without falling back to pure black.
  static const brandDeep = Color(0xFF4A3F37);

  // surfaces
  static const white = Color(0xFFFFFFFF);
  static const offWhite = Color(0xFFF5F5F7);
  static const gray100 = Color(0xFFE5E5EA);
  static const gray200 = Color(0xFFD1D1D6);
  static const gray400 = Color(0xFFA1A1AA);
  static const gray500 = Color(0xFF6B5E54);
  static const ink = Color(0xFF1C1410);

  // Text/icon color to use on top of a [brand] fill.
  static const onBrand = ink;

  // status
  // Duolingo-style green: as saturated as the brand yellow, so a success
  // state (completed level, offer, check) feels like a win rather than a
  // muted gray-green sitting next to a vivid yellow.
  static const success = Color(0xFF58CC02);
  static const warning = Color(0xFFFF9500);
  static const error = Color(0xFFFF3B30);
  // A visible keyboard-focus outline must contrast with white, which rules
  // out the yellow brand color — ink is the app's interactive-accent color.
  static const focusRing = ink;
  // Darker variants for small text sat on that same color's own ~15% tint
  // — the plain success/warning values above read fine as icon fills, but
  // as StatusBadge's foreground text-on-tint they fell under WCAG AA
  // (~2.2-2.6:1). These pass comfortably at the same 12px size.
  static const successDark = Color(0xFF3C8200);
  static const warningDark = Color(0xFFB25900);

  static const border = Color(0xFFE5E5EA);

  // translucent
  static const whiteA10 = Color(0x1AFFFFFF);
  static const whiteA15 = Color(0x26FFFFFF);
  static const whiteA20 = Color(0x33FFFFFF);
  static const whiteA70 = Color(0xB3FFFFFF);
  // Secondary text/captions on a [brand] fill (the old whiteA70 on blue).
  static const inkA70 = Color(0xB31C1410);
  static const successA10 = Color(0x1A58CC02);
  static const warningA15 = Color(0x24FF9500);
  static const errorA10 = Color(0x1FFF3B30);
  static const gray500A15 = Color(0x246B5E54);
}
