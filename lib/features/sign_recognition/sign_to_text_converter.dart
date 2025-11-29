/// Sign-to-Text Converter
/// 
/// Converts a stream of recognized sign gestures into stable text output.
/// Implements buffering and stability filtering to reduce noise and false positives.
/// 
/// Features:
/// - Temporal buffering: Holds multiple frames to ensure stability
/// - Confidence weighting: Prioritizes high-confidence detections
/// - Word assembly: Builds words from individual letters
/// - Context prediction: Optional word completion using language model

import 'dart:async';
import '../../core/models/sign_gesture.dart';
import '../../core/services/cactus_model_service.dart';
import '../../core/utils/logger.dart';

/// Configuration for sign-to-text conversion
class SignToTextConfig {
  /// Number of frames to buffer for stability
  final int bufferSize;
  
  /// Minimum number of matching frames required for stability
  final int stabilityThreshold;
  
  /// Minimum confidence required to accept a gesture
  final double minConfidence;
  
  /// Maximum time between letters before starting a new word (milliseconds)
  final int wordBreakTimeout;
  
  /// Enable word prediction using language model
  final bool enablePrediction;
  
  const SignToTextConfig({
    this.bufferSize = 5,
    this.stabilityThreshold = 4,
    this.minConfidence = 0.75,
    this.wordBreakTimeout = 2000,
    this.enablePrediction = false,
  });
  
  /// Default configuration
  static const SignToTextConfig defaultConfig = SignToTextConfig();
  
  /// Aggressive configuration (faster but less stable)
  static const SignToTextConfig aggressive = SignToTextConfig(
    bufferSize: 3,
    stabilityThreshold: 2,
    minConfidence: 0.65,
    wordBreakTimeout: 1500,
  );
  
  /// Conservative configuration (slower but more stable)
  static const SignToTextConfig conservative = SignToTextConfig(
    bufferSize: 7,
    stabilityThreshold: 6,
    minConfidence: 0.85,
    wordBreakTimeout: 3000,
  );
}

/// Result of text conversion
class TextConversionResult {
  /// Current letter being recognized (null if unstable)
  final String? currentLetter;
  
  /// Current word being built
  final String currentWord;
  
  /// List of completed words
  final List<String> completedWords;
  
  /// Full text (all completed words + current word)
  String get fullText {
    final words = [...completedWords];
    if (currentWord.isNotEmpty) {
      words.add(currentWord);
    }
    return words.join(' ');
  }
  
  /// Confidence of current letter
  final double confidence;
  
  /// Whether the current letter is stable
  final bool isStable;
  
  const TextConversionResult({
    required this.currentLetter,
    required this.currentWord,
    required this.completedWords,
    required this.confidence,
    required this.isStable,
  });
  
  /// Empty result
  static const TextConversionResult empty = TextConversionResult(
    currentLetter: null,
    currentWord: '',
    completedWords: [],
    confidence: 0.0,
    isStable: false,
  );
}

/// Converts sign gestures to text with stability filtering
class SignToTextConverter {
  final _logger = Logger('SignToTextConverter');
  
  /// Configuration
  final SignToTextConfig config;
  
  /// Buffer of recent gestures
  final List<SignGesture?> _buffer = [];
  
  /// Current word being built
  String _currentWord = '';
  
  /// List of completed words
  final List<String> _completedWords = [];
  
  /// Last letter that was added to the word
  String? _lastAddedLetter;
  
  /// Timestamp of last letter addition
  DateTime? _lastLetterTime;
  
  /// Timer for word break detection
  Timer? _wordBreakTimer;
  
  /// Stream controller for text updates
  final _textController = StreamController<TextConversionResult>.broadcast();
  
  /// Stream of text conversion results
  Stream<TextConversionResult> get textStream => _textController.stream;
  
  /// Current conversion result
  TextConversionResult _currentResult = TextConversionResult.empty;
  TextConversionResult get currentResult => _currentResult;
  
  SignToTextConverter({
    this.config = SignToTextConfig.defaultConfig,
  }) {
    _logger.info('Sign-to-text converter initialized with config: '
        'bufferSize=${config.bufferSize}, '
        'stabilityThreshold=${config.stabilityThreshold}, '
        'minConfidence=${config.minConfidence}');
  }
  
  /// Process a new gesture
  void processGesture(SignGesture? gesture) {
    // Add to buffer
    _buffer.add(gesture);
    
    // Maintain buffer size
    if (_buffer.length > config.bufferSize) {
      _buffer.removeAt(0);
    }
    
    // Check for stable letter
    final stableResult = _checkStability();
    
    if (stableResult != null) {
      _handleStableLetter(stableResult);
    }
    
    // Update current result
    _updateCurrentResult(stableResult);
    
    // Reset word break timer
    _resetWordBreakTimer();
  }
  
  /// Check if buffer contains a stable letter
  _StableLetterResult? _checkStability() {
    // Filter out null gestures and low confidence
    final validGestures = _buffer
        .where((g) => g != null && g.confidence >= config.minConfidence)
        .cast<SignGesture>()
        .toList();
    
    if (validGestures.isEmpty) {
      return null;
    }
    
    // Count occurrences of each letter
    final letterCounts = <String, int>{};
    final letterConfidences = <String, List<double>>{};
    
    for (final gesture in validGestures) {
      letterCounts[gesture.letter] = (letterCounts[gesture.letter] ?? 0) + 1;
      letterConfidences.putIfAbsent(gesture.letter, () => []).add(gesture.confidence);
    }
    
    // Find most common letter
    final entries = letterCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    if (entries.isEmpty) {
      return null;
    }
    
    final mostCommon = entries.first;
    
    // Check if it meets stability threshold
    if (mostCommon.value >= config.stabilityThreshold) {
      // Calculate average confidence
      final confidences = letterConfidences[mostCommon.key]!;
      final avgConfidence = confidences.reduce((a, b) => a + b) / confidences.length;
      
      return _StableLetterResult(
        letter: mostCommon.key,
        confidence: avgConfidence,
        count: mostCommon.value,
      );
    }
    
    return null;
  }
  
