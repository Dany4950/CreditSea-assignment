import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;

import '../../routes/app_routes.dart';
import '../config/app_config.dart';
import '../services/cache_service.dart';
import '../services/secure_storage_service.dart';
import 'api_endpoints.dart';
import 'api_exception.dart';
import 'api_models.dart';

/// A parsed response plus where it came from.
class ApiResult<T> {
  const ApiResult(this.data, {this.fromCache = false});
  final T data;

  /// true when served from the local TTL cache (no network request was made).
  final bool fromCache;
}

/// The single HTTP entry point of the app.
///
///  - raw helpers (get/post/put/patch) return decoded JSON
///  - typed helpers (getObject/postObject/putObject) return a parsed model
///  - getObjectResult also tells whether the answer came from the cache
///  - every failure is thrown as [ApiException]
class ApiClient extends GetxService {
  ApiClient({required SecureStorageService storage, required CacheService cache}) {
    final d = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        // Render's free tier sleeps; the first request can take 30-50 s to wake it.
        connectTimeout: const Duration(seconds: 45),
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 45),
        headers: {'Accept': 'application/json'},
        contentType: Headers.jsonContentType,
      ),
    );
    d.interceptors.addAll([
      _AuthInterceptor(storage, cache),
      _CacheInterceptor(cache),
      _RetryInterceptor(d),
      if (kDebugMode) LogInterceptor(requestBody: true, responseBody: false),
    ]);
    dio = d;
  }

  late final Dio dio;

  /// Fire-and-forget at app start so the sleeping server is already awake when the user taps "Request OTP".
  Future<void> warmUp() async {
    try {
      await dio.get<dynamic>(ApiEndpoints.health, options: Options(receiveTimeout: const Duration(seconds: 60)));
    } catch (_) {/* best effort */}
  }

  // ------------------------------------------------------------------ raw

  /// [cacheTtl] enables caching of this GET. [refresh] bypasses a fresh cache hit (pull-to-refresh)
  /// but still stores the new response.
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? query,
    Duration? cacheTtl,
    bool refresh = false,
  }) async =>
      (await getResponse(path, query: query, cacheTtl: cacheTtl, refresh: refresh)).data;

  /// Like [get] but returns the whole response (its `extra['fromCache']` tells if the cache answered).
  Future<Response<dynamic>> getResponse(
    String path, {
    Map<String, dynamic>? query,
    Duration? cacheTtl,
    bool refresh = false,
  }) =>
      _sendResponse(() => dio.get<dynamic>(
            path,
            queryParameters: query,
            options: Options(extra: {'ttl': cacheTtl?.inSeconds, 'refresh': refresh}),
          ));

  Future<dynamic> post(String path, {Object? data}) => _send(() => dio.post<dynamic>(path, data: data));
  Future<dynamic> put(String path, {Object? data}) => _send(() => dio.put<dynamic>(path, data: data));
  Future<dynamic> patch(String path, {Object? data}) => _send(() => dio.patch<dynamic>(path, data: data));

  // ---------------------------------------------------------------- typed

  Future<T> getObject<T>(
    String path,
    FromJson<T> fromJson, {
    Map<String, dynamic>? query,
    Duration? cacheTtl,
    bool refresh = false,
  }) async =>
      fromJson(_asMap(await get(path, query: query, cacheTtl: cacheTtl, refresh: refresh)));

  Future<ApiResult<T>> getObjectResult<T>(
    String path,
    FromJson<T> fromJson, {
    Map<String, dynamic>? query,
    Duration? cacheTtl,
    bool refresh = false,
  }) async {
    final res = await getResponse(path, query: query, cacheTtl: cacheTtl, refresh: refresh);
    return ApiResult<T>(fromJson(_asMap(res.data)), fromCache: res.extra['fromCache'] == true);
  }

  Future<T> postObject<T>(String path, FromJson<T> fromJson, {Object? data}) async =>
      fromJson(_asMap(await post(path, data: data)));

  Future<T> putObject<T>(String path, FromJson<T> fromJson, {Object? data}) async =>
      fromJson(_asMap(await put(path, data: data)));

  // -------------------------------------------------------------- internal

  Future<dynamic> _send(Future<Response<dynamic>> Function() call) async => (await _sendResponse(call)).data;

  Future<Response<dynamic>> _sendResponse(Future<Response<dynamic>> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }

  Map<String, dynamic> _asMap(dynamic body) {
    if (body is Map<String, dynamic>) return body;
    if (body is Map) return Map<String, dynamic>.from(body);
    throw ApiException('Unexpected response from the server.');
  }
}

/// Attaches the bearer token; on 401 (with a stored token) wipes the session and returns to sign-in.
class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._storage, this._cache);
  final SecureStorageService _storage;
  final CacheService _cache;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final t = _storage.token;
    if (t != null) options.headers['Authorization'] = 'Bearer $t';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // A wrong password on sign-in is also a 401, but there is no stored token yet -> not a logout.
    if (err.response?.statusCode == 401 && _storage.hasToken) {
      await _storage.clear();
      await _cache.clear();
      Get.offAllNamed(Routes.signIn);
    }
    handler.next(err);
  }
}

/// TTL cache for GETs that opt in with `cacheTtl`.
class _CacheInterceptor extends Interceptor {
  _CacheInterceptor(this._cache);
  final CacheService _cache;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final ttl = options.extra['ttl'] as int?;
    if (options.method == 'GET' && ttl != null && options.extra['refresh'] != true) {
      final hit = _cache.read(options.uri.toString(), Duration(seconds: ttl));
      if (hit != null) {
        return handler.resolve(Response<dynamic>(
          requestOptions: options,
          data: hit,
          statusCode: 200,
          extra: {'fromCache': true},
        ));
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final o = response.requestOptions;
    if (o.method == 'GET' && o.extra['ttl'] != null && response.statusCode == 200) {
      _cache.write(o.uri.toString(), response.data);
    }
    handler.next(response);
  }
}

/// One retry for GETs that failed on a connection problem (typical during a Render cold start).
/// POST/PUT are never retried automatically: they are not idempotent (OTP sends, loan apply, repay).
class _RetryInterceptor extends Interceptor {
  _RetryInterceptor(this._dio);
  final Dio _dio;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final o = err.requestOptions;
    final attempt = (o.extra['retry'] as int?) ?? 0;
    final transient = err.type == DioExceptionType.connectionTimeout || err.type == DioExceptionType.connectionError;

    if (o.method == 'GET' && transient && attempt < 1) {
      await Future<void>.delayed(const Duration(seconds: 2));
      o.extra['retry'] = attempt + 1;
      try {
        handler.resolve(await _dio.fetch<dynamic>(o));
      } on DioException catch (e) {
        handler.next(e);
      }
      return;
    }
    handler.next(err);
  }
}
