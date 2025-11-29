/// Application-wide configuration constants
class AppConfig {
  // Prevent instantiation
  AppConfig._();
  
  // ============================================================================
  // MODEL CONFIGURATION
  // ============================================================================
  
  /// Path to vision model (LFM2-VL-450M)
  static const String visionModelName = 'lfm2-vl-450m';
  
  /// Path to text model (Qwen3-0.6B)
  static const String textModelName = 'qwen3-0.6';
  
  /// Path to speech model (Whisper-Tiny)
  static const String speechModelName = 'whisper-tiny';
  
  // ============================================================================
  // PERFORMANCE SETTINGS
  // ============================================================================
  
  /// Camera frame processing rate (frames per second)
  static const int cameraFPS = 10;
  
  /// Number of processing threads for AI models
  static const int processingThreads = 4;
  
  /// Confidence threshold for accepting local recognition results
  static const double confidenceThreshold = 0.75;
  
  /// Low confidence threshold (triggers hybrid routing if enabled)
  static const double lowConfidenceThreshold = 0.5;
  
  /// Number of frames to buffer for gesture stability
  static const int gestureBufferSize = 5;
  
  /// Minimum number of matching frames required for stable gesture
  static const int minMatchingFrames = 4;
  
  // ============================================================================
  // HYBRID ROUTING CONFIGURATION
  // ============================================================================
  
  /// Enable hybrid mode by default (can be toggled in settings)
  static const bool hybridModeEnabledByDefault = false;
  
  /// Maximum time to wait for cloud response (milliseconds)
  static const int cloudTimeoutMs = 2000;
  
  /// Cloud API endpoint (configure based on your cloud service)
  static const String cloudApiEndpoint = 'https://api.example.com/recognize';
  
  // ============================================================================
  // UI SETTINGS
  // ============================================================================
  
  /// Duration for sign animations
  static const Duration animationDuration = Duration(milliseconds: 1500);
  
  /// Pause duration between words in sign animation
  static const Duration wordPauseDuration = Duration(milliseconds: 500);
  
  /// Pause duration between letters in fingerspelling
  static const Duration letterPauseDuration = Duration(milliseconds: 300);
  
  /// Show debug overlays (hand landmarks, confidence scores)
  static const bool showDebugOverlays = false;
  
  // ============================================================================
  // TEXT-TO-SPEECH SETTINGS
  // ============================================================================
  
  /// TTS language
  static const String ttsLanguage = 'en-US';
  
  /// TTS speech rate (0.0 - 1.0, where 0.5 is normal)
  static const double ttsSpeechRate = 0.5;
  
  /// TTS volume (0.0 - 1.0)
  static const double ttsVolume = 1.0;
  
  /// TTS pitch (0.5 - 2.0, where 1.0 is normal)
  static const double ttsPitch = 1.0;
  
  // ============================================================================
  // CAMERA SETTINGS
  // ============================================================================
  
  /// Camera resolution preset
  static const String cameraResolution = 'high'; // low, medium, high, veryHigh
  
  /// Enable audio for camera (should be false for sign-to-speech mode)
  static const bool cameraEnableAudio = false;
  
  // ============================================================================
  // STORAGE SETTINGS
  // ============================================================================
  
  /// Maximum size for model cache (bytes)
  static const int maxModelCacheSize = 1024 * 1024 * 1024; // 1GB
  
  /// Maximum number of performance measurements to keep
  static const int maxPerformanceMeasurements = 100;
  
  // ============================================================================
  // ASL DATABASE
  // ============================================================================
  
  /// Number of hand landmarks (MediaPipe standard)
  static const int numHandLandmarks = 21;
  
  /// Number of ASL letters
  static const int numASLLetters = 26;
  
  /// Number of ASL numbers
  static const int numASLNumbers = 10;
  
  /// Total number of basic ASL signs
  static const int totalBasicSigns = numASLLetters + numASLNumbers; // 36
  
  // ============================================================================
  // APP METADATA
  // ============================================================================
  
  /// App version
  static const String appVersion = '1.0.0';
  
  /// App build number
  static const int appBuildNumber = 1;
  
  /// App name
  static const String appName = 'SignBridge';
  
  /// App description
  static const String appDescription = 
      'Bidirectional sign language translator with on-device AI';
  
  // ============================================================================
  // FEATURE FLAGS
  // ============================================================================
  
  /// Enable performance monitoring
  static const bool enablePerformanceMonitoring = true;
  
  /// Enable error reporting
  static const bool enableErrorReporting = true;
  
  /// Enable analytics (local only, no external services)
  static const bool enableAnalytics = true;
  
  /// Enable tutorial on first launch
  static const bool enableTutorial = true;
}