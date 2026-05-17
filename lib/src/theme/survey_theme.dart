import 'package:flutter/material.dart';

/// The main theming class for flutter_survey_js.
///
/// Use the named constructors to apply a theme matching one of the
/// built-in SurveyJS web themes:
///
/// ```dart
/// SurveyWidget(
///   survey: survey,
///   theme: SurveyTheme.sharp(),          // Sharp Light
///   theme: SurveyTheme.sharpDark(),      // Sharp Dark
///   theme: SurveyTheme.layered(),        // Layered Light
///   theme: SurveyTheme.layeredDark(),    // Layered Dark
///   theme: SurveyTheme.contrast(),       // Contrast Light
///   theme: SurveyTheme.contrastDark(),   // Contrast Dark
///   theme: SurveyTheme.plain(),          // Plain Light
///   theme: SurveyTheme.plainDark(),      // Plain Dark
///   theme: SurveyTheme.doubleBorder(),   // DoubleBorder Light
///   theme: SurveyTheme.doubleBorderDark(), // DoubleBorder Dark
///   theme: SurveyTheme.fromBrightness(context), // auto-detect
/// )
/// ```
class SurveyTheme {
  // ─── Colors ───────────────────────────────────────────────────────────────
  final Color primaryColor;
  final Color backgroundColor;
  final Color questionBackgroundColor;
  final Color borderColor;
  final Color focusBorderColor;
  final Color errorColor;
  final Color textColor;
  final Color titleColor;
  final Color hintColor;
  final Color disabledColor;
  final Color ratingSelectedColor;
  final Color ratingUnselectedColor;
  final Color progressBarColor;

  // ─── Typography ───────────────────────────────────────────────────────────
  final TextStyle surveyTitleStyle;
  final TextStyle surveyDescriptionStyle;
  final TextStyle questionTitleStyle;
  final TextStyle questionDescriptionStyle;
  final TextStyle inputTextStyle;
  final TextStyle errorTextStyle;
  final TextStyle choiceLabelStyle;
  final TextStyle buttonTextStyle;

  // ─── Shape & Spacing ──────────────────────────────────────────────────────
  final BorderRadius inputBorderRadius;
  final BorderRadius cardBorderRadius;
  final BorderRadius buttonBorderRadius;
  final double questionSpacing;
  final double cardPadding;
  final EdgeInsets inputPadding;

  // ─── Buttons ──────────────────────────────────────────────────────────────
  final Color nextButtonColor;
  final Color prevButtonColor;
  final Color submitButtonColor;

  // ─── Card decoration extras (used by DoubleBorder) ────────────────────────
  final Border? cardBorder;
  final List<BoxShadow>? cardShadow;

