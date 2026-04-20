import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiQuizConfig {
  const GeminiQuizConfig._();

  // Move this to backend in production.
  static String get apiKey {
    final value = dotenv.env['GEMINI_API_KEY']?.trim();
    if (value == null || value.isEmpty) {
      throw StateError(
        'Missing GEMINI_API_KEY in .env. Add GEMINI_API_KEY=your_key and restart the app.',
      );
    }
    return value;
  }

  static const String model = 'gemini-2.5-flash';

  static String get endpoint =>
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey';
}
