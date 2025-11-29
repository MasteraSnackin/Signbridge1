/// Speech Recognition Service
/// 
/// Captures voice input and converts it to text using Whisper-Tiny model.
/// Provides real-time transcription for speech-to-sign translation.
/// 
/// Pipeline: Microphone → Audio Capture → Whisper STT → Text Output

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/services/cactus_model_service.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/performance_monitor.dart';
import '../../core/utils/error_handler.dart';

/// Speech recognition configuration
class SpeechRecognitionConfig {
  /// Language code for recognition (e.g., 'en-US')
  final String language;
  
  /// Whether to enable continuous recognition
  final bool continuous;
  
  /// Maximum recording duration in seconds (0 = unlimited)
  final int maxDuration;
  
  /// Whether to enable partial results
  final bool partialResults;
  
  /// Minimum confidence threshold (0.0-1.0)
  final double minConfidence;
  
  const SpeechRecognitionConfig({
    this.language = 'en-US',
    this.continuous = false,
    this.maxDuration = 30,
    this.partialResults = true,
    this.minConfidence = 0.7,
  });
  
  /// Default configuration
  static const SpeechRecognitionConfig defaultConfig = SpeechRecognitionConfig();
  
  /// Continuous mode (for long conversations)
  static const SpeechRecognitionConfig continuousMode = SpeechRecognitionConfig(
    continuous: true,
    maxDuration: 0,
    partialResults: true,
  );
  
  /// Quick mode (for short phrases)
  static const SpeechRecognitionConfig quickMode = SpeechRecognitionConfig(
    continuous: false,
    maxDuration: 10,
    partialResults: false,
  );
}

/// Speech recognition state
enum SpeechRecognitionState {
  idle,
  initializing,
  ready,
  listening,
  processing,
  error,
}

/// Speech recognition result
class SpeechRecognitionResult {
  /// Transcribed text
  final String text;
  
  /// Confidence score (0.0-1.0)
  final double confidence;
  
  /// Whether this is a final result
  final bool isFinal;
  
  /// Processing time in milliseconds
  final int processingTime;
  
  /// Timestamp
  final DateTime timestamp;
  
  const SpeechRecognitionResult({
    required this.text,
    required this.confidence,
    required this.isFinal,
    required this.processingTime,
    required this.timestamp,
  });
  
  /// Empty result
  static final SpeechRecognitionResult empty = SpeechRecognitionResult(
    text: '',
    confidence: 0.0,
    isFinal: false,
    processingTime: 0,
    timestamp: DateTime.now(),
  );
}

/// Speech recognition service
class SpeechRecognitionService extends ChangeNotifier {
  final _logger = Logger('SpeechRecognitionService');
  final _performanceMonitor = PerformanceMonitor.instance;
  
  /// Configuration
  SpeechRecognitionConfig _config = SpeechRecognitionConfig.defaultConfig;
  SpeechRecognitionConfig get config => _config;
  
  /// Current state
  SpeechRecognitionState _state = SpeechRecognitionState.idle;
  SpeechRecognitionState get state => _state;
  
  /// Whether currently listening
  bool get isListening => _state == SpeechRecognitionState.listening;
  
  /// Whether currently processing
  bool get isProcessing => _state == SpeechRecognitionState.processing;
  
  /// Transcribed text (final result)
  String _transcribedText = '';
  String get transcribedText => _transcribedText;
  
  /// Partial text (interim result)
  String _partialText = '';
  String get partialText => _partialText;
  
  /// Current confidence
  double _confidence = 0.0;
  double get confidence => _confidence;
  
  /// Words to sign (split from transcribed text)
  List<String> _wordsToSign = [];
  List<String> get wordsToSign => List.unmodifiable(_wordsToSign);
  
  /// Stream controller for recognition results
  final _resultController = StreamController<SpeechRecognitionResult>.broadcast();
  
  /// Stream of recognition results
  Stream<SpeechRecognitionResult> get resultStream => _resultController.stream;
  
  /// Recording start time
  DateTime? _recordingStartTime;
  
  /// Recording timer
  Timer? _recordingTimer;
  
  /// Statistics
  int _recognitionCount = 0;
  int _totalWords = 0;
  
  int get recognitionCount => _recognitionCount;
  int get totalWords => _totalWords;
  
