import 'package:flutter/material.dart';
import '../models/survey_model.dart';
import '../controller/survey_controller.dart';
import 'package:flutter_html/flutter_html.dart';
import '../theme/survey_theme.dart';
import '../utils/survey_html.dart';
import 'question_widget.dart';
import 'file_question.dart';

class SurveyWidget extends StatefulWidget {
  final SurveyModel survey;
  final SurveyTheme? theme;

  /// Padding around the scrollable survey content (questions and page title).
  /// Defaults to `EdgeInsets.all(16)`.
  final EdgeInsets contentPadding;

  final ValueChanged<Map<String, dynamic>>? onSubmit;
  final ValueChanged<Map<String, dynamic>>? onChange;
  final VoidCallback? onComplete;
  final OnUploadFile? onUploadFile;
  final OnDownloadFile? onDownloadFile;
  final OnClearFile? onClearFile;

  const SurveyWidget({
    super.key,
    required this.survey,
    this.theme,
    this.contentPadding = const EdgeInsets.all(16),
    this.onSubmit,
    this.onChange,
    this.onComplete,
    this.onUploadFile,
    this.onDownloadFile,
    this.onClearFile,
  });

  @override
  State<SurveyWidget> createState() => SurveyWidgetState();
}

class SurveyWidgetState extends State<SurveyWidget> {
  late final SurveyController _controller;

  /// Validates the current page's required fields, highlighting any invalid
  /// questions (red title/border). Returns true when every field passes.
  ///
  /// Exposed so a host can gate an external submit button (e.g. when the
  /// survey's own navigation buttons are hidden) via a [GlobalKey].
  bool validate() => _controller.validateCurrentPage();

  // ─── Page navigation (for hosts that render their own footer) ─────────────
  // When the survey's built-in navigation buttons are hidden, drive these from
  // a custom "Next / Previous / Submit" footer via a [GlobalKey].

  bool get isFirstPage => _controller.isFirstPage;
  bool get isLastPage => _controller.isLastPage;
  int get currentPageIndex => _controller.currentPageIndex;
  int get pageCount => widget.survey.pageCount;
  bool get isCompleted => _controller.isCompleted;

  /// Current answers map.
  Map<String, dynamic> get answers => _controller.answers;

  /// Notifies on every page change / answer update — listen to rebuild a
  /// custom footer (e.g. to switch the button label from "Next" to "Submit").
  Listenable get listenable => _controller;

  /// Validates the current page, then advances to the next visible page.
  /// On the last page this validates and completes the survey instead.
  /// Returns false if validation failed (the page did not change).
  bool nextPage() => _controller.nextPage();

  /// Goes back to the previous visible page.
  void prevPage() => _controller.prevPage();

  /// Jumps directly to a page by index.
  void goToPage(int index) => _controller.goToPage(index);

  /// Validates the current page and marks the survey complete.
  void complete() => _controller.complete();

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
    // widget.theme → explicit (highest priority)
    // otherwise → SurveyTheme.of() handles both: inherited provider OR auto brightness
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
            contentPadding: widget.contentPadding,
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
  final EdgeInsets contentPadding;
  final VoidCallback onSubmit;
  final OnUploadFile? onUploadFile;
  final OnDownloadFile? onDownloadFile;
  final OnClearFile? onClearFile;

  const _SurveyBody({
    required this.controller,
    required this.theme,
    required this.contentPadding,
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
          if (controller.isFirstPage && survey.title != null)
            _SurveyHeader(survey: survey, theme: theme),
          if (survey.showProgressBar && survey.isMultiPage)
            survey.progressBarType == 'buttons'
                ? _ProgressButtons(controller: controller, theme: theme)
                : _ProgressBar(
                    progress: controller.progress,
                    theme: theme,
                    currentPage: controller.currentPageIndex + 1,
                    totalPages: survey.pageCount,
                  ),
          Expanded(
            child: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: contentPadding,
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (page.title != null && page.title!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(page.title!,
                              style: theme.surveyTitleStyle.copyWith(fontSize: 18)),
                        ),
                      ...page.elements.asMap().entries.map((entry) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: theme.questionSpacing),
                          child: QuestionWidget(
                            question: entry.value,
                            controller: controller,
                            questionNumber: survey.showQuestionNumbers ? entry.key + 1 : null,
                            onUploadFile: onUploadFile,
                            onDownloadFile: onDownloadFile,
                            onClearFile: onClearFile,
                          ),
                        );
                      }),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          _NavigationBar(controller: controller, theme: theme, onSubmit: onSubmit),
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
              Text('Page $currentPage of $totalPages',
                  style: TextStyle(fontSize: 12, color: theme.hintColor)),
              Text('${(progress * 100).round()}%',
                  style: TextStyle(fontSize: 12, color: theme.primaryColor, fontWeight: FontWeight.w600)),
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

// ─── Progress Buttons ─────────────────────────────────────────────────────────
// SurveyJS `progressBarType: "buttons"` — a horizontal, scrollable strip of
// page steps showing each page title, its state (passed / current / upcoming),
// and tappable for direct navigation.

class _ProgressButtons extends StatelessWidget {
  final SurveyController controller;
  final SurveyTheme theme;

