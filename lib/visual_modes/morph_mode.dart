import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'visual_mode.dart';
import '../gesture_engine/gesture_state.dart';

class ShapeMorphEngine extends VisualMode {
  @override
  String get name => "SHAPE MORPH ENGINE";
  
  @override
  String get description => "Interpolated geometry";

  @override
  void paint(Canvas canvas, Size size, GestureState state, double time) {
    final center = size.center(Offset.zero);
    final radius = 150.0 * state.scale;
    
    // Interpolation factor between 3 shapes based on time or gesture
    double t = (math.sin(time) + 1) / 2; // Cyclic morph
    // Or use state.intensity
    t = state.intensity;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.pinkAccent;

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..color = Colors.pinkAccent.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    int points = 100;
    final path = Path();
    
    for (int i = 0; i <= points; i++) {
        double angle = (i / points) * 2 * math.pi;
        
        // Circle point
        double cx = math.cos(angle) * radius;
        double cy = math.sin(angle) * radius;
        
        // Square point
        double sx, sy;
        double absCos = math.cos(angle).abs();
        double absSin = math.sin(angle).abs();
        if (absCos > absSin) {
            sx = (math.cos(angle) > 0 ? 1 : -1) * radius;
            sy = math.tan(angle) * sx;
        } else {
            sy = (math.sin(angle) > 0 ? 1 : -1) * radius;
            sx = (1 / math.tan(angle)) * sy;
        }

        // Star point
        double r = radius * (i % 20 < 10 ? 1.0 : 0.4);
        double stx = math.cos(angle) * r;
        double sty = math.sin(angle) * r;

        // Morph
        double x, y;
        if (t < 0.5) {
            // Morph Square to Circle
            double t2 = t * 2;
            x = sx * (1 - t2) + cx * t2;
            y = sy * (1 - t2) + cy * t2;
        } else {
            // Morph Circle to Star
            double t2 = (t - 0.5) * 2;
            x = cx * (1 - t2) + stx * t2;
            y = cy * (1 - t2) + sty * t2;
        }

        if (i == 0) {
          path.moveTo(center.dx + x, center.dy + y);
        } else {
          path.lineTo(center.dx + x, center.dy + y);
        }
    }
    path.close();

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }
}
