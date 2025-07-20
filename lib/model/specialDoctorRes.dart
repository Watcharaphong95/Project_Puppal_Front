// To parse this JSON data, do
//
//     final specialDoctorResponse = specialDoctorResponseFromJson(jsonString);

import 'dart:convert';

List<SpecialDoctorResponse> specialDoctorResponseFromJson(String str) =>
    List<SpecialDoctorResponse>.from(
        json.decode(str).map((x) => SpecialDoctorResponse.fromJson(x)));

String specialDoctorResponseToJson(List<SpecialDoctorResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SpecialDoctorResponse {
  int specialId;
  String name;

  SpecialDoctorResponse({
    required this.specialId,
    required this.name,
  });

  factory SpecialDoctorResponse.fromJson(Map<String, dynamic> json) =>
      SpecialDoctorResponse(
        specialId: json["special_id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "special_id": specialId,
        "name": name,
      };
}
