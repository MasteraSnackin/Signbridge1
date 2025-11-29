/// Home Screen
/// 
/// Main landing screen for the SignBridge application.
/// Provides navigation to Sign-to-Speech and Speech-to-Sign modes.

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'sign_to_speech_screen.dart';
import 'speech_to_sign_screen.dart';
import 'settings_screen.dart';

/// Home screen widget
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SignBridge'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsScreen()),
              );
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App logo/icon
              Icon(
                Icons.sign_language,
                size: 120,
                color: AppColors.primary,
              ),
              
              SizedBox(height: 24),
              
              // App title
              Text(
                'SignBridge',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 8),
              
              // App subtitle
              Text(
                'Bidirectional Sign Language Translation',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 48),
              
              // Sign-to-Speech button
              _ModeCard(
                icon: Icons.videocam,
                title: 'Sign to Speech',
                description: 'Camera captures hand gestures and converts to spoken words',
                color: AppColors.primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SignToSpeechScreen()),
                  );
                },
              ),
              
              SizedBox(height: 16),
              
              // Speech-to-Sign button
              _ModeCard(
                icon: Icons.mic,
                title: 'Speech to Sign',
                description: 'Microphone captures voice and displays sign language',
                color: AppColors.secondary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SpeechToSignScreen()),
                  );
                },
              ),
              
              SizedBox(height: 32),
              
              // Info text
              Text(
                'Choose a mode to get started',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mode selection card widget
class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;
  
  const _ModeCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Row(
            children: [
              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 36,
                  color: color,
                ),
              ),
              
              SizedBox(width: 16),
              
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Arrow icon
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}