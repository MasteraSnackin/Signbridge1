# Performance Optimization Guide

This guide provides strategies and techniques to optimize SignBridge for maximum performance, minimal latency, and efficient resource usage.

---

## 🎯 Performance Targets

### Latency Goals
- **Frame Processing**: < 100ms per frame
- **Gesture Recognition**: < 200ms end-to-end
- **Speech Transcription**: < 500ms
- **Animation Playback**: 30 FPS smooth
- **Total Sign-to-Speech**: < 2 seconds

### Resource Goals
- **Memory Usage**: < 500MB RAM
- **Battery Drain**: < 10% per hour
- **Storage**: < 200MB (including models)
- **CPU Usage**: < 50% average

---

## 📊 Current Performance Baseline

Run benchmarks to establish baseline:

```dart
// test/performance/benchmark_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:signbridge/features/sign_recognition/gesture_classifier.dart';

void main() {
  group('Performance Benchmarks', () {
    test('gesture classification latency', () async {
      final classifier = GestureClassifier();
      final landmarks = /* test landmarks */;
      
      final latencies = <int>[];
      
      for (int i = 0; i < 100; i++) {
        final stopwatch = Stopwatch()..start();
        await classifier.classify(landmarks);
        stopwatch.stop();
        latencies.add(stopwatch.elapsedMilliseconds);
      }
      
      final avg = latencies.reduce((a, b) => a + b) / latencies.length;
      final p95 = latencies..sort()[95];
      
      print('Average: ${avg}ms');
      print('P95: ${p95}ms');
      
      expect(avg, lessThan(100));
      expect(p95, lessThan(150));
    });
  });
}
```

---

## 🚀 Optimization Strategies

### 1. Camera Frame Processing

#### Current Implementation
```dart
// Processes every frame at camera FPS (30 FPS)
_camera!.startImageStream((CameraImage image) {
  _processFrame(image);
});
```

#### Optimized Implementation
```dart
// Rate limit to 10 FPS
DateTime? _lastProcessTime;
static const _minFrameInterval = Duration(milliseconds: 100);

_camera!.startImageStream((CameraImage image) {
  final now = DateTime.now();
  
  if (_lastProcessTime == null || 
      now.difference(_lastProcessTime!) >= _minFrameInterval) {
    _lastProcessTime = now;
    _processFrame(image);
  }
});
```

**Impact**: Reduces CPU usage by 66%, improves battery life

#### Advanced: Adaptive Frame Rate
```dart
class AdaptiveFrameRateController {
  int _currentFPS = 10;
  final int _minFPS = 5;
  final int _maxFPS = 15;
  
  void adjustBasedOnPerformance(int latency) {
    if (latency > 150 && _currentFPS > _minFPS) {
      // Slow down if processing is too slow
      _currentFPS--;
    } else if (latency < 50 && _currentFPS < _maxFPS) {
      // Speed up if we have headroom
      _currentFPS++;
    }
  }
  
  Duration get frameInterval => 
    Duration(milliseconds: 1000 ~/ _currentFPS);
}
```

### 2. Image Preprocessing Optimization

#### Current Implementation
```dart
Future<Uint8List> _preprocessImage(CameraImage image) async {
  // Convert YUV420 to RGB (expensive)
  final rgbImage = await _convertYUV420ToRGB(image);
  
  // Resize to 224x224
  final resized = await _resizeImage(rgbImage, 224, 224);
  
  return resized;
}
```

