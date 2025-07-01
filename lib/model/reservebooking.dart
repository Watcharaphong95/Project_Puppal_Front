// To parse this JSON data, do
//
//     final reservebooking = reservebookingFromJson(jsonString);

import 'dart:convert';

List<Reservebooking> reservebookingFromJson(String str) =>
    List<Reservebooking>.from(
        json.decode(str).map((x) => Reservebooking.fromJson(x)));

String reservebookingToJson(List<Reservebooking> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Reservebooking {
  int reserveId;
  String generalEmail;
  String clinicEmail;
  int dogDogId;
  DateTime date;
  int status;
  String typeVaccine;
  int type;
  dynamic message;
  String username;
  String phone;
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

  Reservebooking({
    required this.reserveId,
    required this.generalEmail,
    required this.clinicEmail,
    required this.dogDogId,
    required this.date,
    required this.status,
    required this.typeVaccine,
    required this.type,
    required this.message,
    required this.username,
    required this.phone,
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

  factory Reservebooking.fromJson(Map<String, dynamic> json) => Reservebooking(
        reserveId: json["reserveID"],
        generalEmail: json["general_email"],
        clinicEmail: json["clinic_email"],
        dogDogId: json["dog_dogId"],
        date: DateTime.parse(json["date"]),
        status: json["status"],
        typeVaccine: json["typeVaccine"],
        type: json["type"],
        message: json["message"],
        username: json["username"],
        phone: json["phone"],
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
        "reserveID": reserveId,
        "general_email": generalEmail,
        "clinic_email": clinicEmail,
        "dog_dogId": dogDogId,
        "date": date.toIso8601String(),
        "status": status,
        "typeVaccine": typeVaccine,
        "type": type,
        "message": message,
        "username": username,
        "phone": phone,
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
