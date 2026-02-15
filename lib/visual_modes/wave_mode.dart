import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'visual_mode.dart';
import '../gesture_engine/gesture_state.dart';

class WaveLab extends VisualMode {
  @override
  String get name => "WAVE & DISTORTION LAB";
  
  @override
  String get description => "Gravitational warp simulation";

  @override
  void paint(Canvas canvas, Size size, GestureState state, double time) {
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.blueAccent.withOpacity(0.5);

    double rows = 20;
    double cols = 20;
    double cellW = size.width / cols;
    double cellH = size.height / rows;

    // Interaction point (e.g. hand position)
    final interactX = center.dx + state.translation.dx;
    final interactY = center.dy + state.translation.dy;

    for (int i = 0; i <= rows; i++) {
      final path = Path();
      for (int j = 0; j <= cols; j++) {
        double px = j * cellW;
        double py = i * cellH;

        // Distort based on hand distance
        double dx = px - interactX;
        double dy = py - interactY;
        double dist = math.sqrt(dx * dx + dy * dy);
        
        double force = math.exp(-dist / (200 * state.scale)) * 100 * state.intensity;
        double angle = math.atan2(dy, dx);
        
        double targetX = px + math.cos(angle) * force;
        double targetY = py + math.sin(angle) * force;

        if (j == 0) {
          path.moveTo(targetX, targetY);
        } else {
          path.lineTo(targetX, targetY);
        }
      }
      canvas.drawPath(path, paint);
    }

    // Vertical lines
    for (int j = 0; j <= cols; j++) {
      final path = Path();
      for (int i = 0; i <= rows; i++) {
        double px = j * cellW;
        double py = i * cellH;

        double dx = px - interactX;
        double dy = py - interactY;
        double dist = math.sqrt(dx * dx + dy * dy);
        
        double force = math.exp(-dist / (200 * state.scale)) * 100 * state.intensity;
        double angle = math.atan2(dy, dx);
        
        double targetX = px + math.cos(angle) * force;
        double targetY = py + math.sin(angle) * force;

        if (i == 0) {
          path.moveTo(targetX, targetY);
        } else {
          path.lineTo(targetX, targetY);
        }
      }
      canvas.drawPath(path, paint);
    }
  }
}
