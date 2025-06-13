// To parse this JSON data, do

//     final specialPost = specialPostFromJson(jsonString);

import 'dart:convert';

List<SpecialPost> specialPostFromJson(String str) => List<SpecialPost>.from(
    json.decode(str).map((x) => SpecialPost.fromJson(x)));

String specialPostToJson(List<SpecialPost> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SpecialPost {
  int specialId;
  String name;

  SpecialPost({
    required this.specialId,
    required this.name,
  });

  factory SpecialPost.fromJson(Map<String, dynamic> json) => SpecialPost(
        specialId: json["special_id"] ?? 0,
        name: json["name"] ?? '',
      );

  get length => null;

  Map<String, dynamic> toJson() => {
        "special_id": specialId,
        "name": name,
      };
}
