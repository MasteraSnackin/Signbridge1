/// Camera Preview Widget
/// 
/// Displays live camera feed with optional hand landmark overlay for debugging.

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../core/models/hand_landmarks.dart';
import '../../core/models/point_3d.dart';
import '../theme/app_theme.dart';

/// Camera preview widget
class CameraPreviewWidget extends StatelessWidget {
  final CameraController? controller;
  final HandLandmarks? landmarks;
  
  const CameraPreviewWidget({
    Key? key,
    required this.controller,
    this.landmarks,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera preview
        CameraPreview(controller!),
        
        // Hand landmarks overlay (debug mode)
        if (landmarks != null)
          CustomPaint(
            painter: HandLandmarksPainter(landmarks!),
          ),
      ],
    );
  }
}

/// Custom painter for hand landmarks
class HandLandmarksPainter extends CustomPainter {
  final HandLandmarks landmarks;
  
  HandLandmarksPainter(this.landmarks);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;
    
    final linePaint = Paint()
      ..color = AppColors.accent.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    // Draw connections between landmarks
    _drawConnections(canvas, size, linePaint);
    
    // Draw landmark points
    for (final point in landmarks.points) {
      final offset = _pointToOffset(point, size);
      canvas.drawCircle(offset, 4, paint);
    }
  }
  
  void _drawConnections(Canvas canvas, Size size, Paint paint) {
    // MediaPipe hand connections
    final connections = [
      // Thumb
      [0, 1], [1, 2], [2, 3], [3, 4],
      // Index finger
      [0, 5], [5, 6], [6, 7], [7, 8],
      // Middle finger
      [0, 9], [9, 10], [10, 11], [11, 12],
      // Ring finger
      [0, 13], [13, 14], [14, 15], [15, 16],
      // Pinky
      [0, 17], [17, 18], [18, 19], [19, 20],
      // Palm
      [5, 9], [9, 13], [13, 17],
    ];
    
    for (final connection in connections) {
      final start = _pointToOffset(landmarks.points[connection[0]], size);
      final end = _pointToOffset(landmarks.points[connection[1]], size);
      canvas.drawLine(start, end, paint);
    }
  }
  
  Offset _pointToOffset(Point3D point, Size size) {
    // Convert normalized coordinates (0-1) to screen coordinates
    return Offset(
      point.x * size.width,
      point.y * size.height,
    );
  }
  
  @override
  bool shouldRepaint(HandLandmarksPainter oldDelegate) {
    return oldDelegate.landmarks != landmarks;
  }
}