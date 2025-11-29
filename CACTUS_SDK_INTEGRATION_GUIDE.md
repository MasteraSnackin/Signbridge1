# Cactus SDK Integration Guide

This guide provides step-by-step instructions for integrating the actual Cactus SDK into the SignBridge application.

---

## 📋 Prerequisites

- Cactus SDK package access
- API keys (if required)
- Flutter development environment
- Android device or emulator

---

## 🔧 Integration Steps

### Step 1: Add Cactus SDK Dependency

Update `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Add Cactus SDK
  cactus: ^latest_version  # Replace with actual version
  
  # Or if using local package
  cactus:
    path: ../cactus_sdk
```

Run:
```bash
flutter pub get
```

### Step 2: Update CactusModelService

**File**: `lib/core/services/cactus_model_service.dart`

Replace the placeholder implementation with actual Cactus SDK calls:

```dart
import 'package:cactus/cactus.dart';  // Import actual SDK

class CactusModelService {
  static final instance = CactusModelService._();
  CactusModelService._internal();
  
  // Replace placeholders with actual SDK instances
  CactusLM? visionModel;
  CactusLM? textModel;
  CactusSTT? speechModel;
  
  Future<void> initialize() async {
    try {
      _logger.info('Initializing Cactus SDK models...');
      
      // Initialize Vision Model (LFM2-VL-450M)
      visionModel = CactusLM();
      await visionModel!.downloadModel(
        model: "lfm2-vl-450m",
        onProgress: (progress) {
          _logger.debug('Vision model download: ${progress}%');
        },
      );
      
      await visionModel!.initializeModel(
        CactusInitParams(
          useGPU: true,
          numThreads: 4,
          maxTokens: 512,
        ),
      );
      
      // Initialize Text Model (Qwen3-0.6B)
      textModel = CactusLM();
      await textModel!.downloadModel(
        model: "qwen3-0.6",
        onProgress: (progress) {
          _logger.debug('Text model download: ${progress}%');
        },
      );
      
      await textModel!.initializeModel(
        CactusInitParams(
          useGPU: true,
          numThreads: 2,
        ),
      );
      
      // Initialize Speech Model (Whisper-Tiny)
      speechModel = CactusSTT();
      await speechModel!.download(
        model: "whisper-tiny",
        onProgress: (progress) {
          _logger.debug('Speech model download: ${progress}%');
        },
      );
      
      await speechModel!.init(
        model: "whisper-tiny",
        language: "en",
      );
      
      _logger.info('All Cactus models initialized successfully');
    } catch (e, stackTrace) {
      _logger.error('Failed to initialize Cactus models', e, stackTrace);
      rethrow;
    }
  }
  
  // Add method to check if models are downloaded
  Future<bool> areModelsDownloaded() async {
    try {
      final visionExists = await visionModel?.isModelDownloaded("lfm2-vl-450m") ?? false;
      final textExists = await textModel?.isModelDownloaded("qwen3-0.6") ?? false;
      final speechExists = await speechModel?.isModelDownloaded("whisper-tiny") ?? false;
      
      return visionExists && textExists && speechExists;
    } catch (e) {
      return false;
    }
  }
  
  // Add method to get model info
  Future<Map<String, dynamic>> getModelInfo() async {
    return {
      'vision': await visionModel?.getModelInfo("lfm2-vl-450m"),
      'text': await textModel?.getModelInfo("qwen3-0.6"),
      'speech': await speechModel?.getModelInfo("whisper-tiny"),
    };
  }
}
```

### Step 3: Update Hand Landmark Detector

**File**: `lib/features/sign_recognition/hand_landmark_detector.dart`

Replace the `_detectLandmarks` method:

```dart
Future<HandLandmarks?> _detectLandmarks(Uint8List imageData) async {
  try {
    final visionModel = CactusModelService.instance.visionModel;
    
    if (visionModel == null) {
      throw StateError('Vision model not initialized');
    }
    
    // Prepare image for vision model
    final imageInput = CactusImage.fromBytes(
      imageData,
      width: targetWidth,
      height: targetHeight,
      format: ImageFormat.rgb,
    );
    
    // Run inference
    final result = await visionModel.generateCompletion(
      messages: [
        ChatMessage(
          content: "Detect hand landmarks in this image. "
              "Return 21 3D coordinates (x, y, z) in JSON format.",
          role: "user",
          images: [imageInput],
        ),
      ],
      temperature: 0.1,  // Low temperature for consistent output
      maxTokens: 512,
    );
    
    // Parse response
    final landmarks = _parseModelResponse(result.response);
    
    return landmarks;
  } catch (e, stackTrace) {
    _logger.error('Error detecting landmarks', e, stackTrace);
    return null;
  }
}

HandLandmarks? _parseModelResponse(String response) {
  try {
    // Parse JSON response from vision model
    final json = jsonDecode(response);
    
    // Expected format:
    // {
    //   "landmarks": [
    //     {"x": 0.5, "y": 0.5, "z": 0.0},
    //     ...
    //   ],
    //   "confidence": 0.95
    // }
    
    final landmarksData = json['landmarks'] as List;
    final confidence = (json['confidence'] as num?)?.toDouble() ?? 0.0;
    
    if (landmarksData.length != 21) {
      _logger.warning('Invalid number of landmarks: ${landmarksData.length}');
      return null;
    }
    
    final points = landmarksData.map((data) {
      return Point3D(
        (data['x'] as num).toDouble(),
        (data['y'] as num).toDouble(),
        (data['z'] as num).toDouble(),
      );
    }).toList();
    
    return HandLandmarks(
      points: points,
      timestamp: DateTime.now(),
      confidence: confidence,
    );
  } catch (e, stackTrace) {
    _logger.error('Error parsing model response', e, stackTrace);
    return null;
  }
}
```

