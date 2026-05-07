/// Base class for all SurveyJS validators
abstract class SurveyValidator {
  final String? text; // custom error message

  const SurveyValidator({this.text});

  factory SurveyValidator.fromJson(Map<String, dynamic> json) {
    final type = (json['type'] as String? ?? '').toLowerCase();
    switch (type) {
      case 'numericvalidator':
        return NumericValidator.fromJson(json);
      case 'textvalidator':
        return TextValidator.fromJson(json);
      case 'regexvalidator':
        return RegexValidator.fromJson(json);
      case 'emailvalidator':
        return EmailValidator.fromJson(json);
      case 'expressionvalidator':
        return ExpressionValidator.fromJson(json);
      case 'answercountvalidator':
        return AnswerCountValidator.fromJson(json);
      default:
        return UnknownValidator(type: type, text: json['text'] as String?);
    }
  }

  /// Validates [value], returns error message or null if valid
  String? validate(dynamic value);
}

// ─── Numeric ───────────────────────────────────────────────────────────────

class NumericValidator extends SurveyValidator {
  final num? minValue;
  final num? maxValue;

  const NumericValidator({super.text, this.minValue, this.maxValue});

  factory NumericValidator.fromJson(Map<String, dynamic> json) {
    return NumericValidator(
      text: json['text'] as String?,
      minValue: json['minValue'] as num?,
      maxValue: json['maxValue'] as num?,
    );
  }

  @override
  String? validate(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;
    final n = num.tryParse(value.toString());
    if (n == null) return text ?? 'Please enter a valid number';
    if (minValue != null && n < minValue!) {
      return text ?? 'Value must be at least $minValue';
    }
    if (maxValue != null && n > maxValue!) {
      return text ?? 'Value must be at most $maxValue';
    }
    return null;
  }
}

// ─── Text ──────────────────────────────────────────────────────────────────

class TextValidator extends SurveyValidator {
  final int? minLength;
  final int? maxLength;
  final bool? allowDigits;

  const TextValidator({
    super.text,
    this.minLength,
    this.maxLength,
    this.allowDigits,
  });

  factory TextValidator.fromJson(Map<String, dynamic> json) {
    return TextValidator(
      text: json['text'] as String?,
      minLength: json['minLength'] as int?,
      maxLength: json['maxLength'] as int?,
      allowDigits: json['allowDigits'] as bool?,
    );
  }

  @override
  String? validate(dynamic value) {
    if (value == null) return null;
    final str = value.toString();
    if (minLength != null && str.length < minLength!) {
      return text ?? 'Minimum length is $minLength characters';
    }
    if (maxLength != null && str.length > maxLength!) {
      return text ?? 'Maximum length is $maxLength characters';
    }
    if (allowDigits == false && RegExp(r'\d').hasMatch(str)) {
      return text ?? 'Digits are not allowed';
    }
    return null;
  }
}

// ─── Regex ─────────────────────────────────────────────────────────────────

class RegexValidator extends SurveyValidator {
  final String? regex;

  const RegexValidator({super.text, this.regex});

  factory RegexValidator.fromJson(Map<String, dynamic> json) {
    return RegexValidator(
      text: json['text'] as String?,
      regex: json['regex'] as String?,
    );
  }

  @override
  String? validate(dynamic value) {
    if (regex == null || value == null || value.toString().isEmpty) return null;
    final pattern = RegExp(regex!);
    if (!pattern.hasMatch(value.toString())) {
      return text ?? 'Invalid format';
    }
    return null;
  }
}

// ─── Email ─────────────────────────────────────────────────────────────────

class EmailValidator extends SurveyValidator {
  const EmailValidator({super.text});

  factory EmailValidator.fromJson(Map<String, dynamic> json) {
    return EmailValidator(text: json['text'] as String?);
  }

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
  );

  @override
  String? validate(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;
    if (!_emailRegex.hasMatch(value.toString())) {
      return text ?? 'Please enter a valid email address';
    }
    return null;
  }
}

// ─── Expression ────────────────────────────────────────────────────────────

class ExpressionValidator extends SurveyValidator {
  final String? expression;

  const ExpressionValidator({super.text, this.expression});

  factory ExpressionValidator.fromJson(Map<String, dynamic> json) {
    return ExpressionValidator(
      text: json['text'] as String?,
      expression: json['expression'] as String?,
    );
  }

  @override
  String? validate(dynamic value) {
    // Expression evaluation will be handled by the SurveyController
    // Returns null here — controller overrides this
    return null;
  }
}

// ─── AnswerCount ───────────────────────────────────────────────────────────

class AnswerCountValidator extends SurveyValidator {
  final int? minCount;
  final int? maxCount;

  const AnswerCountValidator({super.text, this.minCount, this.maxCount});

  factory AnswerCountValidator.fromJson(Map<String, dynamic> json) {
    return AnswerCountValidator(
      text: json['text'] as String?,
      minCount: json['minCount'] as int?,
      maxCount: json['maxCount'] as int?,
    );
  }

  @override
  String? validate(dynamic value) {
    if (value == null) return null;
    int count = 0;
    if (value is List) count = value.length;
    if (minCount != null && count < minCount!) {
      return text ?? 'Please select at least $minCount answer(s)';
    }
    if (maxCount != null && count > maxCount!) {
      return text ?? 'Please select at most $maxCount answer(s)';
    }
    return null;
  }
}

// ─── Unknown (fallback) ────────────────────────────────────────────────────

class UnknownValidator extends SurveyValidator {
  final String type;

  const UnknownValidator({required this.type, super.text});

  @override
  String? validate(dynamic value) => null;
}
