import 'package:flutter/material.dart';

/// Represents a single tile in the Pikachu connect game.
class PikachuTile {
  final int id; // unique id per tile instance
  final int type; // type/category used to match pairs
  final bool isEmpty; // border/empty padding tile

  const PikachuTile({
    required this.id,
    required this.type,
    this.isEmpty = false,
  });

  PikachuTile empty(int id) => PikachuTile(id: id, type: -1, isEmpty: true);

  bool matches(PikachuTile other) =>
      !isEmpty && !other.isEmpty && type == other.type;
}

/// Configuration for the board size and tile types.
class BoardConfig {
  final int rows; // includes the outer empty border rows
  final int cols; // includes the outer empty border cols
  final int types; // number of distinct tile types

  const BoardConfig({
    required this.rows,
    required this.cols,
    required this.types,
  });
}

/// Simple style holder for tiles.
class TileStyle {
  final List<Color> palette;
  // Optional icon builder for a given type, returns a widget to place inside the tile.
  final Widget Function(BuildContext context, int type)? iconBuilder;

  const TileStyle(this.palette, {this.iconBuilder});

  Color colorFor(int type) {
    if (type < 0) return Colors.transparent;
    return palette[type % palette.length];
  }
}

/// Game state snapshot
class GameState {
  final List<List<PikachuTile>> grid;
  final PikachuTile? selectedA;
  final PikachuTile? selectedB;
  final List<Offset> pathPoints; // polyline to draw connection
  final int remainingPairs;

  const GameState({
    required this.grid,
    this.selectedA,
    this.selectedB,
    this.pathPoints = const [],
    required this.remainingPairs,
  });
}
