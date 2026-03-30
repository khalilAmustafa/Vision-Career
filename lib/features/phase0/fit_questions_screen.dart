import 'package:flutter/material.dart';

import '../../core/services/phase0_session_service.dart';
import 'fit_chat_screen.dart';

class FitQuestionsScreen extends StatefulWidget {
  const FitQuestionsScreen({super.key});

  @override
  State<FitQuestionsScreen> createState() => _FitQuestionsScreenState();
}

class _FitQuestionsScreenState extends State<FitQuestionsScreen> {
  final Phase0SessionService _sessionService = Phase0SessionService();

  static const List<_InterestQuestion> _questions = [
    _InterestQuestion(
      id: 'subject_family',
      title: 'Which group of school subjects feels closest to you?',
      options: [
        _InterestOption(
          label: 'Math, physics, and technical problem solving',
          scores: {
            'engineering': 3,
            'it': 2,
            'science': 2,
            'math_strength': 2,
            'physics_strength': 2,
            'logic': 2,
          },
        ),
        _InterestOption(
          label: 'Biology, chemistry, labs, and understanding natural systems',
          scores: {
            'science': 3,
            'chemistry_strength': 2,
            'lab_interest': 2,
            'research': 1,
          },
        ),
        _InterestOption(
          label: 'Business, finance, economics, and market thinking',
          scores: {
            'finance': 3,
            'business': 3,
            'numbers': 2,
            'analysis': 1,
          },
        ),
        _InterestOption(
          label: 'Drawing, design, visual ideas, spaces, and creative concepts',
          scores: {
            'architecture': 3,
            'design': 3,
            'creativity': 2,
            'visual': 2,
          },
        ),
      ],
    ),
    _InterestQuestion(
      id: 'problem_type',
      title: 'Which kind of problem would you rather solve?',
      options: [
        _InterestOption(
          label: 'Building or improving systems, devices, or software',
          scores: {
            'engineering': 2,
            'it': 3,
            'logic': 2,
            'building': 2,
          },
        ),
        _InterestOption(
          label: 'Understanding why a scientific process happens',
          scores: {
            'science': 3,
            'research': 2,
            'chemistry_strength': 1,
            'physics_strength': 1,
          },
        ),
        _InterestOption(
          label: 'Analyzing money, risk, decisions, or business performance',
          scores: {
            'finance': 3,
            'business': 2,
            'analysis': 2,
            'numbers': 2,
          },
        ),
        _InterestOption(
          label: 'Designing a place, product look, or visual experience',
          scores: {
            'architecture': 3,
            'design': 3,
            'creativity': 2,
            'visual': 2,
          },
        ),
      ],
    ),
    _InterestQuestion(
      id: 'math_comfort',
      title: 'How comfortable are you with mathematics?',
      options: [
        _InterestOption(
          label: 'Very comfortable, especially equations and calculations',
          scores: {
            'math_strength': 3,
            'engineering': 2,
            'finance': 2,
            'science': 1,
            'logic': 2,
          },
        ),
        _InterestOption(
          label: 'Comfortable when the goal is clear',
          scores: {
            'math_strength': 2,
            'finance': 1,
            'engineering': 1,
            'analysis': 1,
          },
        ),
        _InterestOption(
          label: 'Neutral',
          scores: {
            'creativity': 1,
            'business': 1,
          },
        ),
        _InterestOption(
          label: 'I prefer paths that depend less on heavy math',
          scores: {
            'architecture': 1,
            'design': 2,
            'people': 1,
          },
        ),
      ],
    ),
    _InterestQuestion(
      id: 'physics_chemistry_pull',
      title: 'Which statement sounds more like you?',
      options: [
        _InterestOption(
          label: 'I enjoy physics ideas more than chemistry ideas',
          scores: {
            'engineering': 3,
            'physics_strength': 3,
            'science': 1,
          },
        ),
        _InterestOption(
          label: 'I enjoy chemistry ideas more than physics ideas',
          scores: {
            'science': 3,
            'chemistry_strength': 3,
            'lab_interest': 1,
          },
        ),
        _InterestOption(
          label: 'I enjoy both if there is real-world application',
          scores: {
            'science': 2,
            'engineering': 2,
            'research': 1,
          },
        ),
        _InterestOption(
          label: 'Neither is my main strength',
          scores: {
            'finance': 1,
            'architecture': 1,
            'design': 1,
            'business': 1,
          },
        ),
      ],
    ),
    _InterestQuestion(
      id: 'work_environment',
      title: 'Which environment feels most motivating?',
      options: [
        _InterestOption(
          label: 'Labs, experiments, and scientific investigation',
          scores: {
            'science': 3,
            'research': 3,
            'lab_interest': 2,
          },
        ),
        _InterestOption(
          label: 'Companies, startups, banks, or business teams',
          scores: {
            'finance': 3,
            'business': 3,
            'people': 1,
          },
        ),
        _InterestOption(
          label: 'Technical teams building software or engineered solutions',
          scores: {
            'it': 3,
            'engineering': 2,
            'building': 2,
            'logic': 1,
          },
        ),
        _InterestOption(
          label: 'Studios, design spaces, or project-based creative teams',
          scores: {
            'architecture': 3,
            'design': 3,
            'visual': 2,
          },
        ),
      ],
    ),
    _InterestQuestion(
      id: 'future_output',
      title: 'Which result would make you proudest?',
      options: [
        _InterestOption(
          label: 'A working app, technical product, or smart system',
          scores: {
            'it': 3,
            'engineering': 2,
            'building': 2,
            'logic': 1,
          },
        ),
        _InterestOption(
          label: 'A research result, scientific explanation, or experiment outcome',
          scores: {
            'science': 3,
            'research': 3,
            'lab_interest': 1,
          },
        ),
        _InterestOption(
          label: 'A strong financial plan, business solution, or market strategy',
          scores: {
            'finance': 3,
            'business': 3,
            'analysis': 2,
          },
        ),
        _InterestOption(
          label: 'A designed space, concept, or visual identity',
          scores: {
            'architecture': 3,
            'design': 3,
            'creativity': 2,
            'visual': 2,
          },
        ),
      ],
    ),
    _InterestQuestion(
      id: 'decision_style',
      title: 'When making a decision, what do you trust most?',
      options: [
        _InterestOption(
          label: 'Measurements, formulas, and technical logic',
          scores: {
            'engineering': 2,
            'it': 1,
            'finance': 1,
            'math_strength': 2,
            'logic': 2,
          },
        ),
        _InterestOption(
          label: 'Evidence, experiments, and testing',
          scores: {
            'science': 3,
            'research': 2,
            'lab_interest': 1,
          },
        ),
        _InterestOption(
          label: 'Numbers, trends, and financial/business impact',
          scores: {
            'finance': 3,
            'business': 2,
            'analysis': 2,
            'numbers': 2,
          },
        ),
        _InterestOption(
          label: 'Vision, aesthetics, and how people experience the result',
          scores: {
            'architecture': 2,
            'design': 3,
            'people': 1,
            'visual': 2,
          },
        ),
      ],
    ),
    _InterestQuestion(
      id: 'team_role',
      title: 'In a team, which role sounds most like you?',
      options: [
        _InterestOption(
          label: 'The technical builder or problem solver',
          scores: {
            'it': 3,
            'engineering': 2,
            'building': 2,
            'logic': 1,
          },
        ),
        _InterestOption(
          label: 'The investigator or experimenter',
          scores: {
            'science': 3,
            'research': 3,
            'lab_interest': 1,
          },
        ),
        _InterestOption(
          label: 'The analyst, planner, or decision-maker',
          scores: {
            'finance': 3,
            'business': 3,
            'analysis': 2,
          },
        ),
        _InterestOption(
          label: 'The designer, concept creator, or visual thinker',
          scores: {
            'architecture': 3,
            'design': 3,
            'creativity': 2,
          },
        ),
      ],
    ),
    _InterestQuestion(
      id: 'long_term_energy',
      title: 'What could you stay motivated learning for years?',
      options: [
        _InterestOption(
          label: 'Programming, systems, machines, or advanced technical tools',
          scores: {
            'it': 3,
            'engineering': 3,
            'building': 1,
          },
        ),
        _InterestOption(
          label: 'Scientific theories, chemistry, biology, or lab work',
          scores: {
            'science': 3,
            'research': 2,
            'chemistry_strength': 2,
          },
        ),
        _InterestOption(
          label: 'Finance, business strategy, investing, or markets',
          scores: {
            'finance': 3,
            'business': 3,
            'numbers': 1,
          },
        ),
        _InterestOption(
          label: 'Architecture, form, design, and visual creativity',
          scores: {
            'architecture': 3,
            'design': 3,
            'visual': 2,
          },
        ),
      ],
    ),
    _InterestQuestion(
      id: 'real_world_focus',
      title: 'Which real-world challenge interests you most?',
      options: [
        _InterestOption(
          label: 'Creating better digital or technical solutions',
          scores: {
            'it': 3,
            'engineering': 2,
            'building': 2,
          },
        ),
        _InterestOption(
          label: 'Understanding nature, materials, health, or scientific change',
          scores: {
            'science': 3,
            'research': 2,
            'chemistry_strength': 1,
          },
        ),
        _InterestOption(
          label: 'Improving businesses, money decisions, and economic outcomes',
          scores: {
            'finance': 3,
            'business': 3,
            'analysis': 1,
          },
        ),
        _InterestOption(
          label: 'Improving spaces, cities, and visual human experience',
          scores: {
            'architecture': 3,
            'design': 2,
            'people': 1,
            'visual': 2,
          },
        ),
      ],
    ),
  ];

