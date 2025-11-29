import 'dart:math';

/// Represents a 3D point in space
class Point3D {
  final double x;
  final double y;
  final double z;
  
  const Point3D(this.x, this.y, this.z);
  
  /// Calculate the magnitude (length) of the vector from origin
  double get magnitude => sqrt(x * x + y * y + z * z);
  
  /// Subtract another point (vector subtraction)
  Point3D operator -(Point3D other) {
    return Point3D(
      x - other.x,
      y - other.y,
      z - other.z,
    );
  }
  
  /// Add another point (vector addition)
  Point3D operator +(Point3D other) {
    return Point3D(
      x + other.x,
      y + other.y,
      z + other.z,
    );
  }
  
  /// Divide by scalar
  Point3D operator /(double scalar) {
    if (scalar == 0) {
      throw ArgumentError('Cannot divide by zero');
    }
    return Point3D(
      x / scalar,
      y / scalar,
      z / scalar,
    );
  }
  
  /// Multiply by scalar
  Point3D operator *(double scalar) {
    return Point3D(
      x * scalar,
      y * scalar,
      z * scalar,
    );
  }
  
  /// Calculate Euclidean distance to another point
  double distanceTo(Point3D other) {
    return (this - other).magnitude;
  }
  
  /// Calculate dot product with another point
  double dot(Point3D other) {
    return x * other.x + y * other.y + z * other.z;
  }
  
  /// Normalize the vector (make it unit length)
  Point3D normalize() {
    final mag = magnitude;
    if (mag == 0) {
      return const Point3D(0, 0, 0);
    }
    return this / mag;
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'z': z,
    };
  }
  
  /// Create from JSON
  factory Point3D.fromJson(Map<String, dynamic> json) {
    return Point3D(
      (json['x'] as num).toDouble(),
      (json['y'] as num).toDouble(),
      (json['z'] as num).toDouble(),
    );
  }
  
  @override
  String toString() => 'Point3D($x, $y, $z)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Point3D &&
        other.x == x &&
        other.y == y &&
        other.z == z;
  }
  
  @override
  int get hashCode => Object.hash(x, y, z);
}