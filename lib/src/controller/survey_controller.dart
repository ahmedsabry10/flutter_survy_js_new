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
    _applyCalculatedValues(); // recalculate derived values
    _applyTriggers();
    notifyListeners(); // rebuild AFTER calculated values are updated
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

  // ─── Public expression evaluator (for expression questions) ─────────────────

  /// Evaluates a calculated expression and returns the result.
  /// Used by expression-type questions to display computed values.
  dynamic evaluateCalculatedExpression(String expression) {
    return _evaluateCalculatedExpression(expression);
  }

  // ─── Calculated Values ────────────────────────────────────────────────────

  void _applyCalculatedValues() {
    for (final cv in survey.calculatedValues) {
      final name = cv['name'] as String?;
      final expression = cv['expression'] as String?;
      if (name == null || expression == null) continue;
      // Always evaluate and store — even if null clears old value
      final result = _evaluateCalculatedExpression(expression);
      _answers[name] = result;
    }
  }

  dynamic _evaluateCalculatedExpression(String expression) {
    try {
      final expr = expression.trim();

      // ── iif() — handles nested iif recursively ──────────────────────────
      if (expr.toLowerCase().startsWith('iif(')) {
        return _evalIif(expr);
      }

      // ── Simple {varName} reference ────────────────────────────────────
      final simpleRef = RegExp(r'^\{(\w+)\}$').firstMatch(expr);
      if (simpleRef != null) {
        return _answers[simpleRef.group(1)];
      }

      // ── String concatenation: {a} + ' ' + {b} ────────────────────────
      if (expr.contains("'")) {
        String result = expr;
        for (final m in RegExp(r'\{(\w+)\}').allMatches(expr)) {
          result = result.replaceAll(m.group(0)!, _answers[m.group(1)]?.toString() ?? '');
        }
        // Remove string literal quotes and + operators
        result = result
            .replaceAll(RegExp(r"'\s*\+\s*'"), '')
            .replaceAll(RegExp(r"'\s*\+\s*"), '')
            .replaceAll(RegExp(r"\s*\+\s*'"), '')
            .replaceAll("'", '')
            .trim();
        return result;
      }

      // ── Arithmetic: ({a} + {b}) / 2 ───────────────────────────────────
      if (RegExp(r'[\+\-\*\/]').hasMatch(expr)) {
        // Replace all {varName} with their numeric values
        String evalStr = expr.replaceAll('(', '').replaceAll(')', '');
        for (final m in RegExp(r'\{(\w+)\}').allMatches(expr)) {
          final val = _answers[m.group(1)]?.toString() ?? '0';
          evalStr = evalStr.replaceAll(m.group(0)!, val);
        }
        // Simple two-operand arithmetic
        final parts = RegExp(r'([\d\.]+)\s*([\+\-\*\/])\s*([\d\.]+)')
            .firstMatch(evalStr);
        if (parts != null) {
          final a = double.tryParse(parts.group(1)!) ?? 0;
          final op = parts.group(2)!;
          final b = double.tryParse(parts.group(3)!) ?? 0;
          return _applyOp(a, b, op);
        }
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  /// Evaluates iif(condition, trueVal, falseVal) with nested iif support
  dynamic _evalIif(String expr) {
    try {
      // Find the matching parentheses for iif(...)
      final inner = _extractIifInner(expr);
      if (inner == null) return null;

      // Split into: condition, trueVal, falseVal
      // Careful: falseVal might be a nested iif()
      final parts = _splitIifParts(inner);
      if (parts == null || parts.length < 3) return null;

      final condition = parts[0].trim();
      final trueVal = parts[1].trim().replaceAll("'", '');
      final falseVal = parts[2].trim();

      final condResult = _evaluateCondition(condition);

      if (condResult) {
        return trueVal;
      } else {
        // falseVal might be another iif
        if (falseVal.toLowerCase().startsWith('iif(')) {
          return _evalIif(falseVal);
        }
        return falseVal.replaceAll("'", '');
      }
    } catch (_) {
      return null;
    }
  }

  /// Extracts the inner content of iif(...)
  String? _extractIifInner(String expr) {
    final start = expr.indexOf('(');
    if (start < 0) return null;
    int depth = 0;
    int end = -1;
    for (int i = start; i < expr.length; i++) {
      if (expr[i] == '(') depth++;
      else if (expr[i] == ')') {
        depth--;
        if (depth == 0) { end = i; break; }
      }
    }
    if (end < 0) return null;
    return expr.substring(start + 1, end);
  }

  /// Splits iif inner into [condition, trueVal, falseVal]
  /// Handles nested iif() in falseVal
  List<String>? _splitIifParts(String inner) {
    final parts = <String>[];
    int depth = 0;
    int start = 0;
    for (int i = 0; i < inner.length; i++) {
      if (inner[i] == '(') depth++;
      else if (inner[i] == ')') depth--;
      else if (inner[i] == ',' && depth == 0) {
        parts.add(inner.substring(start, i).trim());
        start = i + 1;
      }
    }
    parts.add(inner.substring(start).trim());
    // condition, trueVal, rest (falseVal may have commas if nested iif)
    if (parts.length >= 3) {
      final condition = parts[0];
      final trueVal = parts[1];
      final falseVal = parts.sublist(2).join(',');
      return [condition, trueVal, falseVal];
    }
    return parts.length == 2 ? parts : null;
  }

  /// Evaluates a simple boolean condition like "{age} < 18"
  bool _evaluateCondition(String condition) {
    // Numeric comparisons: {varName} op number
    final numMatch = RegExp(
      r'\{(\w+)\}\s*([<>=!]+)\s*([\d\.]+)',
    ).firstMatch(condition);
    if (numMatch != null) {
      final varName = numMatch.group(1)!;
      final op = numMatch.group(2)!;
      final expected = double.tryParse(numMatch.group(3)!) ?? 0;
      final rawVal = _answers[varName]?.toString() ?? '';
      // If value is empty/null — can't compare numerically → return false
      final actual = double.tryParse(rawVal);
      if (actual == null) return false;
      switch (op) {
        case '<':  return actual < expected;
        case '<=': return actual <= expected;
        case '>':  return actual > expected;
        case '>=': return actual >= expected;
        case '=':
        case '==': return actual == expected;
        case '!=':
        case '<>': return actual != expected;
      }
    }
    // Fall back to general expression evaluator
    return evaluateExpression(condition);
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
      if (!_validateQuestionTree(question)) {
        isValid = false;
      }
    }
    notifyListeners();
    return isValid;
  }

  /// Validates a question and its children recursively.
  bool _validateQuestionTree(QuestionModel question) {
    if (!isQuestionVisible(question)) return true;

    bool isValid = true;

    // panel — validate children only (panel itself has no answer)
    if (question.type.name == 'panel') {
      for (final child in question.elements) {
        if (!_validateQuestionTree(child)) isValid = false;
      }
      return isValid;
    }

    // paneldynamic — only validate if there are actual instances
    if (question.type.name == 'paneldynamic') {
      final instances = _answers[question.name];
      final minCount = question.minPanelCount ?? 0;

      // If no instances and minPanelCount = 0 — perfectly valid
      if (instances == null || (instances is List && instances.isEmpty)) {
        if (minCount > 0) {
          _errors[question.name] = 'Please add at least $minCount panel(s)';
          return false;
        }
        return true;
      }

      // Validate each actual instance
      if (instances is List) {
        for (int i = 0; i < instances.length; i++) {
          final instanceAnswers = instances[i] is Map
              ? Map<String, dynamic>.from(instances[i] as Map)
              : <String, dynamic>{};
          for (final tmpl in question.elements) {
            if (!tmpl.isRequired) continue;
            final val = instanceAnswers[tmpl.name];
            if (_isValueEmpty(val)) {
              _errors[question.name] =
                  'Please fill required fields in panel ${i + 1}';
              isValid = false;
            }
          }
        }
      }
      if (isValid) _errors.remove(question.name);
      return isValid;
    }

    // Normal question
    final error = _validateQuestion(question);
    if (error != null) {
      _errors[question.name] = error;
      isValid = false;
    } else {
      _errors.remove(question.name);
    }
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
    // Find next VISIBLE page
    int next = _currentPageIndex + 1;
    while (next < survey.pages.length - 1 &&
        !isPageVisible(survey.pages[next])) {
      next++;
    }
    _currentPageIndex = next;
    _errors.clear();
    _applyCalculatedValues();
    notifyListeners();
    return true;
  }

  void prevPage() {
    if (isFirstPage) return;
    // Find previous VISIBLE page — always go at least to index 0
    int prev = _currentPageIndex - 1;
    while (prev > 0 && !isPageVisible(survey.pages[prev])) {
      prev--;
    }
    _currentPageIndex = prev;
    _errors.clear();
    notifyListeners();
  }

  /// Jump directly to a page index
  void goToPage(int index) {
    if (index >= 0 && index < survey.pageCount) {
      _currentPageIndex = index;
      _errors.clear();
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
