import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../auth/widgets/auth_tokens.dart';

const _monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const _weekdayInitials = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
const _ink = Color(0xFF1F2937);
const _faded = Color(0xFFB7BECB);
const _surface = Color(0xFFEEF3FF);
const _pickerWidth = 252.0;
const _pickerHeight = 322.0;

DateTime _d(DateTime x) => DateTime(x.year, x.month, x.day);

/// Docked calendar popup (252x322) anchored under [anchorKey]'s widget, as in
/// the Figma: month and year dropdowns with chevrons, day grid, Clear/Cancel/OK.
/// Returns the picked date, or null if cancelled; [onClear] runs on Clear.
Future<DateTime?> showDockedDatePicker({
  required BuildContext context,
  required GlobalKey anchorKey,
  required DateTime firstDate,
  required DateTime lastDate,
  DateTime? selected,
  DateTime? initialView,
  VoidCallback? onClear,
}) {
  final box = anchorKey.currentContext?.findRenderObject() as RenderBox?;
  if (box == null || !box.attached) return Future.value(null);
  final anchor = box.localToGlobal(Offset.zero) & box.size;

  return showGeneralDialog<DateTime>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close calendar',
    barrierColor: const Color(0x14000000),
    transitionDuration: const Duration(milliseconds: 160),
    pageBuilder: (ctx, _, __) => _DockedLayout(
      anchor: anchor,
      child: _DockedDatePicker(
        firstDate: _d(firstDate),
        lastDate: _d(lastDate),
        selected: selected,
        initialView: initialView,
        onClear: onClear,
      ),
    ),
    transitionBuilder: (ctx, anim, _, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOut);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
          alignment: Alignment.topCenter,
          child: child,
        ),
      );
    },
  );
}

class _DockedLayout extends StatelessWidget {
  const _DockedLayout({required this.anchor, required this.child});
  final Rect anchor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final width = math.min(_pickerWidth, mq.size.width - 32);
    final left = (anchor.center.dx - width / 2)
        .clamp(16.0, math.max(16.0, mq.size.width - width - 16))
        .toDouble();
    final below = anchor.bottom + 4;
    final fitsBelow = below + _pickerHeight <= mq.size.height - mq.padding.bottom - 8;
    final top = fitsBelow
        ? below
        : math.max(mq.padding.top + 8, anchor.top - 4 - _pickerHeight);
    return Stack(
      children: [
        Positioned(left: left, top: top, width: width, height: _pickerHeight, child: child),
      ],
    );
  }
}

enum _Mode { days, months, years }

class _DockedDatePicker extends StatefulWidget {
  const _DockedDatePicker({
    required this.firstDate,
    required this.lastDate,
    this.selected,
    this.initialView,
    this.onClear,
  });
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? selected;
  final DateTime? initialView;
  final VoidCallback? onClear;

  @override
  State<_DockedDatePicker> createState() => _DockedDatePickerState();
}

class _DockedDatePickerState extends State<_DockedDatePicker> {
  late DateTime _view; // first day of the visible month
  DateTime? _selected;
  _Mode _mode = _Mode.days;
  late final List<int> _years;
  late final ScrollController _yearScroll;

  DateTime get _firstMonth => DateTime(widget.firstDate.year, widget.firstDate.month);
  DateTime get _lastMonth => DateTime(widget.lastDate.year, widget.lastDate.month);

  @override
  void initState() {
    super.initState();
    _selected = widget.selected == null ? null : _d(widget.selected!);
    final seed = widget.selected ?? widget.initialView ?? widget.lastDate;
    _view = _clamp(DateTime(seed.year, seed.month));
    _years = [for (var y = widget.lastDate.year; y >= widget.firstDate.year; y--) y];
    final row = math.max(0, _years.indexOf(_view.year)) ~/ 3;
    _yearScroll = ScrollController(initialScrollOffset: math.max(0, row * 40.0 - 40));
  }

  @override
  void dispose() {
    _yearScroll.dispose();
    super.dispose();
  }

  DateTime _clamp(DateTime v) =>
      v.isBefore(_firstMonth) ? _firstMonth : (v.isAfter(_lastMonth) ? _lastMonth : v);

  void _shiftMonth(int delta) =>
      setState(() => _view = _clamp(DateTime(_view.year, _view.month + delta)));

  void _shiftYear(int delta) =>
      setState(() => _view = _clamp(DateTime(_view.year + delta, _view.month)));

  void _toggle(_Mode m) => setState(() => _mode = _mode == m ? _Mode.days : m);

