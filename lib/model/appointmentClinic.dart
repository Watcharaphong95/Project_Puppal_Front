import 'dart:convert';

AppointmentClinic appointmentClinicFromJson(String str) =>
    AppointmentClinic.fromJson(json.decode(str));

String appointmentClinicToJson(AppointmentClinic data) =>
    json.encode(data.toJson());

class AppointmentClinic {
  List<Datum> data;

  AppointmentClinic({
    required this.data,
  });

  factory AppointmentClinic.fromJson(Map<String, dynamic> json) =>
      AppointmentClinic(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  int dogId;
  String generalUserEmail;
  DateTime latestDate; // เปลี่ยนชื่อจาก date เป็น latestDate
  String? vaccines; // เปลี่ยนจาก vaccine เป็น vaccines

  Datum({
    required this.dogId,
    required this.generalUserEmail,
    required this.latestDate,
    this.vaccines,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        dogId: json["dogId"] ?? 0,
        generalUserEmail: (json["general_user_email"] ?? '').toString(),
        latestDate: json["latest_date"] != null
            ? DateTime.parse(json["latest_date"])
            : DateTime.now(),
        vaccines: (json["vaccines"] ?? '-').toString(),
      );

  Map<String, dynamic> toJson() => {
        "dogId": dogId,
        "general_user_email": generalUserEmail,
        "latest_date": latestDate.toIso8601String(),
        "vaccines": vaccines,
      };
}
