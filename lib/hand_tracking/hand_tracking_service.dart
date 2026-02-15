import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';
import 'dart:convert';
import '../gesture_engine/gesture_state.dart';

class HandTrackingService {
  late IO.Socket socket;
  final GestureState gestureState;
  Size? screenSize;

  HandTrackingService(this.gestureState);

  void connect() {
    // Connect to the Python bridge - Use local network IP for mobile support
    // Replace with your actual IP or Render URL
    const String serverUrl = 'http://192.168.1.7:5050';
    
    socket = IO.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) {
      print('✅ Connected to Hand Tracking Bridge at $serverUrl');
    });

    socket.on('hand_update', (data) {
      if (data is List) {
        List<HandData> hands = [];
        for (var handMap in data) {
          if (handMap is List) {
            List<HandLandmark> landmarks = [];
            for (var lm in handMap) {
              landmarks.add(HandLandmark(
                (lm['x'] as num).toDouble(),
                (lm['y'] as num).toDouble(),
                (lm['z'] as num).toDouble(),
              ));
            }
            hands.add(HandData(landmarks: landmarks, isLeft: false));
          }
        }
        
        gestureState.updateFromHands(hands, screenSize: screenSize);
      }
    });

    socket.on('camera_frame', (data) {
      if (data is Map && data.containsKey('frame')) {
        final String base64Frame = data['frame'];
        gestureState.updateCameraFrame(base64.decode(base64Frame));
      }
    });

    socket.onDisconnect((_) => print('❌ Disconnected from Bridge'));
    socket.onError((error) => print('⚠️ Socket error: $error'));
  }

  void sendFrame(String base64Image) {
    if (socket.connected) {
      socket.emit('process_frame', {
        'image': base64Image,
        'want_preview': true, // We want the processed frame back for HUD
      });
    }
  }

  void updateScreenSize(Size size) {
    screenSize = size;
  }

  void dispose() {
    socket.dispose();
  }
}

