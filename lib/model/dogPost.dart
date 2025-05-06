// To parse this JSON data, do
//
//     final dogPost = dogPostFromJson(jsonString);

import 'dart:convert';

DogPost dogPostFromJson(String str) => DogPost.fromJson(json.decode(str));

String dogPostToJson(DogPost data) => json.encode(data.toJson());

class DogPost {
  String userEmail;
  String name;
  String breed;
  String gender;
  String color;
  String defect;
  String birthday;
  String congentialDisease;
  String sterilization;
  String hair;
  String image;

  DogPost({
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

  factory DogPost.fromJson(Map<String, dynamic> json) => DogPost(
        userEmail: json["user_email"],
        name: json["name"],
        breed: json["breed"],
        gender: json["gender"],
        color: json["color"],
        defect: json["defect"],
        birthday: json["birthday"],
        congentialDisease: json["congentialDisease"],
        sterilization: json["sterilization"],
        hair: json["hair"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "user_email": userEmail,
        "name": name,
        "breed": breed,
        "gender": gender,
        "color": color,
        "defect": defect,
        "birthday": birthday,
        "congentialDisease": congentialDisease,
        "sterilization": sterilization,
        "hair": hair,
        "image": image,
      };
}
