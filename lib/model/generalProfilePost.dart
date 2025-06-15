// To parse this JSON data, do
//
//     final generalEditProfilePost = generalEditProfilePostFromJson(jsonString);

import 'dart:convert';

GeneralEditProfilePost generalEditProfilePostFromJson(String str) =>
    GeneralEditProfilePost.fromJson(json.decode(str));

String generalEditProfilePostToJson(GeneralEditProfilePost data) =>
    json.encode(data.toJson());

class GeneralEditProfilePost {
  String userEmail;
  String username;
  String name;
  String surname;
  String phone;
  String address;
  String image;

  GeneralEditProfilePost({
    required this.userEmail,
    required this.username,
    required this.name,
    required this.surname,
    required this.phone,
    required this.address,
    required this.image,
  });

  factory GeneralEditProfilePost.fromJson(Map<String, dynamic> json) =>
      GeneralEditProfilePost(
        userEmail: json["user_email"],
        username: json["username"],
        name: json["name"],
        surname: json["surname"],
        phone: json["phone"],
        address: json["address"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "user_email": userEmail,
        "username": username,
        "name": name,
        "surname": surname,
        "phone": phone,
        "address": address,
        "image": image,
      };
}
