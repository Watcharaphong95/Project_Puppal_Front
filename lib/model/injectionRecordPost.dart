// To parse this JSON data, do
//
//     final injectionRecordPost = injectionRecordPostFromJson(jsonString);

import 'dart:convert';

InjectionRecordPost injectionRecordPostFromJson(String str) =>
    InjectionRecordPost.fromJson(json.decode(str));

String injectionRecordPostToJson(InjectionRecordPost data) =>
    json.encode(data.toJson());

class InjectionRecordPost {
  int dogId;
  String clinicName;
  String vaccineType;
  String date;
  int status;

  InjectionRecordPost({
    required this.dogId,
    required this.clinicName,
    required this.vaccineType,
    required this.date,
    required this.status,
  });

  factory InjectionRecordPost.fromJson(Map<String, dynamic> json) =>
      InjectionRecordPost(
        dogId: json["dogId"],
        clinicName: json["clinicName"],
        vaccineType: json["vaccineType"],
        date: json["date"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "dog_Id": dogId,
        "clinicName": clinicName,
        "vaccineType": vaccineType,
        "date": date,
        "status": status,
      };
}
