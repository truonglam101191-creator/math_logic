import 'package:flutter/material.dart';

class GameDialog extends StatelessWidget {
  const GameDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.showCloseButton = true,
  });

  final String title;
  final Widget content;
  final List<Widget>? actions;
  final bool showCloseButton;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Main Body
          Container(
            padding: const EdgeInsets.only(
              top: 50, // space for banner
              bottom: 24,
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E7),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF8B4513), // Wood-like border
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                content,
                if (actions != null && actions!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: actions!,
                  ),
                ],
              ],
            ),
          ),

          // Top Ribbon/Banner
          Positioned(
            top: -20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE53935), // Red ribbon
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFB71C1C), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      offset: Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Close Button
          if (showCloseButton)
            Positioned(
              top: -15,
              right: -15,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Future<T?> showGameDialog<T>({
  required BuildContext context,
  required String title,
  required Widget content,
  List<Widget>? actions,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return GameDialog(
        title: title,
        content: content,
        actions: actions,
      );
    },
  );
}
