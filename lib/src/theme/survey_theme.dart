import 'package:flutter/material.dart';

/// Controls the visual appearance of all survey widgets.
/// Pass a custom [SurveyTheme] to [SurveyWidget] to override defaults.
///
/// ⚡ Smart defaults: [nextButtonColor], [submitButtonColor],
/// [focusBorderColor], [ratingSelectedColor], and [progressBarColor]
/// all follow [primaryColor] automatically if you don't set them explicitly.
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

  // ─── Button colors ────────────────────────────────────────────────────────
  /// لون زرار Next — لو مش محدد بياخد primaryColor تلقائياً
  final Color nextButtonColor;

  /// لون زرار Previous — لو مش محدد بياخد رمادي تلقائياً
  final Color prevButtonColor;

  /// لون زرار Submit — لو مش محدد بياخد primaryColor تلقائياً
  final Color submitButtonColor;

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
    this.nextButtonColor = const Color(0xFF1AB394),
    this.prevButtonColor = const Color(0xFF999999),
    this.submitButtonColor = const Color(0xFF1AB394),
    this.surveyTitleStyle = const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Color(0xFF111111),
    ),
    this.surveyDescriptionStyle = const TextStyle(
      fontSize: 15,
      color: Color(0xFF666666),
      height: 1.5,
    ),
    this.questionTitleStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Color(0xFF111111),
      height: 1.4,
    ),
    this.questionDescriptionStyle = const TextStyle(
      fontSize: 13,
      color: Color(0xFF888888),
      height: 1.4,
    ),
    this.inputTextStyle = const TextStyle(
      fontSize: 15,
      color: Color(0xFF333333),
    ),
    this.errorTextStyle = const TextStyle(
      fontSize: 12,
      color: Color(0xFFE74C3C),
    ),
    this.choiceLabelStyle = const TextStyle(
      fontSize: 15,
      color: Color(0xFF333333),
    ),
    this.buttonTextStyle = const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    this.inputBorderRadius = const BorderRadius.all(Radius.circular(4)),
    this.cardBorderRadius = const BorderRadius.all(Radius.circular(8)),
    this.buttonBorderRadius = const BorderRadius.all(Radius.circular(4)),
    this.questionSpacing = 16,
    this.cardPadding = 20,
    this.inputPadding =
        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  });

  /// Creates a [SurveyTheme] where button colors & accents that were NOT
  /// explicitly set by the user will follow [primaryColor] automatically.
  ///
  /// Use this factory instead of the default constructor when you want
  /// "change primaryColor → everything updates".
  factory SurveyTheme.fromPrimary({
    Color primaryColor = const Color(0xFF1AB394),
    Color? backgroundColor,
    Color? questionBackgroundColor,
    Color? borderColor,
    Color? focusBorderColor,        // ← follows primaryColor if null
    Color? errorColor,
    Color? textColor,
    Color? titleColor,
    Color? hintColor,
    Color? disabledColor,
    Color? ratingSelectedColor,     // ← follows primaryColor if null
    Color? ratingUnselectedColor,
    Color? progressBarColor,        // ← follows primaryColor if null
    Color? nextButtonColor,         // ← follows primaryColor if null
    Color? prevButtonColor,
    Color? submitButtonColor,       // ← follows primaryColor if null
    TextStyle? surveyTitleStyle,
    TextStyle? surveyDescriptionStyle,
    TextStyle? questionTitleStyle,
    TextStyle? questionDescriptionStyle,
    TextStyle? inputTextStyle,
    TextStyle? errorTextStyle,
    TextStyle? choiceLabelStyle,
    TextStyle? buttonTextStyle,
    BorderRadius? inputBorderRadius,
    BorderRadius? cardBorderRadius,
    BorderRadius? buttonBorderRadius,
    double? questionSpacing,
    double? cardPadding,
    EdgeInsets? inputPadding,
  }) {
    return SurveyTheme(
      primaryColor: primaryColor,
      backgroundColor: backgroundColor ?? const Color(0xFFF5F5F5),
      questionBackgroundColor: questionBackgroundColor ?? Colors.white,
      borderColor: borderColor ?? const Color(0xFFDDDDDD),
      // ↓ these all fall back to primaryColor
      focusBorderColor: focusBorderColor ?? primaryColor,
      ratingSelectedColor: ratingSelectedColor ?? primaryColor,
      progressBarColor: progressBarColor ?? primaryColor,
      nextButtonColor: nextButtonColor ?? primaryColor,
      submitButtonColor: submitButtonColor ?? primaryColor,
      // ↓ these have their own independent defaults
      prevButtonColor: prevButtonColor ?? const Color(0xFF999999),
      errorColor: errorColor ?? const Color(0xFFE74C3C),
      textColor: textColor ?? const Color(0xFF333333),
      titleColor: titleColor ?? const Color(0xFF111111),
      hintColor: hintColor ?? const Color(0xFF999999),
      disabledColor: disabledColor ?? const Color(0xFFCCCCCC),
      ratingUnselectedColor: ratingUnselectedColor ?? const Color(0xFFDDDDDD),
      surveyTitleStyle: surveyTitleStyle ??
          const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111111)),
      surveyDescriptionStyle: surveyDescriptionStyle ??
          const TextStyle(
              fontSize: 15, color: Color(0xFF666666), height: 1.5),
      questionTitleStyle: questionTitleStyle ??
          const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111111),
              height: 1.4),
      questionDescriptionStyle: questionDescriptionStyle ??
          const TextStyle(
              fontSize: 13, color: Color(0xFF888888), height: 1.4),
      inputTextStyle: inputTextStyle ??
          const TextStyle(fontSize: 15, color: Color(0xFF333333)),
      errorTextStyle: errorTextStyle ??
          const TextStyle(fontSize: 12, color: Color(0xFFE74C3C)),
      choiceLabelStyle: choiceLabelStyle ??
          const TextStyle(fontSize: 15, color: Color(0xFF333333)),
      buttonTextStyle: buttonTextStyle ??
          const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white),
      inputBorderRadius:
          inputBorderRadius ?? const BorderRadius.all(Radius.circular(4)),
      cardBorderRadius:
          cardBorderRadius ?? const BorderRadius.all(Radius.circular(8)),
      buttonBorderRadius:
          buttonBorderRadius ?? const BorderRadius.all(Radius.circular(4)),
      questionSpacing: questionSpacing ?? 16,
      cardPadding: cardPadding ?? 20,
      inputPadding: inputPadding ??
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  /// Access the theme from any widget using [SurveyTheme.of(context)]
  static SurveyTheme of(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<_SurveyThemeInherited>();
    return inherited?.theme ?? const SurveyTheme();
  }

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
    BorderRadius? inputBorderRadius,
    BorderRadius? cardBorderRadius,
    BorderRadius? buttonBorderRadius,
    EdgeInsets? inputPadding,
  }) {
    return SurveyTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      questionBackgroundColor:
          questionBackgroundColor ?? this.questionBackgroundColor,
      borderColor: borderColor ?? this.borderColor,
      focusBorderColor: focusBorderColor ?? this.focusBorderColor,
      errorColor: errorColor ?? this.errorColor,
      textColor: textColor ?? this.textColor,
      titleColor: titleColor ?? this.titleColor,
      hintColor: hintColor ?? this.hintColor,
      disabledColor: disabledColor ?? this.disabledColor,
      ratingSelectedColor: ratingSelectedColor ?? this.ratingSelectedColor,
      ratingUnselectedColor:
          ratingUnselectedColor ?? this.ratingUnselectedColor,
      progressBarColor: progressBarColor ?? this.progressBarColor,
      nextButtonColor: nextButtonColor ?? this.nextButtonColor,
      prevButtonColor: prevButtonColor ?? this.prevButtonColor,
      submitButtonColor: submitButtonColor ?? this.submitButtonColor,
      surveyTitleStyle: surveyTitleStyle ?? this.surveyTitleStyle,
      surveyDescriptionStyle:
          surveyDescriptionStyle ?? this.surveyDescriptionStyle,
      questionTitleStyle: questionTitleStyle ?? this.questionTitleStyle,
      questionDescriptionStyle:
          questionDescriptionStyle ?? this.questionDescriptionStyle,
      inputTextStyle: inputTextStyle ?? this.inputTextStyle,
      errorTextStyle: errorTextStyle ?? this.errorTextStyle,
      choiceLabelStyle: choiceLabelStyle ?? this.choiceLabelStyle,
      buttonTextStyle: buttonTextStyle ?? this.buttonTextStyle,
      questionSpacing: questionSpacing ?? this.questionSpacing,
      cardPadding: cardPadding ?? this.cardPadding,
      inputBorderRadius: inputBorderRadius ?? this.inputBorderRadius,
      cardBorderRadius: cardBorderRadius ?? this.cardBorderRadius,
      buttonBorderRadius: buttonBorderRadius ?? this.buttonBorderRadius,
      inputPadding: inputPadding ?? this.inputPadding,
    );
  }
}

/// InheritedWidget that provides [SurveyTheme] down the widget tree
class _SurveyThemeInherited extends InheritedWidget {
  final SurveyTheme theme;

  const _SurveyThemeInherited({
    required this.theme,
    required super.child,
  });

  @override
  bool updateShouldNotify(_SurveyThemeInherited old) => theme != old.theme;
}

/// Wrap your survey widget tree with this to provide a custom theme
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
    return _SurveyThemeInherited(theme: theme, child: child);
  }
}
