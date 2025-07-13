// To parse this JSON data, do
//
//     final clinicGetInjectionRecord = clinicGetInjectionRecordFromJson(jsonString);

import 'dart:convert';

ClinicGetInjectionRecord clinicGetInjectionRecordFromJson(String str) =>
    ClinicGetInjectionRecord.fromJson(json.decode(str));

String clinicGetInjectionRecordToJson(ClinicGetInjectionRecord data) =>
    json.encode(data.toJson());

class ClinicGetInjectionRecord {
  List<Datum> data;

  ClinicGetInjectionRecord({
    required this.data,
  });

  factory ClinicGetInjectionRecord.fromJson(Map<String, dynamic> json) =>
      ClinicGetInjectionRecord(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  int rid;
  int oldAppointmentAid;
  int nextAppointmentAid;
  String clinicEmail;
  String vaccine;
  DateTime date;
  String vaccineLabel;
  int type;
  DateTime injectionDateOnly;
  int aid;
  int dogId;
  String generalUserEmail;

  Datum({
    required this.rid,
    required this.oldAppointmentAid,
    required this.nextAppointmentAid,
    required this.clinicEmail,
    required this.vaccine,
    required this.date,
    required this.vaccineLabel,
    required this.type,
    required this.injectionDateOnly,
    required this.aid,
    required this.dogId,
    required this.generalUserEmail,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        rid: json["rid"],
        oldAppointmentAid: json["oldAppointment_aid"],
        nextAppointmentAid: json["nextAppointment_aid"],
        clinicEmail: json["clinic_email"],
        vaccine: json["vaccine"],
        date: DateTime.parse(json["date"]),
        vaccineLabel: json["vaccine_label"],
        type: json["type"],
        injectionDateOnly: DateTime.parse(json["injection_date_only"]),
        aid: json["aid"],
        dogId: json["dogId"],
        generalUserEmail: json["general_user_email"],
      );

  Map<String, dynamic> toJson() => {
        "rid": rid,
        "oldAppointment_aid": oldAppointmentAid,
        "nextAppointment_aid": nextAppointmentAid,
        "clinic_email": clinicEmail,
        "vaccine": vaccine,
        "date": date.toIso8601String(),
        "vaccine_label": vaccineLabel,
        "type": type,
        "injection_date_only": injectionDateOnly.toIso8601String(),
        "aid": aid,
        "dogId": dogId,
        "general_user_email": generalUserEmail,
      };
}
