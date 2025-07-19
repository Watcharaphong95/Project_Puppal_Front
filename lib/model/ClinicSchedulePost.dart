// To parse this JSON data, do
//
//     final clinicSchedulePost = clinicSchedulePostFromJson(jsonString);

import 'dart:convert';

List<ClinicSchedulePost> clinicSchedulePostFromJson(String str) =>
    List<ClinicSchedulePost>.from(
        json.decode(str).map((x) => ClinicSchedulePost.fromJson(x)));

String clinicSchedulePostToJson(List<ClinicSchedulePost> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ClinicSchedulePost {
  String weekdays;
  String openTime;
  String closeTime;

  ClinicSchedulePost({
    required this.weekdays,
    required this.openTime,
    required this.closeTime,
  });

  factory ClinicSchedulePost.fromJson(Map<String, dynamic> json) =>
      ClinicSchedulePost(
        weekdays: json["weekdays"],
        openTime: json["open_time"],
        closeTime: json["close_time"],
      );

  Map<String, dynamic> toJson() => {
        "weekdays": weekdays,
        "open_time": openTime,
        "close_time": closeTime,
      };
}
