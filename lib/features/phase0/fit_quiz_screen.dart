import 'package:flutter/material.dart';

import '../../core/services/phase0_session_service.dart';
import 'fit_result_screen.dart';

class FitQuizScreen extends StatefulWidget {
  const FitQuizScreen({super.key});

  @override
  State<FitQuizScreen> createState() => _FitQuizScreenState();
}

class _FitQuizScreenState extends State<FitQuizScreen> {
  final Phase0SessionService _sessionService = Phase0SessionService();

  static const List<_AptitudeQuestion> _questions = [
    _AptitudeQuestion(
      question: 'A company buys equipment for 12,000 JOD and expects a salvage value of 2,000 JOD after 5 years. Using straight-line depreciation, what is the annual depreciation expense?',
      category: 'finance_score',
      answers: ['1,600 JOD', '2,000 JOD', '2,400 JOD', '2,800 JOD'],
      correctIndex: 1,
    ),
    _AptitudeQuestion(
      question: 'If f(x) = 2x² - 3x + 1, what is f(3)?',
      category: 'math_score',
      answers: ['8', '10', '12', '14'],
      correctIndex: 1,
    ),
    _AptitudeQuestion(
      question: 'A car increases its speed uniformly from 10 m/s to 22 m/s in 4 seconds. What is its acceleration?',
      category: 'physics_score',
      answers: ['2 m/s²', '3 m/s²', '4 m/s²', '5 m/s²'],
      correctIndex: 1,
    ),
    _AptitudeQuestion(
      question: 'What is the molar mass of H₂SO₄?',
      category: 'chemistry_score',
      answers: ['66 g/mol', '82 g/mol', '98 g/mol', '118 g/mol'],
      correctIndex: 2,
    ),
    _AptitudeQuestion(
      question: 'If revenue is 90,000 and total cost is 63,000, what is the profit margin on revenue?',
      category: 'finance_score',
      answers: ['20%', '25%', '30%', '42.9%'],
      correctIndex: 2,
    ),
    _AptitudeQuestion(
      question: 'Solve: 3x - 7 = 14',
      category: 'math_score',
      answers: ['5', '6', '7', '8'],
      correctIndex: 2,
    ),
    _AptitudeQuestion(
      question: 'What is the equivalent resistance of two resistors 6Ω and 3Ω connected in parallel?',
      category: 'physics_score',
      answers: ['1Ω', '2Ω', '3Ω', '9Ω'],
      correctIndex: 1,
    ),
    _AptitudeQuestion(
      question: 'Which statement is correct about pH?',
      category: 'chemistry_score',
      answers: [
        'A solution with pH 2 is less acidic than pH 6',
        'A solution with pH 7 is neutral',
        'A solution with pH 10 is strongly acidic',
        'pH does not relate to hydrogen ion concentration',
      ],
      correctIndex: 1,
    ),
    _AptitudeQuestion(
      question: 'An investment grows from 5,000 to 5,750. What is the percentage increase?',
      category: 'finance_score',
      answers: ['10%', '12%', '15%', '17.5%'],
      correctIndex: 2,
    ),
    _AptitudeQuestion(
      question: 'What is the slope of the line passing through (2, 3) and (6, 11)?',
      category: 'math_score',
      answers: ['1', '2', '3', '4'],
      correctIndex: 1,
    ),
    _AptitudeQuestion(
      question: 'A force of 20 N acts on an object of mass 4 kg. What is the acceleration?',
      category: 'physics_score',
      answers: ['2 m/s²', '4 m/s²', '5 m/s²', '8 m/s²'],
      correctIndex: 2,
    ),
    _AptitudeQuestion(
      question: 'How many moles are in 18 g of water (H₂O)?',
      category: 'chemistry_score',
      answers: ['0.5 mol', '1 mol', '1.5 mol', '2 mol'],
      correctIndex: 1,
    ),
    _AptitudeQuestion(
      question: 'If an item costs 80 JOD after a 20% discount, what was its original price?',
      category: 'finance_score',
      answers: ['90 JOD', '96 JOD', '100 JOD', '120 JOD'],
      correctIndex: 2,
    ),
    _AptitudeQuestion(
      question: 'What is the value of 2⁵ × 2²?',
      category: 'math_score',
      answers: ['32', '64', '128', '256'],
      correctIndex: 2,
    ),
    _AptitudeQuestion(
      question: 'Which quantity is a vector?',
      category: 'physics_score',
      answers: ['Speed', 'Distance', 'Mass', 'Velocity'],
      correctIndex: 3,
    ),
    _AptitudeQuestion(
      question: 'Which bond type usually forms between sodium and chlorine in NaCl?',
      category: 'chemistry_score',
      answers: ['Covalent bond', 'Hydrogen bond', 'Ionic bond', 'Metallic bond'],
      correctIndex: 2,
    ),
  ];

