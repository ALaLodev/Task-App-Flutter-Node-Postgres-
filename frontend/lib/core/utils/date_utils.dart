import 'package:flutter/material.dart';

class AppDateUtils {
  // Genera la lista de fechas para una semana dada
  static List<DateTime> generateWeekDates(int weekOffset) {
    final today = DateTime.now();

    // TRUCO: Normalizamos 'today' para que sea las 00:00 horas.
    // Así evitamos problemas de comparación de horas/minutos.
    DateTime normalizedToday = DateTime(today.year, today.month, today.day);

    // Calculamos el lunes de la semana correspondiente
    DateTime startOfWeek = normalizedToday.subtract(
      Duration(days: normalizedToday.weekday - 1),
    );
    startOfWeek = startOfWeek.add(Duration(days: weekOffset * 7));

    return List.generate(7, (index) {
      return startOfWeek.add(Duration(days: index));
    });
  }

  // Compara si dos fechas son el mismo día (ignorando la hora)
  static bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Genera colores hexadecimales a Color de Flutter
  static Color hexToColor(String hex) {
    return Color(int.parse(hex.replaceAll('#', '0xFF')));
  }

  // Genera String hexadecimal desde Color
  static String colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2)}';
  }

  // Oscurece un color (para bordes)
  static Color strengthenColor(Color color, double factor) {
    int r = (color.r * 255 * factor).clamp(0, 255).toInt();
    int g = (color.g * 255 * factor).clamp(0, 255).toInt();
    int b = (color.b * 255 * factor).clamp(0, 255).toInt();
    int a = (color.a * 255).toInt();

    return Color.fromARGB(a, r, g, b);
  }
}
