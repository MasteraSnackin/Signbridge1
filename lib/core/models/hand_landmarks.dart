import 'dart:math';
import 'package:signbridge/core/models/point_3d.dart';
import 'package:signbridge/config/app_config.dart';

/// Represents hand landmarks detected from an image
/// Uses MediaPipe standard with 21 landmarks per hand
class HandLandmarks {
  final List<Point3D> points;
  final DateTime timestamp;
  final double confidence;
  
  HandLandmarks({
    required this.points,
    required this.timestamp,
    required this.confidence,
  }) : assert(
    points.length == AppConfig.numHandLandmarks,
    'Hand landmarks must have exactly ${AppConfig.numHandLandmarks} points',
  );
  
  // ============================================================================
  // NAMED ACCESSORS FOR KEY LANDMARKS (MediaPipe standard)
  // ============================================================================
  
  /// Wrist (landmark 0)
  Point3D get wrist => points[0];
  
  /// Thumb landmarks
  Point3D get thumbCMC => points[1];
  Point3D get thumbMCP => points[2];
  Point3D get thumbIP => points[3];
  Point3D get thumbTip => points[4];
  
  /// Index finger landmarks
  Point3D get indexMCP => points[5];
  Point3D get indexPIP => points[6];
  Point3D get indexDIP => points[7];
  Point3D get indexTip => points[8];
  
  /// Middle finger landmarks
  Point3D get middleMCP => points[9];
  Point3D get middlePIP => points[10];
  Point3D get middleDIP => points[11];
  Point3D get middleTip => points[12];
  
  /// Ring finger landmarks
  Point3D get ringMCP => points[13];
  Point3D get ringPIP => points[14];
  Point3D get ringDIP => points[15];
  Point3D get ringTip => points[16];
  
  /// Pinky finger landmarks
  Point3D get pinkyMCP => points[17];
  Point3D get pinkyPIP => points[18];
  Point3D get pinkyDIP => points[19];
  Point3D get pinkyTip => points[20];
  
  // ============================================================================
  // NORMALIZATION METHODS
  // ============================================================================
  
  /// Normalize landmarks to be scale and translation invariant
  /// 
  /// Steps:
  /// 1. Translate to wrist origin (make wrist the center)
  /// 2. Scale to unit size (normalize by maximum distance from wrist)
  /// 3. Optionally rotate to canonical orientation
  HandLandmarks normalize() {
    // Step 1: Translate to wrist origin
    final translated = points.map((p) => p - wrist).toList();
    
    // Step 2: Find maximum distance from wrist
    final maxDist = translated
        .map((p) => p.magnitude)
        .reduce((a, b) => a > b ? a : b);
    
    // Avoid division by zero
    if (maxDist == 0) {
      return HandLandmarks(
        points: points,
        timestamp: timestamp,
        confidence: confidence,
      );
    }
    
    // Step 3: Scale to unit size
    final scaled = translated.map((p) => p / maxDist).toList();
    
    return HandLandmarks(
      points: scaled,
      timestamp: timestamp,
      confidence: confidence,
    );
  }
  
  /// Convert landmarks to a flat feature vector for classification
  /// Returns a list of 63 values (21 landmarks × 3 coordinates)
  List<double> toFeatureVector() {
    return points.expand((p) => [p.x, p.y, p.z]).toList();
  }
  
  // ============================================================================
  // GEOMETRIC CALCULATIONS
  // ============================================================================
  
  /// Calculate the bounding box of the hand
  Map<String, double> getBoundingBox() {
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;
    
    for (final point in points) {
      minX = min(minX, point.x);
      minY = min(minY, point.y);
      maxX = max(maxX, point.x);
      maxY = max(maxY, point.y);
    }
    
    return {
      'minX': minX,
      'minY': minY,
      'maxX': maxX,
      'maxY': maxY,
      'width': maxX - minX,
      'height': maxY - minY,
    };
  }
  
  /// Calculate the center point of the hand
  Point3D getCenter() {
    double sumX = 0;
    double sumY = 0;
    double sumZ = 0;
    
    for (final point in points) {
      sumX += point.x;
      sumY += point.y;
      sumZ += point.z;
    }
    
    final count = points.length;
    return Point3D(sumX / count, sumY / count, sumZ / count);
  }
  
  /// Calculate the distance between two specific landmarks
  double distanceBetween(int index1, int index2) {
    if (index1 < 0 || index1 >= points.length ||
        index2 < 0 || index2 >= points.length) {
      throw ArgumentError('Invalid landmark indices');
    }
    return points[index1].distanceTo(points[index2]);
  }
  
  // ============================================================================
  // SERIALIZATION
  // ============================================================================
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'points': points.map((p) => p.toJson()).toList(),
      'timestamp': timestamp.toIso8601String(),
      'confidence': confidence,
    };
  }
  
  /// Create from JSON
  factory HandLandmarks.fromJson(Map<String, dynamic> json) {
    return HandLandmarks(
      points: (json['points'] as List)
          .map((p) => Point3D.fromJson(p as Map<String, dynamic>))
          .toList(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      confidence: (json['confidence'] as num).toDouble(),
    );
  }
  
  // ============================================================================
  // UTILITY METHODS
  // ============================================================================
  
  @override
  String toString() {
    return 'HandLandmarks(points: ${points.length}, '
           'confidence: ${confidence.toStringAsFixed(2)}, '
           'timestamp: $timestamp)';
  }
  
  /// Create a copy with modified fields
  HandLandmarks copyWith({
    List<Point3D>? points,
    DateTime? timestamp,
    double? confidence,
  }) {
    return HandLandmarks(
      points: points ?? this.points,
      timestamp: timestamp ?? this.timestamp,
      confidence: confidence ?? this.confidence,
    );
  }
}