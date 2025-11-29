import 'package:signbridge/config/app_config.dart';

/// ASL (American Sign Language) gesture database
/// 
/// Contains normalized hand landmark coordinates for:
/// - 26 letters (A-Z)
/// - 10 numbers (0-9)
/// 
/// Each entry is a list of 63 values representing 21 3D landmarks:
/// [x1, y1, z1, x2, y2, z2, ..., x21, y21, z21]
/// 
/// Landmarks are normalized to be scale and translation invariant:
/// - Translated to wrist origin (wrist at 0,0,0)
/// - Scaled to unit size (max distance from wrist = 1.0)
/// 
/// MediaPipe Hand Landmark Model (21 points):
/// 0: WRIST
/// 1-4: THUMB (CMC, MCP, IP, TIP)
/// 5-8: INDEX (MCP, PIP, DIP, TIP)
/// 9-12: MIDDLE (MCP, PIP, DIP, TIP)
/// 13-16: RING (MCP, PIP, DIP, TIP)
/// 17-20: PINKY (MCP, PIP, DIP, TIP)
class ASLDatabase {
  // Prevent instantiation
  ASLDatabase._();
  
  /// Complete ASL gesture database (36 signs)
  static const Map<String, List<double>> signs = {
    ...letters,
    ...numbers,
  };
  