  /// Initialize the service
  Future<void> initialize({SpeechRecognitionConfig? config}) async {
    if (_state == SpeechRecognitionState.initializing) {
      _logger.warning('Already initializing');
      return;
    }
    
    if (_state == SpeechRecognitionState.ready || _state == SpeechRecognitionState.listening) {
      _logger.info('Already initialized');
      return;
    }
    
    try {
      _setState(SpeechRecognitionState.initializing);
      _logger.info('Initializing speech recognition service...');
      
      // Update configuration
      if (config != null) {
        _config = config;
      }
      
      // Ensure Whisper model is loaded
      await CactusModelService.instance.ensureSpeechModelLoaded();
      
      _setState(SpeechRecognitionState.ready);
      _logger.info('Speech recognition service initialized successfully');
    } catch (e, stackTrace) {
      _logger.error('Failed to initialize speech recognition service', e, stackTrace);
      _setState(SpeechRecognitionState.error);
      AppErrorHandler.handleRecognitionError(e as Exception);
      rethrow;
    }
  }
  
  /// Start listening
  Future<void> startListening() async {
    if (_state != SpeechRecognitionState.ready) {
      throw StateError('Cannot start listening from state: $_state');
    }
    
    try {
      _logger.info('Starting speech recognition...');
      _setState(SpeechRecognitionState.listening);
      
      // Clear previous results
      _partialText = '';
      _transcribedText = '';
      _wordsToSign = [];
      _confidence = 0.0;
      
      // Record start time
      _recordingStartTime = DateTime.now();
      
      // Setup recording timer if max duration is set
      if (_config.maxDuration > 0) {
        _recordingTimer = Timer(
          Duration(seconds: _config.maxDuration),
          () {
            _logger.info('Max recording duration reached');
            stopListening();
          },
        );
      }
      
      // Start audio capture and transcription
      await _startTranscription();
      
      notifyListeners();
      _logger.info('Speech recognition started');
    } catch (e, stackTrace) {
      _logger.error('Failed to start listening', e, stackTrace);
      _setState(SpeechRecognitionState.ready);
      AppErrorHandler.handleRecognitionError(e as Exception);
      rethrow;
    }
  }
  
  /// Stop listening
  Future<void> stopListening() async {
    if (_state != SpeechRecognitionState.listening && 
        _state != SpeechRecognitionState.processing) {
      _logger.warning('Not currently listening');
      return;
    }
    
    try {
      _logger.info('Stopping speech recognition...');
      
      // Cancel recording timer
      _recordingTimer?.cancel();
      _recordingTimer = null;
      
      // Process final transcription if in listening state
      if (_state == SpeechRecognitionState.listening) {
        _setState(SpeechRecognitionState.processing);
        await _finalizeTranscription();
      }
      
      _setState(SpeechRecognitionState.ready);
      notifyListeners();
      _logger.info('Speech recognition stopped');
    } catch (e, stackTrace) {
      _logger.error('Error stopping listening', e, stackTrace);
      _setState(SpeechRecognitionState.ready);
    }
  }
  
  /// Start transcription using Whisper model
  Future<void> _startTranscription() async {
    try {
      final speechModel = CactusModelService.instance.speechModel;
      
      if (speechModel == null) {
        throw StateError('Speech model not available');
      }
      
      // TODO: Replace with actual Cactus SDK STT API
      // This is a placeholder implementation
      
      _logger.debug('Starting Whisper transcription...');
      
      // Simulate transcription process
      // In real implementation, this would:
      // 1. Start audio recording from microphone
      // 2. Stream audio to Whisper model
      // 3. Get partial results if enabled
      // 4. Return final transcription
      
      // For now, we'll simulate with a delay
      await Future.delayed(Duration(milliseconds: 100));
      
      // In continuous mode, keep listening
      if (_config.continuous) {
        _setupContinuousListening();
      }
    } catch (e, stackTrace) {
      _logger.error('Error starting transcription', e, stackTrace);
      rethrow;
    }
  }
  
  /// Setup continuous listening mode
  void _setupContinuousListening() {
    // TODO: Implement continuous listening with Cactus SDK
    // This would involve:
    // 1. Continuous audio capture
    // 2. Voice activity detection
    // 3. Automatic segmentation
    // 4. Real-time transcription
    
    _logger.debug('Continuous listening mode active');
  }
  
