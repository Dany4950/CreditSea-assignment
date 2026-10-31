import 'package:flutter/material.dart';
import 'shimmer.dart';

/// Generic loading placeholder for form screens: optional illustration block
/// followed by [fields] label+input pairs.
class FormSkeleton extends StatelessWidget {
  const FormSkeleton({super.key, this.fields = 4, this.hero = false});
  final int fields;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 0),
      child: Shimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hero) ...[
              const Center(child: _Bar(width: 170, height: 130, radius: 28)),
              const SizedBox(height: 36),
            ],
            for (var i = 0; i < fields; i++) ...[
              const _Bar(width: 96, height: 14, radius: 4),
              const SizedBox(height: 12),
              const _Bar(height: 48, radius: 8),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({this.width, required this.height, required this.radius});
  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      );
}
