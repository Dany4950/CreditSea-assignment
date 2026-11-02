import 'dart:async';
import 'package:creditsea/core/widgets/otp_notice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../repositories/auth_repository.dart';

class OtpController extends GetxController {
  OtpController(this._repo);
  final AuthRepository _repo;

  static const length = 4;
  static const resendSeconds = 30;

  late final String mobile;
  final otp = TextEditingController();
  final focus = FocusNode();

  // Each Rx feeds one tiny Obx.
  final secondsLeft = resendSeconds.obs;
  final loading = false.obs;
  final canVerify = false.obs;
  final error = RxnString();

  Timer? _timer;
  bool _resending = false;
  String? _issuedOtp; // the code the server issued for the request that opened this screen

  String get displayMobile => '+91 $mobile';

  String get timerLabel {
    final s = secondsLeft.value;
    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    mobile = args is Map ? (args['mobile'] as String? ?? '') : '';
    _issuedOtp = args is Map ? args['otp'] as String? : null;
    otp.addListener(_onChanged);
    _startTimer();
  }

  @override
  void onReady() {
    super.onReady();
    showOtpNotice(_issuedOtp, onFill: _fill); // like an incoming SMS; tap to fill the boxes
  }

  void _fill(String code) => otp.text = code;

  void _onChanged() {
    if (error.value != null) error.value = null;
    final ok = otp.text.length == length;
    if (canVerify.value != ok) canVerify.value = ok; // notify only on flip
  }

  void _startTimer() {
    _timer?.cancel();
    secondsLeft.value = resendSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsLeft.value <= 1) {
        secondsLeft.value = 0;
        t.cancel();
      } else {
        secondsLeft.value--;
      }
    });
  }

  Future<void> verify() async {
    if (loading.value || otp.text.length != length) return;
    FocusManager.instance.primaryFocus?.unfocus();
    loading.value = true;
    try {
      await _repo.verifyOtp(mobile, otp.text);
      // replace OTP so Back from password returns to Create Account
      Get.offNamed(Routes.createPassword, arguments: {'mobile': mobile});
    } on AuthException catch (e) {
      _fail(e.message);
    } catch (_) {
      _fail('Something went wrong. Please try again.');
    } finally {
      loading.value = false;
    }
  }

  void _fail(String message) {
    HapticFeedback.heavyImpact();
    otp.clear(); // clear first: the listener resets error
    error.value = message;
    focus.requestFocus();
  }

  Future<void> resend() async {
    if (secondsLeft.value > 0 || _resending) return;
    _resending = true;
    try {
      final code = await _repo.requestOtp(mobile);
      otp.clear();
      _startTimer();
      focus.requestFocus();
      showOtpNotice(code, onFill: _fill);
    } on AuthException catch (e) {
      error.value = e.message;
    } catch (_) {
      error.value = 'Could not resend OTP. Please try again.';
    } finally {
      _resending = false;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    otp
      ..removeListener(_onChanged)
      ..dispose();
    focus.dispose();
    super.onClose();
  }
}
