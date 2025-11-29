import 'dart:async';
import 'package:signbridge/core/models/performance_metrics.dart';
import 'package:signbridge/core/models/recognition_result.dart';
import 'package:signbridge/config/app_config.dart';
import 'package:signbridge/core/utils/logger.dart';

/// Monitors and tracks performance metrics
class PerformanceMonitor {
  // Singleton instance
  static final PerformanceMonitor instance = PerformanceMonitor._();
  
  PerformanceMonitor._();
  
  // Storage for measurements
  final List<LatencyMeasurement> _measurements = [];
  
  // Stream controller for real-time metrics
  final _metricsController = StreamController<PerformanceMetrics>.broadcast();
  
  /// Stream of performance metrics updates
  Stream<PerformanceMetrics> get metricsStream => _metricsController.stream;
  
  /// Record a latency measurement
  void recordLatency({
    required String operation,
    required Duration duration,
    required ProcessingSource source,
  }) {
    final measurement = LatencyMeasurement(
      operation: operation,
      latencyMs: duration.inMilliseconds,
      source: source,
      timestamp: DateTime.now(),
    );
    
    _measurements.add(measurement);
    
    // Keep only the last N measurements
    if (_measurements.length > AppConfig.maxPerformanceMeasurements) {
      _measurements.removeAt(0);
    }
    
    // Log performance
    Logger.performance(operation, duration, source.name.toUpperCase());
    
    // Emit updated metrics
    _metricsController.add(getStats());
  }
  
  /// Get aggregated statistics
  PerformanceMetrics getStats() {
    if (_measurements.isEmpty) {
      return PerformanceMetrics(
        avgLocalLatency: 0,
        avgCloudLatency: 0,
        localCount: 0,
        cloudCount: 0,
        fallbackCount: 0,
        totalProcessed: 0,
        localPercentage: 0,
        cloudPercentage: 0,
        generatedAt: DateTime.now(),
      );
    }
    
    // Separate measurements by source
    final local = _measurements.where(
      (m) => m.source == ProcessingSource.local,
    ).toList();
    
    final cloud = _measurements.where(
      (m) => m.source == ProcessingSource.cloud,
    ).toList();
    
    final fallback = _measurements.where(
      (m) => m.source == ProcessingSource.localFallback,
    ).toList();
    
    // Calculate averages
    final avgLocal = local.isEmpty
        ? 0.0
        : local.map((m) => m.latencyMs).reduce((a, b) => a + b) / local.length;
    
    final avgCloud = cloud.isEmpty
        ? 0.0
        : cloud.map((m) => m.latencyMs).reduce((a, b) => a + b) / cloud.length;
    
    final total = _measurements.length;
    final localPercentage = (local.length / total) * 100;
    final cloudPercentage = (cloud.length / total) * 100;
    
    return PerformanceMetrics(
      avgLocalLatency: avgLocal,
      avgCloudLatency: avgCloud,
      localCount: local.length,
      cloudCount: cloud.length,
      fallbackCount: fallback.length,
      totalProcessed: total,
      localPercentage: localPercentage,
      cloudPercentage: cloudPercentage,
      generatedAt: DateTime.now(),
    );
  }
  
  /// Get raw measurements
  List<LatencyMeasurement> getMeasurements() {
    return List.unmodifiable(_measurements);
  }
  
  /// Get measurements for a specific operation
  List<LatencyMeasurement> getMeasurementsForOperation(String operation) {
    return _measurements.where((m) => m.operation == operation).toList();
  }
  
  /// Get measurements for a specific source
  List<LatencyMeasurement> getMeasurementsForSource(ProcessingSource source) {
    return _measurements.where((m) => m.source == source).toList();
  }
  
  /// Clear all measurements
  void clear() {
    _measurements.clear();
    _metricsController.add(getStats());
    Logger.info('Performance measurements cleared', 'PERFORMANCE');
  }
  
  /// Export metrics as CSV
  String exportMetricsCSV() {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('Timestamp,Operation,Latency (ms),Source');
    
    // Data rows
    for (final measurement in _measurements) {
      buffer.writeln(
        '${measurement.timestamp.toIso8601String()},'
        '${measurement.operation},'
        '${measurement.latencyMs},'
        '${measurement.source.name}',
      );
    }
    
    return buffer.toString();
  }
  
  /// Export metrics as JSON
  String exportMetricsJSON() {
    final stats = getStats();
    final data = {
      'summary': stats.toJson(),
      'measurements': _measurements.map((m) => m.toJson()).toList(),
    };
    
    return data.toString();
  }
  
  /// Dispose resources
  void dispose() {
    _metricsController.close();
  }
}