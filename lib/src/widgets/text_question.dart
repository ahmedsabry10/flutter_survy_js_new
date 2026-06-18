import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/question_model.dart';
import '../theme/survey_theme.dart';

/// Renders a SurveyJS `text` or `comment` question.
///
/// Dispatches on [QuestionModel.inputType] to a native Flutter input:
/// - `color`           → swatch field + HSV color picker dialog
/// - `date`            → date picker            (stored as `yyyy-MM-dd`)
/// - `datetime-local`  → date + time picker     (stored as `yyyy-MM-ddTHH:mm`)
/// - `month`           → month/year picker       (stored as `yyyy-MM`)
/// - `time`            → time picker            (stored as `HH:mm`)
/// - `week`            → date picker → ISO week  (stored as `yyyy-Www`)
/// - `range`           → slider
/// - `number`          → text field with +/- steppers
/// - `password`        → obscured text field
/// - `email`/`tel`/`url`/`text`/default → plain text field
class TextQuestion extends StatefulWidget {
  final QuestionModel question;
  final dynamic initialValue;
  final ValueChanged<String> onChanged;
  final bool enabled;

  const TextQuestion({
    super.key,
    required this.question,
    required this.onChanged,
    this.initialValue,
    this.enabled = true,
  });

  @override
  State<TextQuestion> createState() => _TextQuestionState();
}

