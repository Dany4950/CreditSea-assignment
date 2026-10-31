import 'package:flutter/material.dart';

class AuthSlide {
  const AuthSlide({
    required this.icons,
    required this.title,
    required this.subtitle,
    this.watermark,
  });
  final List<IconData> icons;
  final IconData? watermark;
  final String title;
  final String subtitle;
  bool get isGrid => icons.length > 1;
}

/// Copy taken verbatim from Figma. Swap Material icons for the exported SVGs
/// (flutter_svg) when assets are ready.
const authSlides = <AuthSlide>[
  AuthSlide(
    icons: [
      Icons.directions_car_rounded,
      Icons.two_wheeler_rounded,
      Icons.laptop_mac_rounded,
      Icons.smartphone_rounded,
    ],
    title: 'Flexible Loan Options',
    subtitle: 'Loan types to cater to different financial needs',
  ),
  AuthSlide(
    icons: [Icons.description_outlined],
    watermark: Icons.verified_outlined,
    title: 'Instant Loan Approval',
    subtitle: 'Users will receive approval within minutes',
  ),
  AuthSlide(
    icons: [Icons.support_agent_rounded],
    watermark: Icons.thumb_up_alt_outlined,
    title: '24x7 Customer Care',
    subtitle: 'Dedicated customer support team',
  ),
];
