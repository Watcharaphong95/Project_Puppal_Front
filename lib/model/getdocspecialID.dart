// To parse this JSON data, do
//
//     final getDocSpecialIdPost = getDocSpecialIdPostFromJson(jsonString);

import 'dart:convert';

List<GetDocSpecialIdPost> getDocSpecialIdPostFromJson(String str) =>
    List<GetDocSpecialIdPost>.from(
        json.decode(str).map((x) => GetDocSpecialIdPost.fromJson(x)));

String getDocSpecialIdPostToJson(List<GetDocSpecialIdPost> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetDocSpecialIdPost {
  int docspecialId;
  String doctorId;
  int specialId;

  GetDocSpecialIdPost({
    required this.docspecialId,
    required this.doctorId,
    required this.specialId,
  });

  factory GetDocSpecialIdPost.fromJson(Map<String, dynamic> json) =>
      GetDocSpecialIdPost(
        docspecialId: json["docspecialID"],
        doctorId: json["doctorID"],
        specialId: json["specialID"],
      );

  Map<String, dynamic> toJson() => {
        "docspecialID": docspecialId,
        "doctorID": doctorId,
        "specialID": specialId,
      };
}
