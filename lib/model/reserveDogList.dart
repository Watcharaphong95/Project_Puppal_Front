// To parse this JSON data, do
//
//     final reserveDoglist = reserveDoglistFromJson(jsonString);

import 'dart:convert';

List<ReserveDoglist> reserveDoglistFromJson(String str) =>
    List<ReserveDoglist>.from(
        json.decode(str).map((x) => ReserveDoglist.fromJson(x)));

String reserveDoglistToJson(List<ReserveDoglist> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ReserveDoglist {
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
  int status;

  ReserveDoglist({
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
    required this.status,
  });

  factory ReserveDoglist.fromJson(Map<String, dynamic> json) => ReserveDoglist(
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
        status: json["status"],
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
        "status": status,
      };
}
