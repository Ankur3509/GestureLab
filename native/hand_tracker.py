import cv2
import mediapipe as mp
import eventlet
import socketio
import math
import base64
import numpy as np

# Initialize Socket.IO server
sio = socketio.Server(cors_allowed_origins='*', async_mode='eventlet')
app = socketio.WSGIApp(sio)

# MediaPipe Setup
mp_hands = mp.solutions.hands
mp_drawing = mp.solutions.drawing_utils
hands = mp_hands.Hands(
    static_image_mode=False,
    max_num_hands=2,
    min_detection_confidence=0.6,
    min_tracking_confidence=0.5,
    model_complexity=1
)

connected_clients = set()

@sio.event
def connect(sid, environ):
    print(f'Client connected: {sid}')
    connected_clients.add(sid)

@sio.event
def disconnect(sid):
    print(f'Client disconnected: {sid}')
    connected_clients.discard(sid)

def process_tracking():
    cap = cv2.VideoCapture(0)
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
    cap.set(cv2.CAP_PROP_FPS, 30)
    
    print("🎥 Camera started. Hand tracking active...")
    print("✋ Show your hands to control the mathematical reality!")
    
    frame_count = 0
    
    while True:
        success, image = cap.read()
        if not success:
            eventlet.sleep(0.01)
            continue

        frame_count += 1
        
        # Flip for mirroring
        image = cv2.flip(image, 1)
        image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        results = hands.process(image_rgb)

        hand_data = []
        
        # Draw landmarks on image
        if results.multi_hand_landmarks:
            for hand_landmarks in results.multi_hand_landmarks:
                # Draw hand landmarks
                mp_drawing.draw_landmarks(
                    image, 
                    hand_landmarks, 
                    mp_hands.HAND_CONNECTIONS,
                    mp_drawing.DrawingSpec(color=(0, 255, 255), thickness=2, circle_radius=2),
                    mp_drawing.DrawingSpec(color=(255, 0, 255), thickness=2)
                )
                
                # Extract landmarks
                marks = []
                for lm in hand_landmarks.landmark:
                    marks.append({'x': lm.x, 'y': lm.y, 'z': lm.z})
                hand_data.append(marks)

        # Send data to all connected clients
        if connected_clients and hand_data:
            sio.emit('hand_update', hand_data)
        
        # Send camera frame every 3rd frame to reduce bandwidth
        if connected_clients and frame_count % 3 == 0:
            # Resize for preview
            preview = cv2.resize(image, (320, 240))
            _, buffer = cv2.imencode('.jpg', preview, [cv2.IMWRITE_JPEG_QUALITY, 60])
            frame_b64 = base64.b64encode(buffer).decode('utf-8')
            sio.emit('camera_frame', {'frame': frame_b64})
        
        eventlet.sleep(0.016)  # ~60 FPS

if __name__ == '__main__':
    print("=" * 60)
    print("🚀 GESTURELAB - HAND TRACKING SERVER")
    print("=" * 60)
    print("📡 Starting server on http://127.0.0.1:5050")
    print("🎯 Waiting for Flutter app to connect...")
    print()
    
    # Run tracking in a separate eventlet thread
    eventlet.spawn(process_tracking)
    eventlet.wsgi.server(eventlet.listen(('0.0.0.0', 5050)), app)
