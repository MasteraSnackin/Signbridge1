# SignBridge - Project Structure & File Organization

## Complete Directory Tree

```
signbridge/
├── android/
│   ├── app/
│   │   ├── src/
│   │   │   └── main/
│   │   │       ├── AndroidManifest.xml
│   │   │       ├── kotlin/
│   │   │       │   └── com/
│   │   │       │       └── signbridge/
│   │   │       │           └── MainActivity.kt
│   │   │       └── res/
│   │   │           ├── drawable/
│   │   │           ├── mipmap/
│   │   │           └── values/
│   │   ├── build.gradle
│   │   └── proguard-rules.pro
│   ├── gradle/
│   ├── build.gradle
│   └── settings.gradle
├── assets/
│   ├── animations/
│   │   ├── words/
│   │   │   ├── hello.json
│   │   │   ├── thank.json
│   │   │   ├── you.json
│   │   │   ├── help.json
│   │   │   ├── please.json
│   │   │   └── ... (200+ word animations)
│   │   └── letters/
│   │       ├── A.json
│   │       ├── B.json
│   │       └── ... (26 letter animations)
│   └── images/
│       ├── logo.png
│       └── tutorial/
├── lib/
│   ├── main.dart
│   ├── config/
│   │   ├── app_config.dart
│   │   ├── permissions_config.dart
│   │   └── theme_config.dart
│   ├── core/
│   │   ├── models/
│   │   │   ├── sign_gesture.dart
│   │   │   ├── hand_landmarks.dart
│   │   │   ├── recognition_result.dart
│   │   │   ├── translation_mode.dart
│   │   │   ├── sign_animation.dart
│   │   │   └── performance_metrics.dart
│   │   ├── services/
│   │   │   ├── cactus_model_service.dart
│   │   │   ├── camera_service.dart
│   │   │   ├── permission_service.dart
│   │   │   └── storage_service.dart
│   │   └── utils/
│   │       ├── logger.dart
│   │       ├── performance_monitor.dart
│   │       ├── error_handler.dart
│   │       └── constants.dart
│   ├── features/
│   │   ├── sign_recognition/
│   │   │   ├── sign_recognition_service.dart
│   │   │   ├── hand_landmark_detector.dart
│   │   │   ├── gesture_classifier.dart
│   │   │   ├── sign_to_text_converter.dart
│   │   │   └── asl_database.dart
│   │   ├── speech_recognition/
│   │   │   ├── speech_recognition_service.dart
│   │   │   ├── text_to_sign_mapper.dart
│   │   │   └── voice_activity_detector.dart
│   │   ├── sign_animation/
│   │   │   ├── sign_animation_service.dart
│   │   │   ├── animation_player.dart
│   │   │   └── animation_queue_manager.dart
│   │   ├── text_to_speech/
│   │   │   ├── tts_service.dart
│   │   │   └── tts_config.dart
│   │   └── hybrid_routing/
│   │       ├── hybrid_router.dart
│   │       ├── confidence_scorer.dart
│   │       ├── cloud_fallback_service.dart
│   │       └── network_monitor.dart
│   ├── ui/
│   │   ├── screens/
│   │   │   ├── home_screen.dart
│   │   │   ├── sign_to_speech_screen.dart
│   │   │   ├── speech_to_sign_screen.dart
│   │   │   ├── settings_screen.dart
│   │   │   ├── privacy_dashboard_screen.dart
│   │   │   ├── model_download_screen.dart
│   │   │   └── tutorial_screen.dart
│   │   ├── widgets/
│   │   │   ├── camera_preview_widget.dart
│   │   │   ├── sign_animation_widget.dart
│   │   │   ├── mode_toggle_button.dart
│   │   │   ├── confidence_indicator.dart
│   │   │   ├── transcription_display.dart
│   │   │   ├── hand_landmarks_overlay.dart
│   │   │   ├── performance_overlay.dart
│   │   │   └── loading_indicator.dart
│   │   └── theme/
│   │       ├── app_theme.dart
│   │       ├── colors.dart
│   │       └── text_styles.dart
│   └── data/
│       ├── repositories/
│       │   ├── sign_dictionary_repository.dart
│       │   ├── model_cache_repository.dart
│       │   └── settings_repository.dart
│       └── models/
│           └── (downloaded AI models stored here)
├── test/
│   ├── unit/
│   │   ├── models/
│   │   ├── services/
│   │   └── utils/
│   ├── integration/
│   │   ├── sign_recognition_test.dart
│   │   ├── speech_recognition_test.dart
│   │   └── hybrid_routing_test.dart
│   └── widget/
│       ├── screens/
│       └── widgets/
├── docs/
│   ├── IMPLEMENTATION_PLAN.md
│   ├── TECHNICAL_ARCHITECTURE.md
│   ├── API_DOCUMENTATION.md
│   ├── PERFORMANCE_REPORT.md
│   └── USER_GUIDE.md
├── .gitignore
├── pubspec.yaml
├── pubspec.lock
├── analysis_options.yaml
└── README.md
```

