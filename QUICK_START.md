# 🎯 QUICK START GUIDE

## ✅ Your App is Now Running!

### What You Should See:
1. **Python Terminal**: Hand tracking server running with camera feed
2. **Flutter App**: Black background with neon cyan UI
3. **Camera Preview**: Small box in top-right showing your webcam
4. **HUD Display**: Stats showing Scale, Rotation, Intensity

---

## 🎮 Controls

### **On-Screen Buttons**
- **PREV / NEXT**: Switch between the 7 mathematical modes.
- **RESET**: Instant reset of all transformations (Scale, Rotation, Position).

### **Hand Gestures**
- **Pinch (Thumb + Index)**: Zoom in and out.
- **Rotate Wrist**: rotate the geometry around the Z-axis (screen plane).
- **Move Hand**: Translate objects and tilt them in 3D (X/Y axes).
- **Two-Hand Zoom**: Move hands apart for massive scaling.

## 📱 Mobile Setup (Android)
To run on your phone:
1. Find your computer's IP address: Run `ipconfig` in command prompt.
2. The app is pre-configured to `192.168.1.7:5050`. If your IP is different, update `lib/hand_tracking/hand_tracking_service.dart`.
3. Build the APK: `flutter build apk`.
4. Install the APK on your phone (ensure phone and PC are on the same WiFi).
5. Start the Python server on your PC: `python native/hand_tracker.py`.

---

## 🎨 VISUAL MODES (Swipe to Switch)

1. **GEOMETRY PLAYGROUND** 🔷
   - Interactive triangles and circles
   - Affine transformation grid
   - Neon glow effects

2. **FUNCTION UNIVERSE** 📈
   - Live sine and cosine waves
   - Mathematical curves
   - Animated coordinate axes

3. **WAVE & DISTORTION LAB** 🌊
   - Rubber mesh grid
   - Gravitational warping
   - Hand creates ripples

4. **PARTICLE GALAXY** ✨
   - Thousands of particles
   - Hand acts as gravity source
   - Swirling vortex effects

5. **SHAPE MORPH ENGINE** 🔄
   - Square → Circle → Star
   - Smooth interpolation
   - Gesture-controlled morphing

---

## 📱 BUILDING FOR MOBILE

### For Android:

1. **Find Your Computer's IP Address**:
   ```bash
   ipconfig
   ```
   Look for "IPv4 Address" (e.g., 192.168.1.100)

2. **Edit Connection Settings**:
   Open: `lib/hand_tracking/hand_tracking_service.dart`
   
   Change line 12:
   ```dart
   socket = IO.io('http://192.168.1.100:5050', ...);  // Use YOUR IP
   ```

3. **Build APK**:
   ```bash
   flutter build apk --release
   ```

4. **Install on Phone**:
   - APK location: `build/app/outputs/flutter-apk/app-release.apk`
   - Transfer to phone and install
   - OR: `flutter install` if connected via USB

5. **Connect**:
   - Make sure phone and computer are on SAME WiFi
   - Python server must be running on computer
   - Open app on phone - it will connect automatically!

---

## 🔧 TROUBLESHOOTING

### "Nothing happens when I move my hands"
✅ Check camera preview - do you see hand tracking lines?
✅ Make sure you have good lighting
✅ Try moving closer to camera (1-2 feet away)
✅ Check console for "Connected to Hand Tracking Bridge"

### "Scale/Rotation not working"
✅ The gestures are VERY responsive now!
✅ Pinch distance: 0.05 (very close) to 0.3 (far apart)
✅ Rotation: Slowly rotate your wrist - watch the geometry spin
✅ Try with ONE hand first, then experiment with TWO hands

### "Camera preview is blank"
✅ This is normal - it shows "TRACKING ACTIVE" when working
✅ The actual camera feed is processed by Python server
✅ Look for hand skeleton overlay in Python terminal window

### Mobile app won't connect
✅ Both devices on same WiFi network?
✅ IP address correct in hand_tracking_service.dart?
✅ Python server running on computer?
✅ Try: `ping 192.168.1.XXX` from phone to test connection

---

## 🎮 PRO TIPS

1. **Best Distance**: 1-2 feet from camera
2. **Lighting**: Face a window or light source
3. **Background**: Plain background works best
4. **Smooth Movements**: Slow, deliberate gestures = better tracking
5. **Two Hands**: Use both hands for mega zoom and intensity boost!

---

## 📊 WHAT'S HAPPENING UNDER THE HOOD

### Gesture → Parameter Mapping:
- **Pinch Distance** → Scale (0.3x to 3.0x zoom)
- **Pinch Tightness** → Intensity (0% to 100%)
- **Wrist Angle** → Rotation (continuous)
- **Palm Position** → Translation (X, Y coordinates)
- **Two-Hand Distance** → Mega Scale (0.5x to 4.0x)

### Smoothing:
- 5-frame moving average on landmarks
- Lerp interpolation (0.15-0.3 factor)
- Angle wrapping for rotation
- Prevents jitter and sudden jumps

### Performance:
- Flutter: 60 FPS rendering
- MediaPipe: 30 FPS hand tracking
- Socket.IO: ~16ms latency
- Total: Smooth real-time control!

---

## 🚀 NEXT STEPS

Want to customize?
- Add new visual modes in `lib/visual_modes/`
- Adjust sensitivity in `lib/gesture_engine/gesture_state.dart`
- Change colors/effects in each mode file
- Add new gestures (peace sign, thumbs up, etc.)

---

**Enjoy controlling mathematical reality with your hands! 🌌**

*No controllers. No touchscreens. Just pure gesture magic.*