### Step 4: Update Speech Recognition Service

**File**: `lib/features/speech_recognition/speech_recognition_service.dart`

Replace the `_finalizeTranscription` method:

```dart
Future<void> _finalizeTranscription() async {
  final stopwatch = Stopwatch()..start();
  
  try {
    final speechModel = CactusModelService.instance.speechModel;
    
    if (speechModel == null) {
      throw StateError('Speech model not initialized');
    }
    
    _logger.debug('Starting transcription...');
    
    // Start audio recording
    await speechModel.startRecording();
    
    // Wait for recording to complete (or use streaming)
    await Future.delayed(Duration(seconds: 3));
    
    // Stop recording and get transcription
    final transcription = await speechModel.stopRecording();
    
    if (transcription != null && transcription.text.isNotEmpty) {
      _transcribedText = transcription.text;
      _confidence = transcription.confidence ?? 0.0;
      
      // Split into words
      _wordsToSign = _transcribedText
          .split(RegExp(r'\s+'))
          .where((word) => word.isNotEmpty)
          .toList();
      
      _totalWords += _wordsToSign.length;
      _recognitionCount++;
      
      stopwatch.stop();
      
      // Create result
      final result = SpeechRecognitionResult(
        text: _transcribedText,
        confidence: _confidence,
        isFinal: true,
        processingTime: stopwatch.elapsedMilliseconds,
        timestamp: DateTime.now(),
      );
      
      // Record performance
      _performanceMonitor.recordLatency(
        operation: 'speech_recognition',
        duration: stopwatch.elapsed,
        source: ProcessingSource.local,
      );
      
      // Emit result
      _resultController.add(result);
      
      _logger.info(
        'Transcription: "$_transcribedText" '
        '(${_wordsToSign.length} words, '
        'confidence: ${_confidence.toStringAsFixed(2)}, '
        '${stopwatch.elapsedMilliseconds}ms)'
      );
    }
  } catch (e, stackTrace) {
    _logger.error('Error in transcription', e, stackTrace);
  }
}
```

### Step 5: Test Integration

Create a test file to verify integration:

```dart
// test/cactus_integration_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:signbridge/core/services/cactus_model_service.dart';

void main() {
  group('Cactus SDK Integration', () {
    test('Models initialize successfully', () async {
      final service = CactusModelService.instance;
      
      await service.initialize();
      
      expect(service.visionModel, isNotNull);
      expect(service.textModel, isNotNull);
      expect(service.speechModel, isNotNull);
    });
    
    test('Models are downloaded', () async {
      final service = CactusModelService.instance;
      
      final downloaded = await service.areModelsDownloaded();
      
      expect(downloaded, isTrue);
    });
    
    test('Vision model processes image', () async {
      final service = CactusModelService.instance;
      
      // Create test image
      final testImage = Uint8List(224 * 224 * 3);
      
      // Process with vision model
      final result = await service.visionModel!.generateCompletion(
        messages: [
          ChatMessage(
            content: "Test",
            role: "user",
            images: [CactusImage.fromBytes(testImage, width: 224, height: 224)],
          ),
        ],
      );
      
      expect(result.response, isNotEmpty);
    });
  });
}
```

---

## 🔍 Troubleshooting

### Model Download Issues

If models fail to download:

```dart
// Check storage space
final storage = await StorageService.instance.getStorageInfo();
print('Available space: ${storage['availableSpace']}');

// Clear cache if needed
await StorageService.instance.clearCache();

// Retry download
await CactusModelService.instance.initialize();
```

### Performance Issues

If inference is slow:

```dart
// Reduce image resolution
static const int targetWidth = 192;  // Instead of 224
static const int targetHeight = 192;

// Use fewer threads
CactusInitParams(
  useGPU: true,
  numThreads: 2,  // Instead of 4
)

// Reduce frame rate
static const int targetFPS = 5;  // Instead of 10
```

### Memory Issues

If app crashes due to memory:

```dart
// Dispose models when not in use
await visionModel?.dispose();
await textModel?.dispose();
await speechModel?.dispose();

// Reduce buffer sizes
final int _maxBufferSize = 3;  // Instead of 10
```

---

## 📊 Verification Checklist

- [ ] Cactus SDK dependency added to pubspec.yaml
- [ ] Models download successfully
- [ ] Vision model detects hand landmarks
- [ ] Speech model transcribes audio
- [ ] Text model provides predictions (optional)
- [ ] Performance is acceptable (< 200ms per frame)
- [ ] Memory usage is reasonable (< 500MB)
- [ ] No crashes or errors in logs
- [ ] Integration tests pass

---

## 📞 Support

If you encounter issues:

1. Check Cactus SDK documentation
2. Review error logs in `Logger` output
3. Test with sample data first
4. Verify model files are downloaded
5. Check device compatibility

---

## 🎯 Next Steps

After successful integration:

1. Test with real camera input
2. Optimize performance
3. Add error recovery
4. Implement model updates
5. Add telemetry (optional)

---

**Integration Status**: Ready for Cactus SDK  
**Estimated Time**: 2-4 hours  
**Difficulty**: Medium