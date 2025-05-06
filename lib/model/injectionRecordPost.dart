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

  InjectionRecordPost({
    required this.dogId,
    required this.clinicName,
    required this.vaccineType,
    required this.date,
  });

  factory InjectionRecordPost.fromJson(Map<String, dynamic> json) =>
      InjectionRecordPost(
        dogId: json["dogId"],
        clinicName: json["clinicName"],
        vaccineType: json["vaccineType"],
        date: json["date"],
      );

  Map<String, dynamic> toJson() => {
        "dog_Id": dogId,
        "clinicName": clinicName,
        "vaccineType": vaccineType,
        "date": date,
      };
}
