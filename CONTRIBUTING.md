# Contributing to SignBridge

Thank you for your interest in contributing to SignBridge! This document provides guidelines and instructions for contributing to the project.

---

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
3. [Development Setup](#development-setup)
4. [How to Contribute](#how-to-contribute)
5. [Coding Standards](#coding-standards)
6. [Testing Guidelines](#testing-guidelines)
7. [Documentation](#documentation)
8. [Pull Request Process](#pull-request-process)
9. [Issue Guidelines](#issue-guidelines)

---

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive environment for all contributors, regardless of:
- Age, body size, disability, ethnicity
- Gender identity and expression
- Level of experience
- Nationality, personal appearance, race
- Religion, sexual identity and orientation

### Our Standards

**Positive behavior includes:**
- Using welcoming and inclusive language
- Being respectful of differing viewpoints
- Gracefully accepting constructive criticism
- Focusing on what is best for the community
- Showing empathy towards other community members

**Unacceptable behavior includes:**
- Trolling, insulting/derogatory comments, personal attacks
- Public or private harassment
- Publishing others' private information
- Other conduct which could reasonably be considered inappropriate

### Enforcement

Instances of abusive, harassing, or otherwise unacceptable behavior may be reported to the project team at conduct@signbridge.app. All complaints will be reviewed and investigated promptly and fairly.

---

## Getting Started

### Prerequisites

Before contributing, ensure you have:
- Flutter SDK (3.0.0 or higher)
- Android Studio or VS Code
- Git
- Basic knowledge of Dart and Flutter
- Understanding of sign language (helpful but not required)

### First-Time Contributors

If you're new to open source:
1. Read this entire document
2. Check out [good first issues](https://github.com/signbridge/signbridge/labels/good%20first%20issue)
3. Join our [Discord community](https://discord.gg/signbridge)
4. Ask questions - we're here to help!

---

## Development Setup

### 1. Fork and Clone

```bash
# Fork the repository on GitHub, then:
git clone https://github.com/YOUR_USERNAME/signbridge.git
cd signbridge

# Add upstream remote
git remote add upstream https://github.com/signbridge/signbridge.git
```

### 2. Install Dependencies

```bash
# Get Flutter dependencies
flutter pub get

# Verify setup
flutter doctor
```

### 3. Run Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/gesture_classifier_test.dart

# Run with coverage
flutter test --coverage
```

### 4. Run the App

```bash
# Run in debug mode
flutter run

# Run in profile mode (for performance testing)
flutter run --profile

# Run on specific device
flutter run -d <device-id>
```

---

## How to Contribute

### Types of Contributions

We welcome:
- **Bug fixes**: Fix issues in existing code
- **New features**: Add new functionality
- **Documentation**: Improve or add documentation
- **Tests**: Add or improve test coverage
- **Performance**: Optimize existing code
- **Accessibility**: Improve accessibility features
- **Translations**: Add support for new sign languages
- **Animations**: Create sign language animations

### Contribution Workflow

1. **Find or Create an Issue**
   - Check existing issues
   - Create new issue if needed
   - Discuss approach before coding

2. **Create a Branch**
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/bug-description
   ```

3. **Make Changes**
   - Write clean, documented code
   - Follow coding standards
   - Add tests for new features
   - Update documentation

4. **Commit Changes**
   ```bash
   git add .
   git commit -m "feat: add new feature"
   ```

5. **Push and Create PR**
   ```bash
   git push origin feature/your-feature-name
   ```
   Then create a Pull Request on GitHub

---

## Coding Standards

### Dart Style Guide

Follow the [official Dart style guide](https://dart.dev/guides/language/effective-dart/style).

**Key points:**
- Use `lowerCamelCase` for variables and functions
- Use `UpperCamelCase` for classes
- Use `lowercase_with_underscores` for file names
- Maximum line length: 80 characters
- Use trailing commas for better formatting

### Code Organization

```dart
// 1. Imports (grouped and sorted)
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:signbridge/core/models/hand_landmarks.dart';
import 'package:signbridge/core/utils/logger.dart';

// 2. Class definition
class MyClass {
  // 3. Constants
  static const int maxRetries = 3;
  
  // 4. Static variables
  static final instance = MyClass._();
  
  // 5. Instance variables
  final String name;
  int _counter = 0;
  
  // 6. Constructor
  MyClass(this.name);
  
  // 7. Named constructors
  MyClass.empty() : name = '';
  
  // 8. Getters/Setters
  int get counter => _counter;
  
  // 9. Public methods
  void increment() {
    _counter++;
  }
  
  // 10. Private methods
  void _reset() {
    _counter = 0;
  }
}
```

### Documentation

**Every public API must have documentation:**

```dart
/// Classifies hand landmarks into ASL gestures.
///
/// Uses cosine similarity to compare normalized landmarks
/// against a database of known ASL signs.
///
/// Example:
/// ```dart
/// final classifier = GestureClassifier();
/// final result = await classifier.classify(landmarks);
/// print('Recognized: ${result.letter}');
/// ```
class GestureClassifier {
  /// Classifies the given [landmarks] into a gesture.
  ///
  /// Returns a [GestureResult] containing the recognized letter
  /// and confidence score. Returns null letter if confidence
  /// is below threshold.
  ///
  /// Throws [ArgumentError] if landmarks are invalid.
  Future<GestureResult> classify(HandLandmarks landmarks) async {
    // Implementation
  }
}
```

### Error Handling

```dart
// Use try-catch for expected errors
try {
  await riskyOperation();
} catch (e, stackTrace) {
  Logger.error(e, stackTrace, 'OPERATION');
  await ErrorHandler.handleError(
    e as Exception,
    ErrorContext.operation,
    stackTrace: stackTrace,
  );
}

// Use assertions for programming errors
assert(value != null, 'Value must not be null');
assert(list.isNotEmpty, 'List must not be empty');
```

### Naming Conventions

```dart
// Classes: UpperCamelCase
class SignRecognitionService {}

// Variables: lowerCamelCase
final recognizedText = 'Hello';

// Constants: lowerCamelCase
const maxRetries = 3;

// Private members: _leadingUnderscore
int _counter = 0;

// Booleans: is/has/can prefix
bool isProcessing = false;
bool hasPermission = true;
bool canRecognize = false;
```

---

## Testing Guidelines

### Test Structure

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:signbridge/features/sign_recognition/gesture_classifier.dart';

void main() {
  group('GestureClassifier', () {
    late GestureClassifier classifier;

    setUp(() {
      classifier = GestureClassifier();
    });

    tearDown(() {
      // Clean up
    });

    test('classifies perfect match with high confidence', () async {
      // Arrange
      final landmarks = createTestLandmarks('A');

      // Act
      final result = await classifier.classify(landmarks);

      // Assert
      expect(result.letter, equals('A'));
      expect(result.confidence, greaterThan(0.95));
    });

    test('rejects low confidence matches', () async {
      // Arrange
      final randomLandmarks = createRandomLandmarks();

      // Act
      final result = await classifier.classify(randomLandmarks);

      // Assert
      expect(result.letter, isNull);
      expect(result.confidence, lessThan(0.75));
    });
  });
}
```

### Test Coverage

**Aim for:**
- Unit tests: 80%+ coverage
- Integration tests: Key user flows
- Widget tests: All UI components

**Run coverage:**
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Test Types

**Unit Tests:**
- Test individual functions/classes
- Mock dependencies
- Fast execution

**Integration Tests:**
- Test feature workflows
- Use real dependencies where possible
- Test error scenarios

**Widget Tests:**
- Test UI components
- Test user interactions
- Test state changes

---

## Documentation

### What to Document

**Code Documentation:**
- All public APIs
- Complex algorithms
- Non-obvious behavior
- Performance considerations

**User Documentation:**
- Feature guides
- API references
- Troubleshooting
- FAQs

**Developer Documentation:**
- Architecture decisions
- Setup instructions
- Contributing guidelines
- Testing strategies

### Documentation Style

```dart
/// Brief one-line summary.
///
/// Detailed description explaining what the function does,
/// when to use it, and any important considerations.
///
/// Parameters:
/// - [param1]: Description of first parameter
/// - [param2]: Description of second parameter
///
/// Returns: Description of return value
///
/// Throws:
/// - [ExceptionType]: When this exception is thrown
///
/// Example:
/// ```dart
/// final result = myFunction(param1, param2);
/// print(result);
/// ```
///
/// See also:
/// - [RelatedClass]
/// - [RelatedFunction]
void myFunction(String param1, int param2) {
  // Implementation
}
```

---

## Pull Request Process

### Before Submitting

**Checklist:**
- [ ] Code follows style guidelines
- [ ] All tests pass
- [ ] New tests added for new features
- [ ] Documentation updated
- [ ] No merge conflicts
- [ ] Commit messages follow convention
- [ ] PR description is clear

### PR Title Format

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add gesture recognition for numbers
fix: resolve camera permission issue
docs: update API reference
test: add tests for gesture classifier
refactor: improve performance of landmark detection
style: format code according to style guide
chore: update dependencies
```

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
How has this been tested?

## Screenshots (if applicable)
Add screenshots for UI changes

## Checklist
- [ ] Code follows style guidelines
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] No breaking changes (or documented)

## Related Issues
Closes #123
```

### Review Process

1. **Automated Checks**
   - Tests must pass
   - Code analysis must pass
   - Coverage must not decrease

2. **Code Review**
   - At least one approval required
   - Address all comments
   - Request re-review after changes

3. **Merge**
   - Squash and merge (default)
   - Rebase and merge (for clean history)
   - Merge commit (for feature branches)

---

## Issue Guidelines

### Creating Issues

**Bug Reports:**
```markdown
**Describe the bug**
Clear description of the bug

**To Reproduce**
Steps to reproduce:
1. Go to '...'
2. Click on '...'
3. See error

**Expected behavior**
What should happen

**Screenshots**
If applicable

**Environment:**
- Device: [e.g. Pixel 6]
- Android version: [e.g. 13]
- App version: [e.g. 1.0.0]

**Additional context**
Any other information
```

**Feature Requests:**
```markdown
**Is your feature request related to a problem?**
Description of the problem

**Describe the solution you'd like**
Clear description of desired feature

**Describe alternatives you've considered**
Other solutions considered

**Additional context**
Mockups, examples, etc.
```

### Issue Labels

- `bug`: Something isn't working
- `enhancement`: New feature or request
- `documentation`: Documentation improvements
- `good first issue`: Good for newcomers
- `help wanted`: Extra attention needed
- `question`: Further information requested
- `wontfix`: This will not be worked on

---

## Areas Needing Contribution

### High Priority

1. **Sign Language Animations**
   - Create professional ASL animations
   - Add more word animations
   - Improve animation quality

2. **Gesture Recognition**
   - Improve accuracy
   - Add more signs
   - Optimize performance

3. **Accessibility**
   - Screen reader support
   - High contrast mode
   - Voice guidance

### Medium Priority

1. **Testing**
   - Increase test coverage
   - Add integration tests
   - Performance benchmarks

2. **Documentation**
   - Video tutorials
   - More examples
   - Translations

3. **Features**
   - Sentence recognition
   - Multiple sign languages
   - Offline voice synthesis

### Low Priority

1. **UI/UX**
   - Theme customization
   - Animation effects
   - Sound effects

2. **Performance**
   - Battery optimization
   - Memory optimization
   - Startup time

---

## Recognition

### Contributors

All contributors will be:
- Listed in CONTRIBUTORS.md
- Mentioned in release notes
- Credited in the app (Settings → About)

### Hall of Fame

Outstanding contributors may be featured in:
- Project README
- Website
- Social media

---

## Getting Help

### Resources

- **Documentation**: Read all docs in `/docs`
- **Discord**: Join our community
- **Email**: dev@signbridge.app
- **Issues**: Ask questions in GitHub issues

### Mentorship

New contributors can request mentorship:
1. Comment on a "good first issue"
2. Tag @mentors
3. A mentor will guide you through the process

---

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (MIT License).

---

## Thank You!

Your contributions make SignBridge better for everyone. Whether you're fixing a typo or adding a major feature, every contribution matters.

**Happy coding!** 🎉

---

**For more information:**
- [Technical Architecture](TECHNICAL_ARCHITECTURE.md)
- [API Reference](API_REFERENCE.md)
- [Simple Start Guide](SIMPLE_START_GUIDE.md)