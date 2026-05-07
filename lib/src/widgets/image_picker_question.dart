import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../models/survey_choice.dart';
import '../theme/survey_theme.dart';

/// Renders a SurveyJS `imagepicker` question.
/// Shows a grid of images — user taps to select one (or multiple if multiSelect).
class ImagePickerQuestion extends StatelessWidget {
  final QuestionModel question;
  final dynamic currentValue; // String or List<String>
  final ValueChanged<dynamic> onChanged;
  final bool enabled;

  const ImagePickerQuestion({
    super.key,
    required this.question,
    required this.onChanged,
    this.currentValue,
    this.enabled = true,
  });

  bool get _isMulti => question.allowMultiple ?? false;

  bool _isSelected(String value) {
    if (_isMulti) {
      return currentValue is List &&
          (currentValue as List).contains(value);
    }
    return currentValue?.toString() == value;
  }

  void _toggle(String value) {
    if (_isMulti) {
      final current = currentValue is List
          ? List<String>.from(currentValue as List)
          : <String>[];
      current.contains(value)
          ? current.remove(value)
          : current.add(value);
      onChanged(current);
    } else {
      onChanged(_isSelected(value) ? null : value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SurveyTheme.of(context);
    final choices = question.choices;

    if (choices.isEmpty) {
      return Text('No images configured.',
          style: theme.questionDescriptionStyle);
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.3,
      ),
      itemCount: choices.length,
      itemBuilder: (context, i) {
        final choice = choices[i];
        final selected = _isSelected(choice.value);
        return _ImageChoice(
          choice: choice,
          isSelected: selected,
          enabled: enabled,
          theme: theme,
          onTap: () => _toggle(choice.value),
        );
      },
    );
  }
}

class _ImageChoice extends StatelessWidget {
  final SurveyChoice choice;
  final bool isSelected;
  final bool enabled;
  final SurveyTheme theme;
  final VoidCallback onTap;

  const _ImageChoice({
    required this.choice,
    required this.isSelected,
    required this.enabled,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? theme.primaryColor : theme.borderColor,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              choice.imageLink != null
                  ? Image.network(
                      choice.imageLink!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _Placeholder(theme: theme),
                    )
                  : _Placeholder(theme: theme),

              // Selection overlay
              if (isSelected)
                Container(
                  color: theme.primaryColor.withOpacity(0.15),
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.all(6),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: const Icon(Icons.check,
                        color: Colors.white, size: 14),
                  ),
                ),

              // Label at bottom
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.55),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    choice.label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final SurveyTheme theme;
  const _Placeholder({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.backgroundColor,
      child: Icon(Icons.image_outlined, color: theme.hintColor, size: 32),
    );
  }
}
