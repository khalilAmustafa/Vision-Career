import 'package:flutter/material.dart';

import '../../core/services/career_llm_service.dart';
import '../../core/services/career_storage_service.dart';
import '../../data/models/subject_model.dart';
import 'job_selection_screen.dart';
import 'phase3_path_screen.dart';

class CareerSelectionScreen extends StatefulWidget {
  final String college;
  final String specialization;
  final List<Subject> completedSubjects;

  const CareerSelectionScreen({
    super.key,
    required this.college,
    required this.specialization,
    required this.completedSubjects,
  });

  @override
  State<CareerSelectionScreen> createState() => _CareerSelectionScreenState();
}

class _CareerSelectionScreenState extends State<CareerSelectionScreen> {
  final CareerLlmService _careerLlmService = CareerLlmService();
  final CareerStorageService _careerStorageService = CareerStorageService();

  bool _isLoading = false;

  Future<void> _startFinalPhase() async {
    final alreadyGenerated = await _careerStorageService.isPhase3Generated(
      college: widget.college,
      specialization: widget.specialization,
    );

    if (alreadyGenerated) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Phase3PathScreen(
            college: widget.college,
            specialization: widget.specialization,
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final jobs = await _careerLlmService.suggestJobs(
        college: widget.college,
        specialization: widget.specialization,
        completedSubjects: widget.completedSubjects,
      );

      await _careerStorageService.saveSuggestedJobs(
        college: widget.college,
        specialization: widget.specialization,
        jobs: jobs,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => JobSelectionScreen(
            college: widget.college,
            specialization: widget.specialization,
            completedSubjects: widget.completedSubjects,
            suggestedJobs: jobs,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not load job suggestions: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Final Phase'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.workspace_premium, size: 78),
            const SizedBox(height: 20),
            const Text(
              'FINAL PHASE',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You completed the academic path for ${widget.specialization} in ${widget.college}. '
              'This phase turns your finished subjects into a career-readiness mini path.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 28),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'What happens next?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text('1. The AI suggests matching jobs.'),
                    SizedBox(height: 8),
                    Text('2. You choose up to 3 jobs.'),
                    SizedBox(height: 8),
                    Text('3. The app builds your final 3–5 employability nodes.'),
                    SizedBox(height: 8),
                    Text('4. Each node uses the same quiz and resources system.'),
                    SizedBox(height: 8),
                    Text('5. Generation is locked permanently after creation.'),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 62,
              child: FilledButton(
                onPressed: _isLoading ? null : _startFinalPhase,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                        'FINAL PHASE',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
