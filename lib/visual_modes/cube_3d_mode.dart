import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import 'visual_mode.dart';
import '../gesture_engine/gesture_state.dart';

class Cube3DMode extends VisualMode {
  @override
  String get name => "3D CUBE UNIVERSE";
  
  @override
  String get description => "Multi-axis 3D rotation";

  // Define cube vertices in 3D space
  final List<vm.Vector3> cubeVertices = [
    vm.Vector3(-1, -1, -1), vm.Vector3(1, -1, -1),
    vm.Vector3(1, 1, -1),   vm.Vector3(-1, 1, -1),
    vm.Vector3(-1, -1, 1),  vm.Vector3(1, -1, 1),
    vm.Vector3(1, 1, 1),    vm.Vector3(-1, 1, 1),
  ];

  // Define cube edges (pairs of vertex indices)
  final List<List<int>> cubeEdges = [
    [0, 1], [1, 2], [2, 3], [3, 0], // Back face
    [4, 5], [5, 6], [6, 7], [7, 4], // Front face
    [0, 4], [1, 5], [2, 6], [3, 7], // Connecting edges
  ];

  @override
  void paint(Canvas canvas, Size size, GestureState state, double time) {
    final center = size.center(Offset.zero) + state.translation;
    
    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Create rotation matrices based on hand gestures
    // Z-axis rotation (screen plane) from wrist rotation
    final rotZ = state.rotation;
    // X and Y rotation from hand position
    final rotX = -(state.translation.dy / 150).clamp(-math.pi/2, math.pi/2);
    final rotY = (state.translation.dx / 150).clamp(-math.pi/2, math.pi/2);

    // Draw multiple cubes at different depths
    _draw3DCube(canvas, state, rotX, rotY, rotZ, 100.0, Colors.cyanAccent);
    _draw3DCube(canvas, state, rotX * 0.7, rotY * 0.7, rotZ * 0.7, 150.0, Colors.purpleAccent);
    _draw3DCube(canvas, state, rotX * 0.5, rotY * 0.5, rotZ * 0.5, 200.0, Colors.greenAccent);

    // Draw pyramid
    _draw3DPyramid(canvas, state, rotX * 1.2, rotY * 1.2, rotZ * 0.3, 80.0, Colors.orangeAccent);

    canvas.restore();

    // Draw axis indicators
    _drawAxisIndicators(canvas, size, state);
  }

  void _draw3DCube(Canvas canvas, GestureState state, double rotX, double rotY, double rotZ, double baseSize, Color color) {
    final size = baseSize * state.scale;
    
    // Create rotation matrix
    final matrix = vm.Matrix4.identity()
      ..rotateX(rotX)
      ..rotateY(rotY)
      ..rotateZ(rotZ);

    // Transform vertices
    List<Offset> projected = [];
    for (var vertex in cubeVertices) {
      final transformed = matrix.transform3(vertex * size);
      
      // Perspective projection
      final perspective = 500.0 / (500.0 + transformed.z);
      projected.add(Offset(
        transformed.x * perspective,
        transformed.y * perspective,
      ));
    }

    // Draw edges with depth-based opacity
    for (var edge in cubeEdges) {
      final v1 = cubeVertices[edge[0]];
      final v2 = cubeVertices[edge[1]];
      final t1 = matrix.transform3(v1 * size);
      final t2 = matrix.transform3(v2 * size);
      
      // Calculate depth for opacity
      final avgDepth = (t1.z + t2.z) / 2;
      final depthFactor = (avgDepth + size) / (size * 2);
      
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 + state.intensity * 3
        ..color = color.withOpacity(0.4 + depthFactor * 0.4 + state.intensity * 0.2);

      // Glow effect
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0 + state.intensity * 6
        ..color = color.withOpacity(0.2 + state.intensity * 0.3)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 + state.intensity * 8);

      canvas.drawLine(projected[edge[0]], projected[edge[1]], glowPaint);
      canvas.drawLine(projected[edge[0]], projected[edge[1]], paint);
    }

    // Draw vertices
    for (int i = 0; i < projected.length; i++) {
      final vertex = cubeVertices[i];
      final transformed = matrix.transform3(vertex * size);
      final depthFactor = (transformed.z + size) / (size * 2);
      
      final vertexPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = color.withOpacity(0.6 + depthFactor * 0.4);

      canvas.drawCircle(projected[i], 3 + state.intensity * 4, vertexPaint);
    }
  }

  void _draw3DPyramid(Canvas canvas, GestureState state, double rotX, double rotY, double rotZ, double baseSize, Color color) {
    final size = baseSize * state.scale;
    
    // Pyramid vertices
    final vertices = [
      vm.Vector3(0, -1.5, 0),     // Top
      vm.Vector3(-1, 0.5, -1),    // Base corners
      vm.Vector3(1, 0.5, -1),
      vm.Vector3(1, 0.5, 1),
      vm.Vector3(-1, 0.5, 1),
    ];

    final edges = [
      [0, 1], [0, 2], [0, 3], [0, 4], // Top to base
      [1, 2], [2, 3], [3, 4], [4, 1], // Base edges
    ];

    final matrix = vm.Matrix4.identity()
      ..rotateX(rotX)
      ..rotateY(rotY)
      ..rotateZ(rotZ);

    List<Offset> projected = [];
    for (var vertex in vertices) {
      final transformed = matrix.transform3(vertex * size);
      final perspective = 500.0 / (500.0 + transformed.z);
      projected.add(Offset(
        transformed.x * perspective,
        transformed.y * perspective,
      ));
    }

    for (var edge in edges) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 + state.intensity * 2
        ..color = color.withOpacity(0.5 + state.intensity * 0.3);

      canvas.drawLine(projected[edge[0]], projected[edge[1]], paint);
    }
  }

  void _drawAxisIndicators(Canvas canvas, Size size, GestureState state) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final pos = Offset(60, size.height - 60);

    // X-axis (Red)
    canvas.drawLine(pos, pos + Offset(40 * math.cos(state.rotation), 40 * math.sin(state.rotation)), 
      paint..color = Colors.red.withOpacity(0.7));
    
    // Y-axis (Green)
    canvas.drawLine(pos, pos + Offset(0, -40), 
      paint..color = Colors.green.withOpacity(0.7));
    
    // Z-axis (Blue)
    canvas.drawLine(pos, pos + Offset(40, 0), 
      paint..color = Colors.blue.withOpacity(0.7));

    // Labels
    final textStyle = TextStyle(color: Colors.white70, fontSize: 10);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    
    textPainter.text = TextSpan(text: 'X', style: textStyle.copyWith(color: Colors.red));
    textPainter.layout();
    textPainter.paint(canvas, pos + Offset(45, -5));
    
    textPainter.text = TextSpan(text: 'Y', style: textStyle.copyWith(color: Colors.green));
    textPainter.layout();
    textPainter.paint(canvas, pos + Offset(-5, -45));
    
    textPainter.text = TextSpan(text: 'Z', style: textStyle.copyWith(color: Colors.blue));
    textPainter.layout();
    textPainter.paint(canvas, pos + Offset(45, 35));
  }
}
