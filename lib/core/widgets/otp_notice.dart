import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Shows the code the server just issued, like an incoming SMS notification
/// (the app has no SMS provider). Tapping it fills the OTP box via [onFill].
/// Does nothing when [code] is null, i.e. when the server delivered a real SMS/email instead.
void showOtpNotice(String? code, {required void Function(String code) onFill}) {
  if (code == null || code.isEmpty) return;
  Get.closeAllSnackbars();
  Get.snackbar(
    'CreditSea',
    '$code is your verification code. Valid for 5 minutes. Tap to fill it in.',
    snackPosition: SnackPosition.TOP,
    margin: const EdgeInsets.all(12),
    borderRadius: 14,
    backgroundColor: const Color(0xFF111827),
    colorText: Colors.white,
    icon: const Icon(Icons.sms_rounded, color: Colors.white),
    duration: const Duration(seconds: 10),
    onTap: (_) {
      Get.closeAllSnackbars();
      onFill(code);
    },
  );
}
