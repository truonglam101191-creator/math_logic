import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/pikachu_board.dart';
import 'tile_widget.dart';

class PikachuBoardView extends StatelessWidget {
  final PikachuBoardController controller;
  final double tileSize;
  final Color pathConnectionColor;

  final ScrollController scrollControllerVertical;

  const PikachuBoardView({
    super.key,
    required this.controller,
    this.tileSize = 44,
    this.pathConnectionColor = Colors.black,
    required this.scrollControllerVertical,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: Consumer<PikachuBoardController>(
        builder: (context, ctr, _) {
          final s = ctr.state;
          final rows = s.grid.length;
          final cols = s.grid.first.length;

          // Use a lazy GridView to only build visible tiles. The page
          // must provide a bounded height for this widget so GridView can
          // be the primary (vertical) scrollable and remain lazy.
          final innerRows = rows; // includes border rows
          final innerCols = cols;

          return LayoutBuilder(
            builder: (context, constraints) {
              // Compute full grid pixel size
              final gridPixelWidth = innerCols * tileSize;
              final gridPixelHeight = innerRows * tileSize;

              return Stack(
                children: [
                  // Center the grid horizontally; allow vertical scrolling
                  Center(
                    child: SizedBox(
                      width: gridPixelWidth,
                      height: constraints.maxHeight.isFinite
                          ? constraints.maxHeight
                          : gridPixelHeight,
                      child: GridView.builder(
                        controller: scrollControllerVertical,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: innerCols,
                          childAspectRatio: 1.0,
                          mainAxisSpacing: 0,
                          crossAxisSpacing: 0,
                        ),
                        itemCount: innerRows * innerCols,
                        cacheExtent: 3 * tileSize,
                        itemBuilder: (context, index) {
                          final r = index ~/ innerCols;
                          final c = index % innerCols;
                          final t = s.grid[r][c];
                          final selected =
                              s.selectedA?.id == t.id ||
                              s.selectedB?.id == t.id;
                          return RepaintBoundary(
                            child: SizedBox(
                              width: tileSize,
                              height: tileSize,
                              child: PikachuTileWidget(
                                tile: t,
                                selected: selected,
                                style: ctr.style,
                                onTap: () => ctr.tap(r, c),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Overlay for the animated connection path.
                  // Clip to the viewport and translate by the GridView's vertical scroll
                  // so the overlay stays aligned with the scrolled content.
                  Center(
                    child: SizedBox(
                      width: gridPixelWidth,
                      height: constraints.maxHeight.isFinite
                          ? constraints.maxHeight
                          : gridPixelHeight,
                      child: ClipRect(
                        child: AnimatedBuilder(
                          animation: scrollControllerVertical,
                          builder: (context, _) {
                            final offsetY = scrollControllerVertical.hasClients
                                ? scrollControllerVertical.offset
                                : 0.0;
                            return Transform.translate(
                              offset: Offset(0, -offsetY),
                              child: SizedBox(
                                width: gridPixelWidth,
                                height: gridPixelHeight,
                                child: AnimatedPathOverlay(
                                  points: s.pathPoints,
                                  tileSize: tileSize,
                                  pathConnectionColor: pathConnectionColor,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class AnimatedPathOverlay extends StatefulWidget {
  final List<Offset> points; // in grid coordinates
  final double tileSize;

  final Color pathConnectionColor;

  const AnimatedPathOverlay({
    super.key,
    required this.points,
    required this.tileSize,
    required this.pathConnectionColor,
  });

  @override
  State<AnimatedPathOverlay> createState() => _AnimatedPathOverlayState();
}

class _AnimatedPathOverlayState extends State<AnimatedPathOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _stroke;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      reverseDuration: const Duration(milliseconds: 250),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _stroke = Tween<double>(
      begin: 2,
      end: 6,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad));
  }

  @override
  void didUpdateWidget(covariant AnimatedPathOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    final hasPath = widget.points.isNotEmpty;
    final hadPath = oldWidget.points.isNotEmpty;
    if (hasPath && !hadPath) {
      _controller.forward(from: 0);
    } else if (!hasPath && hadPath) {
      _controller.reverse(from: _controller.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.points.isEmpty) return const SizedBox.shrink();
    return IgnorePointer(
      ignoring: true,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _PathPainter(
              widget.points,
              widget.tileSize,
              opacity: _fade.value,
              strokeWidth: _stroke.value,
              pathConnectionColor: widget.pathConnectionColor,
            ),
          );
        },
      ),
    );
  }
}

class _PathPainter extends CustomPainter {
  final List<Offset> points; // in grid coordinates
  final double tileSize;
  final double opacity;
  final double strokeWidth;
  final Color pathConnectionColor;

  _PathPainter(
    this.points,
    this.tileSize, {
    this.opacity = 1.0,
    this.strokeWidth = 4,
    required this.pathConnectionColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    // Draw a solid black line (as requested)
    final mainPaint = Paint()
      ..color = pathConnectionColor.withOpacity(opacity)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    Offset toPixel(Offset grid) => Offset(
      grid.dx * tileSize + tileSize / 2,
      grid.dy * tileSize + tileSize / 2,
    );
    path.moveTo(toPixel(points.first).dx, toPixel(points.first).dy);
    for (var i = 1; i < points.length; i++) {
      final p = toPixel(points[i]);
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, mainPaint);
  }

  @override
  bool shouldRepaint(covariant _PathPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.tileSize != tileSize ||
        oldDelegate.opacity != opacity ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.pathConnectionColor != pathConnectionColor;
  }
}

// class _TopHeader extends StatelessWidget {
//   final int cols;
//   final double tileSize;
//   const _TopHeader({required this.cols, required this.tileSize});

//   @override
//   Widget build(BuildContext context) {
//     final innerCols = cols - 2;
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         SizedBox(width: tileSize, height: tileSize), // spacer
//         ...List.generate(innerCols, (i) {
//           return SizedBox(
//             width: tileSize,
//             height: tileSize,
//             child: Center(
//               child: Text(
//                 '${i + 1}',
//                 style: const TextStyle(color: Colors.black54),
//               ),
//             ),
//           );
//         }),
//         SizedBox(width: tileSize, height: tileSize),
//       ],
//     );
//   }
// }

// class _LeftIndex extends StatelessWidget {
//   final int row;
//   final int rows;
//   final double tileSize;
//   const _LeftIndex({
//     required this.row,
//     required this.rows,
//     required this.tileSize,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isBorder = row == 0 || row == rows - 1;
//     return SizedBox(
//       width: tileSize,
//       height: tileSize,
//       child: Center(
//         child: isBorder
//             ? const SizedBox()
//             : Text('$row', style: const TextStyle(color: Colors.black54)),
//       ),
//     );
//   }
// }
