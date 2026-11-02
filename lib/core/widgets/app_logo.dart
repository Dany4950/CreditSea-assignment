import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Shared logo with a Hero tag so it glides from splash -> auth header.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.width = 200,
    this.color = false,
  });

  final double width;
  final bool color;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: AppHero.logo,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: width * 1.4,
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 40.0,
            ),
            child: Container(
              height: 120,
              child: Image.asset(
                color ? AppAssets.logoColor : AppAssets.logoWhite,
                width: 163,
                fit: BoxFit.fill,
                errorBuilder: (_, __, ___) => SizedBox(
                  width: width,
                  height: width * 0.25,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Image.asset(
            AppHero.logoText,
            width: width,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => SizedBox(
              width: width,
              height: width * 0.35,
            ),
          ),
        ],
      ),
    );
  }
}
