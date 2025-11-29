/// Hybrid Router
/// 
/// Intelligently routes recognition requests between local and cloud processing
/// based on confidence scores, network availability, and user preferences.
/// 
/// Decision Logic:
/// - High confidence (≥75%) → Local processing
/// - Low confidence (<75%) + Online → Cloud processing
/// - Low confidence + Offline → Local processing (fallback)
/// 
/// This is a Track 2 feature for the hackathon.

import 'dart:async';
import '../../core/models/hand_landmarks.dart';
import '../../core/models/recognition_result.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/performance_monitor.dart';
import '../../core/services/storage_service.dart';
import '../sign_recognition/gesture_classifier.dart';
import 'cloud_fallback_service.dart';
import 'confidence_scorer.dart';

/// Hybrid routing configuration
class HybridRoutingConfig {
  /// Local confidence threshold (below this, consider cloud)
  final double localConfidenceThreshold;
  
  /// Whether cloud fallback is enabled
  final bool cloudEnabled;
  
  /// Maximum cloud request timeout in milliseconds
  final int cloudTimeout;
  
  /// Whether to always try local first
  final bool localFirst;
  
  /// Maximum number of cloud requests per minute
  final int cloudRateLimit;
  
  const HybridRoutingConfig({
    this.localConfidenceThreshold = 0.75,
    this.cloudEnabled = false,
    this.cloudTimeout = 5000,
    this.localFirst = true,
    this.cloudRateLimit = 30,
  });
  
  /// Default configuration (local-only)
  static const HybridRoutingConfig defaultConfig = HybridRoutingConfig();
  
  /// Aggressive cloud usage
  static const HybridRoutingConfig aggressive = HybridRoutingConfig(
    localConfidenceThreshold: 0.85,
    cloudEnabled: true,
    cloudTimeout: 3000,
    cloudRateLimit: 60,
  );
  
  /// Conservative cloud usage
  static const HybridRoutingConfig conservative = HybridRoutingConfig(
    localConfidenceThreshold: 0.65,
    cloudEnabled: true,
    cloudTimeout: 10000,
    cloudRateLimit: 15,
  );
}

/// Routing decision
class RoutingDecision {
  /// Whether to use cloud processing
  final bool useCloud;
  
  /// Reason for the decision
  final String reason;
  
  /// Local confidence score
  final double localConfidence;
  
  /// Whether network is available
  final bool networkAvailable;
  
  /// Timestamp
  final DateTime timestamp;
  
  const RoutingDecision({
    required this.useCloud,
    required this.reason,
    required this.localConfidence,
    required this.networkAvailable,
    required this.timestamp,
  });
}

/// Routing statistics
class RoutingStats {
  int localRequests = 0;
  int cloudRequests = 0;
  int cloudSuccesses = 0;
  int cloudFailures = 0;
  int localFallbacks = 0;
  
  double get totalRequests => (localRequests + cloudRequests).toDouble();
  double get cloudSuccessRate => cloudRequests > 0 
      ? cloudSuccesses / cloudRequests 
      : 0.0;
  double get localPercentage => totalRequests > 0 
      ? localRequests / totalRequests * 100 
      : 0.0;
  double get cloudPercentage => totalRequests > 0 
      ? cloudRequests / totalRequests * 100 
      : 0.0;
  
  Map<String, dynamic> toJson() {
    return {
      'localRequests': localRequests,
      'cloudRequests': cloudRequests,
      'cloudSuccesses': cloudSuccesses,
      'cloudFailures': cloudFailures,
      'localFallbacks': localFallbacks,
      'totalRequests': totalRequests.toInt(),
      'cloudSuccessRate': cloudSuccessRate,
      'localPercentage': localPercentage,
      'cloudPercentage': cloudPercentage,
    };
  }
}

/// Hybrid router for intelligent local/cloud routing
class HybridRouter {
  static final HybridRouter _instance = HybridRouter._internal();
  factory HybridRouter() => _instance;
  HybridRouter._internal();
  
  final _logger = Logger('HybridRouter');
  final _performanceMonitor = PerformanceMonitor.instance;
  final _gestureClassifier = GestureClassifier();
  final _cloudService = CloudFallbackService();
  final _confidenceScorer = ConfidenceScorer();
  
  /// Configuration
  HybridRoutingConfig _config = HybridRoutingConfig.defaultConfig;
  HybridRoutingConfig get config => _config;
  
  /// Statistics
  final _stats = RoutingStats();
  RoutingStats get stats => _stats;
  
