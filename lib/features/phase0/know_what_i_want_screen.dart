import 'package:flutter/material.dart';

import '../../core/services/phase0_gemini_service.dart';
import '../../core/services/phase0_mapping_service.dart';
import 'specialty_recommendation_screen.dart';

class KnowWhatIWantScreen extends StatefulWidget {
  const KnowWhatIWantScreen({super.key});

  @override
  State<KnowWhatIWantScreen> createState() => _KnowWhatIWantScreenState();
}

class _KnowWhatIWantScreenState extends State<KnowWhatIWantScreen> {
  final TextEditingController _controller = TextEditingController();
  final Phase0GeminiService _geminiService = const Phase0GeminiService();
  final Phase0MappingService _mappingService = Phase0MappingService();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() {
        _errorMessage = 'Write a short description first.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final allowedSpecialties = await _mappingService.getAllowedSpecialties();

      if (allowedSpecialties.isEmpty) {
        throw const FormatException(
          'No locally supported specialties were found in the dataset.',
        );
      }

      final results = await _geminiService.recommendFromFreeText(
        userDescription: text,
        allowedSpecialties: allowedSpecialties,
      );

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SpecialtyRecommendationScreen(
            title: 'Suggested specialties',
            subtitle:
                'Choose one path to open its learning tree immediately. Each option already exists in the local dataset.',
            recommendations: results,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Could not get valid specialty suggestions. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08111F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('I Know What I Want'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF091321),
              Color(0xFF0D1A2D),
              Color(0xFF06101B),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Describe what you want to study, build, or become.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Example: I like building apps, solving logic problems, and I want a path that can lead to strong software jobs.',
                        style: TextStyle(
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF111E34),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: TextField(
                    controller: _controller,
                    maxLines: 8,
                    minLines: 6,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText:
                          'Write your interests, goals, favorite type of work, or what kind of future you want.',
                      hintStyle: TextStyle(color: Colors.white38),
                      contentPadding: EdgeInsets.all(18),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B8B).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFFF6B8B).withOpacity(0.28),
                      ),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Color(0xFFFFB7C5)),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.4),
                          )
                        : const Text(
                            'Get Specialty Suggestions',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
