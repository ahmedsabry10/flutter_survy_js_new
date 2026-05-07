import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../models/survey_choice.dart';
import '../theme/survey_theme.dart';

/// Renders a SurveyJS `dropdown` question as a Flutter DropdownButton.
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

    return Container(
      decoration: BoxDecoration(
        borderRadius: theme.inputBorderRadius,
        border: Border.all(color: theme.borderColor),
        color: enabled
            ? theme.questionBackgroundColor
            : theme.disabledColor.withOpacity(0.05),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: validValue,
          isExpanded: true,
          hint: Text(
            question.placeholder ?? 'Select...',
            style: theme.inputTextStyle.copyWith(color: theme.hintColor),
          ),
          icon: Icon(Icons.keyboard_arrow_down, color: theme.hintColor),
          style: theme.inputTextStyle,
          onChanged: enabled ? (v) => onChanged(v) : null,
          items: choices
              .map((c) => DropdownMenuItem(
                    value: c.value,
                    child: Text(c.label, style: theme.inputTextStyle),
                  ))
              .toList(),
        ),
      ),
    );
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
