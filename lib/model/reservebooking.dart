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
  int? appointmentAid;
  DateTime date;
  int status;
  int type;
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
  int? aid;
  String? appointmentName;

  Reservebooking({
    required this.reserveId,
    required this.generalEmail,
    required this.clinicEmail,
    required this.dogDogId,
    required this.appointmentAid,
    required this.date,
    required this.status,
    required this.type,
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
    required this.aid,
    required this.appointmentName,
  });

  factory Reservebooking.fromJson(Map<String, dynamic> json) => Reservebooking(
        reserveId: json["reserveID"],
        generalEmail: json["general_email"],
        clinicEmail: json["clinic_email"],
        dogDogId: json["dog_dogId"],
        appointmentAid: json["appointment_aid"],
        date: DateTime.parse(json["date"]),
        status: json["status"],
        type: json["type"],
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
        aid: json["aid"],
        appointmentName: json["appointment_name"],
      );

  Map<String, dynamic> toJson() => {
        "reserveID": reserveId,
        "general_email": generalEmail,
        "clinic_email": clinicEmail,
        "dog_dogId": dogDogId,
        "appointment_aid": appointmentAid,
        "date": date.toIso8601String(),
        "status": status,
        "type": type,
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
        "aid": aid,
        "appointment_name": appointmentName,
      };
}
