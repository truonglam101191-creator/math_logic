import 'package:flutter/material.dart';
import '../../logic/physics_controller.dart';

/// Represents an evolution stage item in the game
class EvolutionType {
  final int level;
  final String name;
  final double size;
  final int points;
  final String assetId;
  final Color fallbackColor;

  const EvolutionType({
    required this.level,
    required this.name,
    required this.size,
    required this.points,
    required this.assetId,
    required this.fallbackColor,
  });

  double get radius => size / 2;
  double get physicsRadius => radius * 0.9;
}

/// Represents a creature/fruit in the game world
class EvolutionItem {
  final String id;
  final int typeIndex;
  PhysicsBody? body;
  bool markedForDeletion;
  double visualSize;

  EvolutionItem({
    required this.id,
    required this.typeIndex,
    this.body,
    this.markedForDeletion = false,
    required this.visualSize,
  });

  Vec2 get position => body?.position ?? Vec2.zero();
  double get angle => body?.angle ?? 0.0;
  Vec2 get velocity => body?.velocity ?? Vec2.zero();

  bool get isSettled => velocity.length < 0.5;
}