  const _ProgressButtons({required this.controller, required this.theme});

  static const double _circle = 28;
  static const double _stepWidth = 92;
  static const double _connector = 20;

  @override
  Widget build(BuildContext context) {
    final survey = controller.survey;

    // Visible pages paired with their real index in survey.pages.
    final steps = <MapEntry<int, PageModel>>[];
    for (var i = 0; i < survey.pages.length; i++) {
      if (controller.isPageVisible(survey.pages[i])) {
        steps.add(MapEntry(i, survey.pages[i]));
      }
    }
    final currentIndex = controller.currentPageIndex;

    return Container(
      color: theme.questionBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var pos = 0; pos < steps.length; pos++) ...[
              if (pos > 0)
                Container(
                  width: _connector,
                  height: 2,
                  margin: const EdgeInsets.only(top: _circle / 2 - 1),
                  color: steps[pos].key <= currentIndex
                      ? theme.progressBarColor
                      : theme.borderColor,
                ),
              _ProgressStep(
                number: pos + 1,
                title: steps[pos].value.title,
                isPassed: steps[pos].key < currentIndex,
                isCurrent: steps[pos].key == currentIndex,
                theme: theme,
                onTap: () => controller.goToPage(steps[pos].key),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProgressStep extends StatelessWidget {
  final int number;
  final String? title;
  final bool isPassed;
  final bool isCurrent;
  final SurveyTheme theme;
  final VoidCallback onTap;

  const _ProgressStep({
    required this.number,
    required this.title,
    required this.isPassed,
    required this.isCurrent,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = isPassed || isCurrent;
    final circleColor =
        active ? theme.progressBarColor : theme.questionBackgroundColor;
    final borderColor = active ? theme.progressBarColor : theme.borderColor;
    final fgColor = active ? Colors.white : theme.hintColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: _ProgressButtons._stepWidth,
        child: Column(
          children: [
            Container(
              width: _ProgressButtons._circle,
              height: _ProgressButtons._circle,
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor,
                  width: isCurrent ? 2.5 : 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: isPassed
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text(
                      '$number',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: fgColor,
                      ),
                    ),
            ),
            const SizedBox(height: 6),
            Text(
              title ?? 'Page $number',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                height: 1.3,
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                color: isCurrent
                    ? theme.progressBarColor
                    : (isPassed ? theme.textColor : theme.hintColor),
              ),
            ),
          ],
        ),
      ),
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
          if (!controller.isFirstPage && controller.survey.showPrevButton)
            Expanded(
              child: OutlinedButton(
                onPressed: controller.prevPage,
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.textColor,
                  side: BorderSide(color: theme.borderColor),
                  shape: RoundedRectangleBorder(borderRadius: theme.buttonBorderRadius),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Previous'),
              ),
            ),
          if (!controller.isFirstPage && controller.survey.showPrevButton)
            const SizedBox(width: 12),
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
                shape: RoundedRectangleBorder(borderRadius: theme.buttonBorderRadius),
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
    // Custom completedHtml → render it richly.
    if (html != null && html!.trim().isNotEmpty) {
      return Container(
        color: theme.backgroundColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Html(
            data: normalizeSurveyHtml(html!),
            style: {
              'body': Style(
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
                color: theme.textColor,
              ),
            },
          ),
        ),
      );
    }

    // Default completion message.
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 72, color: theme.primaryColor),
            const SizedBox(height: 20),
            Text('Thank you for completing the survey!',
                style: theme.surveyTitleStyle.copyWith(fontSize: 20),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
