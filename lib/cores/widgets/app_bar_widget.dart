import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logic_mathematics/cores/themes/app_colors.dart';
import 'package:logic_mathematics/gen/assets.gen.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWidget({
    super.key,
    this.leading,
    this.automaticallyImplyLeading,
    this.title,
    this.actions,
    this.flexibleSpace,
    this.bottom,
    this.elevation,
    this.scrolledUnderElevation,
    this.notificationPredicate,
    this.shadowColor,
    this.surfaceTintColor,
    this.shape,
    this.backgroundColor,
    this.foregroundColor,
    this.iconTheme,
    this.actionsIconTheme,
    this.primary,
    this.centerTitle,
    this.excludeHeaderSemantics,
    this.titleSpacing,
    this.toolbarOpacity,
    this.bottomOpacity,
    this.toolbarHeight,
    this.leadingWidth,
    this.toolbarTextStyle,
    this.titleTextStyle,
    this.systemOverlayStyle,
    this.forceMaterialTransparency,
    this.useDefaultSemanticsOrder,
    this.clipBehavior,
    this.actionsPadding,
  });

  final Widget? leading;

  final bool? automaticallyImplyLeading;

  final Widget? title;

  final List<Widget>? actions;

  final Widget? flexibleSpace;

  final PreferredSizeWidget? bottom;

  final double? elevation;

  final double? scrolledUnderElevation;

  final ScrollNotificationPredicate? notificationPredicate;

  final Color? shadowColor;

  final Color? surfaceTintColor;

  final ShapeBorder? shape;

  final Color? backgroundColor;

  final Color? foregroundColor;

  final IconThemeData? iconTheme;

  final IconThemeData? actionsIconTheme;

  final bool? primary;

  final bool? centerTitle;

  final bool? excludeHeaderSemantics;

  final double? titleSpacing;

  final double? toolbarOpacity;

  final double? bottomOpacity;

  final double? toolbarHeight;

  final double? leadingWidth;

  final TextStyle? toolbarTextStyle;

  final TextStyle? titleTextStyle;

  final SystemUiOverlayStyle? systemOverlayStyle;

  final bool? forceMaterialTransparency;

  final bool? useDefaultSemanticsOrder;

  final Clip? clipBehavior;

  final EdgeInsetsGeometry? actionsPadding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AppColors.gradientStartusbar),
      ),
      child: AppBar(
        leading:
            leading ??
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: AssetsImages.icons.iconArrowRight.svg(),
            ),
        automaticallyImplyLeading: automaticallyImplyLeading ?? true,
        title: title,
        actions: actions,
        flexibleSpace: flexibleSpace,
        bottom: bottom,
        elevation: elevation ?? 0.0,
        scrolledUnderElevation: scrolledUnderElevation ?? 0.0,
        notificationPredicate:
            notificationPredicate ?? defaultScrollNotificationPredicate,
        shadowColor: shadowColor,
        surfaceTintColor: surfaceTintColor,
        shape: shape,
        backgroundColor: backgroundColor ?? Colors.transparent,
        foregroundColor: foregroundColor,
        iconTheme: iconTheme,
        actionsIconTheme: actionsIconTheme,
        primary: primary ?? true,
        centerTitle: centerTitle,
        excludeHeaderSemantics: excludeHeaderSemantics ?? false,
        titleSpacing: titleSpacing ?? NavigationToolbar.kMiddleSpacing,
        toolbarOpacity: toolbarOpacity ?? 1.0,
        bottomOpacity: bottomOpacity ?? 1.0,
        toolbarHeight: toolbarHeight,
        leadingWidth: leadingWidth,
        toolbarTextStyle: toolbarTextStyle,
        titleTextStyle: titleTextStyle,
        systemOverlayStyle: systemOverlayStyle,
        forceMaterialTransparency: forceMaterialTransparency ?? false,
        useDefaultSemanticsOrder: useDefaultSemanticsOrder ?? true,
        clipBehavior: clipBehavior,
        actionsPadding: actionsPadding,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
