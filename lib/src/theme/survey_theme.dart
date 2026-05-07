import 'package:flutter/material.dart';

/// Controls the visual appearance of all survey widgets.
/// Pass a custom [SurveyTheme] to [SurveyWidget] to override defaults.
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
    this.inputPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    this.nextButtonColor = const Color(0xFF1AB394),
    this.prevButtonColor = const Color(0xFF999999),
    this.submitButtonColor = const Color(0xFF1AB394),
  });

  /// Access the theme from any widget using [SurveyTheme.of(context)]
  static SurveyTheme of(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<_SurveyThemeInherited>();
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
    TextStyle? questionTitleStyle,
    TextStyle? choiceLabelStyle,
    double? questionSpacing,
    double? cardPadding,
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
      questionTitleStyle: questionTitleStyle ?? this.questionTitleStyle,
      choiceLabelStyle: choiceLabelStyle ?? this.choiceLabelStyle,
      questionSpacing: questionSpacing ?? this.questionSpacing,
      cardPadding: cardPadding ?? this.cardPadding,
      inputBorderRadius: inputBorderRadius ?? this.inputBorderRadius,
      cardBorderRadius: cardBorderRadius ?? this.cardBorderRadius,
      buttonBorderRadius: buttonBorderRadius ?? this.buttonBorderRadius,
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
