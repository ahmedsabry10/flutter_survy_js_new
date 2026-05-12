import 'package:flutter/foundation.dart';
import '../models/survey_model.dart';
import '../models/question_model.dart';
import '../validators/survey_validator.dart';

class SurveyController extends ChangeNotifier {
  final SurveyModel survey;

  int _currentPageIndex = 0;
  final Map<String, dynamic> _answers = {};
  final Map<String, String?> _errors = {};
  bool _isCompleted = false;

  SurveyController({required this.survey}) {
    _applyDefaultValues();
    _applyCalculatedValues();
    _applyTriggers();
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

  // ─── Answers ──────────────────────────────────────────────────────────────

  dynamic getAnswer(String name) => _answers[name];

  void setAnswer(String name, dynamic value) {
    _answers[name] = value;
    _errors.remove(name);
    _applyCalculatedValues();
    _applyTriggers();
    notifyListeners();
  }

  void clearAnswer(String name) {
    _answers.remove(name);
    _errors.remove(name);
    notifyListeners();
  }

  // ─── Expression Engine ────────────────────────────────────────────────────
  // Supports: =, ==, !=, <>, >, <, >=, <=, contains, anyof, allof,
  //           notempty, empty, and, or

  bool evaluateExpression(String expression) {
    try {
      final expr = expression.trim();
      // Handle 'and'
      if (RegExp(r'\s+and\s+', caseSensitive: false).hasMatch(expr)) {
        final parts = expr.split(RegExp(r'\s+and\s+', caseSensitive: false));
        return parts.every((p) => _evaluateSingle(p.trim()));
      }
      // Handle 'or'
      if (RegExp(r'\s+or\s+', caseSensitive: false).hasMatch(expr)) {
        final parts = expr.split(RegExp(r'\s+or\s+', caseSensitive: false));
        return parts.any((p) => _evaluateSingle(p.trim()));
      }
      return _evaluateSingle(expr);
    } catch (_) {
      return true;
    }
  }

  bool _evaluateSingle(String expr) {
    try {
      expr = expr.trim();
      // Remove wrapping parens
      if (expr.startsWith('(') && expr.endsWith(')')) {
        expr = expr.substring(1, expr.length - 1).trim();
      }

      final nameMatch = RegExp(r'\{(\w+)\}').firstMatch(expr);
      if (nameMatch == null) return true;

      final qName = nameMatch.group(1)!;
      final answer = _answers[qName];

      // anyof ['a','b','c']
      if (RegExp(r'\banyof\b', caseSensitive: false).hasMatch(expr)) {
        final listMatch = RegExp(r"anyof\s*\[([^\]]+)\]", caseSensitive: false).firstMatch(expr);
        if (listMatch != null) {
          final vals = listMatch.group(1)!
              .split(',')
              .map((s) => s.trim().replaceAll("'", '').replaceAll('"', ''))
              .toList();
          if (answer is List) return answer.any((a) => vals.contains(a.toString()));
          return vals.contains(answer?.toString());
        }
      }

      // allof ['a','b','c']
      if (RegExp(r'\ballof\b', caseSensitive: false).hasMatch(expr)) {
        final listMatch = RegExp(r"allof\s*\[([^\]]+)\]", caseSensitive: false).firstMatch(expr);
        if (listMatch != null) {
          final vals = listMatch.group(1)!
              .split(',')
              .map((s) => s.trim().replaceAll("'", '').replaceAll('"', ''))
              .toList();
          if (answer is List) return vals.every((v) => answer.contains(v));
          return false;
        }
      }

      // notempty
      if (RegExp(r'\bnotempty\b', caseSensitive: false).hasMatch(expr)) {
        return !_isValueEmpty(answer);
      }

      // empty
      if (RegExp(r'\bempty\b', caseSensitive: false).hasMatch(expr)) {
        return _isValueEmpty(answer);
      }

      // contains 'value'
      if (RegExp(r'\bcontains\b', caseSensitive: false).hasMatch(expr)) {
        final vMatch = RegExp(r"contains\s+'?([^']+)'?", caseSensitive: false).firstMatch(expr);
        final expected = vMatch?.group(1)?.trim() ?? '';
        if (answer is List) return answer.any((a) => a.toString() == expected);
        return answer?.toString().contains(expected) ?? false;
      }

      // notcontains
      if (RegExp(r'\bnotcontains\b', caseSensitive: false).hasMatch(expr)) {
        final vMatch = RegExp(r"notcontains\s+'?([^']+)'?", caseSensitive: false).firstMatch(expr);
        final expected = vMatch?.group(1)?.trim() ?? '';
        if (answer is List) return !answer.any((a) => a.toString() == expected);
        return !(answer?.toString().contains(expected) ?? false);
      }

      // Extract operator and value
      final opMatch = RegExp(r"\{[\w]+\}\s*(>=|<=|!=|<>|==|=|>|<)\s*'?([^']*)'?").firstMatch(expr);
      if (opMatch == null) return true;

      final op = opMatch.group(1)!.trim();
      final expected = opMatch.group(2)!.trim();
      final answerStr = answer?.toString() ?? '';
      final answerNum = num.tryParse(answerStr);
      final expectedNum = num.tryParse(expected);

      switch (op) {
        case '=':
        case '==':
          // Handle bool comparison
          if (answer is bool) {
            return answer.toString() == expected ||
                (expected == 'true' && answer == true) ||
                (expected == 'false' && answer == false);
          }
          return answerStr == expected;
        case '!=':
        case '<>':
          if (answer is bool) return answer.toString() != expected;
          return answerStr != expected;
        case '>':
          if (answerNum != null && expectedNum != null) return answerNum > expectedNum;
          return answerStr.compareTo(expected) > 0;
        case '<':
          if (answerNum != null && expectedNum != null) return answerNum < expectedNum;
          return answerStr.compareTo(expected) < 0;
        case '>=':
          if (answerNum != null && expectedNum != null) return answerNum >= expectedNum;
          return answerStr.compareTo(expected) >= 0;
        case '<=':
          if (answerNum != null && expectedNum != null) return answerNum <= expectedNum;
          return answerStr.compareTo(expected) <= 0;
        default:
          return true;
      }
    } catch (_) {
      return true;
    }
  }

  // ─── Calculated Values ────────────────────────────────────────────────────

  void _applyCalculatedValues() {
    for (final cv in survey.calculatedValues) {
      final name = cv['name'] as String?;
      final expression = cv['expression'] as String?;
      if (name == null || expression == null) continue;

      final result = _evaluateCalculatedExpression(expression);
      if (result != null) {
        _answers[name] = result;
      }
    }
  }

  dynamic _evaluateCalculatedExpression(String expression) {
    try {
      // iif(condition, trueVal, falseVal)
      final iifMatch = RegExp(
              r"iif\((.+),\s*'?([^',]*)'?,\s*'?([^')]*)'?\)",
              caseSensitive: false)
          .firstMatch(expression);
      if (iifMatch != null) {
        final condition = iifMatch.group(1)!;
        final trueVal = iifMatch.group(2)!.trim();
        final falseVal = iifMatch.group(3)!.trim();

        // Handle nested iif
        if (falseVal.toLowerCase().startsWith('iif(')) {
          return evaluateExpression(condition)
              ? trueVal
              : _evaluateCalculatedExpression(falseVal);
        }
        return evaluateExpression(condition) ? trueVal : falseVal;
      }

      // {a} + ' ' + {b}  (string concatenation)
      if (expression.contains("'")) {
        String result = expression;
        final refs = RegExp(r'\{(\w+)\}').allMatches(expression);
        for (final m in refs) {
          final val = _answers[m.group(1)]?.toString() ?? '';
          result = result.replaceAll(m.group(0)!, val);
        }
        result = result
            .replaceAll(RegExp(r"'\s*\+\s*'"), '')
            .replaceAll(RegExp(r"'\s*\+\s*"), '')
            .replaceAll(RegExp(r"\s*\+\s*'"), '')
            .replaceAll("'", '');
        return result;
      }

      // ({a} + {b}) / 2  (arithmetic)
      if (RegExp(r'[\+\-\*\/]').hasMatch(expression)) {
        String eval = expression.replaceAll('(', '').replaceAll(')', '');
        final refs = RegExp(r'\{(\w+)\}').allMatches(expression);
        double? result;
        String op = '+';
        for (final m in refs) {
          final val = num.tryParse(_answers[m.group(1)]?.toString() ?? '');
          if (val != null) {
            result = result == null ? val.toDouble() : _applyOp(result, val.toDouble(), op);
          }
          final afterMatch = eval.substring(m.end < eval.length ? m.end : eval.length - 1);
          final opMatch = RegExp(r'^\s*([\+\-\*\/])').firstMatch(afterMatch);
          if (opMatch != null) op = opMatch.group(1)!;
        }
        // Handle divisor (e.g. / 2)
        final divisorMatch = RegExp(r'/\s*(\d+)$').firstMatch(expression);
        if (divisorMatch != null && result != null) {
          final div = double.tryParse(divisorMatch.group(1)!);
          if (div != null && div != 0) result = result / div;
        }
        return result;
      }

      // Simple {varName}
      final refMatch = RegExp(r'^\{(\w+)\}$').firstMatch(expression.trim());
      if (refMatch != null) return _answers[refMatch.group(1)];

      return null;
    } catch (_) {
      return null;
    }
  }

  double _applyOp(double a, double b, String op) {
    switch (op) {
      case '+': return a + b;
      case '-': return a - b;
      case '*': return a * b;
      case '/': return b != 0 ? a / b : 0;
      default: return a + b;
    }
  }

  // ─── Triggers ─────────────────────────────────────────────────────────────

  void _applyTriggers() {
    for (final trigger in survey.triggers) {
      final type = trigger['type'] as String?;
      final expression = trigger['expression'] as String?;
      if (expression == null || !evaluateExpression(expression)) continue;

      switch (type) {
        case 'setvalue':
          final setToName = trigger['setToName'] as String?;
          final setValue = trigger['setValue'];
          if (setToName != null) _answers[setToName] = setValue;
          break;

        case 'copyvalue':
          final setToName = trigger['setToName'] as String?;
          final fromName = trigger['fromName'] as String?;
          if (setToName != null && fromName != null) {
            _answers[setToName] = _answers[fromName];
          }
          break;

        case 'runexpression':
          final setToName = trigger['setToName'] as String?;
          final runExpr = trigger['runExpression'] as String?;
          if (setToName != null && runExpr != null) {
            _answers[setToName] = _evaluateCalculatedExpression(runExpr);
          }
          break;

        case 'complete':
          _isCompleted = true;
          break;

        case 'skip':
          // Navigate to a specific page
          final gotoName = trigger['gotoName'] as String?;
          if (gotoName != null) {
            final pageIdx = survey.pages.indexWhere((p) =>
                p.elements.any((e) => e.name == gotoName));
            if (pageIdx >= 0) _currentPageIndex = pageIdx;
          }
          break;
      }
    }
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
      // Recursively validate panel children
      if (question.elements.isNotEmpty) {
        for (final child in question.elements) {
          final childError = _validateQuestion(child);
          if (childError != null) {
            _errors[child.name] = childError;
            isValid = false;
          } else {
            _errors.remove(child.name);
          }
        }
      }
    }
    notifyListeners();
    return isValid;
  }

