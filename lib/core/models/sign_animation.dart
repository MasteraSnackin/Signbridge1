/// Represents a sign language animation
class SignAnimation {
  final String path;
  final Duration duration;
  final SignType type;
  
  const SignAnimation({
    required this.path,
    required this.duration,
    this.type = SignType.word,
  });
  
  /// Get duration in milliseconds
  int get durationMs => duration.inMilliseconds;
  
  /// Check if this is a word-level sign
  bool get isWord => type == SignType.word;
  
  /// Check if this is a letter-level sign
  bool get isLetter => type == SignType.letter;
  
  /// Check if this is a phrase-level sign
  bool get isPhrase => type == SignType.phrase;
  
  @override
  String toString() {
    return 'SignAnimation(path: $path, duration: ${durationMs}ms, type: $type)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SignAnimation &&
        other.path == path &&
        other.duration == duration &&
        other.type == type;
  }
  
  @override
  int get hashCode => Object.hash(path, duration, type);
}

/// Type of sign animation
enum SignType {
  /// Single letter (fingerspelling)
  letter,
  
  /// Complete word
  word,
  
  /// Multi-word phrase
  phrase,
}

/// Extension to get display name for SignType
extension SignTypeExtension on SignType {
  String get displayName {
    switch (this) {
      case SignType.letter:
        return 'Letter';
      case SignType.word:
        return 'Word';
      case SignType.phrase:
        return 'Phrase';
    }
  }
}