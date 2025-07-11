// To parse this JSON data, do
//
//     final clinicSearch = clinicSearchFromJson(jsonString);

import 'dart:convert';

ClinicSearch clinicSearchFromJson(String str) =>
    ClinicSearch.fromJson(json.decode(str));

String clinicSearchToJson(ClinicSearch data) => json.encode(data.toJson());

class ClinicSearch {
  String email;
  String word;
  String date;

  ClinicSearch({
    required this.email,
    required this.word,
    required this.date,
  });

  factory ClinicSearch.fromJson(Map<String, dynamic> json) => ClinicSearch(
        email: json["email"],
        word: json["word"],
        date: json["date"],
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "word": word,
        "date": date,
      };
}