---

## File Descriptions

### Root Level

#### `pubspec.yaml`
**Purpose**: Flutter project configuration and dependencies

**Key Sections**:
```yaml
name: signbridge
description: Bidirectional sign language translator with on-device AI

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  cactus: ^latest
  camera: ^0.10.5
  flutter_tts: ^3.8.3
  lottie: ^2.7.0
  provider: ^6.1.1
  permission_handler: ^11.0.1
  path_provider: ^2.1.1
  shared_preferences: ^2.2.2
  http: ^1.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  mockito: ^5.4.4
  integration_test:
    sdk: flutter

flutter:
  uses-material-design: true
  assets:
    - assets/animations/words/
    - assets/animations/letters/
    - assets/images/
```

#### `README.md`
**Purpose**: Project overview and quick start guide

**Contents**:
- Project description
- Features list
- Installation instructions
- Usage examples
- Demo video link
- Contributing guidelines
- License information

---

### `/lib` Directory

#### `main.dart`
**Purpose**: Application entry point

**Responsibilities**:
- Initialize Flutter bindings
- Download/initialize AI models
- Request permissions
- Setup dependency injection (Provider)
- Run app

**Key Code**:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await CactusModelService.instance.initialize();
  await PermissionService.requestAllPermissions();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SignRecognitionService()),
        ChangeNotifierProvider(create: (_) => SpeechRecognitionService()),
        ChangeNotifierProvider(create: (_) => SignAnimationService()),
        ChangeNotifierProvider(create: (_) => TTSService()),
      ],
      child: SignBridgeApp(),
    ),
  );
}

class SignBridgeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SignBridge',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: HomeScreen(),
    );
  }
}
```

---

### `/lib/config` Directory

#### `app_config.dart`
**Purpose**: Application-wide configuration constants

**Contents**:
```dart
class AppConfig {
  // Model paths
  static const String visionModelPath = 'models/lfm2-vl-450m';
  static const String textModelPath = 'models/qwen3-0.6';
  static const String speechModelPath = 'models/whisper-tiny';
  
  // Performance settings
  static const int cameraFPS = 10;
  static const int processingThreads = 4;
  static const double confidenceThreshold = 0.75;
  
  // Hybrid routing
  static const bool hybridModeEnabled = false;
  static const int cloudTimeoutMs = 2000;
  
  // UI settings
  static const Duration animationDuration = Duration(milliseconds: 1500);
  static const Duration wordPauseDuration = Duration(milliseconds: 500);
}
```

#### `permissions_config.dart`
**Purpose**: Permission handling configuration

**Contents**:
```dart
class PermissionsConfig {
  static const List<Permission> requiredPermissions = [
    Permission.camera,
    Permission.microphone,
    Permission.storage,
  ];
  
  static const List<Permission> optionalPermissions = [
    Permission.internet,
  ];
}
```

---

### `/lib/core/models` Directory

#### `hand_landmarks.dart`
**Purpose**: Hand landmark data structure

**Contents**:
```dart
class HandLandmarks {
  final List<Point3D> points;
  final DateTime timestamp;
  final double confidence;
  
  HandLandmarks({
    required this.points,
    required this.timestamp,
    required this.confidence,
  });
  
  // Named accessors for key landmarks
  Point3D get wrist => points[0];
  Point3D get thumbTip => points[4];
  Point3D get indexTip => points[8];
  Point3D get middleTip => points[12];
  Point3D get ringTip => points[16];
  Point3D get pinkyTip => points[20];
  
  // Normalization
  HandLandmarks normalize() {
    // Translate to wrist origin
    final translated = points.map((p) => p - wrist).toList();
    
    // Scale to unit size
    final maxDist = translated.map((p) => p.magnitude).reduce(max);
    final scaled = translated.map((p) => p / maxDist).toList();
    
    return HandLandmarks(
      points: scaled,
      timestamp: timestamp,
      confidence: confidence,
    );
  }
  
