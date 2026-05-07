import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../theme/survey_theme.dart';

/// Renders a SurveyJS `matrix` question.
/// Grid of rows × columns — one radio selection per row.
class MatrixQuestion extends StatelessWidget {
  final QuestionModel question;
  final Map<String, String> currentValues; // { rowValue: columnValue }
  final ValueChanged<Map<String, String>> onChanged;
  final bool enabled;

  const MatrixQuestion({
    super.key,
    required this.question,
    required this.onChanged,
    this.currentValues = const {},
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SurveyTheme.of(context);
    final rows = question.rows;
    final cols = question.columns;

    if (rows.isEmpty || cols.isEmpty) {
      return Text('Matrix has no rows or columns.',
          style: theme.questionDescriptionStyle);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width - 64,
        ),
        child: Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          border: TableBorder.all(color: theme.borderColor, width: 1),
          children: [
            // Header row
            TableRow(
              decoration: BoxDecoration(
                color: theme.backgroundColor,
              ),
              children: [
                // Empty top-left cell
                const TableCell(child: SizedBox()),
                ...cols.map(
                  (col) => TableCell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      child: Text(
                        col.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.titleColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Data rows
            ...rows.asMap().entries.map((entry) {
              final rowIndex = entry.key;
              final row = entry.value;
              final selectedCol = currentValues[row.value];
              final isEven = rowIndex % 2 == 0;

              return TableRow(
                decoration: BoxDecoration(
                  color: isEven
                      ? theme.questionBackgroundColor
                      : theme.backgroundColor,
                ),
                children: [
                  // Row label
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Text(
                        row.label,
                        style: TextStyle(
                            fontSize: 14, color: theme.textColor),
                      ),
                    ),
                  ),
                  // Radio cells
                  ...cols.map(
                    (col) => TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Center(
                        child: Radio<String>(
                          value: col.value,
                          groupValue: selectedCol,
                          onChanged: enabled
                              ? (v) {
                                  final updated =
                                      Map<String, String>.from(currentValues);
                                  if (v == null) {
                                    updated.remove(row.value);
                                  } else {
                                    updated[row.value] = v;
                                  }
                                  onChanged(updated);
                                }
                              : null,
                          activeColor: theme.primaryColor,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
