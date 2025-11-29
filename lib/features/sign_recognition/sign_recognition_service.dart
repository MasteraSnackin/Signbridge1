/// Sign Recognition Service
/// 
/// Orchestrates the complete sign-to-speech pipeline:
/// Camera Frame → Hand Detection → Gesture Classification → Text Conversion → Speech Output
/// 
/// This is the main service that coordinates all sign recognition components.

import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import '../../core/models/hand_landmarks.dart';
import '../../core/models/sign_gesture.dart';
import '../../core/models/recognition_result.dart';
import '../../core/services/camera_service.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/performance_monitor.dart';
import '../../core/utils/error_handler.dart';
import 'hand_landmark_detector.dart';
import 'gesture_classifier.dart';
import 'sign_to_text_converter.dart';
import '../text_to_speech/tts_service.dart';

/// Sign recognition configuration
class SignRecognitionConfig {
  /// Whether to enable automatic speech output
  final bool autoSpeak;
  
  /// Whether to speak individual letters or wait for complete words
  final bool speakLetters;
  
  /// Text conversion configuration
  final SignToTextConfig textConfig;
  
  /// Whether to show debug information
  final bool showDebug;
  
  const SignRecognitionConfig({
    this.autoSpeak = true,
    this.speakLetters = false,
    this.textConfig = SignToTextConfig.defaultConfig,
    this.showDebug = false,
  });
  
  /// Default configuration
  static const SignRecognitionConfig defaultConfig = SignRecognitionConfig();
}

/// Sign recognition state
enum SignRecognitionState {
  idle,
  initializing,
  ready,
  recognizing,
  paused,
  error,
}

/// Sign recognition service
class SignRecognitionService extends ChangeNotifier {
  final _logger = Logger('SignRecognitionService');
  final _performanceMonitor = PerformanceMonitor.instance;
  
  /// Services
  final _cameraService = CameraService();
  final _handDetector = HandLandmarkDetector();
  final _gestureClassifier = GestureClassifier();
  late final SignToTextConverter _textConverter;
  final _ttsService = TTSService();
  
  /// Configuration
  SignRecognitionConfig _config = SignRecognitionConfig.defaultConfig;
  SignRecognitionConfig get config => _config;
  
  /// Current state
  SignRecognitionState _state = SignRecognitionState.idle;
  SignRecognitionState get state => _state;
  
  /// Camera controller
  CameraController? get cameraController => _cameraService.controller;
  
  /// Current hand landmarks (for debug visualization)
  HandLandmarks? _currentLandmarks;
  HandLandmarks? get currentLandmarks => _currentLandmarks;
  
  /// Current gesture
  SignGesture? _currentGesture;
  SignGesture? get currentGesture => _currentGesture;
  
  /// Current text result
  String _recognizedText = '';
  String get recognizedText => _recognizedText;
  
  /// Current word being built
  String _currentWord = '';
  String get currentWord => _currentWord;
  
  /// Completed words
  List<String> _completedWords = [];
  List<String> get completedWords => List.unmodifiable(_completedWords);
  
  /// Current confidence
  double _confidence = 0.0;
  double get confidence => _confidence;
  
  /// Whether currently processing a frame
  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;
  
  /// Frame processing subscription
  StreamSubscription<CameraImage>? _frameSubscription;
  
  /// Text conversion subscription
  StreamSubscription<TextConversionResult>? _textSubscription;
  
  /// Statistics
  int _framesProcessed = 0;
  int _gesturesRecognized = 0;
  int _wordsCompleted = 0;
  
  int get framesProcessed => _framesProcessed;
  int get gesturesRecognized => _gesturesRecognized;
  int get wordsCompleted => _wordsCompleted;
  
  /// Whether debug info should be shown
  bool get showDebug => _config.showDebug;
  
  SignRecognitionService() {
    _textConverter = SignToTextConverter(config: _config.textConfig);
    _setupTextSubscription();
  }
  
