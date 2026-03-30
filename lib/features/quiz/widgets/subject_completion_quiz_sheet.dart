import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/services/gemini_quiz_service.dart';
import '../../../core/services/quiz_screen_security_service.dart';
import '../../../data/models/quiz_attempt_result_model.dart';
import '../../../data/models/quiz_question_model.dart';
import '../../../data/models/subject_model.dart';

Future<QuizAttemptResult?> showSubjectCompletionQuiz({
  required BuildContext context,
  required Subject subject,
  required String college,
  required String specialization,
  required String achievementsSummary,
}) {
  return showModalBottomSheet<QuizAttemptResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
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

class _SubjectCompletionQuizSheetState extends State<SubjectCompletionQuizSheet> {
  final GeminiQuizService _quizService = GeminiQuizService();
  final QuizScreenSecurityService _securityService =
      QuizScreenSecurityService();

  List<QuizQuestion> _questions = [];
  List<int?> _answers = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  int _currentIndex = 0;




  String _buildResultTitle({
    required bool knowledgePassed,
    required bool integrityPassed,
  }) {
    if (knowledgePassed && integrityPassed) {
      return 'Subject Cleared';
    }

    if (!integrityPassed) {
      return 'Integrity Flag Detected';
    }

    return 'Retake Required';
  }

  String _buildResultMessage({
    required double scorePercent,
    required int correctAnswers,
    required int totalQuestions,
    required int integrityFlags,
    required bool integrityPassed,
  }) {
    final buffer = StringBuffer()
      ..writeln('Score: ${scorePercent.toStringAsFixed(1)}%')
      ..writeln('Correct answers: $correctAnswers / $totalQuestions')
      ..write('Required to pass: ${(totalQuestions * 0.6).ceil()} / $totalQuestions');

    if (!integrityPassed) {
      buffer
        ..writeln()
        ..writeln()
        ..write(
          'Integrity flags: $integrityFlags\n'
          'You switched apps or left the quiz screen during the exam.',
        );
    }

    return buffer.toString();
  }
  @override
  void initState() {
    super.initState();
    _startProtectedQuizFlow();
  }

  Future<void> _startProtectedQuizFlow() async {
    await _securityService.startProtectedQuizSession();
    await _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final questions = await _quizService.generateQuiz(
        subject: widget.subject,
        college: widget.college,
        specialization: widget.specialization,
        achievementsSummary: widget.achievementsSummary,
      );

      if (!mounted) return;

      setState(() {
        _questions = questions;
        _answers = List<int?>.filled(questions.length, null);
        _currentIndex = 0;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _securityService.stopProtectedQuizSession();
    super.dispose();
  }

  Future<void> _cancelAttempt() async {
    final shouldLeave = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cancel quiz attempt?'),
            content: const Text(
              'Your current quiz progress will be lost and the subject will stay uncompleted.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Stay'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Cancel Attempt'),
              ),
            ],
          ),
        ) ??
        false;

    if (!mounted || !shouldLeave) return;
    Navigator.pop(context);
  }

  void _selectAnswer(int optionIndex) {
    setState(() {
      _answers[_currentIndex] = optionIndex;
    });
  }

  void _goPrevious() {
    if (_currentIndex == 0) return;
    setState(() {
      _currentIndex -= 1;
    });
  }

  void _goNext() {
    if (_currentIndex >= _questions.length - 1) return;
    setState(() {
      _currentIndex += 1;
    });
  }
  Future<void> _submitQuiz() async {
    if (_answers.any((answer) => answer == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Answer all 20 questions before finishing the quiz.'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final correctAnswers = _questions.asMap().entries.where((entry) {
      final index = entry.key;
      final question = entry.value;
      return _answers[index] == question.correctAnswerIndex;
    }).length;

    final totalQuestions = _questions.length;
    final scorePercent = (correctAnswers / totalQuestions) * 100;
    final knowledgePassed = scorePercent >= 60;
    final integrityFlags = _securityService.appSwitchFlags;
    final integrityPassed = _securityService.integrityPassed;
    final passed = knowledgePassed && integrityPassed;

    final result = QuizAttemptResult(
      passed: passed,
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
      scorePercent: scorePercent,
      integrityFlags: integrityFlags,
      integrityPassed: integrityPassed,
    );

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF0C1626),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: passed
                ? const Color(0xFF54F7B3).withOpacity(0.45)
                : const Color(0xFFFF6B8B).withOpacity(0.45),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                passed ? Icons.verified_rounded : Icons.gpp_bad_rounded,
                size: 56,
                color: passed
                    ? const Color(0xFF54F7B3)
                    : const Color(0xFFFF6B8B),
              ),
              const SizedBox(height: 12),
              Text(
                _buildResultTitle(
                  knowledgePassed: knowledgePassed,
                  integrityPassed: integrityPassed,
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                _buildResultMessage(
                  scorePercent: scorePercent,
                  correctAnswers: correctAnswers,
                  totalQuestions: totalQuestions,
                  integrityFlags: integrityFlags,
                  integrityPassed: integrityPassed,
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              if (!integrityPassed)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B8B).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFFF6B8B).withOpacity(0.35),
                    ),
                  ),
                  child: const Text(
                    'Integrity failure: app switching was detected during the quiz attempt.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFFFB7C5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(passed ? 'Complete Subject' : 'Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!mounted) return;
    Navigator.pop(context, result);
  }
  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF08111F),
            Color(0xFF0D1A2D),
            Color(0xFF071523),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: _isLoading
            ? _QuizLoadingView(
                subject: widget.subject,
                onCancel: _cancelAttempt,
              )
            : _errorMessage != null
                ? _QuizErrorView(
                    message: _errorMessage!,
                    onRetry: _loadQuestions,
                    onCancel: _cancelAttempt,
                  )
                : _QuizBody(
                    subject: widget.subject,
                    specialization: widget.specialization,
                    currentIndex: _currentIndex,
                    questions: _questions,
                    answers: _answers,
                    isSubmitting: _isSubmitting,
                    onCancel: _cancelAttempt,
                    onSelectAnswer: _selectAnswer,
                    onNext: _goNext,
                    onPrevious: _goPrevious,
                    onSubmit: _submitQuiz,
                  ),
      ),
    );
  }
}