  String? _validateQuestion(QuestionModel question) {
    if (!isQuestionVisible(question)) return null;

    final value = _answers[question.name];
    final empty = _isValueEmpty(value);

    // isRequired
    if (question.isRequired && empty) return 'This field is required';

    // requiredIf
    if (question.requiredIf != null &&
        evaluateExpression(question.requiredIf!) &&
        empty) {
      return 'This field is required';
    }

    if (empty) return null;

    // Run validators
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
    if (value is Map) return value.isEmpty;
    return false;
  }

  String? getError(String name) => _errors[name];

  // ─── Visibility ───────────────────────────────────────────────────────────

  bool isQuestionVisible(QuestionModel question) {
    if (!question.visible) return false;
    if (question.visibleIf == null) return true;
    return evaluateExpression(question.visibleIf!);
  }

  bool isQuestionEnabled(QuestionModel question) {
    if (question.readOnly) return false;
    if (question.enableIf == null) return true;
    return evaluateExpression(question.enableIf!);
  }

  bool isPageVisible(PageModel page) {
    if (!page.visible) return false;
    // If no visibleIf, always visible
    if (page.visibleIf == null || page.visibleIf!.isEmpty) return true;
    // Evaluate expression — if answers not yet set, default to visible
    try {
      return evaluateExpression(page.visibleIf!);
    } catch (_) {
      return true;
    }
  }

