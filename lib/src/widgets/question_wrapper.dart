import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../theme/survey_theme.dart';

/// Wraps any question widget with the standard title, description,
/// required marker, and error message. All question widgets use this.
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

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.questionBackgroundColor,
        borderRadius: theme.cardBorderRadius,
        border: Border.all(
          color: hasError ? theme.errorColor : theme.borderColor,
          width: hasError ? 1.5 : 1,
        ),
      ),
      padding: EdgeInsets.all(theme.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          _buildTitle(theme),

          // Description
          if (question.description != null && question.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              question.description!,
              style: theme.questionDescriptionStyle,
            ),
          ],

          const SizedBox(height: 12),

          // The actual input widget
          child,

          // Error message
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
    final number = questionNumber != null ? '${questionNumber}. ' : '';
    final required = question.isRequired ? ' *' : '';

    return RichText(
      text: TextSpan(
        style: theme.questionTitleStyle,
        children: [
          if (number.isNotEmpty)
            TextSpan(
              text: number,
              style: theme.questionTitleStyle.copyWith(
                color: theme.hintColor,
              ),
            ),
          TextSpan(text: question.displayTitle),
          if (required.isNotEmpty)
            TextSpan(
              text: required,
              style: theme.questionTitleStyle.copyWith(
                color: theme.errorColor,
              ),
            ),
        ],
      ),
    );
  }
}
