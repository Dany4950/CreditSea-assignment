import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../repositories/auth_repository.dart';

class CreatePasswordController extends GetxController {
  CreatePasswordController(this._repo);
  final AuthRepository _repo;

  static final _special = RegExp(r'[^A-Za-z0-9]');
  static const minLength = 8;

  late final String mobile;
  final password = TextEditingController();
  final confirm = TextEditingController();
  final passFocus = FocusNode();
  final confirmFocus = FocusNode();

  final obscurePass = true.obs;
  final obscureConfirm = true.obs;
  final loading = false.obs;
  final ruleError = false.obs; // hint turns red
  final confirmError = RxnString();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    mobile = args is Map ? (args['mobile'] as String? ?? '') : '';
    password.addListener(_clearErrors);
    confirm.addListener(_clearErrors);
  }

  void _clearErrors() {
    if (ruleError.value) ruleError.value = false;
    if (confirmError.value != null) confirmError.value = null;
  }

  static bool _meetsRules(String p) => p.length >= minLength && _special.hasMatch(p);

  Future<void> submit() async {
    if (loading.value) return;
    final p = password.text;
    final c = confirm.text;

    final rulesOk = _meetsRules(p);
    ruleError.value = !rulesOk;
    confirmError.value = c.isEmpty
        ? 'Please re-enter your password'
        : (p != c ? 'Passwords do not match' : null);

    if (!rulesOk || confirmError.value != null) {
      HapticFeedback.mediumImpact();
      (rulesOk ? confirmFocus : passFocus).requestFocus();
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    loading.value = true;
    try {
      await _repo.setPassword(mobile: mobile, password: p);
      TextInput.finishAutofillContext();
      // Account created -> user signs in with the new credentials.
      Get.offAllNamed(Routes.signIn, arguments: {'mobile': mobile, 'registered': true});
    } catch (_) {
      confirmError.value = 'Could not set password. Please try again.';
    } finally {
      loading.value = false;
    }
  }

  @override
  void onClose() {
    password
      ..removeListener(_clearErrors)
      ..dispose();
    confirm
      ..removeListener(_clearErrors)
      ..dispose();
    passFocus.dispose();
    confirmFocus.dispose();
    super.onClose();
  }
}
