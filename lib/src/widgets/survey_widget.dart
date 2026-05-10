import 'package:flutter/material.dart';
import '../models/survey_model.dart';
import '../controller/survey_controller.dart';
import '../theme/survey_theme.dart';
import 'question_widget.dart';
import 'file_question.dart';

/// The main widget. Drop it anywhere in your widget tree.
///
/// ```dart
/// SurveyWidget(
///   survey: surveyFromJson(myJson),
///   onSubmit: (answers) => print(answers),
/// )
/// ```
class SurveyWidget extends StatefulWidget {
  final SurveyModel survey;
  final SurveyTheme? theme;

  // ─── Survey callbacks ─────────────────────────────────────────────────────
  final ValueChanged<Map<String, dynamic>>? onSubmit;
  final ValueChanged<Map<String, dynamic>>? onChange;
  final VoidCallback? onComplete;

  // ─── File callbacks (mirrors SurveyJS web API) ────────────────────────────

  /// Called when user picks files. Upload them here and return with content set.
  /// Same as SurveyJS `onUploadFiles` event.
  final OnUploadFile? onUploadFile;

  /// Called when user taps the download icon on a file.
  /// Same as SurveyJS `onDownloadFile` event.
  final OnDownloadFile? onDownloadFile;

  /// Called when user removes a file. Return true to confirm removal.
  /// Same as SurveyJS `onClearFiles` event.
  final OnClearFile? onClearFile;

  const SurveyWidget({
    super.key,
    required this.survey,
    this.theme,
    this.onSubmit,
    this.onChange,
    this.onComplete,
    this.onUploadFile,
    this.onDownloadFile,
    this.onClearFile,
  });

  @override
  State<SurveyWidget> createState() => _SurveyWidgetState();
}

class _SurveyWidgetState extends State<SurveyWidget> {
  late final SurveyController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SurveyController(survey: widget.survey);
    _controller.addListener(_onAnswerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onAnswerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onAnswerChanged() {
    widget.onChange?.call(_controller.answers);
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme ?? SurveyTheme.of(context);

    return SurveyThemeProvider(
      theme: theme,
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isCompleted) {
            return _CompletedView(
              html: widget.survey.completedHtml,
              theme: theme,
              onRestart: _controller.reset,
            );
          }

          return _SurveyBody(
            controller: _controller,
            theme: theme,
            onUploadFile: widget.onUploadFile,
            onDownloadFile: widget.onDownloadFile,
            onClearFile: widget.onClearFile,
            onSubmit: () {
              widget.onSubmit?.call(_controller.answers);
              widget.onComplete?.call();
            },
          );
        },
      ),
    );
  }
}

// ─── Survey Body ──────────────────────────────────────────────────────────────

class _SurveyBody extends StatelessWidget {
  final SurveyController controller;
  final SurveyTheme theme;
  final VoidCallback onSubmit;
  final OnUploadFile? onUploadFile;
  final OnDownloadFile? onDownloadFile;
  final OnClearFile? onClearFile;

  const _SurveyBody({
    required this.controller,
    required this.theme,
    required this.onSubmit,
    this.onUploadFile,
    this.onDownloadFile,
    this.onClearFile,
  });

  @override
  Widget build(BuildContext context) {
    final survey = controller.survey;
    final page = controller.currentPage;

    return Container(
      color: theme.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Survey title + description (first page only)
          if (controller.isFirstPage && survey.title != null)
            _SurveyHeader(survey: survey, theme: theme),

          // Progress bar
          if (survey.showProgressBar && survey.isMultiPage)
            _ProgressBar(
              progress: controller.progress,
              theme: theme,
              currentPage: controller.currentPageIndex + 1,
              totalPages: survey.pageCount,
            ),

          // Questions
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Page title
                  if (page.title != null && page.title!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(page.title!, style: theme.surveyTitleStyle.copyWith(fontSize: 18)),
                    ),

                  // Questions list
                  ...page.elements.asMap().entries.map((entry) {
                    final index = entry.key;
                    final question = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(bottom: theme.questionSpacing),
                      child: QuestionWidget(
                        question: question,
                        controller: controller,
                        questionNumber: survey.showQuestionNumbers ? index + 1 : null,
                        onUploadFile: onUploadFile,
                        onDownloadFile: onDownloadFile,
                        onClearFile: onClearFile,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Navigation buttons
          _NavigationBar(
            controller: controller,
            theme: theme,
            onSubmit: onSubmit,
          ),
        ],
      ),
    );
  }
}

// ─── Survey Header ────────────────────────────────────────────────────────────

class _SurveyHeader extends StatelessWidget {
  final SurveyModel survey;
  final SurveyTheme theme;

  const _SurveyHeader({required this.survey, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.questionBackgroundColor,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (survey.title != null)
            Text(survey.title!, style: theme.surveyTitleStyle),
          if (survey.description != null) ...[
            const SizedBox(height: 8),
            Text(survey.description!, style: theme.surveyDescriptionStyle),
          ],
        ],
      ),
    );
  }
}

// ─── Progress Bar ─────────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  final double progress;
  final SurveyTheme theme;
  final int currentPage;
  final int totalPages;

  const _ProgressBar({
    required this.progress,
    required this.theme,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Page $currentPage of $totalPages',
                style: TextStyle(fontSize: 12, color: theme.hintColor),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(fontSize: 12, color: theme.primaryColor, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: theme.borderColor,
          valueColor: AlwaysStoppedAnimation(theme.progressBarColor),
          minHeight: 4,
        ),
      ],
    );
  }
}

// ─── Navigation Bar ───────────────────────────────────────────────────────────

class _NavigationBar extends StatelessWidget {
  final SurveyController controller;
  final SurveyTheme theme;
  final VoidCallback onSubmit;

  const _NavigationBar({
    required this.controller,
    required this.theme,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    if (!controller.survey.showNavigationButtons) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: theme.questionBackgroundColor,
        border: Border(top: BorderSide(color: theme.borderColor)),
      ),
      child: Row(
        children: [
          // Prev button
          if (!controller.isFirstPage && controller.survey.showPrevButton)
            Expanded(
              child: OutlinedButton(
                onPressed: controller.prevPage,
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.textColor,
                  side: BorderSide(color: theme.borderColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: theme.buttonBorderRadius,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Previous'),
              ),
            ),

          if (!controller.isFirstPage && controller.survey.showPrevButton)
            const SizedBox(width: 12),

          // Next / Submit button
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                if (controller.isLastPage) {
                  controller.complete();
                  onSubmit();
                } else {
                  controller.nextPage();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: controller.isLastPage
                    ? theme.submitButtonColor
                    : theme.nextButtonColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: theme.buttonBorderRadius,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: Text(
                controller.isLastPage ? 'Submit' : 'Next',
                style: theme.buttonTextStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Completed View ───────────────────────────────────────────────────────────

class _CompletedView extends StatelessWidget {
  final String? html;
  final SurveyTheme theme;
  final VoidCallback onRestart;

  const _CompletedView({this.html, required this.theme, required this.onRestart});

  @override
  Widget build(BuildContext context) {
    final message = html != null
        ? html!.replaceAll(RegExp(r'<[^>]+>'), '')
        : 'Thank you for completing the survey!';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 72, color: theme.primaryColor),
            const SizedBox(height: 20),
            Text(
              message,
              style: theme.surveyTitleStyle.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
