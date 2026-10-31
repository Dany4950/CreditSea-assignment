import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Blue/green CreditSea logo for light backgrounds.
/// Needs assets/images/logo_color.svg (export from Figma) listed in pubspec.
class ColorLogo extends StatelessWidget {
  const ColorLogo({super.key, this.height = 44});
  final double height;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: SvgPicture.asset(
          'assets/images/logo_color.svg',
          height: height,
          semanticsLabel: 'CreditSea',
        ),
      );
}
