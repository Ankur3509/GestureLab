import cv2
import mediapipe as mp
import eventlet
import socketio
import math
import base64
import numpy as np
import os

# Initialize Socket.IO server with CORS enabled for all origins
sio = socketio.Server(cors_allowed_origins='*', async_mode='eventlet')
app = socketio.WSGIApp(sio)

# MediaPipe Setup
try:
    import mediapipe as mp
    mp_hands = mp.solutions.hands
    mp_drawing = mp.solutions.drawing_utils
except (AttributeError, ImportError):
    import mediapipe.python.solutions.hands as mp_hands
    import mediapipe.python.solutions.drawing_utils as mp_drawing

hands = mp_hands.Hands(
    static_image_mode=False,
    max_num_hands=2,
    min_detection_confidence=0.6,
    min_tracking_confidence=0.5,
    model_complexity=1
)

@sio.event
def connect(sid, environ):
    print(f'Client connected: {sid}')

@sio.event
def disconnect(sid):
    print(f'Client disconnected: {sid}')

@sio.on('process_frame')
def handle_frame(sid, data):
    """
    Receives a base64 encoded frame from the client, 
    processes it with MediaPipe, and returns landmarks.
    """
    try:
        # Decode base64 image
        if 'image' not in data:
            return
            
        img_data = base64.b64decode(data['image'])
        nparr = np.frombuffer(img_data, np.uint8)
        image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        
        if image is None:
            return

        # Process with MediaPipe
        image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        results = hands.process(image_rgb)

        hand_data = []
        if results.multi_hand_landmarks:
            for hand_landmarks in results.multi_hand_landmarks:
                marks = []
                for lm in hand_landmarks.landmark:
                    marks.append({'x': lm.x, 'y': lm.y, 'z': lm.z})
                hand_data.append(marks)

        # Emit back the landmarks
        sio.emit('hand_update', hand_data, room=sid)
        
        # Optional: Return processed frame with landmarks drawn (for HUD)
        if data.get('want_preview', False):
            for hand_landmarks in results.multi_hand_landmarks or []:
                mp_drawing.draw_landmarks(
                    image, hand_landmarks, mp_hands.HAND_CONNECTIONS,
                    mp_drawing.DrawingSpec(color=(0, 255, 255), thickness=2, circle_radius=2),
                    mp_drawing.DrawingSpec(color=(255, 0, 255), thickness=2)
                )
            
            preview = cv2.resize(image, (320, 240))
            _, buffer = cv2.imencode('.jpg', preview, [cv2.IMWRITE_JPEG_QUALITY, 60])
            frame_b64 = base64.b64encode(buffer).decode('utf-8')
            sio.emit('camera_frame', {'frame': frame_b64}, room=sid)

    except Exception as e:
        print(f"Error processing frame: {e}")

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5050))
    print(f"🚀 GESTURELAB BACKEND - Listening on port {port}")
    eventlet.wsgi.server(eventlet.listen(('0.0.0.0', port)), app)