  /// Finalize transcription and get final result
  Future<void> _finalizeTranscription() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final speechModel = CactusModelService.instance.speechModel;
      
      if (speechModel == null) {
        throw StateError('Speech model not available');
      }
      
      _logger.debug('Finalizing transcription...');
      
      // TODO: Replace with actual Cactus SDK transcription
      // Placeholder implementation:
      final transcription = await speechModel.transcribe();
      
      if (transcription != null && transcription.text.isNotEmpty) {
        _transcribedText = transcription.text;
        _confidence = transcription.confidence ?? 0.0;
        
        // Split into words for sign animation
        _wordsToSign = _transcribedText
            .split(RegExp(r'\s+'))
            .where((word) => word.isNotEmpty)
            .toList();
        
        _totalWords += _wordsToSign.length;
        _recognitionCount++;
        
        stopwatch.stop();
        
        // Create result
        final result = SpeechRecognitionResult(
          text: _transcribedText,
          confidence: _confidence,
          isFinal: true,
          processingTime: stopwatch.elapsedMilliseconds,
          timestamp: DateTime.now(),
        );
        
        // Record performance
        _performanceMonitor.recordLatency(
          operation: 'speech_recognition',
          duration: stopwatch.elapsed,
          source: ProcessingSource.local,
        );
        
        // Emit result
        _resultController.add(result);
        
        _logger.info(
          'Transcription complete: "$_transcribedText" '
          '(${_wordsToSign.length} words, '
          'confidence: ${_confidence.toStringAsFixed(2)}, '
          '${stopwatch.elapsedMilliseconds}ms)'
        );
      } else {
        _logger.warning('No transcription result');
        _transcribedText = '';
        _wordsToSign = [];
        _confidence = 0.0;
      }
    } catch (e, stackTrace) {
      _logger.error('Error finalizing transcription', e, stackTrace);
      _transcribedText = '';
      _wordsToSign = [];
      _confidence = 0.0;
    }
  }
  
  /// Handle partial result (interim transcription)
  void _handlePartialResult(String text, double confidence) {
    if (!_config.partialResults) {
      return;
    }
    
    _partialText = text;
    _confidence = confidence;
    
    // Emit partial result
    final result = SpeechRecognitionResult(
      text: text,
      confidence: confidence,
      isFinal: false,
      processingTime: 0,
      timestamp: DateTime.now(),
    );
    
    _resultController.add(result);
    notifyListeners();
    
    _logger.debug('Partial result: "$text" (${confidence.toStringAsFixed(2)})');
  }
  
  /// Clear transcribed text
  void clearText() {
    _logger.info('Clearing transcribed text');
    _transcribedText = '';
    _partialText = '';
    _wordsToSign = [];
    _confidence = 0.0;
    notifyListeners();
  }
  
  /// Update configuration
  void updateConfig(SpeechRecognitionConfig newConfig) {
    _logger.info('Updating configuration');
    _config = newConfig;
    notifyListeners();
  }
  
  /// Get recording duration
  Duration? get recordingDuration {
    if (_recordingStartTime == null) {
      return null;
    }
    return DateTime.now().difference(_recordingStartTime!);
  }
  
  /// Get statistics
  Map<String, dynamic> getStatistics() {
    return {
      'state': _state.toString(),
      'recognitionCount': _recognitionCount,
      'totalWords': _totalWords,
      'transcribedText': _transcribedText,
      'wordsToSign': _wordsToSign.length,
      'confidence': _confidence,
      'recordingDuration': recordingDuration?.inSeconds,
      'config': {
        'language': _config.language,
        'continuous': _config.continuous,
        'maxDuration': _config.maxDuration,
        'partialResults': _config.partialResults,
        'minConfidence': _config.minConfidence,
      },
    };
  }
  
  /// Set state and notify listeners
  void _setState(SpeechRecognitionState newState) {
    if (_state != newState) {
      _logger.debug('State changed: $_state → $newState');
      _state = newState;
      notifyListeners();
    }
  }
  
  /// Dispose resources
  @override
  void dispose() {
    _logger.info('Disposing speech recognition service');
    
    stopListening();
    _recordingTimer?.cancel();
    _resultController.close();
    
    super.dispose();
  }
}

/// Placeholder for Whisper transcription result
class WhisperTranscription {
  final String text;
  final double? confidence;
  
  WhisperTranscription({
    required this.text,
    this.confidence,
  });
}