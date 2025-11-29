import 'package:signbridge/core/models/recognition_result.dart';

/// Represents a single latency measurement
class LatencyMeasurement {
  final String operation;
  final int latencyMs;
  final ProcessingSource source;
  final DateTime timestamp;
  
  LatencyMeasurement({
    required this.operation,
    required this.latencyMs,
    required this.source,
    required this.timestamp,
  });
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'operation': operation,
      'latencyMs': latencyMs,
      'source': source.name,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  /// Create from JSON
  factory LatencyMeasurement.fromJson(Map<String, dynamic> json) {
    return LatencyMeasurement(
      operation: json['operation'] as String,
      latencyMs: json['latencyMs'] as int,
      source: ProcessingSource.values.firstWhere(
        (e) => e.name == json['source'],
        orElse: () => ProcessingSource.local,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

/// Aggregated performance metrics
class PerformanceMetrics {
  final double avgLocalLatency;
  final double avgCloudLatency;
  final int localCount;
  final int cloudCount;
  final int fallbackCount;
  final int totalProcessed;
  final double localPercentage;
  final double cloudPercentage;
  final DateTime generatedAt;
  
  PerformanceMetrics({
    required this.avgLocalLatency,
    required this.avgCloudLatency,
    required this.localCount,
    required this.cloudCount,
    required this.fallbackCount,
    required this.totalProcessed,
    required this.localPercentage,
    required this.cloudPercentage,
    required this.generatedAt,
  });
  
  /// Get privacy score (percentage of local processing)
  double get privacyScore => localPercentage + (fallbackCount / totalProcessed * 100);
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'avgLocalLatency': avgLocalLatency,
      'avgCloudLatency': avgCloudLatency,
      'localCount': localCount,
      'cloudCount': cloudCount,
      'fallbackCount': fallbackCount,
      'totalProcessed': totalProcessed,
      'localPercentage': localPercentage,
      'cloudPercentage': cloudPercentage,
      'privacyScore': privacyScore,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
  
  /// Create from JSON
  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return PerformanceMetrics(
      avgLocalLatency: (json['avgLocalLatency'] as num).toDouble(),
      avgCloudLatency: (json['avgCloudLatency'] as num).toDouble(),
      localCount: json['localCount'] as int,
      cloudCount: json['cloudCount'] as int,
      fallbackCount: json['fallbackCount'] as int,
      totalProcessed: json['totalProcessed'] as int,
      localPercentage: (json['localPercentage'] as num).toDouble(),
      cloudPercentage: (json['cloudPercentage'] as num).toDouble(),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );
  }
  
  @override
  String toString() {
    return 'PerformanceMetrics('
           'avgLocal: ${avgLocalLatency.toStringAsFixed(1)}ms, '
           'avgCloud: ${avgCloudLatency.toStringAsFixed(1)}ms, '
           'local: $localCount, cloud: $cloudCount, '
           'privacy: ${privacyScore.toStringAsFixed(1)}%)';
  }
}