import 'package:flutter/material.dart';
import 'auth_bottom_sheet.dart';
import 'auth_header.dart';
import 'auth_tokens.dart';

/// Shared scaffold for all auth screens: fixed blue header (52% of height)
/// + bottom sheet that rides above the keyboard.
/// Pass [pager] for the live carousel, or [page] for a fixed slide.
class AuthShell extends StatelessWidget {
  const AuthShell({super.key, required this.child, this.page = 0, this.pager});
  final Widget child;
  final int page;
  final PageController? pager;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height; // size changes only

    return Scaffold(
      backgroundColor: AuthTokens.primaryDark,
      resizeToAvoidBottomInset: false, // keyboard handled below
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: height * 0.52,
              child: AuthHeader(page: page, pager: pager),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _KeyboardAvoider(
                child: AuthBottomSheet(minHeight: height * 0.478, child: child),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KeyboardAvoider extends StatelessWidget {
  const _KeyboardAvoider({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedPadding(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: child,
      );
}
