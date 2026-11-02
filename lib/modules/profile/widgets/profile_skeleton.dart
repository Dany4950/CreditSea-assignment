import 'package:flutter/material.dart';

import 'profile_ui.dart';

/// Loading placeholder: grey blocks that gently pulse (one controller, one RepaintBoundary).
class ProfileSkeleton extends StatefulWidget {
  const ProfileSkeleton({super.key});

  @override
  State<ProfileSkeleton> createState() => _ProfileSkeletonState();
}

class _ProfileSkeletonState extends State<ProfileSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat(reverse: true);
  late final Animation<double> _opacity = Tween<double>(begin: 0.45, end: 1).animate(
    CurvedAnimation(parent: _c, curve: Curves.easeInOut),
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: FadeTransition(
        opacity: _opacity,
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(ProfileUi.pad, 24, ProfileUi.pad, 24),
          children: const [
            Row(
              children: [
                _Block(width: 56, height: 56, radius: 28),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Block(width: 160, height: 18),
                      SizedBox(height: 8),
                      _Block(width: 110, height: 13),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _Block(height: 92, radius: ProfileUi.radius),
            SizedBox(height: 16),
            _Block(height: 196, radius: ProfileUi.radius),
            SizedBox(height: 24),
            _Block(width: 120, height: 18),
            SizedBox(height: 12),
            _Block(height: 150, radius: ProfileUi.radius),
            SizedBox(height: 12),
            _Block(height: 150, radius: ProfileUi.radius),
          ],
        ),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({this.width, required this.height, this.radius = 8});
  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(color: ProfileUi.border, borderRadius: BorderRadius.circular(radius)),
      );
}
