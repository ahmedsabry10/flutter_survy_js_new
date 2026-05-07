import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../models/survey_choice.dart';
import '../theme/survey_theme.dart';

/// Renders a SurveyJS `tagbox` question.
/// Multi-select searchable dropdown — selected values shown as chips.
class TagboxQuestion extends StatefulWidget {
  final QuestionModel question;
  final List<String> currentValues;
  final ValueChanged<List<String>> onChanged;
  final bool enabled;

  const TagboxQuestion({
    super.key,
    required this.question,
    required this.onChanged,
    this.currentValues = const [],
    this.enabled = true,
  });

  @override
  State<TagboxQuestion> createState() => _TagboxQuestionState();
}

class _TagboxQuestionState extends State<TagboxQuestion> {
  bool _isOpen = false;
  String _searchText = '';
  final _searchController = TextEditingController();
  final _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _searchController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  List<SurveyChoice> get _filteredChoices {
    final all = widget.question.choices;
    if (_searchText.isEmpty) return all;
    return all
        .where((c) =>
            c.label.toLowerCase().contains(_searchText.toLowerCase()))
        .toList();
  }

  void _toggleChoice(String value) {
    final updated = List<String>.from(widget.currentValues);
    if (updated.contains(value)) {
      updated.remove(value);
    } else {
      updated.add(value);
    }
    widget.onChanged(updated);
  }

  void _removeChip(String value) {
    final updated = List<String>.from(widget.currentValues)..remove(value);
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = SurveyTheme.of(context);
    final selectedChoices = widget.question.choices
        .where((c) => widget.currentValues.contains(c.value))
        .toList();
    final filtered = _filteredChoices
        .where((c) => !widget.currentValues.contains(c.value))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input box
        GestureDetector(
          onTap: widget.enabled
              ? () => setState(() => _isOpen = !_isOpen)
              : null,
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(
                color:
                    _isOpen ? theme.focusBorderColor : theme.borderColor,
                width: _isOpen ? 2 : 1,
              ),
              borderRadius: theme.inputBorderRadius,
              color: widget.enabled
                  ? theme.questionBackgroundColor
                  : theme.disabledColor.withOpacity(0.05),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      // Selected chips
                      ...selectedChoices.map((c) => _Chip(
                            label: c.label,
                            theme: theme,
                            onRemove: widget.enabled
                                ? () => _removeChip(c.value)
                                : null,
                          )),
                      // Placeholder
                      if (selectedChoices.isEmpty)
                        Text(
                          widget.question.placeholder ?? 'Select...',
                          style: theme.inputTextStyle
                              .copyWith(color: theme.hintColor),
                        ),
                    ],
                  ),
                ),
                Icon(
                  _isOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: theme.hintColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        // Dropdown panel
        if (_isOpen) ...[
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: theme.borderColor),
              borderRadius: theme.inputBorderRadius,
              color: theme.questionBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search field
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    controller: _searchController,
                    style: theme.inputTextStyle,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: theme.inputTextStyle
                          .copyWith(color: theme.hintColor),
                      prefixIcon: Icon(Icons.search,
                          size: 18, color: theme.hintColor),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
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
                        borderSide: BorderSide(
                            color: theme.focusBorderColor, width: 2),
                      ),
                    ),
                    onChanged: (v) => setState(() => _searchText = v),
                  ),
                ),
                // Choices list
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: filtered.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            'No results found.',
                            style: theme.questionDescriptionStyle,
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: filtered.length,
                          itemBuilder: (ctx, i) {
                            final choice = filtered[i];
                            return InkWell(
                              onTap: () {
                                _toggleChoice(choice.value);
                                setState(() {});
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                child: Text(choice.label,
                                    style: theme.choiceLabelStyle),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final SurveyTheme theme;
  final VoidCallback? onRemove;

  const _Chip(
      {required this.label, required this.theme, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: theme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onRemove,
              child: Icon(Icons.close, size: 14, color: theme.primaryColor),
            ),
          ],
        ],
      ),
    );
  }
}
