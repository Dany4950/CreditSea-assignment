import 'package:flutter/material.dart';

/// 48dp title row: optional back arrow on the left, centered title that
/// scales down instead of overflowing (large system fonts).
class AuthSheetTitle extends StatelessWidget {
  const AuthSheetTitle(
    this.title, {
    super.key,
    this.onBack,
    this.fontSize = 22,
    this.fontWeight = FontWeight.w600,
  });
  final String title;
  final VoidCallback? onBack;
  final double fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (onBack != null)
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: onBack,
                tooltip: 'Back',
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                icon: const Icon(Icons.arrow_back_rounded, size: 24, color: Color(0xFF6B7280)),
              ),
            ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: onBack != null ? 44 : 0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(title, style: TextStyle(fontSize: fontSize, fontWeight: fontWeight)),
            ),
          ),
        ],
      ),
    );
  }
}
