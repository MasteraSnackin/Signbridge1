/// Confidence Scorer
/// 
/// Analyzes gesture recognition results and provides confidence scores
/// to help the hybrid router make intelligent routing decisions.
/// 
/// Scoring Factors:
/// - Raw classifier confidence
/// - Temporal consistency (stability over frames)
/// - Landmark quality (completeness, visibility)
/// - Historical accuracy for similar gestures
/// - Context-based adjustments

import 'dart:math';
import '../../core/models/hand_landmarks.dart';
import '../../core/models/sign_gesture.dart';
import '../../core/utils/logger.dart';

/// Confidence scoring configuration
class ConfidenceScoringConfig {
  /// Weight for raw classifier confidence (0.0-1.0)
  final double classifierWeight;
  
  /// Weight for temporal consistency (0.0-1.0)
  final double temporalWeight;
  
  /// Weight for landmark quality (0.0-1.0)
  final double landmarkWeight;
  
  /// Weight for historical accuracy (0.0-1.0)
  final double historicalWeight;
  
  /// Minimum number of frames for temporal analysis
  final int minFramesForTemporal;
  
  const ConfidenceScoringConfig({
    this.classifierWeight = 0.5,
    this.temporalWeight = 0.2,
    this.landmarkWeight = 0.2,
    this.historicalWeight = 0.1,
    this.minFramesForTemporal = 3,
  });
  
  /// Default configuration
  static const ConfidenceScoringConfig defaultConfig = ConfidenceScoringConfig();
  
  /// Validate weights sum to 1.0
  bool get isValid {
    final sum = classifierWeight + temporalWeight + landmarkWeight + historicalWeight;
    return (sum - 1.0).abs() < 0.01;
  }
}

/// Confidence score breakdown
class ConfidenceScore {
  /// Overall confidence (0.0-1.0)
  final double overall;
  
  /// Classifier confidence component
  final double classifier;
  
  /// Temporal consistency component
  final double temporal;
  
  /// Landmark quality component
  final double landmark;
  
  /// Historical accuracy component
  final double historical;
  
  /// Recommendation
  final ConfidenceRecommendation recommendation;
  
  const ConfidenceScore({
    required this.overall,
    required this.classifier,
    required this.temporal,
    required this.landmark,
    required this.historical,
    required this.recommendation,
  });
  
  /// Create from components
  factory ConfidenceScore.fromComponents({
    required double classifier,
    required double temporal,
    required double landmark,
    required double historical,
    required ConfidenceScoringConfig config,
  }) {
    final overall = (classifier * config.classifierWeight) +
        (temporal * config.temporalWeight) +
        (landmark * config.landmarkWeight) +
        (historical * config.historicalWeight);
    
    final recommendation = _getRecommendation(overall);
    
    return ConfidenceScore(
      overall: overall,
      classifier: classifier,
      temporal: temporal,
      landmark: landmark,
      historical: historical,
      recommendation: recommendation,
    );
  }
  
  /// Get recommendation based on overall score
  static ConfidenceRecommendation _getRecommendation(double score) {
    if (score >= 0.85) {
      return ConfidenceRecommendation.veryHigh;
    } else if (score >= 0.75) {
      return ConfidenceRecommendation.high;
    } else if (score >= 0.60) {
      return ConfidenceRecommendation.medium;
    } else if (score >= 0.45) {
      return ConfidenceRecommendation.low;
    } else {
      return ConfidenceRecommendation.veryLow;
    }
  }
  
  Map<String, dynamic> toJson() {
    return {
      'overall': overall,
      'classifier': classifier,
      'temporal': temporal,
      'landmark': landmark,
      'historical': historical,
      'recommendation': recommendation.toString(),
    };
  }
}

/// Confidence recommendation
enum ConfidenceRecommendation {
  veryHigh,  // ≥0.85: Definitely use local
  high,      // ≥0.75: Use local
  medium,    // ≥0.60: Consider cloud if available
  low,       // ≥0.45: Prefer cloud if available
  veryLow,   // <0.45: Strongly prefer cloud
}

/// Historical gesture data
class _GestureHistory {
  final String letter;
  int totalAttempts = 0;
  int successfulAttempts = 0;
  
  double get accuracy => totalAttempts > 0 
      ? successfulAttempts / totalAttempts 
      : 0.5; // Default to neutral
  
  _GestureHistory(this.letter);
  
  void recordAttempt(bool success) {
    totalAttempts++;
    if (success) {
      successfulAttempts++;
    }
  }
}

/// Confidence scorer
class ConfidenceScorer {
  final _logger = Logger('ConfidenceScorer');
  
  /// Configuration
  ConfidenceScoringConfig _config = ConfidenceScoringConfig.defaultConfig;
  ConfidenceScoringConfig get config => _config;
  
  /// Recent gesture buffer for temporal analysis
  final List<SignGesture> _recentGestures = [];
  final int _maxBufferSize = 10;
  
  /// Historical accuracy data
  final Map<String, _GestureHistory> _history = {};
  
