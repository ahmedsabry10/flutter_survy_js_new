import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../models/question_type.dart';
import '../controller/survey_controller.dart';
import '../theme/survey_theme.dart';
import 'question_wrapper.dart';
import 'text_question.dart';
import 'radio_group_question.dart';
import 'checkbox_question.dart';
import 'dropdown_question.dart';
import 'rating_question.dart';
import 'boolean_question.dart';
import 'matrix_question.dart';
import 'matrix_dropdown_question.dart';
import 'matrix_dynamic_question.dart';
import 'multiple_text_question.dart';
import 'ranking_question.dart';
import 'tagbox_question.dart';
import 'panel_dynamic_question.dart';
import 'image_picker_question.dart';
import 'signature_pad_question.dart';
import 'file_question.dart';

/// Dispatches to the correct widget based on [question.type].
class QuestionWidget extends StatelessWidget {
  final QuestionModel question;
  final SurveyController controller;
  final int? questionNumber;
  final OnUploadFile? onUploadFile;
  final OnDownloadFile? onDownloadFile;
  final OnClearFile? onClearFile;

  const QuestionWidget({
    super.key,
    required this.question,
    required this.controller,
    this.questionNumber,
    this.onUploadFile,
    this.onDownloadFile,
    this.onClearFile,
  });

  @override
  Widget build(BuildContext context) {
    if (!controller.isQuestionVisible(question)) {
      return const SizedBox.shrink();
    }

    final enabled = controller.isQuestionEnabled(question);
    final errorText = controller.getError(question.name);
    final answer = controller.getAnswer(question.name);

    // Display-only types skip the wrapper card
    if (question.type == QuestionType.html) {
      return _HtmlDisplay(html: question.html ?? '');
    }
    if (question.type == QuestionType.image) {
      return _ImageDisplay(question: question);
    }
    if (question.type == QuestionType.empty) {
      return const SizedBox.shrink();
    }

    // Panel is a transparent container — no card wrapper
    if (question.type == QuestionType.panel) {
      return _PanelContainer(
        question: question,
        controller: controller,
      );
    }

    // PanelDynamic — also skips the wrapper card
    if (question.type == QuestionType.paneldynamic) {
      return QuestionWrapper(
        question: question,
        errorText: controller.getError(question.name),
        questionNumber: questionNumber,
        child: PanelDynamicQuestion(
          question: question,
          currentValues: controller.getAnswer(question.name) is List
              ? List<Map<String, dynamic>>.from(
                  (controller.getAnswer(question.name) as List)
                      .map((e) => Map<String, dynamic>.from(e as Map)))
              : [],
          parentController: controller,
          enabled: controller.isQuestionEnabled(question),
          onChanged: (v) => controller.setAnswer(question.name, v),
        ),
      );
    }

    return QuestionWrapper(
      question: question,
      errorText: errorText,
      questionNumber: questionNumber,
      child: _buildInput(context, answer, enabled),
    );
  }

