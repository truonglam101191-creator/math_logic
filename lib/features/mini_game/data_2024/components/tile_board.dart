import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../const/colors.dart';
import '../managers/board.dart';

import 'animated_tile.dart';
import 'button.dart';

class TileBoardWidget extends ConsumerWidget {
  const TileBoardWidget({
    super.key,
    required this.moveAnimation,
    required this.scaleAnimation,
  });

  final CurvedAnimation moveAnimation;
  final CurvedAnimation scaleAnimation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final board = ref.watch(boardManager);

    //Decides the maximum size the Board can be based on the shortest size of the screen.
    final size = max(
      290.0,
      min(
        (MediaQuery.of(context).size.shortestSide * 0.90).floorToDouble(),
        460.0,
      ),
    );

    //Decide the size of the tile based on the size of the board minus the space between each tile.
    final sizePerTile = (size / 4).floorToDouble();
    final tileSize = sizePerTile - 16.0 - (16.0 / 4);
    final boardSize = sizePerTile * 4;
    return SizedBox(
      width: boardSize,
      height: boardSize,
      child: Stack(
        children: [
          ...List.generate(board.tiles.length, (i) {
            var tile = board.tiles[i];

            return AnimatedTile(
              key: ValueKey(tile.id),
              tile: tile,
              moveAnimation: moveAnimation,
              scaleAnimation: scaleAnimation,
              size: tileSize,
              //In order to optimize performances and prevent unneeded re-rendering the actual tile is passed as child to the AnimatedTile
              //as the tile won't change for the duration of the movement (apart from it's position)
              child: Container(
                width: tileSize,
                height: tileSize,
                decoration: BoxDecoration(
                  color: tileColors[tile.value],
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${tile.value}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: _getFontSize(tile.value, tileSize),
                      color: tile.value < 8 ? textColor : textColorWhite,
                    ),
                  ),
                ),
              ),
            );
          }),
          if (board.over)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      board.won ? Icons.emoji_events : Icons.refresh,
                      size: 80,
                      color: board.won ? Colors.amber : Colors.red,
                    ),
                    SizedBox(height: 20),
                    Text(
                      board.won ? 'You Win!' : 'Game Over!',
                      style: TextStyle(
                        color: board.won
                            ? Colors.amber.shade700
                            : Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 48.0,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Score: ${board.score}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 24.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 30),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: board.won
                              ? [Colors.amber, Colors.orange]
                              : [Color(0xFFf093fb), Color(0xFFf5576c)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            ref.read(boardManager.notifier).newGame();
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 16,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  board.won ? 'New Game' : 'Try Again',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Helper method to calculate font size based on tile value
  double _getFontSize(int value, double tileSize) {
    if (value < 100) {
      return tileSize * 0.45;
    } else if (value < 1000) {
      return tileSize * 0.35;
    } else if (value < 10000) {
      return tileSize * 0.28;
    } else {
      return tileSize * 0.22;
    }
  }
}
