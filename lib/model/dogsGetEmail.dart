// To parse this JSON data, do
//
//     final dogsGetEmail = dogsGetEmailFromJson(jsonString);

import 'dart:convert';

List<DogsGetEmail> dogsGetEmailFromJson(String str) => List<DogsGetEmail>.from(
    json.decode(str).map((x) => DogsGetEmail.fromJson(x)));

String dogsGetEmailToJson(List<DogsGetEmail> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DogsGetEmail {
  int dogId;
  String userEmail;
  String name;
  String breed;
  String gender;
  String color;
  String defect;
  String birthday;
  String congentialDisease;
  int sterilization;
  String hair;
  String image;

  DogsGetEmail({
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

  factory DogsGetEmail.fromJson(Map<String, dynamic> json) => DogsGetEmail(
        dogId: json["dogId"],
        userEmail: json["user_email"],
        name: json["name"],
        breed: json["breed"],
        gender: json["gender"],
        color: json["color"],
        defect: json["defect"],
        birthday: json["birthday"],
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
        "birthday": birthday,
        "congentialDisease": congentialDisease,
        "sterilization": sterilization,
        "Hair": hair,
        "image": image,
      };
}
