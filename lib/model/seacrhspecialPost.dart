// To parse this JSON data, do
//
//     final getSpecialDataPost = getSpecialDataPostFromJson(jsonString);

import 'dart:convert';

List<GetSpecialDataPost> getSpecialDataPostFromJson(String str) =>
    List<GetSpecialDataPost>.from(
        json.decode(str).map((x) => GetSpecialDataPost.fromJson(x)));

String getSpecialDataPostToJson(List<GetSpecialDataPost> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetSpecialDataPost {
  String specialName;
  int specialId;

  GetSpecialDataPost({
    required this.specialName,
    required this.specialId,
  });

  factory GetSpecialDataPost.fromJson(Map<String, dynamic> json) =>
      GetSpecialDataPost(
        specialName: json["specialName"],
        specialId: json["specialID"],
      );

  Map<String, dynamic> toJson() => {
        "specialName": specialName,
        "specialID": specialId,
      };
}
