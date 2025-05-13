import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String username;
  final String token;
  final String androidId;

  const User({
    required this.id,
    required this.username,
    required this.token,
    required this.androidId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      token: json['token'],
      androidId: json['android_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'token': token,
      'android_id': androidId,
    };
  }

  @override
  List<Object?> get props => [id, username, token, androidId];
}
