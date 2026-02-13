import 'dart:math';

import 'package:flutter/material.dart';
import 'package:logic_mathematics/features/mini_game/arrows_escape/logic/game_controller.dart';
import 'package:logic_mathematics/features/mini_game/arrows_escape/models/arrow_model.dart';
import 'package:logic_mathematics/features/mini_game/arrows_escape/widgets/arrow_widget.dart';

import 'widgets/arrow_painter.dart'; // Unused here but available

class ArrowsEscapePage extends StatefulWidget {
  const ArrowsEscapePage({super.key});

  @override
  State<ArrowsEscapePage> createState() => _ArrowsEscapePageState();
}

class _ArrowsEscapePageState extends State<ArrowsEscapePage>
    with TickerProviderStateMixin {
  late final GameController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GameController(vsync: this)..addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dark Blue Background: 0xFF050A30
    final background = const Color(0xFF050A30);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            const SizedBox(height: 8),
            _buildLevelHeader(),
            const SizedBox(height: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double boardSize = _calculateBoardSize(constraints);
                  final int gridSize = _controller.gridSize;
                  final double cellSize = boardSize / gridSize;

                  return Center(
                    child: SizedBox(
                      width: boardSize,
                      height: boardSize,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _GridPainter(
                                gridSize: gridSize,
                                color: Colors.white.withOpacity(0.05),
                              ),
                            ),
                          ),
                          // Global Touch Handler for Snake Bodies
                          Positioned.fill(
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTapUp: (details) {
                                final dx = details.localPosition.dx;
                                final dy = details.localPosition.dy;
                                // Calculate grid (row, col)
                                int col = (dx / cellSize).floor();
                                int row = (dy / cellSize).floor();
                                // Clamp to be safe
                                if (col >= 0 &&
                                    col < gridSize &&
                                    row >= 0 &&
                                    row < gridSize) {
                                  _controller.handleGridTap(row, col);
                                }
                              },
                              child: Container(
                                color: Colors.transparent,
                              ), // Touch surface
                            ),
                          ),
                          ..._controller.arrows.map(
                            (arrow) => ArrowWidget(
                              arrow: arrow,
                              cellSize: cellSize,
                              onTap: () {
                                // Also handle direct taps on the head widget
                                _controller.handleGridTap(arrow.row, arrow.col);
                              },
                            ),
                          ),
                          if (_controller.isLevelComplete)
                            _buildLevelCompleteOverlay(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            _buildBottomBar(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCompleteOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.6),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.pinkAccent.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.pinkAccent.withOpacity(0.3),
                  blurRadius: 25,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'PUZZLE SOLVED',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2,
                    shadows: [Shadow(color: Colors.pinkAccent, blurRadius: 15)],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'All arrows have escaped!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    foregroundColor: Colors.white,
                    elevation: 10,
                    shadowColor: Colors.pinkAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    _controller.generateLevel(
                      5,
                      12 + Random().nextInt(6),
                    ); // Slightly harder
                  },
                  child: const Text(
                    'NEXT LEVEL',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: Colors.white70,
          ),
          const SizedBox(width: 8),
          const Text(
            'NEON ARROWS',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.pinkAccent,
              letterSpacing: 1.5,
              shadows: [Shadow(color: Colors.pinkAccent, blurRadius: 15)],
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'New Puzzle',
            onPressed: _controller.isAnimating
                ? null
                : () {
                    _controller.restartLevel();
                  },
            icon: const Icon(Icons.refresh_rounded),
            color: Colors.white70,
          ),
        ],
      ),
    );
  }

  Widget _buildLevelHeader() {
    int cleared = _controller.arrows
        .where((a) => a.state == ArrowState.cleared)
        .length;
    int total = _controller.arrows.length;

    return Column(
      children: [
        const SizedBox(height: 4),
        Text(
          '$cleared / $total escaped',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 13,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Tap an arrow to send it flying',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white30,
              fontWeight: FontWeight.w400,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateBoardSize(BoxConstraints constraints) {
    final double maxWidth = constraints.maxWidth - 24;
    final double maxHeight = constraints.maxHeight - 32;
    return min(maxWidth, maxHeight).clamp(220, 520);
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.gridSize, required this.color});

  final int gridSize;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double cellSize = size.width / gridSize;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    for (int i = 0; i <= gridSize; i++) {
      double offset = i * cellSize;
      canvas.drawLine(Offset(0, offset), Offset(size.width, offset), paint);
      canvas.drawLine(Offset(offset, 0), Offset(offset, size.height), paint);
    }

    // Outer Neon Glow Border
    final glowPaint = Paint()
      ..color = Colors.blueAccent.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 10);

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), glowPaint);

    // Core white border
    final borderPaint = Paint()
      ..color = Colors.blueAccent.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.gridSize != gridSize || oldDelegate.color != color;
  }
}
