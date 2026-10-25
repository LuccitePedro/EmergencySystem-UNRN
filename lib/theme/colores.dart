import 'package:flutter/material.dart';

/// Paleta de la app. Todos los colores salen de acá para que no queden repetidos en cada pantalla.
class Colores {
  static const rojo = Color(0xFFF9183E);    // encabezados, botón principal
  static const bordo = Color(0xFFA03333);   // tarjetas y botones de categoría
  static const verde = Color(0xFF43A047);   // llamada al 911
  static const gris = Color(0xFF9E9E9E);    // llamada a contactos
  static const fondo = Colors.white;
  static const textoSuave = Color(0xFF757575);

  // Severidad de las alergias
  static const leve = bordo;
  static const moderada = Color(0xFFE65100);
  static const grave = Color(0xFFB71C1C);

  /// Color de la tarjeta de una alergia según su severidad.
  static Color severidad(String sev) {
    switch (sev) {
      case 'Grave':
        return grave;
      case 'Moderada':
        return moderada;
      default:
        return leve;
    }
  }
}

/// Tema Material 3 armado con los colores de la app.
ThemeData temaApp() {
  final esquema = ColorScheme.fromSeed(
    seedColor: Colores.rojo,
    primary: Colores.rojo,
    secondary: Colores.bordo,
    surface: Colores.fondo,
  );
  final bordeCampo = OutlineInputBorder(borderRadius: BorderRadius.circular(12));

  return ThemeData(
    useMaterial3: true,
    colorScheme: esquema,
    scaffoldBackgroundColor: Colores.fondo,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colores.rojo,
      foregroundColor: Colors.white,
      centerTitle: false,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    cardTheme: CardThemeData(
      color: Colores.bordo,
      elevation: 2,
      shadowColor: Colors.black26,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: bordeCampo,
      enabledBorder: bordeCampo,
      focusedBorder: bordeCampo.copyWith(
        borderSide: const BorderSide(color: Colores.rojo, width: 2),
      ),
      prefixIconColor: Colores.bordo,
      floatingLabelStyle: const TextStyle(color: Colores.bordo),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colores.fondo,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: Colores.bordo),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
    }),
  );
}
