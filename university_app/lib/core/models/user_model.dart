// ملف: lib/core/models/user_model.dart

import 'dart:convert';

List<UserModel> userModelFromJson(String str) => List<UserModel>.from(json.decode(str).map((x) => UserModel.fromJson(x)));
UserModel userModelFromSingleJson(String str) => UserModel.fromJson(json.decode(str));

class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String? token;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json["id"] ?? '',
    email: json["email"] ?? 'N/A',
    firstName: json["firstName"] ?? '',
    lastName: json["lastName"] ?? '',
    role: json["role"] ?? 'STUDENT',
    token: json["token"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "email": email,
    "firstName": firstName,
    "lastName": lastName,
    "role": role,
    "token": token,
  };
}