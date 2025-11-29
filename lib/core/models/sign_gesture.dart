import 'package:signbridge/core/models/hand_landmarks.dart';
import 'package:signbridge/config/app_config.dart';

/// Represents a recognized sign gesture
class SignGesture {
  final String letter;
  final double confidence;
  final DateTime timestamp;
  final HandLandmarks landmarks;
  final Duration processingTime;
  
  SignGesture({
    required this.letter,
    required this.confidence,
    required this.timestamp,
    required this.landmarks,
    required this.processingTime,
  });
  
  /// Check if confidence is above the threshold
  bool get isHighConfidence => 
      confidence >= AppConfig.confidenceThreshold;
  
  /// Check if confidence is below the low threshold
  bool get isLowConfidence => 
      confidence < AppConfig.lowConfidenceThreshold;
  
  /// Check if confidence is in the medium range
  bool get isMediumConfidence => 
      !isHighConfidence && !isLowConfidence;
  
  /// Get confidence as a percentage string
  String get confidencePercentage => 
      '${(confidence * 100).toStringAsFixed(1)}%';
  
  /// Get processing time in milliseconds
  int get processingTimeMs => processingTime.inMilliseconds;
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'letter': letter,
      'confidence': confidence,
      'timestamp': timestamp.toIso8601String(),
      'landmarks': landmarks.toJson(),
      'processingTimeMs': processingTimeMs,
    };
  }
  
  /// Create from JSON
  factory SignGesture.fromJson(Map<String, dynamic> json) {
    return SignGesture(
      letter: json['letter'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      landmarks: HandLandmarks.fromJson(
        json['landmarks'] as Map<String, dynamic>,
      ),
      processingTime: Duration(
        milliseconds: json['processingTimeMs'] as int,
      ),
    );
  }
  
  @override
  String toString() {
    return 'SignGesture(letter: $letter, '
           'confidence: $confidencePercentage, '
           'processingTime: ${processingTimeMs}ms)';
  }
  
  /// Create a copy with modified fields
  SignGesture copyWith({
    String? letter,
    double? confidence,
    DateTime? timestamp,
    HandLandmarks? landmarks,
    Duration? processingTime,
  }) {
    return SignGesture(
      letter: letter ?? this.letter,
      confidence: confidence ?? this.confidence,
      timestamp: timestamp ?? this.timestamp,
      landmarks: landmarks ?? this.landmarks,
      processingTime: processingTime ?? this.processingTime,
    );
  }
}

/// Result of gesture classification
class GestureResult {
  final String? letter;
  final double confidence;
  final Map<String, double>? allSimilarities;
  
  GestureResult({
    required this.letter,
    required this.confidence,
    this.allSimilarities,
  });
  
  /// Check if a valid gesture was recognized
  bool get isValid => letter != null && letter!.isNotEmpty;
  
  /// Get the top N most similar gestures
  List<MapEntry<String, double>> getTopSimilarities(int n) {
    if (allSimilarities == null) return [];
    
    final sorted = allSimilarities!.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.take(n).toList();
  }
  
  @override
  String toString() {
    return 'GestureResult(letter: $letter, confidence: $confidence)';
  }
}