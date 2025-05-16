import 'package:flutter/material.dart';

/// Clase que define los temas y estilos visuales de la aplicación
/// Proporciona colores, temas claro y oscuro, y estilos para los componentes UI

class AppTheme {
  /// Color primario de la aplicación
  static final Color primaryColor = Color.fromARGB(255, 6, 179, 202);
  /// Color secundario de la aplicación
  static final Color secondaryColor = Color.fromARGB(255, 151, 243, 255);
  /// Color de acento para elementos destacados
  static final Color accentColor = Color.fromARGB(255, 0, 140, 158);
  /// Color de fondo predeterminado
  static final Color backgroundColor = Colors.white;
  /// Color para errores y alertas críticas
  static final Color errorColor = Colors.red.shade700;
  /// Color para mensajes de éxito
  static final Color successColor = Colors.green.shade600;
  /// Color para advertencias
  static final Color warningColor = Colors.amber.shade700;
  /// Color principal para textos
  static final Color textPrimaryColor = Colors.black87;
  /// Color secundario para textos menos importantes
  static final Color textSecondaryColor = Colors.black54;

  /// Tema claro de la aplicación
  /// Define los estilos para el modo de día
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: backgroundColor,
      error: errorColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: primaryColor),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: BorderSide(color: primaryColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: errorColor, width: 1),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: AppTheme.backgroundColor,
      titleTextStyle: TextStyle(
        color: AppTheme.primaryColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: const Color.fromARGB(255, 241, 241, 241),
      foregroundColor: const Color.fromARGB(255, 37, 37, 37),
      elevation: 4,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: const Color.fromARGB(255, 37, 37, 37),
          width: 2,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    dividerTheme: DividerThemeData(thickness: 1, color: Colors.grey.shade300),
    scaffoldBackgroundColor: Colors.grey.shade50,
  );

  /// Tema oscuro de la aplicación
  /// Define los estilos para el modo nocturno
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: Color(0xFF1E1E1E),
      error: errorColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: secondaryColor),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: secondaryColor,
        side: BorderSide(color: secondaryColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF2C2C2C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: errorColor, width: 1),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    cardTheme: CardTheme(
      color: Color(0xFF2C2C2C),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: AppTheme.backgroundColor,
      titleTextStyle: TextStyle(
        color: AppTheme.primaryColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    dividerTheme: DividerThemeData(thickness: 1, color: Colors.grey.shade800),
    scaffoldBackgroundColor: Color(0xFF121212),
  );
}
