// To parse this JSON data, do
//
//     final reserveGeneralPost = reserveGeneralPostFromJson(jsonString);

import 'dart:convert';

List<ReserveGeneralPost> reserveGeneralPostFromJson(String str) =>
    List<ReserveGeneralPost>.from(
        json.decode(str).map((x) => ReserveGeneralPost.fromJson(x)));

String reserveGeneralPostToJson(List<ReserveGeneralPost> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ReserveGeneralPost {
  int reserveId;
  String generalEmail;
  String clinicEmail;
  int dogDogId;
  String date;
  int? status;
  String typeVaccine;
  int? type;

  ReserveGeneralPost({
    required this.reserveId,
    required this.generalEmail,
    required this.clinicEmail,
    required this.dogDogId,
    required this.date,
    this.status,
    required this.typeVaccine,
    this.type,
  });

  factory ReserveGeneralPost.fromJson(Map<String, dynamic> json) =>
      ReserveGeneralPost(
        reserveId: json["reserveID"],
        generalEmail: json["general_email"],
        clinicEmail: json["clinic_email"],
        dogDogId: json["dog_dogId"],
        date: json["date"],
        status: json["status"],
        typeVaccine: json["typeVaccine"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "reserveID": reserveId,
        "general_email": generalEmail,
        "clinic_email": clinicEmail,
        "dog_dogId": dogDogId,
        "date": date,
        "status": status,
        "typeVaccine": typeVaccine,
        "type": type,
      };
}
