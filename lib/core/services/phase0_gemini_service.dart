import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/gemini_quiz_config.dart';
import 'phase0_mapping_service.dart';

class Phase0SpecialtyRecommendation {
  final String specialtyKey;
  final String title;
  final String shortDescription;
  final String fitReason;
  final double confidence;

  const Phase0SpecialtyRecommendation({
    required this.specialtyKey,
    required this.title,
    required this.shortDescription,
    required this.fitReason,
    required this.confidence,
  });

  factory Phase0SpecialtyRecommendation.fromJson(Map<String, dynamic> json) {
    return Phase0SpecialtyRecommendation(
      specialtyKey: (json['specialty_key'] ?? '').toString().trim(),
      title: (json['title'] ?? '').toString().trim(),
      shortDescription: (json['short_description'] ?? '').toString().trim(),
      fitReason: (json['fit_reason'] ?? '').toString().trim(),
      confidence: _parseConfidence(json['confidence']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'specialty_key': specialtyKey,
      'title': title,
      'short_description': shortDescription,
      'fit_reason': fitReason,
      'confidence': confidence,
    };
  }

  static double _parseConfidence(dynamic value) {
    if (value is num) {
      return value.toDouble().clamp(0.0, 1.0);
    }
    return (double.tryParse(value.toString()) ?? 0.0).clamp(0.0, 1.0);
  }
}

class Phase0GeminiService {
  const Phase0GeminiService();

  Future<List<Phase0SpecialtyRecommendation>> recommendFromFreeText({
    required String userDescription,
    required List<Phase0SpecialtyOption> allowedSpecialties,
  }) {
    return recommendFromDescription(
      userDescription: userDescription,
      allowedSpecialties: allowedSpecialties,

    );
  }

  Future<List<Phase0SpecialtyRecommendation>> recommendFromDescription({
    required String userDescription,
    required List<Phase0SpecialtyOption> allowedSpecialties,
  }) async {
    final prompt = _buildDescriptionPrompt(
      userDescription: userDescription,
      allowedSpecialties: allowedSpecialties,
    );

    final text = await _sendPrompt(prompt);
    final decoded = jsonDecode(_normalizeJson(text)) as Map<String, dynamic>;

    return _extractRecommendations(
      decoded,
      allowedSpecialties,
      minCount: 1,
      maxCount: 5,
    );
  }

  Future<List<String>> buildGuidedChatQuestions({
    required Map<String, dynamic> interestProfile,
    required List<Phase0SpecialtyOption> allowedSpecialties,
    required String language,
  }) async {
    final prompt = _buildGuidedChatQuestionsPrompt(
      interestProfile: interestProfile,
      allowedSpecialties: allowedSpecialties,
      language: language,

    );

    final text = await _sendPrompt(prompt);
    final decoded = jsonDecode(_normalizeJson(text)) as Map<String, dynamic>;
    final rawQuestions = decoded['questions'] as List<dynamic>? ?? const [];

    final questions = rawQuestions
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .take(6)
        .toList(growable: false);

    if (questions.length < 4) {
      throw const FormatException(
        'Phase 0 guided chat must return 4 to 6 usable questions.',
      );
    }

    return questions;
  }

  Future<String> summarizeDiscoveryChat({
    required List<Map<String, dynamic>> transcript,
    required String language,
  }) async {
    final prompt = _buildChatSummaryPrompt(
      transcript: transcript,
       language: language,
    );

    final text = await _sendPrompt(prompt);
    final decoded = jsonDecode(_normalizeJson(text)) as Map<String, dynamic>;
    final summary = (decoded['summary'] ?? '').toString().trim();

    if (summary.isEmpty) {
      throw const FormatException('Phase 0 chat summary was empty.');
    }

    return summary;
  }

