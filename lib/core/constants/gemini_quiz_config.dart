class GeminiQuizConfig {
  const GeminiQuizConfig._();

  // Move this out of the client before production release.
  static const String apiKey = 'AIzaSyDcQFwIsR_pkwL-09SfmNc639ZcMGRJr5Q';
  static const String model = 'gemini-2.5-flash';

  static String get endpoint =>
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey';
}