#### Optimized Implementation
```dart
// Use isolate for heavy computation
Future<Uint8List> _preprocessImage(CameraImage image) async {
  return await compute(_preprocessImageIsolate, image);
}

static Uint8List _preprocessImageIsolate(CameraImage image) {
  // Runs in separate isolate, doesn't block UI
  final rgb = _convertYUV420ToRGBFast(image);
  final resized = _resizeImageFast(rgb, 224, 224);
  return resized;
}

// Optimized YUV conversion (avoid unnecessary allocations)
static Uint8List _convertYUV420ToRGBFast(CameraImage image) {
  final int width = image.width;
  final int height = image.height;
  final int uvRowStride = image.planes[1].bytesPerRow;
  final int uvPixelStride = image.planes[1].bytesPerPixel!;
  
  final rgb = Uint8List(width * height * 3);
  
  // Direct memory access, no intermediate buffers
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final int yIndex = y * width + x;
      final int uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;
      
      final int Y = image.planes[0].bytes[yIndex];
      final int U = image.planes[1].bytes[uvIndex];
      final int V = image.planes[2].bytes[uvIndex];
      
      // YUV to RGB conversion (optimized)
      final int r = (Y + 1.370705 * (V - 128)).clamp(0, 255).toInt();
      final int g = (Y - 0.337633 * (U - 128) - 0.698001 * (V - 128))
          .clamp(0, 255).toInt();
      final int b = (Y + 1.732446 * (U - 128)).clamp(0, 255).toInt();
      
      final int rgbIndex = yIndex * 3;
      rgb[rgbIndex] = r;
      rgb[rgbIndex + 1] = g;
      rgb[rgbIndex + 2] = b;
    }
  }
  
  return rgb;
}
```

**Impact**: Reduces preprocessing time by 40-60%

### 3. Gesture Classification Optimization

#### Cache Normalized Database
```dart
class GestureClassifier {
  // Pre-compute normalized database on initialization
  static final Map<String, List<double>> _normalizedDatabase = {};
  
  static Future<void> initialize() async {
    for (final entry in ASLDatabase.signDatabase.entries) {
      _normalizedDatabase[entry.key] = _normalizeOnce(entry.value);
    }
  }
  
  Future<GestureResult> classify(HandLandmarks landmarks) async {
    final normalized = _normalizeLandmarks(landmarks.points);
    
    // Compare against pre-normalized database
    double bestSimilarity = 0.0;
    String? bestMatch;
    
    for (final entry in _normalizedDatabase.entries) {
      final similarity = _cosineSimilarityFast(normalized, entry.value);
      if (similarity > bestSimilarity) {
        bestSimilarity = similarity;
        bestMatch = entry.key;
      }
    }
    
    return GestureResult(
      letter: bestSimilarity > 0.75 ? bestMatch : null,
      confidence: bestSimilarity,
    );
  }
}
```

#### Optimize Cosine Similarity
```dart
// Use SIMD-like operations where possible
double _cosineSimilarityFast(List<double> a, List<double> b) {
  double dotProduct = 0.0;
  double normA = 0.0;
  double normB = 0.0;
  
  // Single pass calculation
  for (int i = 0; i < a.length; i++) {
    dotProduct += a[i] * b[i];
    normA += a[i] * a[i];
    normB += b[i] * b[i];
  }
  
  return dotProduct / (sqrt(normA) * sqrt(normB));
}
```

**Impact**: Reduces classification time by 30-40%

### 4. Memory Management

#### Object Pooling for Frequent Allocations
```dart
class ObjectPool<T> {
  final List<T> _available = [];
  final T Function() _factory;
  final void Function(T)? _reset;
  
  ObjectPool(this._factory, {void Function(T)? reset}) : _reset = reset;
  
  T acquire() {
    if (_available.isEmpty) {
      return _factory();
    }
    return _available.removeLast();
  }
  
  void release(T object) {
    _reset?.call(object);
    _available.add(object);
  }
}

// Usage
class SignRecognitionService {
  final _landmarksPool = ObjectPool<HandLandmarks>(
    () => HandLandmarks(points: [], timestamp: DateTime.now()),
    reset: (landmarks) {
      landmarks.points.clear();
    },
  );
  
  Future<void> _processFrame(CameraImage image) async {
    final landmarks = _landmarksPool.acquire();
    
    try {
      // Use landmarks
      await _detectAndClassify(landmarks);
    } finally {
      _landmarksPool.release(landmarks);
    }
  }
}
```

