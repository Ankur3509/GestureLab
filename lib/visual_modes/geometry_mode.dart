import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'visual_mode.dart';
import '../gesture_engine/gesture_state.dart';

class GeometryPlayground extends VisualMode {
  @override
  String get name => "GEOMETRY PLAYGROUND";
  
  @override
  String get description => "Hand-controlled shapes";

  @override
  void paint(Canvas canvas, Size size, GestureState state, double time) {
    final center = size.center(Offset.zero) + state.translation;
    
    // Draw grid based on scale
    _drawGrid(canvas, size, state);

    // Main shape controlled by hand
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(state.rotation);
    canvas.scale(state.scale);

    // TRIANGLE - Size controlled by pinch
    final triangleSize = 50.0 + (state.intensity * 100);
    final trianglePath = Path();
    trianglePath.moveTo(0, -triangleSize);
    trianglePath.lineTo(triangleSize * 0.866, triangleSize * 0.5);
    trianglePath.lineTo(-triangleSize * 0.866, triangleSize * 0.5);
    trianglePath.close();
    
    // Glow intensity based on pinch
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0 + (state.intensity * 6)
      ..color = Colors.cyanAccent.withOpacity(0.3 + state.intensity * 0.4)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 + state.intensity * 12);
    
    final mainPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 + state.intensity
      ..color = Colors.cyanAccent.withOpacity(0.8 + state.intensity * 0.2);
    
    canvas.drawPath(trianglePath, glowPaint);
    canvas.drawPath(trianglePath, mainPaint);

    // CIRCLE - Pulsates with intensity
    final circleRadius = 80 + (state.intensity * 40);
    canvas.drawCircle(
      Offset.zero, 
      circleRadius, 
      glowPaint..color = Colors.purpleAccent.withOpacity(0.3 + state.intensity * 0.3)
    );
    canvas.drawCircle(
      Offset.zero, 
      circleRadius, 
      mainPaint..color = Colors.purpleAccent.withOpacity(0.7 + state.intensity * 0.3)
    );

    // SQUARE - Rotates with hand
    final squareSize = 60 + (state.intensity * 50);
    final squarePath = Path();
    squarePath.addRect(Rect.fromCenter(
      center: Offset.zero,
      width: squareSize,
      height: squareSize,
    ));
    
    canvas.drawPath(
      squarePath, 
      glowPaint..color = Colors.greenAccent.withOpacity(0.3 + state.intensity * 0.3)
    );
    canvas.drawPath(
      squarePath, 
      mainPaint..color = Colors.greenAccent.withOpacity(0.7 + state.intensity * 0.3)
    );

    canvas.restore();
  }

  void _drawGrid(Canvas canvas, Size size, GestureState state) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05 + state.intensity * 0.1)
      ..strokeWidth = 1.0;

    double step = 50.0 * state.scale;
    step = math.max(20, math.min(100, step));
    
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }
  }
}
