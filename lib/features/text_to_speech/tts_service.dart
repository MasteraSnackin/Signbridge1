/// Text-to-Speech Service
/// 
/// Provides text-to-speech functionality for speaking recognized sign language.
/// Uses flutter_tts package for cross-platform TTS support.
/// 
/// Features:
/// - Configurable speech rate, volume, and pitch
/// - Multiple language support
/// - Queue management for multiple utterances
/// - Pause/resume/stop controls
/// - Event callbacks for speech progress

import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import '../../core/utils/logger.dart';
import '../../core/services/storage_service.dart';

/// TTS configuration
class TTSConfig {
  /// Speech rate (0.0 - 1.0, default 0.5)
  final double speechRate;
  
  /// Volume (0.0 - 1.0, default 1.0)
  final double volume;
  
  /// Pitch (0.5 - 2.0, default 1.0)
  final double pitch;
  
  /// Language code (e.g., 'en-US')
  final String language;
  
  /// Whether to queue utterances or interrupt
  final bool queueMode;
  
  const TTSConfig({
    this.speechRate = 0.5,
    this.volume = 1.0,
    this.pitch = 1.0,
    this.language = 'en-US',
    this.queueMode = false,
  });
  
  /// Default configuration
  static const TTSConfig defaultConfig = TTSConfig();
  
  /// Slow and clear (for learning)
  static const TTSConfig slow = TTSConfig(
    speechRate: 0.3,
    volume: 1.0,
    pitch: 1.0,
  );
  
  /// Fast (for experienced users)
  static const TTSConfig fast = TTSConfig(
    speechRate: 0.7,
    volume: 1.0,
    pitch: 1.0,
  );
}

/// TTS state
enum TTSState {
  idle,
  speaking,
  paused,
  stopped,
}

/// TTS event
class TTSEvent {
  final TTSEventType type;
  final String? text;
  final int? start;
  final int? end;
  final String? word;
  
  const TTSEvent({
    required this.type,
    this.text,
    this.start,
    this.end,
    this.word,
  });
}

/// TTS event types
enum TTSEventType {
  start,
  complete,
  error,
  pause,
  resume,
  cancel,
  progress,
}

