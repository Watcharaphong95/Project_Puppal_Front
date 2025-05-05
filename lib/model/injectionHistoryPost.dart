// To parse this JSON data, do
//
//     final injectionRecordPost = injectionRecordPostFromJson(jsonString);

import 'dart:convert';

InjectionRecordPost injectionRecordPostFromJson(String str) =>
    InjectionRecordPost.fromJson(json.decode(str));

String injectionRecordPostToJson(InjectionRecordPost data) =>
    json.encode(data.toJson());

class InjectionRecordPost {
  String clinicName;
  String vaccineType;
  String date;

  InjectionRecordPost({
    required this.clinicName,
    required this.vaccineType,
    required this.date,
  });

  factory InjectionRecordPost.fromJson(Map<String, dynamic> json) =>
      InjectionRecordPost(
        clinicName: json["clinicName"],
        vaccineType: json["vaccineType"],
        date: json["date"],
      );

  Map<String, dynamic> toJson() => {
        "clinicName": clinicName,
        "vaccineType": vaccineType,
        "date": date,
      };
}
