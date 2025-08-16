// To parse this JSON data, do
//
//     final appointmentGetvaccine = appointmentGetvaccineFromJson(jsonString);

import 'dart:convert';

AppointmentGetvaccine appointmentGetvaccineFromJson(String str) =>
    AppointmentGetvaccine.fromJson(json.decode(str));

String appointmentGetvaccineToJson(AppointmentGetvaccine data) =>
    json.encode(data.toJson());

class AppointmentGetvaccine {
  int aid;
  int dogId;
  String generalUserEmail;
  String vaccine;
  DateTime date;

  AppointmentGetvaccine({
    required this.aid,
    required this.dogId,
    required this.generalUserEmail,
    required this.vaccine,
    required this.date,
  });

  factory AppointmentGetvaccine.fromJson(Map<String, dynamic> json) =>
      AppointmentGetvaccine(
        aid: json["aid"],
        dogId: json["dogId"],
        generalUserEmail: json["general_user_email"],
        vaccine: json["vaccine"],
        date: DateTime.parse(json["date"]),
      );

  Map<String, dynamic> toJson() => {
        "aid": aid,
        "dogId": dogId,
        "general_user_email": generalUserEmail,
        "vaccine": vaccine,
        "date": date.toIso8601String(),
      };
}
