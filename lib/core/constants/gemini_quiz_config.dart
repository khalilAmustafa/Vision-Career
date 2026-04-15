import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiQuizConfig {
  const GeminiQuizConfig._();

  // ⚠️ Move this to backend in production
  static String get apiKey => dotenv.env['GEMINI_API_KEY']!;

  static const String model = 'gemini-2.5-flash';

  static String get endpoint =>
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey';
}