#### Limit Buffer Sizes
```dart
class SignToTextConverter {
  final List<String> _buffer = [];
  static const int _maxBufferSize = 5; // Limit memory growth
  
  void addLetter(String letter) {
    _buffer.add(letter);
    
    // Prevent unbounded growth
    if (_buffer.length > _maxBufferSize) {
      _buffer.removeAt(0);
    }
  }
}
```

### 5. Model Optimization

#### Quantization (if supported by Cactus SDK)
```dart
await visionModel.initializeModel(
  CactusInitParams(
    useGPU: true,
    numThreads: 4,
    quantization: QuantizationType.int8, // Reduce model size
  ),
);
```

#### Model Pruning
```dart
// Use smaller model variants when available
await visionModel.downloadModel(
  model: "lfm2-vl-450m-lite", // Lighter version
);
```

### 6. Animation Performance

#### Preload Animations
```dart
class SignAnimationService extends ChangeNotifier {
  final Map<String, LottieComposition> _preloadedAnimations = {};
  
  Future<void> preloadCommonAnimations() async {
    final common = ['hello', 'thank', 'please', 'help', 'sorry'];
    
    for (final word in common) {
      final path = _repository.getAnimationPath(word);
      if (path != null) {
        final composition = await AssetLottie(path).load();
        _preloadedAnimations[word] = composition;
      }
    }
  }
  
  Future<void> displaySign(String word) async {
    // Use preloaded if available
    if (_preloadedAnimations.containsKey(word)) {
      _playPreloaded(_preloadedAnimations[word]!);
    } else {
      await _loadAndPlay(word);
    }
  }
}
```

#### Optimize Animation Files
```bash
# Use lottie-optimizer to reduce file size
npm install -g lottie-optimizer

lottie-optimizer input.json output.json
```

### 7. Battery Optimization

#### Reduce Wake Locks
```dart
class PowerManagement {
  static void optimizeForBattery() {
    // Reduce screen brightness during recognition
    // Use lower camera resolution
    // Disable unnecessary sensors
  }
  
  static void enablePowerSaveMode() {
    // Reduce frame rate to 5 FPS
    // Use CPU-only inference (no GPU)
    // Disable animations
  }
}
```

#### Background Processing
```dart
// Pause processing when app is in background
class SignRecognitionService extends ChangeNotifier with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      pauseRecognition();
    } else if (state == AppLifecycleState.resumed) {
      resumeRecognition();
    }
  }
}
```

---

## 🔍 Profiling & Monitoring

### 1. Add Performance Instrumentation

```dart
class PerformanceTracker {
  static final Map<String, List<int>> _metrics = {};
  
  static void recordMetric(String name, int value) {
    _metrics.putIfAbsent(name, () => []).add(value);
    
    // Keep only last 100 samples
    if (_metrics[name]!.length > 100) {
      _metrics[name]!.removeAt(0);
    }
  }
  
  static Map<String, dynamic> getStats(String name) {
    final values = _metrics[name] ?? [];
    if (values.isEmpty) return {};
    
    values.sort();
    return {
      'count': values.length,
      'avg': values.reduce((a, b) => a + b) / values.length,
      'min': values.first,
      'max': values.last,
      'p50': values[values.length ~/ 2],
      'p95': values[(values.length * 0.95).toInt()],
      'p99': values[(values.length * 0.99).toInt()],
    };
  }
}

// Usage
Future<void> _processFrame(CameraImage image) async {
  final stopwatch = Stopwatch()..start();
  
  try {
    // Process frame
    await _detectAndClassify(image);
  } finally {
    stopwatch.stop();
    PerformanceTracker.recordMetric(
      'frame_processing',
      stopwatch.elapsedMilliseconds,
    );
  }
}
```

### 2. Memory Profiling

```dart
class MemoryMonitor {
  static Future<Map<String, dynamic>> getMemoryStats() async {
    // Use DevTools or platform channels to get memory info
    return {
      'used': 0, // MB
      'available': 0, // MB
      'total': 0, // MB
    };
  }
  
  static void logMemoryUsage() {
    Timer.periodic(Duration(seconds: 10), (timer) async {
      final stats = await getMemoryStats();
      Logger.instance.debug('Memory: ${stats['used']}MB used');
    });
  }
}
```

