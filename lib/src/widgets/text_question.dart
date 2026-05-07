import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/question_model.dart';
import '../theme/survey_theme.dart';

/// Renders a SurveyJS `text` or `comment` question as a Flutter TextField.
class TextQuestion extends StatefulWidget {
  final QuestionModel question;
  final dynamic initialValue;
  final ValueChanged<String> onChanged;
  final bool enabled;

  const TextQuestion({
    super.key,
    required this.question,
    required this.onChanged,
    this.initialValue,
    this.enabled = true,
  });

  @override
  State<TextQuestion> createState() => _TextQuestionState();
}

class _TextQuestionState extends State<TextQuestion> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = SurveyTheme.of(context);
    final q = widget.question;
    final isComment = q.type.name == 'comment';

    return TextField(
      controller: _controller,
      enabled: widget.enabled,
      maxLines: isComment ? null : 1,
      minLines: isComment ? 3 : 1,
      maxLength: q.maxLength,
      keyboardType: _keyboardType(q.inputType),
      inputFormatters: _inputFormatters(q.inputType),
      style: theme.inputTextStyle,
      decoration: InputDecoration(
        hintText: q.placeholder,
        hintStyle: theme.inputTextStyle.copyWith(color: theme.hintColor),
        contentPadding: theme.inputPadding,
        filled: true,
        fillColor: widget.enabled
            ? theme.questionBackgroundColor
            : theme.disabledColor.withOpacity(0.1),
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
        disabledBorder: OutlineInputBorder(
          borderRadius: theme.inputBorderRadius,
          borderSide: BorderSide(color: theme.disabledColor),
        ),
        counterText: '',
      ),
      onChanged: widget.onChanged,
    );
  }

  TextInputType _keyboardType(String? inputType) {
    switch (inputType) {
      case 'email': return TextInputType.emailAddress;
      case 'number': return TextInputType.number;
      case 'tel': return TextInputType.phone;
      case 'url': return TextInputType.url;
      case 'date': return TextInputType.datetime;
      default: return TextInputType.text;
    }
  }

  List<TextInputFormatter> _inputFormatters(String? inputType) {
    if (inputType == 'number') {
      return [FilteringTextInputFormatter.allow(RegExp(r'[\d.\-]'))];
    }
    return [];
  }
}
