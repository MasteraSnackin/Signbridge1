/// Sign Animation Widget
/// 
/// Displays sign language animations using Lottie or placeholder graphics.

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../core/models/sign_animation.dart';
import '../theme/app_theme.dart';

/// Sign animation widget
class SignAnimationWidget extends StatelessWidget {
  final SignAnimation? animation;
  final bool isPlaying;
  
  const SignAnimationWidget({
    Key? key,
    required this.animation,
    this.isPlaying = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (animation == null) {
      return _buildPlaceholder(context);
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animation display
          _buildAnimation(context),
          
          SizedBox(height: 16),
          
          // Animation label
          Text(
            animation!.label,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          // Animation type badge
          Chip(
            label: Text(_getTypeLabel(animation!.type)),
            backgroundColor: _getTypeColor(animation!.type),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnimation(BuildContext context) {
    // Try to load Lottie animation
    try {
      return Lottie.asset(
        animation!.path,
        width: 300,
        height: 300,
        repeat: false,
        animate: isPlaying,
        errorBuilder: (context, error, stackTrace) {
          return _buildAnimationPlaceholder(context);
        },
      );
    } catch (e) {
      // Fallback to placeholder if Lottie fails
      return _buildAnimationPlaceholder(context);
    }
  }
  
  Widget _buildAnimationPlaceholder(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sign_language,
            size: 120,
            color: AppColors.primary,
          ),
          SizedBox(height: 16),
          Text(
            animation!.label,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPlaceholder(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sign_language,
            size: 120,
            color: AppColors.textHint,
          ),
          SizedBox(height: 16),
          Text(
            'Ready to sign',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap the microphone to start',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
  
  String _getTypeLabel(SignAnimationType type) {
    switch (type) {
      case SignAnimationType.word:
        return 'Word';
      case SignAnimationType.letter:
        return 'Letter';
      case SignAnimationType.phrase:
        return 'Phrase';
    }
  }
  
  Color _getTypeColor(SignAnimationType type) {
    switch (type) {
      case SignAnimationType.word:
        return AppColors.success.withOpacity(0.2);
      case SignAnimationType.letter:
        return AppColors.info.withOpacity(0.2);
      case SignAnimationType.phrase:
        return AppColors.warning.withOpacity(0.2);
    }
  }
}