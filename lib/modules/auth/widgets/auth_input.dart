import 'package:flutter/material.dart';
import 'auth_tokens.dart';

const _radius = BorderRadius.all(Radius.circular(AuthTokens.fieldRadius));

OutlineInputBorder _border(Color c, [double w = 1]) =>
    OutlineInputBorder(borderRadius: _radius, borderSide: BorderSide(color: c, width: w));

/// Shared 50dp input decoration (use with textAlignVertical: center).
InputDecoration authInputDecoration({
  required String hint,
  Widget? suffix,
  bool error = false,
}) {
  final idle = error ? AuthTokens.error : AuthTokens.border;
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 16, color: AuthTokens.hint),
    suffixIcon: suffix,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
    border: _border(idle),
    enabledBorder: _border(idle),
    focusedBorder: _border(error ? AuthTokens.error : AuthTokens.actionBlue, 1.5),
  );
}
