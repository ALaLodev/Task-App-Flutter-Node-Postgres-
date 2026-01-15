import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_pallete.dart';

final class AppTheme {
  // Borde por defecto (cuando no escribes)
  static OutlineInputBorder _border([Color color = AppPallete.borderColor]) =>
      OutlineInputBorder(
        borderSide: BorderSide(color: color, width: 3),
        borderRadius: BorderRadius.circular(10),
      );

  static final darkThemeMode = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppPallete.backgroundColor,
    appBarTheme: const AppBarTheme(backgroundColor: AppPallete.backgroundColor),
    //Definimos el estilo global de los inputs
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(27),
      enabledBorder: _border(),
      focusedBorder: _border(AppPallete.gradient2), // Borde rosa al enfocar
      errorBorder: _border(AppPallete.errorColor),
    ),
  );
}
