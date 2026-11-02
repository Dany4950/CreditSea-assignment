import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../state/view_status.dart';
import 'error_panel.dart';
import 'form/form_tokens.dart';
import 'form_skeleton.dart';

/// THE template for card-style screens (onboarding, calculator, offer, status).
///  - [header] sits above a rounded white card (StepHeader, logo, ...)
///  - optional title row (+ back arrow), scrollable body, pinned footer
///  - pass [status] for the loader template: skeleton shimmer while the screen's
///    API call runs, cross-fade to content, error panel with retry; the footer is
///    dimmed and disabled until the status is `ready`.
///  - [expandBody] lets the body use Spacers to fill the viewport (offer screen).
///
/// The body is wrapped in [Expanded], so it takes all remaining height and the
/// footer is always pinned to the bottom of the screen (above the keyboard /
/// home indicator), no matter how short the body content is.
class CardShell extends StatelessWidget {
  const CardShell({
    super.key,
    required this.header,
    required this.body,
    required this.footer,
    this.title,
    this.onBack,
    this.headerGap = 36,
    this.status,
    this.onRetry,
    this.skeleton,
    this.expandBody = false,
  });

  final Widget header;
  final double headerGap;
  final String? title;
  final VoidCallback? onBack;
  final Widget body;
  final Widget footer;
  final Rx<ViewStatus>? status;
  final VoidCallback? onRetry;
  final Widget? skeleton;
  final bool expandBody;

  static const _cardShape = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    boxShadow: [
      BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, -2))
    ],
  );

  static const _bodyPadding = EdgeInsets.fromLTRB(
      FormTokens.pagePadding, 12, FormTokens.pagePadding, 16);

  Widget _scrollBody() => expandBody
      ? CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverPadding(
              padding: _bodyPadding,
              sliver: SliverFillRemaining(hasScrollBody: false, child: body),
            ),
          ],
        )
      : SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: _bodyPadding,
          child: body,
        );

  Widget _stateChild(ViewStatus s) => switch (s) {
        ViewStatus.loading => KeyedSubtree(
            key: const ValueKey('loading'),
            child: skeleton ?? const FormSkeleton()),
        ViewStatus.error => KeyedSubtree(
            key: const ValueKey('error'), child: ErrorPanel(onRetry: onRetry)),
        ViewStatus.ready =>
          KeyedSubtree(key: const ValueKey('ready'), child: _scrollBody()),
      };

  /// Fills all remaining height between the title row and the footer.
  Widget _content(Rx<ViewStatus>? st) => Expanded(
        child: st == null
            ? _scrollBody()
            : Obx(() => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  // Stack must fill the Expanded area so every state
                  // (skeleton / error / ready) is laid out against full height.
                  layoutBuilder: (current, previous) => Stack(
                    fit: StackFit.expand,
                    children: [...previous, if (current != null) current],
                  ),
                  child: _stateChild(st.value),
                )),
      );

  Widget _footer(Rx<ViewStatus>? st) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              FormTokens.pagePadding, 8, FormTokens.pagePadding, 20),
          child: st == null
              ? footer
              : Obx(() {
                  final ready = st.value == ViewStatus.ready;
                  return IgnorePointer(
                    ignoring: !ready,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: ready ? 1 : 0.5,
                      child: footer,
                    ),
                  );
                }),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final st = status;
    return Scaffold(
      backgroundColor: FormTokens.background,
      resizeToAvoidBottomInset: true, // footer rides above the keyboard
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 16),
              header,
              SizedBox(height: headerGap),
              Expanded(
                child: DecoratedBox(
                  decoration: _cardShape,
                  child: Column(
                    children: [
                      if (title != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                              FormTokens.pagePadding,
                              12,
                              FormTokens.pagePadding,
                              0),
                          child: _TitleRow(title: title!, onBack: onBack),
                        ),
                      _content(st), // Expanded -> pushes footer to the bottom
                      _footer(st), // pinned
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  const _TitleRow({required this.title, this.onBack});
  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          if (onBack != null) ...[
            IconButton(
              onPressed: onBack,
              tooltip: 'Back',
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 40),
              icon: const Icon(Icons.arrow_back_rounded,
                  size: 24, color: FormTokens.ink),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: FormTokens.ink)),
          ),
        ],
      ),
    );
  }
}