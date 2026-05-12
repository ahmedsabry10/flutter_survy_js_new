import 'survey_choice.dart';
import 'question_type.dart';
import '../validators/survey_validator.dart';

class QuestionModel {
  final String name;
  final QuestionType type;
  final String? title;
  final String? description;
  final bool isRequired;
  final String? visibleIf;
  final String? enableIf;
  final String? requiredIf;
  final dynamic defaultValue;
  final String? defaultValueExpression;
  final bool startWithNewLine;
  final bool visible;
  final bool readOnly;
  final int? colCount;

  // Choices
  final List<SurveyChoice> choices;
  final bool? hasOther;
  final bool? showOtherItem;   // alias for hasOther
  final String? otherText;
  final bool? hasNone;
  final bool? showNoneItem;    // alias for hasNone
  final String? noneText;
  final bool? hasSelectAll;
  final bool? showSelectAllItem; // alias for hasSelectAll
  final String? choicesOrder;

  // Text
  final String? inputType;
  final String? placeholder;
  final int? maxLength;
  final num? min;
  final num? max;
  final String? step;

  // Rating
  final int? rateMin;
  final int? rateMax;
  final int? rateCount;
  final int? rateStep;
  final String? minRateDescription;
  final String? maxRateDescription;
  final String? rateType;

  // Matrix
  final List<SurveyChoice> rows;
  final List<dynamic> columns; // can be String or Map (matrixdropdown)
  final bool? isAllRowRequired;
  final bool? horizontalScroll;

  // MatrixDynamic
  final int? rowCount;
  final int? minRowCount;
  final int? maxRowCount;
  final String? addRowText;
  final String? removeRowText;
  final String? detailPanelMode;
  final List<QuestionModel> detailElements;

  // Panel / PanelDynamic
  final List<QuestionModel> elements;
  final String? templateTitle;
  final int? panelCount;
  final int? minPanelCount;
  final int? maxPanelCount;
  final String? panelAddText;
  final String? panelRemoveText;
  final String? renderMode;
  final bool? allowAddPanel;
  final bool? allowRemovePanel;

  // Multiple text
  final List<MultipleTextItem> items;

  // HTML / Image
  final String? html;
  final String? imageLink;
  final String? imageHeight;
  final String? imageWidth;

  // ImagePicker
  final bool? multiSelect;

  // File
  final bool? allowMultiple;
  final List<String>? acceptedTypes;
  final num? maxSize;
  final bool? storeDataAsText;
  final bool? waitForUpload;
  final bool? allowImagesPreview;

  // Boolean
  final String? labelTrue;
  final String? labelFalse;
  final String? renderAs;

  // Comment
  final int? rows_count; // "rows" field for comment textarea height

  // Expression
  final String? expression;
  final String? displayStyle;
  final int? maximumFractionDigits;

  // Signature
  final int? signatureWidth;
  final int? signatureHeight;

  // Validators
  final List<SurveyValidator> validators;