  // ─── Navigation ───────────────────────────────────────────────────────────

  bool nextPage() {
    if (!validateCurrentPage()) return false;
    if (isLastPage) {
      complete();
      return true;
    }
    // Skip invisible pages but don't skip the last one
    int next = _currentPageIndex + 1;
    while (next < survey.pages.length - 1 &&
        !isPageVisible(survey.pages[next])) {
      next++;
    }
    _currentPageIndex = next;
    _applyCalculatedValues();
    notifyListeners();
    return true;
  }

  void prevPage() {
    if (isFirstPage) return;
    // Go back one page — skip invisible pages but always allow going back
    // to at least page 0
    int prev = _currentPageIndex - 1;
    while (prev > 0 && !isPageVisible(survey.pages[prev])) {
      prev--;
    }
    _currentPageIndex = prev;
    _errors.clear();
    notifyListeners();
  }

  void goToPage(int index) {
    if (index >= 0 && index < survey.pageCount) {
      _currentPageIndex = index;
      notifyListeners();
    }
  }

  void complete() {
    if (!validateCurrentPage()) return;
    _isCompleted = true;
    notifyListeners();
  }

  void reset() {
    _currentPageIndex = 0;
    _answers.clear();
    _errors.clear();
    _isCompleted = false;
    _applyDefaultValues();
    _applyCalculatedValues();
    notifyListeners();
  }

  // ─── Defaults ─────────────────────────────────────────────────────────────

  void _applyDefaultValues() {
    for (final page in survey.pages) {
      _applyDefaultsForElements(page.elements);
    }
  }

  void _applyDefaultsForElements(List<QuestionModel> elements) {
    for (final q in elements) {
      if (q.defaultValue != null && !_answers.containsKey(q.name)) {
        _answers[q.name] = q.defaultValue;
      }
      // defaultValueExpression — try to evaluate simple ones
      if (q.defaultValueExpression != null && !_answers.containsKey(q.name)) {
        final val = _evaluateCalculatedExpression(q.defaultValueExpression!);
        if (val != null) _answers[q.name] = val;
      }
      // Recurse into panels
      if (q.elements.isNotEmpty) _applyDefaultsForElements(q.elements);
    }
  }
}