  bool get _canPrevMonth => _view.isAfter(_firstMonth);
  bool get _canNextMonth => _view.isBefore(_lastMonth);
  bool get _canPrevYear => _view.year > _firstMonth.year;
  bool get _canNextYear => _view.year < _lastMonth.year;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _surface,
      elevation: 8,
      shadowColor: const Color(0x33000000),
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          const SizedBox(height: 6),
          _header(),
          const SizedBox(height: 8),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: KeyedSubtree(key: ValueKey(_mode), child: _body()),
            ),
          ),
          _actions(),
        ],
      ),
    );
  }

  Widget _header() {
    return SizedBox(
      height: 32,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              _Chevron(icon: Icons.chevron_left_rounded, onTap: _canPrevMonth ? () => _shiftMonth(-1) : null),
              _DropLabel(
                text: _monthNames[_view.month - 1],
                active: _mode == _Mode.months,
                onTap: () => _toggle(_Mode.months),
              ),
              _Chevron(icon: Icons.chevron_right_rounded, onTap: _canNextMonth ? () => _shiftMonth(1) : null),
            ]),
            Row(children: [
              _Chevron(icon: Icons.chevron_left_rounded, onTap: _canPrevYear ? () => _shiftYear(-1) : null),
              _DropLabel(
                text: '${_view.year}',
                active: _mode == _Mode.years,
                onTap: () => _toggle(_Mode.years),
              ),
              _Chevron(icon: Icons.chevron_right_rounded, onTap: _canNextYear ? () => _shiftYear(1) : null),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _body() => switch (_mode) {
        _Mode.days => _days(),
        _Mode.months => _months(),
        _Mode.years => _yearsGrid(),
      };

  Widget _days() {
    final offset = _view.weekday % 7; // Sunday = 0
    final first = widget.firstDate;
    final last = widget.lastDate;
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 30,
              child: Row(children: [
                for (final w in _weekdayInitials)
                  Expanded(
                    child: Center(
                      child: Text(w,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500, color: _ink)),
                    ),
                  ),
              ]),
            ),
            const SizedBox(height: 2),
            for (var r = 0; r < 6; r++)
              SizedBox(
                height: 33,
                child: Row(children: [
                  for (var c = 0; c < 7; c++)
                    Expanded(
                      child: Builder(builder: (_) {
                        final date = DateTime(_view.year, _view.month, 1 - offset + r * 7 + c);
                        final inMonth = date.month == _view.month;
                        final enabled = inMonth && !date.isBefore(first) && !date.isAfter(last);
                        final isSel = _selected != null && _selected == date;
                        return _DayCell(
                          day: date.day,
                          enabled: enabled,
                          faded: !enabled,
                          selected: isSel,
                          onTap: () => setState(() => _selected = date),
                        );
                      }),
                    ),
                ]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _months() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          for (var r = 0; r < 4; r++)
            SizedBox(
              height: 52,
              child: Row(children: [
                for (var c = 0; c < 3; c++)
                  Expanded(
                    child: Builder(builder: (_) {
                      final m = r * 3 + c + 1;
                      final target = DateTime(_view.year, m);
                      final enabled =
                          !target.isBefore(_firstMonth) && !target.isAfter(_lastMonth);
                      final current = m == _view.month;
                      return _PickCell(
                        label: _monthNames[m - 1],
                        current: current,
                        enabled: enabled,
                        onTap: () => setState(() {
                          _view = target;
                          _mode = _Mode.days;
                        }),
                      );
                    }),
                  ),
              ]),
            ),
        ],
      ),
    );
  }

  Widget _yearsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        controller: _yearScroll,
        padding: EdgeInsets.zero,
        itemCount: _years.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, mainAxisExtent: 40),
        itemBuilder: (_, i) {
          final y = _years[i];
          return _PickCell(
            label: '$y',
            current: y == _view.year,
            enabled: true,
            onTap: () => setState(() {
              _view = _clamp(DateTime(y, _view.month));
              _mode = _Mode.days;
            }),
          );
        },
      ),
    );
  }

  Widget _actions() {
    const style = TextStyle(fontSize: 12, fontWeight: FontWeight.w600);
    ButtonStyle btn() => TextButton.styleFrom(
          foregroundColor: AuthTokens.actionBlue,
          minimumSize: const Size(0, 32),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
    return SizedBox(
      height: 40,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            TextButton(
              style: btn(),
              onPressed: () {
                widget.onClear?.call();
                Navigator.of(context).pop();
              },
              child: const Text('Clear', style: style),
            ),
            const Spacer(),
            TextButton(
              style: btn(),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: style),
            ),
            TextButton(
              style: btn(),
              onPressed: _selected == null ? null : () => Navigator.of(context).pop(_selected),
              child: const Text('OK', style: style),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkResponse(
        onTap: onTap,
        radius: 16,
        child: SizedBox(
          width: 28,
          height: 32,
          child: Icon(icon, size: 20, color: onTap == null ? _faded : _ink),
        ),
      );
}

class _DropLabel extends StatelessWidget {
  const _DropLabel({required this.text, required this.active, required this.onTap});
  final String text;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(text,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: active ? AuthTokens.actionBlue : _ink)),
              Icon(active ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
                  size: 18, color: active ? AuthTokens.actionBlue : _ink),
            ],
          ),
        ),
      );
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.enabled,
    required this.faded,
    required this.selected,
    required this.onTap,
  });
  final int day;
  final bool enabled;
  final bool faded;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: enabled ? onTap : null,
      radius: 16,
      child: Center(
        child: selected
            ? DecoratedBox(
                decoration: const BoxDecoration(color: AuthTokens.actionBlue, shape: BoxShape.circle),
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: Center(
                    child: Text('$day',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              )
            : Text('$day',
                style: TextStyle(fontSize: 13, color: faded ? _faded : _ink)),
      ),
    );
  }
}

class _PickCell extends StatelessWidget {
  const _PickCell({
    required this.label,
    required this.current,
    required this.enabled,
    required this.onTap,
  });
  final String label;
  final bool current;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: enabled ? onTap : null,
      radius: 24,
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: current ? AuthTokens.actionBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Text(label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: current ? FontWeight.w600 : FontWeight.w400,
                  color: current ? Colors.white : (enabled ? _ink : _faded),
                )),
          ),
        ),
      ),
    );
  }
}
