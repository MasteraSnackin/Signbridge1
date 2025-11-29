/// Sign-to-Speech Screen
/// 
/// Screen for capturing hand gestures via camera and converting them to speech.
/// Displays camera preview, recognized text, and confidence indicators.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../../features/sign_recognition/sign_recognition_service.dart';
import '../theme/app_theme.dart';
import '../widgets/camera_preview_widget.dart';
import '../widgets/confidence_indicator.dart';
import '../widgets/transcription_display.dart';

/// Sign-to-Speech screen widget
class SignToSpeechScreen extends StatefulWidget {
  const SignToSpeechScreen({Key? key}) : super(key: key);
  
  @override
  State<SignToSpeechScreen> createState() => _SignToSpeechScreenState();
}

class _SignToSpeechScreenState extends State<SignToSpeechScreen> {
  late SignRecognitionService _service;
  bool _isInitialized = false;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _initializeService();
  }
  
  Future<void> _initializeService() async {
    try {
      _service = context.read<SignRecognitionService>();
      await _service.initialize();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to initialize: $e';
        });
      }
    }
  }
  
  @override
  void dispose() {
    if (_isInitialized) {
      _service.stopRecognition();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign to Speech'),
        actions: [
          // Debug toggle
          IconButton(
            icon: Icon(
              _service.showDebug ? Icons.bug_report : Icons.bug_report_outlined,
            ),
            onPressed: () {
              _service.toggleDebug();
            },
            tooltip: 'Toggle Debug',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    if (_errorMessage != null) {
      return _buildError();
    }
    
    if (!_isInitialized) {
      return _buildLoading();
    }
    
    return Consumer<SignRecognitionService>(
      builder: (context, service, child) {
        return Column(
          children: [
            // Camera preview
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  CameraPreviewWidget(
                    controller: service.cameraController,
                    landmarks: service.showDebug ? service.currentLandmarks : null,
                  ),
                  
                  // Status overlay
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: _buildStatusOverlay(service),
                  ),
                ],
              ),
            ),
            
            // Recognized text display
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.black87,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TranscriptionDisplay(
                      text: service.recognizedText,
                      currentWord: service.currentWord,
                      fontSize: 48,
                    ),
                    
                    SizedBox(height: 16),
                    
                    ConfidenceIndicator(
                      confidence: service.confidence,
                      showLabel: true,
                    ),
                  ],
                ),
              ),
            ),
            
            // Controls
            Container(
              padding: EdgeInsets.all(16),
              child: _buildControls(service),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildStatusOverlay(SignRecognitionService service) {
    return Card(
      color: Colors.black54,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // State indicator
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: service.state == SignRecognitionState.recognizing
                    ? AppColors.success
                    : AppColors.textHint,
              ),
            ),
            
            SizedBox(width: 8),
            
            Text(
              _getStateText(service.state),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            if (service.isProcessing) ...[
              SizedBox(width: 8),
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildControls(SignRecognitionService service) {
    final isRecognizing = service.state == SignRecognitionState.recognizing;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Start/Stop button
        FloatingActionButton.large(
          onPressed: isRecognizing
              ? () => service.stopRecognition()
              : () => service.startRecognition(),
          backgroundColor: isRecognizing ? AppColors.error : AppColors.success,
          child: Icon(
            isRecognizing ? Icons.stop : Icons.play_arrow,
            size: 36,
          ),
        ),
        
        // Clear button
        FloatingActionButton(
          onPressed: service.recognizedText.isNotEmpty
              ? () => service.clearText()
              : null,
          backgroundColor: AppColors.warning,
          child: Icon(Icons.clear),
        ),
        
        // Speak button
        FloatingActionButton(
          onPressed: service.recognizedText.isNotEmpty
              ? () => service.speakCurrentText()
              : null,
          backgroundColor: AppColors.info,
          child: Icon(Icons.volume_up),
        ),
      ],
    );
  }
  
  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Initializing camera and AI models...'),
        ],
      ),
    );
  }
  
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            SizedBox(height: 16),
            Text(
              'Error',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                });
                _initializeService();
              },
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getStateText(SignRecognitionState state) {
    switch (state) {
      case SignRecognitionState.idle:
        return 'Idle';
      case SignRecognitionState.initializing:
        return 'Initializing...';
      case SignRecognitionState.ready:
        return 'Ready';
      case SignRecognitionState.recognizing:
        return 'Recognizing';
      case SignRecognitionState.paused:
        return 'Paused';
      case SignRecognitionState.error:
        return 'Error';
    }
  }
}