class _TextQuestionState extends State<TextQuestion> {
  late final TextEditingController _controller;
  String _value = '';
  bool _obscured = true;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue?.toString() ?? '';
    _controller = TextEditingController(text: _value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _emit(String v) {
    setState(() => _value = v);
    widget.onChanged(v);
  }

  static String _pad2(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final theme = SurveyTheme.of(context);
    switch (widget.question.inputType) {
      case 'color':
        return _buildColorField(theme);
      case 'date':
        return _buildDateField(theme);
      case 'datetime-local':
        return _buildDateTimeField(theme);
      case 'month':
        return _buildMonthField(theme);
      case 'time':
        return _buildTimeField(theme);
      case 'week':
        return _buildWeekField(theme);
      case 'range':
        return _buildRangeField(theme);
      case 'number':
        return _buildNumberField(theme);
      case 'password':
        return _buildTextField(theme, obscure: true);
      default:
        return _buildTextField(theme);
    }
  }

  // ─── Shared decoration ──────────────────────────────────────────────────

  InputDecoration _decoration(SurveyTheme theme,
      {String? hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint ?? widget.question.placeholder,
      hintStyle: theme.inputTextStyle.copyWith(color: theme.hintColor),
      contentPadding: theme.inputPadding,
      filled: true,
      fillColor: widget.enabled
          ? theme.questionBackgroundColor
          : theme.disabledColor.withOpacity(0.1),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: theme.inputBorderRadius,
        borderSide: BorderSide(color: theme.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: theme.inputBorderRadius,
        borderSide: BorderSide(color: theme.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: theme.inputBorderRadius,
        borderSide: BorderSide(color: theme.focusBorderColor, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: theme.inputBorderRadius,
        borderSide: BorderSide(color: theme.disabledColor),
      ),
      counterText: '',
    );
  }

  /// A read-only field that looks like a text field but opens a picker on tap.
  Widget _pickerField(
    SurveyTheme theme, {
    required String? display,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final hasValue = display != null && display.isNotEmpty;
    return InkWell(
      onTap: widget.enabled ? onTap : null,
      borderRadius: theme.inputBorderRadius,
      child: InputDecorator(
        decoration: _decoration(
          theme,
          suffixIcon: Icon(icon, color: theme.hintColor),
        ),
        child: Text(
          hasValue ? display : (widget.question.placeholder ?? ''),
          style: hasValue
              ? theme.inputTextStyle
              : theme.inputTextStyle.copyWith(color: theme.hintColor),
        ),
      ),
    );
  }

  // ─── Plain text / email / tel / url / password ──────────────────────────

  Widget _buildTextField(SurveyTheme theme, {bool obscure = false}) {
    final q = widget.question;
    final isComment = q.type.name == 'comment';

    return TextField(
      controller: _controller,
      enabled: widget.enabled,
      obscureText: obscure && _obscured,
      maxLines: obscure ? 1 : (isComment ? null : 1),
      minLines: isComment ? 3 : 1,
      maxLength: q.maxLength,
      keyboardType: obscure ? TextInputType.text : _keyboardType(q.inputType),
      inputFormatters: _inputFormatters(q.inputType),
      style: theme.inputTextStyle,
      decoration: _decoration(
        theme,
        suffixIcon: obscure
            ? IconButton(
                icon: Icon(
                  _obscured ? Icons.visibility_off : Icons.visibility,
                  color: theme.hintColor,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : null,
      ),
      onChanged: _emit,
    );
  }

  // ─── Number with steppers ───────────────────────────────────────────────

  Widget _buildNumberField(SurveyTheme theme) {
    final q = widget.question;
    final step = num.tryParse(q.step ?? '') ?? 1;

    void bump(num delta) {
      final current = num.tryParse(_controller.text) ?? q.min ?? 0;
      num next = current + delta;
      if (q.min != null && next < q.min!) next = q.min!;
      if (q.max != null && next > q.max!) next = q.max!;
      // Drop trailing ".0" for whole numbers.
      final text = next == next.roundToDouble()
          ? next.toInt().toString()
          : next.toString();
      _controller.text = text;
      _emit(text);
    }

    return TextField(
      controller: _controller,
      enabled: widget.enabled,
      keyboardType: const TextInputType.numberWithOptions(
          decimal: true, signed: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.\-]'))],
      style: theme.inputTextStyle,
      decoration: _decoration(
        theme,
        suffixIcon: widget.enabled
            ? Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StepButton(
                    icon: Icons.keyboard_arrow_up,
                    color: theme.hintColor,
                    onTap: () => bump(step),
                  ),
                  _StepButton(
                    icon: Icons.keyboard_arrow_down,
                    color: theme.hintColor,
                    onTap: () => bump(-step),
                  ),
                ],
              )
            : null,
      ),
      onChanged: _emit,
    );
  }

  // ─── Range slider ───────────────────────────────────────────────────────

  Widget _buildRangeField(SurveyTheme theme) {
    final q = widget.question;
    final min = (q.min ?? 0).toDouble();
    final max = (q.max ?? 100).toDouble();
    final step = num.tryParse(q.step ?? '')?.toDouble();
    final divisions =
        step != null && step > 0 ? ((max - min) / step).round() : null;

    var current = double.tryParse(_value) ?? min;
    if (current < min) current = min;
    if (current > max) current = max;

    String fmt(double v) =>
        v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(fmt(min), style: theme.questionDescriptionStyle),
            Text(fmt(current),
                style: theme.inputTextStyle
                    .copyWith(fontWeight: FontWeight.w600, color: theme.primaryColor)),
            Text(fmt(max), style: theme.questionDescriptionStyle),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: theme.primaryColor,
            inactiveTrackColor: theme.ratingUnselectedColor,
            thumbColor: theme.primaryColor,
            overlayColor: theme.primaryColor.withOpacity(0.15),
          ),
          child: Slider(
            value: current,
            min: min,
            max: max,
            divisions: divisions,
            label: fmt(current),
            onChanged: widget.enabled
                ? (v) {
                    final text = fmt(v);
                    _emit(text);
                  }
                : null,
          ),
        ),
      ],
    );
  }

  // ─── Date ─────────────────────────────────────────────────────────────────

