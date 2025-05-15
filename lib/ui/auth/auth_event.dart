import 'package:equatable/equatable.dart';

/// Clase base abstracta para todos los eventos de autenticación.
/// Extiende Equatable para facilitar la comparación de eventos.
abstract class AuthEvent extends Equatable {
  /// Constructor constante para la clase base
  const AuthEvent();

  /// Sobrescribe el método props de Equatable
  /// @return Lista vacía por defecto, las subclases pueden sobrescribirlo
  @override
  List<Object> get props => [];
}

/// Evento que representa una solicitud de inicio de sesión.
/// Contiene el nombre de usuario y contraseña para la autenticación.
class LoginRequested extends AuthEvent {
  /// Nombre de usuario para el inicio de sesión
  final String username;
  /// Contraseña para el inicio de sesión
  final String password;

  /// Constructor del evento LoginRequested
  /// @param username Nombre de usuario
  /// @param password Contraseña
  const LoginRequested({
    required this.username,
    required this.password,
  });

  /// Sobrescribe el método props para incluir username y password
  /// @return Lista con username y password para comparación de eventos
  @override
  List<Object> get props => [username, password];
}

/// Evento que representa una solicitud de cierre de sesión.
/// No requiere parámetros adicionales.
class LogoutRequested extends AuthEvent {}

/// Evento para verificar el estado actual de autenticación.
/// Se utiliza al iniciar la aplicación o cuando se necesita verificar si el usuario está autenticado.
class CheckAuthStatus extends AuthEvent {}

/// Evento que indica que el token de autenticación ha expirado.
/// Se dispara cuando el servidor rechaza una petición por token inválido o expirado.
class TokenExpired extends AuthEvent {}
