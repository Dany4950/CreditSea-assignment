import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Design tokens used by the Profile screen (same values as the rest of the app).
abstract final class ProfileUi {
  static const pageBg = Color(0xFFF7F8FA);
  static const ink = Color(0xFF111827);
  static const muted = Color(0xFF667085);
  static const border = Color(0xFFEAECF0);
  static const action = Color(0xFF0075FF);
  static const success = Color(0xFF2E9E5B);
  static const error = Color(0xFFD32F2F);
  static const tint = Color(0xFFEFF4FF);

  static const double pad = 24; // horizontal page padding
  static const double radius = 16; // cards / fields
  static const double sheetRadius = 28; // big white card

  static final NumberFormat _inr = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
  static final DateFormat _date = DateFormat('dd MMM yyyy');

  static String inr(num v) => _inr.format(v);
  static String date(DateTime? d) => d == null ? '--' : _date.format(d);
}
