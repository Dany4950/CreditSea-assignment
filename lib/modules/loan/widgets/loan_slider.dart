import 'package:flutter/material.dart';
import '../../auth/widgets/auth_tokens.dart';

/// Figma slider: 15dp rounded bar, thin vertical handle, dot at the end.
class LoanSlider extends StatelessWidget {
  const LoanSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
    this.semanticFormatter,
  });

  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double>? onChanged;
  final String Function(double)? semanticFormatter;

  static const _inactive = Color(0xFFEEF3FF);

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 15,
        activeTrackColor: AuthTokens.actionBlue,
        inactiveTrackColor: _inactive,
        thumbColor: AuthTokens.actionBlue,
        overlayShape: SliderComponentShape.noOverlay,
        tickMarkShape: SliderTickMarkShape.noTickMark,
        trackShape: const _BarTrackShape(),
        thumbShape: const _BarThumbShape(),
        showValueIndicator: ShowValueIndicator.never,
      ),
      child: SizedBox(
        height: 34,
        child: Slider(
          value: value.clamp(min, max).toDouble(),
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
          semanticFormatterCallback: semanticFormatter,
        ),
      ),
    );
  }
}

class _BarThumbShape extends SliderComponentShape {
  const _BarThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(3, 34);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 3, height: 34),
      const Radius.circular(1.5),
    );
    context.canvas.drawRRect(rrect, Paint()..color = sliderTheme.thumbColor!);
  }
}

class _BarTrackShape extends SliderTrackShape with BaseSliderTrackShape {
  const _BarTrackShape();

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
  }) {
    final rect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    const r = Radius.circular(3);
    final canvas = context.canvas;
    final activePaint = Paint()..color = sliderTheme.activeTrackColor!;
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(rect.left, rect.top, thumbCenter.dx, rect.bottom,
          topLeft: r, bottomLeft: r),
      activePaint,
    );
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(thumbCenter.dx, rect.top, rect.right, rect.bottom,
          topRight: r, bottomRight: r),
      Paint()..color = sliderTheme.inactiveTrackColor!,
    );
    // end-of-track dot
    canvas.drawCircle(Offset(rect.right - 8, rect.center.dy), 2.5, activePaint);
  }
}