  /// Initialize the service
  Future<void> initialize({SignRecognitionConfig? config}) async {
    if (_state == SignRecognitionState.initializing) {
      _logger.warning('Already initializing');
      return;
    }
    
    if (_state == SignRecognitionState.ready || _state == SignRecognitionState.recognizing) {
      _logger.info('Already initialized');
      return;
    }
    
    try {
      _setState(SignRecognitionState.initializing);
      _logger.info('Initializing sign recognition service...');
      
      // Update configuration
      if (config != null) {
        _config = config;
        _textConverter = SignToTextConverter(config: config.textConfig);
        _setupTextSubscription();
      }
      
      // Initialize camera
      await _cameraService.initialize();
      _logger.info('Camera initialized');
      
      // Initialize hand detector
      await _handDetector.initialize();
      _logger.info('Hand detector initialized');
      
      // Initialize TTS
      await _ttsService.initialize();
      _logger.info('TTS initialized');
      
      _setState(SignRecognitionState.ready);
      _logger.info('Sign recognition service initialized successfully');
    } catch (e, stackTrace) {
      _logger.error('Failed to initialize sign recognition service', e, stackTrace);
      _setState(SignRecognitionState.error);
      await ErrorHandler.handleError(e, ErrorContext.signRecognition, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Start recognition
  Future<void> startRecognition() async {
    if (_state != SignRecognitionState.ready && _state != SignRecognitionState.paused) {
      throw StateError('Cannot start recognition from state: $_state');
    }
    
    try {
      _logger.info('Starting sign recognition...');
      
      // Start camera streaming
      await _cameraService.startStreaming();
      
      // Subscribe to frame stream
      _frameSubscription = _cameraService.frameStream.listen(
        _processFrame,
        onError: (error, stackTrace) {
          _logger.error('Error in frame stream', error, stackTrace);
          ErrorHandler.handleError(error, ErrorContext.signRecognition, stackTrace: stackTrace);
        },
      );
      
      _setState(SignRecognitionState.recognizing);
      _logger.info('Sign recognition started');
    } catch (e, stackTrace) {
      _logger.error('Failed to start recognition', e, stackTrace);
      await ErrorHandler.handleError(e, ErrorContext.signRecognition, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Stop recognition
  Future<void> stopRecognition() async {
    if (_state != SignRecognitionState.recognizing) {
      _logger.warning('Not currently recognizing');
      return;
    }
    
    try {
      _logger.info('Stopping sign recognition...');
      
      // Cancel frame subscription
      await _frameSubscription?.cancel();
      _frameSubscription = null;
      
      // Stop camera streaming
      await _cameraService.stopStreaming();
      
      // Complete current word if any
      _textConverter.completeWord();
      
      _setState(SignRecognitionState.ready);
      _logger.info('Sign recognition stopped');
    } catch (e, stackTrace) {
      _logger.error('Error stopping recognition', e, stackTrace);
    }
  }
  
  /// Pause recognition
  Future<void> pauseRecognition() async {
    if (_state != SignRecognitionState.recognizing) {
      _logger.warning('Not currently recognizing');
      return;
    }
    
    try {
      _logger.info('Pausing sign recognition...');
      
      await _frameSubscription?.cancel();
      _frameSubscription = null;
      
      _setState(SignRecognitionState.paused);
      _logger.info('Sign recognition paused');
    } catch (e, stackTrace) {
      _logger.error('Error pausing recognition', e, stackTrace);
    }
  }
  
  /// Resume recognition
  Future<void> resumeRecognition() async {
    if (_state != SignRecognitionState.paused) {
      _logger.warning('Not currently paused');
      return;
    }
    
    await startRecognition();
  }
  
  /// Process a single camera frame
  Future<void> _processFrame(CameraImage frame) async {
    // Skip if already processing
    if (_isProcessing) {
      return;
    }
    
    _isProcessing = true;
    final stopwatch = Stopwatch()..start();
    
    try {
      _framesProcessed++;
      
      // Step 1: Detect hand landmarks
      final detectionResult = await _handDetector.detectFromFrame(frame);
      
      if (!detectionResult.hasHand) {
        // No hand detected - clear current gesture
        _currentLandmarks = null;
        _currentGesture = null;
        _textConverter.processGesture(null);
        notifyListeners();
        return;
      }
      
      _currentLandmarks = detectionResult.landmarks;
      
      // Step 2: Classify gesture
      final classificationResult = await _gestureClassifier.classify(
        detectionResult.landmarks!,
      );
      
      if (classificationResult.letter != null) {
        _gesturesRecognized++;
        
        // Create gesture object
        _currentGesture = SignGesture(
          letter: classificationResult.letter!,
          confidence: classificationResult.confidence,
          timestamp: DateTime.now(),
          landmarks: detectionResult.landmarks!,
          processingTime: stopwatch.elapsed,
        );
        
        // Step 3: Convert to text
        _textConverter.processGesture(_currentGesture);
        
        // Step 4: Speak if configured
        if (_config.autoSpeak && _config.speakLetters) {
          await _ttsService.speakLetter(classificationResult.letter!);
        }
      } else {
        _currentGesture = null;
        _textConverter.processGesture(null);
      }
      
      stopwatch.stop();
      
      // Record performance
      _performanceMonitor.recordLatency(
        operation: 'frame_processing',
        duration: stopwatch.elapsed,
        source: ProcessingSource.local,
      );
      
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.error('Error processing frame', e, stackTrace);
    } finally {
      _isProcessing = false;
    }
  }
  
  /// Setup text conversion subscription
  void _setupTextSubscription() {
    _textSubscription?.cancel();
    
    _textSubscription = _textConverter.textStream.listen((result) {
      _recognizedText = result.fullText;
      _currentWord = result.currentWord;
      _completedWords = result.completedWords;
      _confidence = result.confidence;
      
      // Speak completed words
      if (_config.autoSpeak && !_config.speakLetters) {
        // Check if a new word was completed
        if (_completedWords.length > _wordsCompleted) {
          final newWord = _completedWords.last;
          _ttsService.speakWord(newWord);
          _wordsCompleted = _completedWords.length;
        }
      }
      
      notifyListeners();
    });
  }
  
  /// Manually complete current word
  void completeWord() {
    _textConverter.completeWord();
  }
  
  /// Delete last letter
  void deleteLastLetter() {
    _textConverter.deleteLastLetter();
  }
  
  /// Delete last word
  void deleteLastWord() {
    _textConverter.deleteLastWord();
    if (_wordsCompleted > 0) {
      _wordsCompleted--;
    }
  }
  
  /// Clear all text
  void clearText() {
    _logger.info('Clearing all text');
    _textConverter.clear();
    _recognizedText = '';
    _currentWord = '';
    _completedWords = [];
    _wordsCompleted = 0;
    notifyListeners();
  }
  
  /// Speak current text
  Future<void> speakCurrentText() async {
    if (_recognizedText.isNotEmpty) {
      await _ttsService.speak(_recognizedText);
    }
  }
  
  /// Update configuration
  void updateConfig(SignRecognitionConfig newConfig) {
    _logger.info('Updating configuration');
    _config = newConfig;
    
    // Update text converter if config changed
    if (newConfig.textConfig != _config.textConfig) {
      _textConverter = SignToTextConverter(config: newConfig.textConfig);
      _setupTextSubscription();
    }
    
    notifyListeners();
  }
  
  /// Toggle debug mode
  void toggleDebug() {
    updateConfig(SignRecognitionConfig(
      autoSpeak: _config.autoSpeak,
      speakLetters: _config.speakLetters,
      textConfig: _config.textConfig,
      showDebug: !_config.showDebug,
    ));
  }
  
  /// Get statistics
  Map<String, dynamic> getStatistics() {
    return {
      'state': _state.toString(),
      'framesProcessed': _framesProcessed,
      'gesturesRecognized': _gesturesRecognized,
      'wordsCompleted': _wordsCompleted,
      'currentWord': _currentWord,
      'completedWords': _completedWords.length,
      'totalCharacters': _recognizedText.length,
      'averageConfidence': _confidence,
      'textConverter': _textConverter.getStatistics(),
      'tts': _ttsService.getStatistics(),
      'performance': _performanceMonitor.getStats(),
    };
  }
  
  /// Set state and notify listeners
  void _setState(SignRecognitionState newState) {
    if (_state != newState) {
      _logger.debug('State changed: $_state → $newState');
      _state = newState;
      notifyListeners();
    }
  }
  
  /// Dispose resources
  @override
  void dispose() {
    _logger.info('Disposing sign recognition service');
    
    stopRecognition();
    _frameSubscription?.cancel();
    _textSubscription?.cancel();
    _textConverter.dispose();
    _handDetector.dispose();
    _cameraService.dispose();
    
    super.dispose();
  }
}