// To parse this JSON data, do
//
//     final dogDetailsPost = dogDetailsPostFromJson(jsonString);

import 'dart:convert';

List<DogDetailsPost> dogDetailsPostFromJson(String str) =>
    List<DogDetailsPost>.from(
        json.decode(str).map((x) => DogDetailsPost.fromJson(x)));

String dogDetailsPostToJson(List<DogDetailsPost> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DogDetailsPost {
  int dogId;
  String userEmail;
  String name;
  String breed;
  String gender;
  String color;
  String defect;
  DateTime birthday;
  String congentialDisease;
  int sterilization;
  String hair;
  String image;

  DogDetailsPost({
    required this.dogId,
    required this.userEmail,
    required this.name,
    required this.breed,
    required this.gender,
    required this.color,
    required this.defect,
    required this.birthday,
    required this.congentialDisease,
    required this.sterilization,
    required this.hair,
    required this.image,
  });

  factory DogDetailsPost.fromJson(Map<String, dynamic> json) => DogDetailsPost(
        dogId: json["dogId"],
        userEmail: json["user_email"],
        name: json["name"],
        breed: json["breed"],
        gender: json["gender"],
        color: json["color"],
        defect: json["defect"],
        birthday: DateTime.parse(json["birthday"]),
        congentialDisease: json["congentialDisease"],
        sterilization: json["sterilization"],
        hair: json["Hair"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "dogId": dogId,
        "user_email": userEmail,
        "name": name,
        "breed": breed,
        "gender": gender,
        "color": color,
        "defect": defect,
        "birthday": birthday.toIso8601String(),
        "congentialDisease": congentialDisease,
        "sterilization": sterilization,
        "Hair": hair,
        "image": image,
      };
}