  Future<List<Phase0SpecialtyRecommendation>> recommendFromDiscoveryPackage({
    required Map<String, dynamic> interestProfile,
    required String chatSummary,
    required Map<String, dynamic> aptitudeSummary,
    required List<Phase0SpecialtyOption> allowedSpecialties,
    required String language,
  }) async {
    final prompt = _buildDiscoveryPackagePrompt(
      interestProfile: interestProfile,
      chatSummary: chatSummary,
      aptitudeSummary: aptitudeSummary,
      allowedSpecialties: allowedSpecialties,
      language: language,
    );

    final text = await _sendPrompt(prompt);
    final decoded = jsonDecode(_normalizeJson(text)) as Map<String, dynamic>;

    return _extractRecommendations(
      decoded,
      allowedSpecialties,
      minCount: 1,
      maxCount: 5,
    );
  }

  List<Phase0SpecialtyRecommendation> _extractRecommendations(
      Map<String, dynamic> decoded,
      List<Phase0SpecialtyOption> allowedSpecialties, {
        required int minCount,
        required int maxCount,
      }) {
    final allowedKeys = allowedSpecialties
        .map((item) => item.specialtyKey.trim().toLowerCase())
        .where((item) => item.isNotEmpty)
        .toSet();

    final rawItems = decoded['suggested_specialties'] as List<dynamic>? ?? const [];

    final recommendations = rawItems
        .whereType<Map<String, dynamic>>()
        .map(Phase0SpecialtyRecommendation.fromJson)
        .where(
          (item) =>
      item.specialtyKey.isNotEmpty &&
          allowedKeys.contains(item.specialtyKey.toLowerCase()) &&
          item.title.isNotEmpty &&
          item.shortDescription.isNotEmpty &&
          item.fitReason.isNotEmpty,
    )
        .take(maxCount)
        .toList(growable: false);

    if (recommendations.length < minCount) {
      throw const FormatException(
        'Phase 0 Gemini returned no valid specialties after local validation.',
      );
    }

    return recommendations;
  }

