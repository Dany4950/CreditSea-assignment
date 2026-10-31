import 'package:flutter/material.dart';

/// Gradient-bordered summary card (Principle / Interest / Total Payable).
class SummaryBox extends StatelessWidget {
  const SummaryBox({super.key, required this.rows});
  final List<(String, String)> rows;

  static const _valueColor = Color(0xFF2F6BFF);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: const LinearGradient(colors: [Color(0xFF3B8BFF), Color(0xFF3FB6A8)]),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(2),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0) const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(rows[i].$1,
                          style: const TextStyle(fontSize: 16, color: Color(0xFF111827))),
                      Text(rows[i].$2,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600, color: _valueColor)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
