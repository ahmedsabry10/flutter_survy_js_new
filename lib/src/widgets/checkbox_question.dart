import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../models/survey_choice.dart';
import '../theme/survey_theme.dart';
import 'shared_choice_item.dart';

/// Renders a SurveyJS `checkbox` question.
class CheckboxQuestion extends StatelessWidget {
  final QuestionModel question;
  final List<String> currentValues;
  final ValueChanged<List<String>> onChanged;
  final bool enabled;

  const CheckboxQuestion({
    super.key,
    required this.question,
    required this.onChanged,
    this.currentValues = const [],
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SurveyTheme.of(context);
    final choices = _buildChoices();
    final allValues = choices.map((c) => c.value).toList();
    final allSelected = allValues.every((v) => currentValues.contains(v));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Select All
        if (question.hasSelectAll == true)
          ChoiceItem(
            choice: SurveyChoice(value: '__all__', text: 'Select All'),
            isSelected: allSelected,
            enabled: enabled,
            theme: theme,
            onTap: () => onChanged(allSelected ? [] : allValues),
            leading: Checkbox(
              value: allSelected,
              tristate: true,
              onChanged: enabled ? (_) => onChanged(allSelected ? [] : allValues) : null,
              activeColor: theme.primaryColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),

        ...choices.map((choice) {
          final isSelected = currentValues.contains(choice.value);
          return ChoiceItem(
            choice: choice,
            isSelected: isSelected,
            enabled: enabled,
            theme: theme,
            onTap: () => _toggle(choice.value),
            leading: Checkbox(
              value: isSelected,
              onChanged: enabled ? (_) => _toggle(choice.value) : null,
              activeColor: theme.primaryColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          );
        }),
      ],
    );
  }

  void _toggle(String value) {
    final updated = List<String>.from(currentValues);
    updated.contains(value) ? updated.remove(value) : updated.add(value);
    onChanged(updated);
  }

  List<SurveyChoice> _buildChoices() {
    final choices = List<SurveyChoice>.from(question.choices);
    if (question.hasNone == true) {
      choices.add(SurveyChoice(value: 'none', text: question.noneText ?? 'None'));
    }
    if (question.hasOther == true) {
      choices.add(SurveyChoice(value: 'other', text: question.otherText ?? 'Other'));
    }
    if (question.choicesOrder == 'asc') {
      choices.sort((a, b) => a.label.compareTo(b.label));
    } else if (question.choicesOrder == 'desc') {
      choices.sort((a, b) => b.label.compareTo(a.label));
    } else if (question.choicesOrder == 'random') {
      choices.shuffle();
    }
    return choices;
  }
}
