import 'package:flutter/material.dart';
import 'package:quilmedic/ui/auth/login_page.dart';

/// Servicio de navegación global para la aplicación
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Navega a la pantalla de login y elimina todas las rutas anteriores
  static void navigateToLogin() {
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false, // Eliminar todas las rutas anteriores
      );
    }
  }
}
