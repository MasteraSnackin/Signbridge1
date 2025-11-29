# 🔧 SignBridge Troubleshooting Guide

Common issues and their solutions for SignBridge development and usage.

---

## Table of Contents

1. [Installation Issues](#installation-issues)
2. [Build Issues](#build-issues)
3. [Runtime Issues](#runtime-issues)
4. [Camera Issues](#camera-issues)
5. [Recognition Issues](#recognition-issues)
6. [Performance Issues](#performance-issues)
7. [Model Issues](#model-issues)
8. [Animation Issues](#animation-issues)
9. [Testing Issues](#testing-issues)
10. [Platform-Specific Issues](#platform-specific-issues)

---

## Installation Issues

### Issue: `flutter pub get` fails

**Symptoms:**
```
Running "flutter pub get" in signbridge...
Error: Could not resolve package dependencies
```

**Solutions:**

1. **Check Flutter version:**
```bash
flutter --version
# Should be 3.0.0 or higher
flutter upgrade
```

2. **Clear pub cache:**
```bash
flutter pub cache repair
flutter clean
flutter pub get
```

3. **Check internet connection:**
```bash
ping pub.dev
```

4. **Verify pubspec.yaml syntax:**
- Ensure proper indentation (2 spaces)
- Check for typos in package names
- Verify version constraints

---

### Issue: Cactus SDK not found

**Symptoms:**
```
Error: Package 'cactus' not found
```

**Solutions:**

1. **Use mock SDK for development:**
```dart
// In lib/core/services/cactus_model_service_with_mock.dart
static const bool useMockSDK = true;  // Set to true
```

2. **Contact hackathon organizers:**
- Request access to Cactus SDK
- Get proper package credentials

3. **Check pubspec.yaml:**
```yaml
dependencies:
  cactus: ^latest  # Verify version
```

---

## Build Issues

### Issue: Build fails with "Execution failed for task ':app:processDebugResources'"

**Symptoms:**
```
FAILURE: Build failed with an exception.
* What went wrong:
Execution failed for task ':app:processDebugResources'.
```

**Solutions:**

1. **Clean and rebuild:**
```bash
flutter clean
flutter pub get
flutter build apk --debug
```

2. **Check AndroidManifest.xml:**
- Verify all permissions are properly declared
- Check for duplicate entries

3. **Update Gradle:**
```bash
cd android
./gradlew clean
cd ..
flutter build apk
```

---

### Issue: APK size too large

**Symptoms:**
```
APK size: 150MB (exceeds 100MB limit)
```

**Solutions:**

1. **Use split APKs:**
```bash
flutter build apk --release --split-per-abi
```

2. **Enable ProGuard (Release only):**
```gradle
// android/app/build.gradle
buildTypes {
    release {
        minifyEnabled true
        shrinkResources true
    }
}
```

3. **Remove unused assets:**
```bash
# Check asset sizes
du -sh assets/*
# Remove unnecessary files
```

---

## Runtime Issues

### Issue: App crashes on startup

**Symptoms:**
```
E/AndroidRuntime: FATAL EXCEPTION: main
Process: com.signbridge.app, PID: 12345
```

**Solutions:**

1. **Check logs:**
```bash
flutter logs
# or
adb logcat | grep -i flutter
```

2. **Verify model initialization:**
```dart
// In main.dart
try {
  await CactusModelService.instance.initialize();
} catch (e) {
  print('Model initialization failed: $e');
}
```

3. **Check permissions:**
```dart
// Ensure permissions are granted before starting
await PermissionService.requestCameraAndMicrophone();
```

---

### Issue: "setState() called after dispose()"

**Symptoms:**
```
setState() called after dispose()
This error happens if you call setState() on a State object for a widget that no longer appears in the widget tree
```

**Solutions:**

1. **Check mounted before setState:**
```dart
if (mounted) {
  setState(() {
    // Update state
  });
}
```

2. **Cancel async operations in dispose:**
```dart
@override
void dispose() {
  _subscription?.cancel();
  _controller?.dispose();
  super.dispose();
}
```

---

## Camera Issues

### Issue: Camera permission denied

**Symptoms:**
```
CameraException: Camera permission denied
```

**Solutions:**

1. **Request permissions at runtime:**
```dart
await PermissionService.requestCameraAndMicrophone();
```

2. **Check AndroidManifest.xml:**
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" />
```

3. **Manual permission grant:**
```bash
adb shell pm grant com.signbridge.app android.permission.CAMERA
```

---

### Issue: Camera preview is black

**Symptoms:**
- Camera preview shows black screen
- No error messages

**Solutions:**

1. **Check camera initialization:**
```dart
await _camera.initialize();
await Future.delayed(Duration(milliseconds: 500));
setState(() {});
```

2. **Verify camera availability:**
```dart
final cameras = await availableCameras();
if (cameras.isEmpty) {
  print('No cameras available');
}
```

3. **Test on real device:**
- Emulators have limited camera support
- Use physical Android device

---

### Issue: Camera frame rate too low

**Symptoms:**
- Choppy camera preview
- Slow recognition

**Solutions:**

1. **Adjust resolution:**
```dart
_camera = CameraController(
  cameras.first,
  ResolutionPreset.medium,  // Lower from 'high'
);
```

2. **Reduce processing frequency:**
```dart
const int FRAME_SKIP = 3;
if (frameCount++ % FRAME_SKIP == 0) {
  await _processFrame(image);
}
```

---

## Recognition Issues

### Issue: Low recognition accuracy

**Symptoms:**
- Incorrect letter recognition
- Confidence scores below 50%

**Solutions:**

1. **Improve lighting:**
- Use well-lit environment
- Avoid backlighting
- Ensure even lighting on hands

2. **Adjust hand position:**
- Keep hand centered in frame
- Maintain consistent distance (30-50cm)
- Ensure full hand visibility

3. **Lower confidence threshold:**
```dart
// In gesture_classifier.dart
const double CONFIDENCE_THRESHOLD = 0.65;  // Lower from 0.75
```

4. **Calibrate gestures:**
```dart
// Add more training samples to signDatabase
static const Map<String, List<double>> signDatabase = {
  'A': [/* Add more samples */],
};
```

---

### Issue: Recognition too slow

**Symptoms:**
- Latency > 500ms
- Delayed text output

**Solutions:**

1. **Enable GPU acceleration:**
```dart
await visionModel.initializeModel(CactusInitParams(
  useGPU: true,
  numThreads: 4,
));
```

2. **Optimize frame processing:**
```dart
// Process every 3rd frame instead of every frame
const int FRAME_SKIP = 3;
```

3. **Profile performance:**
```bash
flutter run --profile
# Use DevTools to identify bottlenecks
```

---

### Issue: False positives

**Symptoms:**
- Random letters detected when no hand present
- Unstable recognition

**Solutions:**

1. **Increase buffer size:**
```dart
// In sign_to_text_converter.dart
final int _bufferSize = 7;  // Increase from 5
```

2. **Add hand detection threshold:**
```dart
if (landmarks == null || landmarks.confidence < 0.5) {
  return null;  // Skip processing
}
```

3. **Implement temporal smoothing:**
```dart
// Only accept if same letter appears 5/7 times
final stable = counts.entries.firstWhere(
  (e) => e.value >= 5,
  orElse: () => MapEntry("", 0),
);
```

---

## Performance Issues

### Issue: High memory usage

**Symptoms:**
```
Memory usage: 2.5GB
App becomes sluggish
```

**Solutions:**

1. **Monitor memory:**
```bash
flutter run --profile
# Open DevTools → Memory tab
```

2. **Dispose resources properly:**
```dart
@override
void dispose() {
  _camera?.dispose();
  _controller?.dispose();
  super.dispose();
}
```

3. **Clear caches periodically:**
```dart
// Clear animation cache
await _clearAnimationCache();

// Clear gesture cache
_gestureBuffer.clear();
```

---

### Issue: Battery drain

**Symptoms:**
- Battery depletes quickly
- Device gets hot

**Solutions:**

1. **Reduce frame rate:**
```dart
// Process at 5 FPS instead of 10 FPS
const int FRAME_SKIP = 6;  // 30 FPS / 6 = 5 FPS
```

2. **Disable GPU when not needed:**
```dart
await visionModel.initializeModel(CactusInitParams(
  useGPU: false,  // Use CPU for better battery life
  numThreads: 2,
));
```

3. **Implement idle detection:**
```dart
// Stop processing after 30 seconds of inactivity
Timer? _idleTimer;
void _resetIdleTimer() {
  _idleTimer?.cancel();
  _idleTimer = Timer(Duration(seconds: 30), () {
    stopRecognition();
  });
}
```

---

## Model Issues

### Issue: Models fail to download

**Symptoms:**
```
Error: Failed to download model
Network error or insufficient storage
```

**Solutions:**

1. **Check storage space:**
```bash
adb shell df /data
# Ensure at least 2GB free space
```

2. **Check internet connection:**
```bash
ping google.com
```

3. **Use mock SDK temporarily:**
```dart
static const bool useMockSDK = true;
```

4. **Manual model download:**
- Download models separately
- Place in `assets/models/`
- Update paths in config

---

### Issue: Model initialization fails

**Symptoms:**
```
Error: Failed to initialize model
Model file corrupted or incompatible
```

**Solutions:**

1. **Re-download models:**
```dart
await CactusModelService.instance._downloadModelsIfNeeded();
```

2. **Verify model files:**
```bash
# Check file sizes
ls -lh /data/data/com.signbridge.app/models/
```

3. **Check model compatibility:**
- Verify Cactus SDK version
- Ensure model format matches SDK

---

## Animation Issues

### Issue: Animations not playing

**Symptoms:**
- Sign avatar shows blank screen
- No animation displayed

**Solutions:**

1. **Check animation paths:**
```dart
final path = SignDictionaryRepository().getAnimationPath('hello');
print('Animation path: $path');
```

2. **Verify asset declaration:**
```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/animations/
    - assets/animations/letters/
```

3. **Generate placeholder animations:**
```bash
dart scripts/generate_placeholder_animations.dart
```

---

### Issue: Animations are choppy

**Symptoms:**
- Jerky animation playback
- Frame drops

**Solutions:**

1. **Preload animations:**
```dart
// Preload frequently used animations
await precacheImage(
  AssetImage('assets/animations/hello.json'),
  context,
);
```

2. **Reduce animation complexity:**
- Use simpler Lottie files
- Reduce frame count
- Optimize file size

---

## Testing Issues

### Issue: Tests fail with "No MediaQuery widget found"

**Symptoms:**
```
Error: No MediaQuery widget found
```

**Solutions:**

1. **Wrap widget in MaterialApp:**
```dart
testWidgets('Test description', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: YourWidget(),
    ),
  );
});
```

---

### Issue: Integration tests timeout

**Symptoms:**
```
Test timed out after 30 seconds
```

**Solutions:**

1. **Increase timeout:**
```dart
testWidgets('Test', (tester) async {
  // ...
}, timeout: Timeout(Duration(minutes: 2)));
```

2. **Use pumpAndSettle:**
```dart
await tester.pumpAndSettle();  // Wait for animations
```

---

## Platform-Specific Issues

### Android Issues

#### Issue: "Cleartext HTTP traffic not permitted"

**Solutions:**

1. **Add network security config:**
```xml
<!-- android/app/src/main/res/xml/network_security_config.xml -->
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="true" />
</network-security-config>
```

2. **Reference in AndroidManifest.xml:**
```xml
<application
    android:networkSecurityConfig="@xml/network_security_config">
```

---

#### Issue: "Minimum SDK version"

**Symptoms:**
```
Error: Minimum supported SDK version is 24
```

**Solutions:**

1. **Update build.gradle:**
```gradle
android {
    defaultConfig {
        minSdkVersion 24  // Android 7.0+
    }
}
```

---

## Getting Help

If you can't find a solution here:

1. **Check existing issues:**
   - [GitHub Issues](https://github.com/yourusername/signbridge/issues)

2. **Search documentation:**
   - [User Guide](USER_GUIDE.md)
   - [API Reference](API_REFERENCE.md)
   - [Technical Architecture](TECHNICAL_ARCHITECTURE.md)

3. **Ask the community:**
   - [GitHub Discussions](https://github.com/yourusername/signbridge/discussions)
   - [Discord Server](https://discord.gg/signbridge)

4. **Report a bug:**
   - [Create an issue](https://github.com/yourusername/signbridge/issues/new)
   - Include: OS version, Flutter version, error logs, steps to reproduce

5. **Contact support:**
   - Email: support@signbridge.app
   - Include: Device info, logs, screenshots

---

## Debug Checklist

Before reporting an issue, try these steps:

- [ ] Run `flutter doctor` and fix any issues
- [ ] Run `flutter clean && flutter pub get`
- [ ] Check logs with `flutter logs`
- [ ] Test on a real device (not emulator)
- [ ] Verify permissions are granted
- [ ] Check internet connection
- [ ] Ensure sufficient storage space (2GB+)
- [ ] Try with mock SDK enabled
- [ ] Update Flutter to latest stable version
- [ ] Review recent code changes

---

<div align="center">

**Still having issues? We're here to help!**

[Report an Issue](https://github.com/yourusername/signbridge/issues) • [Join Discord](https://discord.gg/signbridge)

[⬆ Back to Top](#-signbridge-troubleshooting-guide)

</div>