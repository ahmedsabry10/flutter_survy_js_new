import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../theme/survey_theme.dart';

/// Renders a SurveyJS `rating` question.
/// Supports stars (default) and numeric button styles.
class RatingQuestion extends StatelessWidget {
  final QuestionModel question;
  final dynamic currentValue;
  final ValueChanged<int?> onChanged;
  final bool enabled;

  const RatingQuestion({
    super.key,
    required this.question,
    required this.onChanged,
    this.currentValue,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SurveyTheme.of(context);
    final min = question.rateMin ?? 1;
    final max = question.rateMax ?? 5;
    final step = question.rateStep ?? 1;
    final selected = currentValue is int ? currentValue as int : int.tryParse(currentValue?.toString() ?? '');
    final rateType = question.rateType ?? 'labels';
    final useStars = rateType == 'stars' || (max - min <= 4 && rateType != 'labels');

    final values = <int>[];
    for (var i = min; i <= max; i += step) {
      values.add(i);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Min/Max descriptions
        if (question.minRateDescription != null || question.maxRateDescription != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (question.minRateDescription != null)
                  Text(
                    question.minRateDescription!,
                    style: theme.questionDescriptionStyle,
                  ),
                if (question.maxRateDescription != null)
                  Text(
                    question.maxRateDescription!,
                    style: theme.questionDescriptionStyle,
                  ),
              ],
            ),
          ),

        // Rating items
        useStars
            ? _buildStars(values, selected, theme)
            : _buildButtons(values, selected, theme),
      ],
    );
  }

  Widget _buildStars(List<int> values, int? selected, SurveyTheme theme) {
    return Wrap(
      spacing: 4,
      children: values.map((v) {
        final isFilled = selected != null && v <= selected;
        return GestureDetector(
          onTap: enabled ? () => onChanged(selected == v ? null : v) : null,
          child: Icon(
            isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 36,
            color: isFilled
                ? theme.ratingSelectedColor
                : theme.ratingUnselectedColor,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildButtons(List<int> values, int? selected, SurveyTheme theme) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: values.map((v) {
        final isSelected = selected == v;
        return GestureDetector(
          onTap: enabled ? () => onChanged(isSelected ? null : v) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected ? theme.primaryColor : Colors.transparent,
              border: Border.all(
                color: isSelected ? theme.primaryColor : theme.borderColor,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(
              '$v',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : theme.textColor,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
