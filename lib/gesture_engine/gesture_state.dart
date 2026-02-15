import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:typed_data';
import '../hand_tracking/landmark_smoother.dart';

enum GestureType {
  none,
  pinch,
  palm,
  swipe,
  rotate,
  stretch,
}

class HandLandmark {
  final double x;
  final double y;
  final double z;

  HandLandmark(this.x, this.y, this.z);
}

class HandData {
  final List<HandLandmark> landmarks;
  final bool isLeft;

  HandData({required this.landmarks, required this.isLeft});
}

class GestureState extends ChangeNotifier {
  double scale = 1.0;
  double rotation = 0.0;
  Offset translation = Offset.zero;
  double intensity = 0.5;
  int currentModeIndex = 0;
  
  final ValueNotifier<Uint8List?> cameraFrame = ValueNotifier<Uint8List?>(null);

  bool _isAutoDemo = true;
  double _demoTime = 0;

  final LandmarkSmoother _smoother = LandmarkSmoother(windowSize: 5);
  double _baseRotation = 0;
  double _lastWristAngle = 0;
  bool _rotationInitialized = false;

  void updateCameraFrame(Uint8List bytes) {
    cameraFrame.value = bytes;
  }

  void updateFromHands(List<HandData> hands, {Size? screenSize}) {
    if (hands.isEmpty) {
      _isAutoDemo = true;
      _updateAutoDemo();
      return;
    }
    _isAutoDemo = false;

    // Process primary hand
    final hand = hands[0];
    if (hand.landmarks.length < 21) return;

    // === TRANSLATION: Palm Center (Landmark 9) ===
    final rawPalm = hand.landmarks[9];
    final smoothedPalm = _smoother.smooth(9, math.Point(rawPalm.x, rawPalm.y));

    if (screenSize != null) {
      final targetX = (smoothedPalm.x - 0.5) * screenSize.width * 2.0;
      final targetY = (smoothedPalm.y - 0.5) * screenSize.height * 2.0;
      translation = Offset(
        translation.dx + (targetX - translation.dx) * 0.3,
        translation.dy + (targetY - translation.dy) * 0.3,
      );
    }

    // === PINCH ZOOM: Thumb + Index Distance ===
    final thumb = hand.landmarks[4];
    final index = hand.landmarks[8];
    
    double pinchDist = math.sqrt(
      math.pow(thumb.x - index.x, 2) + 
      math.pow(thumb.y - index.y, 2)
    );

    // Map pinch distance to scale (0.05 = very close, 0.3 = far apart)
    double targetScale = 0.5 + (pinchDist / 0.15) * 1.5;
    targetScale = math.max(0.3, math.min(3.0, targetScale));
    scale += (targetScale - scale) * 0.15;
    
    // === INTENSITY: Pinch Tightness ===
    if (pinchDist < 0.12) {
      double targetIntensity = 1.0 - (pinchDist / 0.12);
      intensity += (targetIntensity - intensity) * 0.2;
    } else {
      intensity += (0.1 - intensity) * 0.1;
    }

    // === ROTATION: Wrist to Palm Angle ===
    final wrist = hand.landmarks[0];
    double currentAngle = math.atan2(rawPalm.y - wrist.y, rawPalm.x - wrist.x);
    
    if (!_rotationInitialized) {
      _lastWristAngle = currentAngle;
      _baseRotation = rotation;
      _rotationInitialized = true;
    }
    
    double angleDelta = currentAngle - _lastWristAngle;
    
    // Handle angle wrapping
    if (angleDelta > math.pi) angleDelta -= 2 * math.pi;
    if (angleDelta < -math.pi) angleDelta += 2 * math.pi;
    
    _baseRotation += angleDelta * 0.5; // Sensitivity multiplier
    rotation += (_baseRotation - rotation) * 0.2;
    _lastWristAngle = currentAngle;

    // === TWO-HAND GESTURES ===
    if (hands.length == 2) {
      final hand2 = hands[1];
      if (hand2.landmarks.length >= 21) {
        final palm2 = hand2.landmarks[9];
        final thumb2 = hand2.landmarks[4];
        final index2 = hand2.landmarks[8];
        
        // Two-hand distance for MEGA ZOOM
        double twoHandDist = math.sqrt(
          math.pow(rawPalm.x - palm2.x, 2) + 
          math.pow(rawPalm.y - palm2.y, 2)
        );
        
        double twoHandScale = 0.5 + (twoHandDist / 0.3) * 2.0;
        twoHandScale = math.max(0.5, math.min(4.0, twoHandScale));
        scale += (twoHandScale - scale) * 0.2;
        
        // Two-hand pinch for INTENSITY BOOST
        double pinch2Dist = math.sqrt(
          math.pow(thumb2.x - index2.x, 2) + 
          math.pow(thumb2.y - index2.y, 2)
        );
        
        if (pinchDist < 0.08 && pinch2Dist < 0.08) {
          intensity = math.min(1.0, intensity + 0.05);
        }
      }
    }

    notifyListeners();
  }

  void _updateAutoDemo() {
    _demoTime += 0.01;
    scale = 1.0 + 0.1 * math.sin(_demoTime);
    rotation = _demoTime * 0.3;
    intensity = (math.sin(_demoTime * 0.5) + 1) / 2;
    translation = Offset(
      30 * math.cos(_demoTime * 0.5),
      30 * math.sin(_demoTime * 0.5),
    );
    notifyListeners();
  }

  void nextMode() {
    currentModeIndex = (currentModeIndex + 1) % 7;
    notifyListeners();
  }

  void prevMode() {
    currentModeIndex = (currentModeIndex - 1 + 7) % 7;
    notifyListeners();
  }

  void reset() {
    scale = 1.0;
    rotation = 0.0;
    translation = Offset.zero;
    intensity = 0.5;
    notifyListeners();
  }
}
