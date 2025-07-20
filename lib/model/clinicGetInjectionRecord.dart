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
        data: List<Datum>.from(
          (json["data"] ?? []).map((x) => Datum.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  int? rid;
  int? oldAppointmentAid;
  int? nextAppointmentAid;
  String? clinicEmail;
  String? vaccine;
  DateTime? date;
  String? vaccineLabel;
  int? type;
  DateTime? injectionDateOnly;
  int? aid;
  int? dogId;
  String? generalUserEmail;

  Datum({
    this.rid,
    this.oldAppointmentAid,
    this.nextAppointmentAid,
    this.clinicEmail,
    this.vaccine,
    this.date,
    this.vaccineLabel,
    this.type,
    this.injectionDateOnly,
    this.aid,
    this.dogId,
    this.generalUserEmail,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        rid: json["rid"] as int?,
        oldAppointmentAid: json["oldAppointment_aid"] as int?,
        nextAppointmentAid: json["nextAppointment_aid"] as int?,
        clinicEmail: json["clinic_email"] as String?,
        vaccine: json["vaccine"] as String?,
        date: json["date"] != null ? DateTime.tryParse(json["date"]) : null,
        vaccineLabel: json["vaccine_label"] as String?,
        type: json["type"] as int?,
        injectionDateOnly: json["injection_date_only"] != null
            ? DateTime.tryParse(json["injection_date_only"])
            : null,
        aid: json["aid"] as int?,
        dogId: json["dogId"] as int?,
        generalUserEmail: json["general_user_email"] as String?,
      );

  Map<String, dynamic> toJson() => {
        "rid": rid,
        "oldAppointment_aid": oldAppointmentAid,
        "nextAppointment_aid": nextAppointmentAid,
        "clinic_email": clinicEmail,
        "vaccine": vaccine,
        "date": date?.toIso8601String(),
        "vaccine_label": vaccineLabel,
        "type": type,
        "injection_date_only": injectionDateOnly?.toIso8601String(),
        "aid": aid,
        "dogId": dogId,
        "general_user_email": generalUserEmail,
      };
}
