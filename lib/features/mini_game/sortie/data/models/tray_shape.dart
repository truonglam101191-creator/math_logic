import 'dart:ui';

/// Type of tray shape
enum TrayShapeType { rectangle, roundedRectangle, circle, oval, shelf }

/// Model representing a tray shape (background element)
class TrayShape {
  final String id;
  double x;
  double y;
  double width;
  double height;
  final TrayShapeType type;
  Color color;
  Color borderColor;
  double borderWidth;
  double cornerRadius;
  double rotation;
  double opacity;
  String? assetId;

  TrayShape({
    required this.id,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.type,
    this.color = const Color(0xFFC55230),
    this.borderColor = const Color(0xFFCCCCCC),
    this.borderWidth = 2,
    this.cornerRadius = 20,
    this.rotation = 0,
    this.opacity = 1.0,
    this.assetId,
  });

  factory TrayShape.fromJson(Map<String, dynamic> json) {
    return TrayShape(
      id: json['id'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      type: _parseType(json['type'] as String? ?? 'rounded_rectangle'),
      color: _parseColor(json['color'] as String? ?? '#c55230'),
      borderColor: _parseColor(json['borderColor'] as String? ?? '#ccc'),
      borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 2,
      cornerRadius: (json['cornerRadius'] as num?)?.toDouble() ?? 20,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
      assetId: json['assetId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'type': _typeToString(type),
      'color': _colorToHex(color),
      'borderColor': _colorToHex(borderColor),
      'borderWidth': borderWidth,
      'cornerRadius': cornerRadius,
      'rotation': rotation,
      'opacity': opacity,
      'assetId': assetId,
    };
  }

  /// Get bounding rect
  Rect get bounds => Rect.fromLTWH(x, y, width, height);

  static TrayShapeType _parseType(String type) {
    switch (type.toLowerCase()) {
      case 'circle':
        return TrayShapeType.circle;
      case 'oval':
        return TrayShapeType.oval;
      case 'rectangle':
        return TrayShapeType.rectangle;
      default:
        return TrayShapeType.roundedRectangle;
    }
  }

  static String _typeToString(TrayShapeType type) {
    switch (type) {
      case TrayShapeType.circle:
        return 'circle';
      case TrayShapeType.oval:
        return 'oval';
      case TrayShapeType.rectangle:
        return 'rectangle';
      case TrayShapeType.roundedRectangle:
        return 'rounded_rectangle';
      case TrayShapeType.shelf:
        return 'shelf';
    }
  }

  static Color _parseColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  static String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}
