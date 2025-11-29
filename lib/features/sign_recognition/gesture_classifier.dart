import 'dart:math';
import 'package:signbridge/core/models/hand_landmarks.dart';
import 'package:signbridge/core/models/sign_gesture.dart';
import 'package:signbridge/config/app_config.dart';
import 'package:signbridge/features/sign_recognition/asl_database.dart';
import 'package:signbridge/core/utils/logger.dart';

/// Classifies hand gestures by comparing landmarks to ASL database
class GestureClassifier {
  /// Classify a hand gesture based on landmarks
  /// 
  /// Returns a [GestureResult] with the best matching sign and confidence score.
  /// Uses cosine similarity to compare normalized landmark vectors.
  Future<GestureResult> classify(HandLandmarks landmarks) async {
    final startTime = DateTime.now();
    
    try {
      // Step 1: Normalize landmarks
      final normalized = landmarks.normalize();
      final featureVector = normalized.toFeatureVector();
      
      Logger.debug(
        'Classifying gesture with ${featureVector.length} features',
        'GESTURE_CLASSIFIER',
      );
      
      // Step 2: Calculate similarities to all known gestures
      final similarities = <String, double>{};
      
      for (final entry in ASLDatabase.signs.entries) {
        final similarity = _cosineSimilarity(featureVector, entry.value);
        similarities[entry.key] = similarity;
      }
      
      // Step 3: Find best match
      final best = similarities.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      
      // Step 4: Check if confidence meets threshold
      final meetsThreshold = best.value >= AppConfig.confidenceThreshold;
      
      final duration = DateTime.now().difference(startTime);
      
      Logger.debug(
        'Best match: ${best.key} (${(best.value * 100).toStringAsFixed(1)}%) '
        'in ${duration.inMilliseconds}ms',
        'GESTURE_CLASSIFIER',
      );
      
      return GestureResult(
        letter: meetsThreshold ? best.key : null,
        confidence: best.value,
        allSimilarities: similarities,
      );
    } catch (e, stackTrace) {
      Logger.error(e, stackTrace, 'GESTURE_CLASSIFIER');
      
      // Return empty result on error
      return GestureResult(
        letter: null,
        confidence: 0.0,
      );
    }
  }
  
  /// Calculate cosine similarity between two vectors
  /// 
  /// Cosine similarity = (A · B) / (||A|| × ||B||)
  /// Returns a value between -1 and 1, where 1 means identical direction
  double _cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) {
      throw ArgumentError('Vectors must have same length');
    }
    
    // Calculate dot product
    double dotProduct = 0.0;
    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
    }
    
    // Calculate magnitudes
    double magnitudeA = 0.0;
    double magnitudeB = 0.0;
    
    for (int i = 0; i < a.length; i++) {
      magnitudeA += a[i] * a[i];
      magnitudeB += b[i] * b[i];
    }
    
    magnitudeA = sqrt(magnitudeA);
    magnitudeB = sqrt(magnitudeB);
    
    // Avoid division by zero
    if (magnitudeA == 0 || magnitudeB == 0) {
      return 0.0;
    }
    
    // Calculate cosine similarity
    return dotProduct / (magnitudeA * magnitudeB);
  }
  
  /// Calculate Euclidean distance between two vectors
  /// 
  /// Lower distance means more similar gestures.
  /// This is an alternative to cosine similarity.
  double _euclideanDistance(List<double> a, List<double> b) {
    if (a.length != b.length) {
      throw ArgumentError('Vectors must have same length');
    }
    
    double sum = 0.0;
    for (int i = 0; i < a.length; i++) {
      final diff = a[i] - b[i];
      sum += diff * diff;
    }
    
    return sqrt(sum);
  }
  
  /// Classify using multiple methods and combine results
  /// 
  /// This can improve accuracy by using both cosine similarity
  /// and Euclidean distance, then averaging the results.
  Future<GestureResult> classifyHybrid(HandLandmarks landmarks) async {
    final normalized = landmarks.normalize();
    final featureVector = normalized.toFeatureVector();
    
    final cosineSimilarities = <String, double>{};
    final euclideanDistances = <String, double>{};
    
    // Calculate both metrics
    for (final entry in ASLDatabase.signs.entries) {
      cosineSimilarities[entry.key] = _cosineSimilarity(
        featureVector,
        entry.value,
      );
      
      euclideanDistances[entry.key] = _euclideanDistance(
        featureVector,
        entry.value,
      );
    }
    
    // Normalize Euclidean distances to 0-1 range (inverted, so closer = higher)
    final maxDistance = euclideanDistances.values.reduce(max);
    final normalizedDistances = <String, double>{};
    
    for (final entry in euclideanDistances.entries) {
      normalizedDistances[entry.key] = 1.0 - (entry.value / maxDistance);
    }
    
    // Combine scores (weighted average)
    final combinedScores = <String, double>{};
    const cosineWeight = 0.7;
    const distanceWeight = 0.3;
    
    for (final key in ASLDatabase.signs.keys) {
      combinedScores[key] = 
          (cosineSimilarities[key]! * cosineWeight) +
          (normalizedDistances[key]! * distanceWeight);
    }
    
    // Find best match
    final best = combinedScores.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );
    
    final meetsThreshold = best.value >= AppConfig.confidenceThreshold;
    
    return GestureResult(
      letter: meetsThreshold ? best.key : null,
      confidence: best.value,
      allSimilarities: combinedScores,
    );
  }
  
  /// Get top N most similar gestures
  /// 
  /// Useful for debugging or showing alternative interpretations
  List<MapEntry<String, double>> getTopMatches(
    HandLandmarks landmarks,
    int n,
  ) {
    final normalized = landmarks.normalize();
    final featureVector = normalized.toFeatureVector();
    
    final similarities = <String, double>{};
    
    for (final entry in ASLDatabase.signs.entries) {
      similarities[entry.key] = _cosineSimilarity(featureVector, entry.value);
    }
    
    final sorted = similarities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.take(n).toList();
  }
  
  /// Validate that the classifier is working correctly
  /// 
  /// Tests classification against known gestures from the database
  Future<Map<String, dynamic>> validateClassifier() async {
    Logger.info('Validating gesture classifier...', 'GESTURE_CLASSIFIER');
    
    int correct = 0;
    int total = 0;
    final errors = <String>[];
    
    // Test each gesture in the database
    for (final entry in ASLDatabase.signs.entries) {
      final testLandmarks = HandLandmarks(
        points: _vectorToPoints(entry.value),
        timestamp: DateTime.now(),
        confidence: 1.0,
      );
      
      final result = await classify(testLandmarks);
      
      total++;
      if (result.letter == entry.key) {
        correct++;
      } else {
        errors.add(
          'Expected ${entry.key}, got ${result.letter} '
          '(confidence: ${result.confidence.toStringAsFixed(2)})',
        );
      }
    }
    
    final accuracy = (correct / total) * 100;
    
    Logger.info(
      'Classifier validation: $correct/$total correct (${accuracy.toStringAsFixed(1)}%)',
      'GESTURE_CLASSIFIER',
    );
    
    return {
      'correct': correct,
      'total': total,
      'accuracy': accuracy,
      'errors': errors,
    };
  }
  
  /// Convert feature vector back to Point3D list
  List<Point3D> _vectorToPoints(List<double> vector) {
    final points = <Point3D>[];
    
    for (int i = 0; i < vector.length; i += 3) {
      points.add(Point3D(
        vector[i],
        vector[i + 1],
        vector[i + 2],
      ));
    }
    
    return points;
  }
}