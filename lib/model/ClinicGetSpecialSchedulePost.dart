// To parse this JSON data, do
//
//     final clinicGetSpecialSchedulePost = clinicGetSpecialSchedulePostFromJson(jsonString);

import 'dart:convert';

List<ClinicGetSpecialSchedulePost> clinicGetSpecialSchedulePostFromJson(
        String str) =>
    List<ClinicGetSpecialSchedulePost>.from(
        json.decode(str).map((x) => ClinicGetSpecialSchedulePost.fromJson(x)));

String clinicGetSpecialSchedulePostToJson(
        List<ClinicGetSpecialSchedulePost> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ClinicGetSpecialSchedulePost {
  int specialScheduleId;
  String clinicEmail;
  DateTime date;

  ClinicGetSpecialSchedulePost({
    required this.specialScheduleId,
    required this.clinicEmail,
    required this.date,
  });

  factory ClinicGetSpecialSchedulePost.fromJson(Map<String, dynamic> json) =>
      ClinicGetSpecialSchedulePost(
        specialScheduleId: json["special_schedule_id"],
        clinicEmail: json["clinic_email"],
        date: DateTime.parse(json["date"]),
      );

  Map<String, dynamic> toJson() => {
        "special_schedule_id": specialScheduleId,
        "clinic_email": clinicEmail,
        "date": date.toIso8601String(),
      };
}