  Widget _buildDateField(SurveyTheme theme) {
    final parsed = DateTime.tryParse(_value);
    return _pickerField(
      theme,
      display: parsed == null
          ? null
          : '${parsed.year}-${_pad2(parsed.month)}-${_pad2(parsed.day)}',
      icon: Icons.calendar_today_outlined,
      onTap: () async {
        final picked = await _pickDate(parsed);
        if (picked != null) {
          _emit('${picked.year}-${_pad2(picked.month)}-${_pad2(picked.day)}');
        }
      },
    );
  }

  // ─── Date + time ────────────────────────────────────────────────────────

  Widget _buildDateTimeField(SurveyTheme theme) {
    final parsed = DateTime.tryParse(_value);
    return _pickerField(
      theme,
      display: parsed == null
          ? null
          : '${parsed.year}-${_pad2(parsed.month)}-${_pad2(parsed.day)} '
              '${_pad2(parsed.hour)}:${_pad2(parsed.minute)}',
      icon: Icons.event_outlined,
      onTap: () async {
        final date = await _pickDate(parsed);
        if (date == null || !mounted) return;
        final time = await showTimePicker(
          context: context,
          initialTime: parsed == null
              ? TimeOfDay.now()
              : TimeOfDay(hour: parsed.hour, minute: parsed.minute),
        );
        if (time == null) return;
        _emit('${date.year}-${_pad2(date.month)}-${_pad2(date.day)}'
            'T${_pad2(time.hour)}:${_pad2(time.minute)}');
      },
    );
  }

  // ─── Time ─────────────────────────────────────────────────────────────────

