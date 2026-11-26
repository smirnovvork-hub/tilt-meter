import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static const panelRadius = BorderRadius.all(Radius.circular(12));

  static BoxDecoration panel({Color color = AppColors.card}) => BoxDecoration(
    color: color,
    border: Border.all(color: AppColors.border),
    borderRadius: panelRadius,
  );

  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: AppColors.orange,
      onPrimary: AppColors.onOrange,
      surface: AppColors.card,
      onSurface: AppColors.text,
      onSurfaceVariant: AppColors.muted,
      outline: AppColors.border,
      error: AppColors.loss,
    );
    final base = ThemeData(colorScheme: scheme, scaffoldBackgroundColor: AppColors.background, useMaterial3: true);

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineMedium: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -1),
        titleLarge: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, letterSpacing: -.4),
        titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        bodySmall: const TextStyle(fontSize: 12, color: AppColors.muted, height: 1.4),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        toolbarHeight: 68,
        titleTextStyle: TextStyle(color: AppColors.text, fontSize: 21, fontWeight: FontWeight.w800),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 66,
        elevation: 0,
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.orange.withValues(alpha: .13),
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(size: 23, color: selected ? AppColors.orange : AppColors.muted);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? AppColors.text : AppColors.muted,
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
      ),
      inputDecorationTheme: const InputDecorationThemeData(
        filled: true,
        fillColor: AppColors.background,
        hintStyle: TextStyle(color: AppColors.muted),
        enabledBorder: OutlineInputBorder(
          borderRadius: panelRadius,
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: panelRadius,
          borderSide: BorderSide(color: AppColors.orange),
        ),
        border: OutlineInputBorder(borderRadius: panelRadius),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.raised,
        contentTextStyle: const TextStyle(color: AppColors.text),
        shape: RoundedRectangleBorder(
          borderRadius: panelRadius,
          side: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}
