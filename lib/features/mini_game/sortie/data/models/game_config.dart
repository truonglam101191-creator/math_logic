import 'dart:convert';
import 'game_item.dart';
import 'game_slot.dart';
import 'tray_shape.dart';

/// Animation settings
class AnimationSettings {
  final double snapSpeed;
  final double bounceIntensity;
  final double sparkleIntensity;

  const AnimationSettings({
    this.snapSpeed = 1.2,
    this.bounceIntensity = 1.3,
    this.sparkleIntensity = 1.9,
  });

  factory AnimationSettings.fromJson(Map<String, dynamic> json) {
    return AnimationSettings(
      snapSpeed: (json['snapSpeed'] as num?)?.toDouble() ?? 1.2,
      bounceIntensity: (json['bounceIntensity'] as num?)?.toDouble() ?? 1.3,
      sparkleIntensity: (json['sparkleIntensity'] as num?)?.toDouble() ?? 1.9,
    );
  }

  Map<String, dynamic> toJson() => {
    'snapSpeed': snapSpeed,
    'bounceIntensity': bounceIntensity,
    'sparkleIntensity': sparkleIntensity,
  };
}

/// UI settings
class UISettings {
  final String theme;
  final bool showHelpOnStart;
  final bool enableHints;
  final String primaryColor;
  final String secondaryColor;
  final String successColor;
  final bool enablePreviewMode;
  final bool showGlowEffects;

  const UISettings({
    this.theme = 'soft-medical',
    this.showHelpOnStart = false,
    this.enableHints = true,
    this.primaryColor = '#ff6b9d',
    this.secondaryColor = '#ff4757',
    this.successColor = '#2ed573',
    this.enablePreviewMode = true,
    this.showGlowEffects = true,
  });

  factory UISettings.fromJson(Map<String, dynamic> json) {
    return UISettings(
      theme: json['theme'] as String? ?? 'soft-medical',
      showHelpOnStart: json['showHelpOnStart'] as bool? ?? false,
      enableHints: json['enableHints'] as bool? ?? true,
      primaryColor: json['primaryColor'] as String? ?? '#ff6b9d',
      secondaryColor: json['secondaryColor'] as String? ?? '#ff4757',
      successColor: json['successColor'] as String? ?? '#2ed573',
      enablePreviewMode:
          json['enablePreviewMode'] == 'true' ||
          json['enablePreviewMode'] == true,
      showGlowEffects:
          json['showGlowEffects'] == 'true' || json['showGlowEffects'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'theme': theme,
    'showHelpOnStart': showHelpOnStart,
    'enableHints': enableHints,
    'primaryColor': primaryColor,
    'secondaryColor': secondaryColor,
    'successColor': successColor,
    'enablePreviewMode': enablePreviewMode.toString(),
    'showGlowEffects': showGlowEffects.toString(),
  };
}

/// Scoring settings
class ScoringSettings {
  final int basePoints;
  final int maxMultiplier;
  final double streakBonus;

  const ScoringSettings({
    this.basePoints = 100,
    this.maxMultiplier = 5,
    this.streakBonus = 0.5,
  });

  factory ScoringSettings.fromJson(Map<String, dynamic> json) {
    return ScoringSettings(
      basePoints: (json['basePoints'] as num?)?.toInt() ?? 100,
      maxMultiplier: (json['maxMultiplier'] as num?)?.toInt() ?? 5,
      streakBonus: (json['streakBonus'] as num?)?.toDouble() ?? 0.5,
    );
  }

  Map<String, dynamic> toJson() => {
    'basePoints': basePoints,
    'maxMultiplier': maxMultiplier,
    'streakBonus': streakBonus,
  };
}

/// Tray configuration
class TrayConfig {
  final List<TrayShape> shapes;

  TrayConfig({required this.shapes});

  factory TrayConfig.fromJson(Map<String, dynamic> json) {
    final shapesJson = json['shapes'] as List<dynamic>? ?? [];
    return TrayConfig(
      shapes: shapesJson
          .map((s) => TrayShape.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'shapes': shapes.map((s) => s.toJson()).toList(),
  };
}

/// Complete game configuration
class GameConfig {
  final TrayConfig tray;
  final AnimationSettings animations;
  final UISettings ui;
  final ScoringSettings scoring;
  final String currentTheme;
  final int currentLevel;
  final List<int> unlockedLevels;
  final int maxLevels;
  List<GameItem> items;
  List<GameSlot> slots;
  final Map<String, dynamic>? levelConfigurations;

  GameConfig({
    required this.tray,
    required this.animations,
    required this.ui,
    required this.scoring,
    required this.currentTheme,
    required this.currentLevel,
    required this.unlockedLevels,
    required this.maxLevels,
    required this.items,
    required this.slots,
    this.levelConfigurations,
  });

  factory GameConfig.fromJson(Map<String, dynamic> json) {
    // Parse items (can be string or list)
    List<GameItem> items = [];
    final itemsData = json['items'];
    if (itemsData is String) {
      try {
        final parsed = jsonDecode(itemsData) as List<dynamic>;
        items = parsed
            .map((i) => GameItem.fromJson(i as Map<String, dynamic>))
            .toList();
      } catch (e) {
        items = [];
      }
    } else if (itemsData is List) {
      items = itemsData
          .map((i) => GameItem.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    // Parse slots (can be string or list)
    List<GameSlot> slots = [];
    final slotsData = json['slots'];
    if (slotsData is String) {
      try {
        final parsed = jsonDecode(slotsData) as List<dynamic>;
        slots = parsed
            .map((s) => GameSlot.fromJson(s as Map<String, dynamic>))
            .toList();
      } catch (e) {
        slots = [];
      }
    } else if (slotsData is List) {
      slots = slotsData
          .map((s) => GameSlot.fromJson(s as Map<String, dynamic>))
          .toList();
    }

    return GameConfig(
      tray: TrayConfig.fromJson(
        json['tray'] as Map<String, dynamic>? ?? {'shapes': []},
      ),
      animations: AnimationSettings.fromJson(
        json['animations'] as Map<String, dynamic>? ?? {},
      ),
      ui: UISettings.fromJson(json['ui'] as Map<String, dynamic>? ?? {}),
      scoring: ScoringSettings.fromJson(
        json['scoring'] as Map<String, dynamic>? ?? {},
      ),
      currentTheme: json['currentTheme'] as String? ?? 'medical',
      currentLevel: (json['currentLevel'] as num?)?.toInt() ?? 1,
      unlockedLevels:
          (json['unlockedLevels'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [1],
      maxLevels: (json['maxLevels'] as num?)?.toInt() ?? 10,
      items: items,
      slots: slots,
      levelConfigurations: json['levelConfigurations'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'tray': tray.toJson(),
    'animations': animations.toJson(),
    'ui': ui.toJson(),
    'scoring': scoring.toJson(),
    'currentTheme': currentTheme,
    'currentLevel': currentLevel,
    'unlockedLevels': unlockedLevels,
    'maxLevels': maxLevels,
    'items': jsonEncode(items.map((i) => i.toJson()).toList()),
    'slots': jsonEncode(slots.map((s) => s.toJson()).toList()),
    'levelConfigurations': levelConfigurations,
  };
}
