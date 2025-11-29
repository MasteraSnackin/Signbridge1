import 'dart:async';
import 'package:camera/camera.dart';
import 'package:signbridge/config/app_config.dart';
import 'package:signbridge/core/utils/logger.dart';
import 'package:signbridge/core/utils/error_handler.dart';

/// Service for managing camera operations
/// 
/// Handles camera initialization, frame streaming, and lifecycle management.
/// Optimized for real-time hand gesture recognition.
class CameraService {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isStreaming = false;
  CameraImage? _currentFrame;
  
  // Stream controller for frame updates
  final _frameController = StreamController<CameraImage>.broadcast();
  
  // Frame processing rate limiter
  DateTime? _lastFrameTime;
  final _frameInterval = Duration(
    milliseconds: 1000 ~/ AppConfig.cameraFPS,
  );
  
  /// Check if camera is initialized
  bool get isInitialized => _isInitialized;
  
  /// Check if camera is streaming
  bool get isStreaming => _isStreaming;
  
  /// Get camera controller
  CameraController? get controller => _controller;
  
  /// Stream of camera frames
  Stream<CameraImage> get frameStream => _frameController.stream;
  
  /// Initialize camera
  Future<void> initialize() async {
    if (_isInitialized) {
      Logger.warning('Camera already initialized', 'CAMERA');
      return;
    }
    
    try {
      Logger.info('Initializing camera...', 'CAMERA');
      
      // Get available cameras
      final cameras = await availableCameras();
      
      if (cameras.isEmpty) {
        throw CameraException('No cameras available');
      }
      
      // Use front camera for sign language (user facing)
      final camera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      
      Logger.info('Using camera: ${camera.name}', 'CAMERA');
      
      // Create controller
      _controller = CameraController(
        camera,
        _getResolutionPreset(),
        enableAudio: AppConfig.cameraEnableAudio,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      
      // Initialize controller
      await _controller!.initialize();
      
      _isInitialized = true;
      Logger.info('Camera initialized successfully', 'CAMERA');
    } catch (e, stackTrace) {
      Logger.error(e, stackTrace, 'CAMERA');
      await ErrorHandler.handleError(
        CameraException('Failed to initialize camera: $e'),
        ErrorContext.cameraAccess,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  /// Start streaming frames
  Future<void> startStreaming() async {
    if (!_isInitialized) {
      throw CameraException('Camera not initialized');
    }
    
    if (_isStreaming) {
      Logger.warning('Camera already streaming', 'CAMERA');
      return;
    }
    
    try {
      Logger.info('Starting camera stream...', 'CAMERA');
      
      await _controller!.startImageStream((CameraImage image) {
        _onFrameAvailable(image);
      });
      
      _isStreaming = true;
      Logger.info('Camera streaming started', 'CAMERA');
    } catch (e, stackTrace) {
      Logger.error(e, stackTrace, 'CAMERA');
      throw CameraException('Failed to start streaming: $e');
    }
  }
  
  /// Stop streaming frames
  Future<void> stopStreaming() async {
    if (!_isStreaming) {
      return;
    }
    
    try {
      Logger.info('Stopping camera stream...', 'CAMERA');
      
      await _controller?.stopImageStream();
      
      _isStreaming = false;
      _currentFrame = null;
      _lastFrameTime = null;
      
      Logger.info('Camera streaming stopped', 'CAMERA');
    } catch (e, stackTrace) {
      Logger.error(e, stackTrace, 'CAMERA');
    }
  }
  
  /// Handle incoming frame
  void _onFrameAvailable(CameraImage image) {
    // Rate limiting: only process frames at target FPS
    final now = DateTime.now();
    
    if (_lastFrameTime != null) {
      final elapsed = now.difference(_lastFrameTime!);
      if (elapsed < _frameInterval) {
        return; // Skip this frame
      }
    }
    
    _lastFrameTime = now;
    _currentFrame = image;
    
    // Emit frame to stream
    if (!_frameController.isClosed) {
      _frameController.add(image);
    }
  }
  
  /// Get current frame
  CameraImage? getCurrentFrame() => _currentFrame;
  
  /// Take a picture
  Future<XFile?> takePicture() async {
    if (!_isInitialized) {
      throw CameraException('Camera not initialized');
    }
    
    try {
      Logger.info('Taking picture...', 'CAMERA');
      
      // Stop streaming temporarily
      final wasStreaming = _isStreaming;
      if (wasStreaming) {
        await stopStreaming();
      }
      
      final picture = await _controller!.takePicture();
      
      // Resume streaming if it was active
      if (wasStreaming) {
        await startStreaming();
      }
      
      Logger.info('Picture taken: ${picture.path}', 'CAMERA');
      return picture;
    } catch (e, stackTrace) {
      Logger.error(e, stackTrace, 'CAMERA');
      return null;
    }
  }
  
  /// Switch camera (front/back)
  Future<void> switchCamera() async {
    if (!_isInitialized) {
      throw CameraException('Camera not initialized');
    }
    
    try {
      Logger.info('Switching camera...', 'CAMERA');
      
      final cameras = await availableCameras();
      if (cameras.length < 2) {
        Logger.warning('Only one camera available', 'CAMERA');
        return;
      }
      
      // Stop current camera
      final wasStreaming = _isStreaming;
      await stopStreaming();
      await _controller?.dispose();
      
      // Find other camera
      final currentDirection = _controller!.description.lensDirection;
      final newCamera = cameras.firstWhere(
        (cam) => cam.lensDirection != currentDirection,
        orElse: () => cameras.first,
      );
      
      // Initialize new camera
      _controller = CameraController(
        newCamera,
        _getResolutionPreset(),
        enableAudio: AppConfig.cameraEnableAudio,
      );
      
      await _controller!.initialize();
      
      // Resume streaming if it was active
      if (wasStreaming) {
        await startStreaming();
      }
      
      Logger.info('Camera switched to: ${newCamera.name}', 'CAMERA');
    } catch (e, stackTrace) {
      Logger.error(e, stackTrace, 'CAMERA');
      throw CameraException('Failed to switch camera: $e');
    }
  }
  
  /// Set flash mode
  Future<void> setFlashMode(FlashMode mode) async {
    if (!_isInitialized) {
      throw CameraException('Camera not initialized');
    }
    
    try {
      await _controller!.setFlashMode(mode);
      Logger.info('Flash mode set to: $mode', 'CAMERA');
    } catch (e) {
      Logger.error('Failed to set flash mode: $e', null, 'CAMERA');
    }
  }
  
  /// Set zoom level
  Future<void> setZoomLevel(double zoom) async {
    if (!_isInitialized) {
      throw CameraException('Camera not initialized');
    }
    
    try {
      await _controller!.setZoomLevel(zoom);
      Logger.debug('Zoom level set to: $zoom', 'CAMERA');
    } catch (e) {
      Logger.error('Failed to set zoom level: $e', null, 'CAMERA');
    }
  }
  
  /// Get camera resolution preset based on config
  ResolutionPreset _getResolutionPreset() {
    switch (AppConfig.cameraResolution.toLowerCase()) {
      case 'low':
        return ResolutionPreset.low;
      case 'medium':
        return ResolutionPreset.medium;
      case 'high':
        return ResolutionPreset.high;
      case 'veryhigh':
        return ResolutionPreset.veryHigh;
      case 'ultrahigh':
        return ResolutionPreset.ultraHigh;
      case 'max':
        return ResolutionPreset.max;
      default:
        return ResolutionPreset.high;
    }
  }
  
  /// Get camera info
  Map<String, dynamic> getCameraInfo() {
    if (!_isInitialized || _controller == null) {
      return {'initialized': false};
    }
    
    return {
      'initialized': _isInitialized,
      'streaming': _isStreaming,
      'name': _controller!.description.name,
      'lensDirection': _controller!.description.lensDirection.toString(),
      'sensorOrientation': _controller!.description.sensorOrientation,
      'resolution': '${_controller!.value.previewSize?.width}x${_controller!.value.previewSize?.height}',
      'fps': AppConfig.cameraFPS,
    };
  }
  
  /// Dispose camera resources
  Future<void> dispose() async {
    Logger.info('Disposing camera service...', 'CAMERA');
    
    await stopStreaming();
    await _controller?.dispose();
    await _frameController.close();
    
    _controller = null;
    _isInitialized = false;
    _currentFrame = null;
    
    Logger.info('Camera service disposed', 'CAMERA');
  }
}