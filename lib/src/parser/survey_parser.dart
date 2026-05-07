import 'dart:convert';
import '../models/survey_model.dart';

/// Parses a SurveyJS JSON map or JSON string into a [SurveyModel].
///
/// Accepts:
/// - [Map<String, dynamic>] — already decoded JSON object
/// - [String] — raw JSON string (will be decoded automatically)
///
/// Example:
/// ```dart
/// final survey = surveyFromJson(jsonMap);
/// final survey = surveyFromJson('{"title": "My Survey", "elements": [...]}');
/// ```
SurveyModel surveyFromJson(dynamic json) {
  if (json is String) {
    return SurveyModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }
  if (json is Map<String, dynamic>) {
    return SurveyModel.fromJson(json);
  }
  throw ArgumentError(
    'surveyFromJson expects a Map<String, dynamic> or a JSON String, '
    'got ${json.runtimeType}',
  );
}

/// Converts a [SurveyModel] back to a JSON-encodable map.
/// Useful for debugging or sending results back to the server.
Map<String, dynamic> surveyToJson(SurveyModel survey) {
  return {
    if (survey.title != null) 'title': survey.title,
    if (survey.description != null) 'description': survey.description,
    if (survey.locale != null) 'locale': survey.locale,
    'pages': survey.pages
        .map((p) => {
              'name': p.name,
              if (p.title != null) 'title': p.title,
              'elements': p.elements.map((q) => q.rawJson).toList(),
            })
        .toList(),
  };
}
