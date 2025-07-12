// To parse this JSON data, do
//
//     final generalPost = generalPostFromJson(jsonString);

import 'dart:convert';

GeneralPost generalPostFromJson(String str) =>
    GeneralPost.fromJson(json.decode(str));

String generalPostToJson(GeneralPost data) => json.encode(data.toJson());

class GeneralPost {
  String userEmail;
  String username;
  String name;
  String surname;
  String phone;
  String address;
  String lat;
  String lng;
  String image;
  String? fcmToken;

  GeneralPost({
    required this.userEmail,
    required this.username,
    required this.name,
    required this.surname,
    required this.phone,
    required this.address,
    required this.lat,
    required this.lng,
    required this.image,
    fcmToken,
  });

  factory GeneralPost.fromJson(Map<String, dynamic> json) => GeneralPost(
        userEmail: json["user_email"],
        username: json["username"],
        name: json["name"],
        surname: json["surname"],
        phone: json["phone"],
        address: json["address"],
        lat: json["lat"],
        lng: json["lng"],
        image: json["image"],
        fcmToken: json["fcmToken"],
      );

  Map<String, dynamic> toJson() => {
        "user_email": userEmail,
        "username": username,
        "name": name,
        "surname": surname,
        "phone": phone,
        "address": address,
        "lat": lat,
        "lng": lng,
        "image": image,
        "fcmToken": fcmToken,
      };
}