  /// ASL Alphabet (A-Z)
  /// 
  /// Note: These are simplified representations. In production, these should be
  /// replaced with actual normalized landmark data from training samples.
  static const Map<String, List<double>> letters = {
    // Letter A: Closed fist with thumb on side
    'A': [
      0.0, 0.0, 0.0,      // 0: Wrist (origin)
      0.15, 0.25, 0.05,   // 1: Thumb CMC
      0.20, 0.35, 0.08,   // 2: Thumb MCP
      0.22, 0.42, 0.10,   // 3: Thumb IP
      0.24, 0.48, 0.12,   // 4: Thumb TIP
      0.25, 0.15, 0.02,   // 5: Index MCP
      0.28, 0.22, 0.03,   // 6: Index PIP
      0.30, 0.28, 0.04,   // 7: Index DIP
      0.32, 0.32, 0.05,   // 8: Index TIP
      0.30, 0.12, 0.01,   // 9: Middle MCP
      0.35, 0.18, 0.02,   // 10: Middle PIP
      0.38, 0.23, 0.03,   // 11: Middle DIP
      0.40, 0.27, 0.04,   // 12: Middle TIP
      0.32, 0.10, 0.00,   // 13: Ring MCP
      0.37, 0.15, 0.01,   // 14: Ring PIP
      0.40, 0.19, 0.02,   // 15: Ring DIP
      0.42, 0.22, 0.03,   // 16: Ring TIP
      0.33, 0.08, -0.01,  // 17: Pinky MCP
      0.36, 0.12, 0.00,   // 18: Pinky PIP
      0.38, 0.15, 0.01,   // 19: Pinky DIP
      0.40, 0.18, 0.02,   // 20: Pinky TIP
    ],
    
    // Letter B: Flat hand, fingers together, thumb across palm
    'B': [
      0.0, 0.0, 0.0,      // 0: Wrist
      0.12, 0.18, -0.05,  // 1: Thumb CMC
      0.15, 0.25, -0.08,  // 2: Thumb MCP
      0.17, 0.30, -0.10,  // 3: Thumb IP
      0.18, 0.35, -0.12,  // 4: Thumb TIP
      0.20, 0.15, 0.00,   // 5: Index MCP
      0.22, 0.35, 0.00,   // 6: Index PIP
      0.23, 0.55, 0.00,   // 7: Index DIP
      0.24, 0.75, 0.00,   // 8: Index TIP
      0.25, 0.15, 0.00,   // 9: Middle MCP
      0.27, 0.35, 0.00,   // 10: Middle PIP
      0.28, 0.55, 0.00,   // 11: Middle DIP
      0.29, 0.78, 0.00,   // 12: Middle TIP
      0.28, 0.14, 0.00,   // 13: Ring MCP
      0.30, 0.33, 0.00,   // 14: Ring PIP
      0.31, 0.52, 0.00,   // 15: Ring DIP
      0.32, 0.72, 0.00,   // 16: Ring TIP
      0.30, 0.13, 0.00,   // 17: Pinky MCP
      0.31, 0.30, 0.00,   // 18: Pinky PIP
      0.32, 0.47, 0.00,   // 19: Pinky DIP
      0.33, 0.65, 0.00,   // 20: Pinky TIP
    ],
    
    // Letter C: Curved hand forming C shape
    'C': [
      0.0, 0.0, 0.0,      // 0: Wrist
      0.15, 0.20, 0.10,   // 1: Thumb CMC
      0.18, 0.35, 0.15,   // 2: Thumb MCP
      0.20, 0.48, 0.18,   // 3: Thumb IP
      0.22, 0.60, 0.20,   // 4: Thumb TIP
      0.25, 0.18, 0.05,   // 5: Index MCP
      0.30, 0.38, 0.08,   // 6: Index PIP
      0.33, 0.55, 0.10,   // 7: Index DIP
      0.35, 0.70, 0.12,   // 8: Index TIP
      0.30, 0.16, 0.03,   // 9: Middle MCP
      0.36, 0.36, 0.05,   // 10: Middle PIP
      0.40, 0.54, 0.07,   // 11: Middle DIP
      0.43, 0.72, 0.08,   // 12: Middle TIP
      0.33, 0.14, 0.01,   // 13: Ring MCP
      0.39, 0.32, 0.02,   // 14: Ring PIP
      0.43, 0.49, 0.03,   // 15: Ring DIP
      0.46, 0.66, 0.04,   // 16: Ring TIP
      0.35, 0.12, -0.01,  // 17: Pinky MCP
      0.40, 0.28, 0.00,   // 18: Pinky PIP
      0.43, 0.43, 0.01,   // 19: Pinky DIP
      0.45, 0.58, 0.02,   // 20: Pinky TIP
    ],
    
    // Letter D: Index finger up, other fingers and thumb form O
    'D': [
      0.0, 0.0, 0.0,      // 0: Wrist
      0.18, 0.22, 0.08,   // 1: Thumb CMC
      0.22, 0.32, 0.12,   // 2: Thumb MCP
      0.25, 0.40, 0.15,   // 3: Thumb IP
      0.27, 0.48, 0.17,   // 4: Thumb TIP
      0.22, 0.18, 0.02,   // 5: Index MCP
      0.24, 0.40, 0.02,   // 6: Index PIP
      0.25, 0.62, 0.02,   // 7: Index DIP
      0.26, 0.85, 0.02,   // 8: Index TIP
      0.28, 0.16, 0.00,   // 9: Middle MCP
      0.32, 0.28, 0.05,   // 10: Middle PIP
      0.34, 0.38, 0.08,   // 11: Middle DIP
      0.35, 0.46, 0.10,   // 12: Middle TIP
      0.30, 0.14, -0.02,  // 13: Ring MCP
      0.34, 0.24, 0.02,   // 14: Ring PIP
      0.36, 0.32, 0.05,   // 15: Ring DIP
      0.37, 0.39, 0.07,   // 16: Ring TIP
      0.31, 0.12, -0.04,  // 17: Pinky MCP
      0.34, 0.20, 0.00,   // 18: Pinky PIP
      0.35, 0.27, 0.02,   // 19: Pinky DIP
      0.36, 0.33, 0.04,   // 20: Pinky TIP
    ],
    
    // Letter E: Fingers curled, thumb across fingertips
    'E': [
      0.0, 0.0, 0.0,      // 0: Wrist
      0.15, 0.20, 0.05,   // 1: Thumb CMC
      0.18, 0.30, 0.08,   // 2: Thumb MCP
      0.20, 0.38, 0.10,   // 3: Thumb IP
      0.22, 0.45, 0.12,   // 4: Thumb TIP
      0.24, 0.16, 0.02,   // 5: Index MCP
      0.28, 0.26, 0.04,   // 6: Index PIP
      0.30, 0.34, 0.06,   // 7: Index DIP
      0.32, 0.40, 0.08,   // 8: Index TIP
      0.28, 0.15, 0.01,   // 9: Middle MCP
      0.33, 0.24, 0.03,   // 10: Middle PIP
      0.36, 0.32, 0.05,   // 11: Middle DIP
      0.38, 0.38, 0.07,   // 12: Middle TIP
      0.30, 0.13, 0.00,   // 13: Ring MCP
      0.35, 0.21, 0.02,   // 14: Ring PIP
      0.38, 0.28, 0.04,   // 15: Ring DIP
      0.40, 0.34, 0.06,   // 16: Ring TIP
      0.32, 0.11, -0.01,  // 17: Pinky MCP
      0.36, 0.18, 0.01,   // 18: Pinky PIP
      0.38, 0.24, 0.03,   // 19: Pinky DIP
      0.40, 0.29, 0.05,   // 20: Pinky TIP
    ],
    
    // Letter F: Index and thumb form circle, other fingers extended
    'F': [
      0.0, 0.0, 0.0,      // 0: Wrist
      0.18, 0.25, 0.10,   // 1: Thumb CMC
      0.22, 0.38, 0.15,   // 2: Thumb MCP
      0.24, 0.48, 0.18,   // 3: Thumb IP
      0.25, 0.58, 0.20,   // 4: Thumb TIP
      0.22, 0.20, 0.05,   // 5: Index MCP
      0.26, 0.35, 0.10,   // 6: Index PIP
      0.28, 0.48, 0.14,   // 7: Index DIP
      0.29, 0.60, 0.17,   // 8: Index TIP
      0.26, 0.18, 0.02,   // 9: Middle MCP
      0.28, 0.40, 0.02,   // 10: Middle PIP
      0.29, 0.62, 0.02,   // 11: Middle DIP
      0.30, 0.84, 0.02,   // 12: Middle TIP
      0.28, 0.16, 0.00,   // 13: Ring MCP
      0.30, 0.38, 0.00,   // 14: Ring PIP
      0.31, 0.60, 0.00,   // 15: Ring DIP
      0.32, 0.82, 0.00,   // 16: Ring TIP
      0.30, 0.14, -0.02,  // 17: Pinky MCP
      0.31, 0.35, -0.02,  // 18: Pinky PIP
      0.32, 0.56, -0.02,  // 19: Pinky DIP
      0.33, 0.77, -0.02,  // 20: Pinky TIP
    ],
    
    // Add remaining letters G-Z with similar structure
    // For brevity, I'll add a few more key letters and note that
    // the full database should include all 26 letters
    
    // Letter I: Pinky extended, other fingers closed
    'I': [
      0.0, 0.0, 0.0,      // 0: Wrist
      0.15, 0.22, 0.05,   // 1: Thumb CMC
      0.18, 0.30, 0.08,   // 2: Thumb MCP
      0.20, 0.36, 0.10,   // 3: Thumb IP
      0.22, 0.42, 0.12,   // 4: Thumb TIP
      0.24, 0.18, 0.02,   // 5: Index MCP
      0.28, 0.26, 0.04,   // 6: Index PIP
      0.30, 0.32, 0.06,   // 7: Index DIP
      0.32, 0.37, 0.08,   // 8: Index TIP
      0.28, 0.16, 0.01,   // 9: Middle MCP
      0.33, 0.24, 0.03,   // 10: Middle PIP
      0.36, 0.30, 0.05,   // 11: Middle DIP
      0.38, 0.35, 0.07,   // 12: Middle TIP
      0.30, 0.14, 0.00,   // 13: Ring MCP
      0.35, 0.21, 0.02,   // 14: Ring PIP
      0.38, 0.27, 0.04,   // 15: Ring DIP
      0.40, 0.32, 0.06,   // 16: Ring TIP
      0.32, 0.12, -0.01,  // 17: Pinky MCP
      0.33, 0.32, -0.01,  // 18: Pinky PIP
      0.34, 0.52, -0.01,  // 19: Pinky DIP
      0.35, 0.72, -0.01,  // 20: Pinky TIP (extended)
    ],
    
    // Letter L: Index and thumb form L shape
    'L': [
      0.0, 0.0, 0.0,      // 0: Wrist
      0.15, 0.20, 0.05,   // 1: Thumb CMC
      0.18, 0.35, 0.08,   // 2: Thumb MCP
      0.20, 0.50, 0.10,   // 3: Thumb IP
      0.22, 0.65, 0.12,   // 4: Thumb TIP (extended)
      0.22, 0.18, 0.02,   // 5: Index MCP
      0.24, 0.38, 0.02,   // 6: Index PIP
      0.25, 0.58, 0.02,   // 7: Index DIP
      0.26, 0.78, 0.02,   // 8: Index TIP (extended)
      0.28, 0.16, 0.00,   // 9: Middle MCP
      0.32, 0.26, 0.03,   // 10: Middle PIP
      0.34, 0.34, 0.05,   // 11: Middle DIP
      0.36, 0.40, 0.07,   // 12: Middle TIP
      0.30, 0.14, -0.01,  // 13: Ring MCP
      0.34, 0.23, 0.02,   // 14: Ring PIP
      0.36, 0.30, 0.04,   // 15: Ring DIP
      0.38, 0.36, 0.06,   // 16: Ring TIP
      0.32, 0.12, -0.02,  // 17: Pinky MCP
      0.35, 0.20, 0.01,   // 18: Pinky PIP
      0.37, 0.27, 0.03,   // 19: Pinky DIP
      0.39, 0.33, 0.05,   // 20: Pinky TIP
    ],
    
    // Letter O: All fingers and thumb form circle
    'O': [
      0.0, 0.0, 0.0,      // 0: Wrist
      0.18, 0.25, 0.12,   // 1: Thumb CMC
      0.22, 0.38, 0.18,   // 2: Thumb MCP
      0.25, 0.48, 0.22,   // 3: Thumb IP
      0.27, 0.56, 0.25,   // 4: Thumb TIP
      0.24, 0.22, 0.08,   // 5: Index MCP
      0.28, 0.36, 0.14,   // 6: Index PIP
      0.30, 0.48, 0.19,   // 7: Index DIP
      0.31, 0.58, 0.23,   // 8: Index TIP
      0.28, 0.20, 0.06,   // 9: Middle MCP
      0.33, 0.34, 0.12,   // 10: Middle PIP
      0.36, 0.46, 0.17,   // 11: Middle DIP
      0.38, 0.56, 0.21,   // 12: Middle TIP
      0.30, 0.18, 0.04,   // 13: Ring MCP
      0.35, 0.31, 0.09,   // 14: Ring PIP
      0.38, 0.42, 0.13,   // 15: Ring DIP
      0.40, 0.52, 0.17,   // 16: Ring TIP
      0.32, 0.16, 0.02,   // 17: Pinky MCP
      0.36, 0.28, 0.06,   // 18: Pinky PIP
      0.38, 0.38, 0.10,   // 19: Pinky DIP
      0.40, 0.47, 0.13,   // 20: Pinky TIP
    ],
    
    // Letter V: Index and middle fingers extended in V shape
    'V': [
      0.0, 0.0, 0.0,      // 0: Wrist
      0.15, 0.22, 0.05,   // 1: Thumb CMC
      0.18, 0.30, 0.08,   // 2: Thumb MCP
      0.20, 0.36, 0.10,   // 3: Thumb IP
      0.22, 0.42, 0.12,   // 4: Thumb TIP
      0.22, 0.18, 0.02,   // 5: Index MCP
      0.24, 0.40, 0.04,   // 6: Index PIP
      0.25, 0.62, 0.06,   // 7: Index DIP
      0.26, 0.84, 0.08,   // 8: Index TIP (extended)
      0.26, 0.18, 0.00,   // 9: Middle MCP
      0.30, 0.40, 0.00,   // 10: Middle PIP
      0.32, 0.62, 0.00,   // 11: Middle DIP
      0.34, 0.84, 0.00,   // 12: Middle TIP (extended)
      0.30, 0.16, -0.02,  // 13: Ring MCP
      0.34, 0.26, 0.00,   // 14: Ring PIP
      0.36, 0.34, 0.02,   // 15: Ring DIP
      0.38, 0.40, 0.04,   // 16: Ring TIP
      0.32, 0.14, -0.03,  // 17: Pinky MCP
      0.35, 0.23, -0.01,  // 18: Pinky PIP
      0.37, 0.30, 0.01,   // 19: Pinky DIP
      0.39, 0.36, 0.03,   // 20: Pinky TIP
    ],
    
    // Letter Y: Thumb and pinky extended
    'Y': [
      0.0, 0.0, 0.0,      // 0: Wrist
      0.15, 0.20, 0.08,   // 1: Thumb CMC
      0.18, 0.35, 0.12,   // 2: Thumb MCP
      0.20, 0.50, 0.15,   // 3: Thumb IP
      0.22, 0.65, 0.18,   // 4: Thumb TIP (extended)
      0.24, 0.18, 0.02,   // 5: Index MCP
      0.28, 0.28, 0.04,   // 6: Index PIP
      0.30, 0.36, 0.06,   // 7: Index DIP
      0.32, 0.42, 0.08,   // 8: Index TIP
      0.28, 0.16, 0.01,   // 9: Middle MCP
      0.33, 0.26, 0.03,   // 10: Middle PIP
      0.36, 0.34, 0.05,   // 11: Middle DIP
      0.38, 0.40, 0.07,   // 12: Middle TIP
      0.30, 0.14, 0.00,   // 13: Ring MCP
      0.35, 0.23, 0.02,   // 14: Ring PIP
      0.38, 0.30, 0.04,   // 15: Ring DIP
      0.40, 0.36, 0.06,   // 16: Ring TIP
      0.32, 0.12, -0.02,  // 17: Pinky MCP
      0.33, 0.32, -0.02,  // 18: Pinky PIP
      0.34, 0.52, -0.02,  // 19: Pinky DIP
      0.35, 0.72, -0.02,  // 20: Pinky TIP (extended)
    ],
    
    // TODO: Add remaining letters G, H, J, K, M, N, P, Q, R, S, T, U, W, X, Z
    // These should be populated with actual normalized landmark data
    // For now, using placeholder data
    'G': _generatePlaceholder(),
    'H': _generatePlaceholder(),
    'J': _generatePlaceholder(),
    'K': _generatePlaceholder(),
    'M': _generatePlaceholder(),
    'N': _generatePlaceholder(),
    'P': _generatePlaceholder(),
    'Q': _generatePlaceholder(),
    'R': _generatePlaceholder(),
    'S': _generatePlaceholder(),
    'T': _generatePlaceholder(),
    'U': _generatePlaceholder(),
    'W': _generatePlaceholder(),
    'X': _generatePlaceholder(),
    'Z': _generatePlaceholder(),
  };
  
