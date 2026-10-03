import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/text_styles.dart';

/// Mirrors frontend/src/components/ui.tsx Chip.
/// Named AppChip to avoid clashing with Flutter's built-in Chip widget.
///
/// Selected = white fill + 2px brand-yellow stroke + semibold ink label.
/// Deliberately NOT a solid yellow pill: that is the primary-CTA look, and
/// filter/option chips must never read as buttons. Unselected = neutral
/// [AppColors.offWhite] with no stroke (the transparent 2px border keeps the
/// two states the same size, so nothing shifts on tap).
class AppChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onPressed;
  final bool disabled;

  /// When true, selected chips show a leading checkmark (multi-select roles).
  final bool showCheck;
  final Key? testKey;

  /// Smaller footprint for sub-tags nested under a primary chip row (e.g.
  /// interested-role filters sitting below the main type filter) — same
  /// pill, just shorter and lighter so the hierarchy between the two rows
  /// reads at a glance.
  final bool dense;

  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onPressed,
    this.disabled = false,
    this.showCheck = false,
    this.testKey,
    this.dense = false,
  });

  void _handleTap() {
    if (disabled) return;
    HapticFeedback.selectionClick();
    onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final fontWeight = selected ? AppFontWeight.semibold : AppFontWeight.medium;

    // No Container.alignment — with an alignment + bounded max width (e.g. inside
    // Wrap), Flutter expands the chip to full row width instead of hugging text.
    return Opacity(
      opacity: disabled ? 0.4 : 1.0,
      child: GestureDetector(
        key: testKey,
        onTap: disabled ? null : _handleTap,
        child: Container(
          height: dense ? 28 : 40,
          padding: EdgeInsets.symmetric(horizontal: dense ? AppSpacing.md : AppSpacing.lg),
          decoration: BoxDecoration(
            color: selected ? AppColors.white : AppColors.offWhite,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: selected ? AppColors.brand : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showCheck && selected) ...[
                Icon(Ionicons.checkmark, size: dense ? 11 : AppTextStyles.body.fontSize, color: AppColors.ink),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(
                label,
                style: dense
                    ? AppTextStyles.caption.copyWith(fontWeight: fontWeight, color: AppColors.ink, fontSize: 12)
                    : AppTextStyles.body.copyWith(fontWeight: fontWeight, color: AppColors.ink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
