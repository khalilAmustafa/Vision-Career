import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/services/gemini_quiz_service.dart';
import '../../../data/models/quiz_attempt_result_model.dart';
import '../../../data/models/quiz_models.dart';
import '../../../data/models/quiz_question_model.dart';
import '../../../data/models/subject_model.dart';
import '../../../core/services/gemini_image_quiz_service.dart';
import 'image_quiz_widget.dart';

Future<QuizAttemptResult?> showSubjectCompletionQuiz({
  required BuildContext context,
  required Subject subject,
  required String college,
  required String specialization,
  required String achievementsSummary,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => SubjectCompletionQuizSheet(
      subject: subject,
      college: college,
      specialization: specialization,
      achievementsSummary: achievementsSummary,
    ),
  );
}

class SubjectCompletionQuizSheet extends StatefulWidget {
  final Subject subject;
  final String college;
  final String specialization;
  final String achievementsSummary;

  const SubjectCompletionQuizSheet({
    super.key,
    required this.subject,
    required this.college,
    required this.specialization,
    required this.achievementsSummary,
  });

  @override
  State<SubjectCompletionQuizSheet> createState() =>
      _SubjectCompletionQuizSheetState();
}

class _SubjectCompletionQuizSheetState
    extends State<SubjectCompletionQuizSheet> {
  final GeminiQuizService _service = const GeminiQuizService();

  GeneratedQuiz? _quiz;
  bool _loading = true;

  int _currentIndex = 0;
  List<int?> _answers = [];

  final TextEditingController _writingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  @override
  void dispose() {
    _writingController.dispose();
    super.dispose();
  }

  Future<void> _loadQuiz() async {
    final quiz = await _service.generateDynamicQuiz(
      subject: widget.subject,
      college: widget.college,
      specialization: widget.specialization,
      achievementsSummary: widget.achievementsSummary,
    );

    if (!mounted) return;

    setState(() {
      _quiz = quiz;
      _loading = false;

      if (quiz.type == QuizType.mcq) {
        _answers = List<int?>.filled(
          quiz.mcqQuestions?.length ?? 0,
          null,
        );
      }
    });
  }

  void _finish({
    required bool passed,
    required int correctAnswers,
    required int totalQuestions,
  }) {
    final scorePercent =
        totalQuestions == 0 ? 0.0 : (correctAnswers / totalQuestions) * 100.0;

    Navigator.pop(
      context,
      QuizAttemptResult(
        passed: passed,
        correctAnswers: correctAnswers,
        totalQuestions: totalQuestions,
        scorePercent: scorePercent,
        integrityFlags: 0,
        integrityPassed: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.9;

    return SafeArea(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _buildQuizBody(),
      ),
    );
  }

  Widget _buildQuizBody() {
    switch (_quiz!.type) {
      case QuizType.mcq:
        return _buildMCQ();
      case QuizType.writing:
        return _buildWriting();
      case QuizType.image:
        return _buildImage();
    }
  }

  Widget _buildMCQ() {
    final questions = _quiz!.mcqQuestions!
        .map((q) => QuizQuestion.fromJson(q))
        .toList();

    final q = questions[_currentIndex];

    return Column(
      children: [
        _buildHeader(),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question ${_currentIndex + 1}/${questions.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  q.question,
                  style: const TextStyle(fontSize: 17),
                ),

                const SizedBox(height: 24),

                ...List.generate(q.choices.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: RadioListTile<int>(
                      value: i,
                      groupValue: _answers[_currentIndex],
                      onChanged: (v) {
                        setState(() {
                          _answers[_currentIndex] = v;
                        });
                      },
                      title: Text(q.choices[i]),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_answers[_currentIndex] == null) return;

                if (_currentIndex < questions.length - 1) {
                  setState(() => _currentIndex++);
                  return;
                }

                int correct = 0;
                for (int i = 0; i < questions.length; i++) {
                  if (_answers[i] == questions[i].correctAnswerIndex) {
                    correct++;
                  }
                }

                final passed =
                    correct >= (questions.length * 0.6).ceil();

                _finish(
                  passed: passed,
                  correctAnswers: correct,
                  totalQuestions: questions.length,
                );
              },
              child: Text(
                _currentIndex == questions.length - 1
                    ? 'Finish'
                    : 'Next',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWriting() {
    return Column(
      children: [
        _buildHeader(),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _quiz!.writingPrompt ?? '',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _writingController,
                  maxLines: 12,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Write your answer here...',
                  ),
                ),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _finish(
                  passed: _writingController.text.trim().isNotEmpty,
                  correctAnswers: 1,
                  totalQuestions: 1,
                );
              },
              child: const Text('Submit'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImage() {
    return StatefulBuilder(
      builder: (context, setLocalState) {
        bool isSubmitting = false;

        return Column(
          children: [
            _buildHeader(),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ImageQuizWidget(
                  task: _quiz!.imageTask ?? '',
                  instructions: _quiz!.instructions,
                  isSubmitting: isSubmitting,
                  onSubmit: (File imageFile) async {
                    setLocalState(() => isSubmitting = true);

                    try {
                      final evaluation =
                          await GeminiImageQuizService()
                              .evaluateImageSubmission(
                        subject: widget.subject,
                        college: widget.college,
                        specialization: widget.specialization,
                        achievementsSummary:
                            widget.achievementsSummary,
                        instructions: _quiz!.instructions,
                        imageTask: _quiz!.imageTask ?? '',
                        rubric: _quiz!.imageRubric,
                        passingScore: _quiz!.passingScore,
                        imageFile: imageFile,
                      );

                      if (!mounted) return;

                      _finish(
                        passed: evaluation.passed,
                        correctAnswers:
                            evaluation.passed ? 1 : 0,
                        totalQuestions: 1,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            evaluation.feedback,
                          ),
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Image grading failed: $e',
                          ),
                        ),
                      );
                    } finally {
                      if (mounted) {
                        setLocalState(() => isSubmitting = false);
                      }
                    }
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }


 Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.subject.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}