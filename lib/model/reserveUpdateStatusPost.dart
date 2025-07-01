// To parse this JSON data, do
//
//     final reserveUpdateStatusPost = reserveUpdateStatusPostFromJson(jsonString);

import 'dart:convert';

List<ReserveUpdateStatusPost> reserveUpdateStatusPostFromJson(String str) =>
    List<ReserveUpdateStatusPost>.from(
        json.decode(str).map((x) => ReserveUpdateStatusPost.fromJson(x)));

String reserveUpdateStatusPostToJson(List<ReserveUpdateStatusPost> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ReserveUpdateStatusPost {
  int reserveId;
  int status;

  ReserveUpdateStatusPost({
    required this.reserveId,
    required this.status,
  });

  factory ReserveUpdateStatusPost.fromJson(Map<String, dynamic> json) =>
      ReserveUpdateStatusPost(
        reserveId: json["reserveID"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "reserveID": reserveId,
        "status": status,
      };
}
