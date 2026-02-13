import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logic_mathematics/features/mini_game/logic_tetris/logic_of_game.dart';
import 'package:logic_mathematics/features/mini_game/logic_tetris/pixels.dart';
import 'package:logic_mathematics/features/mini_game/logic_tetris/pieces.dart'
    as pieces;
import 'package:logic_mathematics/features/mini_game/logic_tetris/shapes.dart';

// The TetrisGame is a 2D list that represents the game grid.
// a non empty space will have the color to represent the landing piece

class TetrisGame extends StatefulWidget {
  const TetrisGame({super.key});
  @override
  State<TetrisGame> createState() => _TetrisGameState();
}

class _TetrisGameState extends State<TetrisGame> {
  Timer? _gameTimer;
  @override
  void initState() {
    super.initState();
    // start game when app start
    startGame();
  }

  void startGame() {
    currentPiece.intializePiece();
    Duration frameRate = const Duration(milliseconds: 400);
    gameLoop(frameRate);
  }

  void gameLoop(Duration frameRate) {
    // Cancel any previous timer before starting a new loop
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(frameRate, (timer) {
      // Guard against calling setState after dispose
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        clearLine();
        checkLadning();
        // check if game is over
        if (gameOver == true) {
          timer.cancel();
          _gameTimer = null;
          showGameOverMessageDialog();
          return;
        }
        //move currentPieceDown
        currentPiece.movePiece(pieces.Direction.down);
      });
    });
  }

  void showGameOverMessageDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        title: Column(
          children: [
            Icon(Icons.videogame_asset_off, size: 64, color: Color(0xFFf7971e)),
            SizedBox(height: 16),
            Text(
              'GAME OVER',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 32,
                color: Color(0xFFf7971e),
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        content: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFf7971e), Color(0xFFffd200)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(Icons.stars, color: Colors.white, size: 32),
                    SizedBox(height: 8),
                    Text(
                      'YOUR SCORE',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '$currentScore',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          Center(
            child: Container(
              margin: EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFf7971e), Color(0xFFffd200)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFf7971e).withOpacity(0.4),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    resetGame();
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh, color: Colors.white, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Play Again',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void resetGame() {
    gameBoard = List.generate(
      columnLength,
      (i) => List.generate(rowLength, (j) => null),
    );
    // new game
    currentScore = 0;
    gameOver = false;

    createNewPiece();
    // restart the loop
    startGame();
  }

  // move piece
  void moveLeft() {
    //make sure the piece of valid before moving
    if (!checkCollision(pieces.Direction.left)) {
      setState(() {
        currentPiece.movePiece(pieces.Direction.left);
      });
    }
  }

  void moveRight() {
    //make sure the piece of valid before moving
    if (!checkCollision(pieces.Direction.right)) {
      setState(() {
        currentPiece.movePiece(pieces.Direction.right);
      });
    }
  }

  void rotatePiece() {
    setState(() {
      currentPiece.rotatePiece();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFf7971e), Color(0xFFffd200)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Back Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    SizedBox(width: 16),
                    // Title
                    Expanded(
                      child: Text(
                        'Tetris',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    // Score Display
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.stars, color: Colors.white, size: 20),
                          SizedBox(height: 4),
                          Text(
                            'SCORE',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '$currentScore',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Game Board
              Expanded(
                child: Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: GridView.builder(
                        itemCount: rowLength * columnLength,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: rowLength,
                        ),
                        itemBuilder: (context, index) {
                          //get row and column for each piece
                          int row = (index / rowLength).floor();
                          int column = index % rowLength;

                          if (currentPiece.position.contains(index)) {
                            return Pixels(color: currentPiece.color);
                          } else if (gameBoard[row][column] != null) {
                            TetrominoShapes? tetrominoShape =
                                gameBoard[row][column];
                            return Pixels(
                              color: tetrominoColor[tetrominoShape],
                            );
                          }
                          //landed pieces
                          else {
                            return Pixels(color: Colors.grey[900]);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // GAME CONTROL
              Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Left Button
                    _buildControlButton(
                      icon: Icons.arrow_back_ios_new,
                      onPressed: moveLeft,
                    ),
                    SizedBox(width: 20),
                    // Rotate Button
                    _buildControlButton(
                      icon: Icons.rotate_right,
                      onPressed: rotatePiece,
                      isPrimary: true,
                    ),
                    SizedBox(width: 20),
                    // Right Button
                    _buildControlButton(
                      icon: Icons.arrow_forward_ios,
                      onPressed: moveRight,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // cancel the running timer to avoid callbacks after dispose
    _gameTimer?.cancel();
    _gameTimer = null;
    super.dispose();
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isPrimary
            ? Colors.white.withOpacity(0.3)
            : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
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
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(isPrimary ? 20 : 16),
            child: Icon(icon, color: Colors.white, size: isPrimary ? 32 : 28),
          ),
        ),
      ),
    );
  }
}
