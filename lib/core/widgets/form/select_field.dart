import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../modules/auth/widgets/auth_tokens.dart';
import 'form_tokens.dart';

/// Tappable field for dropdowns and the date picker.
class SelectField extends StatelessWidget {
  const SelectField({
    super.key,
    required this.hint,
    required this.onTap,
    this.value,
    this.icon = Icons.keyboard_arrow_down_rounded,
    this.hasError = false,
  });

  final String hint;
  final String? value;
  final VoidCallback onTap;
  final IconData icon;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(FormTokens.fieldRadius);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: radius,
        border: Border.all(color: hasError ? AuthTokens.error : FormTokens.border),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: SizedBox(
            height: FormTokens.fieldHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value ?? hint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        color: value == null ? AuthTokens.hint : FormTokens.ink,
                      ),
                    ),
                  ),
                  Icon(icon, size: 22, color: FormTokens.ink),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Modal list picker. Returns the chosen option or null if dismissed.
Future<String?> showOptionSheet({
  required String title,
  required List<String> options,
  String? selected,
}) {
  FocusManager.instance.primaryFocus?.unfocus();
  return Get.bottomSheet<String>(
    _OptionSheet(title: title, options: options, selected: selected),
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
  );
}

class _OptionSheet extends StatelessWidget {
  const _OptionSheet({required this.title, required this.options, this.selected});
  final String title;
  final List<String> options;
  final String? selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFFD9DEE5),
                borderRadius: BorderRadius.all(Radius.circular(2)),
              ),
              child: SizedBox(width: 40, height: 4),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(title,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final o in options)
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                      title: Text(o, style: const TextStyle(fontSize: 15)),
                      trailing: o == selected
                          ? const Icon(Icons.check_rounded, color: AuthTokens.actionBlue)
                          : null,
                      onTap: () => Get.back(result: o),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
