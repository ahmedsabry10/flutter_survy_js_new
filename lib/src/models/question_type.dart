/// All supported SurveyJS question types.
///
/// Each variant maps 1-to-1 with the `type` field in SurveyJS JSON.
/// Use [QuestionType.fromString] to parse the raw JSON string safely.
enum QuestionType {
  /// Single-line text input. Supports inputType: email | number | date | tel | url | password
  text,

  /// Multi-line text area (long answers)
  comment,

  /// Single-select list of choices rendered as radio buttons
  radiogroup,

  /// Multi-select list of choices rendered as checkboxes
  checkbox,

  /// Single-select rendered as a native dropdown / select
  dropdown,

  /// Multi-select rendered as a searchable tag input (like a multi-select dropdown)
  tagbox,

  /// Numeric rating scale — supports stars, smileys, or number buttons
  rating,

  /// Yes / No toggle (renders as an animated switch)
  boolean,

  /// Single-select grid: rows × columns, one answer per row
  matrix,

  /// Multi-column grid: rows × columns, each cell is a dropdown
  matrixdropdown,

  /// Dynamic rows matrix — user can add/remove rows at runtime
  matrixdynamic,

  /// Group of labelled text inputs rendered inline
  multipletext,

  /// Static container that groups other questions together
  panel,

  /// Dynamic panel — user can add/remove repeated groups of questions
  paneldynamic,

  /// Static HTML content block (no answer collected)
  html,

  /// Displays a static image (no answer collected)
  image,

  /// Image-based choice picker (like radiogroup but with pictures)
  imagepicker,

  /// Drag-and-drop ranking of choices
  ranking,

  /// Freehand signature capture pad
  signaturepad,

  /// Computed / read-only expression field
  expression,

  /// File upload input
  file,

  /// Invisible placeholder question (no widget rendered)
  empty,

  /// Fallback for unrecognised / future question types
  unknown;

  // ─── Factory ──────────────────────────────────────────────────────────────

  /// Parses the `type` string from SurveyJS JSON.
  /// Returns [QuestionType.unknown] for unrecognised values instead of throwing.
  static QuestionType fromString(String value) {
    final normalised = value.trim().toLowerCase();
    return QuestionType.values.firstWhere(
      (e) => e.name == normalised,
      orElse: () => QuestionType.unknown,
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  /// True for types that collect a single scalar answer (String / num / bool).
  bool get isSingleAnswer => const {
        QuestionType.text,
        QuestionType.comment,
        QuestionType.radiogroup,
        QuestionType.dropdown,
        QuestionType.tagbox,
        QuestionType.rating,
        QuestionType.boolean,
        QuestionType.expression,
        QuestionType.signaturepad,
      }.contains(this);

  /// True for types that collect a List answer.
  bool get isMultiAnswer => const {
        QuestionType.checkbox,
        QuestionType.ranking,
        QuestionType.imagepicker,
      }.contains(this);

  /// True for types that collect a Map answer (matrix, multipletext, paneldynamic…).
  bool get isComplexAnswer => const {
        QuestionType.matrix,
        QuestionType.matrixdropdown,
        QuestionType.matrixdynamic,
        QuestionType.multipletext,
        QuestionType.paneldynamic,
      }.contains(this);

  /// True for display-only types (no answer collected).
  bool get isDisplayOnly => const {
        QuestionType.html,
        QuestionType.image,
        QuestionType.empty,
      }.contains(this);

  /// True for container types that hold child questions.
  bool get isContainer => const {
        QuestionType.panel,
        QuestionType.paneldynamic,
      }.contains(this);

  /// True for types that show a list of [SurveyChoice] items.
  bool get hasChoices => const {
        QuestionType.radiogroup,
        QuestionType.checkbox,
        QuestionType.dropdown,
        QuestionType.tagbox,
        QuestionType.imagepicker,
        QuestionType.ranking,
      }.contains(this);
}
