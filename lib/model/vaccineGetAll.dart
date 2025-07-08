// To parse this JSON data, do
//
//     final vaccineGetAll = vaccineGetAllFromJson(jsonString);

import 'dart:convert';

List<VaccineGetAll> vaccineGetAllFromJson(String str) =>
    List<VaccineGetAll>.from(
        json.decode(str).map((x) => VaccineGetAll.fromJson(x)));

String vaccineGetAllToJson(List<VaccineGetAll> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class VaccineGetAll {
  int vid;
  String name;
  String description;
  int startAge;
  int numDose;
  int doseWeek;
  int boostWeek;

  VaccineGetAll({
    required this.vid,
    required this.name,
    required this.description,
    required this.startAge,
    required this.numDose,
    required this.doseWeek,
    required this.boostWeek,
  });

  factory VaccineGetAll.fromJson(Map<String, dynamic> json) => VaccineGetAll(
        vid: json["vid"],
        name: json["name"],
        description: json["description"],
        startAge: json["start_age"],
        numDose: json["num_dose"],
        doseWeek: json["dose_week"],
        boostWeek: json["boost_week"],
      );

  Map<String, dynamic> toJson() => {
        "vid": vid,
        "name": name,
        "description": description,
        "start_age": startAge,
        "num_dose": numDose,
        "dose_week": doseWeek,
        "boost_week": boostWeek,
      };
}