  /// ASL Numbers (0-9)
  static const Map<String, List<double>> numbers = {
    // Number 0: Similar to letter O
    '0': [
      0.0, 0.0, 0.0,      // 0: Wrist
      0.18, 0.25, 0.12,   // 1-4: Thumb
      0.22, 0.38, 0.18,
      0.25, 0.48, 0.22,
      0.27, 0.56, 0.25,
      0.24, 0.22, 0.08,   // 5-8: Index
      0.28, 0.36, 0.14,
      0.30, 0.48, 0.19,
      0.31, 0.58, 0.23,
      0.28, 0.20, 0.06,   // 9-12: Middle
      0.33, 0.34, 0.12,
      0.36, 0.46, 0.17,
      0.38, 0.56, 0.21,
      0.30, 0.18, 0.04,   // 13-16: Ring
      0.35, 0.31, 0.09,
      0.38, 0.42, 0.13,
      0.40, 0.52, 0.17,
      0.32, 0.16, 0.02,   // 17-20: Pinky
      0.36, 0.28, 0.06,
      0.38, 0.38, 0.10,
      0.40, 0.47, 0.13,
    ],
    
    // Number 1: Index finger extended
    '1': [
      0.0, 0.0, 0.0,      // 0: Wrist
      0.15, 0.22, 0.05,   // 1-4: Thumb
      0.18, 0.30, 0.08,
      0.20, 0.36, 0.10,
      0.22, 0.42, 0.12,
      0.22, 0.18, 0.02,   // 5-8: Index (extended)
      0.24, 0.40, 0.02,
      0.25, 0.62, 0.02,
      0.26, 0.85, 0.02,
      0.28, 0.16, 0.00,   // 9-12: Middle
      0.32, 0.26, 0.03,
      0.34, 0.34, 0.05,
      0.36, 0.40, 0.07,
      0.30, 0.14, -0.01,  // 13-16: Ring
      0.34, 0.23, 0.02,
      0.36, 0.30, 0.04,
      0.38, 0.36, 0.06,
      0.32, 0.12, -0.02,  // 17-20: Pinky
      0.35, 0.20, 0.01,
      0.37, 0.27, 0.03,
      0.39, 0.33, 0.05,
    ],
    
    // Number 2: Index and middle fingers extended
    '2': [
      0.0, 0.0, 0.0,      // 0: Wrist
      0.15, 0.22, 0.05,   // 1-4: Thumb
      0.18, 0.30, 0.08,
      0.20, 0.36, 0.10,
      0.22, 0.42, 0.12,
      0.22, 0.18, 0.02,   // 5-8: Index (extended)
      0.24, 0.40, 0.04,
      0.25, 0.62, 0.06,
      0.26, 0.84, 0.08,
      0.26, 0.18, 0.00,   // 9-12: Middle (extended)
      0.30, 0.40, 0.00,
      0.32, 0.62, 0.00,
      0.34, 0.84, 0.00,
      0.30, 0.16, -0.02,  // 13-16: Ring
      0.34, 0.26, 0.00,
      0.36, 0.34, 0.02,
      0.38, 0.40, 0.04,
      0.32, 0.14, -0.03,  // 17-20: Pinky
      0.35, 0.23, -0.01,
      0.37, 0.30, 0.01,
      0.39, 0.36, 0.03,
    ],
    
    // Number 3: Thumb, index, and middle extended
    '3': [
      0.0, 0.0, 0.0,      // 0: Wrist
      0.15, 0.20, 0.08,   // 1-4: Thumb (extended)
      0.18, 0.35, 0.12,
      0.20, 0.50, 0.15,
      0.22, 0.65, 0.18,
      0.22, 0.18, 0.02,   // 5-8: Index (extended)
      0.24, 0.40, 0.04,
      0.25, 0.62, 0.06,
      0.26, 0.84, 0.08,
      0.26, 0.18, 0.00,   // 9-12: Middle (extended)
      0.30, 0.40, 0.00,
      0.32, 0.62, 0.00,
      0.34, 0.84, 0.00,
      0.30, 0.16, -0.02,  // 13-16: Ring
      0.34, 0.26, 0.00,
      0.36, 0.34, 0.02,
      0.38, 0.40, 0.04,
      0.32, 0.14, -0.03,  // 17-20: Pinky
      0.35, 0.23, -0.01,
      0.37, 0.30, 0.01,
      0.39, 0.36, 0.03,
    ],
    
    // Number 4: Four fingers extended, thumb folded
    '4': [
      0.0, 0.0, 0.0,      // 0: Wrist
      0.15, 0.22, 0.05,   // 1-4: Thumb (folded)
      0.18, 0.30, 0.08,
      0.20, 0.36, 0.10,
      0.22, 0.42, 0.12,
      0.22, 0.18, 0.02,   // 5-8: Index (extended)
      0.24, 0.40, 0.02,
      0.25, 0.62, 0.02,
      0.26, 0.84, 0.02,
      0.26, 0.18, 0.00,   // 9-12: Middle (extended)
      0.28, 0.40, 0.00,
      0.29, 0.62, 0.00,
      0.30, 0.84, 0.00,
      0.28, 0.16, -0.02,  // 13-16: Ring (extended)
      0.30, 0.38, -0.02,
      0.31, 0.60, -0.02,
      0.32, 0.82, -0.02,
      0.30, 0.14, -0.04,  // 17-20: Pinky (extended)
      0.31, 0.36, -0.04,
      0.32, 0.58, -0.04,
      0.33, 0.80, -0.04,
    ],
    
    // Number 5: All five fingers extended
    '5': [
      0.0, 0.0, 0.0,      // 0: Wrist
      0.15, 0.20, 0.08,   // 1-4: Thumb (extended)
      0.18, 0.35, 0.12,
      0.20, 0.50, 0.15,
      0.22, 0.65, 0.18,
      0.22, 0.18, 0.02,   // 5-8: Index (extended)
      0.24, 0.40, 0.02,
      0.25, 0.62, 0.02,
      0.26, 0.84, 0.02,
      0.26, 0.18, 0.00,   // 9-12: Middle (extended)
      0.28, 0.40, 0.00,
      0.29, 0.62, 0.00,
      0.30, 0.86, 0.00,
      0.28, 0.16, -0.02,  // 13-16: Ring (extended)
      0.30, 0.38, -0.02,
      0.31, 0.60, -0.02,
      0.32, 0.82, -0.02,
      0.30, 0.14, -0.04,  // 17-20: Pinky (extended)
      0.31, 0.36, -0.04,
      0.32, 0.58, -0.04,
      0.33, 0.78, -0.04,
    ],
    
    // Numbers 6-9: Placeholder data
    '6': _generatePlaceholder(),
    '7': _generatePlaceholder(),
    '8': _generatePlaceholder(),
    '9': _generatePlaceholder(),
  };
  
  /// Generate placeholder landmark data
  /// This should be replaced with actual normalized data
  static List<double> _generatePlaceholder() {
    return List.generate(63, (i) {
      // Generate semi-random but consistent values
      final landmarkIndex = i ~/ 3;
      final coord = i % 3;
      
      // Base position increases with landmark index
      final base = landmarkIndex * 0.04;
      
      // Add some variation based on coordinate
      final variation = coord == 0 ? 0.02 : (coord == 1 ? 0.03 : 0.01);
      
      return base + variation;
    });
  }
  
  /// Get all sign labels
  static List<String> get allLabels => signs.keys.toList();
  
  /// Get letter labels only
  static List<String> get letterLabels => letters.keys.toList();
  
  /// Get number labels only
  static List<String> get numberLabels => numbers.keys.toList();
  
  /// Check if a label exists in the database
  static bool hasSign(String label) => signs.containsKey(label.toUpperCase());
  
  /// Get landmark data for a specific sign
  static List<double>? getSign(String label) => signs[label.toUpperCase()];
  
  /// Validate that all signs have correct number of coordinates
  static bool validate() {
    for (final entry in signs.entries) {
      if (entry.value.length != AppConfig.numHandLandmarks * 3) {
        return false;
      }
    }
    return true;
  }
}