#include <iostream>

#if defined(_WIN32)
#define FFI_EXPORT __declspec(dllexport)
#else
#define FFI_EXPORT
#endif

extern "C" {
    FFI_EXPORT void process_frame(unsigned char* data, int width, int height) {
        // This is where OpenCV and MediaPipe code would go.
        // Example: 
        // cv::Mat frame(height, width, CV_8UC3, data);
        // auto results = hand_tracker.Process(frame);
        // ... return landmarks to Dart via a callback or return value ...
        
        std::cout << "Processing frame: " << width << "x" << height << std::endl;
    }
}