  const SurveyTheme({
    this.primaryColor = const Color(0xFF19B394),
    this.backgroundColor = const Color(0xFFF3F3F3),
    this.questionBackgroundColor = Colors.white,
    this.borderColor = const Color(0xFFE0E0E0),
    this.focusBorderColor = const Color(0xFF19B394),
    this.errorColor = const Color(0xFFE60A3E),
    this.textColor = const Color(0xFF161616),
    this.titleColor = const Color(0xFF161616),
    this.hintColor = const Color(0xFF909090),
    this.disabledColor = const Color(0xFFD0D0D0),
    this.ratingSelectedColor = const Color(0xFF19B394),
    this.ratingUnselectedColor = const Color(0xFFE0E0E0),
    this.progressBarColor = const Color(0xFF19B394),
    this.surveyTitleStyle = const TextStyle(
        fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF161616)),
    this.surveyDescriptionStyle = const TextStyle(
        fontSize: 15, color: Color(0xFF516270), height: 1.5),
    this.questionTitleStyle = const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF161616),
        height: 1.4),
    this.questionDescriptionStyle = const TextStyle(
        fontSize: 13, color: Color(0xFF516270), height: 1.4),
    this.inputTextStyle =
        const TextStyle(fontSize: 15, color: Color(0xFF161616)),
    this.errorTextStyle =
        const TextStyle(fontSize: 12, color: Color(0xFFE60A3E)),
    this.choiceLabelStyle =
        const TextStyle(fontSize: 15, color: Color(0xFF161616)),
    this.buttonTextStyle = const TextStyle(
        fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
    this.inputBorderRadius = const BorderRadius.all(Radius.circular(4)),
    this.cardBorderRadius = const BorderRadius.all(Radius.circular(4)),
    this.buttonBorderRadius = const BorderRadius.all(Radius.circular(4)),
    this.questionSpacing = 16,
    this.cardPadding = 20,
    this.inputPadding =
        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    this.nextButtonColor = const Color(0xFF19B394),
    this.prevButtonColor = const Color(0xFF909090),
    this.submitButtonColor = const Color(0xFF19B394),
    this.cardBorder,
    this.cardShadow,
  });

  // ══════════════════════════════════════════════════════════════════════════
  // Built-in named themes  (mirrors the SurveyJS web theme catalogue)
  // ══════════════════════════════════════════════════════════════════════════

  // ─── Default ──────────────────────────────────────────────────────────────

  factory SurveyTheme.defaultLight({
    Color primaryColor = const Color(0xFF19B394),
  }) =>
      SurveyTheme(
        primaryColor: primaryColor,
        backgroundColor: const Color(0xFFF3F3F3),
        questionBackgroundColor: Colors.white,
        borderColor: const Color(0xFFE0E0E0),
        focusBorderColor: primaryColor,
        errorColor: const Color(0xFFE60A3E),
        textColor: const Color(0xFF161616),
        titleColor: const Color(0xFF161616),
        hintColor: const Color(0xFF909090),
        disabledColor: const Color(0xFFD0D0D0),
        ratingSelectedColor: primaryColor,
        ratingUnselectedColor: const Color(0xFFE0E0E0),
        progressBarColor: primaryColor,
        surveyTitleStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF161616)),
        surveyDescriptionStyle: const TextStyle(fontSize: 15, color: Color(0xFF516270), height: 1.5),
        questionTitleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF161616), height: 1.4),
        questionDescriptionStyle: const TextStyle(fontSize: 13, color: Color(0xFF516270), height: 1.4),
        inputTextStyle: const TextStyle(fontSize: 15, color: Color(0xFF161616)),
        errorTextStyle: const TextStyle(fontSize: 12, color: Color(0xFFE60A3E)),
        choiceLabelStyle: const TextStyle(fontSize: 15, color: Color(0xFF161616)),
        buttonTextStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
        inputBorderRadius: const BorderRadius.all(Radius.circular(4)),
        cardBorderRadius: const BorderRadius.all(Radius.circular(4)),
        buttonBorderRadius: const BorderRadius.all(Radius.circular(4)),
        nextButtonColor: primaryColor,
        prevButtonColor: const Color(0xFF909090),
        submitButtonColor: primaryColor,
      );

  factory SurveyTheme.defaultDark({
    Color primaryColor = const Color(0xFF19B394),
  }) =>
      SurveyTheme(
        primaryColor: primaryColor,
        backgroundColor: const Color(0xFF1C1C1C),
        questionBackgroundColor: const Color(0xFF2B2B2B),
        borderColor: const Color(0xFF3D3D3D),
        focusBorderColor: primaryColor,
        errorColor: const Color(0xFFFF6771),
        textColor: const Color(0xFFE0E0E0),
        titleColor: const Color(0xFFFFFFFF),
        hintColor: const Color(0xFF6E7273),
        disabledColor: const Color(0xFF444444),
        ratingSelectedColor: primaryColor,
        ratingUnselectedColor: const Color(0xFF3D3D3D),
        progressBarColor: primaryColor,
        surveyTitleStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        surveyDescriptionStyle: const TextStyle(fontSize: 15, color: Color(0xFF9DA1A1), height: 1.5),
        questionTitleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white, height: 1.4),
        questionDescriptionStyle: const TextStyle(fontSize: 13, color: Color(0xFF9DA1A1), height: 1.4),
        inputTextStyle: const TextStyle(fontSize: 15, color: Color(0xFFE0E0E0)),
        errorTextStyle: const TextStyle(fontSize: 12, color: Color(0xFFFF6771)),
        choiceLabelStyle: const TextStyle(fontSize: 15, color: Color(0xFFE0E0E0)),
        buttonTextStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
        inputBorderRadius: const BorderRadius.all(Radius.circular(4)),
        cardBorderRadius: const BorderRadius.all(Radius.circular(4)),
        buttonBorderRadius: const BorderRadius.all(Radius.circular(4)),
        nextButtonColor: primaryColor,
        prevButtonColor: const Color(0xFF444444),
        submitButtonColor: primaryColor,
      );

  // ─── Sharp ────────────────────────────────────────────────────────────────
  // Square corners, very minimal, no card shadows.

  factory SurveyTheme.sharp({
    Color primaryColor = const Color(0xFF19B394),
  }) =>
      SurveyTheme(
        primaryColor: primaryColor,
        backgroundColor: const Color(0xFFEDEDED),
        questionBackgroundColor: Colors.white,
        borderColor: const Color(0xFFD6D6D6),
        focusBorderColor: primaryColor,
        errorColor: const Color(0xFFE60A3E),
        textColor: const Color(0xFF161616),
        titleColor: const Color(0xFF161616),
        hintColor: const Color(0xFF8C8C8C),
        disabledColor: const Color(0xFFCCCCCC),
        ratingSelectedColor: primaryColor,
        ratingUnselectedColor: const Color(0xFFD6D6D6),
        progressBarColor: primaryColor,
        surveyTitleStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF161616)),
        surveyDescriptionStyle: const TextStyle(fontSize: 15, color: Color(0xFF516270), height: 1.5),
        questionTitleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF161616), height: 1.4),
        questionDescriptionStyle: const TextStyle(fontSize: 13, color: Color(0xFF516270), height: 1.4),
        inputTextStyle: const TextStyle(fontSize: 15, color: Color(0xFF161616)),
        errorTextStyle: const TextStyle(fontSize: 12, color: Color(0xFFE60A3E)),
        choiceLabelStyle: const TextStyle(fontSize: 15, color: Color(0xFF161616)),
        buttonTextStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
        // Sharp → zero radius everywhere
        inputBorderRadius: BorderRadius.zero,
        cardBorderRadius: BorderRadius.zero,
        buttonBorderRadius: BorderRadius.zero,
        nextButtonColor: primaryColor,
        prevButtonColor: const Color(0xFF8C8C8C),
        submitButtonColor: primaryColor,
      );

  factory SurveyTheme.sharpDark({
    Color primaryColor = const Color(0xFF19B394),
  }) =>
      SurveyTheme(
        primaryColor: primaryColor,
        backgroundColor: const Color(0xFF1A1A1A),
        questionBackgroundColor: const Color(0xFF252525),
        borderColor: const Color(0xFF383838),
        focusBorderColor: primaryColor,
        errorColor: const Color(0xFFFF6771),
        textColor: const Color(0xFFE0E0E0),
        titleColor: Colors.white,
        hintColor: const Color(0xFF6E7273),
        disabledColor: const Color(0xFF383838),
        ratingSelectedColor: primaryColor,
        ratingUnselectedColor: const Color(0xFF383838),
        progressBarColor: primaryColor,
        surveyTitleStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        surveyDescriptionStyle: const TextStyle(fontSize: 15, color: Color(0xFF9DA1A1), height: 1.5),
        questionTitleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white, height: 1.4),
        questionDescriptionStyle: const TextStyle(fontSize: 13, color: Color(0xFF9DA1A1), height: 1.4),
        inputTextStyle: const TextStyle(fontSize: 15, color: Color(0xFFE0E0E0)),
        errorTextStyle: const TextStyle(fontSize: 12, color: Color(0xFFFF6771)),
        choiceLabelStyle: const TextStyle(fontSize: 15, color: Color(0xFFE0E0E0)),
        buttonTextStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
        inputBorderRadius: BorderRadius.zero,
        cardBorderRadius: BorderRadius.zero,
        buttonBorderRadius: BorderRadius.zero,
        nextButtonColor: primaryColor,
        prevButtonColor: const Color(0xFF383838),
        submitButtonColor: primaryColor,
      );

  // ─── Layered ──────────────────────────────────────────────────────────────
  // Panelless (no card background), questions sit directly on the page bg.

  factory SurveyTheme.layered({
    Color primaryColor = const Color(0xFF19B394),
  }) =>
      SurveyTheme(
        primaryColor: primaryColor,
        backgroundColor: const Color(0xFFF9F9F9),
        // panelless → question bg = page bg
        questionBackgroundColor: const Color(0xFFF9F9F9),
        borderColor: const Color(0xFFD6D6D6),
        focusBorderColor: primaryColor,
        errorColor: const Color(0xFFE60A3E),
        textColor: const Color(0xFF161616),
        titleColor: const Color(0xFF161616),
        hintColor: const Color(0xFF8C8C8C),
        disabledColor: const Color(0xFFCCCCCC),
        ratingSelectedColor: primaryColor,
        ratingUnselectedColor: const Color(0xFFD6D6D6),
        progressBarColor: primaryColor,
        surveyTitleStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF161616)),
        surveyDescriptionStyle: const TextStyle(fontSize: 15, color: Color(0xFF516270), height: 1.5),
        questionTitleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF161616), height: 1.4),
        questionDescriptionStyle: const TextStyle(fontSize: 13, color: Color(0xFF516270), height: 1.4),
        inputTextStyle: const TextStyle(fontSize: 15, color: Color(0xFF161616)),
        errorTextStyle: const TextStyle(fontSize: 12, color: Color(0xFFE60A3E)),
        choiceLabelStyle: const TextStyle(fontSize: 15, color: Color(0xFF161616)),
        buttonTextStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
        inputBorderRadius: const BorderRadius.all(Radius.circular(4)),
        cardBorderRadius: const BorderRadius.all(Radius.circular(4)),
        buttonBorderRadius: const BorderRadius.all(Radius.circular(4)),
        nextButtonColor: primaryColor,
        prevButtonColor: const Color(0xFF8C8C8C),
        submitButtonColor: primaryColor,
        // no card border (panelless)
        cardBorder: const Border(),
      );

  factory SurveyTheme.layeredDark({
    Color primaryColor = const Color(0xFF19B394),
  }) =>
      SurveyTheme(
        primaryColor: primaryColor,
        backgroundColor: const Color(0xFF1C1C1C),
        questionBackgroundColor: const Color(0xFF1C1C1C),
        borderColor: const Color(0xFF3D3D3D),
        focusBorderColor: primaryColor,
        errorColor: const Color(0xFFFF6771),
        textColor: const Color(0xFFE0E0E0),
        titleColor: Colors.white,
        hintColor: const Color(0xFF6E7273),
        disabledColor: const Color(0xFF444444),
        ratingSelectedColor: primaryColor,
        ratingUnselectedColor: const Color(0xFF3D3D3D),
        progressBarColor: primaryColor,
        surveyTitleStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        surveyDescriptionStyle: const TextStyle(fontSize: 15, color: Color(0xFF9DA1A1), height: 1.5),
        questionTitleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white, height: 1.4),
        questionDescriptionStyle: const TextStyle(fontSize: 13, color: Color(0xFF9DA1A1), height: 1.4),
        inputTextStyle: const TextStyle(fontSize: 15, color: Color(0xFFE0E0E0)),
        errorTextStyle: const TextStyle(fontSize: 12, color: Color(0xFFFF6771)),
        choiceLabelStyle: const TextStyle(fontSize: 15, color: Color(0xFFE0E0E0)),
        buttonTextStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
        inputBorderRadius: const BorderRadius.all(Radius.circular(4)),
        cardBorderRadius: const BorderRadius.all(Radius.circular(4)),
        buttonBorderRadius: const BorderRadius.all(Radius.circular(4)),
        nextButtonColor: primaryColor,
        prevButtonColor: const Color(0xFF444444),
        submitButtonColor: primaryColor,
        cardBorder: const Border(),
      );

  // ─── Contrast ─────────────────────────────────────────────────────────────
  // High contrast, darker borders, stronger text.

  factory SurveyTheme.contrast({
    Color primaryColor = const Color(0xFF19B394),
  }) =>
      SurveyTheme(
        primaryColor: primaryColor,
        backgroundColor: const Color(0xFFFFFFFF),
        questionBackgroundColor: const Color(0xFFFFFFFF),
        borderColor: const Color(0xFF161616),
        focusBorderColor: primaryColor,
        errorColor: const Color(0xFFE60A3E),
        textColor: const Color(0xFF161616),
        titleColor: const Color(0xFF161616),
        hintColor: const Color(0xFF516270),
        disabledColor: const Color(0xFFB0B0B0),
        ratingSelectedColor: primaryColor,
        ratingUnselectedColor: const Color(0xFF161616),
        progressBarColor: primaryColor,
        surveyTitleStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF161616)),
        surveyDescriptionStyle: const TextStyle(fontSize: 15, color: Color(0xFF516270), height: 1.5),
        questionTitleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF161616), height: 1.4),
        questionDescriptionStyle: const TextStyle(fontSize: 13, color: Color(0xFF516270), height: 1.4),
        inputTextStyle: const TextStyle(fontSize: 15, color: Color(0xFF161616)),
        errorTextStyle: const TextStyle(fontSize: 12, color: Color(0xFFE60A3E)),
        choiceLabelStyle: const TextStyle(fontSize: 15, color: Color(0xFF161616)),
        buttonTextStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
        inputBorderRadius: const BorderRadius.all(Radius.circular(4)),
        cardBorderRadius: const BorderRadius.all(Radius.circular(4)),
        buttonBorderRadius: const BorderRadius.all(Radius.circular(4)),
        nextButtonColor: primaryColor,
        prevButtonColor: const Color(0xFF516270),
        submitButtonColor: primaryColor,
        cardBorder: Border.all(color: const Color(0xFF161616), width: 1.5),
      );

  factory SurveyTheme.contrastDark({
    Color primaryColor = const Color(0xFF19B394),
  }) =>
      SurveyTheme(
        primaryColor: primaryColor,
        backgroundColor: const Color(0xFF000000),
        questionBackgroundColor: const Color(0xFF000000),
        borderColor: const Color(0xFFFFFFFF),
        focusBorderColor: primaryColor,
        errorColor: const Color(0xFFFF6771),
        textColor: const Color(0xFFFFFFFF),
        titleColor: const Color(0xFFFFFFFF),
        hintColor: const Color(0xFF9DA1A1),
        disabledColor: const Color(0xFF444444),
        ratingSelectedColor: primaryColor,
        ratingUnselectedColor: const Color(0xFFFFFFFF),
        progressBarColor: primaryColor,
        surveyTitleStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        surveyDescriptionStyle: const TextStyle(fontSize: 15, color: Color(0xFF9DA1A1), height: 1.5),
        questionTitleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white, height: 1.4),
        questionDescriptionStyle: const TextStyle(fontSize: 13, color: Color(0xFF9DA1A1), height: 1.4),
        inputTextStyle: const TextStyle(fontSize: 15, color: Colors.white),
        errorTextStyle: const TextStyle(fontSize: 12, color: Color(0xFFFF6771)),
        choiceLabelStyle: const TextStyle(fontSize: 15, color: Colors.white),
        buttonTextStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black),
        inputBorderRadius: const BorderRadius.all(Radius.circular(4)),
        cardBorderRadius: const BorderRadius.all(Radius.circular(4)),
        buttonBorderRadius: const BorderRadius.all(Radius.circular(4)),
        nextButtonColor: primaryColor,
        prevButtonColor: const Color(0xFF444444),
        submitButtonColor: primaryColor,
        cardBorder: Border.all(color: Colors.white, width: 1.5),
      );

  // ─── Plain ────────────────────────────────────────────────────────────────
  // Clean, flat, no heavy borders, subtle separators.

  factory SurveyTheme.plain({
    Color primaryColor = const Color(0xFF19B394),
  }) =>
      SurveyTheme(
        primaryColor: primaryColor,
        backgroundColor: const Color(0xFFFFFFFF),
        questionBackgroundColor: const Color(0xFFFFFFFF),
        borderColor: const Color(0xFFEAEAEA),
        focusBorderColor: primaryColor,
        errorColor: const Color(0xFFE60A3E),
        textColor: const Color(0xFF161616),
        titleColor: const Color(0xFF161616),
        hintColor: const Color(0xFFAAAAAA),
        disabledColor: const Color(0xFFE0E0E0),
        ratingSelectedColor: primaryColor,
        ratingUnselectedColor: const Color(0xFFEAEAEA),
        progressBarColor: primaryColor,
        surveyTitleStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Color(0xFF161616)),
        surveyDescriptionStyle: const TextStyle(fontSize: 15, color: Color(0xFF6E7273), height: 1.5),
        questionTitleStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF161616), height: 1.4),
        questionDescriptionStyle: const TextStyle(fontSize: 13, color: Color(0xFF6E7273), height: 1.4),
        inputTextStyle: const TextStyle(fontSize: 15, color: Color(0xFF161616)),
        errorTextStyle: const TextStyle(fontSize: 12, color: Color(0xFFE60A3E)),
        choiceLabelStyle: const TextStyle(fontSize: 15, color: Color(0xFF161616)),
        buttonTextStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
        inputBorderRadius: const BorderRadius.all(Radius.circular(6)),
        cardBorderRadius: const BorderRadius.all(Radius.circular(6)),
        buttonBorderRadius: const BorderRadius.all(Radius.circular(6)),
        nextButtonColor: primaryColor,
        prevButtonColor: const Color(0xFFAAAAAA),
        submitButtonColor: primaryColor,
        cardBorder: Border.all(color: const Color(0xFFEAEAEA)),
      );

  factory SurveyTheme.plainDark({
    Color primaryColor = const Color(0xFF19B394),
  }) =>
      SurveyTheme(
        primaryColor: primaryColor,
        backgroundColor: const Color(0xFF1A1A1A),
        questionBackgroundColor: const Color(0xFF242424),
        borderColor: const Color(0xFF363636),
        focusBorderColor: primaryColor,
        errorColor: const Color(0xFFFF6771),
        textColor: const Color(0xFFE0E0E0),
        titleColor: Colors.white,
        hintColor: const Color(0xFF6E7273),
        disabledColor: const Color(0xFF363636),
        ratingSelectedColor: primaryColor,
        ratingUnselectedColor: const Color(0xFF363636),
        progressBarColor: primaryColor,
        surveyTitleStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.white),
        surveyDescriptionStyle: const TextStyle(fontSize: 15, color: Color(0xFF9DA1A1), height: 1.5),
        questionTitleStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white, height: 1.4),
        questionDescriptionStyle: const TextStyle(fontSize: 13, color: Color(0xFF9DA1A1), height: 1.4),
        inputTextStyle: const TextStyle(fontSize: 15, color: Color(0xFFE0E0E0)),
        errorTextStyle: const TextStyle(fontSize: 12, color: Color(0xFFFF6771)),
        choiceLabelStyle: const TextStyle(fontSize: 15, color: Color(0xFFE0E0E0)),
        buttonTextStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
        inputBorderRadius: const BorderRadius.all(Radius.circular(6)),
        cardBorderRadius: const BorderRadius.all(Radius.circular(6)),
        buttonBorderRadius: const BorderRadius.all(Radius.circular(6)),
        nextButtonColor: primaryColor,
        prevButtonColor: const Color(0xFF444444),
        submitButtonColor: primaryColor,
        cardBorder: Border.all(color: const Color(0xFF363636)),
      );

  // ─── DoubleBorder ─────────────────────────────────────────────────────────
  // Cards have a visible shadow + double-border feeling via BoxShadow.

  factory SurveyTheme.doubleBorder({
    Color primaryColor = const Color(0xFF19B394),
  }) =>
      SurveyTheme(
        primaryColor: primaryColor,
        backgroundColor: const Color(0xFFF3F3F3),
        questionBackgroundColor: Colors.white,
        borderColor: const Color(0xFFE0E0E0),
        focusBorderColor: primaryColor,
        errorColor: const Color(0xFFE60A3E),
        textColor: const Color(0xFF161616),
        titleColor: const Color(0xFF161616),
        hintColor: const Color(0xFF909090),
        disabledColor: const Color(0xFFD0D0D0),
        ratingSelectedColor: primaryColor,
        ratingUnselectedColor: const Color(0xFFE0E0E0),
        progressBarColor: primaryColor,
        surveyTitleStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF161616)),
        surveyDescriptionStyle: const TextStyle(fontSize: 15, color: Color(0xFF516270), height: 1.5),
        questionTitleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF161616), height: 1.4),
        questionDescriptionStyle: const TextStyle(fontSize: 13, color: Color(0xFF516270), height: 1.4),
        inputTextStyle: const TextStyle(fontSize: 15, color: Color(0xFF161616)),
        errorTextStyle: const TextStyle(fontSize: 12, color: Color(0xFFE60A3E)),
        choiceLabelStyle: const TextStyle(fontSize: 15, color: Color(0xFF161616)),
        buttonTextStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
        inputBorderRadius: const BorderRadius.all(Radius.circular(4)),
        cardBorderRadius: const BorderRadius.all(Radius.circular(4)),
        buttonBorderRadius: const BorderRadius.all(Radius.circular(4)),
        nextButtonColor: primaryColor,
        prevButtonColor: const Color(0xFF909090),
        submitButtonColor: primaryColor,
        cardBorder: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        cardShadow: const [
          BoxShadow(color: Color(0xFFE0E0E0), offset: Offset(4, 4), blurRadius: 0, spreadRadius: 0),
        ],
      );

  factory SurveyTheme.doubleBorderDark({
    Color primaryColor = const Color(0xFF19B394),
  }) =>
      SurveyTheme(
        primaryColor: primaryColor,
        backgroundColor: const Color(0xFF1C1C1C),
        questionBackgroundColor: const Color(0xFF2B2B2B),
        borderColor: const Color(0xFF3D3D3D),
        focusBorderColor: primaryColor,
        errorColor: const Color(0xFFFF6771),
        textColor: const Color(0xFFE0E0E0),
        titleColor: Colors.white,
        hintColor: const Color(0xFF6E7273),
        disabledColor: const Color(0xFF444444),
        ratingSelectedColor: primaryColor,
        ratingUnselectedColor: const Color(0xFF3D3D3D),
        progressBarColor: primaryColor,
        surveyTitleStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        surveyDescriptionStyle: const TextStyle(fontSize: 15, color: Color(0xFF9DA1A1), height: 1.5),
        questionTitleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white, height: 1.4),
        questionDescriptionStyle: const TextStyle(fontSize: 13, color: Color(0xFF9DA1A1), height: 1.4),
        inputTextStyle: const TextStyle(fontSize: 15, color: Color(0xFFE0E0E0)),
        errorTextStyle: const TextStyle(fontSize: 12, color: Color(0xFFFF6771)),
        choiceLabelStyle: const TextStyle(fontSize: 15, color: Color(0xFFE0E0E0)),
        buttonTextStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
        inputBorderRadius: const BorderRadius.all(Radius.circular(4)),
        cardBorderRadius: const BorderRadius.all(Radius.circular(4)),
        buttonBorderRadius: const BorderRadius.all(Radius.circular(4)),
        nextButtonColor: primaryColor,
        prevButtonColor: const Color(0xFF444444),
        submitButtonColor: primaryColor,
        cardBorder: Border.all(color: const Color(0xFF3D3D3D), width: 1),
        cardShadow: const [
          BoxShadow(color: Color(0xFF111111), offset: Offset(4, 4), blurRadius: 0, spreadRadius: 0),
        ],
      );

  // ──────────────────────────────────────────────────────────────────────────
  // Utility factories
  // ──────────────────────────────────────────────────────────────────────────

  /// Convenience aliases — match SurveyJS web naming exactly.
  factory SurveyTheme.light({Color primaryColor = const Color(0xFF19B394)}) =>
      SurveyTheme.defaultLight(primaryColor: primaryColor);

  factory SurveyTheme.dark({Color primaryColor = const Color(0xFF19B394)}) =>
      SurveyTheme.defaultDark(primaryColor: primaryColor);

  /// Auto-detects brightness from [MaterialApp.themeMode].
  factory SurveyTheme.fromBrightness(
    BuildContext context, {
    Color primaryColor = const Color(0xFF19B394),
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? SurveyTheme.defaultDark(primaryColor: primaryColor)
        : SurveyTheme.defaultLight(primaryColor: primaryColor);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // InheritedWidget access
  // ──────────────────────────────────────────────────────────────────────────

  /// Returns the nearest [SurveyTheme] from a [SurveyThemeProvider],
  /// or falls back to auto-detecting the brightness.
  static SurveyTheme of(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<SurveyThemeInherited>();
    return inherited?.theme ?? SurveyTheme.fromBrightness(context);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // copyWith
  // ──────────────────────────────────────────────────────────────────────────

  SurveyTheme copyWith({
    Color? primaryColor,
    Color? backgroundColor,
    Color? questionBackgroundColor,
    Color? borderColor,
    Color? focusBorderColor,
    Color? errorColor,
    Color? textColor,
    Color? titleColor,
    Color? hintColor,
    Color? disabledColor,
    Color? ratingSelectedColor,
    Color? ratingUnselectedColor,
    Color? progressBarColor,
    Color? nextButtonColor,
    Color? prevButtonColor,
    Color? submitButtonColor,
    TextStyle? surveyTitleStyle,
    TextStyle? surveyDescriptionStyle,
    TextStyle? questionTitleStyle,
    TextStyle? questionDescriptionStyle,
    TextStyle? inputTextStyle,
    TextStyle? errorTextStyle,
    TextStyle? choiceLabelStyle,
    TextStyle? buttonTextStyle,
    double? questionSpacing,
    double? cardPadding,
    EdgeInsets? inputPadding,
    BorderRadius? inputBorderRadius,
    BorderRadius? cardBorderRadius,
    BorderRadius? buttonBorderRadius,
    Border? cardBorder,
    List<BoxShadow>? cardShadow,
  }) {
    return SurveyTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      questionBackgroundColor: questionBackgroundColor ?? this.questionBackgroundColor,
      borderColor: borderColor ?? this.borderColor,
      focusBorderColor: focusBorderColor ?? this.focusBorderColor,
      errorColor: errorColor ?? this.errorColor,
      textColor: textColor ?? this.textColor,
      titleColor: titleColor ?? this.titleColor,
      hintColor: hintColor ?? this.hintColor,
      disabledColor: disabledColor ?? this.disabledColor,
      ratingSelectedColor: ratingSelectedColor ?? this.ratingSelectedColor,
      ratingUnselectedColor: ratingUnselectedColor ?? this.ratingUnselectedColor,
      progressBarColor: progressBarColor ?? this.progressBarColor,
      nextButtonColor: nextButtonColor ?? this.nextButtonColor,
      prevButtonColor: prevButtonColor ?? this.prevButtonColor,
      submitButtonColor: submitButtonColor ?? this.submitButtonColor,
      surveyTitleStyle: surveyTitleStyle ?? this.surveyTitleStyle,
      surveyDescriptionStyle: surveyDescriptionStyle ?? this.surveyDescriptionStyle,
      questionTitleStyle: questionTitleStyle ?? this.questionTitleStyle,
      questionDescriptionStyle: questionDescriptionStyle ?? this.questionDescriptionStyle,
      inputTextStyle: inputTextStyle ?? this.inputTextStyle,
      errorTextStyle: errorTextStyle ?? this.errorTextStyle,
      choiceLabelStyle: choiceLabelStyle ?? this.choiceLabelStyle,
      buttonTextStyle: buttonTextStyle ?? this.buttonTextStyle,
      questionSpacing: questionSpacing ?? this.questionSpacing,
      cardPadding: cardPadding ?? this.cardPadding,
      inputPadding: inputPadding ?? this.inputPadding,
      inputBorderRadius: inputBorderRadius ?? this.inputBorderRadius,
      cardBorderRadius: cardBorderRadius ?? this.cardBorderRadius,
      buttonBorderRadius: buttonBorderRadius ?? this.buttonBorderRadius,
      cardBorder: cardBorder ?? this.cardBorder,
      cardShadow: cardShadow ?? this.cardShadow,
    );
  }
}

// ─── InheritedWidget ──────────────────────────────────────────────────────────

class SurveyThemeInherited extends InheritedWidget {
  final SurveyTheme theme;
  const SurveyThemeInherited({required this.theme, required super.child});

  @override
  bool updateShouldNotify(SurveyThemeInherited old) => theme != old.theme;
}

// ─── SurveyThemeProvider ──────────────────────────────────────────────────────

class SurveyThemeProvider extends StatelessWidget {
  final SurveyTheme theme;
  final Widget child;

  const SurveyThemeProvider(
      {super.key, required this.theme, required this.child});

  @override
  Widget build(BuildContext context) =>
      SurveyThemeInherited(theme: theme, child: child);
}
