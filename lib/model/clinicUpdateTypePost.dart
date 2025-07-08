// To parse this JSON data, do
//
//     final clinicUpdateTypePost = clinicUpdateTypePostFromJson(jsonString);

import 'dart:convert';

List<ClinicUpdateTypePost> clinicUpdateTypePostFromJson(String str) =>
    List<ClinicUpdateTypePost>.from(
        json.decode(str).map((x) => ClinicUpdateTypePost.fromJson(x)));

String clinicUpdateTypePostToJson(List<ClinicUpdateTypePost> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ClinicUpdateTypePost {
  int reserveId;
  int type;

  ClinicUpdateTypePost({
    required this.reserveId,
    required this.type,
  });

  factory ClinicUpdateTypePost.fromJson(Map<String, dynamic> json) =>
      ClinicUpdateTypePost(
        reserveId: json["reserveID"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "reserveID": reserveId,
        "type": type,
      };
}
