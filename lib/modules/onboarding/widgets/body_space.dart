import 'package:flutter/widgets.dart';

/// Height (dp) of everything around a CardShell body that uses a StepHeader and
/// a pinned 48dp footer button:
///   header 16 + 24 + 36, title row 12 + 48, body padding 12 + 24,
///   footer padding 16 + button 48 + 20  = 256 (+ system insets).
const double kCardChrome = 256;

/// Illustration height that leaves at least [minGap] dp between the form content
/// and the pinned button. The Figma frame is taller than real phones, so on a
/// normal phone the illustration shrinks a little (never below [min]) to keep the
/// generous Figma gap above the button; on tall screens it stays at [max].
///
/// [fixed] = height of everything in the body except the illustration.
double fitIllustration(
  BuildContext context, {
  required int fixed,
  required double max,
  double min = 80,
  double minGap = 88,
}) {
  final size = MediaQuery.sizeOf(context);
  final pad = MediaQuery.paddingOf(context);
  final space = size.height - pad.top - pad.bottom - kCardChrome;
  return (space - fixed - minGap).clamp(min, max).toDouble();
}