  Future<String> _sendPrompt(String prompt) async {
    final payload = {
      'contents': [
        {
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      'generationConfig': {
        'responseMimeType': 'application/json',
        'temperature': 0.35,
        'topP': 0.9,
      },
    };

    int attempts = 0;

    while (attempts < 3) {
      try {
        final response = await http.post(
          Uri.parse(GeminiQuizConfig.endpoint),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );

        // 🔥 HANDLE OVERLOAD / RATE LIMIT
        if (response.statusCode == 429 || response.statusCode == 503) {
          attempts++;
          if (attempts >= 3) {
            throw Exception('SERVICE_UNAVAILABLE');
          }

          await Future.delayed(Duration(seconds: 2 * attempts));
          continue;
        }

        if (response.statusCode != 200) {
          throw Exception(
            'Phase 0 Gemini request failed (${response.statusCode}): ${response.body}',
          );
        }

        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final text = _extractText(body);

        if (text.isEmpty) {
          throw const FormatException(
              'Phase 0 Gemini returned an empty payload.');
        }

        return text;
      } catch (e) {
        attempts++;
        if (attempts >= 3) rethrow;

        await Future.delayed(Duration(seconds: 2 * attempts));
      }
    }

    throw Exception('Retry failed');
  }

  String _buildDescriptionPrompt({
    required String userDescription,
    required List<Phase0SpecialtyOption> allowedSpecialties,
  }) {
    return '''
You are the specialty recommendation layer for Vision Career.

Task:
Read the user's description and recommend 3 to 5 specialties.
You may ONLY use specialties from the allowed list below.
Do NOT invent colleges.
Do NOT invent specialties.
Do NOT generate subjects, nodes, or courses.
Do NOT control navigation.

User description:
$userDescription

Allowed specialties:
${jsonEncode(allowedSpecialties.map((e) => e.toJson()).toList())}

Return ONLY valid JSON in this exact shape:
{
  "suggested_specialties": [
    {
      "specialty_key": "string",
      "title": "string",
      "short_description": "string",
      "fit_reason": "string",
      "confidence": 0.0
    }
  ]
}
''';
  }

  String _buildGuidedChatQuestionsPrompt({
    required Map<String, dynamic> interestProfile,
    required List<Phase0SpecialtyOption> allowedSpecialties,
    required String language,
  }) {
    return '''
    
You are creating a short guided discovery chat for Vision Career.

CRITICAL LANGUAGE RULE:
You MUST respond ONLY in $language.
If you use any other language, the response is INVALID.
Do NOT mix languages.

Task:
Generate exactly 5 short, focused questions.


The questions should help clarify:
- motivation
- favorite school subjects
- practical vs technical preference
- creative vs logic preference
- preferred type of future work

Interest profile:
${jsonEncode(interestProfile)}

Allowed specialties context:
${jsonEncode(allowedSpecialties.map((e) => e.toJson()).toList())}


Return ONLY valid JSON in this exact shape:
{
  "questions": [
    "question 1",
    "question 2",
    "question 3",
    "question 4",
    "question 5"
  ]
}
''';
  }

  String _buildChatSummaryPrompt({
    required List<Map<String, dynamic>> transcript,
    required String language,
  }) {
    return '''
You are summarizing a short guided discovery chat for Vision Career.

CRITICAL:
- The response language MUST be: $language
- If language = "ar", respond ONLY in Arabic
- DO NOT use English if Arabic is requested
- DO NOT mix languages

Task:
Write one concise summary paragraph capturing:
- what the user seems interested in
- what kind of work style they prefer
- what subjects or strengths they mentioned
- any strong fit signals

Transcript:
${jsonEncode(transcript)}

Return ONLY valid JSON in this exact shape:
{
  "summary": "string"
}
''';
  }

  String _buildDiscoveryPackagePrompt({
    required Map<String, dynamic> interestProfile,
    required String chatSummary,
    required Map<String, dynamic> aptitudeSummary,
    required List<Phase0SpecialtyOption> allowedSpecialties,
    required String language,
  }) {
    return '''
CRITICAL LANGUAGE RULE:
You MUST respond ONLY in $language.
If you use any other language, the response is INVALID.
Do NOT mix languages.
You are the specialty recommendation layer for Vision Career.

Task:
Recommend 3 to 5 specialties based on the user's full discovery package.
You may ONLY use specialties from the allowed list below.
Do NOT invent colleges.
Do NOT invent specialties.
Do NOT generate subjects, nodes, or courses.

Interest profile:
${jsonEncode(interestProfile)}

Chat summary:
$chatSummary

Aptitude summary:
${jsonEncode(aptitudeSummary)}

Allowed specialties:
${jsonEncode(allowedSpecialties.map((e) => e.toJson()).toList())}

Return ONLY valid JSON in this exact shape:
{
  "suggested_specialties": [
    {
      "specialty_key": "string",
      "title": "string",
      "short_description": "string",
      "fit_reason": "string",
      "confidence": 0.0
    }
  ]
}
''';
  }

  String _extractText(Map<String, dynamic> json) {
    final candidates = json['candidates'] as List<dynamic>? ?? const [];
    if (candidates.isEmpty) return '';

    final firstCandidate = candidates.first as Map<String, dynamic>;
    final content = firstCandidate['content'] as Map<String, dynamic>? ?? const {};
    final parts = content['parts'] as List<dynamic>? ?? const [];
    if (parts.isEmpty) return '';

    final firstPart = parts.first as Map<String, dynamic>;
    return (firstPart['text'] ?? '').toString().trim();
  }

  String _normalizeJson(String input) {
    var output = input.trim();

    if (output.startsWith('```')) {
      output = output
          .replaceFirst(RegExp(r'^```json\s*'), '')
          .replaceFirst(RegExp(r'^```\s*'), '')
          .replaceFirst(RegExp(r'\s*```$'), '');
    }

    final startIndex = output.indexOf('{');
    final endIndex = output.lastIndexOf('}');

    if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
      output = output.substring(startIndex, endIndex + 1);
    }

    return output.trim();
  }
}