  /// Calculate confidence score
  ConfidenceScore calculateScore(
    SignGesture gesture,
    HandLandmarks landmarks,
  ) {
    try {
      // Add to recent gestures buffer
      _addToBuffer(gesture);
      
      // Calculate individual components
      final classifierScore = _scoreClassifier(gesture);
      final temporalScore = _scoreTemporal(gesture);
      final landmarkScore = _scoreLandmark(landmarks);
      final historicalScore = _scoreHistorical(gesture);
      
      // Combine into overall score
      final score = ConfidenceScore.fromComponents(
        classifier: classifierScore,
        temporal: temporalScore,
        landmark: landmarkScore,
        historical: historicalScore,
        config: _config,
      );
      
      _logger.debug(
        'Confidence score for ${gesture.letter}: '
        '${score.overall.toStringAsFixed(2)} '
        '(classifier: ${classifierScore.toStringAsFixed(2)}, '
        'temporal: ${temporalScore.toStringAsFixed(2)}, '
        'landmark: ${landmarkScore.toStringAsFixed(2)}, '
        'historical: ${historicalScore.toStringAsFixed(2)})'
      );
      
      return score;
    } catch (e, stackTrace) {
      _logger.error('Error calculating confidence score', e, stackTrace);
      
      // Return low confidence on error
      return ConfidenceScore.fromComponents(
        classifier: gesture.confidence,
        temporal: 0.5,
        landmark: 0.5,
        historical: 0.5,
        config: _config,
      );
    }
  }
  
  /// Score classifier confidence
  double _scoreClassifier(SignGesture gesture) {
    // Use raw classifier confidence
    return gesture.confidence.clamp(0.0, 1.0);
  }
  
  /// Score temporal consistency
  double _scoreTemporal(SignGesture gesture) {
    if (_recentGestures.length < _config.minFramesForTemporal) {
      // Not enough data for temporal analysis
      return 0.5; // Neutral score
    }
    
    // Count how many recent gestures match this letter
    final recentMatches = _recentGestures
        .where((g) => g.letter == gesture.letter)
        .length;
    
    // Calculate consistency ratio
    final consistency = recentMatches / _recentGestures.length;
    
    // Higher consistency = higher confidence
    return consistency;
  }
  
  /// Score landmark quality
  double _scoreLandmark(HandLandmarks landmarks) {
    double score = 1.0;
    
    // Factor 1: Landmark confidence
    score *= landmarks.confidence;
    
    // Factor 2: Check for missing or invalid landmarks
    final invalidCount = landmarks.points.where((p) {
      return p.x.isNaN || p.y.isNaN || p.z.isNaN ||
             p.x < 0 || p.x > 1 ||
             p.y < 0 || p.y > 1;
    }).length;
    
    if (invalidCount > 0) {
      score *= (1.0 - (invalidCount / landmarks.points.length));
    }
    
    // Factor 3: Check landmark spread (hand should occupy reasonable space)
    final spread = _calculateLandmarkSpread(landmarks);
    if (spread < 0.1) {
      // Hand too small/far away
      score *= 0.7;
    } else if (spread > 0.9) {
      // Hand too large/close
      score *= 0.8;
    }
    
    return score.clamp(0.0, 1.0);
  }
  
  /// Calculate landmark spread (bounding box size)
  double _calculateLandmarkSpread(HandLandmarks landmarks) {
    double minX = 1.0, maxX = 0.0;
    double minY = 1.0, maxY = 0.0;
    
    for (final point in landmarks.points) {
      if (!point.x.isNaN && !point.y.isNaN) {
        minX = min(minX, point.x);
        maxX = max(maxX, point.x);
        minY = min(minY, point.y);
        maxY = max(maxY, point.y);
      }
    }
    
    final width = maxX - minX;
    final height = maxY - minY;
    
    return max(width, height);
  }
  
  /// Score historical accuracy
  double _scoreHistorical(SignGesture gesture) {
    final history = _history[gesture.letter];
    
    if (history == null || history.totalAttempts < 3) {
      // Not enough historical data
      return 0.5; // Neutral score
    }
    
    // Use historical accuracy as score
    return history.accuracy;
  }
  
  /// Add gesture to buffer
  void _addToBuffer(SignGesture gesture) {
    _recentGestures.add(gesture);
    
    // Maintain buffer size
    if (_recentGestures.length > _maxBufferSize) {
      _recentGestures.removeAt(0);
    }
  }
  
  /// Record gesture attempt result
  void recordAttempt(String letter, bool success) {
    final history = _history.putIfAbsent(
      letter,
      () => _GestureHistory(letter),
    );
    
    history.recordAttempt(success);
    
    _logger.debug(
      'Recorded attempt for $letter: ${success ? "success" : "failure"} '
      '(accuracy: ${history.accuracy.toStringAsFixed(2)})'
    );
  }
  
  /// Update configuration
  void updateConfig(ConfidenceScoringConfig newConfig) {
    if (!newConfig.isValid) {
      throw ArgumentError('Confidence scoring weights must sum to 1.0');
    }
    
    _logger.info('Updating confidence scoring configuration');
    _config = newConfig;
  }
  
  /// Clear recent gestures buffer
  void clearBuffer() {
    _logger.debug('Clearing gesture buffer (${_recentGestures.length} items)');
    _recentGestures.clear();
  }
  
  /// Clear historical data
  void clearHistory() {
    _logger.info('Clearing historical accuracy data (${_history.length} letters)');
    _history.clear();
  }
  
  /// Get statistics
  Map<String, dynamic> getStatistics() {
    final historyStats = <String, dynamic>{};
    for (final entry in _history.entries) {
      historyStats[entry.key] = {
        'attempts': entry.value.totalAttempts,
        'successes': entry.value.successfulAttempts,
        'accuracy': entry.value.accuracy,
      };
    }
    
    return {
      'bufferSize': _recentGestures.length,
      'historySize': _history.length,
      'history': historyStats,
      'config': {
        'classifierWeight': _config.classifierWeight,
        'temporalWeight': _config.temporalWeight,
        'landmarkWeight': _config.landmarkWeight,
        'historicalWeight': _config.historicalWeight,
      },
    };
  }
}