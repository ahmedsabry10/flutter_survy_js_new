import 'question_model.dart';

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
    final elements = rawElements is List
        ? rawElements
            .whereType<Map<String, dynamic>>()
            .map((e) => QuestionModel.fromJson(e))
            .toList()
        : <QuestionModel>[];

    return PageModel(
      name: json['name']?.toString() ?? '',
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      elements: elements,
      visibleIf: json['visibleIf']?.toString(),
      visible: json['visible'] as bool? ?? true,
    );
  }
}

class SurveyModel {
  final String? title;
  final String? description;
  final String? completedHtml;
  final List<Map<String, dynamic>> completedHtmlOnCondition;
  final String? locale;
  final String? logo;
  final String? logoPosition;
  final List<PageModel> pages;

  // Calculated values & triggers (stored for future use)
  final List<Map<String, dynamic>> calculatedValues;
  final List<Map<String, dynamic>> triggers;

  // Navigation
  final bool showNavigationButtons;
  final bool showPrevButton;
  final bool showProgressBar;
  final String? progressBarType;
  final String? completeText;
  final String? startSurveyText;
  final String? previewText;
  final String? editText;

  // Display
  final String? questionTitleLocation;
  final bool showQuestionNumbers;
  final String? requiredText;
  final String? questionErrorLocation;
  final bool showTOC;

  // Behaviour
  final String? checkErrorsMode;
  final String? textUpdateMode;
  final bool goNextPageAutomatic;
  final String? showPreviewBeforeComplete;

  const SurveyModel({
    required this.pages,
    this.title,
    this.description,
    this.completedHtml,
    this.completedHtmlOnCondition = const [],
    this.locale,
    this.logo,
    this.logoPosition,
    this.calculatedValues = const [],
    this.triggers = const [],
    this.showNavigationButtons = true,
    this.showPrevButton = true,
    this.showProgressBar = false,
    this.progressBarType,
    this.completeText,
    this.startSurveyText,
    this.previewText,
    this.editText,
    this.questionTitleLocation,
    this.showQuestionNumbers = true,
    this.requiredText,
    this.questionErrorLocation,
    this.showTOC = false,
    this.checkErrorsMode,
    this.textUpdateMode,
    this.goNextPageAutomatic = false,
    this.showPreviewBeforeComplete,
  });

  List<QuestionModel> get allQuestions =>
      pages.expand((p) => p.elements).toList();

  int get pageCount => pages.length;
  bool get isMultiPage => pages.length > 1;

  factory SurveyModel.fromJson(Map<String, dynamic> json) {
    List<PageModel> pages;
    if (json.containsKey('pages') && json['pages'] is List) {
      pages = (json['pages'] as List)
          .whereType<Map<String, dynamic>>()
          .map((p) => PageModel.fromJson(p))
          .toList();
    } else {
      final elements = json['elements'] ?? json['questions'] ?? [];
      pages = [PageModel.fromJson({'name': 'page1', 'elements': elements})];
    }

    // showProgressBar can be bool or string "top"/"bottom"/"both"
    bool parseProgressBar(dynamic val) {
      if (val == null) return false;
      if (val is bool) return val;
      if (val is String) return val == 'top' || val == 'bottom' || val == 'both' || val == 'true';
      return false;
    }

    // showQuestionNumbers can be bool or string "on"/"off"
    bool parseShowNumbers(dynamic val) {
      if (val == null) return true;
      if (val is bool) return val;
      if (val is String) return val != 'off' && val != 'false';
      return true;
    }

    List<Map<String, dynamic>> parseListOfMaps(dynamic val) {
      if (val == null || val is! List) return [];
      return val.whereType<Map<String, dynamic>>().toList();
    }

    return SurveyModel(
      pages: pages,
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      completedHtml: json['completedHtml']?.toString(),
      completedHtmlOnCondition: parseListOfMaps(json['completedHtmlOnCondition']),
      locale: json['locale']?.toString(),
      logo: json['logo']?.toString(),
      logoPosition: json['logoPosition']?.toString(),
      calculatedValues: parseListOfMaps(json['calculatedValues']),
      triggers: parseListOfMaps(json['triggers']),
      showNavigationButtons: json['showNavigationButtons'] as bool? ?? true,
      showPrevButton: json['showPrevButton'] as bool? ?? true,
      showProgressBar: parseProgressBar(json['showProgressBar']),
      progressBarType: json['progressBarType']?.toString(),
      completeText: json['completeText']?.toString(),
      startSurveyText: json['startSurveyText']?.toString(),
      previewText: json['previewText']?.toString(),
      editText: json['editText']?.toString(),
      questionTitleLocation: json['questionTitleLocation']?.toString(),
      showQuestionNumbers: parseShowNumbers(json['showQuestionNumbers']),
      requiredText: json['requiredText']?.toString(),
      questionErrorLocation: json['questionErrorLocation']?.toString(),
      showTOC: json['showTOC'] as bool? ?? false,
      checkErrorsMode: json['checkErrorsMode']?.toString(),
      textUpdateMode: json['textUpdateMode']?.toString(),
      goNextPageAutomatic: json['goNextPageAutomatic'] as bool? ?? false,
      showPreviewBeforeComplete: json['showPreviewBeforeComplete']?.toString(),
    );
  }

  @override
  String toString() =>
      'SurveyModel(title: $title, pages: ${pages.length}, questions: ${allQuestions.length})';
}