  Widget _buildInput(BuildContext context, dynamic answer, bool enabled) {
    final theme = SurveyTheme.of(context);

    switch (question.type) {
      // ─── Text / Comment ───────────────────────────────────────────────────
      case QuestionType.text:
      case QuestionType.comment:
        return TextQuestion(
          question: question,
          initialValue: answer,
          enabled: enabled,
          onChanged: (v) => controller.setAnswer(question.name, v),
        );

      // ─── Radio ────────────────────────────────────────────────────────────
      case QuestionType.radiogroup:
        return RadioGroupQuestion(
          question: question,
          currentValue: answer,
          enabled: enabled,
          onChanged: (v) => controller.setAnswer(question.name, v),
        );

      // ─── Checkbox ─────────────────────────────────────────────────────────
      case QuestionType.checkbox:
        return CheckboxQuestion(
          question: question,
          currentValues: answer is List ? List<String>.from(answer) : [],
          enabled: enabled,
          onChanged: (v) => controller.setAnswer(question.name, v),
        );

      // ─── Dropdown ─────────────────────────────────────────────────────────
      case QuestionType.dropdown:
        return DropdownQuestion(
          question: question,
          currentValue: answer,
          enabled: enabled,
          onChanged: (v) => controller.setAnswer(question.name, v),
        );

      // ─── Tagbox (multi-select searchable) ─────────────────────────────────
      case QuestionType.tagbox:
        return TagboxQuestion(
          question: question,
          currentValues: answer is List ? List<String>.from(answer) : [],
          enabled: enabled,
          onChanged: (v) => controller.setAnswer(question.name, v),
        );

      // ─── Rating ───────────────────────────────────────────────────────────
      case QuestionType.rating:
        return RatingQuestion(
          question: question,
          currentValue: answer,
          enabled: enabled,
          onChanged: (v) => controller.setAnswer(question.name, v),
        );

      // ─── Boolean ──────────────────────────────────────────────────────────
      case QuestionType.boolean:
        return BooleanQuestion(
          question: question,
          currentValue: answer,
          enabled: enabled,
          onChanged: (v) => controller.setAnswer(question.name, v),
        );

      // ─── Matrix ───────────────────────────────────────────────────────────
      case QuestionType.matrix:
        return MatrixQuestion(
          question: question,
          currentValues: answer is Map
              ? Map<String, String>.from(answer)
              : {},
          enabled: enabled,
          onChanged: (v) => controller.setAnswer(question.name, v),
        );

      // ─── Multiple Text ────────────────────────────────────────────────────
      case QuestionType.multipletext:
        return MultipleTextQuestion(
          question: question,
          currentValues: answer is Map
              ? Map<String, String>.from(answer)
              : {},
          enabled: enabled,
          onChanged: (v) => controller.setAnswer(question.name, v),
        );

      // ─── Ranking ──────────────────────────────────────────────────────────
      case QuestionType.ranking:
        return RankingQuestion(
          question: question,
          currentValues: answer is List ? List<String>.from(answer) : [],
          enabled: enabled,
          onChanged: (v) => controller.setAnswer(question.name, v),
        );

      // ─── Image Picker ─────────────────────────────────────────────────────
      case QuestionType.imagepicker:
        return ImagePickerQuestion(
          question: question,
          currentValue: answer,
          enabled: enabled,
          onChanged: (v) => controller.setAnswer(question.name, v),
        );

      // ─── Signature Pad ────────────────────────────────────────────────────
      case QuestionType.signaturepad:
        return SignaturePadQuestion(
          question: question,
          currentValue: answer,
          enabled: enabled,
          onChanged: (v) => controller.setAnswer(question.name, v),
        );

      // ─── File Upload ──────────────────────────────────────────────────────
      case QuestionType.file:
        return FileQuestion(
          question: question,
          currentFiles: answer is List
              ? List<SurveyFile>.from(
                  (answer as List).map((e) => e is SurveyFile
                      ? e
                      : SurveyFile.fromJson(Map<String, dynamic>.from(e as Map))))
              : [],
          enabled: enabled,
          onUploadFile: onUploadFile,
          onDownloadFile: onDownloadFile,
          onClearFile: onClearFile,
          onChanged: (v) => controller.setAnswer(question.name, v),
        );

      // ─── Expression (read-only computed field) ───────────────────────────
      case QuestionType.expression:
        // Try 1: look up calculated value by name directly e.g. {ageBucket}
        // Try 2: evaluate the raw expression string
        // Try 3: look up by question name
        dynamic exprValue;
        if (question.expression != null) {
          final expr = question.expression!.trim();
          // Simple {varName} reference → direct lookup
          final simpleRef = RegExp(r'^\{(\w+)\}$').firstMatch(expr);
          if (simpleRef != null) {
            exprValue = controller.getAnswer(simpleRef.group(1)!);
          } else {
            // Complex expression → evaluate it
            exprValue = controller.evaluateCalculatedExpression(expr);
          }
        }
        exprValue ??= controller.getAnswer(question.name);
        return _ExpressionDisplay(
          question: question,
          value: exprValue,
          theme: theme,
        );

      // ─── MatrixDropdown ───────────────────────────────────────────────────
      case QuestionType.matrixdropdown:
        return MatrixDropdownQuestion(
          question: question,
          currentValues: answer is Map
              ? Map<String, Map<String, dynamic>>.from(
                  (answer as Map).map((k, v) =>
                      MapEntry(k.toString(), Map<String, dynamic>.from(v as Map))))
              : {},
          enabled: enabled,
          onChanged: (v) => controller.setAnswer(question.name, v),
        );

      // ─── MatrixDynamic ────────────────────────────────────────────────────
      case QuestionType.matrixdynamic:
        return MatrixDynamicQuestion(
          question: question,
          currentValues: answer is List
              ? List<Map<String, dynamic>>.from(
                  (answer as List).map((e) => Map<String, dynamic>.from(e as Map)))
              : [],
          enabled: enabled,
          onChanged: (v) => controller.setAnswer(question.name, v),
        );

      // ─── Unsupported ──────────────────────────────────────────────────────
      default:
        return _UnsupportedBadge(type: question.type.name, theme: theme);
    }
  }
}

