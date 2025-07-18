// To parse this JSON data, do
//
//     final clinicGetSchedule = clinicGetScheduleFromJson(jsonString);

import 'dart:convert';

List<ClinicGetSchedule> clinicGetScheduleFromJson(String str) =>
    List<ClinicGetSchedule>.from(
        json.decode(str).map((x) => ClinicGetSchedule.fromJson(x)));

String clinicGetScheduleToJson(List<ClinicGetSchedule> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ClinicGetSchedule {
  int sid;
  String clinicEmail;
  String weekdays;
  String openTime;
  String closeTime;

  ClinicGetSchedule({
    required this.sid,
    required this.clinicEmail,
    required this.weekdays,
    required this.openTime,
    required this.closeTime,
  });

  factory ClinicGetSchedule.fromJson(Map<String, dynamic> json) =>
      ClinicGetSchedule(
        sid: json["sid"],
        clinicEmail: json["clinic_email"],
        weekdays: json["weekdays"],
        openTime: json["open_time"],
        closeTime: json["close_time"],
      );

  Map<String, dynamic> toJson() => {
        "sid": sid,
        "clinic_email": clinicEmail,
        "weekdays": weekdays,
        "open_time": openTime,
        "close_time": closeTime,
      };
}
