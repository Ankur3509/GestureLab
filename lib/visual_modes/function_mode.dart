import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'visual_mode.dart';
import '../gesture_engine/gesture_state.dart';

class FunctionUniverse extends VisualMode {
  @override
  String get name => "FUNCTION UNIVERSE";
  
  @override
  String get description => "Mathematical wave functions";

  @override
  void paint(Canvas canvas, Size size, GestureState state, double time) {
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.greenAccent;

    // Draw Axes
    final axisPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), axisPaint);
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), axisPaint);

    // Sine Wave
    final path = Path();
    double amplitude = 100 * state.scale;
    double frequency = 0.02 * (1.0 + state.intensity);

    path.moveTo(0, center.dy + amplitude * math.sin(time + 0));
    for (double x = 0; x < size.width; x += 2) {
      double y = center.dy + amplitude * math.sin(frequency * (x - center.dx) + time * 2);
      path.lineTo(x, y);
    }

    // Glow effect
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..color = Colors.greenAccent.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);

    // Cosine Wave (offset)
    final path2 = Path();
    path2.moveTo(0, center.dy + amplitude * math.cos(time + 0));
    for (double x = 0; x < size.width; x += 2) {
      double y = center.dy + amplitude * math.cos(frequency * (x - center.dx) + time * 1.5);
      path2.lineTo(x, y);
    }
    canvas.drawPath(path2, glowPaint..color = Colors.orangeAccent.withOpacity(0.2));
    canvas.drawPath(path2, paint..color = Colors.orangeAccent);
  }
}
