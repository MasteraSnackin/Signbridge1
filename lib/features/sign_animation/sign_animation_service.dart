/// Sign Animation Service
/// 
/// Manages and plays sign language animations for speech-to-sign translation.
/// Coordinates animation playback, timing, and sequencing.
/// 
/// Features:
/// - Word-level sign animations
/// - Letter-level fingerspelling fallback
/// - Animation queue management
/// - Playback controls (play, pause, stop, skip)
/// - Speed adjustment
/// - Loop support

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/models/sign_animation.dart';
import '../../data/repositories/sign_dictionary_repository.dart';
import '../../core/utils/logger.dart';

/// Animation playback configuration
class AnimationConfig {
  /// Playback speed multiplier (0.5 = half speed, 2.0 = double speed)
  final double speed;
  
  /// Whether to loop animations
  final bool loop;
  
  /// Delay between animations in milliseconds
  final int delayBetweenAnimations;
  
  /// Whether to auto-play next animation in queue
  final bool autoPlay;
  
  const AnimationConfig({
    this.speed = 1.0,
    this.loop = false,
    this.delayBetweenAnimations = 500,
    this.autoPlay = true,
  });
  
  /// Default configuration
  static const AnimationConfig defaultConfig = AnimationConfig();
  
  /// Slow mode (for learning)
  static const AnimationConfig slow = AnimationConfig(
    speed: 0.5,
    delayBetweenAnimations: 1000,
  );
  
  /// Fast mode (for experienced users)
  static const AnimationConfig fast = AnimationConfig(
    speed: 1.5,
    delayBetweenAnimations: 300,
  );
}

/// Animation playback state
enum AnimationState {
  idle,
  playing,
  paused,
  stopped,
}

/// Animation playback event
class AnimationEvent {
  final AnimationEventType type;
  final SignAnimation? animation;
  final int? queuePosition;
  final int? queueSize;
  
  const AnimationEvent({
    required this.type,
    this.animation,
    this.queuePosition,
    this.queueSize,
  });
}

/// Animation event types
enum AnimationEventType {
  started,
  completed,
  paused,
  resumed,
  stopped,
  queueUpdated,
  error,
}

/// Sign animation service
class SignAnimationService extends ChangeNotifier {
  final _logger = Logger('SignAnimationService');
  final _repository = SignDictionaryRepository();
  
  /// Configuration
  AnimationConfig _config = AnimationConfig.defaultConfig;
  AnimationConfig get config => _config;
  
  /// Current state
  AnimationState _state = AnimationState.idle;
  AnimationState get state => _state;
  
  /// Whether currently playing
  bool get isPlaying => _state == AnimationState.playing;
  
  /// Whether paused
  bool get isPaused => _state == AnimationState.paused;
  
  /// Current animation being played
  SignAnimation? _currentAnimation;
  SignAnimation? get currentAnimation => _currentAnimation;
  
  /// Animation queue
  final List<SignAnimation> _queue = [];
  List<SignAnimation> get queue => List.unmodifiable(_queue);
  
  /// Current position in queue
  int _currentPosition = 0;
  int get currentPosition => _currentPosition;
  
  /// Total animations played
  int _animationsPlayed = 0;
  int get animationsPlayed => _animationsPlayed;
  
  /// Stream controller for animation events
  final _eventController = StreamController<AnimationEvent>.broadcast();
  
  /// Stream of animation events
  Stream<AnimationEvent> get eventStream => _eventController.stream;
  
  /// Animation timer
  Timer? _animationTimer;
  
  /// Playback start time
  DateTime? _playbackStartTime;
  
  /// Initialize the service
  void initialize({AnimationConfig? config}) {
    _logger.info('Initializing sign animation service...');
    
    if (config != null) {
      _config = config;
    }
    
    _logger.info('Sign animation service initialized');
  }
  
  /// Display signs for text
  Future<void> displaySignsForText(String text) async {
    if (text.isEmpty) {
      _logger.warning('Cannot display signs for empty text');
      return;
    }
    
    _logger.info('Displaying signs for text: "$text"');
    
    try {
      // Get animations for the text
      final animations = _repository.getAnimationsForSentence(text);
      
      if (animations.isEmpty) {
        _logger.warning('No animations found for text: "$text"');
        return;
      }
      
      _logger.info('Found ${animations.length} animations for text');
      
      // Add to queue
      addToQueue(animations);
      
      // Start playing if auto-play is enabled
      if (_config.autoPlay && _state == AnimationState.idle) {
        await play();
      }
    } catch (e, stackTrace) {
      _logger.error('Error displaying signs for text', e, stackTrace);
      _emitEvent(AnimationEvent(type: AnimationEventType.error));
    }
  }
  
