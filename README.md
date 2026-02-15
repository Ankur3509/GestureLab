# 🌌 GestureLab – Interactive Mathematical Reality

A futuristic, exhibition-grade Flutter application where mathematical universes are controlled using **real-time hand gestures**. Experience a touchless interface that feels like JARVIS, powered by MediaPipe and Flutter's high-performance rendering engine.

![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Android%20%7C%20iOS-blue?style=for-the-badge)
![Flutter](https://img.shields.io/badge/Flutter-3.9+-02569B?style=for-the-badge&logo=flutter)
![Python](https://img.shields.io/badge/Python-3.8+-3776AB?style=for-the-badge&logo=python)
![MediaPipe](https://img.shields.io/badge/MediaPipe-Tracking-007f7b?style=for-the-badge)

---

## ✨ Core Features

### 🎮 Touchless Gesture Interface
Direct manipulation of 3D and 2D mathematical spaces:
- **👆 Precision Pinch**: Thumb + Index distance controls **Visual Scale (Zoom)**.
- **🔄 Wrist Torque**: Rotate your wrist to spin the geometry via **Axis Rotation**.
- **✋ Palm Tracking**: 1:1 mapping of your hand position to **Spatial Translation**.
- **🤏 Dual Hand Control**: Engage both hands for **Exponential Scaling**.
- **👋 Dynamic Swipe**: Quick horizontal movement to cycle through **Visualization Modes**.
- **🖐️ Reset Gesture**: Open palm spread to instantly normalize the environment.

### 🌟 Interactive Visualization Modes
1. **Geometry Playground**: Affine transformations with neon grids and real-time snapping.
2. **Cube & Sphere 3D**: High-performance 3D primitives with lighting and glow.
3. **Particle Galaxy**: 2000+ particles reacting to hand gravity and rotation velocity.
4. **Function Universe**: Live mathematical wave functions (Sine, Cosine, Parabola).
5. **Wave Distortion Lab**: Gravitational mesh warping with local hand influence.
6. **Shape Morph Engine**: Seamless interpolation between Geometric Primitives.

### 🎨 Visual Identity
- **Dark Matter Aesthetic**: Deep black backgrounds with cyan/neon accents.
- **Cyber HUD Overlay**: Real-time telemetry (Scale, Rotation, Intensity) with sci-fi typography.
- **Micro-Animations**: Smooth transitions powered by `flutter_animate`.
- **Active Scanning**: Live camera preview with hand landmark visualization.

---

## ⚡ Performance & Optimization
*Recently optimized for maximum responsiveness:*

- **Selective Repainting**: Only the `CustomPainter` repaints during hand movement, preventing full widget tree rebuilds.
- **Throttled Frame Decoding**: Camera preview frames are decoded only when the UI thread is idle.
- **ValueNotifier Architecture**: Real-time telemetry updates (Scale/Rotation) now bypass Global State notifications.
- **Zero-Latency Smoothing**: 5-frame moving average with linear interpolation for jitter-free tracking.

---

## 🚀 Installation & Quick Start

### 1️⃣ Dependencies
- **Flutter SDK** (3.9+)
- **Python 3.8+**
- **Webcam**

### 2️⃣ Clone & Setup
```bash
git clone https://github.com/yourusername/GestureLab.git
cd GestureLab

# Install Flutter packages
flutter pub get

# Install Python Hand Tracking dependencies
pip install opencv-python mediapipe flask flask-socketio eventlet numpy
```

### 3️⃣ Launch Sequence
**Terminal 1 (The Brain):**
```bash
python native/hand_tracker.py
```
*Wait for "🎯 Waiting for Flutter app to connect..."*

**Terminal 2 (The Interface):**
```bash
flutter run -d windows  # Or your preferred device
```

---

## 📱 Mobile Deployment (Android/iOS)

1. **Find your Local IP**: Run `ipconfig` (Windows) or `ifconfig` (Mac).
2. **Update Config**: In `lib/hand_tracking/hand_tracking_service.dart`, update the `serverUrl` string with your computer's IP.
3. **Network**: Ensure both devices are on the same WiFi.
4. **Build**:
   - **Android**: `flutter build apk --release`
   - **iOS**: Build through Xcode (`ios/Runner.xcworkspace`)

---

## 🏗️ Technical Architecture

| Layer | Responsibility | Technology |
|-------|----------------|------------|
| **Tracking** | Hand Pose Estimation | Python + MediaPipe |
| **Bridge** | Real-time Data Streaming | Socket.IO (WebSockets) |
| **Engine** | Gesture Interpretation | Dart State Management |
| **Rendering** | High-performance Graphics | Flutter CustomPainter + Tickers |
| **UI/HUD** | User Feedback & Telemetry | Flutter Widgets + Google Fonts |

---

## 🛠️ Troubleshooting

- **Low FPS?**: Ensure your laptop is plugged in. Performance modes significantly improve MediaPipe tracking speed.
- **No Connection?**: Check your Firewall settings. Port `5050` must be reachable.
- **Jittery Movement?**: Improve lighting. MediaPipe performs best with clear palm visibility.

---

## 📜 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Developed for the next generation of Human-Computer Interaction.**
*Crafted with high-frequency math and neon light.*
