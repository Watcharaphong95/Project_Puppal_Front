// To parse this JSON data, do
//
//     final userPost = userPostFromJson(jsonString);

import 'dart:convert';

UserPost userPostFromJson(String str) => UserPost.fromJson(json.decode(str));

String userPostToJson(UserPost data) => json.encode(data.toJson());

class UserPost {
  String? email;
  String? password;
  int? general;
  int? clinic;

  UserPost({
    this.email,
    this.password,
    this.general,
    this.clinic,
  });

  factory UserPost.fromJson(Map<String, dynamic> json) => UserPost(
        email: json["email"],
        password: json["password"],
        general: json["general"],
        clinic: json["clinic"],
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "password": password,
        "general": general,
        "clinic": clinic,
      };
}
