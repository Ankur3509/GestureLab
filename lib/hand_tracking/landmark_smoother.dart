import 'dart:math';

class LandmarkSmoother {
  final Map<int, List<Point<double>>> _history = {};
  final int windowSize;

  LandmarkSmoother({this.windowSize = 5});

  Point<double> smooth(int id, Point<double> current) {
    if (!_history.containsKey(id)) {
      _history[id] = [];
    }
    
    _history[id]!.add(current);
    if (_history[id]!.length > windowSize) {
      _history[id]!.removeAt(0);
    }

    double avgX = 0;
    double avgY = 0;
    for (var p in _history[id]!) {
      avgX += p.x;
      avgY += p.y;
    }

    return Point(avgX / _history[id]!.length, avgY / _history[id]!.length);
  }
}
