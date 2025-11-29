/// Mock Cactus SDK Implementation for Testing/Demo
/// 
/// This file provides a mock implementation of the Cactus SDK that simulates
/// the behavior of the real SDK without requiring the actual package.
/// 
/// USE THIS FOR:
/// - Development and testing without real SDK
/// - Demo purposes
/// - Understanding the SDK interface
/// 
/// REPLACE WITH REAL SDK:
/// - Follow CACTUS_SDK_INTEGRATION_GUIDE.md
/// - Remove this file when integrating actual Cactus SDK

import 'dart:async';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:signbridge/core/models/hand_landmarks.dart';
import 'package:signbridge/core/models/point_3d.dart';
import 'package:signbridge/core/utils/logger.dart';

/// Mock Vision Model (simulates LFM2-VL-450M)
class MockCactusLM {
  static const String _tag = 'MockCactusLM';
  bool _isInitialized = false;
  final _random = math.Random();

  Future<void> downloadModel({required String model}) async {
    Logger.info('Mock: Downloading model $model...', _tag);
    await Future.delayed(Duration(milliseconds: 500));
    Logger.info('Mock: Model $model downloaded', _tag);
  }

  Future<void> initializeModel([MockCactusInitParams? params]) async {
    Logger.info('Mock: Initializing model...', _tag);
    await Future.delayed(Duration(milliseconds: 300));
    _isInitialized = true;
    Logger.info('Mock: Model initialized', _tag);
  }

  Future<MockCompletionResult> generateCompletion({
    required List<MockChatMessage> messages,
    double temperature = 0.7,
    int maxTokens = 512,
  }) async {
    if (!_isInitialized) {
      throw StateError('Model not initialized');
    }

    // Simulate processing time
    await Future.delayed(Duration(milliseconds: 50 + _random.nextInt(50)));

    // Generate mock hand landmarks
    final landmarks = _generateMockLandmarks();

    return MockCompletionResult(
      response: _formatLandmarksAsJson(landmarks),
      confidence: 0.85 + _random.nextDouble() * 0.15,
    );
  }

  List<Point3D> _generateMockLandmarks() {
    // Generate 21 realistic hand landmark points
    // These are normalized coordinates similar to MediaPipe format
    return List.generate(21, (i) {
      // Create a hand-like shape
      final angle = (i / 21) * math.pi * 2;
      final radius = 0.3 + (i % 5) * 0.1;
      
      return Point3D(
        0.5 + math.cos(angle) * radius + (_random.nextDouble() - 0.5) * 0.05,
        0.5 + math.sin(angle) * radius + (_random.nextDouble() - 0.5) * 0.05,
        (_random.nextDouble() - 0.5) * 0.1,
      );
    });
  }

  String _formatLandmarksAsJson(List<Point3D> landmarks) {
    final landmarksJson = landmarks.map((p) => 
      '{"x": ${p.x.toStringAsFixed(4)}, "y": ${p.y.toStringAsFixed(4)}, "z": ${p.z.toStringAsFixed(4)}}'
    ).join(', ');
    
    return '{"landmarks": [$landmarksJson], "confidence": ${0.85 + _random.nextDouble() * 0.15}}';
  }

  Future<bool> isModelDownloaded(String model) async {
    return true; // Mock: always downloaded
  }

  Future<Map<String, dynamic>> getModelInfo(String model) async {
    return {
      'name': model,
      'size': '450MB',
      'version': '1.0.0',
      'downloaded': true,
    };
  }

  Future<void> dispose() async {
    _isInitialized = false;
    Logger.info('Mock: Model disposed', _tag);
  }
}

/// Mock Speech-to-Text Model (simulates Whisper-Tiny)
class MockCactusSTT {
  static const String _tag = 'MockCactusSTT';
  bool _isInitialized = false;
  bool _isRecording = false;
  final _random = math.Random();

  // Sample phrases for mock transcription
  final List<String> _samplePhrases = [
    'Hello',
    'Thank you',
    'Please help me',
    'I need assistance',
    'Good morning',
    'How are you',
    'Nice to meet you',
    'See you later',
    'Have a good day',
    'I understand',
  ];

  Future<void> download({required String model}) async {
    Logger.info('Mock: Downloading STT model $model...', _tag);
    await Future.delayed(Duration(milliseconds: 500));
    Logger.info('Mock: STT model $model downloaded', _tag);
  }

  Future<void> init({required String model, String language = 'en'}) async {
    Logger.info('Mock: Initializing STT model...', _tag);
    await Future.delayed(Duration(milliseconds: 300));
    _isInitialized = true;
    Logger.info('Mock: STT model initialized', _tag);
  }

