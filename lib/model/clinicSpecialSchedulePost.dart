// To parse this JSON data, do
//
//     final clinicSpecialSchedulePost = clinicSpecialSchedulePostFromJson(jsonString);

import 'dart:convert';

List<ClinicSpecialSchedulePost> clinicSpecialSchedulePostFromJson(String str) =>
    List<ClinicSpecialSchedulePost>.from(
        json.decode(str).map((x) => ClinicSpecialSchedulePost.fromJson(x)));

String clinicSpecialSchedulePostToJson(List<ClinicSpecialSchedulePost> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ClinicSpecialSchedulePost {
  String clinicEmail;
  DateTime date;

  ClinicSpecialSchedulePost({
    required this.clinicEmail,
    required this.date,
  });

  factory ClinicSpecialSchedulePost.fromJson(Map<String, dynamic> json) =>
      ClinicSpecialSchedulePost(
        clinicEmail: json["clinic_email"],
        date: DateTime.parse(json["date"]),
      );

  Map<String, dynamic> toJson() => {
        "clinic_email": clinicEmail,
        "date": date.toIso8601String(),
      };
}
