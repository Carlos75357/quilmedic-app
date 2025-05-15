import 'package:equatable/equatable.dart';
import 'package:quilmedic/domain/user.dart';

/// Clase base abstracta para todos los estados de autenticación.
/// Extiende Equatable para facilitar la comparación de estados.
abstract class AuthState extends Equatable {
  /// Constructor constante para la clase base
  const AuthState();
  
  /// Sobrescribe el método props de Equatable
  /// @return Lista vacía por defecto, las subclases pueden sobrescribirlo
  @override
  List<Object?> get props => [];
}

/// Estado inicial de autenticación.
/// Representa el estado antes de verificar si el usuario está autenticado.
class AuthInitial extends AuthState {}

/// Estado de carga durante el proceso de autenticación.
/// Se utiliza mientras se está verificando credenciales o el estado de autenticación.
class AuthLoading extends AuthState {}

/// Estado que indica que el usuario está autenticado.
/// Contiene la información del usuario autenticado.
class Authenticated extends AuthState {
  /// Objeto User con la información del usuario autenticado
  final User user;
  
  /// Constructor del estado Authenticated
  /// @param user Usuario autenticado
  const Authenticated(this.user);
  
  /// Sobrescribe el método props para incluir el usuario
  /// @return Lista con el usuario para comparación de estados
  @override
  List<Object?> get props => [user];
}

/// Estado que indica que el usuario no está autenticado.
/// Se utiliza cuando el usuario no ha iniciado sesión o ha cerrado sesión.
class Unauthenticated extends AuthState {}

/// Estado de error durante el proceso de autenticación.
/// Contiene un mensaje descriptivo del error ocurrido.
class AuthError extends AuthState {
  /// Mensaje descriptivo del error de autenticación
  final String message;
  
  /// Constructor del estado AuthError
  /// @param message Mensaje de error
  const AuthError(this.message);
  
  /// Sobrescribe el método props para incluir el mensaje de error
  /// @return Lista con el mensaje para comparación de estados
  @override
  List<Object?> get props => [message];
}
