import 'package:flutter/material.dart';

import '../../core/services/phase0_gemini_service.dart';
import '../../core/services/phase0_mapping_service.dart';
import '../path_view/path_view_screen.dart';

class SpecialtyRecommendationScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<Phase0SpecialtyRecommendation> recommendations;
  final String? emptyMessage;

  const SpecialtyRecommendationScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.recommendations,
    this.emptyMessage,
  });

  @override
  State<SpecialtyRecommendationScreen> createState() =>
      _SpecialtyRecommendationScreenState();
}

class _SpecialtyRecommendationScreenState
    extends State<SpecialtyRecommendationScreen> {
  final Phase0MappingService _mappingService = Phase0MappingService();
  final Map<String, Phase0MappedSpecialty> _mappingCache = {};

  bool _isOpening = false;

  @override
  void initState() {
    super.initState();
    _primeMappings();
  }

  Future<void> _primeMappings() async {
    for (final recommendation in widget.recommendations) {
      final mapping = await _mappingService.mapSpecialtyKey(
        recommendation.specialtyKey,
      );
      if (mapping != null) {
        _mappingCache[recommendation.specialtyKey] = mapping;
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openTree(Phase0SpecialtyRecommendation recommendation) async {
    if (_isOpening) return;

    setState(() {
      _isOpening = true;
    });

    try {
      final mapping = await _mappingService.requireMapping(
        recommendation.specialtyKey,
      );

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PathViewScreen(
            college: mapping.collegeTitle,
            specialization: mapping.datasetSpecialization,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This specialty could not be opened locally.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isOpening = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08111F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Choose Your Specialty'),
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: widget.recommendations.isEmpty
                    ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      widget.emptyMessage ??
                          'No valid specialties were found. Go back and try again.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                  ),
                )
                    : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                  itemCount: widget.recommendations.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = widget.recommendations[index];
                    return _RecommendationCard(
                      recommendation: item,
                      mapping: _mappingCache[item.specialtyKey],
                      isBusy: _isOpening,
                      onTap: () => _openTree(item),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final Phase0SpecialtyRecommendation recommendation;
  final Phase0MappedSpecialty? mapping;
  final bool isBusy;
  final VoidCallback onTap;

  const _RecommendationCard({
    required this.recommendation,
    required this.mapping,
    required this.isBusy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (recommendation.confidence * 100).round();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isBusy ? null : onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: const Color(0xFF111E34),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      recommendation.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5EE7FF).withOpacity(0.14),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: const Color(0xFF5EE7FF).withOpacity(0.26),
                      ),
                    ),
                    child: Text(
                      '$percent%',
                      style: const TextStyle(
                        color: Color(0xFF5EE7FF),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (mapping != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Text(
                    'College: ${mapping!.collegeTitle}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                recommendation.shortDescription,
                style: const TextStyle(color: Colors.white70, height: 1.5),
              ),
              const SizedBox(height: 12),
              Text(
                recommendation.fitReason,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: isBusy ? null : onTap,
                  child: const Text('Open Tree'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
