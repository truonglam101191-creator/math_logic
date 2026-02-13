import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/arrow_model.dart';
// Alias ArrowModel as PuzzlePiece if desired, but sticking to class name
// The user asked for PuzzlePiece concept, ArrowModel fulfills it.

class GameController extends ChangeNotifier {
  GameController({required TickerProvider vsync}) : _vsync = vsync {
    generateLevel(8, 120); // 8x8 grid
  }

  final TickerProvider _vsync;

  int gridSize = 8;
  List<ArrowModel> arrows = [];
  bool isAnimating = false;
  bool isLevelComplete = false;

  /// Snake/Uncurling Collision Logic
  /// Returns TRUE if piece passes snake-like movement check
  bool canMove(ArrowModel piece, {List<ArrowModel>? contextArrows}) {
    int dR = 0;
    int dC = 0;
    switch (piece.direction) {
      case ArrowDirection.up:
        dR = -1;
        break;
      case ArrowDirection.down:
        dR = 1;
        break;
      case ArrowDirection.left:
        dC = -1;
        break;
      case ArrowDirection.right:
        dC = 1;
        break;
    }

    // Snake Movement:
    // Head moves (dR, dC). Body[i] moves to Body[i-1].
    List<Point<int>> currentShape = List.from(piece.body);
    int maxSteps = gridSize * 3;

    for (int step = 0; step < maxSteps; step++) {
      // 1. Calculate Next Shape
      List<Point<int>> nextShape = [];

      // New Head
      nextShape.add(Point(currentShape[0].x + dR, currentShape[0].y + dC));

      // Body follows
      for (int i = 1; i < currentShape.length; i++) {
        nextShape.add(currentShape[i - 1]);
      }

      // Check bounds: If ALL points are off-board, success.
      bool allOutOfBounds = nextShape.every(
        (p) => p.x < 0 || p.x >= gridSize || p.y < 0 || p.y >= gridSize,
      );

      if (allOutOfBounds) return true; // SUCCESS

      // 3. Collision Check
      for (var p in nextShape) {
        if (p.x >= 0 && p.x < gridSize && p.y >= 0 && p.y < gridSize) {
          if (_isCollision(
            p,
            ignoreId: piece.id,
            contextArrows: contextArrows,
          )) {
            return false; // BLOCKED
          }
        }
      }

      // Update for next iteration
      currentShape = nextShape;
    }

    return true; // Should have exited by now
  }

  // Simulation helper for solvability (Snake logic)
  bool _canMoveSimulation(
    ArrowModel piece,
    List<ArrowModel> allArrows,
    Set<String> clearedIds,
  ) {
    int dR = 0;
    int dC = 0;
    switch (piece.direction) {
      case ArrowDirection.up:
        dR = -1;
        break;
      case ArrowDirection.down:
        dR = 1;
        break;
      case ArrowDirection.left:
        dC = -1;
        break;
      case ArrowDirection.right:
        dC = 1;
        break;
    }

    List<Point<int>> currentShape = List.from(piece.body);
    int maxSteps = gridSize * 3;

    for (int step = 0; step < maxSteps; step++) {
      List<Point<int>> nextShape = [];
      nextShape.add(Point(currentShape[0].x + dR, currentShape[0].y + dC));
      for (int i = 1; i < currentShape.length; i++) {
        nextShape.add(currentShape[i - 1]);
      }

      bool allOutOfBounds = nextShape.every(
        (p) => p.x < 0 || p.x >= gridSize || p.y < 0 || p.y >= gridSize,
      );
      if (allOutOfBounds) return true;

      for (var p in nextShape) {
        if (p.x >= 0 && p.x < gridSize && p.y >= 0 && p.y < gridSize) {
          for (var other in allArrows) {
            if (clearedIds.contains(other.id)) continue;
            if (other.id == piece.id) continue;
            for (var op in other.body) {
              if (op.x == p.x && op.y == p.y) return false;
            }
          }
        }
      }
      currentShape = nextShape;
    }
    return true;
  }

