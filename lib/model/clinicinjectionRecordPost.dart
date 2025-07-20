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
  int? oldAppointmentAid;
  int? nextAppointmentAid;
  String? clinicEmail;
  String doctorCareerNo;
  String vaccine;
  DateTime date;
  String vaccineLabel;
  int type;

  ClinicinjectionRecordPost({
    required this.oldAppointmentAid,
    required this.nextAppointmentAid,
    required this.clinicEmail,
    required this.doctorCareerNo,
    required this.vaccine,
    required this.date,
    required this.vaccineLabel,
    required this.type,
  });

  factory ClinicinjectionRecordPost.fromJson(Map<String, dynamic> json) =>
      ClinicinjectionRecordPost(
        oldAppointmentAid: json["oldAppointmentAid"],
        nextAppointmentAid: json["nextAppointmentAid"],
        clinicEmail: json["clinicEmail"],
        doctorCareerNo: json["doctorCareerNo"],
        vaccine: json["vaccine"],
        date: DateTime.parse(json["date"]),
        vaccineLabel: json["vaccine_label"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "oldAppointmentAid": oldAppointmentAid,
        "nextAppointmentAid": nextAppointmentAid,
        "clinicEmail": clinicEmail,
        "doctorCareerNo": doctorCareerNo,
        "vaccine": vaccine,
        "date":
            "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "vaccine_label": vaccineLabel,
        "type": type,
      };
}
