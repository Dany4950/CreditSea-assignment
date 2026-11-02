import 'package:flutter/material.dart';

/// Represents either a Material Icon or an image asset.
class AuthVisual {
  const AuthVisual.icon(this.icon) : imagePath = null;

  const AuthVisual.image(this.imagePath) : icon = null;

  final IconData? icon;
  final String? imagePath;

  bool get isIcon => icon != null;
  bool get isImage => imagePath != null;
}

/// Model for each onboarding/auth slide.
class AuthSlide {
  const AuthSlide({
    required this.visuals,
    required this.title,
    required this.subtitle,
    this.watermark,
  });

  /// Can contain both icons and images.
  final List<AuthVisual> visuals;

  /// Optional background/watermark visual.
  final AuthVisual? watermark;

  final String title;
  final String subtitle;

  bool get isGrid => visuals.length > 1;
}

/// Your onboarding slides.
const authSlides = <AuthSlide>[
  AuthSlide(
    visuals: [
      AuthVisual.image('assets/images/car.png'),
      AuthVisual.icon(Icons.two_wheeler_rounded),
      AuthVisual.icon(Icons.laptop_mac_rounded),
      AuthVisual.image('assets/images/mobile.png'),
    ],
    title: 'Flexible Loan Options',
    subtitle: 'Loan types to cater to different financial needs',
  ),
  AuthSlide(
    visuals: [
      AuthVisual.image('assets/images/loan_approval.png'),
    ],
    watermark: AuthVisual.icon(Icons.verified_outlined),
    title: 'Instant Loan Approval',
    subtitle: 'Users will receive approval within minutes',
  ),
  AuthSlide(
    visuals: [
      AuthVisual.image('assets/images/customer_care.png'),
    ],
    title: '24x7 Customer Care',
    subtitle: 'Dedicated customer support team',
  ),
];

/// Reusable widget that displays either an icon or an image.
class AuthVisualWidget extends StatelessWidget {
  const AuthVisualWidget({
    super.key,
    required this.visual,
    this.size = 48,
    this.color,
  });

  final AuthVisual visual;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (visual.isIcon) {
      return Icon(
        visual.icon,
        size: size,
        color: color,
      );
    }

    if (visual.isImage) {
      return Image.asset(
        visual.imagePath!,
        width: size,
        height: size,
        fit: BoxFit.fill,
      );
    }

    return const SizedBox.shrink();
  }
}