  // Feature vector for classification
  List<double> toFeatureVector() {
    return points.expand((p) => [p.x, p.y, p.z]).toList();
  }
  
  // Serialization
  Map<String, dynamic> toJson();
  factory HandLandmarks.fromJson(Map<String, dynamic> json);
}

class Point3D {
  final double x, y, z;
  
  Point3D(this.x, this.y, this.z);
  
  double get magnitude => sqrt(x * x + y * y + z * z);
  
  Point3D operator -(Point3D other) =>
      Point3D(x - other.x, y - other.y, z - other.z);
  
  Point3D operator /(double scalar) =>
      Point3D(x / scalar, y / scalar, z / scalar);
  
  double distanceTo(Point3D other) =>
      (this - other).magnitude;
}
```

#### `sign_gesture.dart`
**Purpose**: Recognized gesture data

**Contents**:
```dart
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
  
  bool get isHighConfidence => confidence > 0.75;
  bool get isLowConfidence => confidence < 0.5;
  
  Map<String, dynamic> toJson();
  factory SignGesture.fromJson(Map<String, dynamic> json);
}
```

#### `recognition_result.dart`
**Purpose**: Recognition result with metadata

**Contents**:
```dart
enum ProcessingSource {
  local,
  cloud,
  localFallback,
}

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
  
  RecognitionResult copyWith({
    String? text,
    double? confidence,
    ProcessingSource? source,
    int? latencyMs,
    Map<String, dynamic>? metadata,
  });
  
  Map<String, dynamic> toJson();
  factory RecognitionResult.fromJson(Map<String, dynamic> json);
}
```

---

### `/lib/core/services` Directory

#### `cactus_model_service.dart`
**Purpose**: Centralized AI model management

**Key Methods**:
```dart
class CactusModelService {
  static final instance = CactusModelService._();
  
  late CactusLM visionModel;
  late CactusLM textModel;
  late CactusSTT speechModel;
  
  bool _isInitialized = false;
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Download models if needed
    await downloadModels();
    
    // Initialize vision model
    visionModel = CactusLM();
    await visionModel.downloadModel(model: "lfm2-vl-450m");
    await visionModel.initializeModel(CactusInitParams(
      useGPU: true,
      numThreads: 4,
    ));
    
    // Initialize text model
    textModel = CactusLM();
    await textModel.downloadModel(model: "qwen3-0.6");
    await textModel.initializeModel();
    
    // Initialize speech model
    speechModel = CactusSTT();
    await speechModel.download(model: "whisper-tiny");
    await speechModel.init(model: "whisper-tiny");
    
    _isInitialized = true;
  }
  
  Future<void> downloadModels({
    Function(String model, double progress)? onProgress,
  }) async {
    // Download with progress tracking
  }
  
  Future<bool> areModelsReady() async {
    return _isInitialized;
  }
  
  Future<Map<String, dynamic>> getModelInfo() async {
    return {
      'vision': await _getModelDetails(visionModel),
      'text': await _getModelDetails(textModel),
      'speech': await _getModelDetails(speechModel),
    };
  }
}
```

#### `camera_service.dart`
**Purpose**: Camera management and frame streaming

**Key Methods**:
```dart
class CameraService {
  CameraController? _controller;
  bool _isStreaming = false;
  
  Future<void> initialize() async {
    final cameras = await availableCameras();
    _controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _controller!.initialize();
  }
  
  Stream<CameraImage> get frameStream {
    return Stream.periodic(
      Duration(milliseconds: 100), // 10 FPS
      (_) => _currentFrame,
    ).where((frame) => frame != null);
  }
  
  Future<void> startStreaming() async {
    _isStreaming = true;
    _controller!.startImageStream((image) {
      _currentFrame = image;
    });
  }
  
  Future<void> stopStreaming() async {
    _isStreaming = false;
    await _controller!.stopImageStream();
  }
  
  void dispose() {
    _controller?.dispose();
  }
}
```

---

### `/lib/features/sign_recognition` Directory

#### `sign_recognition_service.dart`
**Purpose**: Main orchestrator for sign-to-speech pipeline

**Key Methods**:
```dart
class SignRecognitionService extends ChangeNotifier {
  final CameraService _cameraService;
  final HandLandmarkDetector _landmarkDetector;
  final GestureClassifier _gestureClassifier;
  final SignToTextConverter _textConverter;
  final TTSService _ttsService;
  