  /// Whether cloud is enabled
  bool get cloudEnabled => _config.cloudEnabled;
  
  /// Cloud request rate limiter
  final List<DateTime> _cloudRequestTimes = [];
  
  /// Stream controller for routing decisions
  final _decisionController = StreamController<RoutingDecision>.broadcast();
  
  /// Stream of routing decisions
  Stream<RoutingDecision> get decisionStream => _decisionController.stream;
  
  /// Initialize the router
  Future<void> initialize({HybridRoutingConfig? config}) async {
    _logger.info('Initializing hybrid router...');
    
    // Load saved configuration
    if (config == null) {
      final savedCloudEnabled = await StorageService.instance.getHybridModeEnabled();
      _config = HybridRoutingConfig(
        cloudEnabled: savedCloudEnabled,
      );
    } else {
      _config = config;
    }
    
    // Initialize cloud service if enabled
    if (_config.cloudEnabled) {
      await _cloudService.initialize();
    }
    
    _logger.info(
      'Hybrid router initialized '
      '(cloud: ${_config.cloudEnabled ? "enabled" : "disabled"})'
    );
  }
  
  /// Process gesture with hybrid routing
  Future<RecognitionResult> processGesture(HandLandmarks landmarks) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      // Step 1: Always try local processing first
      final localResult = await _processLocal(landmarks);
      
      // Step 2: Make routing decision
      final decision = await _makeRoutingDecision(localResult);
      
      // Emit decision
      _decisionController.add(decision);
      
      // Step 3: Route based on decision
      RecognitionResult finalResult;
      
      if (decision.useCloud) {
        // Try cloud processing
        try {
          finalResult = await _processCloud(landmarks, localResult);
          _stats.cloudSuccesses++;
        } catch (e) {
          _logger.warning('Cloud processing failed, using local result: $e');
          finalResult = localResult;
          _stats.cloudFailures++;
          _stats.localFallbacks++;
        }
      } else {
        // Use local result
        finalResult = localResult;
      }
      
      stopwatch.stop();
      
      // Record performance
      _performanceMonitor.recordLatency(
        operation: 'hybrid_routing',
        duration: stopwatch.elapsed,
        source: finalResult.source,
      );
      