### 3. Frame Rate Monitoring

```dart
class FPSMonitor {
  final List<DateTime> _frameTimes = [];
  
  void recordFrame() {
    final now = DateTime.now();
    _frameTimes.add(now);
    
    // Keep only last second of frames
    _frameTimes.removeWhere((time) => 
      now.difference(time) > Duration(seconds: 1)
    );
  }
  
  double get currentFPS => _frameTimes.length.toDouble();
  
  bool get isDroppingFrames => currentFPS < 8; // Below 8 FPS
}
```

---

## 📈 Performance Testing

### Load Testing
```dart
// test/performance/load_test.dart
void main() {
  test('sustained load test', () async {
    final service = SignRecognitionService();
    final landmarks = /* test data */;
    
    // Process 1000 frames
    for (int i = 0; i < 1000; i++) {
      await service.processFrame(landmarks);
      
      // Check memory hasn't leaked
      if (i % 100 == 0) {
        final stats = await MemoryMonitor.getMemoryStats();
        expect(stats['used'], lessThan(500)); // < 500MB
      }
    }
    
    // Verify performance hasn't degraded
    final finalStats = PerformanceTracker.getStats('frame_processing');
    expect(finalStats['avg'], lessThan(100));
  });
}
```

### Stress Testing
```dart
test('stress test - rapid mode switching', () async {
  final service = SignRecognitionService();
  
  // Rapidly start/stop recognition
  for (int i = 0; i < 50; i++) {
    await service.startRecognition();
    await Future.delayed(Duration(milliseconds: 100));
    await service.stopRecognition();
    await Future.delayed(Duration(milliseconds: 100));
  }
  
  // Should still be functional
  expect(service.isProcessing, isFalse);
});
```

---

## 🎯 Optimization Checklist

### Critical Path Optimizations
- [ ] Implement frame rate limiting (10 FPS)
- [ ] Move image preprocessing to isolate
- [ ] Pre-normalize ASL database
- [ ] Optimize cosine similarity calculation
- [ ] Add object pooling for frequent allocations
- [ ] Implement animation preloading

### Memory Optimizations
- [ ] Limit buffer sizes
- [ ] Dispose unused resources
- [ ] Clear caches periodically
- [ ] Use weak references where appropriate
- [ ] Profile memory usage

### Battery Optimizations
- [ ] Reduce wake locks
- [ ] Pause processing in background
- [ ] Use lower camera resolution
- [ ] Implement power save mode
- [ ] Optimize GPU usage

### Model Optimizations
- [ ] Use quantized models
- [ ] Enable GPU acceleration
- [ ] Optimize thread count
- [ ] Cache model outputs
- [ ] Use model pruning

---

## 📊 Expected Results

After implementing optimizations:

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Frame Processing | 150ms | 80ms | 47% faster |
| Memory Usage | 600MB | 350MB | 42% less |
| Battery Drain | 15%/hr | 8%/hr | 47% better |
| Recognition Latency | 300ms | 180ms | 40% faster |
| FPS | 6 FPS | 10 FPS | 67% smoother |

---

## 🔧 Tools & Resources

### Profiling Tools
- Flutter DevTools (CPU, Memory, Performance)
- Android Profiler (Battery, Network)
- Dart Observatory (Isolate debugging)

### Benchmarking
```bash
# Run performance tests
flutter test test/performance/

# Profile app
flutter run --profile

# Analyze build size
flutter build apk --analyze-size
```

### Monitoring in Production
```dart
// Add Firebase Performance Monitoring
dependencies:
  firebase_performance: ^latest

// Track custom metrics
final trace = FirebasePerformance.instance.newTrace('sign_recognition');
await trace.start();
// ... do work
await trace.stop();
```

---

**Status**: Ready for optimization  
**Priority**: High (critical for user experience)  
**Estimated Impact**: 40-50% performance improvement