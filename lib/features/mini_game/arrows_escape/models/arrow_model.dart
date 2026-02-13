import 'dart:math';
import 'package:flutter/animation.dart';

enum ArrowDirection { up, down, left, right }

enum ArrowState { idle, moving, cleared, blocked }

class ArrowModel {
  ArrowModel({
    required this.id,
    required this.row,
    required this.col,
    required this.direction,
    required TickerProvider vsync,
    List<Point<int>>? occupiedPoints,
  }) {
    // If occupied points are provided (absolute), use them.
    // Otherwise, defaults to just head.
    if (occupiedPoints != null) {
      body = occupiedPoints;
    } else {
      body = [Point(row, col)];
    }

    moveController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 300),
    );
    shakeController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 400),
    );
  }

  final String id;
  // Anchor (Head) Position
  int row;
  int col;
  final ArrowDirection direction;

  // Occupied cells in absolute grid coordinates
  // Index 0 is typically the Head (Anchor)
  List<Point<int>> body = [];

  ArrowState state = ArrowState.idle;

  late AnimationController moveController;
  late AnimationController shakeController;

  void dispose() {
    moveController.dispose();
    shakeController.dispose();
  }

  // --- Factory Methods ---

  /// Creates a straight line arrow of Length [length]
  /// Rooted at [row, col] pointing in [direction].
  /// The body extends BACKWARDS from the direction.
  static ArrowModel createStraight({
    required String id,
    required int row,
    required int col,
    required int length,
    required ArrowDirection direction,
    required TickerProvider vsync,
  }) {
    List<Point<int>> points = [];
    int dR = 0;
    int dC = 0;

    // Body grows opposite to direction
    switch (direction) {
      case ArrowDirection.up:
        dR = 1;
        break; // Tail is Down
      case ArrowDirection.down:
        dR = -1;
        break; // Tail is Up
      case ArrowDirection.left:
        dC = 1;
        break; // Tail is Right
      case ArrowDirection.right:
        dC = -1;
        break; // Tail is Left
    }

    for (int i = 0; i < length; i++) {
      points.add(Point(row + (dR * i), col + (dC * i)));
    }

    return ArrowModel(
      id: id,
      row: row,
      col: col,
      direction: direction,
      vsync: vsync,
      occupiedPoints: points,
    );
  }

  /// Creates an L-Shaped arrow.
  /// L-Shape occupies 3 cells.
  /// [turnDirection]: +1 for Clockwise turn, -1 for Counter-Clockwise from the tail perspective.
  /// Actually, simpler to define as "Head, Neck, Tail".
  /// e.g. Head -> Back 1 Step -> Turn -> Back 1 Step.
  static ArrowModel createLShape({
    required String id,
    required int row,
    required int col,
    required ArrowDirection direction,
    required bool clockWiseTurn, // Direction of the "L" bend
    required TickerProvider vsync,
  }) {
    List<Point<int>> points = [];

    // 1. Head
    points.add(Point(row, col));

    // 2. Neck (One step back)
    int backR = 0;
    int backC = 0;
    switch (direction) {
      case ArrowDirection.up:
        backR = 1;
        break;
      case ArrowDirection.down:
        backR = -1;
        break;
      case ArrowDirection.left:
        backC = 1;
        break;
      case ArrowDirection.right:
        backC = -1;
        break;
    }

    Point<int> neck = Point(row + backR, col + backC);
    points.add(neck);

    // 3. Tail (Turn 90 degrees)
    // If facing UP, Back is DOWN.
    // Clockwise L means the *Body* turns Left relative to Facing?
    // Or the shape looks like 'L'?
    // Let's rely on vector rotation.
    // Vector Back = (backR, backC).
    // Clockwise 90 deg: (x, y) -> (y, -x) ? No.
    // Let's manually map.

    int tailR = 0;
    int tailC = 0;

    // Determine vector for tail extension based on Neck Position
    // We want the tail to stick out to the side.

    if (direction == ArrowDirection.up || direction == ArrowDirection.down) {
      // Vertical Arrow. Tail sticks Left or Right.
      // Clockwise: Up -> Right? No.
      if (clockWiseTurn) {
        tailC = 1; // Right
      } else {
        tailC = -1; // Left
      }
    } else {
      // Horizontal Arrow. Tail sticks Up or Down.
      if (clockWiseTurn) {
        tailR = 1; // Down
      } else {
        tailR = -1; // Up
      }
    }

    // Adjust for specific orientations if needed to match "Clockwise" strictly
    // But "Left/Right" turn is enough variety.

    points.add(Point(neck.x + tailR, neck.y + tailC));

    return ArrowModel(
      id: id,
      row: row,
      col: col,
      direction: direction,
      vsync: vsync,
      occupiedPoints: points,
    );
  }
}
