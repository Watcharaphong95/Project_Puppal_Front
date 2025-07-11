import 'package:cloud_firestore/cloud_firestore.dart';

class ReserveClinicFirebase {
  String? appointmentAid; // Nullable String
  String clinicEmail;
  DateTime date;
  String dogDogId;
  String generalEmail;
  int status;
  int type;
  String docId;

  ReserveClinicFirebase({
    this.appointmentAid, // nullable
    required this.clinicEmail,
    required this.date,
    required this.dogDogId,
    required this.generalEmail,
    required this.status,
    required this.type,
    required this.docId,
  });

  factory ReserveClinicFirebase.fromJson(
          Map<String, dynamic> json, String docId) =>
      ReserveClinicFirebase(
        appointmentAid: json["appointmentAid"]?.toString(), // อาจเป็น null
        clinicEmail: json["clinicEmail"] ?? '',
        date: json["date"] is Timestamp
            ? (json["date"] as Timestamp).toDate()
            : DateTime.tryParse(json["date"]?.toString() ?? '') ??
                DateTime.now(),
        dogDogId: json["dogDogId"]?.toString() ?? '',
        generalEmail: json["generalEmail"] ?? '',
        status: (json["status"] is int)
            ? json["status"]
            : int.tryParse(json["status"]?.toString() ?? '') ?? 0,
        type: (json["type"] is int)
            ? json["type"]
            : int.tryParse(json["type"]?.toString() ?? '') ?? 0,
        docId: docId,
      );

  Map<String, dynamic> toJson() => {
        "appointmentAid": appointmentAid,
        "clinicEmail": clinicEmail,
        "date": date.toIso8601String(),
        "dogDogId": dogDogId,
        "generalEmail": generalEmail,
        "status": status,
        "type": type,
      };
}
