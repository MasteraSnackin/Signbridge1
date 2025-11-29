/// Cactus Model Service with Mock SDK Support
/// 
/// This file wraps the existing CactusModelService to add mock SDK support
/// for demo/testing purposes while keeping the integration guides valid.
/// 
/// USAGE:
/// - Import this file instead of cactus_model_service.dart in main.dart
/// - Set useMockSDK = true for demo mode
/// - Set useMockSDK = false when real Cactus SDK is integrated

import 'package:signbridge/core/services/cactus_model_service.dart';
import 'package:signbridge/core/services/mock_cactus_sdk.dart';
import 'package:signbridge/core/utils/logger.dart';

class CactusModelServiceWithMock {
  static final instance = CactusModelServiceWithMock._();
  CactusModelServiceWithMock._();

  static const String _tag = 'CactusModelServiceWithMock';
  
  // Toggle this flag to switch between mock and real SDK
  static const bool useMockSDK = true; // Set to false for production

  // Mock SDK instances
  MockCactusLM? _mockVisionModel;
  MockCactusLM? _mockTextModel;
  MockCactusSTT? _mockSpeechModel;

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  bool get isUsingMockSDK => useMockSDK;

  /// Initialize models (mock or real based on flag)
  Future<void> initialize() async {
    if (_isInitialized) {
      Logger.info('Models already initialized', _tag);
      return;
    }

    try {
      if (useMockSDK) {
        Logger.info('🎭 Using Mock Cactus SDK for demo/testing', _tag);
        await _initializeMockSDK();
      } else {
        Logger.info('🚀 Using Real Cactus SDK', _tag);
        await CactusModelService.instance.initialize();
      }
      
      _isInitialized = true;
      Logger.info('Models initialized successfully', _tag);
    } catch (e, stackTrace) {
      Logger.error(e, stackTrace, _tag);
      rethrow;
    }
  }

  /// Initialize mock SDK
  Future<void> _initializeMockSDK() async {
    _mockVisionModel = MockCactusLM();
    await _mockVisionModel!.downloadModel(model: "lfm2-vl-450m");
    await _mockVisionModel!.initializeModel(MockCactusInitParams(
      useGPU: true,
      numThreads: 4,
    ));

    _mockTextModel = MockCactusLM();
    await _mockTextModel!.downloadModel(model: "qwen3-0.6");
    await _mockTextModel!.initializeModel();

    _mockSpeechModel = MockCactusSTT();
    await _mockSpeechModel!.download(model: "whisper-tiny");
    await _mockSpeechModel!.init(model: "whisper-tiny");
  }

  /// Get vision model (mock or real)
  dynamic get visionModel {
    if (!_isInitialized) {
      throw StateError('Models not initialized');
    }
    return useMockSDK ? _mockVisionModel : CactusModelService.instance.visionModel;
  }

  /// Get text model (mock or real)
  dynamic get textModel {
    if (!_isInitialized) {
      throw StateError('Models not initialized');
    }
    return useMockSDK ? _mockTextModel : CactusModelService.instance.textModel;
  }

  /// Get speech model (mock or real)
  dynamic get speechModel {
    if (!_isInitialized) {
      throw StateError('Models not initialized');
    }
    return useMockSDK ? _mockSpeechModel : CactusModelService.instance.speechModel;
  }

  /// Check if models are downloaded
  Future<bool> areModelsDownloaded() async {
    if (useMockSDK) {
      return true; // Mock models are always "downloaded"
    }
    return CactusModelService.instance.isInitialized;
  }

  /// Get model information
  Future<Map<String, dynamic>> getModelInfo() async {
    if (useMockSDK) {
      return {
        'mode': 'mock',
        'vision': {'name': 'lfm2-vl-450m', 'status': 'mock', 'size': '450MB'},
        'text': {'name': 'qwen3-0.6', 'status': 'mock', 'size': '600MB'},
        'speech': {'name': 'whisper-tiny', 'status': 'mock', 'size': '40MB'},
      };
    }
    return await CactusModelService.instance.getModelInfo();
  }

  /// Dispose models
  Future<void> dispose() async {
    if (useMockSDK) {
      await _mockVisionModel?.dispose();
      await _mockTextModel?.dispose();
      await _mockSpeechModel?.dispose();
      _mockVisionModel = null;
      _mockTextModel = null;
      _mockSpeechModel = null;
    } else {
      CactusModelService.instance.dispose();
    }
    _isInitialized = false;
    Logger.info('Models disposed', _tag);
  }
}