import 'package:flutter/foundation.dart';
import '../models/survey_model.dart';
import '../models/question_model.dart';
import '../validators/survey_validator.dart';

/// Manages the entire state of a running survey:
/// - current answers
/// - current page
/// - validation errors
/// - navigation
class SurveyController extends ChangeNotifier {
  final SurveyModel survey;

  // ─── State ────────────────────────────────────────────────────────────────
  int _currentPageIndex = 0;
  final Map<String, dynamic> _answers = {};
  final Map<String, String?> _errors = {};
  bool _isCompleted = false;

  SurveyController({required this.survey}) {
    _applyDefaultValues();
  }

  // ─── Getters ──────────────────────────────────────────────────────────────

  int get currentPageIndex => _currentPageIndex;

  PageModel get currentPage => survey.pages[_currentPageIndex];

  bool get isFirstPage => _currentPageIndex == 0;

  bool get isLastPage => _currentPageIndex == survey.pages.length - 1;

  bool get isCompleted => _isCompleted;

  Map<String, dynamic> get answers => Map.unmodifiable(_answers);

  Map<String, String?> get errors => Map.unmodifiable(_errors);

  double get progress {
    if (survey.pageCount <= 1) return 0;
    return _currentPageIndex / (survey.pageCount - 1);
  }

  // ─── Answer Management ────────────────────────────────────────────────────

  dynamic getAnswer(String questionName) => _answers[questionName];

  void setAnswer(String questionName, dynamic value) {
    _answers[questionName] = value;
    // Clear error when user answers
    if (_errors.containsKey(questionName)) {
      _errors.remove(questionName);
    }
    notifyListeners();
  }

  void clearAnswer(String questionName) {
    _answers.remove(questionName);
    _errors.remove(questionName);
    notifyListeners();
  }

  // ─── Validation ───────────────────────────────────────────────────────────

  bool validateCurrentPage() {
    bool isValid = true;
    for (final question in currentPage.elements) {
      final error = _validateQuestion(question);
      if (error != null) {
        _errors[question.name] = error;
        isValid = false;
      } else {
        _errors.remove(question.name);
      }
    }
    notifyListeners();
    return isValid;
  }

  String? _validateQuestion(QuestionModel question) {
    final value = _answers[question.name];
    final isEmpty = _isValueEmpty(value);

    // Required check
    if (question.isRequired && isEmpty) {
      return 'This field is required';
    }

    // Skip further validation if empty (not required)
    if (isEmpty) return null;

    // Run all validators
    for (final validator in question.validators) {
      final error = validator.validate(value);
      if (error != null) return error;
    }

    return null;
  }

  bool _isValueEmpty(dynamic value) {
    if (value == null) return true;
    if (value is String) return value.trim().isEmpty;
    if (value is List) return value.isEmpty;
    return false;
  }

  String? getError(String questionName) => _errors[questionName];

  // ─── Navigation ───────────────────────────────────────────────────────────

  /// Go to next page. Returns false if validation fails.
  bool nextPage() {
    if (!validateCurrentPage()) return false;
    if (isLastPage) {
      complete();
      return true;
    }
    _currentPageIndex++;
    notifyListeners();
    return true;
  }

  /// Go to previous page.
  void prevPage() {
    if (!isFirstPage) {
      _currentPageIndex--;
      _errors.clear();
      notifyListeners();
    }
  }

  /// Jump to a specific page index.
  void goToPage(int index) {
    if (index >= 0 && index < survey.pageCount) {
      _currentPageIndex = index;
      notifyListeners();
    }
  }

  /// Complete the survey (called on last page submit).
  void complete() {
    if (!validateCurrentPage()) return;
    _isCompleted = true;
    notifyListeners();
  }

  /// Reset survey to initial state.
  void reset() {
    _currentPageIndex = 0;
    _answers.clear();
    _errors.clear();
    _isCompleted = false;
    _applyDefaultValues();
    notifyListeners();
  }

  // ─── Visibility (visibleIf support — simple expression engine) ────────────

  bool isQuestionVisible(QuestionModel question) {
    if (!question.visible) return false;
    if (question.visibleIf == null) return true;
    return _evaluateExpression(question.visibleIf!, question.name);
  }

  bool isQuestionEnabled(QuestionModel question) {
    if (question.readOnly) return false;
    if (question.enableIf == null) return true;
    return _evaluateExpression(question.enableIf!, question.name);
  }

  /// Simple expression evaluator for visibleIf / enableIf.
  /// Supports: {questionName} = 'value', {questionName} <> 'value',
  ///           {questionName} contains 'value', and/or combinations.
  bool _evaluateExpression(String expression, String selfName) {
    try {
      final expr = expression.trim();

      // Handle 'and' / 'or'
      if (expr.toLowerCase().contains(' and ')) {
        final parts = expr.split(RegExp(r'\s+and\s+', caseSensitive: false));
        return parts.every((p) => _evaluateSingle(p.trim()));
      }
      if (expr.toLowerCase().contains(' or ')) {
        final parts = expr.split(RegExp(r'\s+or\s+', caseSensitive: false));
        return parts.any((p) => _evaluateSingle(p.trim()));
      }

      return _evaluateSingle(expr);
    } catch (_) {
      return true; // fail-open: show the question if expression is invalid
    }
  }

  bool _evaluateSingle(String expr) {
    // Extract {name} operator 'value'
    final nameMatch = RegExp(r'\{(\w+)\}').firstMatch(expr);
    if (nameMatch == null) return true;

    final qName = nameMatch.group(1)!;
    final answer = _answers[qName];

    // = or ==
    if (expr.contains(' = ') || expr.contains(' == ')) {
      final valMatch = RegExp(r"[=!<>]+\s*'?([^']+)'?").firstMatch(expr);
      final expected = valMatch?.group(1)?.trim();
      return answer?.toString() == expected;
    }

    // <> or !=
    if (expr.contains(' <> ') || expr.contains(' != ')) {
      final valMatch = RegExp(r"[<>!]+\s*'?([^']+)'?").firstMatch(expr);
      final expected = valMatch?.group(1)?.trim();
      return answer?.toString() != expected;
    }

    // contains
    if (expr.toLowerCase().contains(' contains ')) {
      final valMatch = RegExp(r"contains\s+'?([^']+)'?", caseSensitive: false).firstMatch(expr);
      final expected = valMatch?.group(1)?.trim() ?? '';
      if (answer is List) return answer.contains(expected);
      return answer?.toString().contains(expected) ?? false;
    }

    // notempty / empty
    if (expr.toLowerCase().contains('notempty')) return answer != null && answer.toString().isNotEmpty;
    if (expr.toLowerCase().contains('empty')) return answer == null || answer.toString().isEmpty;

    return true;
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  void _applyDefaultValues() {
    for (final page in survey.pages) {
      for (final question in page.elements) {
        if (question.defaultValue != null) {
          _answers[question.name] = question.defaultValue;
        }
      }
    }
  }
}
