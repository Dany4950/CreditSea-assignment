import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;

import '../../routes/app_routes.dart';
import '../config/app_config.dart';
import '../services/cache_service.dart';
import '../services/secure_storage_service.dart';
import 'api_exception.dart';

class ApiClient extends GetxService {
  ApiClient({required SecureStorageService storage, required CacheService cache}) {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 20), // Render free tier cold start
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Accept': 'application/json'},
      ),
    )..interceptors.addAll([
        _AuthInterceptor(storage, cache),
        _CacheInterceptor(cache),
        if (kDebugMode) LogInterceptor(requestBody: true, responseBody: false),
      ]);
  }

  late final Dio dio;

  /// [cacheTtl] enables caching for this GET. [refresh] bypasses a fresh cache hit
  /// (pull-to-refresh) but still writes the new response back.
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? query,
    Duration? cacheTtl,
    bool refresh = false,
  }) =>
      _send(() => dio.get(
            path,
            queryParameters: query,
            options: Options(extra: {'ttl': cacheTtl?.inSeconds, 'refresh': refresh}),
          ));

  Future<dynamic> post(String path, {Object? data}) => _send(() => dio.post(path, data: data));
  Future<dynamic> put(String path, {Object? data}) => _send(() => dio.put(path, data: data));
  Future<dynamic> patch(String path, {Object? data}) => _send(() => dio.patch(path, data: data));

  Future<dynamic> _send(Future<Response<dynamic>> Function() call) async {
    try {
      return (await call()).data;
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }
}

/// Attaches the bearer token; on 401 wipes the session and returns to sign-in.
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
    // Only treat as "session expired" if we actually had a token
    // (a wrong password on sign-in is also a 401 but has no token yet).
    if (err.response?.statusCode == 401 && _storage.hasToken) {
      await _storage.clear();
      await _cache.clear();
      Get.offAllNamed(Routes.signIn);
    }
    handler.next(err);
  }
}

class _CacheInterceptor extends Interceptor {
  _CacheInterceptor(this._cache);
  final CacheService _cache;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final ttl = options.extra['ttl'] as int?;
    if (options.method == 'GET' && ttl != null && options.extra['refresh'] != true) {
      final hit = _cache.read(options.uri.toString(), Duration(seconds: ttl));
      if (hit != null) {
        return handler.resolve(Response(
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
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final o = response.requestOptions;
    if (o.method == 'GET' && o.extra['ttl'] != null && response.statusCode == 200) {
      _cache.write(o.uri.toString(), response.data);
    }
    handler.next(response);
  }
}
