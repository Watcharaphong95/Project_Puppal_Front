// To parse this JSON data, do
//
//     final dogAppointmentEmailGet = dogAppointmentEmailGetFromJson(jsonString);

import 'dart:convert';

List<DogAppointmentEmailGet> dogAppointmentEmailGetFromJson(String str) =>
    List<DogAppointmentEmailGet>.from(
        json.decode(str).map((x) => DogAppointmentEmailGet.fromJson(x)));

String dogAppointmentEmailGetToJson(List<DogAppointmentEmailGet> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DogAppointmentEmailGet {
  int dogId;
  String name;
  String image;
  List<NextAppointment> nextAppointments;
  String age;

  DogAppointmentEmailGet({
    required this.dogId,
    required this.name,
    required this.image,
    required this.nextAppointments,
    required this.age,
  });

  factory DogAppointmentEmailGet.fromJson(Map<String, dynamic> json) =>
      DogAppointmentEmailGet(
        dogId: json["dogId"],
        name: json["name"],
        image: json["image"],
        nextAppointments: List<NextAppointment>.from(
            json["nextAppointments"].map((x) => NextAppointment.fromJson(x))),
        age: json["age"],
      );

  Map<String, dynamic> toJson() => {
        "dogId": dogId,
        "name": name,
        "image": image,
        "nextAppointments":
            List<dynamic>.from(nextAppointments.map((x) => x.toJson())),
        "age": age,
      };
}

class NextAppointment {
  String vaccine;
  String date;

  NextAppointment({
    required this.vaccine,
    required this.date,
  });

  factory NextAppointment.fromJson(Map<String, dynamic> json) =>
      NextAppointment(
        vaccine: json["vaccine"],
        date: json["date"],
      );

  Map<String, dynamic> toJson() => {
        "vaccine": vaccine,
        "date": date,
      };
}
