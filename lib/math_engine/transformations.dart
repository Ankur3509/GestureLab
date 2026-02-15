import 'package:vector_math/vector_math_64.dart';
import 'dart:math' as math;

class MathUtils {
  static Matrix4 createTransformationMatrix({
    double tx = 0,
    double ty = 0,
    double tz = 0,
    double rotateX = 0,
    double rotateY = 0,
    double rotateZ = 0,
    double scale = 1.0,
  }) {
    final matrix = Matrix4.identity();
    matrix.translate(tx, ty, tz);
    matrix.rotateX(rotateX);
    matrix.rotateY(rotateY);
    matrix.rotateZ(rotateZ);
    matrix.scale(scale);
    return matrix;
  }

  static double lerp(double a, double b, double t) {
    return a + (b - a) * t;
  }

  static double normalize(double value, double min, double max) {
    return (value - min) / (max - min);
  }

  static double clamp(double value, double min, double max) {
    return math.max(min, math.min(max, value));
  }
}
