import 'package:flutter/material.dart';

class PathHeader extends StatelessWidget {
  final String college;
  final String specialization;
  final double progress;

  const PathHeader({
    super.key,
    required this.college,
    required this.specialization,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progressPercent = (progress * 100).round();

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF162338), const Color(0xFF0E1C2F)]
                : [
                    theme.colorScheme.surfaceVariant,
                    theme.colorScheme.surfaceVariant.withOpacity(0.7),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: isDark
                ? const Color(0xFF57D6FF).withOpacity(0.18)
                : theme.colorScheme.outline.withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.28 : 0.05),
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
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF8EDFFF)
                    : theme.colorScheme.primary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              specialization,
              style: TextStyle(
                color: isDark ? Colors.white : theme.colorScheme.onSurface,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tap a node to inspect it. Hold a node to try marking it complete through the quiz gate. Swipe left or right to view the full tree.',
              style: TextStyle(
                color: isDark
                    ? Colors.white70
                    : theme.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.05),
                valueColor: AlwaysStoppedAnimation(
                  isDark
                      ? const Color(0xFFFFD54F)
                      : theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Progress: $progressPercent%',
              style: TextStyle(
                color: isDark
                    ? Colors.white70
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
