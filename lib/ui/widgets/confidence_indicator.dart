/// Confidence Indicator Widget
/// 
/// Displays confidence score with color-coded visual indicator.

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Confidence indicator widget
class ConfidenceIndicator extends StatelessWidget {
  final double confidence;
  final bool showLabel;
  final bool showPercentage;
  
  const ConfidenceIndicator({
    Key? key,
    required this.confidence,
    this.showLabel = false,
    this.showPercentage = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getConfidenceColor(confidence);
    final percentage = (confidence * 100).toInt();
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel) ...[
          Text(
            'Confidence: ',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          SizedBox(width: 4),
        ],
        
        // Progress bar
        Container(
          width: 100,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: confidence.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        
        if (showPercentage) ...[
          SizedBox(width: 8),
          Text(
            '$percentage%',
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}