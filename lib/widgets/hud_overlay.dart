import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../gesture_engine/gesture_state.dart';

class HudOverlay extends StatelessWidget {
  final String modeName;
  final String modeDesc;

  const HudOverlay({
    Key? key, 
    required this.modeName,
    required this.modeDesc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GestureState>(context, listen: false);
    return Stack(
      children: [
        // Top Left: App Title
        Positioned(
          top: 40,
          left: 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "GESTURE LAB",
                style: GoogleFonts.orbitron(
                  color: Colors.cyanAccent,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              Row(
                children: [
                   Text(
                    "MATHEMATICAL REALITY v1.0",
                    style: GoogleFonts.orbitron(
                      color: Colors.cyanAccent.withOpacity(0.5),
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.greenAccent, blurRadius: 4),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "SENSORS ACTIVE",
                    style: GoogleFonts.orbitron(
                      color: Colors.greenAccent.withOpacity(0.7),
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Bottom Left: Mode Info & Controls
        Positioned(
          bottom: 40,
          left: 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                  color: Colors.black.withOpacity(0.4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "CURRENT MODE",
                      style: GoogleFonts.orbitron(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      modeName,
                      style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      modeDesc,
                      style: GoogleFonts.roboto(
                        color: Colors.cyanAccent.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildButton("PREV", () => state.prevMode()),
                  const SizedBox(width: 12),
                  _buildButton("NEXT", () => state.nextMode()),
                  const SizedBox(width: 12),
                  _buildButton("RESET", () => state.reset(), isAction: true),
                ],
              ),
            ],
          ),
        ),

        // Bottom Right: Stats
        Positioned(
          bottom: 40,
          right: 40,
          child: Selector<GestureState, (double, double, double)>(
            selector: (_, s) => (s.scale, s.rotation, s.intensity),
            builder: (context, data, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildStat("SCALE", data.$1.toStringAsFixed(2)),
                  _buildStat("ROTATION", "${(data.$2 * 180 / 3.14).toStringAsFixed(0)}°"),
                  _buildStat("INTENSITY", "${(data.$3 * 100).toStringAsFixed(0)}%"),
                ],
              );
            },
          ),
        ),

        // Scanning animation overlay (subtle)
        IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.cyanAccent.withOpacity(0.05),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.cyanAccent.withOpacity(0.05),
                ],
                stops: const [0, 0.4, 0.6, 1],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(String label, VoidCallback onTap, {bool isAction = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.cyanAccent.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(
              color: isAction ? Colors.orangeAccent.withOpacity(0.5) : Colors.cyanAccent.withOpacity(0.5),
            ),
            borderRadius: BorderRadius.circular(4),
            color: isAction ? Colors.orangeAccent.withOpacity(0.1) : Colors.cyanAccent.withOpacity(0.05),
          ),
          child: Text(
            label,
            style: GoogleFonts.orbitron(
              color: isAction ? Colors.orangeAccent : Colors.cyanAccent,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$label ",
            style: GoogleFonts.orbitron(color: Colors.white54, fontSize: 10),
          ),
          Text(
            value,
            style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
