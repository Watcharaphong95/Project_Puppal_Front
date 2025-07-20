// To parse this JSON data, do
//
//     final clinicDatuminjectionRecordPost = clinicDatuminjectionRecordPostFromJson(jsonString);

import 'dart:convert';

ClinicDatuminjectionRecordPost clinicDatuminjectionRecordPostFromJson(
        String str) =>
    ClinicDatuminjectionRecordPost.fromJson(json.decode(str));

String clinicDatuminjectionRecordPostToJson(
        ClinicDatuminjectionRecordPost data) =>
    json.encode(data.toJson());

class ClinicDatuminjectionRecordPost {
  List<Datum> data;

  ClinicDatuminjectionRecordPost({
    required this.data,
  });

  factory ClinicDatuminjectionRecordPost.fromJson(Map<String, dynamic> json) =>
      ClinicDatuminjectionRecordPost(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  int? oldAppointmentAid;
  int? nextAppointmentAid;
  String? clinicEmail;
  String doctorCareerNo;
  String vaccine;
  DateTime date;
  String vaccineLabel;
  int type;

  Datum({
    required this.oldAppointmentAid,
    required this.nextAppointmentAid,
    required this.clinicEmail,
    required this.doctorCareerNo,
    required this.vaccine,
    required this.date,
    required this.vaccineLabel,
    required this.type,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        oldAppointmentAid: json["oldAppointment_aid"],
        nextAppointmentAid: json["nextAppointment_aid"],
        clinicEmail: json["clinic_email"],
        doctorCareerNo: json["doctorCareerNo"],
        vaccine: json["vaccine"],
        date: DateTime.parse(json["date"]),
        vaccineLabel: json["vaccine_label"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "oldAppointment_aid": oldAppointmentAid,
        "nextAppointment_aid": nextAppointmentAid,
        "clinic_email": clinicEmail,
        "doctorCareerNo": doctorCareerNo,
        "vaccine": vaccine,
        "date": date.toIso8601String(),
        "vaccine_label": vaccineLabel,
        "type": type,
      };
}
