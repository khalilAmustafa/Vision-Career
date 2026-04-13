import 'package:flutter/material.dart';

import '../../core/services/progress_service.dart';
import '../../core/services/quiz_attempt_limit_service.dart';
import '../../core/utils/path_generator.dart';
import '../../core/utils/quiz_achievement_builder.dart';
import '../../data/datasources/subject_local_datasource.dart';
import '../../data/models/quiz_attempt_result_model.dart';
import '../../data/models/subject_model.dart';
import '../../data/repositories/subject_repository.dart';
import '../career/career_selection_screen.dart';
import '../quiz/widgets/subject_completion_quiz_sheet.dart';
import '../subject_details/subject_details_screen.dart';

class PathViewScreen extends StatefulWidget {
  final String college;
  final String specialization;

  const PathViewScreen({
    super.key,
    required this.college,
    required this.specialization,
  });

  @override
  State<PathViewScreen> createState() => _PathViewScreenState();
}

class _PathViewScreenState extends State<PathViewScreen> {
  late final SubjectRepository repository;
  final ProgressService progressService = ProgressService();
  final QuizAttemptLimitService attemptLimitService = QuizAttemptLimitService();

  List<Subject> allSubjects = [];
  List<Subject> phase1Subjects = [];
  List<Subject> phase2Subjects = [];
  Set<String> completedSubjects = {};

  bool isLoading = true;
  String? errorMessage;
  Subject? selectedSubject;

  @override
  void initState() {
    super.initState();
    repository = SubjectRepository(
      localDataSource: SubjectLocalDataSource(),
    );
    loadPath();
  }

