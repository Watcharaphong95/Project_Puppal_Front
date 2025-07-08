// To parse this JSON data, do
//
//     final dogsRecordIdGet = dogsRecordIdGetFromJson(jsonString);

import 'dart:convert';

List<DogsRecordIdGet> dogsRecordIdGetFromJson(String str) =>
    List<DogsRecordIdGet>.from(
        json.decode(str).map((x) => DogsRecordIdGet.fromJson(x)));

String dogsRecordIdGetToJson(List<DogsRecordIdGet> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DogsRecordIdGet {
  int rid;
  int dogId;
  String clinicName;
  int vaccineType;
  String date;
  int status;
  String name;

  DogsRecordIdGet({
    required this.rid,
    required this.dogId,
    required this.clinicName,
    required this.vaccineType,
    required this.date,
    required this.status,
    required this.name,
  });

  factory DogsRecordIdGet.fromJson(Map<String, dynamic> json) =>
      DogsRecordIdGet(
        rid: json["rid"],
        dogId: json["dog_Id"],
        clinicName: json["clinicName"],
        vaccineType: json["vaccineType"],
        date: json["date"],
        status: json["status"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "rid": rid,
        "dog_Id": dogId,
        "clinicName": clinicName,
        "vaccineType": vaccineType,
        "date": date,
        "status": status,
        "name": name,
      };
}
