import 'package:flutter/material.dart';
import '../../modules/auth/widgets/auth_tokens.dart';

class ErrorPanel extends StatelessWidget {
  const ErrorPanel({super.key, this.onRetry, this.message = 'Something went wrong'});
  final VoidCallback? onRetry;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 44, color: AuthTokens.hint),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('Check your connection and try again',
              style: TextStyle(fontSize: 13, color: AuthTokens.textMuted)),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: AuthTokens.actionBlue,
                side: const BorderSide(color: AuthTokens.actionBlue),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}