// ─── Panel Container ──────────────────────────────────────────────────────────

class _PanelContainer extends StatelessWidget {
  final QuestionModel question;
  final SurveyController controller;

  const _PanelContainer({required this.question, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = SurveyTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Panel title (optional)
        if (question.title != null && question.title!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              question.displayTitle,
              style: theme.questionTitleStyle.copyWith(
                fontSize: 15,
                color: theme.hintColor,
              ),
            ),
          ),

        // Panel border + children
        Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: theme.primaryColor.withOpacity(0.4), width: 3),
            ),
          ),
          padding: const EdgeInsets.only(left: 14),
          child: Column(
            children: question.elements.map((child) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: QuestionWidget(question: child, controller: controller),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ─── HTML Display ─────────────────────────────────────────────────────────────

class _HtmlDisplay extends StatelessWidget {
  final String html;
  const _HtmlDisplay({required this.html});

  @override
  Widget build(BuildContext context) {
    final theme = SurveyTheme.of(context);
    final text = html
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'<strong>(.*?)</strong>'), r'\1')
        .replaceAll(RegExp(r'<[^>]+>'), '');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(text, style: theme.inputTextStyle),
    );
  }
}

// ─── Image Display ────────────────────────────────────────────────────────────

class _ImageDisplay extends StatelessWidget {
  final QuestionModel question;
  const _ImageDisplay({required this.question});

  @override
  Widget build(BuildContext context) {
    final url = question.imageLink;
    if (url == null || url.isEmpty) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 80,
          color: Colors.grey.shade100,
          child: const Center(
            child: Icon(Icons.broken_image_outlined, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}

// ─── Unsupported Badge ────────────────────────────────────────────────────────

class _UnsupportedBadge extends StatelessWidget {
  final String type;
  final SurveyTheme theme;
  const _UnsupportedBadge({required this.type, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.07),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.orange.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.construction_outlined, size: 16, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Question type "$type" — coming in next version',
              style: theme.questionDescriptionStyle.copyWith(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Expression Display ───────────────────────────────────────────────────────

class _ExpressionDisplay extends StatelessWidget {
  final QuestionModel question;
  final dynamic value;
  final SurveyTheme theme;

  const _ExpressionDisplay({
    required this.question,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    // Format value
    String display;
    if (value == null) {
      display = question.expression ?? '—';
    } else if (value is double && question.maximumFractionDigits != null) {
      display = value.toStringAsFixed(question.maximumFractionDigits!);
    } else if (value is double && value == value.roundToDouble()) {
      display = value.toInt().toString();
    } else {
      display = value.toString();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: theme.inputBorderRadius,
        border: Border.all(color: theme.borderColor),
      ),
      child: Row(
        children: [
          Icon(Icons.functions, size: 16, color: theme.hintColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              display,
              style: theme.inputTextStyle.copyWith(
                color: theme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
