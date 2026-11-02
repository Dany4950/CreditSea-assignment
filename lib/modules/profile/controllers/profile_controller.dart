import 'dart:async';

import 'package:creditsea/modules/loan/models/loan.dart';
import 'package:creditsea/modules/loan/repositories/loan_repository.dart';
import 'package:creditsea/modules/profile/models/user_profile.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/state/view_status.dart';
import '../../../../routes/app_routes.dart';

import '../repositories/profile_repository.dart';

class ProfileController extends GetxController {
  ProfileController(this._profiles, this._loans);
  final ProfileRepository _profiles;
  final LoanRepository _loans;

  static const _pageSize = 10;

  final scroll = ScrollController();

  // Each Rx feeds one tiny Obx.
  final status = ViewStatus.loading.obs;
  final profile = Rxn<UserProfile>();
  final loans = <Loan>[].obs;
  final total = 0.obs;
  final hasMore = true.obs;
  final loadingMore = false.obs;
  final loadMoreError = RxnString();
  final repayingId = RxnString();

  int _page = 1;

  @override
  void onInit() {
    super.onInit();
    scroll.addListener(_onScroll);
  }

  @override
  void onReady() {
    super.onReady();
    load();
  }

  /// GET /user/profile + GET /loans?page=1 in parallel.
  /// A cached first page is shown instantly and then revalidated silently (stale-while-revalidate).
  Future<void> load() async {
    status.value = ViewStatus.loading;
    try {
      final (p, page) = await (_profiles.fetchProfile(), _loans.fetchLoans(page: 1, limit: _pageSize)).wait;
      profile.value = p;
      _applyFirstPage(page.items, page.hasMore, page.total);
      status.value = ViewStatus.ready;
      if (page.fromCache) unawaited(_revalidate());
    } catch (_) {
      status.value = ViewStatus.error;
    }
  }

  /// Pull-to-refresh: bypasses the cache and replaces the list.
  Future<void> refresh() async {
    try {
      final (p, page) =
          await (_profiles.fetchProfile(), _loans.fetchLoans(page: 1, limit: _pageSize, refresh: true)).wait;
      profile.value = p;
      _applyFirstPage(page.items, page.hasMore, page.total);
    } catch (_) {
      _snack('Could not refresh', 'Please check your connection and try again');
    }
  }

  Future<void> _revalidate() async {
    try {
      final page = await _loans.fetchLoans(page: 1, limit: _pageSize, refresh: true);
      // If the user already scrolled and loaded more pages, do not yank the list from under them.
      if (_page == 1 && !loadingMore.value) _applyFirstPage(page.items, page.hasMore, page.total);
    } catch (_) {
      // keep showing the cached list
    }
  }

  void _applyFirstPage(List<Loan> items, bool more, int count) {
    _page = 1;
    loans.assignAll(items);
    hasMore.value = more;
    total.value = count;
    loadMoreError.value = null;
  }

  void _onScroll() {
    if (scroll.hasClients && scroll.position.extentAfter < 400) loadMore();
  }

  /// GET /loans?page=n+1 (infinite scroll)
  Future<void> loadMore() async {
    if (loadingMore.value || !hasMore.value || status.value != ViewStatus.ready) return;
    loadingMore.value = true;
    loadMoreError.value = null;
    try {
      final next = await _loans.fetchLoans(page: _page + 1, limit: _pageSize);
      final known = loans.map((l) => l.id).toSet(); // a new loan can shift pages -> avoid duplicates
      loans.addAll(next.items.where((l) => !known.contains(l.id)));
      _page = next.page;
      hasMore.value = next.hasMore;
      total.value = next.total;
    } on LoanException catch (e) {
      loadMoreError.value = e.message;
    } catch (_) {
      loadMoreError.value = 'Could not load more loans.';
    } finally {
      loadingMore.value = false;
    }
  }

  void retryLoadMore() => loadMore();

  /// POST /loans/:id/repay (mock payment) -> loan REPAID, credit score changes.
  Future<void> repay(Loan loan, String method) async {
    if (repayingId.value != null) return;
    repayingId.value = loan.id;
    try {
      final r = await _loans.repay(loan.id, method: method);
      final i = loans.indexWhere((l) => l.id == r.loan.id);
      if (i != -1) loans[i] = r.loan;
      try {
        profile.value = await _profiles.fetchProfile(); // refreshed credit score
      } catch (_) {/* the list already shows the repayment */}
      final sign = r.scoreChange > 0 ? '+' : '';
      _snack('Payment successful', 'Credit score $sign${r.scoreChange}  ->  ${r.creditScore}');
    } on LoanException catch (e) {
      _snack('Could not repay', e.message);
    } catch (_) {
      _snack('Could not repay', 'Please try again');
    } finally {
      repayingId.value = null;
    }
  }

  void openLoan(Loan loan) => Get.toNamed(Routes.status, arguments: {'loanId': loan.id});

  /// FAB: open the loan calculator (its Cancel button comes back here).
  void newLoan() => Get.toNamed(Routes.calculator);

  Future<void> confirmLogout() async {
    final ok = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Log out?'),
            content: const Text('You will need to sign in again to see your loans.'),
            actions: [
              TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
              TextButton(onPressed: () => Get.back(result: true), child: const Text('Log out')),
            ],
          ),
        ) ??
        false;
    if (ok) await _profiles.logout();
  }

  void _snack(String title, String message) => Get.snackbar(title, message,
      snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));

  @override
  void onClose() {
    scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.onClose();
  }
}
