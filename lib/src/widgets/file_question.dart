import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../theme/survey_theme.dart';

/// Represents a single uploaded file — same structure as SurveyJS web.
/// [content] is base64-encoded file data (optional, set after upload).
class SurveyFile {
  final String name;
  final String type; // MIME type e.g. "image/jpeg"
  final int? size; // bytes
  final String? content; // base64 string or URL after upload
  final dynamic raw; // original platform file object (File, XFile, etc.)

  const SurveyFile({
    required this.name,
    required this.type,
    this.size,
    this.content,
    this.raw,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        if (size != null) 'size': size,
        if (content != null) 'content': content,
      };

  factory SurveyFile.fromJson(Map<String, dynamic> json) => SurveyFile(
        name: json['name'] as String? ?? '',
        type: json['type'] as String? ?? '',
        size: json['size'] as int?,
        content: json['content'] as String?,
      );

  @override
  String toString() => 'SurveyFile(name: $name, type: $type)';
}

/// Called when the user selects files to upload.
/// Return the same list with [SurveyFile.content] populated after upload.
/// Throw to cancel / show error.
typedef OnUploadFile = Future<List<SurveyFile>> Function(
  List<SurveyFile> files,
);

/// Called when the user taps download on a file.
/// [file] contains the name, type, and content/URL.
typedef OnDownloadFile = Future<void> Function(SurveyFile file);

/// Called when the user removes a file.
/// Return false to cancel the removal (e.g. if server delete fails).
typedef OnClearFile = Future<bool> Function(SurveyFile file);

// ─────────────────────────────────────────────────────────────────────────────

/// Renders a SurveyJS `file` question with full upload/download/clear support.
///
/// Wire the three callbacks to your backend or file picker:
///
/// ```dart
/// FileQuestion(
///   question: q,
///   onChanged: (files) => controller.setAnswer(q.name, files),
///   onUploadFile: (files) async {
///     // e.g. upload to S3 and return files with content = URL
///     final uploaded = await myApi.upload(files);
///     return uploaded;
///   },
///   onDownloadFile: (file) async {
///     await launchUrl(Uri.parse(file.content!));
///   },
///   onClearFile: (file) async {
///     await myApi.delete(file.name);
///     return true; // confirm removal
///   },
/// )
/// ```
class FileQuestion extends StatefulWidget {
  final QuestionModel question;
  final List<SurveyFile> currentFiles;
  final ValueChanged<List<SurveyFile>> onChanged;

  /// Called when user picks files. Upload them here and return with content set.
  final OnUploadFile? onUploadFile;

  /// Called when user taps the download icon on a file.
  final OnDownloadFile? onDownloadFile;

  /// Called when user taps the remove icon. Return true to confirm removal.
  final OnClearFile? onClearFile;

  /// Called when user taps the upload area but no [onUploadFile] is set.
  /// Use this to open your own file picker and call [onChanged] manually.
  final VoidCallback? onPickFiles;

  final bool enabled;

  const FileQuestion({
    super.key,
    required this.question,
    required this.onChanged,
    this.currentFiles = const [],
    this.onUploadFile,
    this.onDownloadFile,
    this.onClearFile,
    this.onPickFiles,
    this.enabled = true,
  });

  @override
  State<FileQuestion> createState() => _FileQuestionState();
}

class _FileQuestionState extends State<FileQuestion> {
  late List<SurveyFile> _files;
  bool _uploading = false;
  String? _errorMessage;

  // Track which files are downloading
  final Set<String> _downloading = {};
  // Track which files are being cleared
  final Set<String> _clearing = {};

  @override
  void initState() {
    super.initState();
    _files = List.from(widget.currentFiles);
  }

  @override
  void didUpdateWidget(FileQuestion old) {
    super.didUpdateWidget(old);
    if (old.currentFiles != widget.currentFiles) {
      _files = List.from(widget.currentFiles);
    }
  }

  // ─── Upload ───────────────────────────────────────────────────────────────

  Future<void> _handleUpload(List<SurveyFile> picked) async {
    if (!widget.enabled) return;
    setState(() {
      _uploading = true;
      _errorMessage = null;
    });

    try {
      List<SurveyFile> result;

      if (widget.onUploadFile != null) {
        // Let the consumer upload and return enriched files
        result = await widget.onUploadFile!(picked);
      } else {
        // No upload handler — just store the raw files
        result = picked;
      }

      if (widget.question.allowMultiple == true) {
        _files = [..._files, ...result];
      } else {
        _files = [result.first];
      }

      widget.onChanged(_files);
    } catch (e) {
      setState(() => _errorMessage = 'Upload failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  // ─── Download ─────────────────────────────────────────────────────────────

  Future<void> _handleDownload(SurveyFile file) async {
    if (widget.onDownloadFile == null) return;
    setState(() => _downloading.add(file.name));
    try {
      await widget.onDownloadFile!(file);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _downloading.remove(file.name));
    }
  }

  // ─── Clear ────────────────────────────────────────────────────────────────

  Future<void> _handleClear(SurveyFile file) async {
    setState(() => _clearing.add(file.name));
    try {
      bool confirmed = true;
      if (widget.onClearFile != null) {
        confirmed = await widget.onClearFile!(file);
      }
      if (confirmed) {
        _files = _files.where((f) => f.name != file.name).toList();
        widget.onChanged(_files);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Remove failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _clearing.remove(file.name));
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = SurveyTheme.of(context);
    final multi = widget.question.allowMultiple ?? false;
    final accepted = widget.question.acceptedTypes?.join(', ');
    final canAddMore = multi || _files.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Upload zone
        if (widget.enabled && canAddMore)
          _UploadZone(
            uploading: _uploading,
            accepted: accepted,
            hasHandler:
                widget.onUploadFile != null || widget.onPickFiles != null,
            theme: theme,
            onTap: () {
              if (widget.onPickFiles != null) {
                widget.onPickFiles!();
              }
              // If consumer uses onUploadFile with their own picker,
              // they call _handleUpload externally via a GlobalKey or
              // pass files through onPickFiles callback.
            },
          ),

        // Error message
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Icon(Icons.error_outline, size: 14, color: theme.errorColor),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(_errorMessage!,
                      style: theme.errorTextStyle),
                ),
              ],
            ),
          ),

