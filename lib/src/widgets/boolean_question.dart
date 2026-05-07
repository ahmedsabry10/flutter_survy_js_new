import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../theme/survey_theme.dart';

/// Renders a SurveyJS `boolean` question as a toggle switch.
class BooleanQuestion extends StatelessWidget {
  final QuestionModel question;
  final dynamic currentValue;
  final ValueChanged<bool?> onChanged;
  final bool enabled;

  const BooleanQuestion({
    super.key,
    required this.question,
    required this.onChanged,
    this.currentValue,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SurveyTheme.of(context);
    final value = currentValue is bool
        ? currentValue as bool
        : currentValue?.toString() == 'true'
            ? true
            : currentValue?.toString() == 'false'
                ? false
                : null;

    final falseLabel = question.labelFalse ?? 'No';
    final trueLabel = question.labelTrue ?? 'Yes';

    return Row(
      children: [
        // False label
        GestureDetector(
          onTap: enabled ? () => onChanged(false) : null,
          child: Text(
            falseLabel,
            style: theme.choiceLabelStyle.copyWith(
              color: value == false ? theme.primaryColor : theme.hintColor,
              fontWeight: value == false ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Toggle
        GestureDetector(
          onTap: enabled
              ? () {
                  if (value == null || value == false) {
                    onChanged(true);
                  } else {
                    onChanged(false);
                  }
                }
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 52,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: value == true
                  ? theme.primaryColor
                  : value == false
                      ? theme.hintColor
                      : theme.disabledColor,
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: value == true
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.all(3),
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // True label
        GestureDetector(
          onTap: enabled ? () => onChanged(true) : null,
          child: Text(
            trueLabel,
            style: theme.choiceLabelStyle.copyWith(
              color: value == true ? theme.primaryColor : theme.hintColor,
              fontWeight: value == true ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