      return finalResult;
    } catch (e, stackTrace) {
      _logger.error('Error in hybrid routing', e, stackTrace);
      
      // Fallback to local processing
      return _processLocal(landmarks);
    }
  }
  
  /// Process gesture locally
  Future<RecognitionResult> _processLocal(HandLandmarks landmarks) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = await _gestureClassifier.classify(landmarks);
      
      stopwatch.stop();
      _stats.localRequests++;
      
      return RecognitionResult(
        text: result.letter,
        confidence: result.confidence,
        source: ProcessingSource.local,
        latency: stopwatch.elapsedMilliseconds,
        timestamp: DateTime.now(),
      );
    } catch (e, stackTrace) {
      _logger.error('Error in local processing', e, stackTrace);
      
      stopwatch.stop();
      
      return RecognitionResult(
        text: null,
        confidence: 0.0,
        source: ProcessingSource.local,
        latency: stopwatch.elapsedMilliseconds,
        timestamp: DateTime.now(),
      );
    }
  }
  
  /// Process gesture in cloud
  Future<RecognitionResult> _processCloud(
    HandLandmarks landmarks,
    RecognitionResult localResult,
  ) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      _logger.info('Sending to cloud (local confidence: ${localResult.confidence.toStringAsFixed(2)})');
      
      // Check rate limit
      if (!_checkRateLimit()) {
        throw Exception('Cloud rate limit exceeded');
      }
      
      // Send to cloud with timeout
      final cloudResult = await _cloudService
          .recognizeGesture(landmarks)
          .timeout(Duration(milliseconds: _config.cloudTimeout));
      
      stopwatch.stop();
      _stats.cloudRequests++;
      
      // Record cloud request time
      _cloudRequestTimes.add(DateTime.now());
      
      _logger.info(
        'Cloud result: ${cloudResult.text} '
        '(confidence: ${cloudResult.confidence.toStringAsFixed(2)}, '
        'latency: ${stopwatch.elapsedMilliseconds}ms)'
      );
      
      return RecognitionResult(
        text: cloudResult.text,
        confidence: cloudResult.confidence,
        source: ProcessingSource.cloud,
        latency: stopwatch.elapsedMilliseconds,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      _logger.warning('Cloud processing failed: $e');
      rethrow;
    }
  }
  
  /// Make routing decision
  Future<RoutingDecision> _makeRoutingDecision(
    RecognitionResult localResult,
  ) async {
    // Check if cloud is enabled
    if (!_config.cloudEnabled) {
      return RoutingDecision(
        useCloud: false,
        reason: 'Cloud disabled by user',
        localConfidence: localResult.confidence,
        networkAvailable: false,
        timestamp: DateTime.now(),
      );
    }
    
    // Check network availability
    final networkAvailable = await _cloudService.isNetworkAvailable();
    if (!networkAvailable) {
      return RoutingDecision(
        useCloud: false,
        reason: 'Network unavailable',
        localConfidence: localResult.confidence,
        networkAvailable: false,
        timestamp: DateTime.now(),
      );
    }
    
    // Check local confidence
    if (localResult.confidence >= _config.localConfidenceThreshold) {
      return RoutingDecision(
        useCloud: false,
        reason: 'High local confidence (${localResult.confidence.toStringAsFixed(2)})',
        localConfidence: localResult.confidence,
        networkAvailable: true,
        timestamp: DateTime.now(),
      );
    }
    
    // Check rate limit
    if (!_checkRateLimit()) {
      return RoutingDecision(
        useCloud: false,
        reason: 'Cloud rate limit exceeded',
        localConfidence: localResult.confidence,
        networkAvailable: true,
        timestamp: DateTime.now(),
      );
    }
    
    // Use cloud for low confidence
    return RoutingDecision(
      useCloud: true,
      reason: 'Low local confidence (${localResult.confidence.toStringAsFixed(2)})',
      localConfidence: localResult.confidence,
      networkAvailable: true,
      timestamp: DateTime.now(),
    );
  }
  
  /// Check if within rate limit
  bool _checkRateLimit() {
    final now = DateTime.now();
    final oneMinuteAgo = now.subtract(Duration(minutes: 1));
    
    // Remove old requests
    _cloudRequestTimes.removeWhere((time) => time.isBefore(oneMinuteAgo));
    
    // Check if under limit
    return _cloudRequestTimes.length < _config.cloudRateLimit;
  }
  
  /// Update configuration
  Future<void> updateConfig(HybridRoutingConfig newConfig) async {
    _logger.info('Updating hybrid routing configuration');
    
    final wasEnabled = _config.cloudEnabled;
    _config = newConfig;
    
    // Initialize/dispose cloud service based on config change
    if (newConfig.cloudEnabled && !wasEnabled) {
      await _cloudService.initialize();
    } else if (!newConfig.cloudEnabled && wasEnabled) {
      _cloudService.dispose();
    }
    
    // Save to storage
    await StorageService.instance.setHybridModeEnabled(newConfig.cloudEnabled);
  }
  
  /// Enable cloud processing
  Future<void> enableCloud() async {
    await updateConfig(HybridRoutingConfig(
      localConfidenceThreshold: _config.localConfidenceThreshold,
      cloudEnabled: true,
      cloudTimeout: _config.cloudTimeout,
      localFirst: _config.localFirst,
      cloudRateLimit: _config.cloudRateLimit,
    ));
  }
  
  /// Disable cloud processing
  Future<void> disableCloud() async {
    await updateConfig(HybridRoutingConfig(
      localConfidenceThreshold: _config.localConfidenceThreshold,
      cloudEnabled: false,
      cloudTimeout: _config.cloudTimeout,
      localFirst: _config.localFirst,
      cloudRateLimit: _config.cloudRateLimit,
    ));
  }
  
  /// Get statistics
  Map<String, dynamic> getStatistics() {
    return {
      'config': {
        'cloudEnabled': _config.cloudEnabled,
        'localConfidenceThreshold': _config.localConfidenceThreshold,
        'cloudTimeout': _config.cloudTimeout,
        'cloudRateLimit': _config.cloudRateLimit,
      },
      'stats': _stats.toJson(),
      'recentCloudRequests': _cloudRequestTimes.length,
    };
  }
  
  /// Reset statistics
  void resetStatistics() {
    _logger.info('Resetting routing statistics');
    _stats.localRequests = 0;
    _stats.cloudRequests = 0;
    _stats.cloudSuccesses = 0;
    _stats.cloudFailures = 0;
    _stats.localFallbacks = 0;
    _cloudRequestTimes.clear();
  }
  
  /// Dispose resources
  void dispose() {
    _logger.info('Disposing hybrid router');
    _decisionController.close();
    _cloudService.dispose();
  }
}