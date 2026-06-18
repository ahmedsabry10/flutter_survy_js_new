/// Normalises rich SurveyJS HTML so it renders acceptably with `flutter_html`,
/// which has no CSS-gradient support.
///
/// SurveyJS exports lean heavily on `background: linear-gradient(...)` for
/// cards/banners. Without a background, the (often light) text those cards
/// define becomes unreadable — and the result looks broken in both light and
/// dark app themes. We approximate each gradient with a solid colour taken
/// from its first colour stop, so the card keeps a self-consistent
/// background + foreground that reads correctly regardless of app theme.
String normalizeSurveyHtml(String html) {
  // Matches `background: linear-gradient(...)` or
  // `background-image: linear-gradient(...)`, tolerating one level of nested
  // parentheses (e.g. an rgba() colour stop inside the gradient).
  final gradient = RegExp(
    r'background(?:-image)?\s*:\s*linear-gradient\((?:[^()]+|\([^()]*\))*\)',
    caseSensitive: false,
  );
  // First colour stop — a hex or rgb()/rgba() value (skips the "135deg" angle).
  final firstColor = RegExp(r'#[0-9a-fA-F]{3,8}|rgba?\([^)]*\)');

  return html.replaceAllMapped(gradient, (m) {
    final color = firstColor.firstMatch(m.group(0)!)?.group(0);
    return color == null ? '' : 'background-color: $color';
  });
}
