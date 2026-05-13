import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
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
class FileQuestion extends StatefulWidget {
  final QuestionModel question;
  final List<SurveyFile> currentFiles;
  final ValueChanged<List<SurveyFile>> onChanged;

  final OnUploadFile? onUploadFile;
  final OnDownloadFile? onDownloadFile;
  final OnClearFile? onClearFile;
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

  final Set<String> _downloading = {};
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

  // ─── Pick files using file_picker ────────────────────────────────────────

  Future<void> _openPicker() async {
    if (!widget.enabled || _uploading) return;

    // If consumer provided their own picker, use it
    if (widget.onPickFiles != null) {
      widget.onPickFiles!();
      return;
    }

    // Build allowed extensions from acceptedTypes MIME list
    // e.g. ["image/jpeg", "image/png"] → ["jpg", "jpeg", "png"]
    List<String>? allowedExtensions;
    final accepted = widget.question.acceptedTypes;
    if (accepted != null && accepted.isNotEmpty) {
      allowedExtensions = _mimeToExtensions(accepted);
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: widget.question.allowMultiple ?? false,
        type: (allowedExtensions != null && allowedExtensions.isNotEmpty)
            ? FileType.custom
            : FileType.any,
        allowedExtensions: (allowedExtensions != null && allowedExtensions.isNotEmpty)
            ? allowedExtensions
            : null,
        withData: false, // don't load bytes into memory — use path
      );

      if (result == null || result.files.isEmpty) return; // user cancelled

      // Convert picked files to SurveyFile
      final picked = result.files.map((pf) {
        return SurveyFile(
          name: pf.name,
          type: _extensionToMime(pf.extension ?? ''),
          size: pf.size,
          raw: pf, // PlatformFile
        );
      }).toList();

      await _handleUpload(picked);
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Could not open file picker: ${e.toString()}');
      }
    }
  }

  // ─── Upload ───────────────────────────────────────────────────────────────

  Future<void> _handleUpload(List<SurveyFile> picked) async {
    setState(() {
      _uploading = true;
      _errorMessage = null;
    });

    try {
      List<SurveyFile> result;

      if (widget.onUploadFile != null) {
        result = await widget.onUploadFile!(picked);
      } else {
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

  // ─── MIME helpers ─────────────────────────────────────────────────────────

  /// Converts MIME type list to file extensions for FilePicker
  List<String> _mimeToExtensions(List<String> mimes) {
    final map = <String, List<String>>{
      'image/jpeg': ['jpg', 'jpeg'],
      'image/png': ['png'],
      'image/gif': ['gif'],
      'image/webp': ['webp'],
      'image/bmp': ['bmp'],
      'application/pdf': ['pdf'],
      'application/msword': ['doc'],
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document': ['docx'],
      'application/vnd.ms-excel': ['xls'],
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': ['xlsx'],
      'application/vnd.ms-powerpoint': ['ppt'],
      'application/vnd.openxmlformats-officedocument.presentationml.presentation': ['pptx'],
      'text/plain': ['txt'],
      'text/csv': ['csv'],
      'video/mp4': ['mp4'],
      'video/quicktime': ['mov'],
      'audio/mpeg': ['mp3'],
      'audio/wav': ['wav'],
      'application/zip': ['zip'],
    };
    final exts = <String>{};
    for (final mime in mimes) {
      final found = map[mime];
      if (found != null) {
        exts.addAll(found);
      } else if (mime.startsWith('image/')) {
        // Generic image wildcard
        exts.addAll(['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp']);
      }
    }
    return exts.toList();
  }

  /// Maps extension back to MIME for display
  String _extensionToMime(String ext) {
    const map = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'webp': 'image/webp',
      'bmp': 'image/bmp',
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls': 'application/vnd.ms-excel',
      'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'ppt': 'application/vnd.ms-powerpoint',
      'pptx': 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'txt': 'text/plain',
      'csv': 'text/csv',
      'mp4': 'video/mp4',
      'mov': 'video/quicktime',
      'mp3': 'audio/mpeg',
      'wav': 'audio/wav',
      'zip': 'application/zip',
    };
    return map[ext.toLowerCase()] ?? 'application/octet-stream';
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
            theme: theme,
            onTap: _openPicker, // FIX: always calls our picker
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
                  child: Text(_errorMessage!, style: theme.errorTextStyle),
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
                canDownload: widget.onDownloadFile != null && file.content != null,
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
  final SurveyTheme theme;
  final VoidCallback onTap;

  const _UploadZone({
    required this.uploading,
    required this.accepted,
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
            color: uploading ? theme.primaryColor : theme.borderColor,
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
                      size: 36, color: theme.primaryColor),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to upload',
                    style: TextStyle(
                      color: theme.primaryColor,
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
          // Image preview
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(_iconFor(file.type), size: 18, color: theme.primaryColor),
                ),
                const SizedBox(width: 10),

                // Name + size
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.name,
                        style: theme.inputTextStyle.copyWith(fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (file.size != null)
                        Text(
                          _formatSize(file.size!),
                          style: theme.questionDescriptionStyle.copyWith(fontSize: 11),
                        ),
                    ],
                  ),
                ),

                // Download
                if (canDownload)
                  _ActionButton(
                    loading: isDownloading,
                    icon: Icons.download_outlined,
                    color: theme.primaryColor,
                    onTap: onDownload,
                  ),

                const SizedBox(width: 4),

                // Remove
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
    if (mime.contains('word') || mime.contains('document')) return Icons.description_outlined;
    if (mime.contains('sheet') || mime.contains('excel')) return Icons.table_chart_outlined;
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
                child: CircularProgressIndicator(strokeWidth: 2, color: color),
              )
            : Icon(icon, size: 20, color: color),
      ),
    );
  }
}
