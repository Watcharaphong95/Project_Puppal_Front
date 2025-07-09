// To parse this JSON data, do
//
//     final appointmentGetEmail = appointmentGetEmailFromJson(jsonString);

import 'dart:convert';

List<AppointmentGetEmail> appointmentGetEmailFromJson(String str) =>
    List<AppointmentGetEmail>.from(
        json.decode(str).map((x) => AppointmentGetEmail.fromJson(x)));

String appointmentGetEmailToJson(List<AppointmentGetEmail> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AppointmentGetEmail {
  DateTime date;
  List<Dog> dogs;

  AppointmentGetEmail({
    required this.date,
    required this.dogs,
  });

  factory AppointmentGetEmail.fromJson(Map<String, dynamic> json) =>
      AppointmentGetEmail(
        date: DateTime.parse(json["date"]),
        dogs: List<Dog>.from(json["dogs"].map((x) => Dog.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "date":
            "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "dogs": List<dynamic>.from(dogs.map((x) => x.toJson())),
      };
}

class Dog {
  int? reserveId;
  int? aid;
  int status;
  int dogId;
  String name;
  String image;
  String birthday;
  List<String> vaccines;
  String time;
  String clinicName;
  String clinicImage;
  String clinicPhone;
  String clinicLat;
  String clinicLng;

  Dog({
    required this.reserveId,
    required this.aid,
    required this.status,
    required this.dogId,
    required this.name,
    required this.image,
    required this.birthday,
    required this.vaccines,
    required this.time,
    required this.clinicName,
    required this.clinicImage,
    required this.clinicPhone,
    required this.clinicLat,
    required this.clinicLng,
  });

  factory Dog.fromJson(Map<String, dynamic> json) => Dog(
        reserveId: json["reserveID"],
        aid: json["aid"],
        status: json["status"],
        dogId: json["dogId"],
        name: json["name"],
        image: json["image"],
        birthday: json["birthday"],
        vaccines: List<String>.from(json["vaccines"].map((x) => x)),
        time: json["time"],
        clinicName: json["clinicName"],
        clinicImage: json["clinicImage"],
        clinicPhone: json["clinicPhone"],
        clinicLat: json["clinicLat"],
        clinicLng: json["clinicLng"],
      );

  Map<String, dynamic> toJson() => {
        "reserveID": reserveId,
        "aid": aid,
        "status": status,
        "dogId": dogId,
        "name": name,
        "image": image,
        "birthday": birthday,
        "vaccines": List<dynamic>.from(vaccines.map((x) => x)),
        "time": time,
        "clinicName": clinicName,
        "clinicImage": clinicImage,
        "clinicPhone": clinicPhone,
        "clinicLat": clinicLat,
        "clinicLng": clinicLng,
      };
}
