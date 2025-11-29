# SignBridge API Reference

Complete API documentation for all services, models, and utilities in the SignBridge application.

---

## Table of Contents

1. [Core Services](#core-services)
2. [Models](#models)
3. [Recognition Services](#recognition-services)
4. [UI Components](#ui-components)
5. [Utilities](#utilities)

---

## Core Services

### CactusModelService

Manages AI model lifecycle and provides access to vision, text, and speech models.

#### Methods

##### `initialize()`
Initializes all Cactus SDK models.

```dart
Future<void> initialize()
```

**Returns:** `Future<void>`

**Throws:** `ModelException` if initialization fails

**Example:**
```dart
await CactusModelService.instance.initialize();
```

##### `areModelsDownloaded()`
Checks if all required models are downloaded.

```dart
Future<bool> areModelsDownloaded()
```

**Returns:** `Future<bool>` - true if all models are downloaded

**Example:**
```dart
final downloaded = await CactusModelService.instance.areModelsDownloaded();
if (!downloaded) {
  await CactusModelService.instance.downloadModels();
}
```

##### `getModelInfo()`
Retrieves information about all models.

```dart
Future<Map<String, dynamic>> getModelInfo()
```

**Returns:** `Future<Map<String, dynamic>>` containing model metadata

**Example:**
```dart
final info = await CactusModelService.instance.getModelInfo();
print('Vision model: ${info['vision']['name']}');
```

##### `dispose()`
Releases all model resources.

```dart
void dispose()
```

**Example:**
```dart
CactusModelService.instance.dispose();
```

#### Properties

##### `visionModel`
Access to the vision model (LFM2-VL-450M).

```dart
dynamic get visionModel
```

**Throws:** `ModelException` if models not initialized

##### `textModel`
Access to the text model (Qwen3-0.6B).

```dart
dynamic get textModel
```

##### `speechModel`
Access to the speech model (Whisper-Tiny).

```dart
dynamic get speechModel
```

---

### CameraService

Manages camera access and frame capture.

#### Methods

##### `initialize()`
Initializes camera with specified resolution.

```dart
Future<void> initialize({
  ResolutionPreset resolution = ResolutionPreset.high,
})
```

**Parameters:**
- `resolution`: Camera resolution preset (default: high)

**Example:**
```dart
await CameraService.instance.initialize(
  resolution: ResolutionPreset.medium,
);
```

##### `startImageStream()`
Starts streaming camera frames.

```dart
void startImageStream(Function(CameraImage) onFrame)
```

**Parameters:**
- `onFrame`: Callback function receiving camera frames

**Example:**
```dart
CameraService.instance.startImageStream((image) {
  processFrame(image);
});
```

##### `stopImageStream()`
Stops the camera frame stream.

```dart
Future<void> stopImageStream()
```

##### `dispose()`
Releases camera resources.

```dart
Future<void> dispose()
```

#### Properties

##### `controller`
Access to the camera controller.

```dart
CameraController? get controller
```

##### `isInitialized`
Check if camera is initialized.

```dart
bool get isInitialized
```

---

### PermissionService

Handles app permissions for camera and microphone.

#### Methods

##### `requestCameraPermission()`
Requests camera permission from user.

```dart
static Future<bool> requestCameraPermission()
```

**Returns:** `Future<bool>` - true if permission granted

**Example:**
```dart
final granted = await PermissionService.requestCameraPermission();
if (!granted) {
  showPermissionDeniedDialog();
}
```

##### `requestMicrophonePermission()`
Requests microphone permission.

```dart
static Future<bool> requestMicrophonePermission()
```

##### `requestAllPermissions()`
Requests all required permissions.

```dart
static Future<Map<Permission, PermissionStatus>> requestAllPermissions()
```

**Returns:** Map of permissions and their status

**Example:**
```dart
final statuses = await PermissionService.requestAllPermissions();
if (statuses[Permission.camera] != PermissionStatus.granted) {
  // Handle denied permission
}
```

##### `checkPermissions()`
Checks current permission status.

```dart
static Future<Map<Permission, PermissionStatus>> checkPermissions()
```

---

## Models

### HandLandmarks

Represents 21 3D hand landmark points.

#### Constructor

```dart
HandLandmarks({
  required List<Point3D> points,
  required DateTime timestamp,
  double confidence = 1.0,
})
```

#### Properties

```dart
List<Point3D> points          // 21 landmark points
DateTime timestamp            // Capture timestamp
double confidence            // Detection confidence (0.0-1.0)
```

#### Methods

##### `normalize()`
Normalizes landmarks to be scale and translation invariant.

```dart
List<double> normalize()
```

**Returns:** Flattened normalized coordinates

**Example:**
```dart
final landmarks = HandLandmarks(points: detectedPoints, timestamp: DateTime.now());
final normalized = landmarks.normalize();
```

---

### SignGesture

Represents a recognized sign gesture.

#### Constructor

```dart
SignGesture({
  required String letter,
  required double confidence,
  required DateTime timestamp,
  required HandLandmarks landmarks,
})
```

#### Properties

```dart
String letter                 // Recognized letter/sign
double confidence            // Recognition confidence
DateTime timestamp           // Recognition time
HandLandmarks landmarks      // Hand landmark data
```

---

### RecognitionResult

Result of sign or speech recognition.

#### Constructor

```dart
RecognitionResult({
  String? text,
  required double confidence,
  required ProcessingSource source,
  required int latency,
})
```

#### Properties

```dart
String? text                 // Recognized text
double confidence           // Confidence score
ProcessingSource source     // local, cloud, or localFallback
int latency                // Processing time in milliseconds
```

---

### Point3D

3D point with vector operations.

#### Constructor

```dart
Point3D(double x, double y, double z)
```

#### Methods

##### `distanceTo()`
Calculates Euclidean distance to another point.

```dart
double distanceTo(Point3D other)
```

##### `normalize()`
Returns normalized vector.

```dart
Point3D normalize()
```

##### `dot()`
Calculates dot product with another vector.

```dart
double dot(Point3D other)
```

**Example:**
```dart
final p1 = Point3D(1.0, 2.0, 3.0);
final p2 = Point3D(4.0, 5.0, 6.0);
final distance = p1.distanceTo(p2);
final dotProduct = p1.dot(p2);
```

---

## Recognition Services

### SignRecognitionService

Orchestrates the sign-to-speech pipeline.

#### Methods

##### `startRecognition()`
Starts sign recognition from camera.

```dart
Future<void> startRecognition()
```

**Example:**
```dart
final service = SignRecognitionService();
await service.startRecognition();
```

##### `stopRecognition()`
Stops sign recognition.

```dart
Future<void> stopRecognition()
```

##### `clearText()`
Clears recognized text.

```dart
void clearText()
```

##### `getStatistics()`
Returns recognition statistics.

```dart
Map<String, dynamic> getStatistics()
```

**Returns:** Map containing:
- `totalFrames`: Total frames processed
- `recognitionCount`: Number of successful recognitions
- `averageLatency`: Average processing time
- `averageConfidence`: Average confidence score

#### Properties

```dart
bool isProcessing             // Currently processing frames
String recognizedText         // Current recognized text
double confidence            // Current confidence score
Stream<RecognitionResult> resultStream  // Recognition results stream
```

#### Events

Listen to recognition results:

```dart
service.resultStream.listen((result) {
  print('Recognized: ${result.text}');
  print('Confidence: ${result.confidence}');
});
```

---

### GestureClassifier

Classifies hand gestures using cosine similarity.

#### Methods

##### `classify()`
Classifies hand landmarks into a gesture.

```dart
Future<GestureResult> classify(HandLandmarks landmarks)
```

**Parameters:**
- `landmarks`: Hand landmark data

**Returns:** `GestureResult` with letter and confidence

**Example:**
```dart
final classifier = GestureClassifier();
final result = await classifier.classify(landmarks);
if (result.confidence > 0.75) {
  print('Recognized: ${result.letter}');
}
```

##### `normalizeLandmarks()`
Normalizes landmarks for comparison.

```dart
List<double> normalizeLandmarks(List<Point3D> points)
```

##### `cosineSimilarity()`
Calculates similarity between two vectors.

```dart
double cosineSimilarity(List<double> a, List<double> b)
```

**Returns:** Similarity score (0.0 to 1.0)

---

### SpeechRecognitionService

Handles speech-to-text conversion.

#### Methods

##### `startListening()`
Starts listening for speech input.

```dart
Future<void> startListening()
```

**Example:**
```dart
final service = SpeechRecognitionService();
await service.startListening();
```

##### `stopListening()`
Stops listening and finalizes transcription.

```dart
Future<void> stopListening()
```

#### Properties

```dart
bool isListening             // Currently listening
String transcribedText       // Transcribed text
double confidence           // Transcription confidence
List<String> wordsToSign    // Words to animate
```

---

### SignAnimationService

Manages sign language animation playback.

#### Methods

##### `displaySignsForText()`
Displays sign animations for given text.

```dart
Future<void> displaySignsForText(String text)
```

**Parameters:**
- `text`: Text to convert to sign animations

**Example:**
```dart
final service = SignAnimationService();
await service.displaySignsForText('Hello world');
```

##### `playAnimation()`
Plays a specific animation.

```dart
Future<void> playAnimation(String animationPath)
```

##### `stopAnimation()`
Stops current animation.

```dart
void stopAnimation()
```

##### `setPlaybackSpeed()`
Adjusts animation playback speed.

```dart
void setPlaybackSpeed(double speed)
```

**Parameters:**
- `speed`: Playback speed multiplier (0.5 = half speed, 2.0 = double speed)

#### Properties

```dart
String? currentAnimation     // Currently playing animation
bool isAnimating            // Animation in progress
double playbackSpeed        // Current playback speed
```

---

## UI Components

### ConfidenceIndicator

Displays recognition confidence as a colored progress bar.

#### Constructor

```dart
ConfidenceIndicator({
  required double confidence,
  bool showPercentage = true,
})
```

#### Properties

- `confidence`: Confidence value (0.0 to 1.0)
- `showPercentage`: Whether to show percentage text

#### Color Mapping

- **Green** (0.75-1.0): High confidence
- **Orange** (0.5-0.75): Medium confidence
- **Red** (0.0-0.5): Low confidence

**Example:**
```dart
ConfidenceIndicator(
  confidence: 0.85,
  showPercentage: true,
)
```

---

### TranscriptionDisplay

Displays transcribed text with word highlighting.

#### Constructor

```dart
TranscriptionDisplay({
  required String text,
  required bool isListening,
  int? currentWordIndex,
})
```

#### Properties

- `text`: Text to display
- `isListening`: Show listening indicator
- `currentWordIndex`: Index of currently highlighted word

**Example:**
```dart
TranscriptionDisplay(
  text: 'Hello world',
  isListening: false,
  currentWordIndex: 1,  // Highlights 'world'
)
```

---

### SignAnimationWidget

Displays Lottie sign language animations.

#### Constructor

```dart
SignAnimationWidget({
  String? animationPath,
  double width = 300,
  double height = 300,
})
```

**Example:**
```dart
SignAnimationWidget(
  animationPath: 'assets/animations/words/hello.json',
  width: 400,
  height: 400,
)
```

---

## Utilities

### Logger

Centralized logging utility.

#### Methods

##### `debug()`
Logs debug messages.

```dart
static void debug(String message, [String? tag])
```

##### `info()`
Logs informational messages.

```dart
static void info(String message, [String? tag])
```

##### `warning()`
Logs warnings.

```dart
static void warning(String message, [String? tag])
```

##### `error()`
Logs errors with stack traces.

```dart
static void error(dynamic error, [StackTrace? stackTrace, String? tag])
```

**Example:**
```dart
Logger.info('Starting recognition', 'SIGN_RECOGNITION');
Logger.error(exception, stackTrace, 'MODEL_LOADING');
```

---

### PerformanceMonitor

Tracks and reports performance metrics.

#### Methods

##### `recordLatency()`
Records operation latency.

```dart
void recordLatency({
  required String operation,
  required Duration duration,
  required ProcessingSource source,
})
```

**Example:**
```dart
final stopwatch = Stopwatch()..start();
await processFrame(image);
stopwatch.stop();

PerformanceMonitor.instance.recordLatency(
  operation: 'frame_processing',
  duration: stopwatch.elapsed,
  source: ProcessingSource.local,
);
```

##### `getStats()`
Retrieves performance statistics.

```dart
Map<String, dynamic> getStats()
```

**Returns:** Statistics including:
- `avgLocalLatency`: Average local processing time
- `avgCloudLatency`: Average cloud processing time
- `localCount`: Number of local operations
- `cloudCount`: Number of cloud operations

---

### ErrorHandler

Centralized error handling.

#### Methods

##### `handleError()`
Handles and logs errors.

```dart
static Future<void> handleError(
  Exception error,
  ErrorContext context, {
  StackTrace? stackTrace,
  Map<String, dynamic>? metadata,
})
```

**Parameters:**
- `error`: The exception to handle
- `context`: Error context (modelLoading, recognition, etc.)
- `stackTrace`: Optional stack trace
- `metadata`: Additional error information

**Example:**
```dart
try {
  await riskyOperation();
} catch (e, stackTrace) {
  await ErrorHandler.handleError(
    e as Exception,
    ErrorContext.recognition,
    stackTrace: stackTrace,
    metadata: {'frame': frameNumber},
  );
}
```

---

## Constants

### AppConfig

Application-wide configuration constants.

```dart
class AppConfig {
  // Model names
  static const String visionModelName = 'lfm2-vl-450m';
  static const String textModelName = 'qwen3-0.6';
  static const String speechModelName = 'whisper-tiny';
  
  // Processing settings
  static const int targetFPS = 10;
  static const int processingThreads = 4;
  static const int targetImageWidth = 224;
  static const int targetImageHeight = 224;
  
  // Recognition thresholds
  static const double confidenceThreshold = 0.75;
  static const int temporalBufferSize = 5;
  static const int stabilityThreshold = 4;
  
  // Animation settings
  static const int defaultAnimationDuration = 1500;
  static const double defaultPlaybackSpeed = 1.0;
}
```

---

## Error Types

### ModelException

Thrown when model operations fail.

```dart
class ModelException implements Exception {
  final String message;
  ModelException(this.message);
}
```

### CameraException

Thrown when camera operations fail.

```dart
class CameraException implements Exception {
  final String message;
  CameraException(this.message);
}
```

### RecognitionException

Thrown when recognition fails.

```dart
class RecognitionException implements Exception {
  final String message;
  RecognitionException(this.message);
}
```

---

## Enums

### ProcessingSource

Indicates where processing occurred.

```dart
enum ProcessingSource {
  local,           // Processed on device
  cloud,          // Processed in cloud
  localFallback,  // Cloud failed, used local
}
```

### TranslationMode

Application mode.

```dart
enum TranslationMode {
  signToSpeech,   // Camera → Text → Speech
  speechToSign,   // Speech → Text → Animation
}
```

### ErrorContext

Context where error occurred.

```dart
enum ErrorContext {
  modelLoading,
  recognition,
  transcription,
  animation,
  camera,
  permission,
}
```

---

## Best Practices

### Memory Management

```dart
// Always dispose services when done
@override
void dispose() {
  signRecognitionService.dispose();
  speechRecognitionService.dispose();
  super.dispose();
}
```

### Error Handling

```dart
// Wrap risky operations in try-catch
try {
  await service.startRecognition();
} catch (e, stackTrace) {
  await ErrorHandler.handleError(
    e as Exception,
    ErrorContext.recognition,
    stackTrace: stackTrace,
  );
}
```

### Performance Monitoring

```dart
// Monitor critical operations
final stopwatch = Stopwatch()..start();
await criticalOperation();
stopwatch.stop();

PerformanceMonitor.instance.recordLatency(
  operation: 'critical_op',
  duration: stopwatch.elapsed,
  source: ProcessingSource.local,
);
```

---

## Version History

- **v1.0.0** (2024-01-15): Initial release
  - Complete sign-to-speech pipeline
  - Complete speech-to-sign pipeline
  - Hybrid routing support
  - Mock SDK for testing

---

**For more information, see:**
- [Technical Architecture](TECHNICAL_ARCHITECTURE.md)
- [Integration Guide](CACTUS_SDK_INTEGRATION_GUIDE.md)
- [Simple Start Guide](SIMPLE_START_GUIDE.md)