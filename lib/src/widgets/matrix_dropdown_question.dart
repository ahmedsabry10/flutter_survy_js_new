import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../theme/survey_theme.dart';

/// Renders a SurveyJS `matrixdropdown` question.
/// Grid of rows × columns — each column has its own cellType (dropdown, rating, boolean, comment, text).
class MatrixDropdownQuestion extends StatefulWidget {
  final QuestionModel question;
  final Map<String, Map<String, dynamic>> currentValues; // {rowValue: {colName: value}}
  final ValueChanged<Map<String, Map<String, dynamic>>> onChanged;
  final bool enabled;

  const MatrixDropdownQuestion({
    super.key,
    required this.question,
    required this.onChanged,
    this.currentValues = const {},
    this.enabled = true,
  });

  @override
  State<MatrixDropdownQuestion> createState() => _MatrixDropdownQuestionState();
}

class _MatrixDropdownQuestionState extends State<MatrixDropdownQuestion> {
  late Map<String, Map<String, dynamic>> _values;

  @override
  void initState() {
    super.initState();
    _values = widget.currentValues.map((k, v) => MapEntry(k, Map<String, dynamic>.from(v)));
  }

  void _setValue(String rowValue, String colName, dynamic value) {
    setState(() {
      _values[rowValue] ??= {};
      _values[rowValue]![colName] = value;
    });
    widget.onChanged(_values);
  }

  @override
  Widget build(BuildContext context) {
    final theme = SurveyTheme.of(context);
    final rows = widget.question.rows;
    final columns = widget.question.columns;

    if (rows.isEmpty || columns.isEmpty) {
      return Text('Matrix has no rows or columns.', style: theme.questionDescriptionStyle);
    }

    // Parse column definitions
    final colDefs = columns.map((c) {
      if (c is Map<String, dynamic>) return c;
      return <String, dynamic>{'name': c.toString(), 'title': c.toString(), 'cellType': 'text'};
    }).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                color: theme.backgroundColor,
                border: Border.all(color: theme.borderColor),
              ),
              child: Row(
                children: [
                  // Row label column
                  Container(
                    width: 120,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: const SizedBox.shrink(),
                  ),
                  ...colDefs.map((col) => Container(
                    width: 140,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: theme.borderColor)),
                    ),
                    child: Text(
                      col['title']?.toString() ?? col['name']?.toString() ?? '',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.titleColor),
                      textAlign: TextAlign.center,
                    ),
                  )),
                ],
              ),
            ),
            // Data rows
            ...rows.asMap().entries.map((entry) {
              final rowIndex = entry.key;
              final row = entry.value;
              final rowAnswers = _values[row.value] ?? {};
              final isEven = rowIndex % 2 == 0;

              return Container(
                decoration: BoxDecoration(
                  color: isEven ? theme.questionBackgroundColor : theme.backgroundColor,
                  border: Border(
                    left: BorderSide(color: theme.borderColor),
                    right: BorderSide(color: theme.borderColor),
                    bottom: BorderSide(color: theme.borderColor),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Row label
                    SizedBox(
                      width: 120,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Text(row.label, style: TextStyle(fontSize: 13, color: theme.textColor)),
                      ),
                    ),
                    // Cells
                    ...colDefs.map((col) {
                      final colName = col['name']?.toString() ?? '';
                      final cellType = col['cellType']?.toString() ?? 'text';
                      final cellValue = rowAnswers[colName];

                      return Container(
                        width: 140,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          border: Border(left: BorderSide(color: theme.borderColor)),
                        ),
                        child: _buildCell(
                          context, theme, cellType, col, cellValue,
                          (v) => _setValue(row.value, colName, v),
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCell(BuildContext context, SurveyTheme theme, String cellType,
      Map<String, dynamic> colDef, dynamic value, ValueChanged<dynamic> onChanged) {
    switch (cellType) {
      case 'dropdown':
        final choices = (colDef['choices'] as List?)?.map((c) => c.toString()).toList() ?? [];
        return DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: choices.contains(value?.toString()) ? value?.toString() : null,
            isExpanded: true,
            hint: Text('Select...', style: TextStyle(fontSize: 12, color: theme.hintColor)),
            style: TextStyle(fontSize: 12, color: theme.textColor),
            items: choices.map((c) => DropdownMenuItem(value: c, child: Text(c, style: TextStyle(fontSize: 12)))).toList(),
            onChanged: widget.enabled ? onChanged : null,
          ),
        );

      case 'rating':
        final rateMax = colDef['rateMax'] as int? ?? 5;
        final rateMin = colDef['rateMin'] as int? ?? 1;
        final selected = value is int ? value : int.tryParse(value?.toString() ?? '');
        return Wrap(
          spacing: 2,
          children: List.generate(rateMax - rateMin + 1, (i) {
            final v = rateMin + i;
            final isSel = selected == v;
            return GestureDetector(
              onTap: widget.enabled ? () => onChanged(isSel ? null : v) : null,
              child: Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                  color: isSel ? theme.primaryColor : Colors.transparent,
                  border: Border.all(color: isSel ? theme.primaryColor : theme.borderColor),
                  borderRadius: BorderRadius.circular(3),
                ),
                alignment: Alignment.center,
                child: Text('$v', style: TextStyle(fontSize: 10, color: isSel ? Colors.white : theme.textColor)),
              ),
            );
          }),
        );

      case 'boolean':
        final boolVal = value is bool ? value : value?.toString() == 'true';
        return Switch(
          value: boolVal,
          onChanged: widget.enabled ? (v) => onChanged(v) : null,
          activeColor: theme.primaryColor,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );

      case 'comment':
        return TextField(
          enabled: widget.enabled,
          maxLines: 2,
          style: TextStyle(fontSize: 12, color: theme.textColor),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            border: OutlineInputBorder(borderRadius: theme.inputBorderRadius, borderSide: BorderSide(color: theme.borderColor)),
            enabledBorder: OutlineInputBorder(borderRadius: theme.inputBorderRadius, borderSide: BorderSide(color: theme.borderColor)),
            focusedBorder: OutlineInputBorder(borderRadius: theme.inputBorderRadius, borderSide: BorderSide(color: theme.focusBorderColor, width: 2)),
          ),
          onChanged: onChanged,
        );

      // text (default)
      default:
        return TextField(
          enabled: widget.enabled,
          style: TextStyle(fontSize: 12, color: theme.textColor),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            border: OutlineInputBorder(borderRadius: theme.inputBorderRadius, borderSide: BorderSide(color: theme.borderColor)),
            enabledBorder: OutlineInputBorder(borderRadius: theme.inputBorderRadius, borderSide: BorderSide(color: theme.borderColor)),
            focusedBorder: OutlineInputBorder(borderRadius: theme.inputBorderRadius, borderSide: BorderSide(color: theme.focusBorderColor, width: 2)),
          ),
          onChanged: onChanged,
        );
    }
  }
}
