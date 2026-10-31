import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../repositories/auth_repository.dart';

class SignInController extends GetxController {
  SignInController(this._repo);
  final AuthRepository _repo;

  static final _mobileRx = RegExp(r'^[6-9]\d{9}$');

  final mobile = TextEditingController();
  final password = TextEditingController();
  final passFocus = FocusNode();

  final obscure = true.obs;
  final loading = false.obs;
  final canSubmit = false.obs;
  final error = RxnString();

  bool _justRegistered = false;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      mobile.text = args['mobile'] as String? ?? '';
      _justRegistered = args['registered'] == true;
    }
    mobile.addListener(_onChanged);
    password.addListener(_onChanged);
    canSubmit.value = _valid; // prefilled mobile + empty password -> false
  }

  @override
  void onReady() {
    super.onReady();
    if (_justRegistered) {
      Get.snackbar(
        'Account created',
        'Please sign in with your new password',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    }
    if (mobile.text.isNotEmpty) passFocus.requestFocus();
  }

  bool get _valid => _mobileRx.hasMatch(mobile.text) && password.text.isNotEmpty;

  void _onChanged() {
    if (error.value != null) error.value = null;
    final ok = _valid;
    if (canSubmit.value != ok) canSubmit.value = ok; // notify only on flip
  }

  Future<void> submit() async {
    if (loading.value) return;
    if (!_valid) {
      error.value = 'Enter a valid mobile number and password';
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    loading.value = true;
    try {
      final profileComplete =
          await _repo.signIn(mobile: mobile.text, password: password.text);
      Get.offAllNamed(profileComplete ? Routes.calculator : Routes.personalDetails);
    } on AuthException catch (e) {
      HapticFeedback.mediumImpact();
      error.value = e.message;
    } catch (_) {
      error.value = 'Something went wrong. Please try again.';
    } finally {
      loading.value = false;
    }
  }

  // TODO: mobile-OTP password reset flow.
  void forgotPassword() => Get.snackbar(
        'Coming soon',
        'Password reset will be available shortly',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );

  void goToCreateAccount() => Get.offNamed(Routes.createAccount);

  @override
  void onClose() {
    mobile
      ..removeListener(_onChanged)
      ..dispose();
    password
      ..removeListener(_onChanged)
      ..dispose();
    passFocus.dispose();
    super.onClose();
  }
}
