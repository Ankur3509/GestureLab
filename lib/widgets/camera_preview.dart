import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import '../gesture_engine/gesture_state.dart';

class CameraPreviewWidget extends StatefulWidget {
  const CameraPreviewWidget({Key? key}) : super(key: key);

  @override
  State<CameraPreviewWidget> createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  ui.Image? _cameraFrame;
  Uint8List? _lastBytes;
  bool _isProcessing = false;

  void _updateFrame(Uint8List imageBytes) async {
    if (_lastBytes == imageBytes || _isProcessing) return;
    _lastBytes = imageBytes;
    _isProcessing = true;
    
    try {
      final codec = await ui.instantiateImageCodec(imageBytes);
      final frame = await codec.getNextFrame();
      if (mounted) {
        setState(() {
          _cameraFrame = frame.image;
        });
      }
    } catch (e) {
      // Decode errors can happen briefly during connection
    } finally {
      _isProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GestureState>(context, listen: false);
    
    return ValueListenableBuilder<Uint8List?>(
      valueListenable: state.cameraFrame,
      builder: (context, frameBytes, child) {
        if (frameBytes != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateFrame(frameBytes);
          });
        }

        return Container(
          width: 240,
          height: 180,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.cyanAccent.withOpacity(0.5), width: 2),
            borderRadius: BorderRadius.circular(8),
            color: Colors.black.withOpacity(0.7),
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                // Camera feed background
                if (_cameraFrame != null)
                  CustomPaint(
                    painter: _CameraFramePainter(_cameraFrame!),
                    size: Size.infinite,
                  )
                else
                  Container(
                    color: Colors.black87,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.videocam,
                            color: Colors.cyanAccent.withOpacity(0.5),
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'HAND TRACKING',
                            style: TextStyle(
                              color: Colors.cyanAccent.withOpacity(0.7),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 30,
                            height: 3,
                            decoration: BoxDecoration(
                              color: Colors.greenAccent,
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.greenAccent.withOpacity(0.5),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ACTIVE',
                            style: TextStyle(
                              color: Colors.greenAccent.withOpacity(0.8),
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Overlay grid
                CustomPaint(
                  painter: _GridOverlayPainter(),
                  size: Size.infinite,
                ),
                
                // Corner brackets
                Positioned(
                  top: 8,
                  left: 8,
                  child: _buildCornerBracket(true, true),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: _buildCornerBracket(true, false),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: _buildCornerBracket(false, true),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: _buildCornerBracket(false, false),
                ),
                
                // Status indicator
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: Colors.greenAccent.withOpacity(0.5), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.greenAccent.withOpacity(0.9),
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCornerBracket(bool top, bool left) {
    return CustomPaint(
      size: const Size(12, 12),
      painter: _CornerBracketPainter(top: top, left: left),
    );
  }
}

class _CameraFramePainter extends CustomPainter {
  final ui.Image image;

  _CameraFramePainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    final src = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    final dst = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawImageRect(image, src, dst, Paint());
  }

  @override
  bool shouldRepaint(_CameraFramePainter oldDelegate) => image != oldDelegate.image;
}

class _GridOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.15)
      ..strokeWidth = 0.5;

    // Draw grid
    for (int i = 1; i < 4; i++) {
      double x = size.width * i / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (int i = 1; i < 3; i++) {
      double y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    
    // Center crosshair
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    canvas.drawLine(
      Offset(centerX - 10, centerY),
      Offset(centerX + 10, centerY),
      paint..strokeWidth = 1.0,
    );
    canvas.drawLine(
      Offset(centerX, centerY - 10),
      Offset(centerX, centerY + 10),
      paint,
    );
  }

  @override
  bool shouldRepaint(_GridOverlayPainter oldDelegate) => false;
}

class _CornerBracketPainter extends CustomPainter {
  final bool top;
  final bool left;

  _CornerBracketPainter({required this.top, required this.left});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.7)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    if (top && left) {
      path.moveTo(size.width, 0);
      path.lineTo(0, 0);
      path.lineTo(0, size.height);
    } else if (top && !left) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (!top && left) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CornerBracketPainter oldDelegate) => false;
}
