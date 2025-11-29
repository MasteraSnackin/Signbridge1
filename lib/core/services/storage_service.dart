import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:signbridge/core/utils/logger.dart';
import 'package:signbridge/core/models/performance_metrics.dart';

/// Service for managing app storage and persistence
class StorageService {
  // Singleton instance
  static final StorageService instance = StorageService._();
  
  StorageService._();
  
  SharedPreferences? _prefs;
  
  // Storage keys
  static const String _keyHybridModeEnabled = 'hybrid_mode_enabled';
  static const String _keyShowDebugInfo = 'show_debug_info';
  static const String _keyConfidenceThreshold = 'confidence_threshold';
  static const String _keyTTSSpeechRate = 'tts_speech_rate';
  static const String _keyTTSVolume = 'tts_volume';
  static const String _keyTTSPitch = 'tts_pitch';
  static const String _keyFirstLaunch = 'first_launch';
  static const String _keyPerformanceMetrics = 'performance_metrics';
  
  /// Initialize storage service
  Future<void> initialize() async {
    try {
      Logger.info('Initializing storage service...', 'STORAGE');
      _prefs = await SharedPreferences.getInstance();
      Logger.info('Storage service initialized', 'STORAGE');
    } catch (e, stackTrace) {
      Logger.error(e, stackTrace, 'STORAGE');
      rethrow;
    }
  }
  
