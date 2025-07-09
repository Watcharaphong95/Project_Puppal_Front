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
  int reserveId;
  int appointmentAid;
  String vaccine;
  DateTime date;
  String vaccineLabel;

  ClinicinjectionRecordPost({
    required this.reserveId,
    required this.appointmentAid,
    required this.vaccine,
    required this.date,
    required this.vaccineLabel,
  });

  factory ClinicinjectionRecordPost.fromJson(Map<String, dynamic> json) =>
      ClinicinjectionRecordPost(
        reserveId: json["reserveID"],
        appointmentAid: json["appointment_aid"],
        vaccine: json["vaccine"],
        date: DateTime.parse(json["date"]),
        vaccineLabel: json["vaccine_label"],
      );

  Map<String, dynamic> toJson() => {
        "reserveID": reserveId,
        "appointment_aid": appointmentAid,
        "vaccine": vaccine,
        "date": date.toIso8601String(),
        "vaccine_label": vaccineLabel,
      };
}
