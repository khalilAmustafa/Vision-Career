class GeminiQuizConfig {
  const GeminiQuizConfig._();

  // Move this out of the client before production release.
  static const String apiKey = 'AIzaSyBwneguG4W5UHZUK4I_4HnwEzRRkktnoEo';
  static const String model = 'gemini-2.5-flash';

  static String get endpoint =>
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey';
}