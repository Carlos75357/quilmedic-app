import 'package:equatable/equatable.dart';

/// Clase que representa un usuario del sistema.
/// Contiene la información básica del usuario como su identificador, nombre de usuario,
/// token de autenticación y el ID del dispositivo Android.
/// Extiende de Equatable para facilitar la comparación de objetos.
class User extends Equatable {
  /// Identificador único del usuario
  final int id;
  /// Nombre de usuario
  final String username;
  /// Token de autenticación para las peticiones a la API
  final String token;
  /// Identificador único del dispositivo Android
  final String androidId;

  /// Constructor de la clase User
  /// @param [id] Identificador único del usuario
  /// @param [username] Nombre de usuario
  /// @param [token] Token de autenticación
  /// @param [androidId] ID del dispositivo Android
  const User({
    required this.id,
    required this.username,
    required this.token,
    required this.androidId,
  });

  /// Constructor factory para crear una instancia de User desde un mapa JSON
  /// proveniente de la API
  /// @param [json] Mapa con los datos en formato JSON
  /// @return Nueva instancia de [User]
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      token: json['token'],
      androidId: json['android_id'],
    );
  }
  
  /// Convierte la instancia actual a un mapa JSON para enviar a la API
  /// @return [Map] Mapa con los datos del usuario en formato JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'token': token,
      'android_id': androidId,
    };
  }

  /// Sobrescribe el método props de Equatable para definir qué propiedades
  /// se utilizan para comparar objetos User
  /// @return [List] Lista de propiedades para la comparación
  @override
  List<Object?> get props => [id, username, token, androidId];
}