  bool _isCollision(
    Point<int> p, {
    String? ignoreId,
    List<ArrowModel>? contextArrows,
  }) {
    // Use provided context or default to live arrows
    final list = contextArrows ?? arrows;

    for (var other in list) {
      if (other.state == ArrowState.cleared) continue;
      if (other.id == ignoreId) continue;

      for (var op in other.body) {
        if (op.x == p.x && op.y == p.y) return true;
      }
    }
    return false;
  }

  void handleGridTap(int row, int col) {
    if (isAnimating) return;

    // Find clicked piece
    ArrowModel? target;
    for (var arrow in arrows) {
      if (arrow.state == ArrowState.cleared) continue;
      for (var p in arrow.body) {
        if (p.x == row && p.y == col) {
          target = arrow;
          break;
        }
      }
      if (target != null) break;
    }

    if (target != null) {
      _attemptMove(target);
    }
  }

  void _attemptMove(ArrowModel piece) {
    if (canMove(piece)) {
      // Success Animation
      HapticFeedback.mediumImpact();
      piece.state = ArrowState.moving;
      isAnimating = true; // Global lock

      piece.moveController.forward(from: 0).then((_) {
        piece.state = ArrowState.cleared;
        isAnimating = false;
        checkLevelComplete();
        notifyListeners();
      });
    } else {
      // Fail Animation
      HapticFeedback.lightImpact();
      piece.state = ArrowState.blocked;
      piece.shakeController.forward(from: 0).then((_) {
        piece.state = ArrowState.idle;
        notifyListeners();
      });
    }
    notifyListeners();
  }

  // --- Level Generation (Solvable) ---
  void generateLevel(int size, int count) {
    gridSize = size;

    // Attempt to generate a solvable level
    int maxLevelAttempts = 50; // Try 50 different board configurations
    for (int i = 0; i < maxLevelAttempts; i++) {
      disposeAll();
      arrows.clear();
      isLevelComplete = false;

      // 1. Generate Random Layout
      _fillBoardRandomly(size, count);

      // 2. Test Solvability
      if (isSolvable(arrows)) {
        // Success! Keep this layout.
        notifyListeners();
        return;
      }

      // Fail: Discard and retry (handled by disposeAll at start of loop)
    }

    // Fallback if no complex level found: Generate a sparse easy level
    disposeAll();
    arrows.clear();
    _fillBoardRandomly(size, (count * 0.5).floor()); // Fewer arrows
    notifyListeners();
  }

  void _fillBoardRandomly(int size, int targetCount) {
    final r = Random();
    int placed = 0;
    int attempts = 0;

    while (placed < targetCount && attempts < 1000) {
      attempts++;
      int row = r.nextInt(size);
      int col = r.nextInt(size);
      ArrowDirection dir = ArrowDirection.values[r.nextInt(4)];
      bool isL = r.nextBool();

      ArrowModel newPiece;
      String id =
          DateTime.now().microsecondsSinceEpoch.toString() +
          r.nextInt(1000).toString();

      if (isL) {
        newPiece = ArrowModel.createLShape(
          id: id,
          row: row,
          col: col,
          direction: dir,
          clockWiseTurn: r.nextBool(),
          vsync: _vsync,
        );
      } else {
        newPiece = ArrowModel.createStraight(
          id: id,
          row: row,
          col: col,
          direction: dir,
          length: 3 + r.nextInt(3), // Len 3, 4, 5
          vsync: _vsync,
        );
      }

      // Check immediate placement collision
      bool overlap = false;
      for (var p in newPiece.body) {
        if (p.x < 0 || p.x >= size || p.y < 0 || p.y >= size) overlap = true;
        if (_isCollision(p)) overlap = true;
      }

      if (!overlap) {
        arrows.add(newPiece);
        placed++;
      }
    }
  }

