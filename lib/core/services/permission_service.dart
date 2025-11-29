import 'package:permission_handler/permission_handler.dart';
import 'package:signbridge/config/permissions_config.dart';
import 'package:signbridge/core/utils/logger.dart';

/// Service for handling app permissions
class PermissionService {
  // Prevent instantiation
  PermissionService._();
  
  /// Request all required permissions
  static Future<bool> requestAllPermissions() async {
    Logger.info('Requesting all permissions', 'PERMISSION');
    
    bool allGranted = true;
    
    for (final permission in PermissionsConfig.requiredPermissions) {
      final granted = await requestPermission(permission);
      if (!granted) {
        allGranted = false;
        Logger.warning(
          'Required permission ${permission.toString()} not granted',
          'PERMISSION',
        );
      }
    }
    
    return allGranted;
  }
  
  /// Request a specific permission
  static Future<bool> requestPermission(Permission permission) async {
    final status = await permission.status;
    
    if (status.isGranted) {
      Logger.info(
        'Permission ${permission.toString()} already granted',
        'PERMISSION',
      );
      return true;
    }
    
    if (status.isDenied) {
      Logger.info(
        'Requesting permission ${permission.toString()}',
        'PERMISSION',
      );
      final result = await permission.request();
      return result.isGranted;
    }
    
    if (status.isPermanentlyDenied) {
      Logger.warning(
        'Permission ${permission.toString()} permanently denied',
        'PERMISSION',
      );
      return false;
    }
    
    return false;
  }
  
  /// Check if a specific permission is granted
  static Future<bool> isPermissionGranted(Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }
  
  /// Check if all required permissions are granted
  static Future<bool> areAllPermissionsGranted() async {
    for (final permission in PermissionsConfig.requiredPermissions) {
      if (!await isPermissionGranted(permission)) {
        return false;
      }
    }
    return true;
  }
  
  /// Request camera permission
  static Future<bool> requestCameraPermission() async {
    Logger.info('Requesting camera permission', 'PERMISSION');
    return requestPermission(Permission.camera);
  }
  
  /// Request microphone permission
  static Future<bool> requestMicrophonePermission() async {
    Logger.info('Requesting microphone permission', 'PERMISSION');
    return requestPermission(Permission.microphone);
  }
  
  /// Request storage permission
  static Future<bool> requestStoragePermission() async {
    Logger.info('Requesting storage permission', 'PERMISSION');
    return requestPermission(Permission.storage);
  }
  
  /// Check camera permission
  static Future<bool> hasCameraPermission() async {
    return isPermissionGranted(Permission.camera);
  }
  
  /// Check microphone permission
  static Future<bool> hasMicrophonePermission() async {
    return isPermissionGranted(Permission.microphone);
  }
  
  /// Check storage permission
  static Future<bool> hasStoragePermission() async {
    return isPermissionGranted(Permission.storage);
  }
  
  /// Open app settings
  static Future<void> openAppSettings() async {
    Logger.info('Opening app settings', 'PERMISSION');
    await openAppSettings();
  }
  
  /// Get permission status
  static Future<PermissionStatus> getPermissionStatus(
    Permission permission,
  ) async {
    return permission.status;
  }
  
  /// Get all permission statuses
  static Future<Map<Permission, PermissionStatus>> getAllPermissionStatuses() async {
    final statuses = <Permission, PermissionStatus>{};
    
    for (final permission in PermissionsConfig.allPermissions) {
      statuses[permission] = await permission.status;
    }
    
    return statuses;
  }
}