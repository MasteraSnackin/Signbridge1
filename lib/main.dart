import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signbridge/core/services/cactus_model_service_with_mock.dart';
import 'package:signbridge/core/services/permission_service.dart';
import 'package:signbridge/features/sign_recognition/sign_recognition_service.dart';
import 'package:signbridge/features/speech_recognition/speech_recognition_service.dart';
import 'package:signbridge/features/sign_animation/sign_animation_service.dart';
import 'package:signbridge/features/text_to_speech/tts_service.dart';
import 'package:signbridge/ui/screens/home_screen.dart';
import 'package:signbridge/ui/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await _initializeApp();
  
  runApp(const SignBridgeApp());
}

Future<void> _initializeApp() async {
  try {
    // Request permissions
    final permissionsGranted = await PermissionService.requestAllPermissions();
    if (!permissionsGranted) {
      debugPrint('Warning: Not all permissions granted');
    }
    
    // Initialize AI models
    await CactusModelService.instance.initialize();
    
    debugPrint('App initialization complete');
  } catch (e) {
    debugPrint('Error during app initialization: $e');
  }
}

class SignBridgeApp extends StatelessWidget {
  const SignBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SignRecognitionService(),
        ),
        ChangeNotifierProvider(
          create: (_) => SpeechRecognitionService(),
        ),
        ChangeNotifierProvider(
          create: (_) => SignAnimationService(),
        ),
        ChangeNotifierProvider(
          create: (_) => TTSService(),
        ),
      ],
      child: MaterialApp(
        title: 'SignBridge',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}