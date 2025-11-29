import 'package:permission_handler/permission_handler.dart';

/// Configuration for app permissions
class PermissionsConfig {
  // Prevent instantiation
  PermissionsConfig._();
  
  /// Required permissions for core functionality
  static const List<Permission> requiredPermissions = [
    Permission.camera,
    Permission.microphone,
    Permission.storage,
  ];
  
  /// Optional permissions for enhanced features
  static const List<Permission> optionalPermissions = [
    Permission.internet,
  ];
  
  /// All permissions (required + optional)
  static List<Permission> get allPermissions => [
    ...requiredPermissions,
    ...optionalPermissions,
  ];
  
  /// Permission descriptions for user-facing dialogs
  static const Map<Permission, String> permissionDescriptions = {
    Permission.camera: 
        'Camera access is required to capture hand gestures for sign language recognition.',
    Permission.microphone: 
        'Microphone access is required to capture speech for speech-to-sign translation.',
    Permission.storage: 
        'Storage access is required to download and store AI models for offline operation.',
    Permission.internet: 
        'Internet access is optional and only used for cloud-based recognition when enabled in settings.',
  };
  
  /// Permission rationale titles
  static const Map<Permission, String> permissionTitles = {
    Permission.camera: 'Camera Permission',
    Permission.microphone: 'Microphone Permission',
    Permission.storage: 'Storage Permission',
    Permission.internet: 'Internet Permission',
  };
}