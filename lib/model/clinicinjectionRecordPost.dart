// To parse this JSON data, do
//
//     final clinicinjectionRecordPost = clinicinjectionRecordPostFromJson(jsonString);

import 'dart:convert';

List<ClinicinjectionRecordPost> clinicinjectionRecordPostFromJson(String str) =>
    List<ClinicinjectionRecordPost>.from(
        json.decode(str).map((x) => ClinicinjectionRecordPost.fromJson(x)));

String clinicinjectionRecordPostToJson(List<ClinicinjectionRecordPost> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ClinicinjectionRecordPost {
  int oldAppointmentAid;
  int nextAppointmentAid;
  String clinicEmail;
  String vaccine;
  DateTime date;
  String vaccineLabel;
  int type;

  ClinicinjectionRecordPost({
    required this.oldAppointmentAid,
    required this.nextAppointmentAid,
    required this.clinicEmail,
    required this.vaccine,
    required this.date,
    required this.vaccineLabel,
    required this.type,
  });

  factory ClinicinjectionRecordPost.fromJson(Map<String, dynamic> json) =>
      ClinicinjectionRecordPost(
        oldAppointmentAid: json["oldAppointment_aid"],
        nextAppointmentAid: json["nextAppointment_aid"],
        clinicEmail: json["clinic_email"],
        vaccine: json["vaccine"],
        date: DateTime.parse(json["date"]),
        vaccineLabel: json["vaccine_label"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "oldAppointment_aid": oldAppointmentAid,
        "nextAppointment_aid": nextAppointmentAid,
        "clinic_email": clinicEmail,
        "vaccine": vaccine,
        "date": date.toIso8601String(),
        "vaccine_label": vaccineLabel,
        "type": type,
      };
}
