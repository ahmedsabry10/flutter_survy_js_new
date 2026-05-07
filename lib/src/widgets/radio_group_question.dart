import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../models/survey_choice.dart';
import '../theme/survey_theme.dart';
import 'shared_choice_item.dart';

/// Renders a SurveyJS `radiogroup` question.
class RadioGroupQuestion extends StatefulWidget {
  final QuestionModel question;
  final dynamic currentValue;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  const RadioGroupQuestion({
    super.key,
    required this.question,
    required this.onChanged,
    this.currentValue,
    this.enabled = true,
  });

  @override
  State<RadioGroupQuestion> createState() => _RadioGroupQuestionState();
}

class _RadioGroupQuestionState extends State<RadioGroupQuestion> {
  final _otherController = TextEditingController();

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = SurveyTheme.of(context);
    final choices = _buildChoices();
    final selectedValue = widget.currentValue?.toString();
    final otherSelected = selectedValue == 'other' ||
        (selectedValue?.startsWith('other:') ?? false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...choices.map((choice) {
          final isSelected = selectedValue == choice.value ||
              (choice.value == 'other' && otherSelected);
          return ChoiceItem(
            choice: choice,
            isSelected: isSelected,
            enabled: widget.enabled,
            theme: theme,
            onTap: () => widget.onChanged(isSelected ? null : choice.value),
            leading: Radio<String>(
              value: choice.value,
              groupValue: otherSelected ? 'other' : selectedValue,
              onChanged: widget.enabled ? (v) => widget.onChanged(v) : null,
              activeColor: theme.primaryColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          );
        }),

        // "Other" free-text input
        if (widget.question.hasOther == true && otherSelected)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 32),
            child: TextField(
              controller: _otherController,
              enabled: widget.enabled,
              style: theme.inputTextStyle,
              decoration: InputDecoration(
                hintText: 'Please describe...',
                hintStyle: theme.inputTextStyle.copyWith(color: theme.hintColor),
                contentPadding: theme.inputPadding,
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
              ),
              onChanged: (v) => widget.onChanged('other:$v'),
            ),
          ),
      ],
    );
  }

  List<SurveyChoice> _buildChoices() {
    final choices = List<SurveyChoice>.from(widget.question.choices);
    if (widget.question.hasNone == true) {
      choices.add(SurveyChoice(value: 'none', text: widget.question.noneText ?? 'None'));
    }
    if (widget.question.hasOther == true) {
      choices.add(SurveyChoice(value: 'other', text: widget.question.otherText ?? 'Other (describe)'));
    }
    if (widget.question.choicesOrder == 'asc') {
      choices.sort((a, b) => a.label.compareTo(b.label));
    } else if (widget.question.choicesOrder == 'desc') {
      choices.sort((a, b) => b.label.compareTo(a.label));
    } else if (widget.question.choicesOrder == 'random') {
      choices.shuffle();
    }
    return choices;
  }
}