  /// Display sign for a single word
  Future<void> displaySignForWord(String word) async {
    if (word.isEmpty) {
      _logger.warning('Cannot display sign for empty word');
      return;
    }
    
    _logger.info('Displaying sign for word: "$word"');
    
    try {
      // Try to get word-level sign
      final wordSign = _repository.getWordSign(word);
      
      if (wordSign != null) {
        await playAnimation(wordSign);
      } else {
        // Fallback to fingerspelling
        _logger.debug('No word sign found, fingerspelling: "$word"');
        final letterSigns = _repository.fingerspellWord(word);
        addToQueue(letterSigns);
        
        if (_config.autoPlay && _state == AnimationState.idle) {
          await play();
        }
      }
    } catch (e, stackTrace) {
      _logger.error('Error displaying sign for word', e, stackTrace);
      _emitEvent(AnimationEvent(type: AnimationEventType.error));
    }
  }
  
  /// Play a single animation immediately
  Future<void> playAnimation(SignAnimation animation) async {
    _logger.info('Playing animation: ${animation.label}');
    
    try {
      _currentAnimation = animation;
      _setState(AnimationState.playing);
      _playbackStartTime = DateTime.now();
      
      // Emit started event
      _emitEvent(AnimationEvent(
        type: AnimationEventType.started,
        animation: animation,
      ));
      
      // Calculate duration based on animation type and speed
      final baseDuration = _getAnimationDuration(animation);
      final adjustedDuration = (baseDuration / _config.speed).round();
      
      _logger.debug(
        'Animation duration: ${adjustedDuration}ms '
        '(base: ${baseDuration}ms, speed: ${_config.speed}x)'
      );
      
      // Wait for animation to complete
      await Future.delayed(Duration(milliseconds: adjustedDuration));
      
      // Check if still playing (not stopped/paused)
      if (_state == AnimationState.playing) {
        _animationsPlayed++;
        
        // Emit completed event
        _emitEvent(AnimationEvent(
          type: AnimationEventType.completed,
          animation: animation,
        ));
        
        _currentAnimation = null;
        _setState(AnimationState.idle);
        
        _logger.info('Animation completed: ${animation.label}');
      }
    } catch (e, stackTrace) {
      _logger.error('Error playing animation', e, stackTrace);
      _setState(AnimationState.idle);
      _emitEvent(AnimationEvent(type: AnimationEventType.error));
    }
  }
  
  /// Get animation duration based on type
  int _getAnimationDuration(SignAnimation animation) {
    switch (animation.type) {
      case SignAnimationType.word:
        return 1500; // 1.5 seconds for word signs
      case SignAnimationType.letter:
        return 800; // 0.8 seconds for letters
      case SignAnimationType.phrase:
        return 2000; // 2 seconds for phrases
    }
  }
  
  /// Add animations to queue
  void addToQueue(List<SignAnimation> animations) {
    _logger.info('Adding ${animations.length} animations to queue');
    _queue.addAll(animations);
    
    _emitEvent(AnimationEvent(
      type: AnimationEventType.queueUpdated,
      queueSize: _queue.length,
    ));
    
    notifyListeners();
  }
  
  /// Play animations from queue
  Future<void> play() async {
    if (_queue.isEmpty) {
      _logger.warning('Cannot play: queue is empty');
      return;
    }
    
    if (_state == AnimationState.playing) {
      _logger.warning('Already playing');
      return;
    }
    
    if (_state == AnimationState.paused) {
      await resume();
      return;
    }
    
    _logger.info('Starting playback (${_queue.length} animations in queue)');
    _setState(AnimationState.playing);
    _currentPosition = 0;
    
    await _playQueue();
  }
  
  /// Play queue sequentially
  Future<void> _playQueue() async {
    while (_currentPosition < _queue.length && _state == AnimationState.playing) {
      final animation = _queue[_currentPosition];
      
      _logger.debug(
        'Playing animation ${_currentPosition + 1}/${_queue.length}: '
        '${animation.label}'
      );
      
      // Play animation
      await playAnimation(animation);
      
      // Check if still playing (not stopped/paused)
      if (_state != AnimationState.playing) {
        break;
      }
      
      // Delay between animations
      if (_currentPosition < _queue.length - 1) {
        await Future.delayed(Duration(milliseconds: _config.delayBetweenAnimations));
      }
      
      _currentPosition++;
      
      _emitEvent(AnimationEvent(
        type: AnimationEventType.queueUpdated,
        queuePosition: _currentPosition,
        queueSize: _queue.length,
      ));
    }
    
    // Queue completed
    if (_currentPosition >= _queue.length) {
      _logger.info('Queue playback completed');
      
      if (_config.loop) {
        _logger.debug('Looping queue');
        _currentPosition = 0;
        await _playQueue();
      } else {
        _queue.clear();
        _currentPosition = 0;
        _setState(AnimationState.idle);
        
        _emitEvent(AnimationEvent(
          type: AnimationEventType.queueUpdated,
          queueSize: 0,
        ));
      }
    }
  }
  
