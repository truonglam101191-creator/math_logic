import 'dart:ui';

/// Theme item configuration
class ThemeItem {
  final String id;
  final String assetId;
  final String name;
  final Color color;

  const ThemeItem({
    required this.id,
    required this.assetId,
    required this.name,
    required this.color,
  });

  factory ThemeItem.fromJson(Map<String, dynamic> json) {
    return ThemeItem(
      id: json['id'] as String,
      assetId: json['assetId'] as String,
      name: json['name'] as String,
      color: _parseColor(json['color'] as String? ?? '#ffffff'),
    );
  }

  static Color _parseColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}

/// Game theme configuration
class GameTheme {
  final String id;
  final String name;
  final String icon;
  final String trayAsset;
  final Color backgroundColor;
  final String? backgroundMusic;
  final String? snapSound;
  final String? sparkleSound;
  final String? completionSound;
  final String? rustlingSound;
  final List<ThemeItem> items;

  const GameTheme({
    required this.id,
    required this.name,
    required this.icon,
    required this.trayAsset,
    this.backgroundColor = const Color(0xFFF5F5DC),
    this.backgroundMusic,
    this.snapSound,
    this.sparkleSound,
    this.completionSound,
    this.rustlingSound,
    required this.items,
  });

  /// Predefined themes
  static const Map<String, GameTheme> themes = {
    'medical': GameTheme(
      id: 'medical',
      name: 'Medical Kit',
      icon: 'medical_services',
      trayAsset: 'large_medical_tray',
      backgroundColor: Color(0xFF8B9EB0), // Blue-gray background like reference
      backgroundMusic: 'ambient_music',
      snapSound: 'snap_sound',
      sparkleSound: 'sparkle_sound',
      completionSound: 'completion_fanfare',
      rustlingSound: 'rustling_sound',
      items: [
        ThemeItem(
          id: 'stethoscope',
          assetId: 'pink_stethoscope',
          name: 'Stethoscope',
          color: Color(0xFFFF6B9D),
        ),
        ThemeItem(
          id: 'gloves',
          assetId: 'medical_gloves',
          name: 'Medical Gloves',
          color: Color(0xFF87CEEB),
        ),
        ThemeItem(
          id: 'pills',
          assetId: 'pill_bottle',
          name: 'Pill Bottle',
          color: Color(0xFFFFA07A),
        ),
        ThemeItem(
          id: 'thermometer',
          assetId: 'thermometer',
          name: 'Thermometer',
          color: Color(0xFF98FB98),
        ),
        ThemeItem(
          id: 'bottle',
          assetId: 'baby_bottle',
          name: 'Baby Bottle',
          color: Color(0xFFFFB6C1),
        ),
        ThemeItem(
          id: 'gauze',
          assetId: 'gauze_roll',
          name: 'Gauze Roll',
          color: Color(0xFFF5F5DC),
        ),
        ThemeItem(
          id: 'bandages',
          assetId: 'bandages',
          name: 'Bandages',
          color: Color(0xFFDEB887),
        ),
        ThemeItem(
          id: 'syringe',
          assetId: 'syringe',
          name: 'Syringe',
          color: Color(0xFFE0E0E0),
        ),
        ThemeItem(
          id: 'swabs',
          assetId: 'cotton_swabs',
          name: 'Cotton Swabs',
          color: Color(0xFFFFFFFF),
        ),
        ThemeItem(
          id: 'mask',
          assetId: 'medical_mask',
          name: 'Medical Mask',
          color: Color(0xFFADD8E6),
        ),
      ],
    ),
    'toolbox': GameTheme(
      id: 'toolbox',
      name: 'Tool Box',
      icon: 'handyman',
      trayAsset: 'toolbox_tray',
      backgroundColor: Color(0xFFFFF3E0), // Light orange workshop
      backgroundMusic: 'workshop_ambient',
      snapSound: 'metal_clink',
      sparkleSound: 'sparkle_sound',
      completionSound: 'completion_fanfare',
      rustlingSound: 'rustling_sound',
      items: [
        ThemeItem(
          id: 'hammer',
          assetId: 'hammer_tool',
          name: 'Hammer',
          color: Color(0xFF8B4513),
        ),
        ThemeItem(
          id: 'screwdriver',
          assetId: 'screwdriver_tool',
          name: 'Screwdriver',
          color: Color(0xFFFF4500),
        ),
        ThemeItem(
          id: 'wrench',
          assetId: 'wrench_tool',
          name: 'Wrench',
          color: Color(0xFFC0C0C0),
        ),
        ThemeItem(
          id: 'pliers',
          assetId: 'pliers_tool',
          name: 'Pliers',
          color: Color(0xFFDC143C),
        ),
        ThemeItem(
          id: 'measuring_tape',
          assetId: 'measuring_tape',
          name: 'Measuring Tape',
          color: Color(0xFFFFD700),
        ),
        ThemeItem(
          id: 'level',
          assetId: 'level_tool',
          name: 'Level',
          color: Color(0xFFFFFF00),
        ),
        ThemeItem(
          id: 'drill_bits',
          assetId: 'drill_bits',
          name: 'Drill Bits',
          color: Color(0xFF2F4F4F),
        ),
        ThemeItem(
          id: 'utility_knife',
          assetId: 'utility_knife',
          name: 'Utility Knife',
          color: Color(0xFFFF8C00),
        ),
        ThemeItem(
          id: 'safety_glasses',
          assetId: 'safety_glasses',
          name: 'Safety Glasses',
          color: Color(0xFF000000),
        ),
        ThemeItem(
          id: 'allen_wrench',
          assetId: 'allen_wrench_set',
          name: 'Allen Wrench Set',
          color: Color(0xFF696969),
        ),
      ],
    ),
    'farm': GameTheme(
      id: 'farm',
      name: 'Farm Garden',
      icon: 'agriculture',
      trayAsset: 'farm_tray',
      backgroundColor: Color(0xFFF1F8E9), // Light green farm
      backgroundMusic: 'farm_ambient',
      snapSound: 'garden_rustle',
      sparkleSound: 'sparkle_sound',
      completionSound: 'completion_fanfare',
      rustlingSound: 'garden_rustle',
      items: [
        ThemeItem(
          id: 'watering_can',
          assetId: 'watering_can',
          name: 'Watering Can',
          color: Color(0xFF228B22),
        ),
        ThemeItem(
          id: 'shovel',
          assetId: 'garden_shovel',
          name: 'Garden Shovel',
          color: Color(0xFF8B4513),
        ),
        ThemeItem(
          id: 'seeds',
          assetId: 'seed_packet',
          name: 'Seed Packet',
          color: Color(0xFF32CD32),
        ),
        ThemeItem(
          id: 'gloves',
          assetId: 'garden_gloves',
          name: 'Garden Gloves',
          color: Color(0xFFDEB887),
        ),
        ThemeItem(
          id: 'pot',
          assetId: 'plant_pot',
          name: 'Plant Pot',
          color: Color(0xFFCD853F),
        ),
        ThemeItem(
          id: 'shears',
          assetId: 'pruning_shears',
          name: 'Pruning Shears',
          color: Color(0xFFDC143C),
        ),
        ThemeItem(
          id: 'fertilizer',
          assetId: 'fertilizer_bag',
          name: 'Fertilizer',
          color: Color(0xFF8FBC8F),
        ),
        ThemeItem(
          id: 'rake',
          assetId: 'garden_rake',
          name: 'Hand Rake',
          color: Color(0xFFA0522D),
        ),
        ThemeItem(
          id: 'spray',
          assetId: 'spray_bottle',
          name: 'Spray Bottle',
          color: Color(0xFF00CED1),
        ),
        ThemeItem(
          id: 'trowel',
          assetId: 'garden_shovel',
          name: 'Trowel',
          color: Color(0xFFD2691E),
        ),
      ],
    ),
    'school': GameTheme(
      id: 'school',
      name: 'School Supplies',
      icon: 'school',
      trayAsset: 'school_tray',
      backgroundColor: Color(0xFFE3F2FD), // Light blue school
      backgroundMusic: 'school_ambient',
      snapSound: 'paper_rustle',
      sparkleSound: 'sparkle_sound',
      completionSound: 'completion_fanfare',
      rustlingSound: 'paper_rustle',
      items: [
        ThemeItem(
          id: 'pencil',
          assetId: 'pencil_item',
          name: 'Pencil',
          color: Color(0xFFFFD700),
        ),
        ThemeItem(
          id: 'eraser',
          assetId: 'eraser_item',
          name: 'Eraser',
          color: Color(0xFFFFB6C1),
        ),
        ThemeItem(
          id: 'scissors',
          assetId: 'scissors_item',
          name: 'Scissors',
          color: Color(0xFF4169E1),
        ),
        ThemeItem(
          id: 'glue',
          assetId: 'glue_stick',
          name: 'Glue Stick',
          color: Color(0xFF9370DB),
        ),
        ThemeItem(
          id: 'ruler',
          assetId: 'ruler_item',
          name: 'Ruler',
          color: Color(0xFF87CEEB),
        ),
        ThemeItem(
          id: 'crayons',
          assetId: 'crayon_box',
          name: 'Crayon Box',
          color: Color(0xFFFF6347),
        ),
        ThemeItem(
          id: 'notebook',
          assetId: 'notebook_item',
          name: 'Notebook',
          color: Color(0xFFDC143C),
        ),
        ThemeItem(
          id: 'calculator',
          assetId: 'calculator_item',
          name: 'Calculator',
          color: Color(0xFF32CD32),
        ),
        ThemeItem(
          id: 'stapler',
          assetId: 'stapler_item',
          name: 'Stapler',
          color: Color(0xFFFF8C00),
        ),
        ThemeItem(
          id: 'pencil_case',
          assetId: 'pencil_case',
          name: 'Pencil Case',
          color: Color(0xFFDA70D6),
        ),
      ],
    ),
    'art': GameTheme(
      id: 'art',
      name: 'Art Supplies',
      icon: 'palette',
      trayAsset: 'art_tray',
      backgroundColor: Color(0xFFFCE4EC), // Light pink art
      backgroundMusic: 'art_ambient',
      snapSound: 'brush_swish',
      sparkleSound: 'sparkle_sound',
      completionSound: 'completion_fanfare',
      rustlingSound: 'brush_swish',
      items: [
        ThemeItem(
          id: 'paint_brush',
          assetId: 'paint_brush',
          name: 'Paint Brush',
          color: Color(0xFF8B4513),
        ),
        ThemeItem(
          id: 'paint_palette',
          assetId: 'paint_palette',
          name: 'Paint Palette',
          color: Color(0xFFFFFFFF),
        ),
        ThemeItem(
          id: 'colored_pencils',
          assetId: 'colored_pencils',
          name: 'Colored Pencils',
          color: Color(0xFFFF6B35),
        ),
        ThemeItem(
          id: 'paint_tubes',
          assetId: 'paint_tubes',
          name: 'Paint Tubes',
          color: Color(0xFF4ECDC4),
        ),
        ThemeItem(
          id: 'art_canvas',
          assetId: 'art_canvas',
          name: 'Canvas',
          color: Color(0xFFF7F7F7),
        ),
        ThemeItem(
          id: 'art_markers',
          assetId: 'art_markers',
          name: 'Art Markers',
          color: Color(0xFFFF1744),
        ),
        ThemeItem(
          id: 'palette_knife',
          assetId: 'palette_knife',
          name: 'Palette Knife',
          color: Color(0xFF795548),
        ),
        ThemeItem(
          id: 'art_eraser',
          assetId: 'art_eraser',
          name: 'Kneaded Eraser',
          color: Color(0xFF9E9E9E),
        ),
        ThemeItem(
          id: 'sketch_pad',
          assetId: 'sketch_pad',
          name: 'Sketch Pad',
          color: Color(0xFFFAFAFA),
        ),
        ThemeItem(
          id: 'charcoal_sticks',
          assetId: 'charcoal_sticks',
          name: 'Charcoal Sticks',
          color: Color(0xFF212121),
        ),
      ],
    ),
  };

  /// Level order for progression
  static const List<String> levelOrder = [
    'medical',
    'toolbox',
    'farm',
    'school',
    'art',
    'toybox',
    'kitchen',
    'backpack',
    'bathroom',
    'gardening',
  ];

  /// Get theme by level number (1-based)
  static GameTheme? getThemeByLevel(int level) {
    if (level < 1 || level > levelOrder.length) return null;
    return themes[levelOrder[level - 1]];
  }
}
