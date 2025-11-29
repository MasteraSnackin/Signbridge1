# 🧪 SignBridge Testing Strategy

Comprehensive testing strategy and guidelines for SignBridge project.

---

## Table of Contents

1. [Testing Philosophy](#testing-philosophy)
2. [Test Pyramid](#test-pyramid)
3. [Unit Testing](#unit-testing)
4. [Integration Testing](#integration-testing)
5. [Widget Testing](#widget-testing)
6. [End-to-End Testing](#end-to-end-testing)
7. [Performance Testing](#performance-testing)
8. [Accessibility Testing](#accessibility-testing)
9. [Security Testing](#security-testing)
10. [Test Data Management](#test-data-management)
11. [CI/CD Integration](#cicd-integration)
12. [Test Metrics](#test-metrics)

---

## Testing Philosophy

### Core Principles

1. **Test Early, Test Often**
   - Write tests alongside code
   - Run tests before committing
   - Automate test execution

2. **Test Pyramid Approach**
   - Many unit tests (70%)
   - Some integration tests (20%)
   - Few E2E tests (10%)

3. **Quality Over Quantity**
   - Focus on meaningful tests
   - Avoid testing implementation details
   - Test behavior, not code

4. **Maintainable Tests**
   - Clear test names
   - Minimal test setup
   - Independent tests
   - Fast execution

### Testing Goals

- **Coverage**: Maintain ≥80% code coverage
- **Reliability**: <1% flaky test rate
- **Speed**: Unit tests <5s, all tests <2min
- **Clarity**: Self-documenting test names

---

## Test Pyramid

```
         ┌─────────────┐
         │     E2E     │  10% - Full user flows
         │   Tests     │  Slow, expensive
         └─────────────┘
       ┌─────────────────┐
       │  Integration    │  20% - Component interaction
       │     Tests       │  Medium speed
       └─────────────────┘
    ┌──────────────────────┐
    │    Unit Tests        │  70% - Individual functions
    │                      │  Fast, cheap
    └──────────────────────┘
```

### Distribution

| Test Type | Count | Coverage | Execution Time |
|-----------|-------|----------|----------------|
| Unit | ~100 | 70% | <5s |
| Integration | ~30 | 20% | <30s |
| Widget | ~20 | 8% | <20s |
| E2E | ~5 | 2% | <60s |
| **Total** | **~155** | **100%** | **<2min** |

---

## Unit Testing

### What to Test

✅ **Do Test**:
- Pure functions
- Business logic
- Data transformations
- Calculations
- Validators
- Utilities

❌ **Don't Test**:
- Flutter framework code
- Third-party libraries
- Trivial getters/setters
- Generated code

### Test Structure

```dart
// test/unit/gesture_classifier_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:signbridge/features/sign_recognition/gesture_classifier.dart';
import 'package:signbridge/core/models/hand_landmarks.dart';

void main() {
  group('GestureClassifier', () {
    late GestureClassifier classifier;

    setUp(() {
      classifier = GestureClassifier();
    });

    tearDown(() {
      // Clean up if needed
    });

    group('classify', () {
      test('should return high confidence for perfect match', () async {
        // Arrange
        final landmarks = HandLandmarks(
          points: _createPerfectALandmarks(),
          timestamp: DateTime.now(),
          confidence: 1.0,
        );

        // Act
        final result = await classifier.classify(landmarks);

        // Assert
        expect(result.letter, equals('A'));
        expect(result.confidence, greaterThan(0.9));
      });

      test('should return low confidence for ambiguous gesture', () async {
        // Arrange
        final landmarks = HandLandmarks(
          points: _createAmbiguousLandmarks(),
          timestamp: DateTime.now(),
          confidence: 0.5,
        );

        // Act
        final result = await classifier.classify(landmarks);

        // Assert
        expect(result.confidence, lessThan(0.75));
      });

      test('should handle null landmarks gracefully', () async {
        // Arrange
        final landmarks = HandLandmarks(
          points: [],
          timestamp: DateTime.now(),
          confidence: 0.0,
        );

        // Act & Assert
        expect(
          () => classifier.classify(landmarks),
          throwsA(isA<InvalidLandmarksException>()),
        );
      });
    });

    group('normalize', () {
      test('should normalize landmarks to unit scale', () {
        // Arrange
        final landmarks = _createUnnormalizedLandmarks();

        // Act
        final normalized = classifier.normalize(landmarks);

        // Assert
        expect(normalized.points.length, equals(21));
        expect(_getMaxDistance(normalized.points), closeTo(1.0, 0.01));
      });
    });
  });
}

// Test helpers
List<Point3D> _createPerfectALandmarks() {
  // Return known good landmarks for letter 'A'
  return [/* ... */];
}
```

### Best Practices

1. **Naming Convention**
   ```dart
   test('should [expected behavior] when [condition]', () {
     // Test implementation
   });
   ```

2. **AAA Pattern**
   - **Arrange**: Set up test data
   - **Act**: Execute the code under test
   - **Assert**: Verify the results

3. **One Assertion Per Test** (when possible)
   - Focus on single behavior
   - Easier to debug failures
   - Clear test intent

4. **Use Test Helpers**
   ```dart
   // test/helpers/test_data.dart
   class TestData {
     static HandLandmarks createValidLandmarks() {
       // Return test landmarks
     }
     
     static SignGesture createGesture(String letter) {
       // Return test gesture
     }
   }
   ```

### Mocking

```dart
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Generate mocks
@GenerateMocks([CactusModelService, CameraService])
void main() {
  group('SignRecognitionService', () {
    late SignRecognitionService service;
    late MockCactusModelService mockModelService;
    late MockCameraService mockCameraService;

    setUp(() {
      mockModelService = MockCactusModelService();
      mockCameraService = MockCameraService();
      service = SignRecognitionService(
        modelService: mockModelService,
        cameraService: mockCameraService,
      );
    });

    test('should initialize camera on start', () async {
      // Arrange
      when(mockCameraService.initialize())
          .thenAnswer((_) async => true);

      // Act
      await service.startRecognition();

      // Assert
      verify(mockCameraService.initialize()).called(1);
    });
  });
}
```

### Running Unit Tests

```bash
# Run all unit tests
flutter test test/unit/

# Run specific test file
flutter test test/unit/gesture_classifier_test.dart

# Run with coverage
flutter test --coverage test/unit/

# Watch mode
flutter test --watch test/unit/
```

---

## Integration Testing

### What to Test

- Component interactions
- Service orchestration
- Data flow between layers
- External API integration
- Database operations

### Test Structure

```dart
// test/integration/sign_to_speech_integration_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:signbridge/features/sign_recognition/sign_recognition_service.dart';
import 'package:signbridge/features/text_to_speech/tts_service.dart';

void main() {
  group('Sign-to-Speech Integration', () {
    late SignRecognitionService recognitionService;
    late TTSService ttsService;

    setUp(() async {
      recognitionService = SignRecognitionService();
      ttsService = TTSService();
      await recognitionService.initialize();
      await ttsService.initialize();
    });

    tearDown(() async {
      await recognitionService.dispose();
      await ttsService.dispose();
    });

    test('should recognize gesture and speak text', () async {
      // Arrange
      final testFrame = await loadTestFrame('letter_a.jpg');
      String? spokenText;
      
      ttsService.onSpeak.listen((text) {
        spokenText = text;
      });

      // Act
      await recognitionService.processFrame(testFrame);
      await Future.delayed(Duration(milliseconds: 500));

      // Assert
      expect(recognitionService.recognizedText, contains('A'));
      expect(spokenText, equals('A'));
    });

    test('should handle rapid gesture changes', () async {
      // Arrange
      final frames = [
        await loadTestFrame('letter_h.jpg'),
        await loadTestFrame('letter_e.jpg'),
        await loadTestFrame('letter_l.jpg'),
        await loadTestFrame('letter_l.jpg'),
        await loadTestFrame('letter_o.jpg'),
      ];

      // Act
      for (final frame in frames) {
        await recognitionService.processFrame(frame);
        await Future.delayed(Duration(milliseconds: 100));
      }

      // Assert
      expect(recognitionService.recognizedText, equals('HELLO'));
    });
  });
}
```

### Running Integration Tests

```bash
# Run all integration tests
flutter test test/integration/

# Run specific integration test
flutter test test/integration/sign_to_speech_integration_test.dart
```

---

## Widget Testing

### What to Test

- Widget rendering
- User interactions
- Navigation
- State changes
- UI updates

### Test Structure

```dart
// test/widget/home_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signbridge/ui/screens/home_screen.dart';

void main() {
  group('HomeScreen Widget', () {
    testWidgets('should display app title', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(home: HomeScreen()),
      );

      // Assert
      expect(find.text('SignBridge'), findsOneWidget);
    });

    testWidgets('should navigate to sign-to-speech on tap',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(home: HomeScreen()),
      );

      // Act
      await tester.tap(find.text('Sign to Speech'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(SignToSpeechScreen), findsOneWidget);
    });

    testWidgets('should show settings icon', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(home: HomeScreen()),
      );

      // Assert
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });
  });
}
```

### Widget Test Helpers

```dart
// test/helpers/widget_test_helpers.dart

class WidgetTestHelpers {
  static Future<void> pumpApp(
    WidgetTester tester,
    Widget widget,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: widget,
      ),
    );
  }

  static Future<void> tapAndSettle(
    WidgetTester tester,
    Finder finder,
  ) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  static Finder findByTextContaining(String text) {
    return find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data?.contains(text) == true,
    );
  }
}
```

### Running Widget Tests

```bash
# Run all widget tests
flutter test test/widget/

# Run specific widget test
flutter test test/widget/home_screen_test.dart
```

---

## End-to-End Testing

### What to Test

- Complete user journeys
- Critical user flows
- Cross-feature interactions
- Real device behavior

### Test Structure

```dart
// integration_test/app_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:signbridge/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E Tests', () {
    testWidgets('complete sign-to-speech flow', (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to sign-to-speech
      await tester.tap(find.text('Sign to Speech'));
      await tester.pumpAndSettle();

      // Start recognition
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      // Wait for recognition
      await tester.pump(Duration(seconds: 2));

      // Verify text displayed
      expect(find.textContaining('Recognized:'), findsOneWidget);

      // Stop recognition
      await tester.tap(find.text('Stop'));
      await tester.pumpAndSettle();
    });

    testWidgets('complete speech-to-sign flow', (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to speech-to-sign
      await tester.tap(find.text('Speech to Sign'));
      await tester.pumpAndSettle();

      // Start listening
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle();

      // Wait for transcription
      await tester.pump(Duration(seconds: 2));

      // Verify animation displayed
      expect(find.byType(SignAnimationWidget), findsOneWidget);

      // Stop listening
      await tester.tap(find.byIcon(Icons.stop));
      await tester.pumpAndSettle();
    });
  });
}
```

### Running E2E Tests

```bash
# Run on connected device
flutter test integration_test/app_test.dart

# Run on specific device
flutter test integration_test/app_test.dart -d <device-id>
```

---

## Performance Testing

### Metrics to Test

1. **Latency**
   - Sign recognition: <500ms
   - Speech recognition: <1000ms
   - UI response: <100ms

2. **Resource Usage**
   - Memory: <200MB
   - CPU: <50%
   - Battery: <10%/hour

3. **Throughput**
   - Frames processed: 10 FPS
   - Gestures recognized: 2-3/second

### Performance Test Example

```dart
// test/performance/recognition_performance_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:signbridge/features/sign_recognition/sign_recognition_service.dart';

void main() {
  group('Performance Tests', () {
    test('recognition latency should be under 500ms', () async {
      // Arrange
      final service = SignRecognitionService();
      await service.initialize();
      final testFrame = await loadTestFrame('letter_a.jpg');

      // Act
      final stopwatch = Stopwatch()..start();
      await service.processFrame(testFrame);
      stopwatch.stop();

      // Assert
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    test('should handle 10 FPS without dropping frames', () async {
      // Arrange
      final service = SignRecognitionService();
      await service.initialize();
      final frames = await loadTestFrames(100); // 10 seconds at 10 FPS
      int processedFrames = 0;

      // Act
      final stopwatch = Stopwatch()..start();
      for (final frame in frames) {
        await service.processFrame(frame);
        processedFrames++;
        await Future.delayed(Duration(milliseconds: 100));
      }
      stopwatch.stop();

      // Assert
      expect(processedFrames, equals(100));
      expect(stopwatch.elapsedMilliseconds, lessThan(11000)); // 10% margin
    });
  });
}
```

### Profiling

```bash
# Profile app performance
flutter run --profile

# Generate timeline
flutter run --profile --trace-startup

# Analyze build times
flutter build apk --analyze-size
```

---

## Accessibility Testing

### What to Test

- Screen reader compatibility
- Keyboard navigation
- Touch target sizes
- Color contrast
- Font scaling

### Accessibility Test Example

```dart
// test/accessibility/accessibility_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Accessibility Tests', () {
    testWidgets('all buttons have semantic labels', (tester) async {
      await tester.pumpWidget(MaterialApp(home: HomeScreen()));

      final buttons = find.byType(ElevatedButton);
      for (final button in buttons.evaluate()) {
        final semantics = tester.getSemantics(find.byWidget(button.widget));
        expect(semantics.label, isNotNull);
        expect(semantics.label, isNotEmpty);
      }
    });

    testWidgets('touch targets are at least 48x48', (tester) async {
      await tester.pumpWidget(MaterialApp(home: HomeScreen()));

      final buttons = find.byType(ElevatedButton);
      for (final button in buttons.evaluate()) {
        final size = tester.getSize(find.byWidget(button.widget));
        expect(size.width, greaterThanOrEqualTo(48.0));
        expect(size.height, greaterThanOrEqualTo(48.0));
      }
    });

    testWidgets('text contrast meets WCAG AA', (tester) async {
      await tester.pumpWidget(MaterialApp(home: HomeScreen()));

      // Verify contrast ratios
      // This would require custom contrast checking logic
    });
  });
}
```

---

## Security Testing

### What to Test

- Input validation
- Data encryption
- Secure storage
- Permission handling
- Network security

### Security Test Example

```dart
// test/security/security_test.dart

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Security Tests', () {
    test('should not log sensitive data', () {
      // Verify no sensitive data in logs
    });

    test('should encrypt data at rest', () {
      // Verify encryption
    });

    test('should use HTTPS for cloud requests', () {
      // Verify secure connections
    });

    test('should validate all user inputs', () {
      // Test input validation
    });
  });
}
```

---

## Test Data Management

### Test Data Structure

```
test/
├── fixtures/
│   ├── images/
│   │   ├── letter_a.jpg
│   │   ├── letter_b.jpg
│   │   └── ...
│   ├── audio/
│   │   ├── hello.wav
│   │   └── ...
│   └── json/
│       ├── landmarks_a.json
│       └── ...
└── helpers/
    └── test_data.dart
```

### Test Data Helpers

```dart
// test/helpers/test_data.dart

class TestData {
  static Future<CameraImage> loadTestFrame(String filename) async {
    final bytes = await File('test/fixtures/images/$filename').readAsBytes();
    return CameraImage.fromBytes(bytes);
  }

  static HandLandmarks getLetterALandmarks() {
    return HandLandmarks(
      points: [
        Point3D(0.0, 0.0, 0.0),
        // ... 20 more points
      ],
      timestamp: DateTime.now(),
      confidence: 1.0,
    );
  }

  static Map<String, HandLandmarks> getAllLetterLandmarks() {
    return {
      'A': getLetterALandmarks(),
      'B': getLetterBLandmarks(),
      // ... more letters
    };
  }
}
```

---

## CI/CD Integration

### GitHub Actions Workflow

```yaml
# .github/workflows/test.yml

name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.0.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run analyzer
        run: flutter analyze
      
      - name: Run unit tests
        run: flutter test test/unit/ --coverage
      
      - name: Run integration tests
        run: flutter test test/integration/
      
      - name: Run widget tests
        run: flutter test test/widget/
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
```

---

## Test Metrics

### Coverage Goals

| Component | Target | Current |
|-----------|--------|---------|
| Overall | ≥80% | TBD |
| Core Models | ≥90% | TBD |
| Services | ≥85% | TBD |
| UI Widgets | ≥70% | TBD |
| Utils | ≥95% | TBD |

### Quality Metrics

- **Test Pass Rate**: ≥99%
- **Flaky Test Rate**: <1%
- **Test Execution Time**: <2 minutes
- **Code Coverage**: ≥80%
- **Bug Escape Rate**: <5%

### Reporting

```bash
# Generate coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# View report
open coverage/html/index.html
```

---

## Best Practices Summary

### Do's ✅
- Write tests first (TDD)
- Keep tests simple and focused
- Use descriptive test names
- Mock external dependencies
- Run tests before committing
- Maintain high coverage
- Review test failures immediately

### Don'ts ❌
- Don't test implementation details
- Don't write flaky tests
- Don't skip failing tests
- Don't test third-party code
- Don't write slow tests
- Don't ignore test warnings
- Don't commit without running tests

---

## Resources

### Documentation
- [Flutter Testing Guide](https://flutter.dev/docs/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Integration Testing](https://flutter.dev/docs/testing/integration-tests)

### Tools
- `flutter_test`: Flutter testing framework
- `mockito`: Mocking library
- `integration_test`: E2E testing
- `test_coverage`: Coverage reporting

---

**Version**: 1.0.0  
**Last Updated**: 2025-11-26  
**Maintained By**: QA Team