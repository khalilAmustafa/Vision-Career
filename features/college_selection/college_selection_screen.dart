import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../data/datasources/subject_local_datasource.dart';
import '../../data/repositories/subject_repository.dart';
import '../specialization_selection/specialization_selection_screen.dart';

class CollegeSelectionScreen extends StatefulWidget {
  final AppThemePreset currentTheme;
  final void Function(AppThemePreset) onThemeChanged;

  const CollegeSelectionScreen({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
  });

  @override
  State<CollegeSelectionScreen> createState() => _CollegeSelectionScreenState();
}

class _CollegeSelectionScreenState extends State<CollegeSelectionScreen> {
  late final SubjectRepository _repository;

  bool _isLoading = true;
  String? _errorMessage;
  List<String> _colleges = const [];

  @override
  void initState() {
    super.initState();
    _repository = SubjectRepository(localDataSource: SubjectLocalDataSource());
    _loadColleges();
  }

  Future<void> _loadColleges() async {
    try {
      final colleges = await _repository.getAvailableColleges();
      setState(() {
        _colleges = colleges;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Could not load colleges from the dataset.';
        _isLoading = false;
      });
      debugPrint('CollegeSelectionScreen error: $error');
    }
  }

  IconData _iconForCollege(String college) {
    switch (college.toLowerCase()) {
      case 'it':
      case 'information technology':
        return Icons.computer;
      case 'engineering':
        return Icons.engineering;
      case 'finance':
      case 'business':
        return Icons.business_center;
      case 'science':
        return Icons.science;
      default:
        return Icons.school;
    }
  }

  String _subtitleForCollege(String college) {
    switch (college.toLowerCase()) {
      case 'it':
      case 'information technology':
        return 'Software, AI, Cybersecurity, XR';
      case 'engineering':
        return 'Civil, robotics, communications';
      case 'finance':
      case 'business':
        return 'Accounting, MIS, marketing, FinTech';
      case 'science':
        return 'Math, physics, biology, chemistry';
      default:
        return 'Available specializations in the local dataset';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;
    final textColor =
        theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF111827);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppThemes.backgroundGradient(widget.currentTheme),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: textColor),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  gradient: LinearGradient(colors: [accent, secondary]),
                                ),
                                child: const Icon(Icons.auto_awesome, color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Vision Career',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              PopupMenuButton<AppThemePreset>(
                                tooltip: 'Change theme',
                                onSelected: widget.onThemeChanged,
                                icon: const Icon(Icons.palette_outlined),
                                itemBuilder: (context) => const [
                                  PopupMenuItem(
                                    value: AppThemePreset.light,
                                    child: Text('Light Theme'),
                                  ),
                                  PopupMenuItem(
                                    value: AppThemePreset.dark,
                                    child: Text('Dark Theme'),
                                  ),
                                  PopupMenuItem(
                                    value: AppThemePreset.neon,
                                    child: Text('Neon Theme'),
                                  ),
                                  PopupMenuItem(
                                    value: AppThemePreset.fantasy,
                                    child: Text('Fantasy Theme'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: theme.cardColor.withOpacity(0.72),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: accent.withOpacity(0.28)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Choose Your College',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'The app now reads colleges directly from the master dataset instead of using hardcoded IT-only options.',
                                  style: TextStyle(
                                    color: textColor.withOpacity(0.8),
                                    fontSize: 15,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 0.95,
                            ),
                            itemCount: _colleges.length,
                            itemBuilder: (context, index) {
                              final college = _colleges[index];
                              return _CollegeCard(
                                title: college,
                                subtitle: _subtitleForCollege(college),
                                icon: _iconForCollege(college),
                                accent: accent,
                                secondary: secondary,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SpecializationSelectionScreen(
                                        initialCollege: college,
                                      ),
                                    ),
                                  );
                                },
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

class _CollegeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final Color secondary;
  final VoidCallback onTap;

  const _CollegeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.secondary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor =
        theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF111827);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.cardColor.withOpacity(0.80),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: accent.withOpacity(0.30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [accent, secondary]),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: textColor.withOpacity(0.78),
                fontSize: 13.5,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
