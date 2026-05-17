import 'package:flutter/material.dart';

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

  // ─── Button ───────────────────────────────────────────────────────────────
  final Color nextButtonColor;
  final Color prevButtonColor;
  final Color submitButtonColor;

  const SurveyTheme({
    this.primaryColor = const Color(0xFF1AB394),
    this.backgroundColor = const Color(0xFFF5F5F5),
    this.questionBackgroundColor = Colors.white,
    this.borderColor = const Color(0xFFDDDDDD),
    this.focusBorderColor = const Color(0xFF1AB394),
    this.errorColor = const Color(0xFFE74C3C),
    this.textColor = const Color(0xFF333333),
    this.titleColor = const Color(0xFF111111),
    this.hintColor = const Color(0xFF999999),
    this.disabledColor = const Color(0xFFCCCCCC),
    this.ratingSelectedColor = const Color(0xFF1AB394),
    this.ratingUnselectedColor = const Color(0xFFDDDDDD),
    this.progressBarColor = const Color(0xFF1AB394),
    this.surveyTitleStyle = const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF111111)),
    this.surveyDescriptionStyle = const TextStyle(fontSize: 15, color: Color(0xFF666666), height: 1.5),
    this.questionTitleStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF111111), height: 1.4),
    this.questionDescriptionStyle = const TextStyle(fontSize: 13, color: Color(0xFF888888), height: 1.4),
    this.inputTextStyle = const TextStyle(fontSize: 15, color: Color(0xFF333333)),
    this.errorTextStyle = const TextStyle(fontSize: 12, color: Color(0xFFE74C3C)),
    this.choiceLabelStyle = const TextStyle(fontSize: 15, color: Color(0xFF333333)),
    this.buttonTextStyle = const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
    this.inputBorderRadius = const BorderRadius.all(Radius.circular(4)),
    this.cardBorderRadius = const BorderRadius.all(Radius.circular(8)),
    this.buttonBorderRadius = const BorderRadius.all(Radius.circular(4)),
    this.questionSpacing = 16,
    this.cardPadding = 20,
    this.inputPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    this.nextButtonColor = const Color(0xFF1AB394),
    this.prevButtonColor = const Color(0xFF999999),
    this.submitButtonColor = const Color(0xFF1AB394),
  });

  // ─── Light factory ────────────────────────────────────────────────────────

  factory SurveyTheme.light({Color primaryColor = const Color(0xFF1AB394)}) {
    return SurveyTheme(
      primaryColor: primaryColor,
      backgroundColor: const Color(0xFFF5F5F5),
      questionBackgroundColor: Colors.white,
      borderColor: const Color(0xFFDDDDDD),
      focusBorderColor: primaryColor,
      errorColor: const Color(0xFFE74C3C),
      textColor: const Color(0xFF333333),
      titleColor: const Color(0xFF111111),
      hintColor: const Color(0xFF999999),
      disabledColor: const Color(0xFFCCCCCC),
      ratingSelectedColor: primaryColor,
      ratingUnselectedColor: const Color(0xFFDDDDDD),
      progressBarColor: primaryColor,
      surveyTitleStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF111111)),
      surveyDescriptionStyle: const TextStyle(fontSize: 15, color: Color(0xFF666666), height: 1.5),
      questionTitleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF111111), height: 1.4),
      questionDescriptionStyle: const TextStyle(fontSize: 13, color: Color(0xFF888888), height: 1.4),
      inputTextStyle: const TextStyle(fontSize: 15, color: Color(0xFF333333)),
      errorTextStyle: const TextStyle(fontSize: 12, color: Color(0xFFE74C3C)),
      choiceLabelStyle: const TextStyle(fontSize: 15, color: Color(0xFF333333)),
      buttonTextStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
      nextButtonColor: primaryColor,
      prevButtonColor: const Color(0xFF999999),
      submitButtonColor: primaryColor,
    );
  }

  // ─── Dark factory ─────────────────────────────────────────────────────────

  factory SurveyTheme.dark({Color primaryColor = const Color(0xFF1AB394)}) {
    return SurveyTheme(
      primaryColor: primaryColor,
      backgroundColor: const Color(0xFF121212),
      questionBackgroundColor: const Color(0xFF1E1E1E),
      borderColor: const Color(0xFF2C2C2C),
      focusBorderColor: primaryColor,
      errorColor: const Color(0xFFCF6679),
      textColor: const Color(0xFFE0E0E0),
      titleColor: const Color(0xFFFFFFFF),
      hintColor: const Color(0xFF757575),
      disabledColor: const Color(0xFF424242),
      ratingSelectedColor: primaryColor,
      ratingUnselectedColor: const Color(0xFF2C2C2C),
      progressBarColor: primaryColor,
      surveyTitleStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFFFFFFF)),
      surveyDescriptionStyle: const TextStyle(fontSize: 15, color: Color(0xFF9E9E9E), height: 1.5),
      questionTitleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFFFFFFF), height: 1.4),
      questionDescriptionStyle: const TextStyle(fontSize: 13, color: Color(0xFF757575), height: 1.4),
      inputTextStyle: const TextStyle(fontSize: 15, color: Color(0xFFE0E0E0)),
      errorTextStyle: const TextStyle(fontSize: 12, color: Color(0xFFCF6679)),
      choiceLabelStyle: const TextStyle(fontSize: 15, color: Color(0xFFE0E0E0)),
      buttonTextStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
      nextButtonColor: primaryColor,
      prevButtonColor: const Color(0xFF424242),
      submitButtonColor: primaryColor,
    );
  }

  // ─── Auto-detect from Flutter brightness ──────────────────────────────────

  factory SurveyTheme.fromBrightness(
    BuildContext context, {
    Color primaryColor = const Color(0xFF1AB394),
  }) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? SurveyTheme.dark(primaryColor: primaryColor)
        : SurveyTheme.light(primaryColor: primaryColor);
  }

  // ─── of() — used by all child widgets (always returns a value) ────────────
  //
  // Priority: SurveyThemeProvider in tree → auto-detect from brightness
  // This means child widgets never break — they always get a valid theme.

  static SurveyTheme of(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<SurveyThemeInherited>();
    return inherited?.theme ?? SurveyTheme.fromBrightness(context);
  }

  // ─── copyWith ─────────────────────────────────────────────────────────────

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
    );
  }
}

// ─── InheritedWidget (public) ─────────────────────────────────────────────────

class SurveyThemeInherited extends InheritedWidget {
  final SurveyTheme theme;

  const SurveyThemeInherited({
    required this.theme,
    required super.child,
  });

  @override
  bool updateShouldNotify(SurveyThemeInherited old) => theme != old.theme;
}

// ─── SurveyThemeProvider ──────────────────────────────────────────────────────

class SurveyThemeProvider extends StatelessWidget {
  final SurveyTheme theme;
  final Widget child;

  const SurveyThemeProvider({
    super.key,
    required this.theme,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SurveyThemeInherited(theme: theme, child: child);
  }
}
