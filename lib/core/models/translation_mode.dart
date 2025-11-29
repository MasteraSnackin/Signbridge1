/// Translation mode for the application
enum TranslationMode {
  /// Sign language to speech
  signToSpeech,
  
  /// Speech to sign language
  speechToSign,
}

/// Extension to get display information for TranslationMode
extension TranslationModeExtension on TranslationMode {
  /// Get human-readable name
  String get displayName {
    switch (this) {
      case TranslationMode.signToSpeech:
        return 'Sign to Speech';
      case TranslationMode.speechToSign:
        return 'Speech to Sign';
    }
  }
  
  /// Get description
  String get description {
    switch (this) {
      case TranslationMode.signToSpeech:
        return 'Capture hand gestures and convert to spoken words';
      case TranslationMode.speechToSign:
        return 'Speak into microphone and see sign language animations';
    }
  }
  
  /// Get icon name
  String get iconName {
    switch (this) {
      case TranslationMode.signToSpeech:
        return 'sign_language';
      case TranslationMode.speechToSign:
        return 'mic';
    }
  }
  
  /// Check if this mode requires camera
  bool get requiresCamera {
    return this == TranslationMode.signToSpeech;
  }
  
  /// Check if this mode requires microphone
  bool get requiresMicrophone {
    return this == TranslationMode.speechToSign;
  }
}