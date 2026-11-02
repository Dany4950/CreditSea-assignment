/// Parses a JSON object into a model.
typedef FromJson<T> = T Function(Map<String, dynamic> json);

int asInt(dynamic v, [int fallback = 0]) => v is num ? v.toInt() : fallback;
String? asStringOrNull(dynamic v) => v is String ? v : null;
DateTime? asDate(dynamic v) => v is String ? DateTime.tryParse(v)?.toLocal() : null;

/// `{ "message": "..." }` (set-password, logout, ...)
class MessageResponse {
  const MessageResponse(this.message);
  final String message;
  factory MessageResponse.fromJson(Map<String, dynamic> j) => MessageResponse(j['message'] as String? ?? '');
}

/// `{ items, page, limit, total, hasMore }`
class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.hasMore,
  });

  final List<T> items;
  final int page;
  final int limit;
  final int total;
  final bool hasMore;

  factory PaginatedResponse.fromJson(Map<String, dynamic> j, FromJson<T> parse) {
    final raw = (j['items'] as List?) ?? const [];
    return PaginatedResponse<T>(
      items: raw.map((e) => parse(Map<String, dynamic>.from(e as Map))).toList(growable: false),
      page: asInt(j['page'], 1),
      limit: asInt(j['limit'], 10),
      total: asInt(j['total']),
      hasMore: j['hasMore'] == true,
    );
  }
}

/// Response of every "send OTP" call (mobile signup and email verification).
/// `otp` is only present when the server runs in demo mode without a real SMS/email provider.
class OtpSentResponse {
  const OtpSentResponse({required this.message, this.otp});
  final String message;
  final String? otp;
  factory OtpSentResponse.fromJson(Map<String, dynamic> j) =>
      OtpSentResponse(message: j['message'] as String? ?? 'OTP sent', otp: asStringOrNull(j['otp']));
}
