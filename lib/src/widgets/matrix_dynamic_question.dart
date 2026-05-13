import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../theme/survey_theme.dart';

/// Renders a SurveyJS `matrixdynamic` question.
/// Dynamic rows — user can add/remove rows. Each row has columns.
class MatrixDynamicQuestion extends StatefulWidget {
  final QuestionModel question;
  final List<Map<String, dynamic>> currentValues; // List of row maps
  final ValueChanged<List<Map<String, dynamic>>> onChanged;
  final bool enabled;

  const MatrixDynamicQuestion({
    super.key,
    required this.question,
    required this.onChanged,
    this.currentValues = const [],
    this.enabled = true,
  });

  @override
  State<MatrixDynamicQuestion> createState() => _MatrixDynamicQuestionState();
}

class _MatrixDynamicQuestionState extends State<MatrixDynamicQuestion> {
  late List<Map<String, dynamic>> _rows;

  @override
  void initState() {
    super.initState();
    final initial = widget.currentValues.isNotEmpty
        ? widget.currentValues
        : List.generate(widget.question.rowCount ?? 1, (_) => <String, dynamic>{});
    _rows = initial.map((r) => Map<String, dynamic>.from(r)).toList();
  }

  void _addRow() {
    final max = widget.question.maxRowCount;
    if (max != null && _rows.length >= max) return;
    setState(() => _rows.add({}));
    widget.onChanged(_rows);
  }

  void _removeRow(int index) {
    final min = widget.question.minRowCount ?? 0;
    if (_rows.length <= min) return;
    setState(() => _rows.removeAt(index));
    widget.onChanged(_rows);
  }

  void _setValue(int rowIndex, String colName, dynamic value) {
    setState(() => _rows[rowIndex][colName] = value);
    widget.onChanged(_rows);
  }

  @override
  Widget build(BuildContext context) {
    final theme = SurveyTheme.of(context);
    final addText = widget.question.addRowText ?? '+ Add row';
    final removeText = widget.question.removeRowText ?? 'Remove';

    // FIX: read raw column definitions from rawJson so we get cellType, name,
    // title, inputType etc. question.columns is now List<SurveyChoice> and
    // only suitable for the simple matrix widget.
    final rawCols = widget.question.rawJson['columns'];
    final colDefs = (rawCols is List)
        ? rawCols.map((c) {
            if (c is Map<String, dynamic>) return c;
            return <String, dynamic>{
              'name': c.toString(),
              'title': c.toString(),
              'cellType': 'text'
            };
          }).toList()
        : <Map<String, dynamic>>[];

    if (colDefs.isEmpty) {
      return Text('No columns defined.', style: theme.questionDescriptionStyle);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Table
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
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
                    ...colDefs.map((col) => Container(
                      width: 150,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(right: BorderSide(color: theme.borderColor)),
                      ),
                      child: Text(
                        col['title']?.toString() ?? col['name']?.toString() ?? '',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.titleColor),
                      ),
                    )),
                    // Remove column header spacer
                    if (widget.enabled && (widget.question.minRowCount ?? 0) < (_rows.length))
                      const SizedBox(width: 60),
                  ],
                ),
              ),
              // Data rows
              ..._rows.asMap().entries.map((entry) {
                final rowIndex = entry.key;
                final rowData = entry.value;
                final isEven = rowIndex % 2 == 0;
                final canRemove = widget.enabled &&
                    _rows.length > (widget.question.minRowCount ?? 0);

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
                      ...colDefs.map((col) {
                        final colName = col['name']?.toString() ?? '';
                        final cellType = col['cellType']?.toString() ?? 'text';
                        final cellValue = rowData[colName];
                        return Container(
                          width: 150,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            border: Border(right: BorderSide(color: theme.borderColor)),
                          ),
                          child: _buildCell(theme, cellType, col, cellValue,
                              (v) => _setValue(rowIndex, colName, v)),
                        );
                      }),
                      if (canRemove)
                        GestureDetector(
                          onTap: () => _removeRow(rowIndex),
                          child: SizedBox(
                            width: 60,
                            child: Center(
                              child: Text(removeText,
                                  style: TextStyle(fontSize: 11, color: theme.errorColor)),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        // Add row button
        if (widget.enabled &&
            (widget.question.maxRowCount == null ||
                _rows.length < widget.question.maxRowCount!))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: OutlinedButton.icon(
              onPressed: _addRow,
              icon: Icon(Icons.add, size: 16, color: theme.primaryColor),
              label: Text(addText,
                  style: TextStyle(color: theme.primaryColor, fontSize: 13)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.primaryColor),
                shape: RoundedRectangleBorder(borderRadius: theme.buttonBorderRadius),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCell(SurveyTheme theme, String cellType,
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
            items: choices.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12)))).toList(),
            onChanged: widget.enabled ? onChanged : null,
          ),
        );

      case 'rating':
        final rateMax = colDef['rateMax'] as int? ?? 10;
        final rateMin = colDef['rateMin'] as int? ?? 1;
        final selected = value is int ? value : int.tryParse(value?.toString() ?? '');
        return Wrap(
          spacing: 2,
          runSpacing: 2,
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

      default:
        return TextField(
          enabled: widget.enabled,
          style: TextStyle(fontSize: 12, color: theme.textColor),
          keyboardType: colDef['inputType'] == 'number'
              ? TextInputType.number
              : colDef['inputType'] == 'url'
                  ? TextInputType.url
                  : TextInputType.text,
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
