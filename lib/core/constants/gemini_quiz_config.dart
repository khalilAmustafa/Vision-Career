class GeminiQuizConfig {
  const GeminiQuizConfig._();

  // Move this out of the client before production release.
  static const String apiKey = 'AIzaSyAeqoQ16yJOSlTp0GMj0K1ODJuDvckV6hk';
  static const String model = 'gemini-2.5-flash';

  static String get endpoint =>
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey';
}



