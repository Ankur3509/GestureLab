import 'package:flutter/material.dart';
import '../gesture_engine/gesture_state.dart';

abstract class VisualMode {
  String get name;
  String get description;
  
  void paint(Canvas canvas, Size size, GestureState state, double time);
}

class ModePainter extends CustomPainter {
  final VisualMode mode;
  final GestureState state;
  final ValueNotifier<double> timeNotifier;

  ModePainter({
    required this.mode, 
    required this.state, 
    required this.timeNotifier,
  }) : super(repaint: Listenable.merge([state, timeNotifier]));

  @override
  void paint(Canvas canvas, Size size) {
    mode.paint(canvas, size, state, timeNotifier.value);
  }

  @override
  bool shouldRepaint(covariant ModePainter oldDelegate) {
    return oldDelegate.mode != mode || 
           oldDelegate.state != state || 
           oldDelegate.timeNotifier != timeNotifier;
  }
}
