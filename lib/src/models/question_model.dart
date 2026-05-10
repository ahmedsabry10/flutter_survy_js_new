import 'survey_choice.dart';
import 'question_type.dart';
import '../validators/survey_validator.dart';

/// Represents a single question parsed from SurveyJS JSON.
/// All fields are optional except [name] and [type].
class QuestionModel {
  // ─── Identity ─────────────────────────────────────────────────────────────
  final String name;
  final QuestionType type;
  final String? title;
  final String? description;

  // ─── Behaviour ────────────────────────────────────────────────────────────
  final bool isRequired;
  final String? visibleIf;
  final String? enableIf;
  final String? requiredIf;
  final dynamic defaultValue;
  final bool startWithNewLine;
  final bool visible;
  final bool readOnly;

  // ─── Choices (radio, checkbox, dropdown, imagepicker, ranking) ────────────
  final List<SurveyChoice> choices;
  final bool? hasOther;
  final String? otherText;
  final bool? hasNone;
  final String? noneText;
  final bool? hasSelectAll;
  final String? choicesOrder; // "none" | "asc" | "desc" | "random"

  // ─── Text input ───────────────────────────────────────────────────────────
  final String? inputType; // "text" | "email" | "number" | "date" | ...
  final String? placeholder;
  final int? maxLength;
  final num? min;
  final num? max;
  final String? step;

  // ─── Rating ───────────────────────────────────────────────────────────────
  final int? rateMin;
  final int? rateMax;
  final int? rateStep;
  final String? minRateDescription;
  final String? maxRateDescription;
  final String? rateType; // "stars" | "smileys" | "labels"

  // ─── Matrix ───────────────────────────────────────────────────────────────
  final List<SurveyChoice> rows;
  final List<SurveyChoice> columns;

  // ─── Panel / PanelDynamic ─────────────────────────────────────────────────
  final List<QuestionModel> elements;
  final String? templateTitle;
  final int? panelCount;
  final int? minPanelCount;
  final int? maxPanelCount;
  final String? panelAddText;
  final String? panelRemoveText;

  // ─── Multiple text ────────────────────────────────────────────────────────
  final List<MultipleTextItem> items;

  // ─── HTML / Image ─────────────────────────────────────────────────────────
  final String? html;
  final String? imageLink;
  final String? imageHeight;
  final String? imageWidth;

  // ─── File upload ──────────────────────────────────────────────────────────
  final bool? allowMultiple;
  final List<String>? acceptedTypes;
  final num? maxSize;

  // ─── Boolean ──────────────────────────────────────────────────────────────
  final String? labelTrue;
  final String? labelFalse;

  // ─── Validators ───────────────────────────────────────────────────────────
  final List<SurveyValidator> validators;

  // ─── Raw JSON (for unsupported features) ──────────────────────────────────
  final Map<String, dynamic> rawJson;

  const QuestionModel({
    required this.name,
    required this.type,
    required this.rawJson,
    this.title,
    this.description,
    this.isRequired = false,
    this.visibleIf,
    this.enableIf,
    this.requiredIf,
    this.defaultValue,
    this.startWithNewLine = true,
    this.visible = true,
    this.readOnly = false,
    this.choices = const [],
    this.hasOther,
    this.otherText,
    this.hasNone,
    this.noneText,
    this.hasSelectAll,
    this.choicesOrder,
    this.inputType,
    this.placeholder,
    this.maxLength,
    this.min,
    this.max,
    this.step,
    this.rateMin,
    this.rateMax,
    this.rateStep,
    this.minRateDescription,
    this.maxRateDescription,
    this.rateType,
    this.rows = const [],
    this.columns = const [],
    this.elements = const [],
    this.templateTitle,
    this.panelCount,
    this.minPanelCount,
    this.maxPanelCount,
    this.panelAddText,
    this.panelRemoveText,
    this.items = const [],
    this.html,
    this.imageLink,
    this.imageHeight,
    this.imageWidth,
    this.allowMultiple,
    this.acceptedTypes,
    this.maxSize,
    this.labelTrue,
    this.labelFalse,
    this.validators = const [],
  });

