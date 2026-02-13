import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bonfire/bonfire.dart' hide Matrix4;

class VirtualControls extends StatefulWidget {
  final BonfireGameInterface gameRef;
  final VoidCallback? onExit;

  const VirtualControls({
    Key? key,
    required this.gameRef,
    this.onExit,
  }) : super(key: key);

  @override
  State<VirtualControls> createState() => _VirtualControlsState();
}

class _VirtualControlsState extends State<VirtualControls> {
  Set<JoystickMoveDirectional> pressedButtons = {};

  @override
  Widget build(BuildContext context) {
    // Chỉ hiển thị trên mobile (Android/iOS)
    if (kIsWeb ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal:
              MediaQuery.of(context).orientation == Orientation.landscape
                  ? 40
                  : 30,
          vertical: MediaQuery.of(context).orientation == Orientation.landscape
              ? 20
              : 30,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Nút thoát bên trái
            _buildExitButton(),
            // D-pad bên phải
            _buildDPad(),
          ],
        ),
      ),
    );
  }

  Widget _buildDPad() {
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    double dPadSize = isLandscape ? 160 : 200;
    double buttonDistance = isLandscape ? 50 : 70;

    return SizedBox(
      width: dPadSize,
      height: dPadSize,
      child: Stack(
        children: [
          // Background circle để tạo cảm giác D-pad
          // Positioned.fill(
          //   child: Container(
          //     decoration: BoxDecoration(
          //       color: Colors.black.withOpacity(0.1),
          //       borderRadius: BorderRadius.circular(dPadSize / 2),
          //       border: Border.all(
          //         color: Colors.yellow.withOpacity(0.3),
          //         width: 2,
          //       ),
          //     ),
          //   ),
          // ),
          // Nút lên
          Positioned(
            left: buttonDistance,
            child: _buildControlButton(
              icon: Icons.keyboard_arrow_up,
              direction: JoystickMoveDirectional.MOVE_UP,
              onPressed: () =>
                  _sendDirectionalEvent(JoystickMoveDirectional.MOVE_UP),
            ),
          ),
          // Nút trái
          Positioned(
            top: buttonDistance,
            child: _buildControlButton(
              icon: Icons.keyboard_arrow_left,
              direction: JoystickMoveDirectional.MOVE_LEFT,
              onPressed: () =>
                  _sendDirectionalEvent(JoystickMoveDirectional.MOVE_LEFT),
            ),
          ),
          // Nút phải
          Positioned(
            top: buttonDistance,
            right: 0,
            child: _buildControlButton(
              icon: Icons.keyboard_arrow_right,
              direction: JoystickMoveDirectional.MOVE_RIGHT,
              onPressed: () =>
                  _sendDirectionalEvent(JoystickMoveDirectional.MOVE_RIGHT),
            ),
          ),
          // Nút xuống
          Positioned(
            bottom: 0,
            left: buttonDistance,
            child: _buildControlButton(
              icon: Icons.keyboard_arrow_down,
              direction: JoystickMoveDirectional.MOVE_DOWN,
              onPressed: () =>
                  _sendDirectionalEvent(JoystickMoveDirectional.MOVE_DOWN),
            ),
          ),
          // Center dot để tạo cảm giác D-pad thực tế
          Positioned(
            top: (dPadSize - 30) / 2,
            left: (dPadSize - 30) / 2,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.yellow.withOpacity(0.3),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required JoystickMoveDirectional direction,
  }) {
    bool isPressed = pressedButtons.contains(direction);

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          pressedButtons.add(direction);
        });
        onPressed();
      },
      onTapUp: (_) {
        setState(() {
          pressedButtons.remove(direction);
        });
        _sendDirectionalEvent(JoystickMoveDirectional.IDLE);
      },
      onTapCancel: () {
        setState(() {
          pressedButtons.remove(direction);
        });
        _sendDirectionalEvent(JoystickMoveDirectional.IDLE);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 60,
        height: 60,
        transform:
            isPressed ? (Matrix4.identity()..scale(0.95)) : Matrix4.identity(),
        decoration: BoxDecoration(
          color: isPressed
              ? Colors.yellow.withOpacity(0.8)
              : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
              color:
                  isPressed ? Colors.orange.shade700 : Colors.yellow.shade600,
              width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isPressed ? 0.6 : 0.4),
              blurRadius: isPressed ? 4 : 8,
              offset: Offset(0, isPressed ? 2 : 4),
            ),
            BoxShadow(
              color: Colors.yellow.withOpacity(isPressed ? 0.5 : 0.3),
              blurRadius: isPressed ? 6 : 12,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 32,
          color: isPressed ? Colors.black : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildExitButton() {
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Column(
      mainAxisAlignment:
          isLandscape ? MainAxisAlignment.center : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isLandscape) const SizedBox(height: 20),
        GestureDetector(
          onTap: widget.onExit,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.9),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.red.shade700, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: const Icon(
              Icons.close,
              size: 30,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  void _sendDirectionalEvent(JoystickMoveDirectional direction) {
    final player = widget.gameRef.player;
    if (player != null) {
      player.onJoystickChangeDirectional(
        JoystickDirectionalEvent(
          directional: direction,
          intensity: 1.0,
          radAngle: 0,
        ),
      );
    }
  }
}
