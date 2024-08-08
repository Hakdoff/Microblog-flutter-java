import 'dart:convert';

class UserModel {
  final int id;
  final String name;
  final String email;
  final String? profilePictureUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.profilePictureUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      profilePictureUrl: map['profilePictureUrl'],
    );
  }

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));
}