  bool _isProcessing = false;
  String _recognizedText = "";
  double _confidence = 0.0;
  HandLandmarks? _currentLandmarks;
  
  Future<void> startRecognition() async {
    await _cameraService.initialize();
    await _cameraService.startStreaming();
    
    _cameraService.frameStream.listen((frame) async {
      if (!_isProcessing) {
        await _processFrame(frame);
      }
    });
  }
  
  Future<void> _processFrame(CameraImage frame) async {
    _isProcessing = true;
    final startTime = DateTime.now();
    
    try {
      // Detect hand landmarks
      final landmarks = await _landmarkDetector.detectLandmarks(frame);
      if (landmarks == null) return;
      
      _currentLandmarks = landmarks;
      
      // Classify gesture
      final gesture = await _gestureClassifier.classify(landmarks);
      
      // Convert to text
      final text = _textConverter.convertToText(gesture.letter);
      
      // Update state
      _recognizedText = text;
      _confidence = gesture.confidence;
      
      // Speak if new letter
      if (text.isNotEmpty && text != _previousText) {
        await _ttsService.speakLetter(text.last);
      }
      
      notifyListeners();
      
      // Record performance
      final latency = DateTime.now().difference(startTime);
      PerformanceMonitor.instance.recordLatency(
        operation: 'sign_recognition',
        duration: latency,
        source: ProcessingSource.local,
      );
    } finally {
      _isProcessing = false;
    }
  }
  
  Future<void> stopRecognition() async {
    await _cameraService.stopStreaming();
  }
  
  void clearText() {
    _recognizedText = "";
    _textConverter.clearWord();
    notifyListeners();
  }
}
```

#### `gesture_classifier.dart`
**Purpose**: Classify hand landmarks to ASL signs

**Key Methods**:
```dart
class GestureClassifier {
  final Map<String, List<double>> _signDatabase = ASLDatabase.signs;
  
  Future<GestureResult> classify(HandLandmarks landmarks) async {
    // Normalize landmarks
    final normalized = landmarks.normalize();
    final featureVector = normalized.toFeatureVector();
    
    // Calculate similarities
    final similarities = <String, double>{};
    for (final entry in _signDatabase.entries) {
      similarities[entry.key] = _cosineSimilarity(
        featureVector,
        entry.value,
      );
    }
    
    // Find best match
    final best = similarities.entries.reduce((a, b) =>
      a.value > b.value ? a : b
    );
    
    return GestureResult(
      letter: best.value > 0.75 ? best.key : null,
      confidence: best.value,
    );
  }
  
  double _cosineSimilarity(List<double> a, List<double> b) {
    final dotProduct = List.generate(a.length, (i) => a[i] * b[i])
        .reduce((sum, val) => sum + val);
    final normA = sqrt(a.map((x) => x * x).reduce((sum, val) => sum + val));
    final normB = sqrt(b.map((x) => x * x).reduce((sum, val) => sum + val));
    return dotProduct / (normA * normB);
  }
}
```

---

### `/lib/features/speech_recognition` Directory

#### `speech_recognition_service.dart`
**Purpose**: Speech-to-text conversion

**Key Methods**:
```dart
class SpeechRecognitionService extends ChangeNotifier {
  final CactusSTT _whisper;
  bool _isListening = false;
  String _transcribedText = "";
  
  Future<void> startListening() async {
    _isListening = true;
    notifyListeners();
    
    try {
      final transcription = await _whisper.transcribe();
      
      if (transcription != null && transcription.text.isNotEmpty) {
        _transcribedText = transcription.text;
        notifyListeners();
      }
    } catch (e) {
      ErrorHandler.handleError(e, ErrorContext.speechRecognition);
    } finally {
      _isListening = false;
      notifyListeners();
    }
  }
  
  void stopListening() {
    _isListening = false;
    notifyListeners();
  }
  
  void clearTranscription() {
    _transcribedText = "";
    notifyListeners();
  }
}
```

---

### `/lib/data/repositories` Directory

#### `sign_dictionary_repository.dart`
**Purpose**: Map words to sign animations

**Key Methods**:
```dart
class SignDictionaryRepository {
  static const Map<String, SignAnimation> _wordSigns = {
    'hello': SignAnimation(
      path: 'assets/animations/words/hello.json',
      duration: Duration(milliseconds: 1500),
    ),
    'thank': SignAnimation(
      path: 'assets/animations/words/thank.json',
      duration: Duration(milliseconds: 1500),
    ),
    // ... 200+ words
  };
  
