import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../theme/survey_theme.dart';
import '../controller/survey_controller.dart';
import 'question_widget.dart';

/// Renders a SurveyJS `paneldynamic` question.
///
/// The user can add / remove repeated groups of sub-questions.
/// Answer format: List<Map<String, dynamic>> — one map per panel instance.
class PanelDynamicQuestion extends StatefulWidget {
  final QuestionModel question;
  final List<Map<String, dynamic>> currentValues;
  final ValueChanged<List<Map<String, dynamic>>> onChanged;
  final SurveyController parentController;
  final bool enabled;

  const PanelDynamicQuestion({
    super.key,
    required this.question,
    required this.onChanged,
    required this.parentController,
    this.currentValues = const [],
    this.enabled = true,
  });

  @override
  State<PanelDynamicQuestion> createState() => _PanelDynamicQuestionState();
}

class _PanelDynamicQuestionState extends State<PanelDynamicQuestion> {
  // Each panel instance has its own answers map
  late List<Map<String, dynamic>> _panels;

  @override
  void initState() {
    super.initState();
    final initial = widget.currentValues.isNotEmpty
        ? widget.currentValues
        : _buildInitialPanels();
    _panels = initial.map((m) => Map<String, dynamic>.from(m)).toList();
  }

  List<Map<String, dynamic>> _buildInitialPanels() {
    final count = widget.question.panelCount ?? 1;
    return List.generate(count, (_) => {});
  }

  void _addPanel() {
    setState(() => _panels.add({}));
    widget.onChanged(_panels);
  }

  void _removePanel(int index) {
    setState(() => _panels.removeAt(index));
    widget.onChanged(_panels);
  }

  void _setAnswer(int panelIndex, String name, dynamic value) {
    setState(() => _panels[panelIndex][name] = value);
    widget.onChanged(_panels);
  }

  bool get _canAdd {
    final max = widget.question.maxPanelCount;
    return max == null || _panels.length < max;
  }

  bool get _canRemove {
    final min = widget.question.minPanelCount ?? 0;
    return _panels.length > min;
  }

