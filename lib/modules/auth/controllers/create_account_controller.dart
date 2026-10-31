import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../repositories/auth_repository.dart';

class CreateAccountController extends GetxController {
  CreateAccountController(this._repo);
  final AuthRepository _repo;

  static final _mobileRx = RegExp(r'^[6-9]\d{9}$');
  static const slideCount = 3;

  final mobile = TextEditingController();
  final pager = PageController();

  // Each Rx is read by exactly one tiny Obx, so a change rebuilds one widget.
  final agreed = true.obs;
  final loading = false.obs;
  final canSubmit = false.obs;
  final error = RxnString();

  Timer? _autoSlide;

  @override
  void onInit() {
    super.onInit();
    mobile.addListener(_onMobileChanged);
  }

  @override
  void onReady() {
    super.onReady();
    _autoSlide = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!pager.hasClients) return;
      final next = ((pager.page ?? 0).round() + 1) % slideCount;
      pager.animateToPage(next,
          duration: const Duration(milliseconds: 450), curve: Curves.easeOutCubic);
    });
  }

  bool get _isValid => _mobileRx.hasMatch(mobile.text);

  void _onMobileChanged() {
    if (error.value != null) error.value = null;
    final ok = _isValid && agreed.value;
    if (canSubmit.value != ok) canSubmit.value = ok; // notify only on flip
  }

  void toggleAgreed() {
    HapticFeedback.selectionClick();
    agreed.toggle();
    _onMobileChanged();
  }

  Future<void> requestOtp() async {
    if (loading.value) return;
    if (!_isValid) {
      error.value = 'Enter a valid 10-digit mobile number';
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    loading.value = true;
    try {
      await _repo.requestOtp(mobile.text);
      Get.toNamed(Routes.otp, arguments: {'mobile': mobile.text});
    } catch (_) {
      error.value = 'Could not send OTP. Please try again.';
    } finally {
      loading.value = false;
    }
  }

  void goToSignIn() => Get.toNamed(Routes.signIn);

  @override
  void onClose() {
    _autoSlide?.cancel();
    mobile
      ..removeListener(_onMobileChanged)
      ..dispose();
    pager.dispose();
    super.onClose();
  }
}
