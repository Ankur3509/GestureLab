import 'dart:async';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'hand_tracking_service.dart';

class WebCaptureService {
  CameraController? _controller;
  final HandTrackingService trackingService;
  Timer? _timer;
  bool _isProcessing = false;

  WebCaptureService(this.trackingService);

  Future<void> initialize() async {
    if (!kIsWeb) return;

    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(
      cameras[0],
      ResolutionPreset.low,
      enableAudio: false,
    );

    await _controller!.initialize();
    
    // Start a timer to capture frames at 10-15 FPS (to save bandwidth)
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _captureAndSend();
    });
  }

  Future<void> _captureAndSend() async {
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing) return;

    _isProcessing = true;
    try {
      final XFile file = await _controller!.takePicture();
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      
      trackingService.sendFrame(base64String);
    } catch (e) {
      print("Capture error: $e");
    } finally {
      _isProcessing = false;
    }
  }

  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
  }
}
