// To parse this JSON data, do
//
//     final appointmentPost = appointmentPostFromJson(jsonString);

import 'dart:convert';

List<AppointmentPost> appointmentPostFromJson(String str) =>
    List<AppointmentPost>.from(
        json.decode(str).map((x) => AppointmentPost.fromJson(x)));

String appointmentPostToJson(List<AppointmentPost> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AppointmentPost {
  int dogId;
  String generalUserEmail;
  String vaccine;
  DateTime date;

  AppointmentPost({
    required this.dogId,
    required this.generalUserEmail,
    required this.vaccine,
    required this.date,
  });

  factory AppointmentPost.fromJson(Map<String, dynamic> json) =>
      AppointmentPost(
        dogId: json["dogId"],
        generalUserEmail: json["general_user_email"],
        vaccine: json["vaccine"],
        date: DateTime.parse(json["date"]),
      );

  Map<String, dynamic> toJson() => {
        "dogId": dogId,
        "general_user_email": generalUserEmail,
        "vaccine": vaccine,
        "date": date.toIso8601String(),
      };
}
