import '../gesture_engine/gesture_state.dart';

abstract class IHandTracker {
  Future<void> initialize();
  Stream<List<HandData>> get handStream;
  void processImage(dynamic image); // generic for different platforms
  void dispose();
}
