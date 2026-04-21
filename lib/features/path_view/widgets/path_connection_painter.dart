import 'package:flutter/material.dart';

import '../path_view_controller.dart';

class PathConnectionPainter extends CustomPainter {
  final List<Offset> nodeCenters;
  final double nodeHalfHeight;
  final List<NodeVisualState> nodeStates;
  final ThemeData theme;
  final String repaintKey;

  const PathConnectionPainter({
    required this.nodeCenters,
    required this.nodeHalfHeight,
    required this.nodeStates,
    required this.theme,
    required this.repaintKey,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (nodeCenters.length < 2) return;

    final isDark = theme.brightness == Brightness.dark;

    final completedPaint = Paint()
      ..color = const Color(0xFFFFD54F).withOpacity(0.72)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..color = theme.colorScheme.primary.withOpacity(0.6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final lockedPaint = Paint()
      ..color = isDark
          ? Colors.white.withOpacity(0.07)
          : Colors.black.withOpacity(0.07)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < nodeCenters.length - 1; i++) {
      final fromCenter = nodeCenters[i];
      final toCenter = nodeCenters[i + 1];

      // Exit bottom-center of current node, enter top-center of next node
      final from = Offset(fromCenter.dx, fromCenter.dy + nodeHalfHeight);
      final to = Offset(toCenter.dx, toCenter.dy - nodeHalfHeight);
      final midY = (from.dy + to.dy) / 2;

      final path = Path()
        ..moveTo(from.dx, from.dy)
        ..cubicTo(from.dx, midY, to.dx, midY, to.dx, to.dy);

      final fromState =
          i < nodeStates.length ? nodeStates[i] : NodeVisualState.locked;
      final toState = (i + 1) < nodeStates.length
          ? nodeStates[i + 1]
          : NodeVisualState.locked;

      final Paint paint;
      if (fromState == NodeVisualState.completed &&
          toState == NodeVisualState.completed) {
        paint = completedPaint;
      } else if (fromState != NodeVisualState.locked ||
          toState != NodeVisualState.locked) {
        paint = activePaint;
      } else {
        paint = lockedPaint;
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant PathConnectionPainter old) {
    return old.repaintKey != repaintKey ||
        old.theme.brightness != theme.brightness;
  }
}
