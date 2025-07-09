// To parse this JSON data, do
//
//     final clinicSlotPost = clinicSlotPostFromJson(jsonString);

import 'dart:convert';

ClinicSlotPost clinicSlotPostFromJson(String str) =>
    ClinicSlotPost.fromJson(json.decode(str));

String clinicSlotPostToJson(ClinicSlotPost data) => json.encode(data.toJson());

class ClinicSlotPost {
  String email;
  String date;

  ClinicSlotPost({
    required this.email,
    required this.date,
  });

  factory ClinicSlotPost.fromJson(Map<String, dynamic> json) => ClinicSlotPost(
        email: json["email"],
        date: json["date"],
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "date": date,
      };
}
