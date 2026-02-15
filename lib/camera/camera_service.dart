import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  CameraController? get controller => _controller;

  Future<void> initialize() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      _controller = CameraController(
        _cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller?.initialize();
      _isInitialized = true;
    } catch (e) {
      debugPrint("Camera Error: $e");
    }
  }

  void startImageStream(Function(CameraImage) onImage) {
    _controller?.startImageStream(onImage);
  }

  void dispose() {
    _controller?.dispose();
  }
}
