/// Transcription Display Widget
/// 
/// Displays recognized text with current word highlighting.

import 'package:flutter/material.dart';

/// Transcription display widget
class TranscriptionDisplay extends StatelessWidget {
  final String text;
  final String currentWord;
  final double fontSize;
  
  const TranscriptionDisplay({
    Key? key,
    required this.text,
    this.currentWord = '',
    this.fontSize = 32,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (text.isEmpty && currentWord.isEmpty) {
      return Text(
        'Ready to recognize...',
        style: TextStyle(
          color: Colors.white54,
          fontSize: fontSize * 0.6,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      );
    }
    
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
        children: [
          // Completed text
          if (text.isNotEmpty)
            TextSpan(text: text),
          
          // Space between completed and current
          if (text.isNotEmpty && currentWord.isNotEmpty)
            TextSpan(text: ' '),
          
          // Current word (highlighted)
          if (currentWord.isNotEmpty)
            TextSpan(
              text: currentWord,
              style: TextStyle(
                color: Colors.amber,
                decoration: TextDecoration.underline,
              ),
            ),
        ],
      ),
    );
  }
}