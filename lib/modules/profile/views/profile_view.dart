import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/state/view_status.dart';
import '../controllers/profile_controller.dart';
import '../widgets/loan_card.dart';
import '../widgets/profile_skeleton.dart';
import '../widgets/profile_summary_card.dart';
import '../widgets/profile_ui.dart';
import '../widgets/repay_sheet.dart';

/// Full-screen profile: details filled earlier, credit score, and every loan (infinite scroll).
/// The FAB opens the loan calculator.
class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfileUi.pageBg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.newLoan,
        backgroundColor: ProfileUi.action,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New loan', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopBar(onLogout: controller.confirmLogout),
            Expanded(
              child: _Sheet(
                child: Obx(
                  () => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _body(controller.status.value),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(ViewStatus s) {
    if (s == ViewStatus.loading) return const ProfileSkeleton(key: ValueKey('loading'));
    if (s == ViewStatus.error) return _ErrorState(key: const ValueKey('error'), onRetry: controller.load);
    return _Content(key: const ValueKey('ready'), controller: controller);
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onLogout});
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(ProfileUi.pad, 8, 12, 12),
      child: Row(
        children: [
          const Expanded(
            child: Text('Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: ProfileUi.ink)),
          ),
          IconButton(
            onPressed: onLogout,
            tooltip: 'Log out',
            icon: const Icon(Icons.logout_rounded, color: ProfileUi.ink),
          ),
        ],
      ),
    );
  }
}

/// The big white card with rounded top corners (same as every other screen).
class _Sheet extends StatelessWidget {
  const _Sheet({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.vertical(top: Radius.circular(ProfileUi.sheetRadius));
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: radius,
        boxShadow: [BoxShadow(color: Color(0x14101828), blurRadius: 16, offset: Offset(0, -2))],
      ),
      child: ClipRRect(borderRadius: radius, child: child),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({super.key, required this.controller});
  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: ProfileUi.action,
      onRefresh: controller.refresh,
      child: CustomScrollView(
        controller: controller.scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(ProfileUi.pad, 24, ProfileUi.pad, 0),
            sliver: SliverToBoxAdapter(
              child: Obx(() {
                final p = controller.profile.value;
                return p == null ? const SizedBox.shrink() : RepaintBoundary(child: ProfileSummaryCard(profile: p));
              }),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(ProfileUi.pad, 24, ProfileUi.pad, 12),
            sliver: SliverToBoxAdapter(child: _SectionTitle(controller: controller)),
          ),
          Obx(() {
            final items = controller.loans.toList(growable: false);
            if (items.isEmpty) {
              return const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: ProfileUi.pad),
                sliver: SliverToBoxAdapter(child: _EmptyLoans()),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: ProfileUi.pad),
              sliver: SliverList.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final loan = items[i];
                  return RepaintBoundary(
                    child: LoanCard(
                      key: ValueKey(loan.id),
                      loan: loan,
                      repayingId: controller.repayingId,
                      onTap: () => controller.openLoan(loan),
                      onRepay: () => showRepaySheet(loan, onPay: (m) => controller.repay(loan, m)),
                    ),
                  );
                },
              ),
            );
          }),
          SliverToBoxAdapter(child: _ListFooter(controller: controller)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.controller});
  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text('Your loans', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ProfileUi.ink)),
        ),
        Obx(() => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: ProfileUi.tint, borderRadius: BorderRadius.circular(20)),
              child: Text(
                '${controller.total.value}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: ProfileUi.action),
              ),
            )),
      ],
    );
  }
}

/// Spinner while the next page loads, inline retry if it failed, space under the last card for the FAB.
class _ListFooter extends StatelessWidget {
  const _ListFooter({required this.controller});
  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final Widget top;
      if (controller.loadingMore.value) {
        top = const Padding(
          padding: EdgeInsets.only(top: 20),
          child: Center(
            child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5)),
          ),
        );
      } else if (controller.loadMoreError.value != null) {
        top = Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Center(
            child: TextButton.icon(
              onPressed: controller.retryLoadMore,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text('${controller.loadMoreError.value}  Tap to retry'),
            ),
          ),
        );
      } else {
        top = const SizedBox.shrink();
      }
      return Column(children: [top, const SizedBox(height: 112)]);
    });
  }
}

class _EmptyLoans extends StatelessWidget {
  const _EmptyLoans();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ProfileUi.radius),
        border: Border.all(color: ProfileUi.border),
      ),
      child: const Column(
        children: [
          Icon(Icons.receipt_long_rounded, size: 40, color: ProfileUi.muted),
          SizedBox(height: 12),
          Text('No loans yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ProfileUi.ink)),
          SizedBox(height: 4),
          Text(
            'Tap "New loan" to apply.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: ProfileUi.muted),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({super.key, required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ProfileUi.pad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 44, color: ProfileUi.muted),
            const SizedBox(height: 12),
            const Text("Couldn't load your profile",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ProfileUi.ink)),
            const SizedBox(height: 4),
            const Text(
              'Check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: ProfileUi.muted),
            ),
            const SizedBox(height: 20),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
