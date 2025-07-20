// To parse this JSON data, do
//
//     final dogsUpdateDataPut = dogsUpdateDataPutFromJson(jsonString);

import 'dart:convert';

DogsUpdateDataPut dogsUpdateDataPutFromJson(String str) =>
    DogsUpdateDataPut.fromJson(json.decode(str));

String dogsUpdateDataPutToJson(DogsUpdateDataPut data) =>
    json.encode(data.toJson());

class DogsUpdateDataPut {
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

  DogsUpdateDataPut({
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

  factory DogsUpdateDataPut.fromJson(Map<String, dynamic> json) =>
      DogsUpdateDataPut(
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