/// Text-to-Speech service
class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();
  
  final _logger = Logger('TTSService');
  final _tts = FlutterTts();
  
  /// Current configuration
  TTSConfig _config = TTSConfig.defaultConfig;
  TTSConfig get config => _config;
  
  /// Current state
  TTSState _state = TTSState.idle;
  TTSState get state => _state;
  
  /// Whether TTS is initialized
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  
  /// Whether TTS is currently speaking
  bool get isSpeaking => _state == TTSState.speaking;
  
  /// Whether TTS is paused
  bool get isPaused => _state == TTSState.paused;
  
  /// Stream controller for TTS events
  final _eventController = StreamController<TTSEvent>.broadcast();
  
  /// Stream of TTS events
  Stream<TTSEvent> get eventStream => _eventController.stream;
  
  /// Queue of pending utterances
  final List<String> _queue = [];
  
  /// Current utterance being spoken
  String? _currentUtterance;
  
  /// Initialize TTS service
  Future<void> initialize({TTSConfig? config}) async {
    if (_isInitialized) {
      _logger.info('TTS service already initialized');
      return;
    }
    
    try {
      _logger.info('Initializing TTS service...');
      
      // Load saved configuration
      if (config == null) {
        final savedRate = await StorageService.instance.getTTSSpeechRate();
        final savedVolume = await StorageService.instance.getTTSVolume();
        final savedPitch = await StorageService.instance.getTTSPitch();
        
        _config = TTSConfig(
          speechRate: savedRate,
          volume: savedVolume,
          pitch: savedPitch,
        );
      } else {
        _config = config;
      }
      
      // Configure TTS
      await _configureTTS();
      
      // Setup event handlers
      _setupEventHandlers();
      
      _isInitialized = true;
      _logger.info('TTS service initialized successfully');
    } catch (e, stackTrace) {
      _logger.error('Failed to initialize TTS service', e, stackTrace);
      rethrow;
    }
  }
  
  /// Configure TTS with current settings
  Future<void> _configureTTS() async {
    await _tts.setLanguage(_config.language);
    await _tts.setSpeechRate(_config.speechRate);
    await _tts.setVolume(_config.volume);
    await _tts.setPitch(_config.pitch);
    
    // Set iOS-specific settings
    await _tts.setSharedInstance(true);
    await _tts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      [
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        IosTextToSpeechAudioCategoryOptions.mixWithOthers,
      ],
      IosTextToSpeechAudioMode.voicePrompt,
    );
    
    _logger.debug(
      'TTS configured: rate=${_config.speechRate}, '
      'volume=${_config.volume}, pitch=${_config.pitch}'
    );
  }
  
  /// Setup event handlers
  void _setupEventHandlers() {
    _tts.setStartHandler(() {
      _logger.debug('TTS started: $_currentUtterance');
      _state = TTSState.speaking;
      _eventController.add(TTSEvent(
        type: TTSEventType.start,
        text: _currentUtterance,
      ));
    });
    
    _tts.setCompletionHandler(() {
      _logger.debug('TTS completed: $_currentUtterance');
      _state = TTSState.idle;
      _eventController.add(TTSEvent(
        type: TTSEventType.complete,
        text: _currentUtterance,
      ));
      
      _currentUtterance = null;
      
      // Process next in queue
      if (_queue.isNotEmpty) {
        final next = _queue.removeAt(0);
        speak(next);
      }
    });
    
    _tts.setErrorHandler((msg) {
      _logger.error('TTS error: $msg');
      _state = TTSState.idle;
      _eventController.add(TTSEvent(
        type: TTSEventType.error,
        text: msg,
      ));
      
      _currentUtterance = null;
    });
    
    _tts.setPauseHandler(() {
      _logger.debug('TTS paused');
      _state = TTSState.paused;
      _eventController.add(TTSEvent(type: TTSEventType.pause));
    });
    
    _tts.setContinueHandler(() {
      _logger.debug('TTS resumed');
      _state = TTSState.speaking;
      _eventController.add(TTSEvent(type: TTSEventType.resume));
    });
    
    _tts.setCancelHandler(() {
      _logger.debug('TTS cancelled');
      _state = TTSState.stopped;
      _eventController.add(TTSEvent(type: TTSEventType.cancel));
      
      _currentUtterance = null;
      _queue.clear();
    });
    
    // Progress handler (word-by-word)
    _tts.setProgressHandler((text, start, end, word) {
      _eventController.add(TTSEvent(
        type: TTSEventType.progress,
        text: text,
        start: start,
        end: end,
        word: word,
      ));
    });
  }
  
  /// Speak text
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      throw StateError('TTS service not initialized. Call initialize() first.');
    }
    
    if (text.isEmpty) {
      _logger.warning('Attempted to speak empty text');
      return;
    }
    
    _logger.info('Speaking: "$text"');
    
    // If already speaking and queue mode is enabled, add to queue
    if (_state == TTSState.speaking && _config.queueMode) {
      _logger.debug('Adding to queue: "$text"');
      _queue.add(text);
      return;
    }
    
    // Stop current speech if not in queue mode
    if (_state == TTSState.speaking && !_config.queueMode) {
      await stop();
    }
    
    _currentUtterance = text;
    await _tts.speak(text);
  }
  
  /// Speak a single letter
  Future<void> speakLetter(String letter) async {
    if (letter.length != 1) {
      _logger.warning('speakLetter expects single character, got: "$letter"');
      return;
    }
    
    await speak(letter);
  }
  
  /// Speak a word
  Future<void> speakWord(String word) async {
    await speak(word);
  }
  
  /// Speak a sentence
  Future<void> speakSentence(String sentence) async {
    await speak(sentence);
  }
  
  /// Pause speech
  Future<void> pause() async {
    if (_state != TTSState.speaking) {
      _logger.warning('Cannot pause: not currently speaking');
      return;
    }
    
    _logger.info('Pausing speech');
    await _tts.pause();
  }
  
  /// Resume speech
  Future<void> resume() async {
    if (_state != TTSState.paused) {
      _logger.warning('Cannot resume: not currently paused');
      return;
    }
    
    _logger.info('Resuming speech');
    // Note: flutter_tts doesn't have a resume method, need to re-speak
    if (_currentUtterance != null) {
      await _tts.speak(_currentUtterance!);
    }
  }
  
  /// Stop speech
  Future<void> stop() async {
    if (_state == TTSState.idle) {
      return;
    }
    
    _logger.info('Stopping speech');
    await _tts.stop();
    _state = TTSState.stopped;
    _currentUtterance = null;
    _queue.clear();
  }
  
  /// Update configuration
  Future<void> updateConfig(TTSConfig newConfig) async {
    _logger.info('Updating TTS configuration');
    
    _config = newConfig;
    await _configureTTS();
    
    // Save to storage
    await StorageService.instance.setTTSSpeechRate(newConfig.speechRate);
    await StorageService.instance.setTTSVolume(newConfig.volume);
    await StorageService.instance.setTTSPitch(newConfig.pitch);
  }
  
  /// Set speech rate
  Future<void> setSpeechRate(double rate) async {
    if (rate < 0.0 || rate > 1.0) {
      throw ArgumentError('Speech rate must be between 0.0 and 1.0');
    }
    
    await updateConfig(TTSConfig(
      speechRate: rate,
      volume: _config.volume,
      pitch: _config.pitch,
      language: _config.language,
      queueMode: _config.queueMode,
    ));
  }
  
  /// Set volume
  Future<void> setVolume(double volume) async {
    if (volume < 0.0 || volume > 1.0) {
      throw ArgumentError('Volume must be between 0.0 and 1.0');
    }
    
    await updateConfig(TTSConfig(
      speechRate: _config.speechRate,
      volume: volume,
      pitch: _config.pitch,
      language: _config.language,
      queueMode: _config.queueMode,
    ));
  }
  
  /// Set pitch
  Future<void> setPitch(double pitch) async {
    if (pitch < 0.5 || pitch > 2.0) {
      throw ArgumentError('Pitch must be between 0.5 and 2.0');
    }
    
    await updateConfig(TTSConfig(
      speechRate: _config.speechRate,
      volume: _config.volume,
      pitch: pitch,
      language: _config.language,
      queueMode: _config.queueMode,
    ));
  }
  
  /// Get available languages
  Future<List<String>> getAvailableLanguages() async {
    try {
      final languages = await _tts.getLanguages;
      return List<String>.from(languages);
    } catch (e, stackTrace) {
      _logger.error('Error getting available languages', e, stackTrace);
      return [];
    }
  }
  
  /// Get available voices
  Future<List<Map<String, String>>> getAvailableVoices() async {
    try {
      final voices = await _tts.getVoices;
      return List<Map<String, String>>.from(voices);
    } catch (e, stackTrace) {
      _logger.error('Error getting available voices', e, stackTrace);
      return [];
    }
  }
  
  /// Set voice
  Future<void> setVoice(Map<String, String> voice) async {
    try {
      await _tts.setVoice(voice);
      _logger.info('Voice set to: ${voice['name']}');
    } catch (e, stackTrace) {
      _logger.error('Error setting voice', e, stackTrace);
    }
  }
  
  /// Get queue size
  int get queueSize => _queue.length;
  
  /// Clear queue
  void clearQueue() {
    _logger.info('Clearing TTS queue (${_queue.length} items)');
    _queue.clear();
  }
  
  /// Get statistics
  Map<String, dynamic> getStatistics() {
    return {
      'state': _state.toString(),
      'isInitialized': _isInitialized,
      'isSpeaking': isSpeaking,
      'isPaused': isPaused,
      'queueSize': _queue.length,
      'currentUtterance': _currentUtterance,
      'config': {
        'speechRate': _config.speechRate,
        'volume': _config.volume,
        'pitch': _config.pitch,
        'language': _config.language,
        'queueMode': _config.queueMode,
      },
    };
  }
  
  /// Dispose resources
  void dispose() {
    _logger.info('Disposing TTS service');
    stop();
    _eventController.close();
    _isInitialized = false;
  }
}