  /// Pause playback
  void pause() {
    if (_state != AnimationState.playing) {
      _logger.warning('Cannot pause: not currently playing');
      return;
    }
    
    _logger.info('Pausing playback');
    _setState(AnimationState.paused);
    
    _emitEvent(AnimationEvent(type: AnimationEventType.paused));
  }
  
  /// Resume playback
  Future<void> resume() async {
    if (_state != AnimationState.paused) {
      _logger.warning('Cannot resume: not currently paused');
      return;
    }
    
    _logger.info('Resuming playback');
    _setState(AnimationState.playing);
    
    _emitEvent(AnimationEvent(type: AnimationEventType.resumed));
    
    await _playQueue();
  }
  
  /// Stop playback
  void stop() {
    if (_state == AnimationState.idle) {
      return;
    }
    
    _logger.info('Stopping playback');
    
    _animationTimer?.cancel();
    _animationTimer = null;
    
    _currentAnimation = null;
    _setState(AnimationState.idle);
    
    _emitEvent(AnimationEvent(type: AnimationEventType.stopped));
  }
  
  /// Skip to next animation
  Future<void> skipNext() async {
    if (_queue.isEmpty) {
      _logger.warning('Cannot skip: queue is empty');
      return;
    }
    
    _logger.info('Skipping to next animation');
    
    // Stop current animation
    _currentAnimation = null;
    
    // Move to next position
    if (_currentPosition < _queue.length - 1) {
      _currentPosition++;
      
      if (_state == AnimationState.playing) {
        await _playQueue();
      }
    } else {
      _logger.debug('Already at last animation');
      stop();
    }
  }
  
  /// Skip to previous animation
  Future<void> skipPrevious() async {
    if (_queue.isEmpty) {
      _logger.warning('Cannot skip: queue is empty');
      return;
    }
    
    _logger.info('Skipping to previous animation');
    
    // Stop current animation
    _currentAnimation = null;
    
    // Move to previous position
    if (_currentPosition > 0) {
      _currentPosition--;
      
      if (_state == AnimationState.playing) {
        await _playQueue();
      }
    } else {
      _logger.debug('Already at first animation');
    }
  }
  
  /// Clear queue
  void clearQueue() {
    _logger.info('Clearing animation queue (${_queue.length} items)');
    
    stop();
    _queue.clear();
    _currentPosition = 0;
    
    _emitEvent(AnimationEvent(
      type: AnimationEventType.queueUpdated,
      queueSize: 0,
    ));
    
    notifyListeners();
  }
  
  /// Update configuration
  void updateConfig(AnimationConfig newConfig) {
    _logger.info('Updating animation configuration');
    _config = newConfig;
    notifyListeners();
  }
  
  /// Set playback speed
  void setSpeed(double speed) {
    if (speed <= 0.0 || speed > 3.0) {
      throw ArgumentError('Speed must be between 0.0 and 3.0');
    }
    
    updateConfig(AnimationConfig(
      speed: speed,
      loop: _config.loop,
      delayBetweenAnimations: _config.delayBetweenAnimations,
      autoPlay: _config.autoPlay,
    ));
  }
  
  /// Get statistics
  Map<String, dynamic> getStatistics() {
    return {
      'state': _state.toString(),
      'queueSize': _queue.length,
      'currentPosition': _currentPosition,
      'animationsPlayed': _animationsPlayed,
      'currentAnimation': _currentAnimation?.label,
      'playbackDuration': _playbackStartTime != null
          ? DateTime.now().difference(_playbackStartTime!).inSeconds
          : null,
      'config': {
        'speed': _config.speed,
        'loop': _config.loop,
        'delayBetweenAnimations': _config.delayBetweenAnimations,
        'autoPlay': _config.autoPlay,
      },
    };
  }
  
  /// Emit animation event
  void _emitEvent(AnimationEvent event) {
    _eventController.add(event);
  }
  
  /// Set state and notify listeners
  void _setState(AnimationState newState) {
    if (_state != newState) {
      _logger.debug('State changed: $_state → $newState');
      _state = newState;
      notifyListeners();
    }
  }
  
  /// Dispose resources
  @override
  void dispose() {
    _logger.info('Disposing sign animation service');
    
    stop();
    _animationTimer?.cancel();
    _eventController.close();
    
    super.dispose();
  }
}