  /// Ensure preferences are loaded
  Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await initialize();
    }
  }
  
  // ============================================================================
  // APP SETTINGS
  // ============================================================================
  
  /// Get hybrid mode enabled status
  Future<bool> getHybridModeEnabled() async {
    await _ensureInitialized();
    return _prefs!.getBool(_keyHybridModeEnabled) ?? false;
  }
  
  /// Set hybrid mode enabled status
  Future<void> setHybridModeEnabled(bool enabled) async {
    await _ensureInitialized();
    await _prefs!.setBool(_keyHybridModeEnabled, enabled);
    Logger.info('Hybrid mode set to: $enabled', 'STORAGE');
  }
  
  /// Get show debug info status
  Future<bool> getShowDebugInfo() async {
    await _ensureInitialized();
    return _prefs!.getBool(_keyShowDebugInfo) ?? false;
  }
  
  /// Set show debug info status
  Future<void> setShowDebugInfo(bool show) async {
    await _ensureInitialized();
    await _prefs!.setBool(_keyShowDebugInfo, show);
    Logger.info('Show debug info set to: $show', 'STORAGE');
  }
  
  /// Get confidence threshold
  Future<double> getConfidenceThreshold() async {
    await _ensureInitialized();
    return _prefs!.getDouble(_keyConfidenceThreshold) ?? 0.75;
  }
  
  /// Set confidence threshold
  Future<void> setConfidenceThreshold(double threshold) async {
    await _ensureInitialized();
    await _prefs!.setDouble(_keyConfidenceThreshold, threshold);
    Logger.info('Confidence threshold set to: $threshold', 'STORAGE');
  }
  
  // ============================================================================
  // TTS SETTINGS
  // ============================================================================
  
  /// Get TTS speech rate
  Future<double> getTTSSpeechRate() async {
    await _ensureInitialized();
    return _prefs!.getDouble(_keyTTSSpeechRate) ?? 0.5;
  }
  
  /// Set TTS speech rate
  Future<void> setTTSSpeechRate(double rate) async {
    await _ensureInitialized();
    await _prefs!.setDouble(_keyTTSSpeechRate, rate);
    Logger.info('TTS speech rate set to: $rate', 'STORAGE');
  }
  
  /// Get TTS volume
  Future<double> getTTSVolume() async {
    await _ensureInitialized();
    return _prefs!.getDouble(_keyTTSVolume) ?? 1.0;
  }
  
  /// Set TTS volume
  Future<void> setTTSVolume(double volume) async {
    await _ensureInitialized();
    await _prefs!.setDouble(_keyTTSVolume, volume);
    Logger.info('TTS volume set to: $volume', 'STORAGE');
  }
  
  /// Get TTS pitch
  Future<double> getTTSPitch() async {
    await _ensureInitialized();
    return _prefs!.getDouble(_keyTTSPitch) ?? 1.0;
  }
  
  /// Set TTS pitch
  Future<void> setTTSPitch(double pitch) async {
    await _ensureInitialized();
    await _prefs!.setDouble(_keyTTSPitch, pitch);
    Logger.info('TTS pitch set to: $pitch', 'STORAGE');
  }
  
  // ============================================================================
  // APP STATE
  // ============================================================================
  
  /// Check if this is first launch
  Future<bool> isFirstLaunch() async {
    await _ensureInitialized();
    return _prefs!.getBool(_keyFirstLaunch) ?? true;
  }
  
  /// Mark first launch as complete
  Future<void> setFirstLaunchComplete() async {
    await _ensureInitialized();
    await _prefs!.setBool(_keyFirstLaunch, false);
    Logger.info('First launch marked as complete', 'STORAGE');
  }
  
  // ============================================================================
  // PERFORMANCE METRICS
  // ============================================================================
  
  /// Save performance metrics
  Future<void> savePerformanceMetrics(PerformanceMetrics metrics) async {
    await _ensureInitialized();
    final json = jsonEncode(metrics.toJson());
    await _prefs!.setString(_keyPerformanceMetrics, json);
    Logger.debug('Performance metrics saved', 'STORAGE');
  }
  
  /// Load performance metrics
  Future<PerformanceMetrics?> loadPerformanceMetrics() async {
    await _ensureInitialized();
    final json = _prefs!.getString(_keyPerformanceMetrics);
    
    if (json == null) return null;
    
    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      return PerformanceMetrics.fromJson(data);
    } catch (e) {
      Logger.error('Failed to load performance metrics: $e', null, 'STORAGE');
      return null;
    }
  }
  
  /// Clear performance metrics
  Future<void> clearPerformanceMetrics() async {
    await _ensureInitialized();
    await _prefs!.remove(_keyPerformanceMetrics);
    Logger.info('Performance metrics cleared', 'STORAGE');
  }
  
  // ============================================================================
  // FILE STORAGE
  // ============================================================================
  
  /// Get app documents directory
  Future<Directory> getDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }
  
  /// Get app cache directory
  Future<Directory> getCacheDirectory() async {
    return await getTemporaryDirectory();
  }
  
  /// Get models directory
  Future<Directory> getModelsDirectory() async {
    final docs = await getDocumentsDirectory();
    final modelsDir = Directory('${docs.path}/models');
    
    if (!await modelsDir.exists()) {
      await modelsDir.create(recursive: true);
    }
    
    return modelsDir;
  }
  
  /// Save file to documents directory
  Future<File> saveFile(String filename, List<int> bytes) async {
    final docs = await getDocumentsDirectory();
    final file = File('${docs.path}/$filename');
    await file.writeAsBytes(bytes);
    Logger.info('File saved: $filename', 'STORAGE');
    return file;
  }
  
  /// Read file from documents directory
  Future<List<int>?> readFile(String filename) async {
    try {
      final docs = await getDocumentsDirectory();
      final file = File('${docs.path}/$filename');
      
      if (!await file.exists()) {
        Logger.warning('File not found: $filename', 'STORAGE');
        return null;
      }
      
      return await file.readAsBytes();
    } catch (e) {
      Logger.error('Failed to read file: $e', null, 'STORAGE');
      return null;
    }
  }
  
  /// Delete file from documents directory
  Future<bool> deleteFile(String filename) async {
    try {
      final docs = await getDocumentsDirectory();
      final file = File('${docs.path}/$filename');
      
      if (await file.exists()) {
        await file.delete();
        Logger.info('File deleted: $filename', 'STORAGE');
        return true;
      }
      
      return false;
    } catch (e) {
      Logger.error('Failed to delete file: $e', null, 'STORAGE');
      return false;
    }
  }
  
  /// Get storage usage info
  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final docs = await getDocumentsDirectory();
      final cache = await getCacheDirectory();
      
      final docsSize = await _getDirectorySize(docs);
      final cacheSize = await _getDirectorySize(cache);
      
      return {
        'documentsPath': docs.path,
        'documentsSize': docsSize,
        'cachePath': cache.path,
        'cacheSize': cacheSize,
        'totalSize': docsSize + cacheSize,
      };
    } catch (e) {
      Logger.error('Failed to get storage info: $e', null, 'STORAGE');
      return {};
    }
  }
  
  /// Calculate directory size
  Future<int> _getDirectorySize(Directory directory) async {
    int size = 0;
    
    try {
      if (await directory.exists()) {
        await for (final entity in directory.list(recursive: true)) {
          if (entity is File) {
            size += await entity.length();
          }
        }
      }
    } catch (e) {
      Logger.error('Failed to calculate directory size: $e', null, 'STORAGE');
    }
    
    return size;
  }
  
  /// Clear cache
  Future<void> clearCache() async {
    try {
      final cache = await getCacheDirectory();
      
      if (await cache.exists()) {
        await for (final entity in cache.list()) {
          await entity.delete(recursive: true);
        }
      }
      
      Logger.info('Cache cleared', 'STORAGE');
    } catch (e) {
      Logger.error('Failed to clear cache: $e', null, 'STORAGE');
    }
  }
  
  // ============================================================================
  // UTILITY METHODS
  // ============================================================================
  
  /// Clear all app data
  Future<void> clearAllData() async {
    await _ensureInitialized();
    await _prefs!.clear();
    await clearCache();
    Logger.info('All app data cleared', 'STORAGE');
  }
  
  /// Export all settings as JSON
  Future<String> exportSettings() async {
    await _ensureInitialized();
    
    final settings = {
      'hybridModeEnabled': await getHybridModeEnabled(),
      'showDebugInfo': await getShowDebugInfo(),
      'confidenceThreshold': await getConfidenceThreshold(),
      'ttsSpeechRate': await getTTSSpeechRate(),
      'ttsVolume': await getTTSVolume(),
      'ttsPitch': await getTTSPitch(),
    };
    
    return jsonEncode(settings);
  }
  
  /// Import settings from JSON
  Future<void> importSettings(String json) async {
    try {
      final settings = jsonDecode(json) as Map<String, dynamic>;
      
      if (settings.containsKey('hybridModeEnabled')) {
        await setHybridModeEnabled(settings['hybridModeEnabled'] as bool);
      }
      if (settings.containsKey('showDebugInfo')) {
        await setShowDebugInfo(settings['showDebugInfo'] as bool);
      }
      if (settings.containsKey('confidenceThreshold')) {
        await setConfidenceThreshold(
          (settings['confidenceThreshold'] as num).toDouble(),
        );
      }
      if (settings.containsKey('ttsSpeechRate')) {
        await setTTSSpeechRate((settings['ttsSpeechRate'] as num).toDouble());
      }
      if (settings.containsKey('ttsVolume')) {
        await setTTSVolume((settings['ttsVolume'] as num).toDouble());
      }
      if (settings.containsKey('ttsPitch')) {
        await setTTSPitch((settings['ttsPitch'] as num).toDouble());
      }
      
      Logger.info('Settings imported successfully', 'STORAGE');
    } catch (e) {
      Logger.error('Failed to import settings: $e', null, 'STORAGE');
      rethrow;
    }
  }
}