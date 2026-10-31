import 'package:intl/intl.dart';

final NumberFormat _inr = NumberFormat.decimalPattern('en_IN');

/// 100000 -> ₹1,00,000
String inr(int v) => '₹${_inr.format(v)}';

/// 30000 -> ₹ 30,000
String inrSpaced(int v) => '₹ ${_inr.format(v)}';

/// 10600 -> Rs. 10,600
String rs(int v) => 'Rs. ${_inr.format(v)}';
