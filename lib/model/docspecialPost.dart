// To parse this JSON data, do
//
//     final docSpecialPost = docSpecialPostFromJson(jsonString);

import 'dart:convert';

List<DocSpecialPost> docSpecialPostFromJson(String str) =>
    List<DocSpecialPost>.from(
        json.decode(str).map((x) => DocSpecialPost.fromJson(x)));

String docSpecialPostToJson(List<DocSpecialPost> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DocSpecialPost {
  String doctorId;
  int specialId;

  DocSpecialPost({
    required this.doctorId,
    required this.specialId,
  });

  factory DocSpecialPost.fromJson(Map<String, dynamic> json) => DocSpecialPost(
        doctorId: json["doctorID"],
        specialId: json["specialID"],
      );

  Map<String, dynamic> toJson() => {
        "doctorID": doctorId,
        "specialID": specialId,
      };
}