  Future<void> loadPath() async {
    try {
      final subjects = await repository.getSubjectsByCollegeAndSpecialization(
        college: widget.college,
        specialization: widget.specialization,
      );

      final orderedSubjects = PathGenerator.generateOrderedPath(subjects);
      final completed =
          await progressService.getCompletedSubjects(widget.specialization);

      if (!mounted) return;

      setState(() {
        allSubjects = orderedSubjects;
        phase1Subjects =
            orderedSubjects.where((subject) => subject.phase == 1).toList();
        phase2Subjects =
            orderedSubjects.where((subject) => subject.phase == 2).toList();
        completedSubjects = completed;
        selectedSubject =
            orderedSubjects.isNotEmpty ? orderedSubjects.first : null;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  bool isUnlocked(Subject subject) {
    if (subject.prerequisites.isEmpty) return true;
    return subject.prerequisites.every(completedSubjects.contains);
  }

  List<Subject> getMissingPrerequisiteSubjects(Subject subject) {
    return allSubjects.where((candidate) {
      return subject.prerequisites.contains(candidate.code) &&
          !completedSubjects.contains(candidate.code);
    }).toList();
  }

  bool arePhase1And2Completed() {
    final phase12Codes = {
      ...phase1Subjects.map((subject) => subject.code),
      ...phase2Subjects.map((subject) => subject.code),
    };

    if (phase12Codes.isEmpty) return false;
    return phase12Codes.every(completedSubjects.contains);
  }

  NodeVisualState getNodeState(Subject subject) {
    if (completedSubjects.contains(subject.code)) {
      return NodeVisualState.completed;
    }
    if (isUnlocked(subject)) {
      return NodeVisualState.unlocked;
    }
    return NodeVisualState.locked;
  }

  double getProgressPercent() {
    final total = phase1Subjects.length + phase2Subjects.length;
    if (total == 0) return 0;

    final done = [...phase1Subjects, ...phase2Subjects]
        .where((subject) => completedSubjects.contains(subject.code))
        .length;

    return done / total;
  }

  Future<QuizAttemptResult?> _attemptCompletionQuiz(Subject subject) async {
    final canStart = await attemptLimitService.canStartAttempt(
      specialization: widget.specialization,
      subjectCode: subject.code,
    );

    if (!canStart) {
      if (!mounted) return null;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Daily attempt limit reached for ${subject.name}. You can try again tomorrow.',
          ),
        ),
      );
      return null;
    }

    await attemptLimitService.registerAttempt(
      specialization: widget.specialization,
      subjectCode: subject.code,
    );

    final achievementsSummary = QuizAchievementBuilder.build(
      allSubjects: allSubjects,
      completedSubjectCodes: completedSubjects,
    );

    return showSubjectCompletionQuiz(
      context: context,
      subject: subject,
      college: widget.college,
      specialization: widget.specialization,
      achievementsSummary: achievementsSummary,
    );
  }

  Future<void> handleNodeLongPress(Subject subject) async {
    if (completedSubjects.contains(subject.code)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${subject.name} is already completed and cannot be uncompleted.',
          ),
        ),
      );
      return;
    }

    if (!isUnlocked(subject)) {
      final missingNames = getMissingPrerequisiteSubjects(subject)
          .map((item) => item.name)
          .join(', ');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Complete these first: $missingNames'),
        ),
      );
      return;
    }

    final result = await _attemptCompletionQuiz(subject);
    if (result == null) return;

    if (!result.passed) {
      final failureMessage = result.integrityPassed
          ? 'Quiz score ${result.scorePercent.toStringAsFixed(1)}%. You need 60% to complete ${subject.name}.'
          : 'Integrity violation detected during the quiz for ${subject.name}. App switching is not allowed.';

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failureMessage)),
      );
      return;
    }

    await progressService.markCompleted(widget.specialization, subject.code);
    final updated =
        await progressService.getCompletedSubjects(widget.specialization);

    if (!mounted) return;

    setState(() {
      completedSubjects = updated;
      selectedSubject = subject;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${subject.name} marked as completed.'),
      ),
    );
  }

  Future<void> openSubject(Subject subject) async {
    setState(() {
      selectedSubject = subject;
    });

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubjectDetailsScreen(
          subject: subject,
          college: widget.college,
          specialization: widget.specialization,
          allSubjects: allSubjects,
        ),
      ),
    );

    await loadPath();
  }

  Future<void> openFinalPhase() async {
    if (!arePhase1And2Completed()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Complete all Phase 1 and Phase 2 subjects first to unlock Final Phase.',
          ),
        ),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CareerSelectionScreen(
          college: widget.college,
          specialization: widget.specialization,
          completedSubjects: allSubjects
              .where((subject) => completedSubjects.contains(subject.code))
              .toList(),
        ),
      ),
    );

    await loadPath();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF08111F),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF08111F),
        appBar: AppBar(title: const Text('Learning Path')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              errorMessage!,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final progress = getProgressPercent();
    final selected = selectedSubject;
    final selectedMissing =
        selected == null ? const <Subject>[] : getMissingPrerequisiteSubjects(selected);

    return Scaffold(
      backgroundColor: const Color(0xFF08111F),
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
          child: Stack(
            children: [
              const _BackgroundGlow(),
              CustomScrollView(
                reverse: true,
                slivers: [
                  SliverToBoxAdapter(
                    child: _PathHeader(
                      college: widget.college,
                      specialization: widget.specialization,
                      progress: progress,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _SelectedSubjectPanel(
                      subject: selected,
                      state: selected == null ? null : getNodeState(selected),
                      missingSubjects: selectedMissing,
                      onOpenDetails: selected == null ? null : () => openSubject(selected),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _FinalPhaseGateCard(
                      isUnlocked: arePhase1And2Completed(),
                      onTap: openFinalPhase,
                    ),
                  ),
                  if (phase2Subjects.isNotEmpty) ...[
                    const SliverToBoxAdapter(
                      child: _PhaseSectionLabel(
                        title: 'Phase 2',
                        subtitle: 'Specialization Tree',
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SkillTreeSection(
                        subjects: phase2Subjects,
                        selectedSubject: selectedSubject,
                        getNodeState: getNodeState,
                        onNodeTap: openSubject,
                        onNodeLongPress: handleNodeLongPress,
                      ),
                    ),
                  ],
                  if (phase1Subjects.isNotEmpty) ...[
                    const SliverToBoxAdapter(
                      child: _PhaseSectionLabel(
                        title: 'Phase 1',
                        subtitle: 'Foundation Tree',
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SkillTreeSection(
                        subjects: phase1Subjects,
                        selectedSubject: selectedSubject,
                        getNodeState: getNodeState,
                        onNodeTap: openSubject,
                        onNodeLongPress: handleNodeLongPress,
                      ),
                    ),
                  ],
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 32),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum NodeVisualState {
  locked,
  unlocked,
  completed,
}

class SkillTreeSection extends StatelessWidget {
  final List<Subject> subjects;
  final Subject? selectedSubject;
  final NodeVisualState Function(Subject subject) getNodeState;
  final Future<void> Function(Subject subject) onNodeTap;
  final Future<void> Function(Subject subject) onNodeLongPress;

  const SkillTreeSection({
    super.key,
    required this.subjects,
    required this.selectedSubject,
    required this.getNodeState,
    required this.onNodeTap,
    required this.onNodeLongPress,
  });

  List<List<Subject>> _buildRows(List<Subject> items) {
    const pattern = [1, 2, 3, 2, 1];
    final rows = <List<Subject>>[];
    var index = 0;
    var patternIndex = 0;

    while (index < items.length) {
      final rowSize = pattern[patternIndex % pattern.length];
      final end = (index + rowSize > items.length) ? items.length : index + rowSize;
      rows.add(items.sublist(index, end));
      index = end;
      patternIndex++;
    }

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    if (subjects.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Text(
          'No subjects found.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final rows = _buildRows(subjects);
    final contentWidth = _treeContentWidth(rows);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 18),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: contentWidth,
          child: Column(
            children: [
              for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) ...[
                _TreeRow(
                  rowSubjects: rows[rowIndex],
                  treeWidth: contentWidth,
                  selectedSubject: selectedSubject,
                  getNodeState: getNodeState,
                  onNodeTap: onNodeTap,
                  onNodeLongPress: onNodeLongPress,
                ),
                if (rowIndex != rows.length - 1)
                  _TreeConnectorRow(
                    currentRow: rows[rowIndex],
                    nextRow: rows[rowIndex + 1],
                    treeWidth: contentWidth,
                    getNodeState: getNodeState,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  double _treeContentWidth(List<List<Subject>> rows) {
    const horizontalPadding = 12.0;
    var widest = 0.0;

    for (final row in rows) {
      final rowCount = row.length;
      final itemWidth = rowCount == 1 ? 240.0 : 168.0;
      final width = (rowCount * itemWidth) + ((rowCount - 1) * 14.0);
      if (width > widest) {
        widest = width;
      }
    }

    return widest + (horizontalPadding * 2);
  }
}

class _TreeRow extends StatelessWidget {
  final List<Subject> rowSubjects;
  final double treeWidth;
  final Subject? selectedSubject;
  final NodeVisualState Function(Subject subject) getNodeState;
  final Future<void> Function(Subject subject) onNodeTap;
  final Future<void> Function(Subject subject) onNodeLongPress;

  const _TreeRow({
    required this.rowSubjects,
    required this.treeWidth,
    required this.selectedSubject,
    required this.getNodeState,
    required this.onNodeTap,
    required this.onNodeLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final itemWidth = rowSubjects.length == 1 ? 240.0 : 168.0;

    return SizedBox(
      width: treeWidth,
      height: 122,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < rowSubjects.length; i++) ...[
            _TreeNodeCard(
              subject: rowSubjects[i],
              width: itemWidth,
              isSelected: selectedSubject?.code == rowSubjects[i].code,
              state: getNodeState(rowSubjects[i]),
              onTap: () => onNodeTap(rowSubjects[i]),
              onLongPress: () => onNodeLongPress(rowSubjects[i]),
            ),
            if (i != rowSubjects.length - 1) const SizedBox(width: 14),
          ],
        ],
      ),
    );
  }
}

class _TreeConnectorRow extends StatelessWidget {
  final List<Subject> currentRow;
  final List<Subject> nextRow;
  final double treeWidth;
  final NodeVisualState Function(Subject subject) getNodeState;

  const _TreeConnectorRow({
    required this.currentRow,
    required this.nextRow,
    required this.treeWidth,
    required this.getNodeState,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: treeWidth,
      height: 44,
      child: CustomPaint(
        painter: _TreeConnectorPainter(
          currentRow: currentRow,
          nextRow: nextRow,
          getNodeState: getNodeState,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _TreeConnectorPainter extends CustomPainter {
  final List<Subject> currentRow;
  final List<Subject> nextRow;
  final NodeVisualState Function(Subject subject) getNodeState;

  _TreeConnectorPainter({
    required this.currentRow,
    required this.nextRow,
    required this.getNodeState,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final activePaint = Paint()
      ..color = const Color(0xFF4FC3FF).withOpacity(0.75)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;

    final lockedPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final currentXs = _positions(currentRow.length, size.width);
    final nextXs = _positions(nextRow.length, size.width);

    for (var parentIndex = 0; parentIndex < currentRow.length; parentIndex++) {
      final parent = currentRow[parentIndex];

      for (var childIndex = 0; childIndex < nextRow.length; childIndex++) {
        final child = nextRow[childIndex];
        final isLinked = child.prerequisites.contains(parent.code);

        if (!isLinked) continue;

        final from = Offset(currentXs[parentIndex], 0);
        final to = Offset(nextXs[childIndex], size.height);
        final controlY = size.height * 0.5;

        final path = Path()
          ..moveTo(from.dx, from.dy)
          ..cubicTo(
            from.dx,
            controlY,
            to.dx,
            controlY,
            to.dx,
            to.dy,
          );

        final parentUnlocked = getNodeState(parent) != NodeVisualState.locked;
        final childUnlocked = getNodeState(child) != NodeVisualState.locked;

        canvas.drawPath(
          path,
          parentUnlocked && childUnlocked ? activePaint : lockedPaint,
        );
      }
    }
  }

  List<double> _positions(int count, double width) {
    if (count <= 0) return const [];
    if (count == 1) return [width / 2];

    final gap = width / (count + 1);
    return List<double>.generate(count, (index) => gap * (index + 1));
  }

  @override
  bool shouldRepaint(covariant _TreeConnectorPainter oldDelegate) {
    return oldDelegate.currentRow != currentRow || oldDelegate.nextRow != nextRow;
  }
}

class _TreeNodeCard extends StatelessWidget {
  final Subject subject;
  final double width;
  final bool isSelected;
  final NodeVisualState state;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _TreeNodeCard({
    required this.subject,
    required this.width,
    required this.isSelected,
    required this.state,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _paletteForState(state);
    final phaseLabel = subject.phase == 1 ? 'P1' : 'P2';

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: width,
        height: 94,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: palette.gradient,
          border: Border.all(
            color: isSelected ? palette.border : palette.border.withOpacity(0.55),
            width: isSelected ? 1.8 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: palette.glow,
              blurRadius: isSelected ? 26 : 16,
              spreadRadius: isSelected ? 1.2 : 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 14,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: palette.pill,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  phaseLabel,
                  style: TextStyle(
                    color: palette.pillText,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.code,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.codeText,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    subject.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.titleText,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _NodePalette _paletteForState(NodeVisualState state) {
    switch (state) {
      case NodeVisualState.completed:
        return const _NodePalette(
          gradient: LinearGradient(
            colors: [Color(0xFFFFE27A), Color(0xFFFFC93C), Color(0xFFFFB300)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Color(0xFFFFF1A6),
          glow: Color(0x55FFD54F),
          titleText: Color(0xFF2D1F00),
          codeText: Color(0xFF5E4300),
          pill: Color(0xFFF8F0B0),
          pillText: Color(0xFF6B5300),
        );
      case NodeVisualState.unlocked:
        return const _NodePalette(
          gradient: LinearGradient(
            colors: [Color(0xFF173450), Color(0xFF114A79), Color(0xFF0D6EAF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Color(0xFF61D1FF),
          glow: Color(0x334FC3FF),
          titleText: Colors.white,
          codeText: Color(0xFFCFEFFF),
          pill: Color(0x223FD0FF),
          pillText: Color(0xFF9FE5FF),
        );
      case NodeVisualState.locked:
        return const _NodePalette(
          gradient: LinearGradient(
            colors: [Color(0xFF21262E), Color(0xFF181D25), Color(0xFF131821)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Color(0xFF4E5663),
          glow: Color(0x12000000),
          titleText: Color(0xFFB3BAC5),
          codeText: Color(0xFF858F9D),
          pill: Color(0x222A313D),
          pillText: Color(0xFF97A0AE),
        );
    }
  }
}

class _NodePalette {
  final Gradient gradient;
  final Color border;
  final Color glow;
  final Color titleText;
  final Color codeText;
  final Color pill;
  final Color pillText;

  const _NodePalette({
    required this.gradient,
    required this.border,
    required this.glow,
    required this.titleText,
    required this.codeText,
    required this.pill,
    required this.pillText,
  });
}

class _PathHeader extends StatelessWidget {
  final String college;
  final String specialization;
  final double progress;

  const _PathHeader({
    required this.college,
    required this.specialization,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final progressPercent = (progress * 100).round();

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [Color(0xFF162338), Color(0xFF0E1C2F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: const Color(0xFF57D6FF).withOpacity(0.18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              college,
              style: const TextStyle(
                color: Color(0xFF8EDFFF),
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              specialization,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tap a node to inspect it. Hold a node to try marking it complete through the quiz gate. Swipe left or right to view the full tree.',
              style: TextStyle(
                color: Colors.white70,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Colors.white.withOpacity(0.08),
                valueColor: const AlwaysStoppedAnimation(Color(0xFFFFD54F)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Progress: $progressPercent%',
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhaseSectionLabel extends StatelessWidget {
  final String title;
  final String subtitle;

  const _PhaseSectionLabel({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: const LinearGradient(
                colors: [Color(0xFF57D6FF), Color(0xFFFFD54F)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SelectedSubjectPanel extends StatelessWidget {
  final Subject? subject;
  final NodeVisualState? state;
  final List<Subject> missingSubjects;
  final VoidCallback? onOpenDetails;

  const _SelectedSubjectPanel({
    required this.subject,
    required this.state,
    required this.missingSubjects,
    required this.onOpenDetails,
  });

  @override
  Widget build(BuildContext context) {
    if (subject == null) {
      return const SizedBox.shrink();
    }

    final status = switch (state) {
      NodeVisualState.completed => 'Completed',
      NodeVisualState.unlocked => 'Unlocked',
      NodeVisualState.locked => 'Locked',
      null => 'Unknown',
    };

    final lockedReason = missingSubjects.isEmpty
        ? 'All prerequisites completed.'
        : 'Needs: ${missingSubjects.map((item) => item.name).join(', ')}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 14),
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
            Text(
              subject!.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${subject!.code} • $status',
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              lockedReason,
              style: const TextStyle(
                color: Colors.white60,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: onOpenDetails,
                child: const Text('Open Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinalPhaseGateCard extends StatelessWidget {
  final bool isUnlocked;
  final VoidCallback onTap;

  const _FinalPhaseGateCard({
    required this.isUnlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: isUnlocked
                  ? const [Color(0xFF2E1E00), Color(0xFF5C3A00), Color(0xFF8E6200)]
                  : const [Color(0xFF1B1F27), Color(0xFF181B20), Color(0xFF15181C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: isUnlocked
                  ? const Color(0xFFFFD54F).withOpacity(0.45)
                  : Colors.white.withOpacity(0.08),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.workspace_premium_rounded,
                color: isUnlocked ? const Color(0xFFFFE082) : Colors.white54,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FINAL PHASE',
                      style: TextStyle(
                        color: isUnlocked ? Colors.white : Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isUnlocked
                          ? 'Unlocked. Open the career phase.'
                          : 'Finish all Phase 1 and Phase 2 nodes first.',
                      style: TextStyle(
                        color: isUnlocked ? Colors.white70 : Colors.white54,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Colors.white70,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            left: -80,
            top: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF47C4FF).withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            right: -60,
            top: 160,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFD54F).withOpacity(0.07),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
