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
  int reserveId;
  int appointmentAid;
  String injectionVaccine;
  String vaccineLabel;
  String dogName;
  String clinicName;
  String appointmentVaccine;
  String appointmentDate;
  String injectionDate;

  DogsRecordIdGet({
    required this.rid,
    required this.reserveId,
    required this.appointmentAid,
    required this.injectionVaccine,
    required this.vaccineLabel,
    required this.dogName,
    required this.clinicName,
    required this.appointmentVaccine,
    required this.appointmentDate,
    required this.injectionDate,
  });

  factory DogsRecordIdGet.fromJson(Map<String, dynamic> json) =>
      DogsRecordIdGet(
        rid: json["rid"],
        reserveId: json["reserveID"],
        appointmentAid: json["appointment_aid"],
        injectionVaccine: json["injectionVaccine"],
        vaccineLabel: json["vaccine_label"],
        dogName: json["dogName"],
        clinicName: json["clinicName"],
        appointmentVaccine: json["appointmentVaccine"],
        appointmentDate: json["appointmentDate"],
        injectionDate: json["injectionDate"],
      );

  Map<String, dynamic> toJson() => {
        "rid": rid,
        "reserveID": reserveId,
        "appointment_aid": appointmentAid,
        "injectionVaccine": injectionVaccine,
        "vaccine_label": vaccineLabel,
        "dogName": dogName,
        "clinicName": clinicName,
        "appointmentVaccine": appointmentVaccine,
        "appointmentDate": appointmentDate,
        "injectionDate": injectionDate,
      };
}
