import 'package:flutter/material.dart';
import 'auth_tokens.dart';

/// White rounded sheet with a thin blue-to-teal gradient top edge.
/// Scrolls if content + keyboard exceed the screen (small phones).
class AuthBottomSheet extends StatelessWidget {
  const AuthBottomSheet({super.key, required this.child, this.minHeight = 0});
  final Widget child;
  final double minHeight;

  static const _top = BorderRadius.vertical(top: Radius.circular(AuthTokens.sheetRadius));

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          borderRadius: _top,
          gradient: LinearGradient(colors: [Color(0xFF3B8BFF), Color(0xFF3FB6A8)]),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: DecoratedBox(
            decoration: const BoxDecoration(color: Colors.white, borderRadius: _top),
            child: SizedBox(
              width: double.infinity,
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(
                      AuthTokens.pagePadding, 20, AuthTokens.pagePadding, 20),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
