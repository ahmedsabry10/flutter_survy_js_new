import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../models/survey_choice.dart';
import '../theme/survey_theme.dart';

/// Renders a SurveyJS `ranking` question.
/// Users drag and drop items to reorder them.
class RankingQuestion extends StatefulWidget {
  final QuestionModel question;
  final List<String> currentValues; // ordered list of choice values
  final ValueChanged<List<String>> onChanged;
  final bool enabled;

  const RankingQuestion({
    super.key,
    required this.question,
    required this.onChanged,
    this.currentValues = const [],
    this.enabled = true,
  });

  @override
  State<RankingQuestion> createState() => _RankingQuestionState();
}

class _RankingQuestionState extends State<RankingQuestion> {
  late List<SurveyChoice> _orderedChoices;

  @override
  void initState() {
    super.initState();
    _orderedChoices = _buildOrderedChoices();
  }

  List<SurveyChoice> _buildOrderedChoices() {
    final allChoices = widget.question.choices;
    if (widget.currentValues.isEmpty) return List.from(allChoices);

    // Sort based on currentValues order
    final ordered = <SurveyChoice>[];
    for (final v in widget.currentValues) {
      final match = allChoices.where((c) => c.value == v);
      if (match.isNotEmpty) ordered.add(match.first);
    }
    // Add any choices not in currentValues at the end
    for (final c in allChoices) {
      if (!ordered.contains(c)) ordered.add(c);
    }
    return ordered;
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (!widget.enabled) return;
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _orderedChoices.removeAt(oldIndex);
      _orderedChoices.insert(newIndex, item);
    });
    widget.onChanged(_orderedChoices.map((c) => c.value).toList());
  }

  @override
  Widget build(BuildContext context) {
    final theme = SurveyTheme.of(context);

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      onReorder: _onReorder,
      itemCount: _orderedChoices.length,
      itemBuilder: (context, index) {
        final choice = _orderedChoices[index];
        return _RankItem(
          key: ValueKey(choice.value),
          index: index,
          choice: choice,
          enabled: widget.enabled,
          theme: theme,
        );
      },
    );
  }
}

class _RankItem extends StatelessWidget {
  final int index;
  final SurveyChoice choice;
  final bool enabled;
  final SurveyTheme theme;

  const _RankItem({
    super.key,
    required this.index,
    required this.choice,
    required this.enabled,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: theme.questionBackgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: theme.borderColor),
      ),
      child: Row(
        children: [
          // Rank number badge
          Container(
            width: 36,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                bottomLeft: Radius.circular(6),
              ),
            ),
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: theme.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Label
          Expanded(
            child: Text(choice.label, style: theme.choiceLabelStyle),
          ),
          // Drag handle
          if (enabled)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(Icons.drag_handle_rounded,
                  color: theme.hintColor, size: 20),
            ),
        ],
      ),
    );
  }
}
