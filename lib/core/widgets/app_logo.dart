import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Shared logo with a Hero tag so it glides from splash -> auth header.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.width = 200, this.color = false});

  final double width;
  final bool color; // true => blue/green variant for white backgrounds

 @override
Widget build(BuildContext context) {
  return Hero(
    tag: AppHero.logo,
    child: Image.asset(
      color ? AppAssets.logoColor : AppAssets.logoWhite,
      width: width,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => SizedBox(
        width: width,
        height: width * 0.35,
      ),
    ),
  );
  }
}
