import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import 'profile_ui.dart';

/// Avatar + name, credit score, and the details the user filled in during onboarding.
class ProfileSummaryCard extends StatelessWidget {
  const ProfileSummaryCard({super.key, required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final name = profile.fullName.isEmpty ? 'Your profile' : profile.fullName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _Avatar(initials: _initials(profile)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ProfileUi.ink),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '+91 ${profile.mobile}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: ProfileUi.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (profile.creditScore != null) ...[
          const SizedBox(height: 20),
          _ScoreCard(score: profile.creditScore!),
        ],
        const SizedBox(height: 16),
        _DetailsGrid(profile: profile),
      ],
    );
  }

  static String _initials(UserProfile p) {
    final a = (p.firstName ?? '').trim();
    final b = (p.lastName ?? '').trim();
    final s = '${a.isEmpty ? '' : a[0]}${b.isEmpty ? '' : b[0]}'.toUpperCase();
    return s.isEmpty ? '?' : s;
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials});
  final String initials;

  @override
  Widget build(BuildContext context) => Container(
        width: 56,
        height: 56,
        alignment: Alignment.center,
        decoration: const BoxDecoration(color: ProfileUi.tint, shape: BoxShape.circle),
        child: Text(
          initials,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: ProfileUi.action),
        ),
      );
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.score});
  final int score;

  static const _min = 300;
  static const _max = 900;

  String get _band {
    if (score >= 750) return 'Excellent';
    if (score >= 650) return 'Good';
    if (score >= 600) return 'Fair';
    return 'Low';
  }

  Color get _color {
    if (score >= 750) return ProfileUi.success;
    if (score >= 650) return ProfileUi.action;
    if (score >= 600) return const Color(0xFFB54708);
    return ProfileUi.error;
  }

  @override
  Widget build(BuildContext context) {
    final fraction = ((score - _min) / (_max - _min)).clamp(0.0, 1.0).toDouble();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ProfileUi.radius),
        border: Border.all(color: ProfileUi.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Text(
                  'Credit score',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ProfileUi.ink),
                ),
              ),
              Text('$score', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: _color, height: 1)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                child: Text(_band, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _color)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                Container(height: 8, color: ProfileUi.border),
                FractionallySizedBox(
                  widthFactor: fraction,
                  child: Container(
                    height: 8,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [ProfileUi.action, Color(0xFF3FA37A)]),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('300', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: ProfileUi.muted)),
              Text('900', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: ProfileUi.muted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailsGrid extends StatelessWidget {
  const _DetailsGrid({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final dob = profile.dobDate;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ProfileUi.radius),
        border: Border.all(color: ProfileUi.border),
      ),
      child: Column(
        children: [
          _Cell(label: 'Email', value: profile.email ?? '--', verified: profile.emailVerified),
          const _HLine(),
          Row(
            children: [
              Expanded(child: _Cell(label: 'Date of birth', value: ProfileUi.date(dob))),
              const _VLine(),
              Expanded(child: _Cell(label: 'Gender', value: profile.gender ?? '--')),
            ],
          ),
          const _HLine(),
          Row(
            children: [
              Expanded(child: _Cell(label: 'Marital status', value: profile.maritalStatus ?? '--')),
              const _VLine(),
              Expanded(child: _Cell(label: 'PAN', value: profile.panMasked ?? '--', verified: profile.panVerified)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.label, required this.value, this.verified = false});
  final String label;
  final String value;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: ProfileUi.muted)),
            const SizedBox(height: 4),
            Row(
              children: [
                Flexible(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ProfileUi.ink),
                  ),
                ),
                if (verified) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.verified_rounded, size: 16, color: ProfileUi.success),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HLine extends StatelessWidget {
  const _HLine();
  @override
  Widget build(BuildContext context) => const Divider(height: 1, thickness: 1, color: ProfileUi.border);
}

class _VLine extends StatelessWidget {
  const _VLine();
  @override
  Widget build(BuildContext context) => const SizedBox(
        width: 1,
        height: 64,
        child: ColoredBox(color: ProfileUi.border),
      );
}