  final Map<int, int> _selectedAnswers = {};
  bool _isSaving = false;

  Future<void> _finishQuiz() async {
    if (_selectedAnswers.length != _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Answer all quiz questions first.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final categoryTotals = <String, int>{
      'finance_score': 0,
      'math_score': 0,
      'physics_score': 0,
      'chemistry_score': 0,
    };

    final categoryCorrect = <String, int>{
      'finance_score': 0,
      'math_score': 0,
      'physics_score': 0,
      'chemistry_score': 0,
    };

    int totalCorrect = 0;

    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      categoryTotals.update(question.category, (value) => value + 1);

      if (_selectedAnswers[i] == question.correctIndex) {
        totalCorrect += 1;
        categoryCorrect.update(question.category, (value) => value + 1);
      }
    }

    final summary = <String, dynamic>{
      'total_questions': _questions.length,
      'correct_answers': totalCorrect,
      'score_percent': double.parse(
        ((totalCorrect / _questions.length) * 100).toStringAsFixed(1),
      ),
      'finance_score': _ratio(
        categoryCorrect['finance_score']!,
        categoryTotals['finance_score']!,
      ),
      'math_score': _ratio(
        categoryCorrect['math_score']!,
        categoryTotals['math_score']!,
      ),
      'physics_score': _ratio(
        categoryCorrect['physics_score']!,
        categoryTotals['physics_score']!,
      ),
      'chemistry_score': _ratio(
        categoryCorrect['chemistry_score']!,
        categoryTotals['chemistry_score']!,
      ),
      'completed_at': DateTime.now().toIso8601String(),
    };

    try {
      await _sessionService.saveAptitudeSummary(summary);

      if (!mounted) return;

      setState(() => _isSaving = false);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FitResultScreen()),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save quiz results: $error')),
      );
    }
  }

  double _ratio(int correct, int total) {
    if (total == 0) return 0;
    return double.parse((correct / total).toStringAsFixed(2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08111F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Find Your Fit • Stage 3'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF091321), Color(0xFF0D1A2D), Color(0xFF06101B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Academic Readiness Quiz',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This quiz now focuses more on finance, mathematics, physics, and chemistry signals instead of simple reading questions.',
                      style: TextStyle(color: Colors.white70, height: 1.45),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
                itemCount: _questions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final question = _questions[index];

                  return _QuizQuestionCard(
                    index: index + 1,
                    question: question,
                    selectedIndex: _selectedAnswers[index],
                    onSelected: (value) {
                      setState(() {
                        _selectedAnswers[index] = value;
                      });
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _isSaving ? null : _finishQuiz,
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.2),
                        )
                      : const Text('See My Specialty Suggestions'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizQuestionCard extends StatelessWidget {
  final int index;
  final _AptitudeQuestion question;
  final int? selectedIndex;
  final ValueChanged<int> onSelected;

  const _QuizQuestionCard({
    required this.index,
    required this.question,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111E34),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question $index',
            style: const TextStyle(
              color: Color(0xFFFFD98A),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            question.question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          ...List.generate(question.answers.length, (answerIndex) {
            final isSelected = selectedIndex == answerIndex;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => onSelected(answerIndex),
                borderRadius: BorderRadius.circular(18),
                child: Ink(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: isSelected
                        ? const Color(0xFF3B2F17)
                        : Colors.white.withOpacity(0.03),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFFD98A)
                          : Colors.white.withOpacity(0.08),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          question.answers[answerIndex],
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                      Icon(
                        isSelected
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        color: isSelected
                            ? const Color(0xFFFFD98A)
                            : Colors.white38,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _AptitudeQuestion {
  final String question;
  final String category;
  final List<String> answers;
  final int correctIndex;

  const _AptitudeQuestion({
    required this.question,
    required this.category,
    required this.answers,
    required this.correctIndex,
  });
}
