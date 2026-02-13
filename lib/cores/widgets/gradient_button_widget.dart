import 'package:flutter/material.dart';
import 'package:logic_mathematics/cores/configs/configs.dart';
import 'package:logic_mathematics/cores/themes/app_colors.dart';

class GradientButtonWidget extends StatelessWidget {
  const GradientButtonWidget({
    super.key,
    this.onPressed,
    this.child,
    this.padding,
    this.decoration,
    this.width,
    this.height,
    this.isBoolUnselected = false,
  });

  final void Function()? onPressed;
  final Widget? child;
  final EdgeInsetsGeometry? padding;

  final Decoration? decoration;

  final double? width;
  final double? height;
  final bool isBoolUnselected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      splashFactory: NoSplash.splashFactory,
      child: Container(
        alignment: Alignment.center,
        padding: padding ?? EdgeInsets.symmetric(vertical: 10),
        width: width,
        height: height,
        decoration:
            decoration ??
            BoxDecoration(
              color: Theme.of(
                context,
              ).primaryColor.withValues(alpha: isBoolUnselected ? 0.5 : 1),
              borderRadius: BorderRadius.circular(
                Configs.instance.commonRadiusMax,
              ),
            ),
        child: child,
      ),
    );
  }
}