  Widget _buildTimeField(SurveyTheme theme) {
    TimeOfDay? parsed;
    final parts = _value.split(':');
    if (parts.length >= 2) {
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      if (h != null && m != null) parsed = TimeOfDay(hour: h, minute: m);
    }
    return _pickerField(
      theme,
      display: parsed == null ? null : '${_pad2(parsed.hour)}:${_pad2(parsed.minute)}',
      icon: Icons.access_time,
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: parsed ?? TimeOfDay.now(),
        );
        if (time != null) {
          _emit('${_pad2(time.hour)}:${_pad2(time.minute)}');
        }
      },
    );
  }

  // ─── Month ──────────────────────────────────────────────────────────────

  Widget _buildMonthField(SurveyTheme theme) {
    int? year;
    int? month;
    final parts = _value.split('-');
    if (parts.length >= 2) {
      year = int.tryParse(parts[0]);
      month = int.tryParse(parts[1]);
    }
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return _pickerField(
      theme,
      display: (year != null && month != null && month >= 1 && month <= 12)
          ? '${monthNames[month - 1]} $year'
          : null,
      icon: Icons.calendar_today_outlined,
      onTap: () async {
        final result = await showDialog<({int year, int month})>(
          context: context,
          builder: (_) => SurveyThemeProvider(
            theme: theme,
            child: _MonthPickerDialog(
              initialYear: year ?? DateTime.now().year,
              initialMonth: month,
            ),
          ),
        );
        if (result != null) {
          _emit('${result.year}-${_pad2(result.month)}');
        }
      },
    );
  }

  // ─── Week (ISO) ─────────────────────────────────────────────────────────

  Widget _buildWeekField(SurveyTheme theme) {
    // Stored as "yyyy-Www"
    String? display;
    final match = RegExp(r'^(\d{4})-W(\d{1,2})$').firstMatch(_value);
    if (match != null) {
      display = 'Week ${match.group(2)}, ${match.group(1)}';
    }
    return _pickerField(
      theme,
      display: display,
      icon: Icons.date_range_outlined,
      onTap: () async {
        final picked = await _pickDate(DateTime.tryParse(_value));
        if (picked != null) {
          final iso = _isoWeekYear(picked);
          _emit('${iso.year}-W${_pad2(iso.week)}');
        }
      },
    );
  }

  // ─── Color ──────────────────────────────────────────────────────────────

  Widget _buildColorField(SurveyTheme theme) {
    final color = _parseHexColor(_value);
    return InkWell(
      onTap: widget.enabled
          ? () async {
              final result = await showDialog<String>(
                context: context,
                builder: (_) => SurveyThemeProvider(
                  theme: theme,
                  child: _ColorPickerDialog(initial: color ?? theme.primaryColor),
                ),
              );
              if (result != null) _emit(result);
            }
          : null,
      borderRadius: theme.inputBorderRadius,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          borderRadius: theme.inputBorderRadius,
          border: Border.all(color: theme.borderColor),
          color: color ?? theme.questionBackgroundColor,
        ),
        alignment: Alignment.center,
        child: color == null
            ? Text(
                widget.question.placeholder ?? 'Pick a color',
                style: theme.inputTextStyle.copyWith(color: theme.hintColor),
              )
            : null,
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────

  Future<DateTime?> _pickDate(DateTime? initial) {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
  }

  static Color? _parseHexColor(String value) {
    var hex = value.trim().replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    if (hex.length != 8) return null;
    final intColor = int.tryParse(hex, radix: 16);
    return intColor == null ? null : Color(intColor);
  }

  /// ISO-8601 week number and its (possibly shifted) year.
  ({int year, int week}) _isoWeekYear(DateTime d) {
    final ordinal = d.difference(DateTime(d.year, 1, 1)).inDays + 1;
    final weekday = d.weekday; // Mon=1..Sun=7
    var week = (ordinal - weekday + 10) ~/ 7;
    var year = d.year;
    if (week < 1) {
      year -= 1;
      week = _isoWeeksInYear(year);
    } else if (week > _isoWeeksInYear(year)) {
      year += 1;
      week = 1;
    }
    return (year: year, week: week);
  }

  int _isoWeeksInYear(int year) {
    int p(int y) => (y + (y ~/ 4) - (y ~/ 100) + (y ~/ 400)) % 7;
    return (p(year) == 4 || p(year - 1) == 3) ? 53 : 52;
  }

  TextInputType _keyboardType(String? inputType) {
    switch (inputType) {
      case 'email':
        return TextInputType.emailAddress;
      case 'number':
        return TextInputType.number;
      case 'tel':
        return TextInputType.phone;
      case 'url':
        return TextInputType.url;
      default:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter> _inputFormatters(String? inputType) {
    if (inputType == 'number') {
      return [FilteringTextInputFormatter.allow(RegExp(r'[\d.\-]'))];
    }
    return [];
  }
}

// ─── Number stepper button ────────────────────────────────────────────────

class _StepButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StepButton(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 18,
        width: 28,
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}

// ─── Month picker dialog ────────────────────────────────────────────────────

class _MonthPickerDialog extends StatefulWidget {
  final int initialYear;
  final int? initialMonth;

  const _MonthPickerDialog({required this.initialYear, this.initialMonth});

  @override
  State<_MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<_MonthPickerDialog> {
  late int _year;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  void initState() {
    super.initState();
    _year = widget.initialYear;
  }

  @override
  Widget build(BuildContext context) {
    final theme = SurveyTheme.of(context);
    return Dialog(
      backgroundColor: theme.questionBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: theme.cardBorderRadius),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Year selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left, color: theme.textColor),
                  onPressed: () => setState(() => _year--),
                ),
                Text('$_year',
                    style: theme.questionTitleStyle),
                IconButton(
                  icon: Icon(Icons.chevron_right, color: theme.textColor),
                  onPressed: () => setState(() => _year++),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Month grid (4 columns)
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.6,
              children: List.generate(12, (i) {
                final month = i + 1;
                final isSelected = widget.initialMonth == month &&
                    widget.initialYear == _year;
                return InkWell(
                  onTap: () => Navigator.of(context)
                      .pop((year: _year, month: month)),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.primaryColor.withOpacity(0.15)
                          : null,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _months[i],
                      style: isSelected
                          ? theme.inputTextStyle.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.w600)
                          : theme.inputTextStyle,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Color picker dialog ────────────────────────────────────────────────────

class _ColorPickerDialog extends StatefulWidget {
  final Color initial;
  const _ColorPickerDialog({required this.initial});

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late HSVColor _hsv;

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(widget.initial);
  }

  String _toHex(Color c) {
    String h(int v) => v.toRadixString(16).padLeft(2, '0');
    return '#${h(c.red)}${h(c.green)}${h(c.blue)}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = SurveyTheme.of(context);
    final color = _hsv.toColor();

    return Dialog(
      backgroundColor: theme.questionBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: theme.cardBorderRadius),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Saturation / Value area
              LayoutBuilder(
                builder: (ctx, constraints) {
                  final w = constraints.maxWidth;
                  const h = 170.0;
                  void update(Offset p) {
                    final s = (p.dx / w).clamp(0.0, 1.0);
                    final v = (1 - p.dy / h).clamp(0.0, 1.0);
                    setState(() =>
                        _hsv = _hsv.withSaturation(s).withValue(v));
                  }

                  return GestureDetector(
                    onPanDown: (d) => update(d.localPosition),
                    onPanUpdate: (d) => update(d.localPosition),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: w,
                        height: h,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                  painter: _SVPainter(_hsv.hue)),
                            ),
                            Positioned(
                              left: _hsv.saturation * w - 8,
                              top: (1 - _hsv.value) * h - 8,
                              child: _Thumb(color: color),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // Hue slider
              LayoutBuilder(
                builder: (ctx, constraints) {
                  final w = constraints.maxWidth;
                  void update(Offset p) {
                    final hue = (p.dx / w).clamp(0.0, 1.0) * 360;
                    setState(() => _hsv = _hsv.withHue(hue));
                  }

                  return GestureDetector(
                    onPanDown: (d) => update(d.localPosition),
                    onPanUpdate: (d) => update(d.localPosition),
                    child: SizedBox(
                      height: 20,
                      width: w,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CustomPaint(painter: _HuePainter()),
                            ),
                          ),
                          Positioned(
                            left: (_hsv.hue / 360) * w - 8,
                            top: 2,
                            child: _Thumb(
                                color: HSVColor.fromAHSV(1, _hsv.hue, 1, 1)
                                    .toColor()),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // Preview + hex + actions
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.borderColor),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(_toHex(color),
                      style: theme.inputTextStyle
                          .copyWith(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel',
                        style: TextStyle(color: theme.hintColor)),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pop(_toHex(color)),
                    child: Text('OK',
                        style: TextStyle(color: theme.primaryColor)),
                  ),
                ],
              ),
              // RGB readout
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'R ${color.red}   G ${color.green}   B ${color.blue}',
                  style: theme.questionDescriptionStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final Color color;
  const _Thumb({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 2),
        ],
      ),
    );
  }
}

class _SVPainter extends CustomPainter {
  final double hue;
  _SVPainter(this.hue);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    // White → fully-saturated hue (left to right)
    final satPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.white, HSVColor.fromAHSV(1, hue, 1, 1).toColor()],
      ).createShader(rect);
    canvas.drawRect(rect, satPaint);
    // Transparent → black (top to bottom)
    final valPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, Colors.black],
      ).createShader(rect);
    canvas.drawRect(rect, valPaint);
  }

  @override
  bool shouldRepaint(_SVPainter old) => old.hue != hue;
}

class _HuePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    const paintColors = [
      Color(0xFFFF0000),
      Color(0xFFFFFF00),
      Color(0xFF00FF00),
      Color(0xFF00FFFF),
      Color(0xFF0000FF),
      Color(0xFFFF00FF),
      Color(0xFFFF0000),
    ];
    final paint = Paint()
      ..shader =
          const LinearGradient(colors: paintColors).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(_HuePainter old) => false;
}
