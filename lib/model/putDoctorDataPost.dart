// To parse this JSON data, do
//
//     final putDoctorDataPost = putDoctorDataPostFromJson(jsonString);

import 'dart:convert';

List<PutDoctorDataPost> putDoctorDataPostFromJson(String str) =>
    List<PutDoctorDataPost>.from(
        json.decode(str).map((x) => PutDoctorDataPost.fromJson(x)));

String putDoctorDataPostToJson(List<PutDoctorDataPost> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PutDoctorDataPost {
  String name;
  String surname;
  String image;

  PutDoctorDataPost({
    required this.name,
    required this.surname,
    required this.image,
  });

  factory PutDoctorDataPost.fromJson(Map<String, dynamic> json) =>
      PutDoctorDataPost(
        name: json["name"],
        surname: json["surname"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "surname": surname,
        "image": image,
      };
}
