import 'package:flutter/material.dart';
import 'package:quilmedic/ui/auth/login_page.dart';

/// Servicio que gestiona la navegación entre pantallas de la aplicación.
/// Proporciona métodos para navegar a pantallas específicas y mantiene
/// una referencia global al navegador para acceder desde cualquier parte de la app.
class NavigationService {
  /// Clave global para acceder al estado del navegador desde cualquier parte de la aplicación
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Navega a la pantalla de inicio de sesión, eliminando todas las pantallas anteriores de la pila
  /// Utilizado principalmente cuando expira la sesión o se cierra sesión
  static void navigateToLogin() {
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }
}
