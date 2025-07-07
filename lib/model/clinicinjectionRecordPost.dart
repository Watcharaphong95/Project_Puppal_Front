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
  int dog_Id;
  int reserveId;
  String vaccine;
  DateTime date;
  String vaccineLabel;

  ClinicinjectionRecordPost({
    required this.dog_Id,
    required this.reserveId,
    required this.vaccine,
    required this.date,
    required this.vaccineLabel,
  });

  factory ClinicinjectionRecordPost.fromJson(Map<String, dynamic> json) =>
      ClinicinjectionRecordPost(
        dog_Id: json["dog_Id"],
        reserveId: json["reserveID"],
        vaccine: json["vaccine"],
        date: DateTime.parse(json["date"]),
        vaccineLabel: json["vaccine_label"],
      );

  Map<String, dynamic> toJson() => {
        "dog_Id": dog_Id,
        "reserveID": reserveId,
        "vaccine": vaccine,
        "date": date.toIso8601String(),
        "vaccine_label": vaccineLabel,
      };
}