  /// Handle a stable letter detection
  void _handleStableLetter(_StableLetterResult result) {
    final letter = result.letter;
    
    // Check if this is a new letter (not the same as last added)
    if (letter != _lastAddedLetter) {
      _logger.debug(
        'Stable letter detected: $letter '
        '(confidence: ${result.confidence.toStringAsFixed(2)}, '
        'count: ${result.count}/${config.bufferSize})'
      );
      
      // Add letter to current word
      _currentWord += letter;
      _lastAddedLetter = letter;
      _lastLetterTime = DateTime.now();
      
      _logger.info('Current word: $_currentWord');
      
      // Optional: Predict next letter
      if (config.enablePrediction && _currentWord.length >= 2) {
        _predictNextLetter();
      }
    }
  }
  
  /// Update current result and notify listeners
  void _updateCurrentResult(_StableLetterResult? stableResult) {
    _currentResult = TextConversionResult(
      currentLetter: stableResult?.letter,
      currentWord: _currentWord,
      completedWords: List.unmodifiable(_completedWords),
      confidence: stableResult?.confidence ?? 0.0,
      isStable: stableResult != null,
    );
    
    _textController.add(_currentResult);
  }
  
  /// Reset word break timer
  void _resetWordBreakTimer() {
    _wordBreakTimer?.cancel();
    
    if (_currentWord.isNotEmpty) {
      _wordBreakTimer = Timer(
        Duration(milliseconds: config.wordBreakTimeout),
        _handleWordBreak,
      );
    }
  }
  
  /// Handle word break (timeout without new letters)
  void _handleWordBreak() {
    if (_currentWord.isNotEmpty) {
      _logger.info('Word break detected. Completing word: $_currentWord');
      
      // Move current word to completed words
      _completedWords.add(_currentWord);
      _currentWord = '';
      _lastAddedLetter = null;
      _lastLetterTime = null;
      
      // Update result
      _updateCurrentResult(null);
    }
  }
  
  /// Manually complete the current word
  void completeWord() {
    _wordBreakTimer?.cancel();
    _handleWordBreak();
  }
  
  /// Predict next letter using language model
  Future<void> _predictNextLetter() async {
    if (!config.enablePrediction) return;
    
    try {
      final textModel = CactusModelService.instance.textModel;
      
      if (textModel == null) {
        return;
      }
      
      // Use Qwen3 to predict likely next letters
      final prompt = '''
Given the partial word "$_currentWord", what are the 3 most likely next letters?
Consider common English words.
Respond with only the 3 letters, no explanation.
Example: If word is "HE", respond with "L,A,R" (for HELLO, HEART, HEAR)
''';
      
      final response = await textModel.generateCompletion(
        messages: [
          ChatMessage(
            content: prompt,
            role: 'user',
          ),
        ],
      );
      
      _logger.debug('Predicted next letters for "$_currentWord": ${response.response}');
      
      // TODO: Use predictions to show suggestions in UI
    } catch (e, stackTrace) {
      _logger.error('Error predicting next letter', e, stackTrace);
    }
  }
  
  /// Delete last letter from current word
  void deleteLastLetter() {
    if (_currentWord.isNotEmpty) {
      _currentWord = _currentWord.substring(0, _currentWord.length - 1);
      _lastAddedLetter = _currentWord.isNotEmpty ? _currentWord[_currentWord.length - 1] : null;
      
      _logger.info('Deleted last letter. Current word: $_currentWord');
      
      // Update result
      _updateCurrentResult(null);
      
      // Reset timer
      _resetWordBreakTimer();
    }
  }
  
  /// Delete last completed word
  void deleteLastWord() {
    if (_completedWords.isNotEmpty) {
      final deleted = _completedWords.removeLast();
      _logger.info('Deleted last word: $deleted');
      
      // Update result
      _updateCurrentResult(null);
    }
  }
  
  /// Clear all text
  void clear() {
    _logger.info('Clearing all text');
    
    _buffer.clear();
    _currentWord = '';
    _completedWords.clear();
    _lastAddedLetter = null;
    _lastLetterTime = null;
    _wordBreakTimer?.cancel();
    
    _updateCurrentResult(null);
  }
  
  /// Get statistics about conversion
  Map<String, dynamic> getStatistics() {
    return {
      'bufferSize': _buffer.length,
      'currentWord': _currentWord,
      'currentWordLength': _currentWord.length,
      'completedWords': _completedWords.length,
      'totalCharacters': _completedWords.join('').length + _currentWord.length,
      'lastLetterTime': _lastLetterTime?.toIso8601String(),
      'timeSinceLastLetter': _lastLetterTime != null
          ? DateTime.now().difference(_lastLetterTime!).inMilliseconds
          : null,
    };
  }
  
  /// Dispose resources
  void dispose() {
    _logger.info('Disposing sign-to-text converter');
    _wordBreakTimer?.cancel();
    _textController.close();
  }
}

/// Internal class for stable letter results
class _StableLetterResult {
  final String letter;
  final double confidence;
  final int count;
  
  const _StableLetterResult({
    required this.letter,
    required this.confidence,
    required this.count,
  });
}