// To parse this JSON data, do
//
//     final userPasswordChange = userPasswordChangeFromJson(jsonString);

import 'dart:convert';

UserPasswordChange userPasswordChangeFromJson(String str) =>
    UserPasswordChange.fromJson(json.decode(str));

String userPasswordChangeToJson(UserPasswordChange data) =>
    json.encode(data.toJson());

class UserPasswordChange {
  String email;
  String password;

  UserPasswordChange({
    required this.email,
    required this.password,
  });

  factory UserPasswordChange.fromJson(Map<String, dynamic> json) =>
      UserPasswordChange(
        email: json["email"],
        password: json["password"],
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "password": password,
      };
}
