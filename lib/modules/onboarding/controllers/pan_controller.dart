import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/state/view_status.dart';
import '../../../routes/app_routes.dart';
import '../repositories/onboarding_repository.dart';

class PanController extends GetxController {
  PanController(this._repo);
  final OnboardingRepository _repo;

  static final _panRx = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');
  static const panLength = 10;

  // SECURITY: PAN lives only in this controller. Never cache it (Hive),
  // log it or put it in route arguments.
  final pan = TextEditingController();

  final status = ViewStatus.loading.obs;
  final verifying = false.obs;
  final canVerify = false.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    pan.addListener(_onChanged);
  }

  @override
  void onReady() {
    super.onReady();
    load();
  }

  /// GET /onboarding/pan -> already verified? skip straight ahead.
  Future<void> load() async {
    status.value = ViewStatus.loading;
    try {
      final verified = await _repo.fetchPanVerified();
      if (verified) {
        Get.offAllNamed(Routes.calculator);
        return;
      }
      status.value = ViewStatus.ready;
    } catch (_) {
      status.value = ViewStatus.error;
    }
  }

  void _onChanged() {
    if (error.value != null) error.value = null;
    final ok = pan.text.length == panLength;
    if (canVerify.value != ok) canVerify.value = ok; // notify only on flip
  }

  /// POST /onboarding/pan/verify
  Future<void> verify() async {
    if (verifying.value) return;
    final value = pan.text;
    if (!_panRx.hasMatch(value)) {
      HapticFeedback.mediumImpact();
      error.value = 'Enter a valid PAN, e.g. ABCDE1234F';
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    verifying.value = true;
    try {
      await _repo.verifyPan(value);
      // Register step finished: clear the stack so Back never returns here.
      Get.offAllNamed(Routes.calculator);
    } on OnboardingException catch (e) {
      HapticFeedback.mediumImpact();
      error.value = e.message;
    } catch (_) {
      error.value = 'Could not verify PAN. Please try again.';
    } finally {
      verifying.value = false;
    }
  }

  @override
  void onClose() {
    pan
      ..removeListener(_onChanged)
      ..dispose();
    super.onClose();
  }
}
