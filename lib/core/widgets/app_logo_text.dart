import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppLogoText extends StatelessWidget {
  const AppLogoText({
    super.key,
    this.width = 200,
    this.color = false,
  });

  final double width;
  final bool color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 243,
      height: 70,
      child: Hero(
        tag: AppHero.logo,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Image.asset(
                color ? AppAssets.logoColor : AppAssets.logoWhite,
                height: 55,
                fit: BoxFit.contain,
              ),
            ),
            Expanded(
              flex: 4,
              child: Image.asset(
                AppHero.logoText,
                height: 55,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
