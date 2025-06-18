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
  String name;
  int docspecialId;
  String doctorId;

  GetDocSpecialIdPost({
    required this.name,
    required this.docspecialId,
    required this.doctorId,
  });

  factory GetDocSpecialIdPost.fromJson(Map<String, dynamic> json) =>
      GetDocSpecialIdPost(
        name: json["name"],
        docspecialId: json["docspecialId"],
        doctorId: json["doctorId"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "docspecialId": docspecialId,
        "doctorId": doctorId,
      };
}
