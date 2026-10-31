import 'package:flutter/material.dart';

/// One AnimationController + one ShaderMask for the whole skeleton,
/// isolated in a RepaintBoundary so only this subtree repaints.
/// Children must be solid white boxes (the gradient is painted over them).
class Shimmer extends StatefulWidget {
  const Shimmer({super.key, required this.child});
  final Widget child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        child: widget.child,
        builder: (_, child) => ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (rect) => LinearGradient(
            colors: const [Color(0xFFECEFF3), Color(0xFFF8F9FB), Color(0xFFECEFF3)],
            stops: const [0.3, 0.5, 0.7],
            transform: _Slide(-1 + 2 * _c.value),
          ).createShader(rect),
          child: child,
        ),
      ),
    );
  }
}

class _Slide extends GradientTransform {
  const _Slide(this.percent);
  final double percent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * percent, 0, 0);
}
