/// Source of recognition processing
enum ProcessingSource {
  /// Processed locally on device
  local,
  
  /// Processed via cloud API
  cloud,
  
  /// Cloud processing failed, fell back to local
  localFallback,
}

/// Result of sign recognition with metadata
class RecognitionResult {
  final String? text;
  final double confidence;
  final ProcessingSource source;
  final int latencyMs;
  final Map<String, dynamic>? metadata;
  
  RecognitionResult({
    required this.text,
    required this.confidence,
    required this.source,
    required this.latencyMs,
    this.metadata,
  });
  
  /// Check if recognition was successful
  bool get isSuccess => text != null && text!.isNotEmpty;
  
  /// Check if processed locally
  bool get isLocal => source == ProcessingSource.local;
  
  /// Check if processed via cloud
  bool get isCloud => source == ProcessingSource.cloud;
  
  /// Check if fell back to local
  bool get isFallback => source == ProcessingSource.localFallback;
  
  /// Get source as human-readable string
  String get sourceString {
    switch (source) {
      case ProcessingSource.local:
        return 'Local';
      case ProcessingSource.cloud:
        return 'Cloud';
      case ProcessingSource.localFallback:
        return 'Local (Fallback)';
    }
  }
  
  /// Get confidence as percentage
  String get confidencePercentage => 
      '${(confidence * 100).toStringAsFixed(1)}%';
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'confidence': confidence,
      'source': source.name,
      'latencyMs': latencyMs,
      'metadata': metadata,
    };
  }
  
  /// Create from JSON
  factory RecognitionResult.fromJson(Map<String, dynamic> json) {
    return RecognitionResult(
      text: json['text'] as String?,
      confidence: (json['confidence'] as num).toDouble(),
      source: ProcessingSource.values.firstWhere(
        (e) => e.name == json['source'],
        orElse: () => ProcessingSource.local,
      ),
      latencyMs: json['latencyMs'] as int,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
  
  @override
  String toString() {
    return 'RecognitionResult(text: $text, '
           'confidence: $confidencePercentage, '
           'source: $sourceString, '
           'latency: ${latencyMs}ms)';
  }
  
  /// Create a copy with modified fields
  RecognitionResult copyWith({
    String? text,
    double? confidence,
    ProcessingSource? source,
    int? latencyMs,
    Map<String, dynamic>? metadata,
  }) {
    return RecognitionResult(
      text: text ?? this.text,
      confidence: confidence ?? this.confidence,
      source: source ?? this.source,
      latencyMs: latencyMs ?? this.latencyMs,
      metadata: metadata ?? this.metadata,
    );
  }
}