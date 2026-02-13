import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:logic_mathematics/features/mini_game/logic_tetris/logic_of_game.dart';
import 'package:logic_mathematics/features/mini_game/logic_tetris/pieces.dart';
import 'package:logic_mathematics/features/mini_game/logic_tetris/shapes.dart'
    hide Direction;
import 'package:logic_mathematics/l10n/arb/app_localizations.dart';

class TetrisGameScreen extends StatefulWidget {
  const TetrisGameScreen({super.key});

  @override
  State<TetrisGameScreen> createState() => _TetrisGameScreenState();
}

class _TetrisGameScreenState extends State<TetrisGameScreen> {
  Timer? gameLoop;
  int currentLevel = 1;
  Piece? nextPiece;
  bool isPaused = false;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    gameBoard = List.generate(
      columnLength,
      (i) => List.generate(rowLength, (j) => null),
    );
    currentScore = 0;
    gameOver = false;
    currentLevel = 1;
    isPaused = false;

    currentPiece = Piece(type: TetrominoShapes.L);
    currentPiece.intializePiece();

    _generateNextPiece();

    gameLoop?.cancel();
    gameLoop = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!isPaused && !gameOver) {
        setState(() {
          clearLine();
          checkLadning();

          if (gameOver) {
            timer.cancel();
            _showGameOverDialog();
          } else {
            if (!checkCollision(Direction.down)) {
              currentPiece.movePiece(Direction.down);
            }
          }

          currentLevel = (currentScore ~/ 10) + 1;
        });
      }
    });
  }

  void _generateNextPiece() {
    Random random = Random();
    nextPiece = Piece(
      type:
          TetrominoShapes.values[random.nextInt(TetrominoShapes.values.length)],
    );
    nextPiece!.intializePiece();
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppLocalizations.of(context)!.gameOver,
          textAlign: TextAlign.center,
        ),
        content: Text(
          AppLocalizations.of(context)!.scoreMessage(currentScore.toString()),
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  startGame();
                });
              },
              child: Text(
                AppLocalizations.of(context)!.playAgain,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _moveLeft() {
    if (!checkCollision(Direction.left) && !checkLanded()) {
      setState(() {
        currentPiece.movePiece(Direction.left);
      });
    }
  }

  void _moveRight() {
    if (!checkCollision(Direction.right) && !checkLanded()) {
      setState(() {
        currentPiece.movePiece(Direction.right);
      });
    }
  }

  void _moveDown() {
    if (!checkCollision(Direction.down) && !checkLanded()) {
      setState(() {
        currentPiece.movePiece(Direction.down);
      });
    }
  }

  void _rotatePiece() {
    setState(() {
      currentPiece.rotatePiece();
    });
  }

  void _dropPiece() {
    setState(() {
      while (!checkCollision(Direction.down) && !checkLanded()) {
        currentPiece.movePiece(Direction.down);
      }
    });
  }

  void _togglePause() {
    setState(() {
      isPaused = !isPaused;
    });
  }

  @override
  void dispose() {
    gameLoop?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 5),
            // Stats bar
            _buildStatsBar(),
            //const SizedBox(height: 16),
            // Game board
            Expanded(child: _buildGameBoard()),
            //const SizedBox(height: 16),
            // Controls
            _buildControls(),
            // const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Pause button
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: IconButton(
              onPressed: _togglePause,
              icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
              color: Colors.black,
            ),
          ),
          // Title
          Text(
            AppLocalizations.of(context)!.gameTetrisSubtitle,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          // Exit button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.exit,
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF4CAF50),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        spacing: 10,
        children: [
          // Score
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Text(
                    '$currentScore',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.practice_score,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Level
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Text(
                    '$currentLevel',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.level,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Next piece
          // Expanded(
          //   child: Container(
          //     padding: const EdgeInsets.symmetric(vertical: 12),
          //     decoration: BoxDecoration(
          //       color: Colors.white,
          //       borderRadius: BorderRadius.circular(30),
          //       border: Border.all(color: Colors.grey.shade300),
          //     ),
          //     child: Column(
          //       children: [
          //         const Text(
          //           'TIẾP THEO',
          //           style: TextStyle(
          //             fontSize: 10,
          //             color: Colors.grey,
          //             fontWeight: FontWeight.w500,
          //           ),
          //         ),
          //         const SizedBox(height: 4),
          //         SizedBox(height: 40, child: _buildNextPiecePreview()),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  // Widget _buildNextPiecePreview() {
  //   if (nextPiece == null) return const SizedBox();

  //   return CustomPaint(
  //     painter: NextPiecePainter(nextPiece!),
  //     size: const Size(50, 40),
  //   );
  // }

  Widget _buildGameBoard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate optimal cell size based on available space
          double availableWidth = constraints.maxWidth;
          double availableHeight = constraints.maxHeight;

          // Calculate cell size to fit the grid
          double cellWidth = availableWidth / rowLength;
          double cellHeight = availableHeight / columnLength;
          double cellSize = cellWidth < cellHeight ? cellWidth : cellHeight;

          double boardWidth = cellSize * rowLength;
          double boardHeight = cellSize * columnLength;

          return Center(
            child: Container(
              width: boardWidth,
              height: boardHeight,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAF8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFB8D4B8), width: 3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: rowLength * columnLength,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: rowLength,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    int row = index ~/ rowLength;
                    int col = index % rowLength;

                    // Check if current piece occupies this cell
                    if (currentPiece.position.contains(index)) {
                      return _buildCell(currentPiece.type);
                    }

                    // Check if game board has a piece here
                    if (gameBoard[row][col] != null) {
                      return _buildCell(gameBoard[row][col]!);
                    }

                    // Empty cell with grid lines
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 0.5,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCell(TetrominoShapes type) {
    Color color;
    switch (type) {
      case TetrominoShapes.L:
        color = const Color(0xFFFF9800); // Orange
        break;
      case TetrominoShapes.J:
        color = const Color(0xFF2196F3); // Blue
        break;
      case TetrominoShapes.I:
        color = const Color(0xFF00BCD4); // Cyan
        break;
      case TetrominoShapes.O:
        color = const Color(0xFFFFEB3B); // Yellow
        break;
      case TetrominoShapes.S:
        color = const Color(0xFF4CAF50); // Green
        break;
      case TetrominoShapes.Z:
        color = const Color(0xFFF44336); // Red
        break;
      case TetrominoShapes.T:
        color = const Color(0xFF9C27B0); // Purple
        break;
    }

    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side controls (arrows)
          Column(
            children: [
              Row(
                children: [
                  _buildArrowButton(Icons.arrow_back, _moveLeft),
                  const SizedBox(width: 5),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  const SizedBox(width: 5),
                  _buildArrowButton(Icons.arrow_forward, _moveRight),
                ],
              ),
              _buildArrowButton(Icons.keyboard_arrow_down, _moveDown),
            ],
          ),
          // Right side controls (rotate & drop)
          Column(
            spacing: 5,
            children: [
              GestureDetector(
                onTap: _rotatePiece,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF4CAF50),
                  ),
                  child: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
              // const SizedBox(height: 12),
              GestureDetector(
                onTap: _dropPiece,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFE53935),
                  ),
                  child: const Icon(
                    Icons.keyboard_double_arrow_down,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArrowButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.black, size: 28),
      ),
    );
  }

  // Color _getColorForType(TetrominoShapes type) {
  //   switch (type) {
  //     case TetrominoShapes.L:
  //       return const Color(0xFFFF9800);
  //     case TetrominoShapes.J:
  //       return const Color(0xFF2196F3);
  //     case TetrominoShapes.I:
  //       return const Color(0xFF00BCD4);
  //     case TetrominoShapes.O:
  //       return const Color(0xFFFFEB3B);
  //     case TetrominoShapes.S:
  //       return const Color(0xFF4CAF50);
  //     case TetrominoShapes.Z:
  //       return const Color(0xFFF44336);
  //     case TetrominoShapes.T:
  //       return const Color(0xFF9C27B0);
  //   }
  // }
}

class NextPiecePainter extends CustomPainter {
  final Piece piece;

  NextPiecePainter(this.piece);

  @override
  void paint(Canvas canvas, Size size) {
    Color color;
    switch (piece.type) {
      case TetrominoShapes.L:
        color = const Color(0xFFFF9800);
        break;
      case TetrominoShapes.J:
        color = const Color(0xFF2196F3);
        break;
      case TetrominoShapes.I:
        color = const Color(0xFF00BCD4);
        break;
      case TetrominoShapes.O:
        color = const Color(0xFFFFEB3B);
        break;
      case TetrominoShapes.S:
        color = const Color(0xFF4CAF50);
        break;
      case TetrominoShapes.Z:
        color = const Color(0xFFF44336);
        break;
      case TetrominoShapes.T:
        color = const Color(0xFF9C27B0);
        break;
    }

    final paint = Paint()..color = color;
    const cellSize = 10.0;

    // Calculate bounding box of the piece
    List<int> rows = [];
    List<int> cols = [];
    for (int pos in piece.position) {
      rows.add(pos ~/ rowLength);
      cols.add(pos % rowLength);
    }

    int minRow = rows.reduce((a, b) => a < b ? a : b);
    int minCol = cols.reduce((a, b) => a < b ? a : b);

    for (int pos in piece.position) {
      int row = pos ~/ rowLength - minRow;
      int col = pos % rowLength - minCol;

      double x = col * cellSize + size.width / 2 - cellSize * 2;
      double y = row * cellSize + size.height / 2 - cellSize;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, cellSize - 2, cellSize - 2),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
