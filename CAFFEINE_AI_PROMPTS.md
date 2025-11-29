# ☕ Caffeine.AI Build Prompts for SignBridge

Detailed prompts to build the SignBridge application using Caffeine.AI platform.

---

## 🎯 Project Overview

**Project Name**: SignBridge  
**Type**: Mobile Application (Flutter/Android)  
**Purpose**: Bidirectional sign language translation with on-device AI  
**Target Platform**: Android (API 24+)  
**AI Platform**: Cactus SDK (LFM2-VL, Qwen3, Whisper)

---

## 📋 Table of Contents

1. [Initial Project Setup](#initial-project-setup)
2. [Core Models Implementation](#core-models-implementation)
3. [Services Layer](#services-layer)
4. [Features Implementation](#features-implementation)
5. [UI Layer](#ui-layer)
6. [Testing Implementation](#testing-implementation)
7. [Integration & Polish](#integration--polish)

---

## Initial Project Setup

### Prompt 1: Create Flutter Project Structure

```
Create a new Flutter project called "SignBridge" with the following structure:

PROJECT REQUIREMENTS:
- Flutter SDK: 3.0+
- Target Platform: Android (minSdkVersion 24, targetSdkVersion 34)
- Architecture: Clean Architecture with feature-based organization
- State Management: Provider pattern

DIRECTORY STRUCTURE:
lib/
├── main.dart
├── config/
│   ├── app_config.dart
│   └── permissions_config.dart
├── core/
│   ├── models/
│   ├── services/
│   └── utils/
├── features/
│   ├── sign_recognition/
│   ├── speech_recognition/
│   ├── sign_animation/
│   ├── text_to_speech/
│   └── hybrid_routing/
├── ui/
│   ├── screens/
│   ├── widgets/
│   └── theme/
└── data/
    └── repositories/

DEPENDENCIES (pubspec.yaml):
dependencies:
  flutter:
    sdk: flutter
  cactus: ^0.1.0
  camera: ^0.10.5+9
  flutter_tts: ^3.8.5
  lottie: ^3.1.0
  provider: ^6.1.2
  permission_handler: ^11.3.1
  path_provider: ^2.1.3
  shared_preferences: ^2.2.3
  http: ^1.2.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.2
  mockito: ^5.4.4
  build_runner: ^2.4.9

ANDROID CONFIGURATION:
- Update android/app/build.gradle with minSdkVersion 24, targetSdkVersion 34
- Add camera, microphone, and storage permissions to AndroidManifest.xml
- Configure ProGuard rules for Cactus SDK
- Set up app icon and launcher configuration

OUTPUT:
- Complete project structure with all directories
- Configured pubspec.yaml with all dependencies
- Android configuration files properly set up
- Basic main.dart with MaterialApp setup
```

### Prompt 2: Configure App Settings and Theme

```
Implement the application configuration and theme system:

FILE: lib/config/app_config.dart
Create a configuration class with:
- Model paths for LFM2-VL-450M, Qwen3-0.6B, Whisper-Tiny
- Performance settings (camera FPS: 10, processing threads: 4)
- Confidence threshold: 0.75
- Hybrid mode settings (disabled by default, timeout: 2000ms)
- Animation durations (1500ms per sign, 500ms pause between words)

FILE: lib/config/permissions_config.dart
Create permissions configuration with:
- Required permissions: camera, microphone, storage
- Optional permissions: internet
- Permission request handling logic

FILE: lib/ui/theme/app_theme.dart
Implement Material Design 3 theme with:
- Primary color: #007bff (blue)
- Secondary color: #6c757d (gray)
- Success: #28a745, Warning: #ffc107, Error: #dc3545
- Light and dark theme variants
- Typography using Roboto font family
- Consistent spacing (8dp grid system)
- Rounded corners (8dp radius)

OUTPUT:
- AppConfig class with all constants
- PermissionsConfig with permission lists
- AppTheme with light and dark themes
- Proper color schemes and text styles
```

---

## Core Models Implementation

### Prompt 3: Create Data Models

```
Implement all core data models for the SignBridge application:

FILE: lib/core/models/point_3d.dart
Create Point3D class with:
- Properties: x, y, z (double)
- Methods: magnitude, operator-, operator/, distanceTo
- JSON serialization/deserialization

FILE: lib/core/models/hand_landmarks.dart
Create HandLandmarks class with:
- Properties: points (List<Point3D>, 21 landmarks), timestamp, confidence
- Named accessors: wrist, thumbTip, indexTip, middleTip, ringTip, pinkyTip
- Methods: normalize() for scale/rotation invariance, toFeatureVector()
- JSON serialization/deserialization

FILE: lib/core/models/sign_gesture.dart
Create SignGesture class with:
- Properties: letter, confidence, timestamp, landmarks, processingTime
- Getters: isHighConfidence (>0.75), isLowConfidence (<0.5)
- JSON serialization/deserialization

FILE: lib/core/models/recognition_result.dart
Create RecognitionResult class with:
- Enum ProcessingSource: local, cloud, localFallback
- Properties: text, confidence, source, latencyMs, metadata
- Method: copyWith() for immutable updates
- JSON serialization/deserialization

FILE: lib/core/models/sign_animation.dart
Create SignAnimation class with:
- Enum SignType: word, letter, phrase
- Properties: path, duration, type, metadata
- Methods: load(), play()
- JSON serialization/deserialization

FILE: lib/core/models/translation_mode.dart
Create TranslationMode enum:
- Values: signToSpeech, speechToSign

FILE: lib/core/models/performance_metrics.dart
Create PerformanceMetrics class with:
- Properties: operation, duration, source, timestamp, success
- JSON serialization/deserialization

OUTPUT:
- All model classes with proper encapsulation
- Complete JSON serialization support
- Immutable data structures where appropriate
- Comprehensive documentation comments
```

### Prompt 4: Create Utility Classes

```
Implement utility classes for logging, performance monitoring, and error handling:

FILE: lib/core/utils/logger.dart
Create Logger class with:
- Singleton pattern
- Methods: debug(), info(), warning(), error()
- Log levels: DEBUG, INFO, WARNING, ERROR
- Conditional logging (disabled in release builds)
- Timestamp formatting
- File and console output support

FILE: lib/core/utils/performance_monitor.dart
Create PerformanceMonitor class with:
- Singleton pattern
- Method: recordLatency(operation, duration, source)
- Method: getStats() returning Map with averages, counts, distributions
- Properties: _measurements list with max size limit
- Statistics calculation: average, min, max, percentiles
- Memory-efficient circular buffer

FILE: lib/core/utils/error_handler.dart
Create ErrorHandler class with:
- Enum ErrorContext: signRecognition, speechRecognition, camera, model, network
- Static method: handleError(exception, context)
- Error recovery strategies per context
- User-friendly error messages
- Logging integration
- Retry logic for transient errors

OUTPUT:
- Logger with proper log levels and formatting
- PerformanceMonitor with statistics tracking
- ErrorHandler with context-aware error handling
- All classes properly documented
```

---

## Services Layer

### Prompt 5: Implement Core Services

```
Implement the core service layer for AI model management and camera handling:

FILE: lib/core/services/cactus_model_service.dart
Create CactusModelService class with:
- Singleton pattern
- Properties: visionModel (CactusLM), textModel (CactusLM), speechModel (CactusSTT)
- Method: initialize() - downloads and initializes all models
- Method: downloadModels(onProgress) - with progress callbacks
- Method: areModelsReady() - checks if all models are initialized
- Method: getModelInfo() - returns model details and sizes
- Configuration: GPU enabled for vision model, 4 threads
- Error handling for download failures and initialization errors

FILE: lib/core/services/camera_service.dart
Create CameraService class with:
- Property: _controller (CameraController)
- Method: initialize() - sets up camera with high resolution
- Method: startStreaming() - begins image stream at 10 FPS
- Method: stopStreaming() - stops image stream
- Property: frameStream - Stream<CameraImage> for frame processing
- Method: dispose() - cleanup resources
- Error handling for camera permissions and initialization

FILE: lib/core/services/permission_service.dart
Create PermissionService class with:
- Static method: requestAllPermissions() - requests camera, mic, storage
- Static method: checkPermission(permission) - checks single permission
- Static method: openSettings() - opens app settings
- Proper error handling and user feedback
- Permission rationale dialogs

FILE: lib/core/services/storage_service.dart
Create StorageService class with:
- Method: saveSettings(key, value) - saves to SharedPreferences
- Method: loadSettings(key) - loads from SharedPreferences
- Method: getModelDirectory() - returns path for model storage
- Method: getCacheDirectory() - returns cache path
- Method: clearCache() - clears temporary files

OUTPUT:
- CactusModelService with complete model management
- CameraService with frame streaming
- PermissionService with all permission handling
- StorageService for data persistence
- Proper error handling and logging in all services
```

### Prompt 6: Implement Sign Recognition Pipeline

```
Implement the complete sign recognition pipeline:

FILE: lib/features/sign_recognition/hand_landmark_detector.dart
Create HandLandmarkDetector class with:
- Property: _visionModel (from CactusModelService)
- Method: detectLandmarks(CameraImage) - returns HandLandmarks or null
- Image preprocessing: YUV to RGB, resize to 224x224, normalize
- Confidence threshold: 0.5 for hand detection
- Error handling for model inference failures

FILE: lib/features/sign_recognition/gesture_classifier.dart
Create GestureClassifier class with:
- Property: _signDatabase (Map<String, List<double>>) - 36 ASL signs (A-Z, 0-9)
- Method: classify(HandLandmarks) - returns SignGesture
- Method: _normalize(landmarks) - normalizes to scale/rotation invariant
- Method: _cosineSimilarity(a, b) - calculates similarity score
- Returns best match if confidence > 0.75
- Caching for performance optimization

FILE: lib/features/sign_recognition/asl_database.dart
Create ASLDatabase class with:
- Static property: signs (Map<String, List<double>>)
- Pre-computed normalized landmark vectors for all 36 signs
- Each sign has 63 values (21 landmarks × 3 coordinates)
- Documentation for each sign pattern

FILE: lib/features/sign_recognition/sign_to_text_converter.dart
Create SignToTextConverter class with:
- Property: _buffer (List<String>) - last 5 recognized letters
- Property: _currentWord (String)
- Method: convertToText(letter) - adds letter to word
- Method: _checkStability() - requires 4/5 frames agreement
- Method: detectWordEnd() - detects 2-second pause
- Method: clearWord() - resets current word
- Method: predictNextLetter(word) - optional text prediction

FILE: lib/features/sign_recognition/sign_recognition_service.dart
Create SignRecognitionService class extending ChangeNotifier with:
- Properties: _isProcessing, _recognizedText, _confidence, _currentLandmarks
- Dependencies: CameraService, HandLandmarkDetector, GestureClassifier, SignToTextConverter, TTSService
- Method: startRecognition() - initializes camera and starts processing
- Method: stopRecognition() - stops camera and processing
- Method: _processFrame(CameraImage) - complete processing pipeline
- Method: clearText() - resets recognized text
- Notifies listeners on state changes
- Performance monitoring integration
- Error handling throughout pipeline

OUTPUT:
- Complete sign recognition pipeline
- Hand landmark detection with LFM2-VL
- Gesture classification with cosine similarity
- ASL database with all 36 signs
- Text conversion with stability filtering
- Service orchestration with state management
```

---

## Features Implementation

### Prompt 7: Implement Speech Recognition and TTS

```
Implement speech recognition and text-to-speech features:

FILE: lib/features/speech_recognition/speech_recognition_service.dart
Create SpeechRecognitionService class extending ChangeNotifier with:
- Property: _whisper (CactusSTT from CactusModelService)
- Property: _isListening (bool)
- Property: _transcribedText (String)
- Method: startListening() - begins audio capture and transcription
- Method: stopListening() - stops audio capture
- Method: clearTranscription() - resets text
- Integration with Whisper-Tiny model
- Real-time transcription updates
- Error handling for audio permissions and model failures
- Notifies listeners on state changes

FILE: lib/features/text_to_speech/tts_service.dart
Create TTSService class with:
- Property: _tts (FlutterTts instance)
- Method: initialize() - configures TTS settings
- Method: speakLetter(letter) - speaks single letter
- Method: speakWord(word) - speaks complete word
- Method: speakText(text) - speaks any text
- Method: stop() - stops current speech
- Method: setSpeed(speed) - adjusts speech rate
- Method: setVolume(volume) - adjusts volume
- Configuration: language (en-US), pitch (1.0), rate (0.5)
- Error handling for TTS failures

OUTPUT:
- SpeechRecognitionService with Whisper integration
- TTSService with Flutter TTS
- Proper state management
- Error handling and logging
```

### Prompt 8: Implement Sign Animation System

```
Implement the sign animation display system:

FILE: lib/data/repositories/sign_dictionary_repository.dart
Create SignDictionaryRepository class with:
- Static property: _wordSigns (Map<String, SignAnimation>) - 200+ common words
- Static property: _letterSigns (Map<String, SignAnimation>) - 26 letters
- Method: getWordSign(word) - returns animation for word or null
- Method: fingerspellWord(word) - returns list of letter animations
- Method: hasSign(word) - checks if word has animation
- Priority categories: greetings (10), courtesy (15), questions (20), verbs (30), nouns (40), emotions (15), numbers (20), time (10), directions (10), family (10)
- Animation paths: assets/animations/words/ and assets/animations/letters/

FILE: lib/features/sign_animation/sign_animation_service.dart
Create SignAnimationService class extending ChangeNotifier with:
- Property: _repository (SignDictionaryRepository)
- Property: _currentAnimation (String?)
- Property: _isAnimating (bool)
- Property: _queue (List<SignAnimation>)
- Method: displaySignsForText(text) - converts text to animation sequence
- Method: _playAnimation(path) - plays single animation
- Method: pause() - pauses current animation
- Method: resume() - resumes animation
- Method: stop() - stops and clears queue
- Method: skipToNext() - skips to next animation
- Method: skipToPrevious() - goes to previous animation
- Timing: 1500ms per sign, 500ms pause between words
- Notifies listeners on animation changes

FILE: lib/ui/widgets/sign_animation_widget.dart
Create SignAnimationWidget class extending StatefulWidget with:
- Property: animationPath (String)
- Property: onComplete (VoidCallback?)
- Uses Lottie package for animation rendering
- Auto-play on load
- Smooth transitions between animations
- Loading indicator while animation loads
- Error handling for missing animations

OUTPUT:
- SignDictionaryRepository with 200+ word mappings
- SignAnimationService with queue management
- SignAnimationWidget with Lottie rendering
- Complete animation playback system
```

### Prompt 9: Implement Hybrid Routing System

```
Implement the hybrid routing system for local/cloud processing:

FILE: lib/features/hybrid_routing/confidence_scorer.dart
Create ConfidenceScorer class with:
- Method: scoreResult(RecognitionResult) - evaluates confidence
- Method: shouldUseCloud(confidence) - returns bool (threshold: 0.75)
- Method: adjustThreshold(accuracy) - dynamic threshold adjustment
- Considers: recognition confidence, temporal stability, historical accuracy

FILE: lib/features/hybrid_routing/cloud_fallback_service.dart
Create CloudFallbackService class with:
- Property: _httpClient (http.Client)
- Property: _apiEndpoint (String, configurable)
- Method: recognizeGesture(HandLandmarks) - sends to cloud API
- Method: _buildRequest(landmarks) - creates HTTP request
- Method: _parseResponse(response) - parses cloud response
- Timeout: 2 seconds
- HTTPS/TLS 1.3 encryption
- Error handling for network failures
- Retry logic with exponential backoff

FILE: lib/features/hybrid_routing/hybrid_router.dart
Create HybridRouter class with:
- Property: LOCAL_CONFIDENCE_THRESHOLD (0.75)
- Property: _cloudEnabled (bool, from settings)
- Property: _confidenceScorer (ConfidenceScorer)
- Property: _cloudService (CloudFallbackService)
- Method: processGesture(HandLandmarks) - main routing logic
- Method: _processLocal(landmarks) - local processing
- Method: _processCloud(landmarks) - cloud processing with timeout
- Method: _shouldUseLocal(result) - decision logic
- Fallback: always use local if cloud fails
- Metrics tracking: local count, cloud count, fallback count
- Privacy: user-controlled cloud usage

OUTPUT:
- ConfidenceScorer with threshold logic
- CloudFallbackService with API integration
- HybridRouter with intelligent routing
- Complete fallback mechanism
- Privacy-preserving design
```

---

## UI Layer

### Prompt 10: Implement Main Screens

```
Implement the main application screens:

FILE: lib/ui/screens/home_screen.dart
Create HomeScreen class extending StatelessWidget with:
- AppBar with title "SignBridge" and settings icon
- Two main mode cards:
  1. Sign-to-Speech card with camera icon and description
  2. Speech-to-Sign card with microphone icon and description
- Today's stats section showing: translations count, accuracy, local processing %
- Navigation to respective mode screens on tap
- Tutorial and About buttons at bottom
- Material Design 3 styling
- Responsive layout

FILE: lib/ui/screens/sign_to_speech_screen.dart
Create SignToSpeechScreen class extending StatefulWidget with:
- AppBar with back button and menu
- Camera preview widget (full width, 16:9 aspect ratio)
- Recognized text display with large, readable font
- Confidence indicator (progress bar with percentage)
- Processing source indicator (Local/Cloud)
- Latency display
- Control buttons: Start, Stop, Clear
- Status indicator (Recognizing/Stopped)
- Hand landmarks overlay (optional, for debugging)
- Real-time updates using Provider
- Error handling with user-friendly messages

FILE: lib/ui/screens/speech_to_sign_screen.dart
Create SpeechToSignScreen class extending StatefulWidget with:
- AppBar with back button and menu
- Listening indicator with audio waveform visualization
- Transcription display showing recognized text
- Sign animation widget (centered, large)
- Animation progress indicator (current/total)
- Control buttons: Start/Stop listening, Previous, Next, Replay
- Playback controls: Pause, Speed adjustment (0.5x, 1x, 1.5x, 2x)
- Real-time updates using Provider
- Error handling with user-friendly messages

FILE: lib/ui/screens/settings_screen.dart
Create SettingsScreen class extending StatefulWidget with:
- AppBar with back button
- Sections:
  1. AI Models: Download status, manage models button, total size
  2. Hybrid Mode: Toggle switch, warning about cloud usage
  3. Performance: Camera FPS slider, threads selector, confidence threshold slider
  4. Appearance: Theme selector (Auto/Light/Dark), animation speed, performance overlay toggle
  5. Privacy: Privacy dashboard link, clear cache button, data collection toggle
  6. About: Version, tutorial, licenses, feedback
- Settings persistence using StorageService
- Real-time updates

OUTPUT:
- HomeScreen with navigation
- SignToSpeechScreen with camera and recognition
- SpeechToSignScreen with audio and animation
- SettingsScreen with all configurations
- Proper state management with Provider
- Material Design 3 styling throughout
```

### Prompt 11: Implement UI Widgets

```
Implement reusable UI widgets:

FILE: lib/ui/widgets/camera_preview_widget.dart
Create CameraPreviewWidget class extending StatefulWidget with:
- Property: controller (CameraController)
- Property: showLandmarks (bool, default: false)
- Displays camera preview with proper aspect ratio
- Optional hand landmarks overlay
- Loading indicator while initializing
- Error state display
- Proper disposal of resources

FILE: lib/ui/widgets/confidence_indicator.dart
Create ConfidenceIndicator class extending StatelessWidget with:
- Property: confidence (double, 0.0 to 1.0)
- Property: threshold (double, default: 0.75)
- Linear progress indicator with color coding:
  - Red: < 0.5 (low confidence)
  - Orange: 0.5 - 0.75 (medium confidence)
  - Green: > 0.75 (high confidence)
- Percentage text display
- Animated transitions

FILE: lib/ui/widgets/transcription_display.dart
Create TranscriptionDisplay class extending StatelessWidget with:
- Property: text (String)
- Property: isListening (bool)
- Large, readable text display
- Listening indicator (animated microphone icon)
- Auto-scroll for long text
- Copy to clipboard button
- Clear button

FILE: lib/ui/widgets/mode_toggle_button.dart
Create ModeToggleButton class extending StatelessWidget with:
- Property: title (String)
- Property: icon (IconData)
- Property: description (String)
- Property: onTap (VoidCallback)
- Card-based design with elevation
- Icon, title, and description layout
- Tap animation
- Accessibility labels

OUTPUT:
- CameraPreviewWidget with landmarks overlay
- ConfidenceIndicator with color coding
- TranscriptionDisplay with controls
- ModeToggleButton for navigation
- All widgets properly documented
- Accessibility support
```

---

## Testing Implementation

### Prompt 12: Implement Unit Tests

```
Implement comprehensive unit tests:

FILE: test/unit/gesture_classifier_test.dart
Create unit tests for GestureClassifier:
- Test: classify() returns high confidence for perfect match
- Test: classify() returns low confidence for ambiguous gesture
- Test: classify() handles invalid landmarks gracefully
- Test: normalize() produces scale-invariant features
- Test: _cosineSimilarity() calculates correctly
- Use mock data for landmarks
- Verify confidence thresholds
- Test edge cases

FILE: test/unit/sign_recognition_service_test.dart
Create unit tests for SignRecognitionService:
- Test: startRecognition() initializes camera
- Test: stopRecognition() releases resources
- Test: _processFrame() updates recognized text
- Test: clearText() resets state
- Test: notifyListeners() called on state changes
- Mock dependencies: CameraService, GestureClassifier, TTSService
- Verify state transitions
- Test error handling

FILE: test/unit/performance_monitor_test.dart
Create unit tests for PerformanceMonitor:
- Test: recordLatency() stores measurements
- Test: getStats() calculates correct averages
- Test: circular buffer maintains size limit
- Test: statistics calculation (min, max, percentiles)
- Verify memory efficiency

FILE: test/helpers/test_data.dart
Create test data helpers:
- Function: createValidLandmarks() - returns test HandLandmarks
- Function: createGesture(letter) - returns test SignGesture
- Function: createTestFrame() - returns mock CameraImage
- Constant: TEST_LANDMARKS_A through TEST_LANDMARKS_Z
- Utility functions for test data generation

OUTPUT:
- Comprehensive unit tests for core classes
- Test coverage > 80%
- Mock objects for dependencies
- Test helpers for data generation
- Clear test names and documentation
```

### Prompt 13: Implement Integration Tests

```
Implement integration tests for complete workflows:

FILE: test/integration/sign_to_speech_integration_test.dart
Create integration test for sign-to-speech pipeline:
- Test: complete recognition flow from frame to speech
- Test: rapid gesture changes produce correct text
- Test: stability filtering works correctly
- Test: TTS speaks recognized text
- Test: performance metrics recorded
- Use real services (not mocked)
- Verify end-to-end latency < 500ms
- Test error recovery

FILE: test/integration/speech_to_sign_integration_test.dart
Create integration test for speech-to-sign pipeline:
- Test: complete flow from speech to animation
- Test: word lookup and fingerspelling fallback
- Test: animation queue management
- Test: playback controls work correctly
- Use real services
- Verify end-to-end latency < 1000ms

FILE: test/integration/hybrid_routing_test.dart
Create integration test for hybrid routing:
- Test: high confidence uses local processing
- Test: low confidence triggers cloud (if enabled)
- Test: cloud timeout falls back to local
- Test: metrics tracked correctly
- Mock cloud API responses
- Verify decision logic

OUTPUT:
- Integration tests for all major workflows
- Real service integration
- Performance validation
- Error handling verification
```

---

## Integration & Polish

### Prompt 14: Final Integration and Polish

```
Complete the final integration and polish:

TASKS:
1. Main App Integration:
   - Update lib/main.dart with complete app initialization
   - Set up Provider for all services
   - Initialize CactusModelService on startup
   - Request permissions before showing home screen
   - Show loading screen during model download
   - Handle initialization errors gracefully

2. Navigation Setup:
   - Implement proper navigation between screens
   - Handle back button correctly
   - Preserve state during navigation
   - Add transition animations

3. Error Handling:
   - Global error boundary
   - User-friendly error messages
   - Retry mechanisms
   - Graceful degradation

4. Performance Optimization:
   - Lazy loading of heavy resources
   - Image caching
   - Animation preloading
   - Memory management

5. Accessibility:
   - Semantic labels for all interactive elements
   - Screen reader support
   - High contrast mode
   - Font scaling support
   - Touch target sizes ≥ 48dp

6. Localization (Optional):
   - English language support
   - Prepare for future translations
   - Externalize all strings

7. Analytics & Monitoring:
   - Performance metrics collection
   - Error logging
   - Usage statistics (privacy-preserving)
   - Crash reporting setup

8. Final Testing:
   - Run all unit tests
   - Run all integration tests
   - Manual testing on multiple devices
   - Performance profiling
   - Memory leak detection

9. Documentation:
   - Code documentation (dartdoc comments)
   - README with setup instructions
   - API documentation
   - User guide

10. Build Configuration:
    - Release build configuration
    - ProGuard rules
    - App signing setup
    - APK optimization

OUTPUT:
- Fully integrated application
- All features working together
- Proper error handling throughout
- Optimized performance
- Accessibility support
- Complete documentation
- Release-ready build
```

---

## 🎯 Build Sequence

### Recommended Order

1. **Phase 1: Foundation** (Prompts 1-4)
   - Project setup
   - Configuration
   - Core models
   - Utilities

2. **Phase 2: Services** (Prompts 5-6)
   - Core services
   - Sign recognition pipeline

3. **Phase 3: Features** (Prompts 7-9)
   - Speech recognition
   - TTS
   - Sign animation
   - Hybrid routing

4. **Phase 4: UI** (Prompts 10-11)
   - Main screens
   - Reusable widgets

5. **Phase 5: Testing** (Prompts 12-13)
   - Unit tests
   - Integration tests

6. **Phase 6: Polish** (Prompt 14)
   - Final integration
   - Optimization
   - Documentation

---

## 📝 Additional Notes

### For Each Prompt:

1. **Copy the entire prompt** to Caffeine.AI
2. **Review the generated code** carefully
3. **Test the implementation** before moving to next prompt
4. **Fix any issues** before proceeding
5. **Commit changes** to version control

### Important Considerations:

- **Cactus SDK**: Ensure you have access to Cactus SDK and API keys
- **Model Downloads**: First run will download ~1.1GB of AI models
- **Testing**: Test on real Android devices, not just emulators
- **Performance**: Monitor memory usage and battery drain
- **Privacy**: Ensure no sensitive data is logged or transmitted

### Troubleshooting:

If Caffeine.AI generates incomplete code:
- Break the prompt into smaller parts
- Request specific files one at a time
- Provide more context about dependencies
- Reference existing code structure

---

## 🚀 Success Criteria

Your SignBridge app is complete when:

- ✅ All 14 prompts successfully executed
- ✅ App builds without errors
- ✅ All tests passing (>80% coverage)
- ✅ Sign-to-speech works with <500ms latency
- ✅ Speech-to-sign works with <1000ms latency
- ✅ UI is responsive and polished
- ✅ Error handling is robust
- ✅ Performance meets targets
- ✅ Accessibility features work
- ✅ Documentation is complete

---

## 📚 Resources

- **Flutter Documentation**: https://flutter.dev/docs
- **Cactus SDK**: https://cactus.ai/docs
- **Material Design 3**: https://m3.material.io
- **Provider Package**: https://pub.dev/packages/provider
- **Camera Package**: https://pub.dev/packages/camera
- **Lottie Package**: https://pub.dev/packages/lottie

---

**Version**: 1.0.0  
**Last Updated**: 2025-11-26  
**Platform**: Caffeine.AI  
**Target**: SignBridge Mobile App