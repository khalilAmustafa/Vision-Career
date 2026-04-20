import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import '../../core/services/phase0_gemini_service.dart';
import '../../core/services/phase0_mapping_service.dart';
import '../../core/services/phase0_session_service.dart';
import 'fit_quiz_screen.dart';

class FitChatScreen extends StatefulWidget {
  const FitChatScreen({super.key});

  @override
  State<FitChatScreen> createState() => _FitChatScreenState();
}

class _FitChatScreenState extends State<FitChatScreen> {
  final Phase0SessionService _sessionService = Phase0SessionService();
  final Phase0GeminiService _geminiService = const Phase0GeminiService();
  final Phase0MappingService _mappingService = Phase0MappingService();
  final TextEditingController _controller = TextEditingController();

  List<String> _questions = const [];
  final List<Map<String, dynamic>> _transcript = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  int _currentIndex = 0;
  String? _errorMessage;

  static const List<String> _fallbackQuestions = [
    'Which college direction currently feels most attractive to you, even if you are not fully sure yet, and why?',
    'Which subjects give you more energy: math and physics, chemistry and biology, finance and business, or design and visual work?',
    'Do you see yourself more in a lab, a technical/software team, a finance or business environment, or a design/architecture setting?',
    'Would you rather analyze numbers and risk, investigate scientific ideas, build technical solutions, or design spaces and experiences?',
    'What kind of future work would make you feel proud every day?',
  ];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      final profile = await _sessionService.getInterestProfile();
      final allowed = await _mappingService.getAllowedSpecialties();
      if (!mounted) return;

      final locale = Localizations.localeOf(context).languageCode;
      final language = locale == 'ar' ? 'Arabic' : 'English';
      final questions = await _geminiService
          .buildGuidedChatQuestions(
        interestProfile: profile ?? const {},
        allowedSpecialties: allowed,
        language: language,
      )
          .timeout(const Duration(seconds: 10)); // ✅ prevent freeze

      if (!mounted) return;

      setState(() {
        _questions = questions.isNotEmpty ? questions : _fallbackQuestions;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _questions = _fallbackQuestions;
        _isLoading = false;
        // ❌ DON'T use l10n here
        _errorMessage = 'fallback'; // temporary flag
      });
    }
  }

  Future<void> _submitAnswer() async {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final language = locale == 'ar' ? 'Arabic' : 'English';
    final answer = _controller.text.trim();
    if (answer.isEmpty || _isSubmitting || _questions.isEmpty) return;

    final question = _questions[_currentIndex];

    setState(() {
      _transcript.add({'role': 'assistant', 'text': question});
      _transcript.add({'role': 'user', 'text': answer});
      _controller.clear();
    });

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex += 1;
      });
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final summary = await _geminiService.summarizeDiscoveryChat(
        transcript: _transcript,
        language: language,
      );

      await _sessionService.saveChatQuestions(_questions);
      await _sessionService.saveChatTranscript(_transcript);
      await _sessionService.saveChatSummary(summary);

      if (!mounted) return;

      setState(() => _isSubmitting = false);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FitQuizScreen()),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = l10n.fitChatFinalizeError;
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.fitChatSummaryFailed(error.toString()))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF08111F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.fitChatTitle),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF091321), Color(0xFF0D1A2D), Color(0xFF06101B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.fitChatProgress(
                        _currentIndex + 1,
                        _questions.length,
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.fitChatDescription,
                      style: const TextStyle(
                        color: Colors.white70,
                        height: 1.45,
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Color(0xFFFFD98A),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                children: [
                  for (int i = 0; i < _transcript.length; i++)
                    _ChatBubble(
                      text: _transcript[i]['text'].toString(),
                      isUser: _transcript[i]['role'] == 'user',
                    ),
                  _ChatBubble(
                    text: _questions[_currentIndex],
                    isUser: false,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 2,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: l10n.fitChatHint,
                        hintStyle:
                        const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 56,
                    child: FilledButton(
                      onPressed: _isSubmitting ? null : _submitAnswer,
                      child: _isSubmitting
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                        ),
                      )
                          : Text(
                        _currentIndex == _questions.length - 1
                            ? l10n.finish
                            : l10n.next,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const _ChatBubble({
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: isUser
              ? const Color(0xFF1C5D7D)
              : const Color(0xFF111E34),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, height: 1.45),
        ),
      ),
    );
  }
}
