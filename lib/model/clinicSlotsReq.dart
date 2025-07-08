// To parse this JSON data, do
//
//     final clinicSlotReq = clinicSlotReqFromJson(jsonString);

import 'dart:convert';

ClinicSlotReq clinicSlotReqFromJson(String str) =>
    ClinicSlotReq.fromJson(json.decode(str));

String clinicSlotReqToJson(ClinicSlotReq data) => json.encode(data.toJson());

class ClinicSlotReq {
  String generalEmail;
  String clinicEmail;
  String dogDogId;
  String? appointmentAid;
  String date;
  int status;
  int type;

  ClinicSlotReq({
    required this.generalEmail,
    required this.clinicEmail,
    required this.dogDogId,
    required this.appointmentAid,
    required this.date,
    required this.status,
    required this.type,
  });

  factory ClinicSlotReq.fromJson(Map<String, dynamic> json) => ClinicSlotReq(
        generalEmail: json["general_email"],
        clinicEmail: json["clinic_email"],
        dogDogId: json["dog_dogId"],
        appointmentAid: json["appointment_aid"],
        date: json["date"],
        status: json["status"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "general_email": generalEmail,
        "clinic_email": clinicEmail,
        "dog_dogId": dogDogId,
        "appointment_aid": appointmentAid,
        "date": date,
        "status": status,
        "type": type,
      };
}
