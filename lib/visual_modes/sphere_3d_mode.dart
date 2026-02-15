import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import 'visual_mode.dart';
import '../gesture_engine/gesture_state.dart';

class Sphere3DMode extends VisualMode {
  @override
  String get name => "3D SPHERE MATRIX";
  
  @override
  String get description => "Rotating wireframe spheres";

  @override
  void paint(Canvas canvas, Size size, GestureState state, double time) {
    final center = size.center(Offset.zero) + state.translation;
    
    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Multiple spheres with different rotation speeds
    _drawWireframeSphere(canvas, state, 120.0, 20, 15, Colors.cyanAccent);
    _drawWireframeSphere(canvas, state, 80.0, 15, 10, Colors.purpleAccent);
    
    // Draw torus
    _drawTorus(canvas, state, 100.0, 30.0, 30, 20, Colors.greenAccent);

    canvas.restore();
  }

  void _drawWireframeSphere(Canvas canvas, GestureState state, double radius, int latLines, int lonLines, Color color) {
    radius *= state.scale;
    
    // Rotation based on hand gestures
    final rotZ = state.rotation;
    final rotX = -(state.translation.dy / 150).clamp(-math.pi/2, math.pi/2);
    final rotY = (state.translation.dx / 150).clamp(-math.pi/2, math.pi/2);

    final matrix = vm.Matrix4.identity()
      ..rotateX(rotX)
      ..rotateY(rotY)
      ..rotateZ(rotZ);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 + state.intensity * 2
      ..color = color.withOpacity(0.5 + state.intensity * 0.3);

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 + state.intensity * 4
      ..color = color.withOpacity(0.2 + state.intensity * 0.2)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 + state.intensity * 6);

    // Draw latitude lines
    for (int lat = 0; lat < latLines; lat++) {
      final theta = (lat * math.pi) / latLines;
      final nextTheta = ((lat + 1) * math.pi) / latLines;
      
      final path = Path();
      bool firstPoint = true;

      for (int lon = 0; lon <= lonLines; lon++) {
        final phi = (lon * 2 * math.pi) / lonLines;
        
        final x = radius * math.sin(theta) * math.cos(phi);
        final y = radius * math.cos(theta);
        final z = radius * math.sin(theta) * math.sin(phi);
        
        final vertex = vm.Vector3(x, y, z);
        final transformed = matrix.transform3(vertex);
        
        final perspective = 500.0 / (500.0 + transformed.z);
        final projected = Offset(
          transformed.x * perspective,
          transformed.y * perspective,
        );

        if (firstPoint) {
          path.moveTo(projected.dx, projected.dy);
          firstPoint = false;
        } else {
          path.lineTo(projected.dx, projected.dy);
        }
      }

      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, paint);
    }

    // Draw longitude lines
    for (int lon = 0; lon < lonLines; lon++) {
      final phi = (lon * 2 * math.pi) / lonLines;
      
      final path = Path();
      bool firstPoint = true;

      for (int lat = 0; lat <= latLines; lat++) {
        final theta = (lat * math.pi) / latLines;
        
        final x = radius * math.sin(theta) * math.cos(phi);
        final y = radius * math.cos(theta);
        final z = radius * math.sin(theta) * math.sin(phi);
        
        final vertex = vm.Vector3(x, y, z);
        final transformed = matrix.transform3(vertex);
        
        final perspective = 500.0 / (500.0 + transformed.z);
        final projected = Offset(
          transformed.x * perspective,
          transformed.y * perspective,
        );

        if (firstPoint) {
          path.moveTo(projected.dx, projected.dy);
          firstPoint = false;
        } else {
          path.lineTo(projected.dx, projected.dy);
        }
      }

      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, paint);
    }
  }

  void _drawTorus(Canvas canvas, GestureState state, double majorRadius, double minorRadius, int majorSegments, int minorSegments, Color color) {
    majorRadius *= state.scale;
    minorRadius *= (state.scale * 0.5);
    
    final rotZ = state.rotation * 0.7;
    final rotX = -(state.translation.dy / 200).clamp(-math.pi/2, math.pi/2);
    final rotY = (state.translation.dx / 200).clamp(-math.pi/2, math.pi/2);

    final matrix = vm.Matrix4.identity()
      ..rotateX(rotX)
      ..rotateY(rotY)
      ..rotateZ(rotZ);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 + state.intensity
      ..color = color.withOpacity(0.4 + state.intensity * 0.3);

    // Draw torus rings
    for (int i = 0; i < majorSegments; i++) {
      final u = (i * 2 * math.pi) / majorSegments;
      
      final path = Path();
      bool firstPoint = true;

      for (int j = 0; j <= minorSegments; j++) {
        final v = (j * 2 * math.pi) / minorSegments;
        
        final x = (majorRadius + minorRadius * math.cos(v)) * math.cos(u);
        final y = minorRadius * math.sin(v);
        final z = (majorRadius + minorRadius * math.cos(v)) * math.sin(u);
        
        final vertex = vm.Vector3(x, y, z);
        final transformed = matrix.transform3(vertex);
        
        final perspective = 500.0 / (500.0 + transformed.z);
        final projected = Offset(
          transformed.x * perspective,
          transformed.y * perspective,
        );

        if (firstPoint) {
          path.moveTo(projected.dx, projected.dy);
          firstPoint = false;
        } else {
          path.lineTo(projected.dx, projected.dy);
        }
      }

      canvas.drawPath(path, paint);
    }
  }
}
