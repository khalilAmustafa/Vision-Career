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
      id: 'device_problem',
      title:
          'Your phone or a favorite gadget suddenly stops working. What is the very first thing you do?',
      options: [
        _InterestOption(
          label:
              'I try to understand the logic behind the failure and search for the exact error or system cause.',
          scores: {
            'it': 3,
            'engineering': 1,
            'science': 2,
            'logic': 3,
            'building': 1,
          },
        ),
        _InterestOption(
          label:
              'I check the physical build, heat, wiring, or structure to see what failed mechanically.',
          scores: {
            'engineering': 3,
            'it': 1,
            'science': 1,
            'physics_strength': 2,
            'building': 2,
          },
        ),
        _InterestOption(
          label:
              'I think about whether repairing it is worth the money, value, or replacement cost.',
          scores: {
            'finance': 3,
            'business': 2,
            'analysis': 2,
            'numbers': 2,
          },
        ),
        _InterestOption(
          label:
              'I focus on how the experience changed, how frustrating it feels, and how the interface could be better.',
          scores: {
            'design': 3,
            'architecture': 2,
            'visual': 2,
            'creativity': 2,
            'people': 1,
          },
        ),
      ],
    ),
    _InterestQuestion(
      id: 'strategy_game',
      title:
          'You are playing a complex strategy game. What path to victory sounds most satisfying?',
      options: [
        _InterestOption(
          label:
              'Finding a logic loop, automation trick, or system advantage that changes the whole game.',
          scores: {
            'it': 3,
            'logic': 3,
            'engineering': 1,
            'analysis': 1,
          },
        ),
        _InterestOption(
          label:
              'Building the strongest, most efficient, and most durable setup or defense system.',
          scores: {
            'engineering': 3,
            'it': 1,
            'building': 3,
            'physics_strength': 1,
          },
        ),
        _InterestOption(
          label:
              'Optimizing resources, managing wealth, and scaling faster than everyone else.',
          scores: {
            'finance': 3,
            'business': 2,
            'analysis': 2,
            'numbers': 2,
          },
        ),
        _InterestOption(
          label:
              'Studying patterns from previous rounds to predict what will happen next.',
          scores: {
            'science': 3,
            'research': 2,
            'analysis': 2,
            'logic': 1,
          },
        ),
      ],
    ),
    _InterestQuestion(
      id: 'deep_dive_content',
      title:
          'You are watching a deep-dive video or reading a long article. Which topic keeps you locked in until the end?',
      options: [
        _InterestOption(
          label:
              'How a powerful digital system, app, or algorithm actually works under the hood.',
          scores: {
            'it': 3,
            'logic': 2,
            'building': 1,
            'engineering': 1,
          },
        ),
        _InterestOption(
          label:
              'How a large machine, structure, or physical construction works in real life.',
          scores: {
            'engineering': 3,
            'physics_strength': 2,
            'building': 2,
            'science': 1,
          },
        ),
        _InterestOption(
          label:
              'The biological, chemical, or scientific explanation behind a real-world phenomenon.',
          scores: {
            'science': 3,
            'research': 3,
            'chemistry_strength': 1,
            'lab_interest': 2,
          },
        ),
        _InterestOption(
          label:
              'A brand, market, or visual concept becoming successful through strong strategy and presentation.',
          scores: {
            'finance': 2,
            'business': 2,
            'design': 2,
            'creativity': 1,
            'people': 1,
          },
        ),
      ],
    ),
    _InterestQuestion(
      id: 'project_investment',
      title:
          'If you had funding to start a serious project today, what would you be most excited to build?',
      options: [
        _InterestOption(
          label:
              'A digital product, tool, or app that solves a frustrating problem.',
          scores: {
            'it': 3,
            'engineering': 1,
            'building': 2,
            'logic': 2,
          },
        ),
        _InterestOption(
          label:
              'A mechanical or technical product that improves a physical task.',
          scores: {
            'engineering': 3,
            'it': 1,
            'building': 3,
            'physics_strength': 2,
          },
        ),
        _InterestOption(
          label:
              'A research-driven or science-based project where I can test ideas and learn from results.',
          scores: {
            'science': 3,
            'research': 3,
            'lab_interest': 2,
            'analysis': 1,
          },
        ),
        _InterestOption(
          label:
              'A business, brand, or creative concept with strong market or visual potential.',
          scores: {
            'finance': 2,
            'business': 2,
            'design': 2,
            'architecture': 1,
            'creativity': 2,
          },
        ),
      ],
    ),
    _InterestQuestion(
      id: 'team_role',
      title:
          'In a high-stakes team project, which role do you naturally take without being asked?',
      options: [
        _InterestOption(
          label:
              'I become the builder who chooses the tools and makes sure the technical side works.',
          scores: {
            'it': 3,
            'engineering': 2,
            'building': 2,
            'logic': 1,
          },
        ),
        _InterestOption(
          label:
              'I become the person who checks facts, verifies evidence, and keeps things accurate.',
          scores: {
            'science': 3,
            'research': 2,
            'analysis': 2,
            'logic': 1,
          },
        ),
        _InterestOption(
          label:
              'I manage the plan, timeline, priorities, money, and practical decisions.',
          scores: {
            'finance': 3,
            'business': 3,
            'analysis': 2,
            'people': 1,
          },
        ),
        _InterestOption(
          label:
              'I refine the concept, visuals, experience, or presentation so it lands better.',
          scores: {
            'design': 3,
            'architecture': 2,
            'visual': 3,
            'creativity': 2,
            'people': 1,
          },
        ),
      ],
    ),
    _InterestQuestion(
      id: 'friction_point',
      title:
          'What annoys you the most when using a product, service, or system?',
      options: [
        _InterestOption(
          label: 'Too many steps, weak logic, or workflows that should be simpler.',
          scores: {
            'it': 3,
            'engineering': 1,
            'finance': 1,
            'logic': 2,
            'analysis': 1,
          },
        ),
        _InterestOption(
          label:
              'A system that feels unstable, fragile, unsafe, or likely to break under pressure.',
          scores: {
            'engineering': 3,
            'it': 2,
            'building': 2,
            'physics_strength': 1,
          },
        ),
        _InterestOption(
          label:
              'Hidden costs, unclear tradeoffs, or decisions that ignore value and efficiency.',
          scores: {
            'finance': 3,
            'business': 2,
            'analysis': 2,
            'numbers': 1,
          },
        ),
        _InterestOption(
          label:
              'A confusing, messy, or visually inconsistent experience that feels badly designed.',
          scores: {
            'design': 3,
            'architecture': 2,
            'visual': 2,
            'creativity': 1,
          },
        ),
      ],
    ),
    _InterestQuestion(
      id: 'trip_role',
      title:
          'You and your friends are planning a big trip. Which part would you most want to handle?',
      options: [
        _InterestOption(
          label:
              'Setting up the shared systems: calendar, maps, chat, plan, and digital organization.',
          scores: {
            'it': 3,
            'logic': 1,
            'building': 1,
            'people': 1,
          },
        ),
        _InterestOption(
          label:
              'Figuring out transport, packing constraints, and the most practical physical setup.',
          scores: {
            'engineering': 3,
            'building': 2,
            'analysis': 1,
            'physics_strength': 1,
          },
        ),
        _InterestOption(
          label:
              'Managing the money, ticket choices, deals, and best value for the group.',
          scores: {
            'finance': 3,
            'business': 2,
            'numbers': 2,
            'analysis': 1,
          },
        ),
        _InterestOption(
          label:
              'Choosing the atmosphere, places, visual vibe, and overall experience of the trip.',
          scores: {
            'design': 3,
            'architecture': 2,
            'visual': 3,
            'people': 1,
          },
        ),
      ],
    ),
    _InterestQuestion(
      id: 'city_builder',
      title:
          'In a city-building game, what part would keep you playing the longest?',
      options: [
        _InterestOption(
          label:
              'Connecting systems so the city runs smoothly like one intelligent network.',
          scores: {
            'it': 3,
            'engineering': 1,
            'logic': 2,
            'building': 2,
          },
        ),
        _InterestOption(
          label:
              'Making the roads, bridges, and structures strong, efficient, and dependable.',
          scores: {
            'engineering': 3,
            'building': 3,
            'physics_strength': 2,
            'architecture': 1,
          },
        ),
        _InterestOption(
          label:
              'Watching the economy, taxes, growth, and resource decisions to keep the city successful.',
          scores: {
            'finance': 3,
            'business': 3,
            'analysis': 2,
            'numbers': 2,
          },
        ),
        _InterestOption(
          label:
              'Designing the look, layout, parks, and visual feel of the city.',
          scores: {
            'design': 3,
            'architecture': 3,
            'visual': 3,
            'creativity': 2,
          },
        ),
      ],
    ),
  ];

  static const List<String> _signalPriority = [
    'it',
    'engineering',
    'science',
    'finance',
    'design',
    'architecture',
    'business',
    'logic',
    'analysis',
    'research',
    'building',
    'visual',
    'creativity',
    'numbers',
    'people',
    'math_strength',
    'physics_strength',
    'chemistry_strength',
    'lab_interest',
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
      ..sort((a, b) {
        final scoreCompare = b.value.compareTo(a.value);
        if (scoreCompare != 0) return scoreCompare;
        return _priorityIndex(a.key).compareTo(_priorityIndex(b.key));
      });

    final topDomains = [
      'it',
      'engineering',
      'science',
      'finance',
      'design',
      'architecture',
    ]
      ..sort((a, b) {
        final scoreCompare = scores[b]!.compareTo(scores[a]!);
        if (scoreCompare != 0) return scoreCompare;
        return _priorityIndex(a).compareTo(_priorityIndex(b));
      });

    final profile = <String, dynamic>{
      'question_count': _questions.length,
      'raw_scores': scores,
      'normalized_scores': normalized,
      'top_signals': sortedSignals
          .where((entry) => entry.value > 0)
          .map(
            (entry) => {
              'signal': entry.key,
              'score': entry.value,
            },
          )
          .toList(growable: false),
      'dominant_college_signals': {
        'it': scores['it'],
        'science': scores['science'],
        'finance': scores['finance'],
        'architecture': scores['architecture'],
        'engineering': scores['engineering'],
        'design': scores['design'],
      },
      'top_domains': topDomains.take(3).map((domain) {
        return {
          'domain': domain,
          'score': scores[domain],
        };
      }).toList(growable: false),
      'profile_summary': _buildProfileSummary(scores, topDomains),
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

  int _priorityIndex(String key) {
    final index = _signalPriority.indexOf(key);
    return index == -1 ? _signalPriority.length : index;
  }

  String _buildProfileSummary(Map<String, int> scores, List<String> topDomains) {
    final primary = _domainLabel(topDomains[0]);
    final secondary = _domainLabel(topDomains[1]);
    final strengths = <String>[];

    if (scores['logic']! >= 4) strengths.add('strong systems thinking');
    if (scores['analysis']! >= 4 || scores['numbers']! >= 4) {
      strengths.add('clear analytical decision making');
    }
    if (scores['research']! >= 4 || scores['lab_interest']! >= 3) {
      strengths.add('interest in evidence and investigation');
    }
    if (scores['building']! >= 4) strengths.add('hands-on builder energy');
    if (scores['visual']! >= 4 || scores['creativity']! >= 4) {
      strengths.add('visual and creative preference');
    }

    final strengthText = strengths.isEmpty
        ? 'a mixed preference profile'
        : strengths.take(2).join(' with ');

    return 'Top direction: $primary. Secondary direction: $secondary. The answers show $strengthText.';
  }

  String _domainLabel(String key) {
    switch (key) {
      case 'it':
        return 'IT';
      case 'engineering':
        return 'Engineering';
      case 'science':
        return 'Science';
      case 'finance':
        return 'Finance';
      case 'design':
        return 'Design';
      case 'architecture':
        return 'Architecture';
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _selectedByQuestion.length / _questions.length;

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Preference Questions',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Answer the scenario questions honestly. This stage is only trying to understand your natural direction before the AI chat and fundamentals quiz.',
                      style: TextStyle(color: Colors.white70, height: 1.45),
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: Colors.white.withOpacity(0.08),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF5EE7FF),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${_selectedByQuestion.length}/${_questions.length} answered',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
                itemCount: _questions.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
