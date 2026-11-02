import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../state/view_status.dart';
import 'api_exception.dart';

/// Generic API behaviour for any GetX controller:  `class X extends GetxController with ApiCaller`
///
/// 1) callApi  - run a request; on failure show the server message and return null
///      final res = await callApi(() => authApi.login(req));
///      if (res == null) return;
///
/// 2) loadInto - the screen "loader template": loading -> ready | error (shimmer / ErrorPanel + Retry)
///      Future<void> load() => loadInto(status, () => api.getPersonal(), onData: (d) => ...);
mixin ApiCaller on GetxController {
  Future<T?> callApi<T>(
    Future<T> Function() request, {
    void Function(ApiException e)? onError,
    bool showError = true,
  }) async {
    try {
      return await request();
    } on ApiException catch (e) {
      onError?.call(e);
      if (showError) showApiError(e);
      return null;
    }
  }

  Future<void> loadInto<T>(
    Rx<ViewStatus> status,
    Future<T> Function() request, {
    required void Function(T data) onData,
    void Function(ApiException e)? onError,
  }) async {
    status.value = ViewStatus.loading;
    try {
      onData(await request());
      status.value = ViewStatus.ready;
    } on ApiException catch (e) {
      onError?.call(e);
      status.value = ViewStatus.error;
    }
  }
}

/// One consistent error toast for the whole app.
void showApiError(ApiException e) {
  Get.closeAllSnackbars();
  Get.rawSnackbar(
    message: e.message,
    backgroundColor: const Color(0xFF111827),
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(16),
    borderRadius: 10,
    duration: const Duration(seconds: 3),
  );
}