  // Raw JSON
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
    this.defaultValueExpression,
    this.startWithNewLine = true,
    this.visible = true,
    this.readOnly = false,
    this.colCount,
    this.choices = const [],
    this.hasOther,
    this.showOtherItem,
    this.otherText,
    this.hasNone,
    this.showNoneItem,
    this.noneText,
    this.hasSelectAll,
    this.showSelectAllItem,
    this.choicesOrder,
    this.inputType,
    this.placeholder,
    this.maxLength,
    this.min,
    this.max,
    this.step,
    this.rateMin,
    this.rateMax,
    this.rateCount,
    this.rateStep,
    this.minRateDescription,
    this.maxRateDescription,
    this.rateType,
    this.rows = const [],
    this.columns = const [],
    this.isAllRowRequired,
    this.horizontalScroll,
    this.rowCount,
    this.minRowCount,
    this.maxRowCount,
    this.addRowText,
    this.removeRowText,
    this.detailPanelMode,
    this.detailElements = const [],
    this.elements = const [],
    this.templateTitle,
    this.panelCount,
    this.minPanelCount,
    this.maxPanelCount,
    this.panelAddText,
    this.panelRemoveText,
    this.renderMode,
    this.allowAddPanel,
    this.allowRemovePanel,
    this.items = const [],
    this.html,
    this.imageLink,
    this.imageHeight,
    this.imageWidth,
    this.multiSelect,
    this.allowMultiple,
    this.acceptedTypes,
    this.maxSize,
    this.storeDataAsText,
    this.waitForUpload,
    this.allowImagesPreview,
    this.labelTrue,
    this.labelFalse,
    this.renderAs,
    this.rows_count,
    this.expression,
    this.displayStyle,
    this.maximumFractionDigits,
    this.signatureWidth,
    this.signatureHeight,
    this.validators = const [],
  });

  String get displayTitle => (title != null && title!.isNotEmpty) ? title! : name;

  // Resolve aliases
  bool get effectiveHasOther => hasOther ?? showOtherItem ?? false;
  bool get effectiveHasNone => hasNone ?? showNoneItem ?? false;
  bool get effectiveHasSelectAll => hasSelectAll ?? showSelectAllItem ?? false;

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    List<SurveyChoice> parseChoices(dynamic raw) {
      if (raw == null) return [];
      if (raw is! List) return [];
      return raw.map((e) => SurveyChoice.fromJson(e)).toList();
    }

    List<SurveyValidator> parseValidators(dynamic raw) {
      if (raw == null) return [];
      if (raw is! List) return [];
      return raw
          .whereType<Map<String, dynamic>>()
          .map((e) => SurveyValidator.fromJson(e))
          .toList();
    }

    List<QuestionModel> parseElements(dynamic raw) {
      if (raw == null) return [];
      if (raw is! List) return [];
      return raw
          .whereType<Map<String, dynamic>>()
          .map((e) => QuestionModel.fromJson(e))
          .toList();
    }

    List<MultipleTextItem> parseItems(dynamic raw) {
      if (raw == null) return [];
      if (raw is! List) return [];
      return raw
          .whereType<Map<String, dynamic>>()
          .map((e) => MultipleTextItem.fromJson(e))
          .toList();
    }

    // acceptedTypes: accepts both String ".pdf,.doc" and List ["image/jpeg"]
    List<String>? parseAcceptedTypes(dynamic raw) {
      if (raw == null) return null;
      if (raw is List) return List<String>.from(raw);
      if (raw is String && raw.isNotEmpty) return raw.split(',').map((s) => s.trim()).toList();
      return null;
    }

    // columns: can be List<String> or List<Map> (matrixdropdown)
    List<dynamic> parseColumns(dynamic raw) {
      if (raw == null) return [];
      if (raw is! List) return [];
      return raw.map((e) {
        if (e is Map<String, dynamic>) return e;
        return SurveyChoice.fromJson(e);
      }).toList();
    }

    // showProgressBar can be bool OR string "top"/"bottom"
    // handle safely
    bool parseBoolOrString(dynamic val, bool defaultVal) {
      if (val == null) return defaultVal;
      if (val is bool) return val;
      if (val is String) return val == 'true';
      return defaultVal;
    }

    return QuestionModel(
      name: json['name']?.toString() ?? '',
      type: QuestionType.fromString(json['type']?.toString() ?? 'empty'),
      rawJson: json,
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      isRequired: json['isRequired'] as bool? ?? json['required'] as bool? ?? false,
      visibleIf: json['visibleIf']?.toString(),
      enableIf: json['enableIf']?.toString(),
      requiredIf: json['requiredIf']?.toString(),
      defaultValue: json['defaultValue'],
      defaultValueExpression: json['defaultValueExpression']?.toString(),
      startWithNewLine: json['startWithNewLine'] as bool? ?? true,
      visible: json['visible'] as bool? ?? true,
      readOnly: json['readOnly'] as bool? ?? false,
      colCount: json['colCount'] as int?,
      choices: parseChoices(json['choices']),
      hasOther: json['hasOther'] as bool?,
      showOtherItem: json['showOtherItem'] as bool?,
      otherText: json['otherText']?.toString(),
      hasNone: json['hasNone'] as bool?,
      showNoneItem: json['showNoneItem'] as bool?,
      noneText: json['noneText']?.toString(),
      hasSelectAll: json['hasSelectAll'] as bool?,
      showSelectAllItem: json['showSelectAllItem'] as bool?,
      choicesOrder: json['choicesOrder']?.toString(),
      inputType: json['inputType']?.toString(),
      placeholder: json['placeholder']?.toString(),
      maxLength: json['maxLength'] as int?,
      min: json['min'] as num?,
      max: json['max'] as num?,
      step: json['step']?.toString(),
      rateMin: json['rateMin'] as int?,
      rateMax: json['rateMax'] as int?,
      rateCount: json['rateCount'] as int?,
      rateStep: json['rateStep'] as int?,
      minRateDescription: json['minRateDescription']?.toString(),
      maxRateDescription: json['maxRateDescription']?.toString(),
      rateType: json['rateType']?.toString(),
      rows: parseChoices(json['rows']),
      columns: parseColumns(json['columns']),
      isAllRowRequired: json['isAllRowRequired'] as bool?,
      horizontalScroll: json['horizontalScroll'] as bool?,
      rowCount: json['rowCount'] as int?,
      minRowCount: json['minRowCount'] as int?,
      maxRowCount: json['maxRowCount'] as int?,
      addRowText: json['addRowText']?.toString(),
      removeRowText: json['removeRowText']?.toString(),
      detailPanelMode: json['detailPanelMode']?.toString(),
      detailElements: parseElements(json['detailElements']),
      elements: parseElements(
          json['elements'] ?? json['templateElements']),
      templateTitle: json['templateTitle']?.toString(),
      panelCount: json['panelCount'] as int?,
      minPanelCount: json['minPanelCount'] as int?,
      maxPanelCount: json['maxPanelCount'] as int?,
      panelAddText: json['panelAddText']?.toString(),
      panelRemoveText: json['panelRemoveText']?.toString(),
      renderMode: json['renderMode']?.toString(),
      allowAddPanel: json['allowAddPanel'] as bool?,
      allowRemovePanel: json['allowRemovePanel'] as bool?,
      items: parseItems(json['items']),
      html: json['html']?.toString(),
      imageLink: json['imageLink']?.toString(),
      imageHeight: json['imageHeight']?.toString(),
      imageWidth: json['imageWidth']?.toString(),
      multiSelect: json['multiSelect'] as bool?,
      allowMultiple: json['allowMultiple'] as bool?,
      acceptedTypes: parseAcceptedTypes(json['acceptedTypes']),
      maxSize: json['maxSize'] as num?,
      storeDataAsText: json['storeDataAsText'] as bool?,
      waitForUpload: json['waitForUpload'] as bool?,
      allowImagesPreview: json['allowImagesPreview'] as bool?,
      labelTrue: json['labelTrue']?.toString(),
      labelFalse: json['labelFalse']?.toString(),
      renderAs: json['renderAs']?.toString(),
      rows_count: json['rows'] is int ? json['rows'] as int : null,
      expression: json['expression']?.toString(),
      displayStyle: json['displayStyle']?.toString(),
      maximumFractionDigits: json['maximumFractionDigits'] as int?,
      signatureWidth: json['signatureWidth'] as int?,
      signatureHeight: json['signatureHeight'] as int?,
      validators: parseValidators(json['validators']),
    );
  }

  @override
  String toString() => 'QuestionModel(name: $name, type: $type)';
}

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
      name: json['name']?.toString() ?? '',
      title: json['title']?.toString(),
      placeholder: json['placeholder']?.toString(),
      inputType: json['inputType']?.toString(),
      isRequired: json['isRequired'] as bool? ?? false,
    );
  }
}
