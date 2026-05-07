/// Represents a single selectable choice in radiogroup / checkbox /
/// dropdown / tagbox / imagepicker / ranking questions.
///
/// SurveyJS allows choices in two formats:
/// - Plain string:  `"Yes"`
/// - Object:        `{"value": "yes", "text": "Yes!", "imageLink": "..."}`
class SurveyChoice {
  /// The value stored in the answer (always a String internally).
  final String value;

  /// Optional display label. Falls back to [value] when null or empty.
  final String? text;

  /// Optional image URL — used by `imagepicker` questions.
  final String? imageLink;

  /// Optional SurveyJS expression that controls visibility of this choice.
  /// Example: `"{q1} = 'other'"`
  final String? visibleIf;

  /// Optional score used by scoring / quiz modes.
  final num? score;

  const SurveyChoice({
    required this.value,
    this.text,
    this.imageLink,
    this.visibleIf,
    this.score,
  });

  // ─── Display ──────────────────────────────────────────────────────────────

  /// The label to show in the UI.
  /// Returns [text] when set, otherwise falls back to [value].
  String get label => (text != null && text!.isNotEmpty) ? text! : value;

  // ─── Serialisation ────────────────────────────────────────────────────────

  /// Parses a single choice entry from SurveyJS JSON.
  ///
  /// Accepts:
  /// - `String`            → `SurveyChoice(value: "Yes", text: "Yes")`
  /// - `Map<String, dynamic>` → full object form
  /// - Anything else       → `.toString()` used as value
  factory SurveyChoice.fromJson(dynamic json) {
    if (json is String) {
      return SurveyChoice(value: json, text: json);
    }

    if (json is Map<String, dynamic>) {
      return SurveyChoice(
        value: json['value']?.toString() ?? '',
        text: json['text'] as String?,
        imageLink: json['imageLink'] as String?,
        visibleIf: json['visibleIf'] as String?,
        score: json['score'] as num?,
      );
    }

    // Fallback for unexpected types (num, bool…)
    final str = json.toString();
    return SurveyChoice(value: str, text: str);
  }

  /// Serialises back to the SurveyJS object format.
  Map<String, dynamic> toJson() => {
        'value': value,
        if (text != null && text != value) 'text': text,
        if (imageLink != null) 'imageLink': imageLink,
        if (visibleIf != null) 'visibleIf': visibleIf,
        if (score != null) 'score': score,
      };

  // ─── Utility ──────────────────────────────────────────────────────────────

  SurveyChoice copyWith({
    String? value,
    String? text,
    String? imageLink,
    String? visibleIf,
    num? score,
  }) {
    return SurveyChoice(
      value: value ?? this.value,
      text: text ?? this.text,
      imageLink: imageLink ?? this.imageLink,
      visibleIf: visibleIf ?? this.visibleIf,
      score: score ?? this.score,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SurveyChoice &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'SurveyChoice(value: $value, label: $label)';
}
