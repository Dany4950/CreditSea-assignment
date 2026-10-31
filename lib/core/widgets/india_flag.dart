import 'package:flutter/material.dart';

/// Pure-canvas India flag: no asset decode, no SVG parse, never repaints.
class IndiaFlag extends StatelessWidget {
  const IndiaFlag({super.key, this.width = 28, this.height = 20});
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: CustomPaint(size: Size(width, height), painter: const _FlagPainter()),
        ),
      );
}

class _FlagPainter extends CustomPainter {
  const _FlagPainter();
  static final _saffron = Paint()..color = const Color(0xFFFF9933);
  static final _white = Paint()..color = Colors.white;
  static final _green = Paint()..color = const Color(0xFF138808);
  static final _chakra = Paint()
    ..color = const Color(0xFF000080)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.8;

  @override
  void paint(Canvas canvas, Size s) {
    final h = s.height / 3;
    canvas.drawRect(Rect.fromLTWH(0, 0, s.width, h), _saffron);
    canvas.drawRect(Rect.fromLTWH(0, h, s.width, h), _white);
    canvas.drawRect(Rect.fromLTWH(0, h * 2, s.width, h), _green);
    canvas.drawCircle(s.center(Offset.zero), h * 0.4, _chakra);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
