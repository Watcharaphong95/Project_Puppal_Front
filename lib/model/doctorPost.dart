// To parse this JSON data, do
//
//     final doctorPost = doctorPostFromJson(jsonString);

import 'dart:convert';

DoctorPost doctorPostFromJson(String str) =>
    DoctorPost.fromJson(json.decode(str));

String doctorPostToJson(DoctorPost data) => json.encode(data.toJson());

class DoctorPost {
  String userEmail;
  String name;
  String surname;
  String careerNo;
  String? special;

  String image;

  DoctorPost(
      {required this.userEmail,
      required this.name,
      required this.surname,
      required this.careerNo,
      required this.image,
      this.special});

  factory DoctorPost.fromJson(Map<String, dynamic> json) => DoctorPost(
        userEmail: json["user_email"],
        name: json["name"],
        surname: json["surname"],
        careerNo: json["careerNo"],
        image: json["image"],
        special: json["special"],
      );

  Map<String, dynamic> toJson() => {
        "user_email": userEmail,
        "name": name,
        "surname": surname,
        "careerNo": careerNo,
        "image": image,
        "special": special,
      };
}
