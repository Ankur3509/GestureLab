import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'visual_mode.dart';
import '../gesture_engine/gesture_state.dart';

class Particle {
  double x, y;
  double vx, vy;
  double hue;
  double size;

  Particle(this.x, this.y, this.vx, this.vy, this.hue, this.size);
}

class ParticleGalaxy extends VisualMode {
  final List<Particle> particles = [];
  final math.Random random = math.Random();
  bool _initialized = false;

  @override
  String get name => "PARTICLE GALAXY";
  
  @override
  String get description => "Hand gravity field";

  void _initParticles(Size size) {
    if (_initialized) return;
    particles.clear();
    for (int i = 0; i < 800; i++) {
      particles.add(Particle(
        random.nextDouble() * size.width, 
        random.nextDouble() * size.height, 
        (random.nextDouble() - 0.5) * 0.5, 
        (random.nextDouble() - 0.5) * 0.5, 
        random.nextDouble() * 360,
        1.0 + random.nextDouble() * 2.0,
      ));
    }
    _initialized = true;
  }

  @override
  void paint(Canvas canvas, Size size, GestureState state, double time) {
    _initParticles(size);

    // Hand position is the gravity center
    final handX = size.width / 2 + state.translation.dx;
    final handY = size.height / 2 + state.translation.dy;
    
    // Gravity strength based on pinch intensity
    final gravityStrength = 0.1 + (state.intensity * 0.9);
    final attractionRadius = 200 + (state.scale * 200);

    for (var p in particles) {
      // Wrap around screen
      if (p.x < 0) p.x = size.width;
      if (p.x > size.width) p.x = 0;
      if (p.y < 0) p.y = size.height;
      if (p.y > size.height) p.y = 0;

      // Calculate distance to hand
      double dx = handX - p.x;
      double dy = handY - p.y;
      double dist = math.sqrt(dx * dx + dy * dy);
      
      // Apply gravity towards hand
      if (dist < attractionRadius && dist > 1) {
        double force = gravityStrength * (1.0 - dist / attractionRadius);
        p.vx += (dx / dist) * force;
        p.vy += (dy / dist) * force;
      }

      // Rotation effect based on hand rotation
      if (dist < attractionRadius) {
        double angle = math.atan2(dy, dx);
        double rotForce = state.rotation * 0.01;
        p.vx += -math.sin(angle) * rotForce;
        p.vy += math.cos(angle) * rotForce;
      }

      // Friction
      p.vx *= 0.98;
      p.vy *= 0.98;

      // Update position
      p.x += p.vx;
      p.y += p.vy;

      // Draw particle
      final paint = Paint()..style = PaintingStyle.fill;
      
      // Color based on distance and intensity
      double colorFactor = 1.0 - math.min(1.0, dist / attractionRadius);
      Color particleColor = HSVColor.fromAHSV(
        0.6 + colorFactor * 0.4,
        (p.hue + state.intensity * 60) % 360,
        0.7 + state.intensity * 0.3,
        0.8 + colorFactor * 0.2,
      ).toColor();
      
      paint.color = particleColor;
      
      // Size based on intensity
      double particleSize = p.size * (1.0 + state.intensity * 2.0);
      canvas.drawCircle(Offset(p.x, p.y), particleSize, paint);
      
      // Glow for particles near hand
      if (colorFactor > 0.5) {
        paint.color = particleColor.withOpacity(0.3);
        paint.maskFilter = MaskFilter.blur(BlurStyle.normal, 4 + state.intensity * 6);
        canvas.drawCircle(Offset(p.x, p.y), particleSize * 2, paint);
      }
    }

    // Draw hand position indicator
    final handPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 + state.intensity * 3
      ..color = Colors.white.withOpacity(0.3 + state.intensity * 0.4);
    
    canvas.drawCircle(
      Offset(handX, handY), 
      20 + state.intensity * 30, 
      handPaint
    );
  }
}
