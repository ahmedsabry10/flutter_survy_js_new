import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../theme/survey_theme.dart';

class QuestionWrapper extends StatelessWidget {
  final QuestionModel question;
  final Widget child;
  final String? errorText;
  final int? questionNumber;

  const QuestionWrapper({
    super.key,
    required this.question,
    required this.child,
    this.errorText,
    this.questionNumber,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SurveyTheme.of(context);
    final hasError = errorText != null && errorText!.isNotEmpty;

    // cardBorder from theme — but override with error color if there's an error
    final effectiveBorder = hasError
        ? Border.all(color: theme.errorColor, width: 1.5)
        : theme.cardBorder ?? Border.all(color: theme.borderColor, width: 1);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.questionBackgroundColor,
        borderRadius: theme.cardBorderRadius,
        border: effectiveBorder,
        boxShadow: hasError ? null : theme.cardShadow,
      ),
      padding: EdgeInsets.all(theme.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(theme),

          if (question.description != null && question.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(question.description!, style: theme.questionDescriptionStyle),
          ],

          const SizedBox(height: 12),

          child,

          if (hasError) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.error_outline, size: 14, color: theme.errorColor),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(errorText!, style: theme.errorTextStyle),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTitle(SurveyTheme theme) {
    final number = questionNumber != null ? '$questionNumber. ' : '';
    const required = ' *';

    return RichText(
      text: TextSpan(
        style: theme.questionTitleStyle,
        children: [
          if (number.isNotEmpty)
            TextSpan(
              text: number,
              style: theme.questionTitleStyle.copyWith(color: theme.hintColor),
            ),
          TextSpan(text: question.displayTitle),
          if (question.isRequired)
            TextSpan(
              text: required,
              style: theme.questionTitleStyle.copyWith(color: theme.errorColor),
            ),
        ],
      ),
    );
  }
}
