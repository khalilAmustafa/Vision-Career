import 'package:flutter/material.dart';

import '../../core/services/phase0_gemini_service.dart';
import '../../core/services/phase0_mapping_service.dart';
import '../../core/services/phase0_session_service.dart';
import 'specialty_recommendation_screen.dart';

class FitResultScreen extends StatefulWidget {
  const FitResultScreen({super.key});

  @override
  State<FitResultScreen> createState() => _FitResultScreenState();
}

class _FitResultScreenState extends State<FitResultScreen> {
  final Phase0SessionService _sessionService = Phase0SessionService();
  final Phase0GeminiService _geminiService = const Phase0GeminiService();
  final Phase0MappingService _mappingService = Phase0MappingService();

  bool _isLoading = true;
  String? _errorMessage;
  List<Phase0SpecialtyRecommendation> _recommendations = const [];

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await _sessionService.getInterestProfile();
      final summary = await _sessionService.getChatSummary();
      final aptitude = await _sessionService.getAptitudeSummary();
      final allowed = await _mappingService.getAllowedSpecialties();

      final recommendations = await _geminiService.recommendFromDiscoveryPackage(
        interestProfile: profile ?? const {},
        chatSummary: summary ?? '',
        aptitudeSummary: aptitude ?? const {},
        allowedSpecialties: allowed,
      );

      await _sessionService.saveRecommendations(
        recommendations.map((item) => item.toJson()).toList(growable: false),
      );

      setState(() {
        _recommendations = recommendations;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Could not build specialty results. Please retry the fit flow.';
        _isLoading = false;
      });
      debugPrint('FitResultScreen error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF08111F),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF08111F),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Find Your Fit • Results'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, height: 1.5),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _loadRecommendations,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SpecialtyRecommendationScreen(
      title: 'Your Best-Match Specialties',
      subtitle:
          'These results combine your interests, guided chat answers, and soft aptitude signals. Choose one specialty to open the tree immediately.',
      recommendations: _recommendations,
      emptyMessage:
          'No valid specialties were returned after local validation. Retry the fit flow.',
    );
  }
}