class _QuizLoadingView extends StatelessWidget {
  final Subject subject;
  final Future<void> Function() onCancel;

  const _QuizLoadingView({
    required this.subject,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QuizTopBar(
            title: 'Generating Exam',
            subtitle: subject.name,
            onCancel: onCancel,
          ),
          const SizedBox(height: 36),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF5EE7FF).withOpacity(0.4),
              ),
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF5EE7FF).withOpacity(0.18),
                  Colors.transparent,
                ],
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.all(22),
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Building a 20-question hard quiz with screenshot protection enabled.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Passing score: 60% or higher',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 26),
        ],
      ),
    );
  }
}

class _QuizErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;
  final Future<void> Function() onCancel;

  const _QuizErrorView({
    required this.message,
    required this.onRetry,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QuizTopBar(
            title: 'Quiz Error',
            subtitle: 'Could not generate the attempt',
            onCancel: onCancel,
          ),
          const SizedBox(height: 26),
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFFF8E8E),
            size: 54,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuizBody extends StatelessWidget {
  final Subject subject;
  final String specialization;
  final int currentIndex;
  final List<QuizQuestion> questions;
  final List<int?> answers;
  final bool isSubmitting;
  final Future<void> Function() onCancel;
  final void Function(int optionIndex) onSelectAnswer;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final Future<void> Function() onSubmit;

  const _QuizBody({
    required this.subject,
    required this.specialization,
    required this.currentIndex,
    required this.questions,
    required this.answers,
    required this.isSubmitting,
    required this.onCancel,
    required this.onSelectAnswer,
    required this.onNext,
    required this.onPrevious,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final question = questions[currentIndex];
    final selectedAnswer = answers[currentIndex];
    final progress = (currentIndex + 1) / questions.length;
    final answeredCount = answers.where((answer) => answer != null).length;
    final passingCount = (questions.length * 0.6).ceil();

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
      child: Column(
        children: [
          _QuizTopBar(
            title: subject.code,
            subtitle: specialization,
            onCancel: onCancel,
          ),
          const SizedBox(height: 12),
          _QuizInfoStrip(
            currentQuestion: currentIndex + 1,
            totalQuestions: questions.length,
            answeredCount: answeredCount,
            passingCount: passingCount,
            progress: progress,
          ),
          const SizedBox(height: 18),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question ${currentIndex + 1}',
                      style: const TextStyle(
                        color: Color(0xFF5EE7FF),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      question.question,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ...List.generate(question.choices.length, (index) {
                      final isSelected = selectedAnswer == index;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: isSubmitting ? null : () => onSelectAnswer(index),
                          borderRadius: BorderRadius.circular(18),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: isSelected
                                  ? const Color(0xFF17385D)
                                  : const Color(0xFF101A2A),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF5EE7FF)
                                    : Colors.white.withOpacity(0.08),
                                width: isSelected ? 1.6 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF5EE7FF)
                                            .withOpacity(0.16),
                                        blurRadius: 16,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _ChoiceBullet(
                                  label: String.fromCharCode(65 + index),
                                  isSelected: isSelected,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    question.choices[index],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: currentIndex == 0 || isSubmitting ? null : onPrevious,
                  child: const Text('Previous'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: currentIndex == questions.length - 1
                    ? FilledButton(
                        onPressed: isSubmitting ? null : onSubmit,
                        child: Text(isSubmitting ? 'Submitting...' : 'Finish Quiz'),
                      )
                    : FilledButton(
                        onPressed:
                            selectedAnswer == null || isSubmitting ? null : onNext,
                        child: const Text('Next'),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuizTopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final Future<void> Function() onCancel;

  const _QuizTopBar({
    required this.title,
    required this.subtitle,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onCancel,
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    );
  }
}

class _QuizInfoStrip extends StatelessWidget {
  final int currentQuestion;
  final int totalQuestions;
  final int answeredCount;
  final int passingCount;
  final double progress;

  const _QuizInfoStrip({
    required this.currentQuestion,
    required this.totalQuestions,
    required this.answeredCount,
    required this.passingCount,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final remainingToPass = math.max(0, passingCount - answeredCount);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF101927),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatPill(
                  title: 'Question',
                  value: '$currentQuestion / $totalQuestions',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatPill(
                  title: 'Answered',
                  value: '$answeredCount / $totalQuestions',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatPill(
                  title: 'Need to pass',
                  value: '$passingCount',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white10,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              remainingToPass == 0
                  ? 'You already answered enough questions to still be eligible for passing.'
                  : 'Keep going. You still need at least $remainingToPass answered questions before you can possibly clear the minimum pass target.',
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String title;
  final String value;

  const _StatPill({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceBullet extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _ChoiceBullet({
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? const Color(0xFF5EE7FF) : Colors.white12,
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color(0xFF04101D) : Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