  /// The display title — falls back to [name] if no title provided
  String get displayTitle => (title != null && title!.isNotEmpty) ? title! : name;

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    List<SurveyChoice> _parseChoices(dynamic raw) {
      if (raw == null) return [];
      return (raw as List).map((e) => SurveyChoice.fromJson(e)).toList();
    }

    List<SurveyValidator> _parseValidators(dynamic raw) {
      if (raw == null) return [];
      return (raw as List)
          .map((e) => SurveyValidator.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    List<QuestionModel> _parseElements(dynamic raw) {
      if (raw == null) return [];
      return (raw as List)
          .map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    List<MultipleTextItem> _parseItems(dynamic raw) {
      if (raw == null) return [];
      return (raw as List)
          .map((e) => MultipleTextItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return QuestionModel(
      name: json['name'] as String? ?? '',
      type: QuestionType.fromString(json['type'] as String? ?? 'empty'),
      rawJson: json,
      title: json['title'] as String?,
      description: json['description'] as String?,
      isRequired: json['isRequired'] as bool? ?? json['required'] as bool? ?? false,
      visibleIf: json['visibleIf'] as String?,
      enableIf: json['enableIf'] as String?,
      requiredIf: json['requiredIf'] as String?,
      defaultValue: json['defaultValue'],
      startWithNewLine: json['startWithNewLine'] as bool? ?? true,
      visible: json['visible'] as bool? ?? true,
      readOnly: json['readOnly'] as bool? ?? false,
      choices: _parseChoices(json['choices']),
      hasOther: json['hasOther'] as bool?,
      otherText: json['otherText'] as String?,
      hasNone: json['hasNone'] as bool?,
      noneText: json['noneText'] as String?,
      hasSelectAll: json['hasSelectAll'] as bool?,
      choicesOrder: json['choicesOrder'] as String?,
      inputType: json['inputType'] as String?,
      placeholder: json['placeholder'] as String?,
      maxLength: json['maxLength'] as int?,
      min: json['min'] as num?,
      max: json['max'] as num?,
      step: json['step']?.toString(),
      rateMin: json['rateMin'] as int?,
      rateMax: json['rateMax'] as int?,
      rateStep: json['rateStep'] as int?,
      minRateDescription: json['minRateDescription'] as String?,
      maxRateDescription: json['maxRateDescription'] as String?,
      rateType: json['rateType'] as String?,
      rows: _parseChoices(json['rows']),
      columns: _parseChoices(json['columns']),
      elements: _parseElements(json['elements'] ?? json['templateElements']),
      templateTitle: json['templateTitle'] as String?,
      panelCount: json['panelCount'] as int?,
      minPanelCount: json['minPanelCount'] as int?,
      maxPanelCount: json['maxPanelCount'] as int?,
      panelAddText: json['panelAddText'] as String?,
      panelRemoveText: json['panelRemoveText'] as String?,
      items: _parseItems(json['items']),
      html: json['html'] as String?,
      imageLink: json['imageLink'] as String?,
      imageHeight: json['imageHeight']?.toString(),
      imageWidth: json['imageWidth']?.toString(),
      allowMultiple: json['allowMultiple'] as bool?,
      acceptedTypes: json['acceptedTypes'] is List
          ? List<String>.from(json['acceptedTypes'] as List)
          : (json['acceptedTypes'] as String?)?.split(','),
      maxSize: json['maxSize'] as num?,
      labelTrue: json['labelTrue'] as String?,
      labelFalse: json['labelFalse'] as String?,
      validators: _parseValidators(json['validators']),
    );
  }

  @override
  String toString() => 'QuestionModel(name: $name, type: $type)';
}

// ─── Multiple Text Item ────────────────────────────────────────────────────

class MultipleTextItem {
  final String name;
  final String? title;
  final String? placeholder;
  final String? inputType;
  final bool isRequired;

  const MultipleTextItem({
    required this.name,
    this.title,
    this.placeholder,
    this.inputType,
    this.isRequired = false,
  });

  factory MultipleTextItem.fromJson(Map<String, dynamic> json) {
    return MultipleTextItem(
      name: json['name'] as String? ?? '',
      title: json['title'] as String?,
      placeholder: json['placeholder'] as String?,
      inputType: json['inputType'] as String?,
      isRequired: json['isRequired'] as bool? ?? false,
    );
  }
}