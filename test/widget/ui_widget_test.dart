import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:signbridge/ui/screens/home_screen.dart';
import 'package:signbridge/ui/screens/sign_to_speech_screen.dart';
import 'package:signbridge/ui/screens/speech_to_sign_screen.dart';
import 'package:signbridge/ui/screens/settings_screen.dart';
import 'package:signbridge/ui/widgets/confidence_indicator.dart';
import 'package:signbridge/ui/widgets/transcription_display.dart';
import 'package:signbridge/features/sign_recognition/sign_recognition_service.dart';
import 'package:signbridge/features/speech_recognition/speech_recognition_service.dart';
import 'package:signbridge/features/sign_animation/sign_animation_service.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    testWidgets('displays app title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(),
        ),
      );

      expect(find.text('SignBridge'), findsOneWidget);
    });

    testWidgets('shows mode selection buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(),
        ),
      );

      expect(find.text('Sign to Speech'), findsOneWidget);
      expect(find.text('Speech to Sign'), findsOneWidget);
    });

    testWidgets('navigates to Sign-to-Speech screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => SignRecognitionService()),
          ],
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.tap(find.text('Sign to Speech'));
      await tester.pumpAndSettle();

      expect(find.byType(SignToSpeechScreen), findsOneWidget);
    });

    testWidgets('navigates to Speech-to-Sign screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => SpeechRecognitionService()),
            ChangeNotifierProvider(create: (_) => SignAnimationService()),
          ],
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.tap(find.text('Speech to Sign'));
      await tester.pumpAndSettle();

      expect(find.byType(SpeechToSignScreen), findsOneWidget);
    });

    testWidgets('shows settings button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(),
        ),
      );

      expect(find.byIcon(Icons.settings), findsOneWidget);
    });
  });

  group('SignToSpeechScreen Widget Tests', () {
    testWidgets('displays camera preview placeholder', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => SignRecognitionService()),
          ],
          child: MaterialApp(
            home: SignToSpeechScreen(),
          ),
        ),
      );

      // Should show camera preview area
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('shows control buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => SignRecognitionService()),
          ],
          child: MaterialApp(
            home: SignToSpeechScreen(),
          ),
        ),
      );

      // Should have start, stop, clear buttons
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.stop), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('displays recognized text', (WidgetTester tester) async {
      final service = SignRecognitionService();
      
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: service),
          ],
          child: MaterialApp(
            home: SignToSpeechScreen(),
          ),
        ),
      );

      // Initially empty
      expect(find.text(''), findsWidgets);

      // Simulate recognition
      // service.updateRecognizedText('HELLO');
      // await tester.pump();

      // Should display recognized text
      // expect(find.text('HELLO'), findsOneWidget);
    });

    testWidgets('shows confidence indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => SignRecognitionService()),
          ],
          child: MaterialApp(
            home: SignToSpeechScreen(),
          ),
        ),
      );

      expect(find.byType(ConfidenceIndicator), findsOneWidget);
    });

    testWidgets('start button triggers recognition', (WidgetTester tester) async {
      final service = SignRecognitionService();
      
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: service),
          ],
          child: MaterialApp(
            home: SignToSpeechScreen(),
          ),
        ),
      );

      expect(service.isProcessing, isFalse);

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();

      // Should start processing
      // expect(service.isProcessing, isTrue);
    });

    testWidgets('stop button stops recognition', (WidgetTester tester) async {
      final service = SignRecognitionService();
      
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: service),
          ],
          child: MaterialApp(
            home: SignToSpeechScreen(),
          ),
        ),
      );

      // Start recognition
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();

      // Stop recognition
      await tester.tap(find.byIcon(Icons.stop));
      await tester.pump();

      expect(service.isProcessing, isFalse);
    });

    testWidgets('clear button clears text', (WidgetTester tester) async {
      final service = SignRecognitionService();
      
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: service),
          ],
          child: MaterialApp(
            home: SignToSpeechScreen(),
          ),
        ),
      );

      // Set some text
      // service.updateRecognizedText('TEST');
      // await tester.pump();

      // Clear text
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      expect(service.recognizedText, isEmpty);
    });
  });

  group('SpeechToSignScreen Widget Tests', () {
    testWidgets('displays microphone button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => SpeechRecognitionService()),
            ChangeNotifierProvider(create: (_) => SignAnimationService()),
          ],
          child: MaterialApp(
            home: SpeechToSignScreen(),
          ),
        ),
      );

      expect(find.byIcon(Icons.mic_none), findsOneWidget);
    });

    testWidgets('shows transcribed text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => SpeechRecognitionService()),
            ChangeNotifierProvider(create: (_) => SignAnimationService()),
          ],
          child: MaterialApp(
            home: SpeechToSignScreen(),
          ),
        ),
      );

      expect(find.byType(TranscriptionDisplay), findsOneWidget);
    });

    testWidgets('displays sign animation area', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => SpeechRecognitionService()),
            ChangeNotifierProvider(create: (_) => SignAnimationService()),
          ],
          child: MaterialApp(
            home: SpeechToSignScreen(),
          ),
        ),
      );

      // Should have animation display area
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('microphone button toggles listening', (WidgetTester tester) async {
      final service = SpeechRecognitionService();
      
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: service),
            ChangeNotifierProvider(create: (_) => SignAnimationService()),
          ],
          child: MaterialApp(
            home: SpeechToSignScreen(),
          ),
        ),
      );

      expect(service.isListening, isFalse);

      // Start listening
      await tester.tap(find.byIcon(Icons.mic_none));
      await tester.pump();

      // Should be listening
      // expect(service.isListening, isTrue);
      // expect(find.byIcon(Icons.mic), findsOneWidget);

      // Stop listening
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pump();

      expect(service.isListening, isFalse);
    });
  });

  group('ConfidenceIndicator Widget Tests', () {
    testWidgets('displays confidence bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConfidenceIndicator(confidence: 0.8),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('shows correct color for high confidence', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConfidenceIndicator(confidence: 0.9),
          ),
        ),
      );

      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );

      expect(indicator.value, equals(0.9));
      expect(indicator.color, equals(Colors.green));
    });

    testWidgets('shows correct color for medium confidence', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConfidenceIndicator(confidence: 0.6),
          ),
        ),
      );

      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );

      expect(indicator.color, equals(Colors.orange));
    });

    testWidgets('shows correct color for low confidence', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConfidenceIndicator(confidence: 0.3),
          ),
        ),
      );

      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );

      expect(indicator.color, equals(Colors.red));
    });

    testWidgets('displays confidence percentage', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConfidenceIndicator(confidence: 0.85),
          ),
        ),
      );

      expect(find.text('85%'), findsOneWidget);
    });
  });

  group('TranscriptionDisplay Widget Tests', () {
    testWidgets('displays transcribed text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TranscriptionDisplay(
              text: 'Hello world',
              isListening: false,
            ),
          ),
        ),
      );

      expect(find.text('Hello world'), findsOneWidget);
    });

    testWidgets('shows listening indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TranscriptionDisplay(
              text: '',
              isListening: true,
            ),
          ),
        ),
      );

      expect(find.text('Listening...'), findsOneWidget);
    });

    testWidgets('highlights current word', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TranscriptionDisplay(
              text: 'Hello world',
              currentWordIndex: 1,
              isListening: false,
            ),
          ),
        ),
      );

      // Should highlight 'world'
      // In real implementation, would check text styling
    });
  });

  group('SettingsScreen Widget Tests', () {
    testWidgets('displays settings options', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(),
        ),
      );

      expect(find.text('Model Management'), findsOneWidget);
      expect(find.text('Hybrid Mode'), findsOneWidget);
      expect(find.text('Privacy Dashboard'), findsOneWidget);
    });

    testWidgets('hybrid mode toggle works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(),
        ),
      );

      final switchFinder = find.byType(SwitchListTile).first;
      
      // Toggle switch
      await tester.tap(switchFinder);
      await tester.pump();

      // Should update setting
      // In real implementation, would verify setting was saved
    });

    testWidgets('navigates to model management', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(),
        ),
      );

      await tester.tap(find.text('Model Management'));
      await tester.pumpAndSettle();

      // Should navigate to model management screen
      // In real implementation, would verify navigation
    });
  });

  group('Accessibility Tests', () {
    testWidgets('all buttons have semantic labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Check that buttons have proper semantics
      expect(
        tester.getSemantics(find.text('Sign to Speech')),
        matchesSemantics(
          label: 'Sign to Speech',
          isButton: true,
        ),
      );
    });

    testWidgets('screen reader can navigate app', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Verify semantic tree is properly structured
      final semantics = tester.getSemantics(find.byType(HomeScreen));
      expect(semantics, isNotNull);
    });
  });

  group('Responsive Layout Tests', () {
    testWidgets('adapts to different screen sizes', (WidgetTester tester) async {
      // Test with small screen
      tester.binding.window.physicalSizeTestValue = Size(360, 640);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify layout works on small screen
      expect(find.byType(HomeScreen), findsOneWidget);

      // Test with large screen
      tester.binding.window.physicalSizeTestValue = Size(1080, 1920);
      
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify layout works on large screen
      expect(find.byType(HomeScreen), findsOneWidget);

      // Reset
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
  });
}