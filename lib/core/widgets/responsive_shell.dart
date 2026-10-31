import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Wraps the whole app once (via GetMaterialApp.builder):
///  - caps content width on tablets/iPad so the phone design stays pixel-faithful
///  - overrides MediaQuery.size so descendants measure the capped width
///  - clamps text scaling so large system fonts can't break layouts
class ResponsiveShell extends StatelessWidget {
  const ResponsiveShell({super.key, required this.child});
  final Widget? child;

  static const double maxWidth = 480;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final width = math.min(mq.size.width, maxWidth);
    return ColoredBox(
      color: AppColors.tabletBackdrop,
      child: Center(
        child: SizedBox(
          width: width,
          child: MediaQuery(
            data: mq.copyWith(
              size: Size(width, mq.size.height),
              textScaler: mq.textScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.15),
            ),
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
