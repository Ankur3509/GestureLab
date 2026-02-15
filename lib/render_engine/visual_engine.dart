import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../gesture_engine/gesture_state.dart';
import '../visual_modes/visual_mode.dart';
import '../visual_modes/geometry_mode.dart';
import '../visual_modes/function_mode.dart';
import '../visual_modes/wave_mode.dart';
import '../visual_modes/particle_mode.dart';
import '../visual_modes/morph_mode.dart';
import '../visual_modes/cube_3d_mode.dart';
import '../visual_modes/sphere_3d_mode.dart';

class VisualEngine extends StatefulWidget {
  final GestureState gestureState;

  const VisualEngine({Key? key, required this.gestureState}) : super(key: key);

  @override
  State<VisualEngine> createState() => _VisualEngineState();
}

class _VisualEngineState extends State<VisualEngine> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  final ValueNotifier<double> _timeNotifier = ValueNotifier<double>(0);
  
  final List<VisualMode> _modes = [
    GeometryPlayground(),
    Cube3DMode(),
    Sphere3DMode(),
    ParticleGalaxy(),
    FunctionUniverse(),
    WaveLab(),
    ShapeMorphEngine(),
  ];

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      _timeNotifier.value = elapsed.inMilliseconds / 1000.0;
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _timeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<GestureState, int>(
      selector: (_, state) => state.currentModeIndex,
      builder: (context, modeIndex, child) {
        final currentMode = _modes[modeIndex];
        return RepaintBoundary(
          child: CustomPaint(
            painter: ModePainter(
              mode: currentMode,
              state: widget.gestureState,
              timeNotifier: _timeNotifier,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }
}
