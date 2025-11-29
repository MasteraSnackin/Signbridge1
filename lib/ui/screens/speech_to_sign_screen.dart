/// Speech-to-Sign Screen
/// 
/// Screen for capturing voice input and displaying sign language animations.
/// Shows transcribed text and animated sign language.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/speech_recognition/speech_recognition_service.dart';
import '../../features/sign_animation/sign_animation_service.dart';
import '../theme/app_theme.dart';
import '../widgets/sign_animation_widget.dart';

/// Speech-to-Sign screen widget
class SpeechToSignScreen extends StatefulWidget {
  const SpeechToSignScreen({Key? key}) : super(key: key);
  
  @override
  State<SpeechToSignScreen> createState() => _SpeechToSignScreenState();
}

class _SpeechToSignScreenState extends State<SpeechToSignScreen> {
  late SpeechRecognitionService _speechService;
  late SignAnimationService _animationService;
  bool _isInitialized = false;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }
  
  Future<void> _initializeServices() async {
    try {
      _speechService = context.read<SpeechRecognitionService>();
      _animationService = context.read<SignAnimationService>();
      
      await _speechService.initialize();
      _animationService.initialize();
      
      // Listen to speech recognition results
      _speechService.addListener(_onSpeechResult);
      
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
  
  void _onSpeechResult() {
    if (_speechService.transcribedText.isNotEmpty) {
      _animationService.displaySignsForText(_speechService.transcribedText);
    }
  }
  
  @override
  void dispose() {
    _speechService.removeListener(_onSpeechResult);
    if (_isInitialized) {
      _speechService.stopListening();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Speech to Sign'),
        actions: [
          // Speed control
          PopupMenuButton<double>(
            icon: Icon(Icons.speed),
            tooltip: 'Animation Speed',
            onSelected: (speed) {
              _animationService.setSpeed(speed);
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 0.5, child: Text('0.5× (Slow)')),
              PopupMenuItem(value: 1.0, child: Text('1.0× (Normal)')),
              PopupMenuItem(value: 1.5, child: Text('1.5× (Fast)')),
              PopupMenuItem(value: 2.0, child: Text('2.0× (Very Fast)')),
            ],
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
    
    return Consumer2<SpeechRecognitionService, SignAnimationService>(
      builder: (context, speechService, animService, child) {
        return Column(
          children: [
            // Transcribed text display
            Container(
              padding: EdgeInsets.all(16),
              color: AppColors.primaryLight.withOpacity(0.1),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transcribed Text:',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  SizedBox(height: 8),
                  Text(
                    speechService.transcribedText.isEmpty
                        ? 'Tap the microphone to start...'
                        : speechService.transcribedText,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (speechService.partialText.isNotEmpty) ...[
                    SizedBox(height: 4),
                    Text(
                      speechService.partialText,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Sign animation display
            Expanded(
              child: Stack(
                children: [
                  SignAnimationWidget(
                    animation: animService.currentAnimation,
                    isPlaying: animService.isPlaying,
                  ),
                  
                  // Animation queue indicator
                  if (animService.queue.isNotEmpty)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: _buildQueueIndicator(animService),
                    ),
                ],
              ),
            ),
            
            // Playback controls
            if (animService.queue.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildPlaybackControls(animService),
              ),
            
            // Microphone button
            Container(
              padding: EdgeInsets.all(24),
              child: _buildMicrophoneButton(speechService),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildQueueIndicator(SignAnimationService service) {
    return Card(
      color: Colors.black54,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Queue',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '${service.currentPosition + 1} / ${service.queue.length}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPlaybackControls(SignAnimationService service) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous
        IconButton(
          icon: Icon(Icons.skip_previous),
          onPressed: service.currentPosition > 0
              ? () => service.skipPrevious()
              : null,
          tooltip: 'Previous',
        ),
        
        SizedBox(width: 16),
        
        // Play/Pause
        IconButton(
          icon: Icon(
            service.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
          onPressed: () {
            if (service.isPlaying) {
              service.pause();
            } else if (service.isPaused) {
              service.resume();
            } else {
              service.play();
            }
          },
          iconSize: 36,
          tooltip: service.isPlaying ? 'Pause' : 'Play',
        ),
        
        SizedBox(width: 16),
        
        // Next
        IconButton(
          icon: Icon(Icons.skip_next),
          onPressed: service.currentPosition < service.queue.length - 1
              ? () => service.skipNext()
              : null,
          tooltip: 'Next',
        ),
        
        SizedBox(width: 16),
        
        // Stop
        IconButton(
          icon: Icon(Icons.stop),
          onPressed: service.isPlaying || service.isPaused
              ? () => service.stop()
              : null,
          tooltip: 'Stop',
        ),
        
        SizedBox(width: 16),
        
        // Clear queue
        IconButton(
          icon: Icon(Icons.clear_all),
          onPressed: service.queue.isNotEmpty
              ? () => service.clearQueue()
              : null,
          tooltip: 'Clear Queue',
        ),
      ],
    );
  }
  
  Widget _buildMicrophoneButton(SpeechRecognitionService service) {
    final isListening = service.isListening;
    
    return FloatingActionButton.large(
      onPressed: isListening
          ? () => service.stopListening()
          : () => service.startListening(),
      backgroundColor: isListening ? AppColors.error : AppColors.primary,
      child: Icon(
        isListening ? Icons.mic : Icons.mic_none,
        size: 48,
      ),
    );
  }
  
  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Initializing speech recognition...'),
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
                _initializeServices();
              },
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}