  static const Map<String, SignAnimation> _letterSigns = {
    'A': SignAnimation(
      path: 'assets/animations/letters/A.json',
      duration: Duration(milliseconds: 1000),
    ),
    // ... 26 letters
  };
  
  SignAnimation? getWordSign(String word) {
    return _wordSigns[word.toLowerCase()];
  }
  
  List<SignAnimation> fingerspellWord(String word) {
    return word.toUpperCase().split('').map((letter) {
      return _letterSigns[letter]!;
    }).toList();
  }
  
  bool hasSign(String word) {
    return _wordSigns.containsKey(word.toLowerCase());
  }
}
```

---

### `/lib/ui/screens` Directory

#### `home_screen.dart`
**Purpose**: Main navigation screen

**Layout**:
```dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SignBridge'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildModeCard(
              context,
              title: 'Sign to Speech',
              icon: Icons.sign_language,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SignToSpeechScreen()),
              ),
            ),
            SizedBox(height: 32),
            _buildModeCard(
              context,
              title: 'Speech to Sign',
              icon: Icons.mic,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SpeechToSignScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### `/test` Directory

#### Unit Tests Structure
```
test/unit/
├── models/
│   ├── hand_landmarks_test.dart
│   ├── sign_gesture_test.dart
│   └── recognition_result_test.dart
├── services/
│   ├── cactus_model_service_test.dart
│   ├── camera_service_test.dart
│   └── permission_service_test.dart
└── utils/
    ├── performance_monitor_test.dart
    └── error_handler_test.dart
```

#### Integration Tests Structure
```
test/integration/
├── sign_recognition_test.dart
├── speech_recognition_test.dart
└── hybrid_routing_test.dart
```

---

## Build Configuration Files

### `android/app/build.gradle`
```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.signbridge.app"
        minSdkVersion 24
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
        
        aaptOptions {
            noCompress "tflite"
            noCompress "onnx"
        }
    }
    
    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'),
                         'proguard-rules.pro'
        }
    }
}
```

### `android/app/src/main/AndroidManifest.xml`
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.signbridge.app">
    
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    
    <uses-feature android:name="android.hardware.camera" android:required="true" />
    
    <application
        android:label="SignBridge"
        android:icon="@mipmap/ic_launcher"
        android:requestLegacyExternalStorage="true">
        
        <activity
            android:name=".MainActivity"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize"
            android:hardwareAccelerated="true"
            android:screenOrientation="portrait">
            
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>
```

---

## File Size Estimates

| Directory | Estimated Size | Notes |
|-----------|----------------|-------|
| `/lib` | ~5 MB | Dart source code |
| `/assets/animations` | ~50-100 MB | Lottie JSON files |
| `/android` | ~10 MB | Android configuration |
| `/test` | ~2 MB | Test files |
| **Total (excluding models)** | **~70 MB** | |
| **AI Models** | **~500 MB** | Downloaded separately |
| **Total APK** | **~100 MB** | Compressed |

---

## Development Workflow

### 1. Initial Setup
```bash
# Clone repository
git clone <repo-url>
cd signbridge

# Install dependencies
flutter pub get

# Run code generation (if needed)
flutter pub run build_runner build
```

### 2. Development
```bash
# Run in debug mode
flutter run

# Run with hot reload
flutter run --hot

# Run tests
flutter test

# Run integration tests
flutter test integration_test/
```

### 3. Build
```bash
# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release --split-per-abi

# Build app bundle
flutter build appbundle --release
```

---

## Code Organization Principles

### 1. Separation of Concerns
- **UI Layer**: Only presentation logic
- **Business Logic**: Services and use cases
- **Data Layer**: Repositories and models

### 2. Dependency Injection
- Use Provider for state management
- Services injected at app initialization
- Easy to mock for testing

### 3. Single Responsibility
- Each file has one primary purpose
- Classes are focused and cohesive
- Functions are small and testable

### 4. Naming Conventions
- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables**: `camelCase`
- **Constants**: `SCREAMING_SNAKE_CASE`

### 5. Documentation
- Every public class has documentation
- Complex algorithms explained
- Examples provided for key functions

---

## Conclusion

This project structure provides:
- **Clear organization** by feature and layer
- **Scalability** for adding new features
- **Testability** with proper separation
- **Maintainability** with consistent patterns

All files are organized logically to support the full implementation of SignBridge with bidirectional translation, hybrid routing, and comprehensive testing.