  Future<void> startRecording() async {
    if (!_isInitialized) {
      throw StateError('STT model not initialized');
    }
    _isRecording = true;
    Logger.info('Mock: Started recording', _tag);
  }

  Future<MockTranscriptionResult?> stopRecording() async {
    if (!_isRecording) {
      return null;
    }

    _isRecording = false;
    
    // Simulate transcription processing
    await Future.delayed(Duration(milliseconds: 200 + _random.nextInt(300)));

    // Return random sample phrase
    final text = _samplePhrases[_random.nextInt(_samplePhrases.length)];
    
    Logger.info('Mock: Transcribed: "$text"', _tag);

    return MockTranscriptionResult(
      text: text,
      confidence: 0.80 + _random.nextDouble() * 0.20,
      language: 'en',
    );
  }

  Future<MockTranscriptionResult?> transcribe() async {
    await startRecording();
    await Future.delayed(Duration(seconds: 2)); // Simulate recording time
    return await stopRecording();
  }

  Future<bool> isModelDownloaded(String model) async {
    return true; // Mock: always downloaded
  }

  Future<void> dispose() async {
    _isInitialized = false;
    _isRecording = false;
    Logger.info('Mock: STT model disposed', _tag);
  }
}

/// Mock initialization parameters
class MockCactusInitParams {
  final bool useGPU;
  final int numThreads;
  final int maxTokens;

  MockCactusInitParams({
    this.useGPU = true,
    this.numThreads = 4,
    this.maxTokens = 512,
  });
}

/// Mock chat message
class MockChatMessage {
  final String content;
  final String role;
  final List<MockCactusImage>? images;

  MockChatMessage({
    required this.content,
    required this.role,
    this.images,
  });
}

/// Mock image input
class MockCactusImage {
  final Uint8List bytes;
  final int width;
  final int height;

  MockCactusImage({
    required this.bytes,
    required this.width,
    required this.height,
  });

  static MockCactusImage fromBytes(
    Uint8List bytes, {
    required int width,
    required int height,
    String format = 'rgb',
  }) {
    return MockCactusImage(
      bytes: bytes,
      width: width,
      height: height,
    );
  }
}

/// Mock completion result
class MockCompletionResult {
  final String response;
  final double confidence;

  MockCompletionResult({
    required this.response,
    required this.confidence,
  });
}

/// Mock transcription result
class MockTranscriptionResult {
  final String text;
  final double confidence;
  final String language;

  MockTranscriptionResult({
    required this.text,
    required this.confidence,
    required this.language,
  });
}

/// Mock Cactus SDK Service (drop-in replacement for CactusModelService)
class MockCactusModelService {
  static final instance = MockCactusModelService._();
  MockCactusModelService._();

  MockCactusLM? visionModel;
  MockCactusLM? textModel;
  MockCactusSTT? speechModel;

  static const String _tag = 'MockCactusModelService';

  Future<void> initialize() async {
    try {
      Logger.info('Mock: Initializing Cactus SDK models...', _tag);

      // Initialize Vision Model
      visionModel = MockCactusLM();
      await visionModel!.downloadModel(model: "lfm2-vl-450m");
      await visionModel!.initializeModel(MockCactusInitParams(
        useGPU: true,
        numThreads: 4,
      ));

      // Initialize Text Model
      textModel = MockCactusLM();
      await textModel!.downloadModel(model: "qwen3-0.6");
      await textModel!.initializeModel();

      // Initialize Speech Model
      speechModel = MockCactusSTT();
      await speechModel!.download(model: "whisper-tiny");
      await speechModel!.init(model: "whisper-tiny");

      Logger.info('Mock: All Cactus models initialized successfully', _tag);
    } catch (e, stackTrace) {
      Logger.error(e, stackTrace, _tag);
      rethrow;
    }
  }

  Future<bool> areModelsDownloaded() async {
    return true; // Mock: always downloaded
  }

  Future<Map<String, dynamic>> getModelInfo() async {
    return {
      'vision': await visionModel?.getModelInfo("lfm2-vl-450m"),
      'text': await textModel?.getModelInfo("qwen3-0.6"),
      'speech': {'name': 'whisper-tiny', 'downloaded': true},
    };
  }

  Future<void> dispose() async {
    await visionModel?.dispose();
    await textModel?.dispose();
    await speechModel?.dispose();
    Logger.info('Mock: All models disposed', _tag);
  }
}