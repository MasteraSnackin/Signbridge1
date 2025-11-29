# 📋 SignBridge Quick Reference Guide

A one-page reference for developers working with SignBridge.

---

## 🚀 Quick Commands

```bash
# Setup
flutter pub get                          # Install dependencies
flutter doctor                           # Check environment

# Development
flutter run                              # Run on connected device
flutter run -d chrome                    # Run in browser (limited)
flutter run --release                    # Run optimized build

# Testing
flutter test                             # Run all tests
flutter test --coverage                  # Generate coverage report
flutter test test/unit/                  # Run unit tests only

# Building
flutter build apk --debug                # Debug APK
flutter build apk --release              # Release APK
flutter build appbundle --release        # App Bundle for Play Store

# Analysis
flutter analyze                          # Static analysis
dart format lib/                         # Format code
```

---

## 📁 Key File Locations

| Purpose | Path |
|---------|------|
| **Main Entry** | `lib/main.dart` |
| **Config** | `lib/config/app_config.dart` |
| **Models** | `lib/core/models/` |
| **Services** | `lib/core/services/` |
| **UI Screens** | `lib/ui/screens/` |
| **Widgets** | `lib/ui/widgets/` |
| **Tests** | `test/` |
| **Assets** | `assets/animations/` |

---

## 🔧 Core Services API

### CactusModelService
```dart
// Initialize AI models
await CactusModelService.instance.initialize();

// Check if models are downloaded
bool ready = await CactusModelService.instance.areModelsDownloaded();

// Access models
CactusLM vision = CactusModelService.instance.visionModel;
CactusLM text = CactusModelService.instance.textModel;
CactusSTT speech = CactusModelService.instance.speechModel;
```

### SignRecognitionService
```dart
// Start recognition
await signRecognitionService.startRecognition();

// Stop recognition
await signRecognitionService.stopRecognition();

// Access results
String text = signRecognitionService.recognizedText;
double confidence = signRecognitionService.confidence;
```

### SpeechRecognitionService
```dart
// Start listening
await speechRecognitionService.startListening();

// Stop listening
speechRecognitionService.stopListening();

// Access transcription
String text = speechRecognitionService.transcribedText;
```

### SignAnimationService
```dart
// Display signs for text
await signAnimationService.displaySignsForText("Hello");

// Check animation status
bool isAnimating = signAnimationService.isAnimating;
String? currentAnim = signAnimationService.currentAnimation;
```

---

## 🎨 UI Components

### Using Provider
```dart
// In widget
Consumer<SignRecognitionService>(
  builder: (context, service, child) {
    return Text(service.recognizedText);
  },
)

// Or with context
final service = Provider.of<SignRecognitionService>(context);
```

### Camera Preview
```dart
CameraPreviewWidget(
  controller: cameraController,
)
```

### Sign Animation
```dart
SignAvatarWidget(
  animationPath: animationService.currentAnimation,
)
```

### Confidence Indicator
```dart
ConfidenceIndicator(
  confidence: 0.85,
)
```

---

## 📊 Data Models

### HandLandmarks
```dart
class HandLandmarks {
  final List<Point3D> points;  // 21 landmarks
  
  Point3D get wrist => points[0];
  Point3D get thumbTip => points[4];
  Point3D get indexTip => points[8];
}
```

### SignGesture
```dart
class SignGesture {
  final String letter;
  final double confidence;
  final DateTime timestamp;
  final HandLandmarks landmarks;
}
```

### RecognitionResult
```dart
class RecognitionResult {
  final String? text;
  final double confidence;
  final ProcessingSource source;  // local, cloud, localFallback
  final int latency;  // milliseconds
}
```

---

## 🔍 Common Patterns

### Error Handling
```dart
try {
  await service.startRecognition();
} on CameraException catch (e) {
  AppErrorHandler.handleCameraError(e);
} on ModelLoadException catch (e) {
  AppErrorHandler.handleModelLoadError(e);
} catch (e) {
  AppLogger.error('Unexpected error: $e');
}
```

### Performance Monitoring
```dart
final stopwatch = Stopwatch()..start();

// ... perform operation ...

PerformanceMonitor.instance.recordLatency(
  operation: 'gesture_recognition',
  duration: stopwatch.elapsed,
  source: ProcessingSource.local,
);
```

### Logging
```dart
AppLogger.info('Starting recognition');
AppLogger.debug('Frame processed: ${frame.width}x${frame.height}');
AppLogger.warning('Low confidence: $confidence');
AppLogger.error('Recognition failed: $error');
```

---

## 🧪 Testing Patterns

### Unit Test
```dart
test('GestureClassifier recognizes letter A', () async {
  final classifier = GestureClassifier();
  final landmarks = createTestLandmarks('A');
  
  final result = await classifier.classify(landmarks);
  
  expect(result.letter, 'A');
  expect(result.confidence, greaterThan(0.75));
});
```

### Widget Test
```dart
testWidgets('HomeScreen displays mode buttons', (tester) async {
  await tester.pumpWidget(
    MaterialApp(home: HomeScreen()),
  );
  
  expect(find.text('Sign to Speech'), findsOneWidget);
  expect(find.text('Speech to Sign'), findsOneWidget);
});
```

### Integration Test
```dart
testWidgets('Sign-to-speech flow works end-to-end', (tester) async {
  // Setup
  await tester.pumpWidget(MyApp());
  
  // Navigate to sign-to-speech
  await tester.tap(find.text('Sign to Speech'));
  await tester.pumpAndSettle();
  
  // Start recognition
  await tester.tap(find.byIcon(Icons.play_arrow));
  await tester.pump();
  
  // Verify state
  expect(find.byType(CameraPreviewWidget), findsOneWidget);
});
```

