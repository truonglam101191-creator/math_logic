import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logic_mathematics/cores/audio/audio_manager.dart';
import 'package:logic_mathematics/main.dart';

class AnimatedGameButton extends StatefulWidget {
  const AnimatedGameButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.pressedScale = 0.9,
    this.backgroundColor = Colors.blue,
    this.shadowColor,
    this.borderColor,
    this.depth = 6.0,
    this.borderRadius = 16.0,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final double pressedScale;
  final Color backgroundColor;
  final Color? shadowColor;
  final Color? borderColor;
  final double depth;
  final double borderRadius;

  @override
  State<AnimatedGameButton> createState() => _AnimatedGameButtonState();
}

class _AnimatedGameButtonState extends State<AnimatedGameButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pressedScale,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed == null) return;
    _handleRelease();
  }

  void _handleTapCancel() {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleRelease() {
    setState(() => _isPressed = false);
    _controller.reverse();

    // Play Haptic & Audio
    HapticFeedback.lightImpact();
    serviceLocator.get<AudioManager>().playClick();

    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveShadowColor =
        widget.shadowColor ?? _darken(widget.backgroundColor, 0.2);
    final effectiveBorderColor =
        widget.borderColor ?? _darken(widget.backgroundColor, 0.1);

    final currentDepth = _isPressed ? 0.0 : widget.depth;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          margin: EdgeInsets.only(top: currentDepth),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(color: effectiveBorderColor, width: 1.5),
            boxShadow: [
              if (!_isPressed)
                BoxShadow(
                  color: effectiveShadowColor,
                  offset: Offset(0, widget.depth),
                  blurRadius: 0,
                ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Center(
              widthFactor: 1.0,
              heightFactor: 1.0,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }

  Color _darken(Color c, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(c);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
