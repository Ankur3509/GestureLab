import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'gesture_engine/gesture_state.dart';
import 'widgets/camera_preview.dart';
import 'render_engine/visual_engine.dart';
import 'widgets/hud_overlay.dart';
import 'visual_modes/visual_mode.dart';
import 'visual_modes/geometry_mode.dart';
import 'visual_modes/function_mode.dart';
import 'visual_modes/wave_mode.dart';
import 'visual_modes/particle_mode.dart';
import 'visual_modes/morph_mode.dart';
import 'visual_modes/cube_3d_mode.dart';
import 'visual_modes/sphere_3d_mode.dart';
import 'hand_tracking/hand_tracking_service.dart';
import 'hand_tracking/web_capture_service.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GestureState(),
      child: const GestureLabApp(),
    ),
  );
}

class GestureLabApp extends StatelessWidget {
  const GestureLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GestureLab – Interactive Mathematical Reality',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const GestureLabHome(),
    );
  }
}

class GestureLabHome extends StatefulWidget {
  const GestureLabHome({super.key});

  @override
  State<GestureLabHome> createState() => _GestureLabHomeState();
}

class _GestureLabHomeState extends State<GestureLabHome> {
  final List<VisualMode> _modes = [
    GeometryPlayground(),
    Cube3DMode(),
    Sphere3DMode(),
    ParticleGalaxy(),
    FunctionUniverse(),
    WaveLab(),
    ShapeMorphEngine(),
  ];

  late HandTrackingService _trackingService;
  late WebCaptureService _webCaptureService;

  @override
  void initState() {
    super.initState();
    final gestureState = Provider.of<GestureState>(context, listen: false);
    _trackingService = HandTrackingService(gestureState);
    _trackingService.connect();
    
    _webCaptureService = WebCaptureService(_trackingService);
    _webCaptureService.initialize();
  }

  @override
  void dispose() {
    _webCaptureService.dispose();
    _trackingService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    _trackingService.updateScreenSize(screenSize);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background - Visual Engine
          VisualEngine(gestureState: Provider.of<GestureState>(context, listen: false)),

          // Foreground - HUD & Interaction
          Selector<GestureState, int>(
            selector: (_, state) => state.currentModeIndex,
            builder: (context, modeIndex, child) {
              final currentMode = _modes[modeIndex];
              return HudOverlay(
                modeName: currentMode.name,
                modeDesc: currentMode.description,
              );
            },
          ),

          // User interaction layer
          GestureDetector(
            onPanUpdate: (details) {
              final state = Provider.of<GestureState>(context, listen: false);
              state.translation += details.delta;
              state.notifyListeners(); // Manual update
            },
            onDoubleTap: () {
              Provider.of<GestureState>(context, listen: false).nextMode();
            },
            onLongPress: () {
              Provider.of<GestureState>(context, listen: false).reset();
            },
          ),
          
          // Camera Preview
          const Positioned(
            top: 100,
            right: 40,
            child: CameraPreviewWidget(),
          ),
          
          // Floating Hint
          const Positioned(
            top: 100,
            left: 40,
            child: Text(
              "PINCH TO ZOOM | ROTATE WRIST | SWIPE TO CHANGE MODE | SPREAD FINGERS TO RESET",
              style: TextStyle(color: Colors.white24, fontSize: 8),
            ),
          ),
        ],
      ),
    );
  }
}