  @override
  Widget build(BuildContext context) {
    final theme = SurveyTheme.of(context);
    final templateElements = widget.question.elements;
    final addText = widget.question.panelAddText ?? 'Add Panel';
    final removeText = widget.question.panelRemoveText ?? 'Remove';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Panel instances
        ...List.generate(_panels.length, (i) {
          return _PanelInstance(
            key: ValueKey('panel_$i'),
            index: i,
            panelCount: _panels.length,
            templateTitle: widget.question.templateTitle,
            elements: templateElements,
            answers: _panels[i],
            enabled: widget.enabled,
            canRemove: _canRemove && widget.enabled,
            removeText: removeText,
            theme: theme,
            onAnswerChanged: (name, value) => _setAnswer(i, name, value),
            onRemove: () => _removePanel(i),
          );
        }),

        // Add button
        if (widget.enabled && _canAdd)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: OutlinedButton.icon(
              onPressed: _addPanel,
              icon: Icon(Icons.add_circle_outline,
                  size: 18, color: theme.primaryColor),
              label: Text(
                addText,
                style: TextStyle(
                    color: theme.primaryColor, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.primaryColor),
                shape: RoundedRectangleBorder(
                    borderRadius: theme.buttonBorderRadius),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Single Panel Instance ────────────────────────────────────────────────────

class _PanelInstance extends StatelessWidget {
  final int index;
  final int panelCount;
  final String? templateTitle;
  final List<QuestionModel> elements;
  final Map<String, dynamic> answers;
  final bool enabled;
  final bool canRemove;
  final String removeText;
  final SurveyTheme theme;
  final void Function(String name, dynamic value) onAnswerChanged;
  final VoidCallback onRemove;

  const _PanelInstance({
    super.key,
    required this.index,
    required this.panelCount,
    required this.templateTitle,
    required this.elements,
    required this.answers,
    required this.enabled,
    required this.canRemove,
    required this.removeText,
    required this.theme,
    required this.onAnswerChanged,
    required this.onRemove,
  });

  String get _title {
    if (templateTitle == null) return 'Panel ${index + 1}';
    return templateTitle!
        .replaceAll('{panelIndex}', '${index + 1}')
        .replaceAll('{panelCount}', '$panelCount');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.borderColor),
        borderRadius: theme.cardBorderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Panel header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: theme.backgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: theme.cardBorderRadius.topLeft,
                topRight: theme.cardBorderRadius.topRight,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _title,
                    style: theme.questionTitleStyle
                        .copyWith(fontSize: 14, color: theme.primaryColor),
                  ),
                ),
                if (canRemove)
                  GestureDetector(
                    onTap: onRemove,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.remove_circle_outline,
                            size: 16, color: theme.errorColor),
                        const SizedBox(width: 4),
                        Text(
                          removeText,
                          style: TextStyle(
                              fontSize: 13,
                              color: theme.errorColor,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Sub-questions
          Padding(
            padding: const EdgeInsets.all(14),
            child: _PanelInstanceBody(
              elements: elements,
              answers: answers,
              enabled: enabled,
              theme: theme,
              onAnswerChanged: onAnswerChanged,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Panel Instance Body — lightweight local controller ───────────────────────

class _PanelInstanceBody extends StatefulWidget {
  final List<QuestionModel> elements;
  final Map<String, dynamic> answers;
  final bool enabled;
  final SurveyTheme theme;
  final void Function(String name, dynamic value) onAnswerChanged;

  const _PanelInstanceBody({
    required this.elements,
    required this.answers,
    required this.enabled,
    required this.theme,
    required this.onAnswerChanged,
  });

  @override
  State<_PanelInstanceBody> createState() => _PanelInstanceBodyState();
}

class _PanelInstanceBodyState extends State<_PanelInstanceBody> {
  // Lightweight local state — no full SurveyController needed
  late Map<String, dynamic> _localAnswers;

  @override
  void initState() {
    super.initState();
    _localAnswers = Map<String, dynamic>.from(widget.answers);
  }

  void _setAnswer(String name, dynamic value) {
    setState(() => _localAnswers[name] = value);
    widget.onAnswerChanged(name, value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.elements.map((q) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _InlinePanelQuestion(
            question: q,
            answers: _localAnswers,
            enabled: widget.enabled,
            theme: widget.theme,
            onChanged: (v) => _setAnswer(q.name, v),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Inline question renderer for panel instances ─────────────────────────────
// Lightweight version that doesn't need a full SurveyController

class _InlinePanelQuestion extends StatelessWidget {
  final QuestionModel question;
  final Map<String, dynamic> answers;
  final bool enabled;
  final SurveyTheme theme;
  final ValueChanged<dynamic> onChanged;

  const _InlinePanelQuestion({
    required this.question,
    required this.answers,
    required this.enabled,
    required this.theme,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Reuse QuestionWrapper for consistent styling
    return Container(
      decoration: BoxDecoration(
        color: theme.questionBackgroundColor,
        borderRadius: theme.cardBorderRadius,
        border: Border.all(color: theme.borderColor.withOpacity(0.5)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          RichText(
            text: TextSpan(
              style: theme.questionTitleStyle.copyWith(fontSize: 14),
              children: [
                TextSpan(text: question.displayTitle),
                if (question.isRequired)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: theme.errorColor),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Re-use question_widget dispatcher via a fake mini-controller
          _buildField(context),
        ],
      ),
    );
  }

  Widget _buildField(BuildContext context) {
    final answer = answers[question.name];
    // Import individual widgets directly to avoid circular dependency
    // with QuestionWidget (which needs a full SurveyController)
    switch (question.type.name) {
      case 'text':
      case 'comment':
        return _SimpleTextField(
            question: question,
            answer: answer,
            enabled: enabled,
            theme: theme,
            onChanged: onChanged);
      default:
        return Text(
          '${question.type.name} — supported in full survey mode',
          style: theme.questionDescriptionStyle,
        );
    }
  }
}

// Simple text field for use inside panel dynamic
class _SimpleTextField extends StatefulWidget {
  final QuestionModel question;
  final dynamic answer;
  final bool enabled;
  final SurveyTheme theme;
  final ValueChanged<dynamic> onChanged;

  const _SimpleTextField({
    required this.question,
    required this.answer,
    required this.enabled,
    required this.theme,
    required this.onChanged,
  });

  @override
  State<_SimpleTextField> createState() => _SimpleTextFieldState();
}

class _SimpleTextFieldState extends State<_SimpleTextField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.answer?.toString() ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    return TextField(
      controller: _ctrl,
      enabled: widget.enabled,
      maxLines: widget.question.type.name == 'comment' ? 3 : 1,
      style: theme.inputTextStyle,
      decoration: InputDecoration(
        hintText: widget.question.placeholder,
        hintStyle: theme.inputTextStyle.copyWith(color: theme.hintColor),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
          borderSide: BorderSide(color: theme.focusBorderColor, width: 2),
        ),
      ),
      onChanged: widget.onChanged,
    );
  }
}
