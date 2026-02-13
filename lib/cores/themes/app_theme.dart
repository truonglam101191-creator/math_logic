import 'package:flutter/material.dart';
import 'package:logic_mathematics/cores/configs/configs.dart';
import 'package:logic_mathematics/cores/themes/app_colors.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primaryLight,
  scaffoldBackgroundColor: AppColors.backgroundLight,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.backgroundLight,
    centerTitle: true,
    iconTheme: IconThemeData(color: AppColors.primaryDark),
    shadowColor: AppColors.backgroundLight,
    foregroundColor: AppColors.backgroundLight,
    surfaceTintColor: AppColors.backgroundLight,
  ),
  dialogTheme: const DialogThemeData(backgroundColor: AppColors.surfaceLight),
  splashColor: AppColors.primaryDark.withValues(alpha: .1),
  highlightColor: Colors.transparent,
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: AppColors.primaryLight,
    selectionColor: AppColors.primaryLight,
    selectionHandleColor: AppColors.primaryLight,
  ),
  focusColor: AppColors.primaryLight,
  primaryColorDark: AppColors.primaryLight,
  radioTheme: RadioThemeData(
    fillColor: MaterialStateProperty.all(AppColors.primaryLight),
  ),
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: AppColors.backgroundLight,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(Configs.instance.commonRadius),
        topRight: Radius.circular(Configs.instance.commonRadius),
      ),
    ),
  ),
  cardColor: AppColors.surfaceLight,
  iconTheme: const IconThemeData(color: AppColors.iconLight),
  cardTheme: CardThemeData(
    color: AppColors.cardThemeColorLight,
    surfaceTintColor: AppColors.cardThemeColorLight.withValues(alpha: .1),
  ),
  dividerTheme: const DividerThemeData(color: AppColors.lineLight),
  unselectedWidgetColor: AppColors.unSelectedColorLight,
  dividerColor: AppColors.lineLight,
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      side: WidgetStateProperty.all(BorderSide(color: AppColors.primaryLight)),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(AppColors.primaryLight),
      shadowColor: WidgetStatePropertyAll(AppColors.primaryLight),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      overlayColor: WidgetStateProperty.all(
        AppColors.primaryLight.withValues(alpha: .1),
      ),
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppColors.surfaceLight,
  ),
  tabBarTheme: TabBarThemeData(
    labelColor: AppColors.textLight,
    unselectedLabelColor: AppColors.textDark,
    dividerHeight: 0,
    labelStyle: ThemeData.light().textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w500,
    ),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      color: AppColors.textDark,
      fontWeight: FontWeight.w500,
    ),
    displayMedium: TextStyle(
      color: AppColors.textDark,
      fontWeight: FontWeight.w500,
    ),
    displaySmall: TextStyle(
      color: AppColors.textDark,
      fontWeight: FontWeight.w500,
    ),
    headlineLarge: TextStyle(
      color: AppColors.textDark,
      fontWeight: FontWeight.w500,
    ),
    headlineMedium: TextStyle(
      color: AppColors.textDark,
      fontWeight: FontWeight.w500,
    ),
    headlineSmall: TextStyle(
      color: AppColors.textDark,
      fontWeight: FontWeight.w500,
    ),
    titleLarge: TextStyle(
      color: AppColors.textDark,
      fontWeight: FontWeight.w500,
    ),
    titleMedium: TextStyle(
      color: AppColors.textDark,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: TextStyle(
      color: AppColors.textDark,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: TextStyle(
      color: AppColors.textDark,
      fontWeight: FontWeight.w500,
    ),
    bodyMedium: TextStyle(
      color: AppColors.textDark,
      fontWeight: FontWeight.w500,
    ),
    bodySmall: TextStyle(
      color: AppColors.textDark,
      fontWeight: FontWeight.w500,
    ),
    labelLarge: TextStyle(
      color: AppColors.textDark,
      fontWeight: FontWeight.w500,
    ),
    labelMedium: TextStyle(
      color: AppColors.textDark,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: TextStyle(
      color: AppColors.textDark,
      fontWeight: FontWeight.w500,
    ),
  ),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.primaryDark,
  scaffoldBackgroundColor: AppColors.backgroundDark,
  dialogTheme: const DialogThemeData(backgroundColor: AppColors.surfaceDark),
  primaryColorDark: AppColors.primaryDark,
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: AppColors.primaryDark,
    selectionColor: AppColors.primaryDark,
    selectionHandleColor: AppColors.primaryDark,
  ),
  cardColor: AppColors.surfaceDark,
  iconTheme: IconThemeData(color: AppColors.primaryDark),
  dividerTheme: DividerThemeData(color: AppColors.lineDark),
  cardTheme: const CardThemeData(
    color: AppColors.surfaceDark,
    surfaceTintColor: AppColors.surfaceDark,
  ),
  unselectedWidgetColor: AppColors.unSelectedColorDark,
  dividerColor: AppColors.lineDark,
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.backgroundDark,
    centerTitle: true,
    iconTheme: IconThemeData(color: AppColors.primaryDark),
    shadowColor: AppColors.backgroundDark,
    foregroundColor: AppColors.backgroundDark,
    surfaceTintColor: AppColors.backgroundDark,
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      side: WidgetStateProperty.all(BorderSide(color: AppColors.primaryLight)),
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppColors.surfaceDark,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(AppColors.primaryLight),
      shadowColor: WidgetStatePropertyAll(AppColors.primaryLight),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      overlayColor: WidgetStateProperty.all(
        AppColors.primaryLight.withValues(alpha: .1),
      ),
    ),
  ),
  tabBarTheme: TabBarThemeData(
    labelColor: AppColors.textLight,
    unselectedLabelColor: Colors.white,
    dividerHeight: 0,
    // labelStyle: ThemeData.dark()
    //     .textTheme
    //     .titleSmall
    //     ?.copyWith(fontWeight: FontWeight.w500),
  ),
  splashColor: AppColors.primaryDark.withValues(alpha: .2),
  highlightColor: Colors.transparent,
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: AppColors.backgroundDark,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(Configs.instance.commonRadius),
        topRight: Radius.circular(Configs.instance.commonRadius),
      ),
    ),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      color: AppColors.textLight,
      fontWeight: FontWeight.w500,
    ),
    displayMedium: TextStyle(
      color: AppColors.textLight,
      fontWeight: FontWeight.w500,
    ),
    displaySmall: TextStyle(
      color: AppColors.textLight,
      fontWeight: FontWeight.w500,
    ),
    headlineLarge: TextStyle(
      color: AppColors.textLight,
      fontWeight: FontWeight.w500,
    ),
    headlineMedium: TextStyle(
      color: AppColors.textLight,
      fontWeight: FontWeight.w500,
    ),
    headlineSmall: TextStyle(
      color: AppColors.textLight,
      fontWeight: FontWeight.w500,
    ),
    titleLarge: TextStyle(
      color: AppColors.textLight,
      fontWeight: FontWeight.w500,
    ),
    titleMedium: TextStyle(
      color: AppColors.textLight,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: TextStyle(
      color: AppColors.textLight,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: TextStyle(
      color: AppColors.textLight,
      fontWeight: FontWeight.w500,
    ),
    bodyMedium: TextStyle(
      color: AppColors.textLight,
      fontWeight: FontWeight.w500,
    ),
    bodySmall: TextStyle(
      color: AppColors.textLight,
      fontWeight: FontWeight.w500,
    ),
    labelLarge: TextStyle(
      color: AppColors.textLight,
      fontWeight: FontWeight.w500,
    ),
    labelMedium: TextStyle(
      color: AppColors.textLight,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: TextStyle(
      color: AppColors.textLight,
      fontWeight: FontWeight.w500,
    ),
  ),
);
