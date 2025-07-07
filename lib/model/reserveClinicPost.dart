// To parse this JSON data, do
//
//     final reserveClinicPost = reserveClinicPostFromJson(jsonString);

import 'dart:convert';

List<ReserveClinicPost> reserveClinicPostFromJson(String str) =>
    List<ReserveClinicPost>.from(
        json.decode(str).map((x) => ReserveClinicPost.fromJson(x)));

String reserveClinicPostToJson(List<ReserveClinicPost> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ReserveClinicPost {
  int reserveId;
  String generalEmail;
  String clinicEmail;
  int dogDogId;
  DateTime date;
  int status;
  int? appointment_aid;
  int type;
  dynamic message;
  String username;
  String phone;

  ReserveClinicPost({
    required this.reserveId,
    required this.generalEmail,
    required this.clinicEmail,
    required this.dogDogId,
    required this.date,
    required this.status,
    required this.appointment_aid,
    required this.type,
    required this.message,
    required this.username,
    required this.phone,
  });

  factory ReserveClinicPost.fromJson(Map<String, dynamic> json) =>
      ReserveClinicPost(
        reserveId: json["reserveID"],
        generalEmail: json["general_email"],
        clinicEmail: json["clinic_email"],
        dogDogId: json["dog_dogId"],
        date: DateTime.parse(json["date"]),
        status: json["status"],
        appointment_aid: json["appointment_aid"],
        type: json["type"],
        message: json["message"],
        username: json["username"],
        phone: json["phone"],
      );

  Map<String, dynamic> toJson() => {
        "reserveID": reserveId,
        "general_email": generalEmail,
        "clinic_email": clinicEmail,
        "dog_dogId": dogDogId,
        "date": date.toIso8601String(),
        "status": status,
        "appointment_aid": appointment_aid,
        "type": type,
        "message": message,
        "username": username,
        "phone": phone,
      };
}
