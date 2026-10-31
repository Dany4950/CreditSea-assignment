import 'package:flutter/material.dart';

/// Design tokens for the auth flow (measured from Figma).
abstract final class AuthTokens {
  static const Color primaryDark = Color(0xFF0F4B92);
  static const Color actionBlue = Color(0xFF0075FF);
  static const Color success = Color(0xFF3FA37A);
  static const Color error = Color(0xFFD32F2F);
  static const Color border = Color(0xFFD9DEE5);
  static const Color textMuted = Color(0xFF5B6470);
  static const Color hint = Color(0xFF9AA3AF);
  static const Color tile = Color(0x1FFFFFFF); // white @ 12%
  static const double sheetRadius = 28;
  static const double fieldRadius = 10;
  static const double fieldHeight = 50;
  static const double pagePadding = 16;
}
