// To parse this JSON data, do
//
//     final reserveSpecialCheck = reserveSpecialCheckFromJson(jsonString);

import 'dart:convert';

ReserveSpecialCheck reserveSpecialCheckFromJson(String str) =>
    ReserveSpecialCheck.fromJson(json.decode(str));

String reserveSpecialCheckToJson(ReserveSpecialCheck data) =>
    json.encode(data.toJson());

class ReserveSpecialCheck {
  String generalEmail;
  String clinicEmail;
  String date;

  ReserveSpecialCheck({
    required this.generalEmail,
    required this.clinicEmail,
    required this.date,
  });

  factory ReserveSpecialCheck.fromJson(Map<String, dynamic> json) =>
      ReserveSpecialCheck(
        generalEmail: json["general_email"],
        clinicEmail: json["clinic_email"],
        date: json["date"],
      );

  Map<String, dynamic> toJson() => {
        "general_email": generalEmail,
        "clinic_email": clinicEmail,
        "date": date,
      };
}
