import 'question_model.dart';

/// Represents a single page in a SurveyJS survey
class PageModel {
  final String name;
  final String? title;
  final String? description;
  final List<QuestionModel> elements;
  final String? visibleIf;
  final bool visible;

  const PageModel({
    required this.name,
    required this.elements,
    this.title,
    this.description,
    this.visibleIf,
    this.visible = true,
  });

  factory PageModel.fromJson(Map<String, dynamic> json) {
    final rawElements = json['elements'] ?? json['questions'] ?? [];
    final elements = (rawElements as List)
        .map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return PageModel(
      name: json['name'] as String? ?? '',
      title: json['title'] as String?,
      description: json['description'] as String?,
      elements: elements,
      visibleIf: json['visibleIf'] as String?,
      visible: json['visible'] as bool? ?? true,
    );
  }

  @override
  String toString() => 'PageModel(name: $name, elements: ${elements.length})';
}

// ─────────────────────────────────────────────────────────────────────────────

/// Root model representing a complete SurveyJS survey
class SurveyModel {
  final String? title;
  final String? description;
  final String? completedHtml;
  final String? locale;
  final String? logo;
  final List<PageModel> pages;

  // Navigation
  final bool showNavigationButtons;
  final bool showPrevButton;
  final bool showProgressBar;
  final String? progressBarType;

  // Question display
  final String? questionTitleLocation;  // "top" | "bottom" | "left"
  final bool showQuestionNumbers;
  final String? requiredText;

  // Behaviour
  final String? checkErrorsMode; // "onNextPage" | "onValueChanged" | "onComplete"
  final bool goNextPageAutomatic;

  const SurveyModel({
    required this.pages,
    this.title,
    this.description,
    this.completedHtml,
    this.locale,
    this.logo,
    this.showNavigationButtons = true,
    this.showPrevButton = true,
    this.showProgressBar = false,
    this.progressBarType,
    this.questionTitleLocation,
    this.showQuestionNumbers = true,
    this.requiredText,
    this.checkErrorsMode,
    this.goNextPageAutomatic = false,
  });

  /// All questions flattened across all pages
  List<QuestionModel> get allQuestions =>
      pages.expand((p) => p.elements).toList();

  /// Total number of pages
  int get pageCount => pages.length;

  /// True if survey has multiple pages
  bool get isMultiPage => pages.length > 1;

  factory SurveyModel.fromJson(Map<String, dynamic> json) {
    List<PageModel> pages;

    // SurveyJS supports two formats:
    // 1. { pages: [...] }  — multi-page
    // 2. { elements: [...] } — single page shorthand
    if (json.containsKey('pages')) {
      pages = (json['pages'] as List)
          .map((p) => PageModel.fromJson(p as Map<String, dynamic>))
          .toList();
    } else {
      // Wrap elements in a single page
      final elements = json['elements'] ?? json['questions'] ?? [];
      pages = [
        PageModel.fromJson({'name': 'page1', 'elements': elements}),
      ];
    }

    return SurveyModel(
      pages: pages,
      title: json['title'] as String?,
      description: json['description'] as String?,
      completedHtml: json['completedHtml'] as String?,
      locale: json['locale'] as String?,
      logo: json['logo'] as String?,
      showNavigationButtons: json['showNavigationButtons'] as bool? ?? true,
      showPrevButton: json['showPrevButton'] as bool? ?? true,
      showProgressBar: json['showProgressBar'] as bool? ?? false,
      progressBarType: json['progressBarType'] as String?,
      questionTitleLocation: json['questionTitleLocation'] as String?,
      showQuestionNumbers: !(json['showQuestionNumbers'] == false ||
          json['showQuestionNumbers'] == 'off'),
      requiredText: json['requiredText'] as String?,
      checkErrorsMode: json['checkErrorsMode'] as String?,
      goNextPageAutomatic: json['goNextPageAutomatic'] as bool? ?? false,
    );
  }

  @override
  String toString() =>
      'SurveyModel(title: $title, pages: ${pages.length}, questions: ${allQuestions.length})';
}