---

## 🎯 Performance Targets

| Metric | Target | Current |
|--------|--------|---------|
| **Recognition Latency** | <500ms | ~200ms ✓ |
| **Frame Rate** | 10 FPS | 10 FPS ✓ |
| **Accuracy** | >80% | 85-95% ✓ |
| **Memory Usage** | <2GB | ~1.4GB ✓ |
| **APK Size** | <100MB | ~50MB ✓ |
| **Model Load Time** | <10s | ~5s ✓ |

---

## 🔐 Permissions

### Required Permissions
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
```

### Request at Runtime
```dart
await PermissionService.requestCameraAndMicrophone();
```

---

## 📦 Dependencies

### Core
- `flutter: sdk`
- `cactus: ^latest` - AI models
- `camera: ^0.10.5` - Camera access
- `flutter_tts: ^3.8.3` - Text-to-speech

### UI
- `lottie: ^2.7.0` - Animations
- `provider: ^6.1.1` - State management

### Utilities
- `permission_handler: ^11.0.1` - Permissions
- `path_provider: ^2.1.1` - File paths
- `shared_preferences: ^2.2.2` - Settings

---

## 🐛 Common Issues & Solutions

### Issue: Camera not working
```dart
// Solution: Check permissions
if (!await PermissionService.hasCameraPermission()) {
  await PermissionService.requestCameraAndMicrophone();
}
```

### Issue: Models not loading
```dart
// Solution: Check storage and re-download
if (!await CactusModelService.instance.areModelsDownloaded()) {
  await CactusModelService.instance.initialize();
}
```

### Issue: Low recognition accuracy
```dart
// Solution: Adjust confidence threshold
const double CONFIDENCE_THRESHOLD = 0.70;  // Lower from 0.75

if (result.confidence > CONFIDENCE_THRESHOLD) {
  // Accept result
}
```

### Issue: High memory usage
```dart
// Solution: Reduce frame processing rate
const int FRAME_SKIP = 3;  // Process every 3rd frame
int frameCount = 0;

if (frameCount++ % FRAME_SKIP == 0) {
  await _processFrame(image);
}
```

---

## 🔄 State Management Flow

```
User Action
    ↓
UI Widget
    ↓
Service Method Call
    ↓
Service Updates State
    ↓
notifyListeners()
    ↓
Consumer Rebuilds
    ↓
UI Updates
```

---

## 📱 Build Variants

### Debug Build
```bash
flutter build apk --debug
# Features: Hot reload, debugging, larger size
```

### Release Build
```bash
flutter build apk --release --split-per-abi
# Features: Optimized, smaller size, no debugging
```

### Profile Build
```bash
flutter build apk --profile
# Features: Performance profiling enabled
```

---

## 🌐 Hybrid Mode Configuration

### Enable Hybrid Mode
```dart
// In settings
HybridRouter().cloudEnabled = true;
```

### Adjust Confidence Threshold
```dart
// In hybrid_router.dart
static const double LOCAL_CONFIDENCE_THRESHOLD = 0.75;
```

### Monitor Usage
```dart
final stats = PerformanceMonitor.instance.getStats();
print('Local: ${stats['localCount']}');
print('Cloud: ${stats['cloudCount']}');
```

---

## 📈 Metrics & Analytics

### Track Recognition
```dart
PerformanceMonitor.instance.recordLatency(
  operation: 'sign_recognition',
  duration: Duration(milliseconds: 150),
  source: ProcessingSource.local,
);
```

### Get Statistics
```dart
final stats = PerformanceMonitor.instance.getStats();
// Returns: avgLocalLatency, avgCloudLatency, localCount, cloudCount
```

---

## 🎓 Learning Resources

| Resource | Link |
|----------|------|
| **User Guide** | [USER_GUIDE.md](USER_GUIDE.md) |
| **API Reference** | [API_REFERENCE.md](API_REFERENCE.md) |
| **Architecture** | [TECHNICAL_ARCHITECTURE.md](TECHNICAL_ARCHITECTURE.md) |
| **Contributing** | [CONTRIBUTING.md](CONTRIBUTING.md) |
| **Diagrams** | [ARCHITECTURE_DIAGRAMS.md](ARCHITECTURE_DIAGRAMS.md) |

---

## 🔗 Useful Links

- **Flutter Docs**: https://docs.flutter.dev
- **Dart Docs**: https://dart.dev/guides
- **Cactus SDK**: [SDK Documentation]
- **ASL Reference**: https://www.lifeprint.com

---

## 💡 Pro Tips

1. **Use Mock SDK for Development**: Set `useMockSDK = true` in `cactus_model_service_with_mock.dart`
2. **Enable Debug Mode**: Show hand landmarks and confidence scores
3. **Test on Real Device**: Emulators have limited camera support
4. **Monitor Performance**: Use Flutter DevTools for profiling
5. **Cache Animations**: Preload frequently used sign animations
6. **Optimize Frame Rate**: Balance between accuracy and battery life
7. **Handle Edge Cases**: Test with different lighting and hand positions
8. **Use Temporal Buffering**: Reduce false positives with frame stability

---

## 📞 Quick Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/signbridge/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/signbridge/discussions)
- **Email**: support@signbridge.app

---

<div align="center">

**Keep this guide handy for quick reference!**

[⬆ Back to Top](#-signbridge-quick-reference-guide)

</div>