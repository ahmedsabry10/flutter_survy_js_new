import 'package:flutter/material.dart';
import '../models/survey_choice.dart';
import '../theme/survey_theme.dart';

/// Reusable row for a single choice item.
/// Used by [RadioGroupQuestion] and [CheckboxQuestion].
class ChoiceItem extends StatelessWidget {
  final SurveyChoice choice;
  final bool isSelected;
  final bool enabled;
  final SurveyTheme theme;
  final VoidCallback onTap;
  final Widget leading;

  const ChoiceItem({
    super.key,
    required this.choice,
    required this.isSelected,
    required this.enabled,
    required this.theme,
    required this.onTap,
    required this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withOpacity(0.07)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                choice.label,
                style: theme.choiceLabelStyle.copyWith(
                  color: enabled ? theme.textColor : theme.disabledColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
