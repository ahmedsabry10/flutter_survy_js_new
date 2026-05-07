import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../theme/survey_theme.dart';

/// Renders a SurveyJS `file` question.
///
/// Shows a tap-to-upload area. In a real app wire this to
/// `image_picker` or `file_picker` package — the widget
/// handles display and state; you inject the bytes/path via [onChanged].
///
/// Answer format: List<Map> — same as SurveyJS:
/// [{"name": "file.pdf", "type": "application/pdf", "content": "<base64>"}]
class FileQuestion extends StatefulWidget {
  final QuestionModel question;
  final List<Map<String, dynamic>> currentFiles;
  final ValueChanged<List<Map<String, dynamic>>> onChanged;

  /// Called when the user taps the upload area.
  /// Implement this in your app to open a file picker and return files.
  final Future<List<Map<String, dynamic>>> Function()? onPickFiles;
  final bool enabled;

  const FileQuestion({
    super.key,
    required this.question,
    required this.onChanged,
    this.currentFiles = const [],
    this.onPickFiles,
    this.enabled = true,
  });

  @override
  State<FileQuestion> createState() => _FileQuestionState();
}

class _FileQuestionState extends State<FileQuestion> {
  late List<Map<String, dynamic>> _files;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _files = List.from(widget.currentFiles);
  }

  Future<void> _pick() async {
    if (!widget.enabled || widget.onPickFiles == null) return;
    setState(() => _loading = true);
    try {
      final picked = await widget.onPickFiles!();
      if (widget.question.allowMultiple == true) {
        _files.addAll(picked);
      } else {
        _files = picked.take(1).toList();
      }
      widget.onChanged(_files);
      setState(() {});
    } finally {
      setState(() => _loading = false);
    }
  }

  void _remove(int index) {
    setState(() => _files.removeAt(index));
    widget.onChanged(_files);
  }

  @override
  Widget build(BuildContext context) {
    final theme = SurveyTheme.of(context);
    final multi = widget.question.allowMultiple ?? false;
    final accepted = widget.question.acceptedTypes?.join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Drop zone / tap area
        if (widget.enabled && (multi || _files.isEmpty))
          GestureDetector(
            onTap: _pick,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: theme.backgroundColor,
                borderRadius: theme.inputBorderRadius,
                border: Border.all(
                  color: theme.borderColor,
                  style: BorderStyle.solid,
                ),
              ),
              child: _loading
                  ? Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.primaryColor,
                        ),
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cloud_upload_outlined,
                            size: 32, color: theme.hintColor),
                        const SizedBox(height: 8),
                        Text(
                          widget.onPickFiles != null
                              ? 'Tap to upload'
                              : 'File upload not configured',
                          style: TextStyle(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.w600),
                        ),
                        if (accepted != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Accepted: $accepted',
                            style: theme.questionDescriptionStyle,
                          ),
                        ],
                      ],
                    ),
            ),
          ),

        // File list
        if (_files.isNotEmpty) ...[
          const SizedBox(height: 10),
          ..._files.asMap().entries.map((e) {
            final file = e.value;
            final name = file['name']?.toString() ?? 'File ${e.key + 1}';
            final type = file['type']?.toString() ?? '';

            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: theme.questionBackgroundColor,
                borderRadius: theme.inputBorderRadius,
                border: Border.all(color: theme.borderColor),
              ),
              child: Row(
                children: [
                  Icon(_iconFor(type),
                      size: 20, color: theme.primaryColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(name,
                        style: theme.inputTextStyle,
                        overflow: TextOverflow.ellipsis),
                  ),
                  if (widget.enabled)
                    GestureDetector(
                      onTap: () => _remove(e.key),
                      child: Icon(Icons.close,
                          size: 18, color: theme.hintColor),
                    ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  IconData _iconFor(String mimeType) {
    if (mimeType.startsWith('image/')) return Icons.image_outlined;
    if (mimeType.contains('pdf')) return Icons.picture_as_pdf_outlined;
    if (mimeType.contains('word') || mimeType.contains('document')) {
      return Icons.description_outlined;
    }
    if (mimeType.contains('sheet') || mimeType.contains('excel')) {
      return Icons.table_chart_outlined;
    }
    return Icons.attach_file;
  }
}
