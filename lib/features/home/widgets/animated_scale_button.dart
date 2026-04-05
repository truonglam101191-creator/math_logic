import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logic_mathematics/cores/audio/audio_manager.dart';
import 'package:logic_mathematics/main.dart';

/// A button that animates its scale to [pressedScale] when tapped, then
/// returns to its original scale. Use this when you want a quick press
/// feedback (scale-down then back up).
class AnimatedScaleButton extends StatefulWidget {
  const AnimatedScaleButton({
    super.key,
    required this.child,
    this.onPressed,
    this.pressedScale = 0.8,
    this.duration = const Duration(milliseconds: 120),
    this.curve = Curves.easeOut,
    this.alignment = Alignment.center,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final double pressedScale;
  final Duration duration;
  final Curve curve;
  final AlignmentGeometry alignment;

  @override
  State<AnimatedScaleButton> createState() => _AnimatedScaleButtonState();
}

class _AnimatedScaleButtonState extends State<AnimatedScaleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(
      begin: 1.0,
      end: widget.pressedScale,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void didUpdateWidget(covariant AnimatedScaleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pressedScale != widget.pressedScale) {
      _animation = Tween<double>(
        begin: 1.0,
        end: widget.pressedScale,
      ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _runTapAnimation() async {
    try {
      await _controller.forward();
      await _controller.reverse();
    } catch (_) {
      // ignored
    }
  }

  void _handleTap() async {
    HapticFeedback.lightImpact();
    serviceLocator.get<AudioManager>().playClick();
    await _runTapAnimation();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => Transform.scale(
          scale: _animation.value,
          alignment: widget.alignment,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