  final Map<String, int> _selectedByQuestion = {};
  bool _isSaving = false;

  Future<void> _continue() async {
    if (_selectedByQuestion.length != _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Answer all questions first.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final answers = <Map<String, dynamic>>[];
    final scores = <String, int>{
      'it': 0,
      'science': 0,
      'finance': 0,
      'architecture': 0,
      'engineering': 0,
      'business': 0,
      'design': 0,
      'creativity': 0,
      'logic': 0,
      'math_strength': 0,
      'physics_strength': 0,
      'chemistry_strength': 0,
      'research': 0,
      'analysis': 0,
      'numbers': 0,
      'people': 0,
      'building': 0,
      'visual': 0,
      'lab_interest': 0,
    };

    for (final question in _questions) {
      final selectedIndex = _selectedByQuestion[question.id]!;
      final selectedOption = question.options[selectedIndex];

      answers.add({
        'question_id': question.id,
        'question': question.title,
        'selected_index': selectedIndex,
        'selected_label': selectedOption.label,
        'scores': selectedOption.scores,
      });

      selectedOption.scores.forEach((key, value) {
        scores.update(key, (current) => current + value, ifAbsent: () => value);
      });
    }

    final maxScore = scores.values.fold<int>(0, (a, b) => a > b ? a : b);
    final normalized = <String, double>{
      for (final entry in scores.entries)
        '${entry.key}_score': maxScore == 0
            ? 0
            : double.parse((entry.value / maxScore).toStringAsFixed(2)),
    };

    final sortedSignals = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final profile = <String, dynamic>{
      'raw_scores': scores,
      'normalized_scores': normalized,
      'top_signals': sortedSignals
          .map((entry) => {
                'signal': entry.key,
                'score': entry.value,
              })
          .toList(growable: false),
      'dominant_college_signals': {
        'it': scores['it'],
        'science': scores['science'],
        'finance': scores['finance'],
        'architecture': scores['architecture'],
        'engineering': scores['engineering'],
      },
      'completed_at': DateTime.now().toIso8601String(),
    };

    try {
      await _sessionService.saveEntryFlow('fit_discovery');
      await _sessionService.saveFitAnswers(answers);
      await _sessionService.saveInterestProfile(profile);

      if (!mounted) return;

      setState(() => _isSaving = false);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FitChatScreen()),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save your answers: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08111F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Find Your Fit • Stage 1'),
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
                      'College Discovery Questions',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'These questions are built to discover which college direction fits you better first: IT, Science, Finance, Architecture, or Engineering.',
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
                  final selected = _selectedByQuestion[question.id];

                  return _QuestionCard(
                    index: index + 1,
                    question: question,
                    selectedIndex: selected,
                    onSelected: (value) {
                      setState(() {
                        _selectedByQuestion[question.id] = value;
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
                  onPressed: _isSaving ? null : _continue,
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.2),
                        )
                      : Text(
                          'Continue to AI Chat (${_selectedByQuestion.length}/${_questions.length})',
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final int index;
  final _InterestQuestion question;
  final int? selectedIndex;
  final ValueChanged<int> onSelected;

  const _QuestionCard({
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
              color: Color(0xFF5EE7FF),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            question.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          ...List.generate(question.options.length, (optionIndex) {
            final option = question.options[optionIndex];
            final isSelected = selectedIndex == optionIndex;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => onSelected(optionIndex),
                borderRadius: BorderRadius.circular(18),
                child: Ink(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: isSelected
                        ? const Color(0xFF17385D)
                        : Colors.white.withOpacity(0.03),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF5EE7FF)
                          : Colors.white.withOpacity(0.08),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          option.label,
                          style: const TextStyle(
                            color: Colors.white70,
                            height: 1.35,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        isSelected
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        color: isSelected
                            ? const Color(0xFF5EE7FF)
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

class _InterestQuestion {
  final String id;
  final String title;
  final List<_InterestOption> options;

  const _InterestQuestion({
    required this.id,
    required this.title,
    required this.options,
  });
}

class _InterestOption {
  final String label;
  final Map<String, int> scores;

  const _InterestOption({
    required this.label,
    required this.scores,
  });
}
