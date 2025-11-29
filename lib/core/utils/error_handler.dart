import 'package:flutter/material.dart';
import 'package:signbridge/core/utils/logger.dart';

/// Centralized error handling utility
class ErrorHandler {
  // Prevent instantiation
  ErrorHandler._();
  
  /// Handle any error with context
  static Future<void> handleError(
    dynamic error,
    ErrorContext context, {
    StackTrace? stackTrace,
    VoidCallback? onRetry,
  }) async {
    // Log the error
    Logger.error(error, stackTrace, context.name);
    
    // Determine error type and handle accordingly
    if (error is CameraException) {
      await _handleCameraError(error, context);
    } else if (error is ModelException) {
      await _handleModelError(error, context);
    } else if (error is NetworkException) {
      await _handleNetworkError(error, context);
    } else if (error is PermissionException) {
      await _handlePermissionError(error, context);
    } else {
      await _handleGenericError(error, context);
    }
  }
  
  static Future<void> _handleCameraError(
    CameraException error,
    ErrorContext context,
  ) async {
    Logger.error('Camera error: ${error.message}', null, 'CAMERA');
    // Camera errors are usually recoverable by restarting
  }
  
  static Future<void> _handleModelError(
    ModelException error,
    ErrorContext context,
  ) async {
    Logger.error('Model error: ${error.message}', null, 'MODEL');
    // Model errors might require re-initialization
  }
  
  static Future<void> _handleNetworkError(
    NetworkException error,
    ErrorContext context,
  ) async {
    Logger.error('Network error: ${error.message}', null, 'NETWORK');
    // Network errors should fallback to local processing
  }
  
  static Future<void> _handlePermissionError(
    PermissionException error,
    ErrorContext context,
  ) async {
    Logger.error('Permission error: ${error.message}', null, 'PERMISSION');
    // Permission errors require user action
  }
  
  static Future<void> _handleGenericError(
    dynamic error,
    ErrorContext context,
  ) async {
    Logger.error('Generic error: $error', null, 'ERROR');
  }
  
  /// Show error dialog to user
  static Future<void> showErrorDialog(
    BuildContext context,
    String title,
    String message, {
    VoidCallback? onRetry,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Retry'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Context for error handling
enum ErrorContext {
  initialization,
  cameraAccess,
  microphoneAccess,
  modelLoading,
  signRecognition,
  speechRecognition,
  animation,
  cloudFallback,
  storage,
}

/// Custom exception types
class CameraException implements Exception {
  final String message;
  CameraException(this.message);
  
  @override
  String toString() => 'CameraException: $message';
}

class ModelException implements Exception {
  final String message;
  ModelException(this.message);
  
  @override
  String toString() => 'ModelException: $message';
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}

class PermissionException implements Exception {
  final String message;
  PermissionException(this.message);
  
  @override
  String toString() => 'PermissionException: $message';
}