  /// Checks if the given board configuration is solvable.
  /// Does NOT modify the arrows directly (uses simulation state).
  bool isSolvable(List<ArrowModel> initialArrows) {
    // We need to simulate the game flow.
    // Since 'arrows' are stateful objects with controllers, checking solvability
    // without breaking them is tricky.
    // Strategy:
    // 1. Create a Set of "Cleared IDs".
    // 2. Loop until no more moves possible.
    // 3. If Cleared Count == Total, Solvable.

    Set<String> clearedIds = {};
    bool progress = true;

    while (progress) {
      progress = false;

      for (var arrow in initialArrows) {
        if (clearedIds.contains(arrow.id)) continue;

        // Check if this arrow can move given the CURRENT simulation state
        // We need to pass a special Context to canMove.
        // However, canMove calls _isCollision which iterates 'arrows'.
        // Ideally, we shouldn't modify the real 'arrows' list.
        // BUT logic is: _isCollision ignores 'cleared' arrows.
        // So we can mock the state by passing a list where some arrows
        // are treated as 'cleared' temporarily.

        // Actually, canMove logic depends on ArrowState.
        // We can't change ArrowState on the real objects without affecting UI?
        // Correction: This runs inside generateLevel BEFORE notifyListeners().
        // The UI hasn't seen these arrows yet!
        // So we CAN toggle their state freely, as long as we reset it if we fail.
        // OR: Maintain a local set of cleared IDs and pass it to collision check?
        // _isCollision reads 'other.state'.

        // Cleaner: just temporarily set state to cleared if move simulation passes.
        // But wait, canMove() returns boolean. It doesn't change state.
        // We need a version of canMove that checks collision against a filter.

        if (_canMoveSimulation(arrow, initialArrows, clearedIds)) {
          clearedIds.add(arrow.id);
          progress = true;
          // We don't need to break here; we can find multiple moves in one pass.
          // But strictly, order matters?
          // In this game, order only matters if A blocks B.
          // If A moves, B might move.
          // If we mark A as cleared, next iteration B might move.
        }
      }
    }

    return clearedIds.length == initialArrows.length;
  }

  // bool _canMoveSimulation(
  //   ArrowModel piece,
  //   List<ArrowModel> allArrows,
  //   Set<String> clearedIds,
  // ) {
  //   // Re-implement simplified check logic avoiding dependency on 'this.arrows'
  //   // basically copy of canMove but using clearedIds for collision check

  //   int dR = 0;
  //   int dC = 0;
  //   switch (piece.direction) {
  //     case ArrowDirection.up:
  //       dR = -1;
  //       break;
  //     case ArrowDirection.down:
  //       dR = 1;
  //       break;
  //     case ArrowDirection.left:
  //       dC = -1;
  //       break;
  //     case ArrowDirection.right:
  //       dC = 1;
  //       break;
  //   }

  //   List<Point<int>> currentShape = List.from(piece.body);
  //   int maxSteps = gridSize * 2;

  //   for (int step = 0; step < maxSteps; step++) {
  //     List<Point<int>> nextShape = [];
  //     Point<int> head = currentShape[0];
  //     Point<int> nextHead = Point(head.x + dR, head.y + dC);
  //     nextShape.add(nextHead);
  //     for (int i = 1; i < currentShape.length; i++)
  //       nextShape.add(currentShape[i - 1]);

  //     bool allOutOfBounds = nextShape.every(
  //       (p) => p.x < 0 || p.x >= gridSize || p.y < 0 || p.y >= gridSize,
  //     );
  //     if (allOutOfBounds) return true;

  //     for (var p in nextShape) {
  //       if (p.x >= 0 && p.x < gridSize && p.y >= 0 && p.y < gridSize) {
  //         // Collision Check using clearedIds
  //         for (var other in allArrows) {
  //           if (clearedIds.contains(other.id)) continue; // Simulated Cleared
  //           if (other.id == piece.id) continue;
  //           for (var op in other.body) {
  //             if (op.x == p.x && op.y == p.y) return false; // Collision
  //           }
  //         }
  //       }
  //     }
  //     currentShape = nextShape;
  //   }
  //   return true;
  // }

  void checkLevelComplete() {
    if (arrows.every((a) => a.state == ArrowState.cleared)) {
      isLevelComplete = true;
      HapticFeedback.heavyImpact();
    }
  }

  void restartLevel() {
    generateLevel(gridSize, 10);
  }

  void disposeAll() {
    for (var a in arrows) a.dispose();
    arrows.clear();
  }

  @override
  void dispose() {
    disposeAll();
    super.dispose();
  }
}
