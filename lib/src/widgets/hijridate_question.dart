import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import '../models/question_model.dart';
import '../theme/survey_theme.dart';

/// Hijri (Islamic) date picker question.
///
/// Stores the answer as a Hijri date string: "YYYY-MM-DD"
/// e.g. "1447-09-15"
///
/// JSON usage:
/// ```json
/// { "type": "hijridate", "name": "birthDate", "title": "تاريخ الميلاد" }
/// ```
class HijriDateQuestion extends StatefulWidget {
  final QuestionModel question;
  final String? currentValue; // "YYYY-MM-DD" hijri string
  final bool enabled;
  final ValueChanged<String?> onChanged;

  const HijriDateQuestion({
    super.key,
    required this.question,
    required this.onChanged,
    this.currentValue,
    this.enabled = true,
  });

  @override
  State<HijriDateQuestion> createState() => _HijriDateQuestionState();
}

class _HijriDateQuestionState extends State<HijriDateQuestion> {
  HijriCalendar? _selected;

  @override
  void initState() {
    super.initState();
    if (widget.currentValue != null && widget.currentValue!.isNotEmpty) {
      _selected = _parseHijri(widget.currentValue!);
    }
  }

  // ── Parsing ──────────────────────────────────────────────────────────────

  HijriCalendar? _parseHijri(String s) {
    try {
      final parts = s.split('-');
      if (parts.length < 3) return null;
      final h = HijriCalendar()
        ..hYear = int.parse(parts[0])
        ..hMonth = int.parse(parts[1])
        ..hDay = int.parse(parts[2]);
      return h;
    } catch (_) {
      return null;
    }
  }

  String _formatHijri(HijriCalendar h) =>
      '${h.hYear}-${h.hMonth.toString().padLeft(2, '0')}-${h.hDay.toString().padLeft(2, '0')}';

  String _displayHijri(HijriCalendar h) {
    const months = [
      'محرم', 'صفر', 'ربيع الأول', 'ربيع الثاني',
      'جمادى الأولى', 'جمادى الثانية', 'رجب', 'شعبان',
      'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة',
    ];
    final monthName = (h.hMonth >= 1 && h.hMonth <= 12)
        ? months[h.hMonth - 1]
        : h.hMonth.toString();
    return '${h.hDay} $monthName ${h.hYear}';
  }

  // ── Picker ───────────────────────────────────────────────────────────────

  Future<void> _openPicker() async {
    if (!widget.enabled) return;
    final today = HijriCalendar.now();

    final result = await showDialog<HijriCalendar>(
      context: context,
      builder: (ctx) => _HijriPickerDialog(initial: _selected ?? today),
    );

    if (result != null && mounted) {
      setState(() => _selected = result);
      widget.onChanged(_formatHijri(result));
    }
  }

  void _clear() {
    setState(() => _selected = null);
    widget.onChanged(null);
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = SurveyTheme.of(context);
    final hasValue = _selected != null;

    return GestureDetector(
      onTap: widget.enabled ? _openPicker : null,
      child: Container(
        width: double.infinity,
        padding: theme.inputPadding,
        decoration: BoxDecoration(
          color: widget.enabled
              ? theme.questionBackgroundColor
              : theme.disabledColor.withOpacity(0.1),
          borderRadius: theme.inputBorderRadius,
          border: Border.all(color: hasValue ? theme.primaryColor : theme.borderColor),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 20,
              color: hasValue ? theme.primaryColor : theme.hintColor,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hasValue ? _displayHijri(_selected!) : (widget.question.placeholder ?? 'اختر التاريخ الهجري'),
                style: theme.inputTextStyle.copyWith(
                  color: hasValue ? theme.textColor : theme.hintColor,
                ),
              ),
            ),
            if (hasValue && widget.enabled)
              GestureDetector(
                onTap: _clear,
                child: Icon(Icons.close, size: 18, color: theme.hintColor),
              )
            else
              Icon(Icons.arrow_drop_down, color: theme.hintColor),
          ],
        ),
      ),
    );
  }
}

// ─── Hijri Picker Dialog ──────────────────────────────────────────────────────

class _HijriPickerDialog extends StatefulWidget {
  final HijriCalendar initial;
  const _HijriPickerDialog({required this.initial});

  @override
  State<_HijriPickerDialog> createState() => _HijriPickerDialogState();
}

class _HijriPickerDialogState extends State<_HijriPickerDialog> {
  late int _year;
  late int _month;
  late int _day;

  static const _months = [
    'محرم', 'صفر', 'ربيع الأول', 'ربيع الثاني',
    'جمادى الأولى', 'جمادى الثانية', 'رجب', 'شعبان',
    'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة',
  ];

  @override
  void initState() {
    super.initState();
    _year = widget.initial.hYear;
    _month = widget.initial.hMonth;
    _day = widget.initial.hDay;
  }

  int get _daysInMonth {
    // Hijri months alternate 30/29, with Dhul Hijja sometimes 30.
    // FIX: hijriToGregorian returns a DateTime (not a Map), so use
    //      .year / .month / .day properties instead of ['year'] etc.
    try {
      final test = HijriCalendar()
        ..hYear = _year
        ..hMonth = _month
        ..hDay = 30;
      // hijriToGregorian returns DateTime
      final greg = test.hijriToGregorian(_year, _month, 30);
      final back = HijriCalendar.fromDate(
          DateTime(greg.year, greg.month, greg.day));
      return (back.hMonth == _month) ? 30 : 29;
    } catch (_) {
      return 29;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = _daysInMonth;
    if (_day > days) _day = days;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('اختر التاريخ الهجري', textAlign: TextAlign.right),
        contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Year row ──────────────────────────────────────────────────
            _PickerRow(
              label: 'السنة',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(icon: const Icon(Icons.remove), onPressed: () => setState(() => _year--)),
                  Text('$_year', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.add), onPressed: () => setState(() => _year++)),
                ],
              ),
            ),

            const Divider(height: 1),

            // ── Month row ─────────────────────────────────────────────────
            _PickerRow(
              label: 'الشهر',
              child: DropdownButton<int>(
                value: _month,
                underline: const SizedBox(),
                items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text(_months[i]))),
                onChanged: (v) { if (v != null) setState(() => _month = v); },
              ),
            ),

            const Divider(height: 1),

            // ── Day grid ──────────────────────────────────────────────────
            _PickerRow(
              label: 'اليوم',
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: List.generate(days, (i) {
                  final d = i + 1;
                  final selected = d == _day;
                  return GestureDetector(
                    onTap: () => setState(() => _day = d),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: selected ? theme.colorScheme.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: selected ? theme.colorScheme.primary : theme.dividerColor,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$d',
                        style: TextStyle(
                          color: selected ? Colors.white : null,
                          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final h = HijriCalendar()
                ..hYear = _year
                ..hMonth = _month
                ..hDay = _day;
              Navigator.pop(context, h);
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  final String label;
  final Widget child;
  const _PickerRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}
