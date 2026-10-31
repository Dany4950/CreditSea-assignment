import 'package:flutter/material.dart';

/// Flutter-drawn rupee coin (swap for the Figma export if you like).
class CoinIllustration extends StatelessWidget {
  const CoinIllustration({super.key, this.size = 80});
  final double size;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFBE27A), Color(0xFFF3B93B)],
          ),
          boxShadow: [BoxShadow(color: Color(0x33F3B93B), blurRadius: 14, offset: Offset(0, 5))],
        ),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: DecoratedBox(
              decoration: const BoxDecoration(color: Color(0xFFE9A93A), shape: BoxShape.circle),
              child: SizedBox(
                width: size * 0.78,
                height: size * 0.78,
                child: Center(
                  child: Text('₹',
                      style: TextStyle(
                          fontSize: size * 0.48,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFBE27A))),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