        // File list
        if (_files.isNotEmpty) ...[
          const SizedBox(height: 10),
          ..._files.map((file) => _FileItem(
                file: file,
                theme: theme,
                enabled: widget.enabled,
                isDownloading: _downloading.contains(file.name),
                isClearing: _clearing.contains(file.name),
                canDownload: widget.onDownloadFile != null &&
                    file.content != null,
                onDownload: () => _handleDownload(file),
                onClear: () => _handleClear(file),
              )),
        ],
      ],
    );
  }
}

// ─── Upload Zone ─────────────────────────────────────────────────────────────

class _UploadZone extends StatelessWidget {
  final bool uploading;
  final String? accepted;
  final bool hasHandler;
  final SurveyTheme theme;
  final VoidCallback onTap;

  const _UploadZone({
    required this.uploading,
    required this.accepted,
    required this.hasHandler,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: uploading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: theme.backgroundColor,
          borderRadius: theme.inputBorderRadius,
          border: Border.all(
            color: uploading
                ? theme.primaryColor
                : theme.borderColor,
          ),
        ),
        child: uploading
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Uploading...',
                      style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w500)),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_upload_outlined,
                      size: 36,
                      color: hasHandler
                          ? theme.primaryColor
                          : theme.hintColor),
                  const SizedBox(height: 8),
                  Text(
                    hasHandler ? 'Tap to upload' : 'No upload handler set',
                    style: TextStyle(
                      color: hasHandler
                          ? theme.primaryColor
                          : theme.hintColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
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
    );
  }
}

// ─── File Item ────────────────────────────────────────────────────────────────

class _FileItem extends StatelessWidget {
  final SurveyFile file;
  final SurveyTheme theme;
  final bool enabled;
  final bool isDownloading;
  final bool isClearing;
  final bool canDownload;
  final VoidCallback onDownload;
  final VoidCallback onClear;

  const _FileItem({
    required this.file,
    required this.theme,
    required this.enabled,
    required this.isDownloading,
    required this.isClearing,
    required this.canDownload,
    required this.onDownload,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isImage = file.type.startsWith('image/');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.questionBackgroundColor,
        borderRadius: theme.inputBorderRadius,
        border: Border.all(color: theme.borderColor),
      ),
      child: Column(
        children: [
          // Image preview (if image file)
          if (isImage && file.content != null)
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: theme.inputBorderRadius.topLeft,
                topRight: theme.inputBorderRadius.topRight,
              ),
              child: Image.network(
                file.content!,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),

          // File row
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // File icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    _iconFor(file.type),
                    size: 18,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(width: 10),

                // Name + size
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.name,
                        style: theme.inputTextStyle
                            .copyWith(fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (file.size != null)
                        Text(
                          _formatSize(file.size!),
                          style: theme.questionDescriptionStyle
                              .copyWith(fontSize: 11),
                        ),
                    ],
                  ),
                ),

                // Download button
                if (canDownload)
                  _ActionButton(
                    loading: isDownloading,
                    icon: Icons.download_outlined,
                    color: theme.primaryColor,
                    onTap: onDownload,
                  ),

                const SizedBox(width: 4),

                // Clear button
                if (enabled)
                  _ActionButton(
                    loading: isClearing,
                    icon: Icons.close,
                    color: theme.errorColor,
                    onTap: onClear,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String mime) {
    if (mime.startsWith('image/')) return Icons.image_outlined;
    if (mime.contains('pdf')) return Icons.picture_as_pdf_outlined;
    if (mime.contains('word') || mime.contains('document')) {
      return Icons.description_outlined;
    }
    if (mime.contains('sheet') || mime.contains('excel')) {
      return Icons.table_chart_outlined;
    }
    if (mime.startsWith('video/')) return Icons.videocam_outlined;
    if (mime.startsWith('audio/')) return Icons.audiotrack_outlined;
    return Icons.attach_file;
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

// ─── Action Button ────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final bool loading;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.loading,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: SizedBox(
        width: 32,
        height: 32,
        child: loading
            ? Padding(
                padding: const EdgeInsets.all(6),
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: color),
              )
            : Icon(icon, size: 20, color: color),
      ),
    );
  }
}
