import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';

import '../../data/models/image_quiz_models.dart';
import '../../data/models/subject_model.dart';
import '../constants/gemini_quiz_config.dart';

class GeminiImageQuizService {
  const GeminiImageQuizService();

  Future<ImageQuizEvaluation> evaluateImageSubmission({
    required Subject subject,
    required String college,
    required String specialization,
    required String achievementsSummary,
    required String instructions,
    required String imageTask,
    required List<String> rubric,
    required int passingScore,
    required File imageFile,
  }) async {
    final bytes = await imageFile.readAsBytes();
    if (bytes.isEmpty) {
      throw const FormatException('Selected image file is empty.');
    }

    final mimeType = lookupMimeType(imageFile.path, headerBytes: bytes) ?? 'image/jpeg';
    if (!mimeType.startsWith('image/')) {
      throw FormatException('Unsupported file type for image quiz: $mimeType');
    }

    final prompt = _buildEvaluationPrompt(
      subject: subject,
      college: college,
      specialization: specialization,
      achievementsSummary: achievementsSummary,
      instructions: instructions,
      imageTask: imageTask,
      rubric: rubric,
      passingScore: passingScore,
    );

    final payload = {
      'contents': [
        {
          'parts': [
            {'text': prompt},
            {
              'inlineData': {
                'mimeType': mimeType,
                'data': base64Encode(bytes),
              }
            },
          ],
        },
      ],
      'generationConfig': {
        'responseMimeType': 'application/json',
        'temperature': 0.2,
        'topP': 0.9,
      },
    };

    final response = await http.post(
      Uri.parse(GeminiQuizConfig.endpoint),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw HttpException(
        'Gemini image grading failed (${response.statusCode}): ${response.body}',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final text = _extractText(body);
    if (text.isEmpty) {
      throw const FormatException('Gemini image grading returned empty text.');
    }

    final normalized = _normalizeJson(text);
    final decoded = jsonDecode(normalized) as Map<String, dynamic>;
    final evaluation = ImageQuizEvaluation.fromJson(decoded);

    if (evaluation.feedback.isEmpty) {
      throw const FormatException('Gemini image grading returned invalid feedback.');
    }

    return evaluation;
  }

  String _buildEvaluationPrompt({
    required Subject subject,
    required String college,
    required String specialization,
    required String achievementsSummary,
    required String instructions,
    required String imageTask,
    required List<String> rubric,
    required int passingScore,
  }) {
    final safeRubric = rubric.where((e) => e.trim().isNotEmpty).toList(growable: false);

    return '''
You are the image-submission evaluator for Vision Career.

You are grading a student's uploaded image for a subject completion quiz.

STRICT RULES:
- Return ONLY valid JSON
- No markdown
- No code fences
- No extra commentary
- Score from 0 to 100 only
- Be strict but fair
- Fail blank, unreadable, irrelevant, or low-effort submissions
- Check whether the image actually matches the requested task

Subject context:
- College: $college
- Specialization: $specialization
- Subject code: ${subject.code}
- Subject name: ${subject.name}
- Subject description: ${subject.description}
- Subject skills: ${subject.skills.join(', ')}
- Achievements summary: $achievementsSummary

Quiz instructions:
$instructions

Image task:
$imageTask

Rubric:
${jsonEncode(safeRubric)}

Passing score:
$passingScore

Evaluate the uploaded image and return ONLY this JSON shape:
{
  "passed": true,
  "score_percent": 76,
  "feedback": "short evaluator feedback",
  "strengths": ["item", "item"],
  "issues": ["item", "item"],
  "rubric_checks": ["item", "item"]
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

    if (startIndex == -1 || endIndex == -1 || endIndex <= startIndex) {
      throw const FormatException('Could not isolate JSON object from Gemini image grading response.');
    }

    return output.substring(startIndex, endIndex + 1).trim();
  }
}
