import 'dart:ui';

/// Model representing a draggable game item in the Sortie game
class GameItem {
  final String id;
  final String assetId;
  final String name;
  double x;
  double y;
  final double startX;
  final double startY;
  double width;
  double height;
  final Color color;
  bool isPlaced;
  String? slotId;
  double rotation;
  double opacity;
  bool isDragging;
  bool isIncorrectlyPlaced;
  int? lastIncorrectPlacement;

  GameItem({
    required this.id,
    required this.assetId,
    required this.name,
    required this.x,
    required this.y,
    required this.startX,
    required this.startY,
    required this.width,
    required this.height,
    required this.color,
    this.isPlaced = false,
    this.slotId,
    this.rotation = 0,
    this.opacity = 1.0,
    this.isDragging = false,
    this.isIncorrectlyPlaced = false,
    this.lastIncorrectPlacement,
  });

  factory GameItem.fromJson(Map<String, dynamic> json) {
    return GameItem(
      id: json['id'] as String,
      assetId: json['assetId'] as String,
      name: json['name'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      startX:
          (json['startX'] as num?)?.toDouble() ?? (json['x'] as num).toDouble(),
      startY:
          (json['startY'] as num?)?.toDouble() ?? (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      color: _parseColor(json['color'] as String? ?? '#ffffff'),
      isPlaced: json['isPlaced'] as bool? ?? false,
      slotId: json['slotId'] as String?,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assetId': assetId,
      'name': name,
      'x': x,
      'y': y,
      'startX': startX,
      'startY': startY,
      'width': width,
      'height': height,
      'color': _colorToHex(color),
      'isPlaced': isPlaced,
      'slotId': slotId,
      'rotation': rotation,
      'opacity': opacity,
    };
  }

  /// Reset item to its starting position
  void reset() {
    x = startX;
    y = startY;
    isPlaced = false;
    slotId = null;
    isDragging = false;
    isIncorrectlyPlaced = false;
    lastIncorrectPlacement = null;
  }

  /// Get center position of the item
  Offset get center => Offset(x + width / 2, y + height / 2);

  /// Get bounding rect of the item
  Rect get bounds => Rect.fromLTWH(x, y, width, height);

  /// Check if a point is inside the item
  bool containsPoint(Offset point) {
    return bounds.contains(point);
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

  GameItem copyWith({
    String? id,
    String? assetId,
    String? name,
    double? x,
    double? y,
    double? startX,
    double? startY,
    double? width,
    double? height,
    Color? color,
    bool? isPlaced,
    String? slotId,
    double? rotation,
    double? opacity,
  }) {
    return GameItem(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      name: name ?? this.name,
      x: x ?? this.x,
      y: y ?? this.y,
      startX: startX ?? this.startX,
      startY: startY ?? this.startY,
      width: width ?? this.width,
      height: height ?? this.height,
      color: color ?? this.color,
      isPlaced: isPlaced ?? this.isPlaced,
      slotId: slotId ?? this.slotId,
      rotation: rotation ?? this.rotation,
      opacity: opacity ?? this.opacity,
    );
  }
}
