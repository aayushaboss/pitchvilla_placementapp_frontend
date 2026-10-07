import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/text_styles.dart';

/// Jobsvilla's mark: a solid dot. Yellow on white pages; white on a solid
/// `AppColors.brand` page, where a yellow dot would disappear.
class BrandDot extends StatelessWidget {
  final double size;
  final Color color;

  const BrandDot({super.key, this.size = 12, this.color = AppColors.brand});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// Wordmark: the dot followed by lowercase "jobsvilla". Defaults suit a
/// white page; on a `brand` page pass `dot: AppColors.white`.
class Wordmark extends StatelessWidget {
  final Color color;
  final Color dot;
  final double size;

  const Wordmark({
    super.key,
    this.color = AppColors.ink,
    this.dot = AppColors.brand,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BrandDot(size: size * 0.55, color: dot),
        SizedBox(width: size * 0.3),
        Text(
          'jobsvilla',
          style: TextStyle(
            fontFamily: kFontFamily,
            fontWeight: AppFontWeight.semibold,
            letterSpacing: -0.3,
            fontSize: size,
            color: color,
          ),
        ),
      ],
    );
  }
}
