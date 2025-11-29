import 'package:flutter_test/flutter_test.dart';
import 'package:signbridge/core/models/point_3d.dart';
import 'package:signbridge/core/models/hand_landmarks.dart';
import 'package:signbridge/features/sign_recognition/gesture_classifier.dart';
import 'package:signbridge/features/sign_recognition/asl_database.dart';

void main() {
  group('GestureClassifier', () {
    late GestureClassifier classifier;

    setUp(() {
      classifier = GestureClassifier();
    });

    test('classifies perfect match with high confidence', () async {
      // Create landmarks that exactly match letter 'A'
      final aLandmarks = ASLDatabase.getSignLandmarks('A')!;
      final landmarks = HandLandmarks(
        points: aLandmarks,
        timestamp: DateTime.now(),
        confidence: 1.0,
      );

      final result = await classifier.classify(landmarks);

      expect(result.letter, equals('A'));
      expect(result.confidence, greaterThan(0.95));
    });

    test('rejects low confidence matches', () async {
      // Create random landmarks that don't match any sign
      final randomPoints = List.generate(
        21,
        (i) => Point3D(
          (i * 0.1) % 1.0,
          (i * 0.15) % 1.0,
          (i * 0.05) % 1.0,
        ),
      );

      final landmarks = HandLandmarks(
        points: randomPoints,
        timestamp: DateTime.now(),
        confidence: 1.0,
      );

      final result = await classifier.classify(landmarks);

      expect(result.letter, isNull);
      expect(result.confidence, lessThan(0.75));
    });

    test('normalizes landmarks correctly', () {
      final points = [
        Point3D(100, 100, 0), // Wrist
        Point3D(110, 90, 5),
        Point3D(120, 80, 10),
        // ... more points
      ];

      final normalized = classifier.normalizeLandmarks(points);

      // Check that normalized landmarks are centered around origin
      final avgX = normalized.where((_, i) => i % 3 == 0).reduce((a, b) => a + b) / 21;
      final avgY = normalized.where((_, i) => i % 3 == 1).reduce((a, b) => a + b) / 21;

      expect(avgX, closeTo(0.0, 0.1));
      expect(avgY, closeTo(0.0, 0.1));
    });

    test('calculates cosine similarity correctly', () {
      final a = [1.0, 0.0, 0.0];
      final b = [1.0, 0.0, 0.0];
      final c = [0.0, 1.0, 0.0];

      // Identical vectors should have similarity of 1.0
      expect(classifier.cosineSimilarity(a, b), closeTo(1.0, 0.001));

      // Orthogonal vectors should have similarity of 0.0
      expect(classifier.cosineSimilarity(a, c), closeTo(0.0, 0.001));
    });

    test('distinguishes between similar letters', () async {
      // Test that classifier can distinguish between similar signs
      // For example, 'A' and 'S' are similar but different

      final aLandmarks = HandLandmarks(
        points: ASLDatabase.getSignLandmarks('A')!,
        timestamp: DateTime.now(),
        confidence: 1.0,
      );

      final sLandmarks = HandLandmarks(
        points: ASLDatabase.getSignLandmarks('S')!,
        timestamp: DateTime.now(),
        confidence: 1.0,
      );

      final aResult = await classifier.classify(aLandmarks);
      final sResult = await classifier.classify(sLandmarks);

      expect(aResult.letter, equals('A'));
      expect(sResult.letter, equals('S'));
      expect(aResult.letter, isNot(equals(sResult.letter)));
    });

    test('handles edge cases gracefully', () async {
      // Test with null/empty landmarks
      final emptyLandmarks = HandLandmarks(
        points: [],
        timestamp: DateTime.now(),
        confidence: 0.0,
      );

      final result = await classifier.classify(emptyLandmarks);

      expect(result.letter, isNull);
      expect(result.confidence, equals(0.0));
    });

    test('performance is acceptable', () async {
      final landmarks = HandLandmarks(
        points: ASLDatabase.getSignLandmarks('A')!,
        timestamp: DateTime.now(),
        confidence: 1.0,
      );

      final stopwatch = Stopwatch()..start();
      await classifier.classify(landmarks);
      stopwatch.stop();

      // Classification should take less than 50ms
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
    });

    test('batch classification maintains accuracy', () async {
      final letters = ['A', 'B', 'C', 'D', 'E'];
      final results = <String>[];

      for (final letter in letters) {
        final landmarks = HandLandmarks(
          points: ASLDatabase.getSignLandmarks(letter)!,
          timestamp: DateTime.now(),
          confidence: 1.0,
        );

        final result = await classifier.classify(landmarks);
        results.add(result.letter ?? '');
      }

      expect(results, equals(letters));
    });
  });

  group('ASLDatabase', () {
    test('contains all required signs', () {
      // Check all letters A-Z
      for (int i = 0; i < 26; i++) {
        final letter = String.fromCharCode(65 + i); // A-Z
        final landmarks = ASLDatabase.getSignLandmarks(letter);
        expect(landmarks, isNotNull, reason: 'Missing sign: $letter');
        expect(landmarks!.length, equals(21), reason: 'Invalid landmark count for $letter');
      }

      // Check all numbers 0-9
      for (int i = 0; i <= 9; i++) {
        final landmarks = ASLDatabase.getSignLandmarks(i.toString());
        expect(landmarks, isNotNull, reason: 'Missing sign: $i');
        expect(landmarks!.length, equals(21), reason: 'Invalid landmark count for $i');
      }
    });

    test('landmarks are normalized', () {
      final landmarks = ASLDatabase.getSignLandmarks('A')!;

      // Check that all coordinates are in reasonable range
      for (final point in landmarks) {
        expect(point.x, greaterThanOrEqualTo(-1.0));
        expect(point.x, lessThanOrEqualTo(1.0));
        expect(point.y, greaterThanOrEqualTo(-1.0));
        expect(point.y, lessThanOrEqualTo(1.0));
        expect(point.z, greaterThanOrEqualTo(-1.0));
        expect(point.z, lessThanOrEqualTo(1.0));
      }
    });

    test('provides sign descriptions', () {
      final description = ASLDatabase.getSignDescription('A');
      expect(description, isNotNull);
      expect(description, contains('fist'));
    });

    test('lists all available signs', () {
      final signs = ASLDatabase.getAllSigns();
      expect(signs.length, equals(36)); // 26 letters + 10 numbers
      expect(signs, contains('A'));
      expect(signs, contains('Z'));
      expect(signs, contains('0'));
      expect(signs, contains('9'));
    });
  });
}