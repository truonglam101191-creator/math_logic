import 'package:flutter/material.dart';
import '../models/evolution_item.dart';

/// Game dimension and physics constants
class GameConstants {
  // Canvas dimensions (logical)
  static const double canvasWidth = 720;
  static const double canvasHeight = 1280;

  // Container dimensions
  static const double containerWidth = 600;
  static const double containerHeight = 930;
  static const double containerX = (canvasWidth - containerWidth) / 2;
  static const double containerY = 250;

  // Danger line
  static const double dangerLineY = containerY + 50;
  static const int dangerTimeoutMs = 2000;

  // Drop settings
  static const double dropY = containerY - 50;
  static const double dropCooldownMs = 600;
  static const double dropPadding = 40;

  // Physics settings
  static const double gravity = 20.0;
  static const double friction = 0.6;
  static const double restitution = 0.2;
  static const double wallThickness = 60;

  // Container bounds
  static double get containerLeft => containerX;
  static double get containerRight => containerX + containerWidth;
  static double get containerBottom => containerY + containerHeight;

  // Drop bounds
  static double get minDropX => containerX + dropPadding;
  static double get maxDropX => containerX + containerWidth - dropPadding;

  // Colors
  static const Color containerBackground = Color(0xFFE8D4B8);
  static const Color containerBorder = Color(0xFF8B4513);
  static const Color dangerLineNormal = Color(0xFFE0E0E0);
  static const Color dangerLineActive = Color(0xFFF44336);
  static const double containerBorderWidth = 4.0;
}

/// Evolution types configuration
class EvolutionTypes {
  static const List<EvolutionType> types = [
    EvolutionType(
      level: 0,
      name: 'Ooze',
      size: 75,
      points: 10,
      assetId: 'evo_ooze',
      fallbackColor: Color(0xFF8B5CF6),
    ),
    EvolutionType(
      level: 1,
      name: 'Cell',
      size: 94,
      points: 20,
      assetId: 'evo_cell',
      fallbackColor: Color(0xFF06B6D4),
    ),
    EvolutionType(
      level: 2,
      name: 'Bacteria',
      size: 113,
      points: 40,
      assetId: 'evo_bacteria',
      fallbackColor: Color(0xFF10B981),
    ),
    EvolutionType(
      level: 3,
      name: 'Jellyfish',
      size: 138,
      points: 80,
      assetId: 'evo_jellyfish',
      fallbackColor: Color(0xFFF59E0B),
    ),
    EvolutionType(
      level: 4,
      name: 'Fish',
      size: 163,
      points: 160,
      assetId: 'evo_fish',
      fallbackColor: Color(0xFFEF4444),
    ),
    EvolutionType(
      level: 5,
      name: 'Amphibian',
      size: 188,
      points: 320,
      assetId: 'evo_amphibian',
      fallbackColor: Color(0xFFEC4899),
    ),
    EvolutionType(
      level: 6,
      name: 'Reptile',
      size: 219,
      points: 640,
      assetId: 'evo_reptile',
      fallbackColor: Color(0xFF6366F1),
    ),
    EvolutionType(
      level: 7,
      name: 'Mammal',
      size: 250,
      points: 1280,
      assetId: 'evo_mammal',
      fallbackColor: Color(0xFF84CC16),
    ),
    EvolutionType(
      level: 8,
      name: 'Primate',
      size: 288,
      points: 2560,
      assetId: 'evo_primate',
      fallbackColor: Color(0xFFF97316),
    ),
    EvolutionType(
      level: 9,
      name: 'Caveman',
      size: 325,
      points: 5120,
      assetId: 'evo_caveman',
      fallbackColor: Color(0xFF14B8A6),
    ),
    EvolutionType(
      level: 10,
      name: 'Human',
      size: 363,
      points: 10240,
      assetId: 'evo_human',
      fallbackColor: Color(0xFF8B5CF6),
    ),
  ];

  static EvolutionType getType(int index) {
    return types[index.clamp(0, types.length - 1)];
  }

  static int get maxLevel => types.length - 1;

  /// Get random type for initial drop (only first 4 types)
  static int getRandomDropType() {
    return (DateTime.now().millisecondsSinceEpoch % 4);
  }
}
