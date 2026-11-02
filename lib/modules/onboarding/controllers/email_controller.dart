import 'dart:async';
import 'package:creditsea/core/widgets/otp_notice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/state/view_status.dart';
import '../../../routes/app_routes.dart';
import '../repositories/onboarding_repository.dart';

class EmailController extends GetxController {
  EmailController(this._repo);
  final OnboardingRepository _repo;

  static const otpLength = 6;
  static const resendSeconds = 30;
  static final _emailRx = RegExp(r'^[\w.+\-]+@[\w\-]+(\.[\w\-]+)+$');

  final email = TextEditingController();
  final emailFocus = FocusNode();
  final otp = TextEditingController();
  final otpFocus = FocusNode();

  final status = ViewStatus.loading.obs;
  final otpSent = false.obs;
  final sending = false.obs;
  final verifying = false.obs;
  final canVerify = false.obs;
  final secondsLeft = 0.obs;
  final emailError = RxnString();
  final otpError = RxnString();

  Timer? _timer;

  String get timerLabel {
    final s = secondsLeft.value;
    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }

  bool get _emailValid => _emailRx.hasMatch(email.text.trim());

  @override
  void onInit() {
    super.onInit();
    email.addListener(_onEmailChanged);
    otp.addListener(_onOtpChanged);
    emailFocus.addListener(_onEmailFocus);
  }

  @override
  void onReady() {
    super.onReady();
    load();
  }

  /// GET /onboarding/email
  Future<void> load() async {
    status.value = ViewStatus.loading;
    try {
      final saved = await _repo.fetchEmail();
      if (saved != null) email.text = saved;
      status.value = ViewStatus.ready;
    } catch (_) {
      status.value = ViewStatus.error;
    }
  }

  void _onEmailChanged() {
    if (emailError.value != null) emailError.value = null;
    if (otpSent.value) _resetOtp(); // editing the email invalidates the code
    _recompute();
  }

  void _onOtpChanged() {
    if (otpError.value != null) otpError.value = null;
    _recompute();
  }

  void _onEmailFocus() {
    // Leaving the email field with a valid address sends the code.
    if (!emailFocus.hasFocus && !otpSent.value && email.text.trim().isNotEmpty) sendOtp();
  }

  void _recompute() {
    final ok = otpSent.value && _emailValid && otp.text.length == otpLength;
    if (canVerify.value != ok) canVerify.value = ok; // notify only on flip
  }

  void _resetOtp() {
    _timer?.cancel();
    secondsLeft.value = 0;
    otpSent.value = false;
    otp.clear();
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

  /// POST /onboarding/email/send-otp
  Future<void> sendOtp({bool manual = false}) async {
    if (sending.value) return;
    if (manual && secondsLeft.value > 0) return;
    if (!_emailValid) {
      emailError.value = 'Enter a valid email address';
      return;
    }
    sending.value = true;
    try {
      // The server answers with the code it issued (its OTP pool); null when it emailed a real code instead.
      final issuedOtp = await _repo.sendEmailOtp(email.text.trim());
      otp.clear();
      otpSent.value = true;
      _startTimer();
      _recompute();
      otpFocus.requestFocus();
      showOtpNotice(issuedOtp, onFill: (c) => otp.text = c);
    } on OnboardingException catch (e) {
      emailError.value = e.message;
    } catch (_) {
      emailError.value = 'Could not send the code. Please try again.';
    } finally {
      sending.value = false;
    }
  }

  /// POST /onboarding/email/verify
  Future<void> verify() async {
    if (verifying.value || !canVerify.value) return;
    FocusManager.instance.primaryFocus?.unfocus();
    verifying.value = true;
    try {
      await _repo.verifyEmailOtp(email.text.trim(), otp.text);
      Get.toNamed(Routes.pan);
    } on OnboardingException catch (e) {
      _failOtp(e.message);
    } catch (_) {
      _failOtp('Something went wrong. Please try again.');
    } finally {
      verifying.value = false;
    }
  }

  void _failOtp(String message) {
    HapticFeedback.heavyImpact();
    otp.clear(); // clear first: the listener resets the error
    otpError.value = message;
    otpFocus.requestFocus();
  }

  @override
  void onClose() {
    _timer?.cancel();
    emailFocus.removeListener(_onEmailFocus);
    email
      ..removeListener(_onEmailChanged)
      ..dispose();
    otp
      ..removeListener(_onOtpChanged)
      ..dispose();
    emailFocus.dispose();
    otpFocus.dispose();
    super.onClose();
  }
}
