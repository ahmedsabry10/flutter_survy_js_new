import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../models/survey_choice.dart';
import '../theme/survey_theme.dart';

/// Renders a SurveyJS `dropdown` question.
///
/// Opens a searchable popup that lists ~10 choices at a time and scrolls
/// for the rest, instead of the full-screen native dropdown menu.
class DropdownQuestion extends StatelessWidget {
  final QuestionModel question;
  final dynamic currentValue;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  const DropdownQuestion({
    super.key,
    required this.question,
    required this.onChanged,
    this.currentValue,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SurveyTheme.of(context);
    final choices = _buildChoices();

    // Make sure currentValue is valid in choices (or null)
    final validValue = choices.any((c) => c.value == currentValue?.toString())
        ? currentValue?.toString()
        : null;
    final selectedChoice = validValue == null
        ? null
        : choices.firstWhere((c) => c.value == validValue);

    return GestureDetector(
      onTap: enabled ? () => _openPicker(context, choices, validValue) : null,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        decoration: BoxDecoration(
          borderRadius: theme.inputBorderRadius,
          border: Border.all(color: theme.borderColor),
          color: enabled
              ? theme.questionBackgroundColor
              : theme.disabledColor.withOpacity(0.05),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedChoice?.label ??
                    (question.placeholder ?? 'Select...'),
                style: selectedChoice == null
                    ? theme.inputTextStyle.copyWith(color: theme.hintColor)
                    : theme.inputTextStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: theme.hintColor),
          ],
        ),
      ),
    );
  }

  Future<void> _openPicker(
    BuildContext context,
    List<SurveyChoice> choices,
    String? selectedValue,
  ) async {
    final theme = SurveyTheme.of(context);
    final result = await showDialog<_PickerResult>(
      context: context,
      builder: (_) => SurveyThemeProvider(
        theme: theme,
        child: _SearchableDropdownDialog(
          choices: choices,
          selectedValue: selectedValue,
          title: question.placeholder ?? 'Select...',
        ),
      ),
    );
    if (result != null) {
      onChanged(result.value);
    }
  }

  List<SurveyChoice> _buildChoices() {
    final choices = List<SurveyChoice>.from(question.choices);
    if (question.hasNone == true) {
      choices.insert(0, SurveyChoice(value: 'none', text: question.noneText ?? 'None'));
    }
    if (question.hasOther == true) {
      choices.add(SurveyChoice(value: 'other', text: question.otherText ?? 'Other'));
    }
    if (question.choicesOrder == 'asc') {
      choices.sort((a, b) => a.label.compareTo(b.label));
    } else if (question.choicesOrder == 'desc') {
      choices.sort((a, b) => b.label.compareTo(a.label));
    }
    return choices;
  }
}

/// Wraps the picked value so `null` can be returned as an explicit choice
/// (clearing the selection) and distinguished from a dismissed dialog.
class _PickerResult {
  final String? value;
  const _PickerResult(this.value);
}

class _SearchableDropdownDialog extends StatefulWidget {
  final List<SurveyChoice> choices;
  final String? selectedValue;
  final String title;

  const _SearchableDropdownDialog({
    required this.choices,
    required this.selectedValue,
    required this.title,
  });

  @override
  State<_SearchableDropdownDialog> createState() =>
      _SearchableDropdownDialogState();
}

class _SearchableDropdownDialogState extends State<_SearchableDropdownDialog> {
  /// Approximate height of a single list row — used to size the list so that
  /// roughly 10 items are visible before it starts scrolling.
  static const double _itemExtent = 48;
  static const int _visibleItems = 10;

  final _searchController = TextEditingController();
  String _searchText = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SurveyChoice> get _filtered {
    if (_searchText.isEmpty) return widget.choices;
    final q = _searchText.toLowerCase();
    return widget.choices
        .where((c) => c.label.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = SurveyTheme.of(context);
    final filtered = _filtered;
    const listHeight = _itemExtent * _visibleItems;

    return Dialog(
      backgroundColor: theme.questionBackgroundColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      shape: RoundedRectangleBorder(borderRadius: theme.cardBorderRadius),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search field
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: theme.inputTextStyle,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle:
                      theme.inputTextStyle.copyWith(color: theme.hintColor),
                  prefixIcon:
                      Icon(Icons.search, size: 20, color: theme.hintColor),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  isDense: true,
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
                    borderSide:
                        BorderSide(color: theme.focusBorderColor, width: 2),
                  ),
                ),
                onChanged: (v) => setState(() => _searchText = v),
              ),
            ),
            Divider(height: 1, color: theme.borderColor),
            // Choices list — caps visible height at ~10 items, scrolls for more
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: listHeight),
              child: filtered.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No results found.',
                        style: theme.questionDescriptionStyle,
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) {
                        final choice = filtered[i];
                        final isSelected =
                            choice.value == widget.selectedValue;
                        return InkWell(
                          onTap: () => Navigator.of(context)
                              .pop(_PickerResult(choice.value)),
                          child: Container(
                            constraints:
                                const BoxConstraints(minHeight: _itemExtent),
                            color: isSelected
                                ? theme.primaryColor.withOpacity(0.08)
                                : null,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    choice.label,
                                    style: isSelected
                                        ? theme.choiceLabelStyle.copyWith(
                                            color: theme.primaryColor,
                                            fontWeight: FontWeight.w600,
                                          )
                                        : theme.choiceLabelStyle,
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check,
                                      size: 18, color: theme.primaryColor),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
