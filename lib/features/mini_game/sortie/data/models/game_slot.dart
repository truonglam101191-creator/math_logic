import 'dart:ui';

/// Shape types for game slots
enum SlotShape {
  rectangle,
  roundedRectangle,
  circle,
  oval,
  roundedWedge,
  keyhole,
  trapezoid,
  lShape,
  diamond,
  hexagon,
}

/// Difficulty levels for slots
enum SlotDifficulty { easy, medium, hard }

/// Model representing a slot where items can be placed
class GameSlot {
  final String id;
  double x;
  double y;
  double width;
  double height;
  final SlotShape shape;
  final String itemId; // The correct item that belongs in this slot
  double rotation;
  Color color;
  Color borderColor;
  Color backgroundColor;
  double cornerRadius;
  double borderRadius;
  double opacity;
  SlotDifficulty difficulty;
  double borderWidth;
  bool isHovering;
  double hoverIntensity;
  String label;

  GameSlot({
    required this.id,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.shape,
    required this.itemId,
    this.rotation = 0,
    this.color = const Color(0xFFF0F0F0),
    this.borderColor = const Color(0xFFCCCCCC),
    this.backgroundColor = const Color(0xFFF5F5F5),
    this.cornerRadius = 8,
    this.borderRadius = 8,
    this.opacity = 0.5,
    this.difficulty = SlotDifficulty.medium,
    this.borderWidth = 1,
    this.isHovering = false,
    this.hoverIntensity = 0,
    this.label = '',
  });

  factory GameSlot.fromJson(Map<String, dynamic> json) {
    return GameSlot(
      id: json['id'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      shape: _parseShape(json['shape'] as String? ?? 'rectangle'),
      itemId: json['itemId'] as String,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0,
      color: _parseColor(json['color'] as String? ?? '#f0f0f0'),
      borderColor: _parseColor(json['borderColor'] as String? ?? '#cccccc'),
      cornerRadius: (json['cornerRadius'] as num?)?.toDouble() ?? 8,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 0.5,
      difficulty: _parseDifficulty(json['difficulty'] as String? ?? 'medium'),
      borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'shape': _shapeToString(shape),
      'itemId': itemId,
      'rotation': rotation,
      'color': _colorToHex(color),
      'borderColor': _colorToHex(borderColor),
      'cornerRadius': cornerRadius,
      'opacity': opacity,
      'difficulty': _difficultyToString(difficulty),
      'borderWidth': borderWidth,
    };
  }

  /// Get center position of the slot
  Offset get center => Offset(x + width / 2, y + height / 2);

  /// Get bounding rect of the slot
  Rect get bounds => Rect.fromLTWH(x, y, width, height);

  /// Check if a point is inside the slot
  bool containsPoint(Offset point) {
    return bounds.contains(point);
  }

  /// Check if an item is close enough to snap to this slot
  bool isItemCloseEnough(Offset itemCenter) {
    final distance = (itemCenter - center).distance;
    final threshold = (width < height ? width : height) / 2 + 30;
    return distance < threshold;
  }

  static SlotShape _parseShape(String shape) {
    switch (shape.toLowerCase()) {
      case 'rounded_rectangle':
        return SlotShape.roundedRectangle;
      case 'circle':
        return SlotShape.circle;
      case 'oval':
        return SlotShape.oval;
      case 'rounded_wedge':
        return SlotShape.roundedWedge;
      case 'keyhole':
        return SlotShape.keyhole;
      case 'trapezoid':
        return SlotShape.trapezoid;
      case 'l_shape':
        return SlotShape.lShape;
      default:
        return SlotShape.rectangle;
    }
  }

  static String _shapeToString(SlotShape shape) {
    switch (shape) {
      case SlotShape.roundedRectangle:
        return 'rounded_rectangle';
      case SlotShape.circle:
        return 'circle';
      case SlotShape.oval:
        return 'oval';
      case SlotShape.roundedWedge:
        return 'rounded_wedge';
      case SlotShape.keyhole:
        return 'keyhole';
      case SlotShape.trapezoid:
        return 'trapezoid';
      case SlotShape.lShape:
        return 'l_shape';
      case SlotShape.diamond:
        return 'diamond';
      case SlotShape.hexagon:
        return 'hexagon';
      case SlotShape.rectangle:
        return 'rectangle';
    }
  }

  static SlotDifficulty _parseDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return SlotDifficulty.easy;
      case 'hard':
        return SlotDifficulty.hard;
      default:
        return SlotDifficulty.medium;
    }
  }

  static String _difficultyToString(SlotDifficulty difficulty) {
    switch (difficulty) {
      case SlotDifficulty.easy:
        return 'easy';
      case SlotDifficulty.hard:
        return 'hard';
      case SlotDifficulty.medium:
        return 'medium';
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
