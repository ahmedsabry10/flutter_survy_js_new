import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../theme/survey_theme.dart';

/// Renders a SurveyJS `multipletext` question.
/// Shows a group of labelled text inputs — answer is a Map<name, value>.
class MultipleTextQuestion extends StatefulWidget {
  final QuestionModel question;
  final Map<String, String> currentValues;
  final ValueChanged<Map<String, String>> onChanged;
  final bool enabled;

  const MultipleTextQuestion({
    super.key,
    required this.question,
    required this.onChanged,
    this.currentValues = const {},
    this.enabled = true,
  });

  @override
  State<MultipleTextQuestion> createState() => _MultipleTextQuestionState();
}

class _MultipleTextQuestionState extends State<MultipleTextQuestion> {
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final item in widget.question.items)
        item.name: TextEditingController(
          text: widget.currentValues[item.name] ?? '',
        ),
    };
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _onItemChanged(String name, String value) {
    final updated = Map<String, String>.from(widget.currentValues);
    updated[name] = value;
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = SurveyTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.question.items.map((item) {
        final controller = _controllers[item.name]!;
        final label = item.title ?? item.name;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Item label
              SizedBox(
                width: 110,
                child: RichText(
                  text: TextSpan(
                    style: theme.choiceLabelStyle,
                    children: [
                      TextSpan(text: label),
                      if (item.isRequired)
                        TextSpan(
                          text: ' *',
                          style: TextStyle(color: theme.errorColor),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Text input
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: widget.enabled,
                  keyboardType: _keyboardType(item.inputType),
                  style: theme.inputTextStyle,
                  decoration: InputDecoration(
                    hintText: item.placeholder,
                    hintStyle:
                        theme.inputTextStyle.copyWith(color: theme.hintColor),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
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
                  onChanged: (v) => _onItemChanged(item.name, v),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  TextInputType _keyboardType(String? inputType) {
    switch (inputType) {
      case 'email':
        return TextInputType.emailAddress;
      case 'number':
        return TextInputType.number;
      case 'tel':
        return TextInputType.phone;
      default:
        return TextInputType.text;
    }
  }
}
