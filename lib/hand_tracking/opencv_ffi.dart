import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'dart:io';

// C signatures
typedef NativeProcessFrame = ffi.Void Function(ffi.Pointer<ffi.Uint8> data, ffi.Int32 width, ffi.Int32 height);
typedef ProcessFrame = void Function(ffi.Pointer<ffi.Uint8> data, int width, int height);

class OpenCVBridge {
  late ffi.DynamicLibrary _lib;
  late ProcessFrame _processFrame;

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  OpenCVBridge() {
    try {
      if (Platform.isWindows) {
        _lib = ffi.DynamicLibrary.open('hand_tracker.dll');
      } else if (Platform.isAndroid || Platform.isLinux) {
        _lib = ffi.DynamicLibrary.open('libhand_tracker.so');
      } else {
        _lib = ffi.DynamicLibrary.process();
      }

      _processFrame = _lib
          .lookup<ffi.NativeFunction<NativeProcessFrame>>('process_frame')
          .asFunction();
      
      _isAvailable = true;
    } catch (e) {
      print("OpenCV Library not found. Falling back to internal simulation.");
    }
  }

  void process(List<int> bytes, int width, int height) {
    if (!_isAvailable) return;
    
    final pointer = calloc<ffi.Uint8>(bytes.length);
    final byteList = pointer.asTypedList(bytes.length);
    byteList.setAll(0, bytes);
    
    _processFrame(pointer, width, height);
    
    calloc.free(pointer);
  }
}
