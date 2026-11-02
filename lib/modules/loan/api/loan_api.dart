import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_models.dart';
import '../../../core/services/cache_service.dart';
import 'dto/eligibility_dto.dart';
import 'dto/loan_dto.dart';
import 'dto/loan_requests.dart';

/// Remote data source for /loans/*. Returns wire DTOs; the repository adapter maps them to domain models.
class LoanApi {
  LoanApi(this._client, this._cache);
  final ApiClient _client;
  final CacheService _cache;

  /// Never cached: it changes the moment a loan is accepted.
  Future<EligibilityDto> eligibility() => _client.getObject(ApiEndpoints.eligibility, EligibilityDto.fromJson);

  Future<LoanQuoteDto> quote(QuoteRequest r) =>
      _client.postObject(ApiEndpoints.quote, LoanQuoteDto.fromJson, data: r.toJson());

  /// Creates (or replaces) the pending OFFER. 409 ACTIVE_LOAN_EXISTS, 422 AMOUNT_ABOVE_LIMIT / INVALID_TENURE.
  Future<LoanDto> apply(ApplyLoanRequest r) =>
      _client.postObject(ApiEndpoints.apply, LoanDto.fromJson, data: r.toJson());

  /// "Accept Offer": OFFERED -> SUBMITTED and the status engine starts. Safe to call twice.
  Future<LoanDto> accept(String id) async {
    final loan = await _client.postObject(ApiEndpoints.acceptLoan(id), LoanDto.fromJson, data: const <String, dynamic>{});
    await _cache.invalidate('/loans'); // My Loans must not show a stale first page
    return loan;
  }

  /// Infinite-scroll list (used by My Loans). Only page 1 is cached; `refresh: true` for pull-to-refresh.
  Future<PaginatedResponse<LoanDto>> list({int page = 1, int limit = 10, bool refresh = false}) =>
      _client.getObject<PaginatedResponse<LoanDto>>(
        ApiEndpoints.loans,
        (j) => PaginatedResponse<LoanDto>.fromJson(j, LoanDto.fromJson),
        query: {'page': page, 'limit': limit},
        cacheTtl: page == 1 ? AppCacheTtl.short : null,
        refresh: refresh,
      );

  /// Never cached: the status screen polls this every few seconds.
  Future<LoanDto> detail(String id) => _client.getObject(ApiEndpoints.loanById(id), LoanDto.fromJson);
}
