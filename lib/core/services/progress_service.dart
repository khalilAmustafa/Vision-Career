import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static String _key(String specialization) =>
      'completed_subjects_${specialization.replaceAll(' ', '_')}';

  Future<Set<String>> getCompletedSubjects(String specialization) async {
    final prefs = await SharedPreferences.getInstance();
    final savedList = prefs.getStringList(_key(specialization)) ?? [];
    return savedList.toSet();
  }

  Future<void> markCompleted(String specialization, String subjectCode) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getCompletedSubjects(specialization);
    current.add(subjectCode);
    await prefs.setStringList(_key(specialization), current.toList());
  }

  Future<void> markUncompleted(String specialization, String subjectCode) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getCompletedSubjects(specialization);
    current.remove(subjectCode);
    await prefs.setStringList(_key(specialization), current.toList());
  }

  Future<bool> isCompleted(String specialization, String subjectCode) async {
    final current = await getCompletedSubjects(specialization);
    return current.contains(subjectCode);
  }

  double calculateProgress({
    required int totalSubjects,
    required int completedSubjects,
  }) {
    if (totalSubjects == 0) return 0;
    return (completedSubjects / totalSubjects) * 100;
  }
}