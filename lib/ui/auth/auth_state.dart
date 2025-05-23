import 'package:equatable/equatable.dart';
import 'package:quilmedic/domain/user.dart';

/// Clase base abstracta para todos los estados de autenticación.
/// Extiende Equatable para facilitar la comparación de estados.
abstract class AuthState extends Equatable {
  /// Constructor constante para la clase base
  const AuthState();
  
  /// Sobrescribe el método props de Equatable
  /// @return [List] Lista vacía por defecto, las subclases pueden sobrescribirlo
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
  /// @param [user] Usuario autenticado
  const Authenticated(this.user);
  
  /// Sobrescribe el método props para incluir el usuario
  /// @return [List] Lista con el usuario para comparación de estados
  @override
  List<Object?> get props => [user];
}

/// Estado que indica que el usuario está autenticado y hay una actualización disponible.
/// Extiende Authenticated y añade información sobre la actualización disponible.
class AuthenticatedWithUpdate extends Authenticated {
  /// Versión actual de la aplicación
  final String currentVersion;
  /// Última versión disponible
  final String latestVersion;
  /// Ruta al archivo APK descargado
  final String filePath;
  /// Notas de la versión
  final String releaseNotes;
  /// Indica si la actualización es obligatoria
  final bool forceUpdate;
  
  /// Constructor del estado AuthenticatedWithUpdate
  /// @param [user] Usuario autenticado
  /// @param [currentVersion] Versión actual de la aplicación
  /// @param [latestVersion] Última versión disponible
  /// @param [filePath] Ruta al archivo APK descargado
  /// @param [releaseNotes] Notas de la versión
  /// @param [forceUpdate] Indica si la actualización es obligatoria
  const AuthenticatedWithUpdate(
    User user, {
    required this.currentVersion,
    required this.latestVersion,
    required this.filePath,
    required this.releaseNotes,
    required this.forceUpdate,
  }) : super(user);
  
  /// Sobrescribe el método props para incluir la información de actualización
  /// @return [List] Lista con el usuario y la información de actualización
  @override
  List<Object?> get props => [
    user,
    currentVersion,
    latestVersion,
    filePath,
    releaseNotes,
    forceUpdate,
  ];
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
  /// @param [message] Mensaje de error
  const AuthError(this.message);
  
  /// Sobrescribe el método props para incluir el mensaje de error
  /// @return [List] Lista con el mensaje para comparación de estados
  @override
  List<Object?> get props => [message];
}
