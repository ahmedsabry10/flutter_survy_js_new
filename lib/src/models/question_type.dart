enum QuestionType {
  text,
  comment,
  radiogroup,
  checkbox,
  dropdown,
  tagbox,
  rating,
  boolean,
  matrix,
  matrixdropdown,
  matrixdynamic,
  multipletext,
  panel,
  paneldynamic,
  html,
  image,
  imagepicker,
  ranking,
  signaturepad,
  expression,
  file,

  /// QR / Barcode scanner  →  JSON type: "qr-barcode"
  qrcode,

  /// Hijri date picker  →  JSON type: "custom-date"
  hijridate,

  empty,
  unknown;

  static QuestionType fromString(String value) {
    final normalised = value.trim().toLowerCase();

    // ── Custom type aliases (hyphenated names from the server) ──────────────
    if (normalised == 'qr-barcode') return QuestionType.qrcode;
    if (normalised == 'custom-date') return QuestionType.hijridate;

    // ── Standard lookup ─────────────────────────────────────────────────────
    return QuestionType.values.firstWhere(
      (e) => e.name == normalised,
      orElse: () => QuestionType.unknown,
    );
  }

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
        QuestionType.qrcode,
        QuestionType.hijridate,
      }.contains(this);

  bool get isMultiAnswer => const {
        QuestionType.checkbox,
        QuestionType.ranking,
        QuestionType.imagepicker,
      }.contains(this);

  bool get isComplexAnswer => const {
        QuestionType.matrix,
        QuestionType.matrixdropdown,
        QuestionType.matrixdynamic,
        QuestionType.multipletext,
        QuestionType.paneldynamic,
      }.contains(this);

  bool get isDisplayOnly => const {
        QuestionType.html,
        QuestionType.image,
        QuestionType.empty,
      }.contains(this);

  bool get isContainer => const {
        QuestionType.panel,
        QuestionType.paneldynamic,
      }.contains(this);

  bool get hasChoices => const {
        QuestionType.radiogroup,
        QuestionType.checkbox,
        QuestionType.dropdown,
        QuestionType.tagbox,
        QuestionType.imagepicker,
        QuestionType.ranking,
      }.contains(this);
}
