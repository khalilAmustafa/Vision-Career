import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../data/models/subject_model.dart';
import '../../data/models/quiz_question_model.dart';
import '../constants/gemini_quiz_config.dart';

class GeminiQuizService {
  Future<List<QuizQuestion>> generateQuiz({
    required Subject subject,
    required String college,
    required String specialization,
    required String achievementsSummary,
  }) async {
    final prompt = _buildPrompt(
      subject: subject,
      college: college,
      specialization: specialization,
      achievementsSummary: achievementsSummary,
    );

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
        'temperature': 0.5,
        'topP': 0.9,
      },
    };

    final response = await http.post(
      Uri.parse(GeminiQuizConfig.endpoint),
      headers: const {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gemini quiz request failed (${response.statusCode}): ${response.body}',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final text = _extractText(body);

    if (text.isEmpty) {
      throw const FormatException('Gemini returned an empty quiz payload.');
    }

    final normalizedJson = _normalizeJson(text);
    final decoded = jsonDecode(normalizedJson) as Map<String, dynamic>;
    final rawQuestions = decoded['questions'] as List<dynamic>? ?? const [];

    final questions = rawQuestions
        .map((item) => QuizQuestion.fromJson(item as Map<String, dynamic>))
        .where((question) =>
            question.question.isNotEmpty &&
            question.choices.length == 4 &&
            question.correctAnswerIndex >= 0 &&
            question.correctAnswerIndex < 4)
        .toList();

    if (questions.length != 20) {
      throw FormatException(
        'Gemini must return exactly 20 questions. Got ${questions.length}.',
      );
    }

    return questions;
  }

  String _buildPrompt({
    required Subject subject,
    required String college,
    required String specialization,
    required String achievementsSummary,
  }) {
    return '''
You are generating a hard university-level assessment quiz.

Context:
- Subject code: ${subject.code}
- Subject name: ${subject.name}
- College: $college
- Specialization: $specialization
- Subject description: ${subject.description}
- Related skills: ${subject.skills.join(', ')}
- Subject prerequisites: ${subject.prerequisites.join(', ')}
- What the user already achieved:
$achievementsSummary

Task:
Generate exactly 20 difficult MCQ questions for this subject.
The quiz must test understanding, logic, applications, and core concepts that a student should know after completing this subject.
Questions must fit this subject specifically and must not be generic filler.
Avoid repeated questions.
Each question must have exactly 4 answer choices.
Only one answer is correct.
Use 0-based indexing for correct_answer_index.
Keep explanations short.

Return ONLY valid JSON in this exact shape:
{
  "questions": [
    {
      "question": "string",
      "choices": ["A", "B", "C", "D"],
      "correct_answer_index": 0,
      "explanation": "string",
      "difficulty_tag": "hard"
    }
  ]
}
''';
  }

  String _extractText(Map<String, dynamic> json) {
    final candidates = json['candidates'] as List<dynamic>? ?? const [];
    if (candidates.isEmpty) return '';

    final firstCandidate = candidates.first as Map<String, dynamic>;
    final content =
        firstCandidate['content'] as Map<String, dynamic>? ?? const {};
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
