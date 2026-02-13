import 'package:flutter/material.dart';

class ExpensionWidget extends StatefulWidget {
  const ExpensionWidget({
    super.key,
    required this.title,
    this.child,
    this.isExpanded = false,
    this.onExpansionChanged,
    this.onChanged,
  });

  final Widget title;
  final Widget? child;
  final bool isExpanded;

  final Function(bool isExpanded)? onExpansionChanged;

  final ValueChanged<bool>? onChanged;

  @override
  State<ExpensionWidget> createState() => _ExpensionWidgetState();
}

class _ExpensionWidgetState extends State<ExpensionWidget>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;

  late final AnimationController _controller;
  late final Animation<double> _sizeFactor;

  @override
  void initState() {
    super.initState();
    isExpanded = widget.isExpanded;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _sizeFactor = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    if (isExpanded) {
      _controller.value = 1.0;
    } else {
      _controller.value = 0.0;
    }
  }

  @override
  void didUpdateWidget(covariant ExpensionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isExpanded != widget.isExpanded) {
      setState(() {
        isExpanded = widget.isExpanded;
      });
      if (isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          splashFactory: NoSplash.splashFactory,
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
            if (isExpanded) {
              _controller.forward();
            } else {
              _controller.reverse();
            }
            if (widget.onExpansionChanged != null) {
              widget.onExpansionChanged!(isExpanded);
            }
            if (widget.onChanged != null) {
              widget.onChanged!(isExpanded);
            }
          },
          child: widget.title,
        ),
        ClipRect(
          child: SizeTransition(
            sizeFactor: _sizeFactor, // 0 → collapsed, 1 → expanded
            axisAlignment: -1.0, // expand from top
            child: widget.child ?? const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
