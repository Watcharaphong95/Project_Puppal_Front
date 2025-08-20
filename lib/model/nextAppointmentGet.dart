// To parse this JSON data, do
//
//     final nextAppointmentGet = nextAppointmentGetFromJson(jsonString);

import 'dart:convert';

List<NextAppointmentGet> nextAppointmentGetFromJson(String str) =>
    List<NextAppointmentGet>.from(
        json.decode(str).map((x) => NextAppointmentGet.fromJson(x)));

String nextAppointmentGetToJson(List<NextAppointmentGet> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class NextAppointmentGet {
  int aid;
  int dogId;
  String generalUserEmail;
  String vaccine;
  String date;

  NextAppointmentGet({
    required this.aid,
    required this.dogId,
    required this.generalUserEmail,
    required this.vaccine,
    required this.date,
  });

  factory NextAppointmentGet.fromJson(Map<String, dynamic> json) =>
      NextAppointmentGet(
        aid: json["aid"],
        dogId: json["dogId"],
        generalUserEmail: json["general_user_email"],
        vaccine: json["vaccine"],
        date: json["date"],
      );

  Map<String, dynamic> toJson() => {
        "aid": aid,
        "dogId": dogId,
        "general_user_email": generalUserEmail,
        "vaccine": vaccine,
        "date": date,
      };
}
