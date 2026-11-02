import 'loan.dart';

/// One page of "My Loans".
class LoanPage {
  const LoanPage({
    required this.items,
    required this.page,
    required this.hasMore,
    required this.total,
    this.fromCache = false,
  });

  final List<Loan> items;
  final int page;
  final bool hasMore;
  final int total;

  /// Served from the local cache (the UI shows it instantly, then refreshes silently).
  final bool fromCache;
}
