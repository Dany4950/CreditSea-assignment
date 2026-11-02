import 'package:flutter/animation.dart';

class AppDurations {
  AppDurations._();
  static const Duration page = Duration(milliseconds: 280);
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration splashMin = Duration(milliseconds: 1600);
}

class AppCurves {
  AppCurves._();
  static const Curve standard = Curves.easeOutCubic;
}

class AppHero {
  AppHero._();
  static const String logo = 'assets/images/logo.png';
  static const String logoText = 'assets/images/logo_text.png';
    static const String logoTextBlue = 'assets/images/logo_blue.png';
}

class AppAssets {
  AppAssets._();
  static const String logoWhite = 'assets/images/logo.png';
  static const String logoColor = 'assets/images/logo.png';
}

class AppCacheTtl {
  AppCacheTtl._();
  static const Duration short = Duration(minutes: 2);
  static const Duration medium = Duration(minutes: 15);
}
