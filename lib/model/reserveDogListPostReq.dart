// To parse this JSON data, do
//
//     final reserveDoglistReq = reserveDoglistReqFromJson(jsonString);

import 'dart:convert';

ReserveDoglistReq reserveDoglistReqFromJson(String str) =>
    ReserveDoglistReq.fromJson(json.decode(str));

String reserveDoglistReqToJson(ReserveDoglistReq data) =>
    json.encode(data.toJson());

class ReserveDoglistReq {
  String email;
  String date;

  ReserveDoglistReq({
    required this.email,
    required this.date,
  });

  factory ReserveDoglistReq.fromJson(Map<String, dynamic> json) =>
      ReserveDoglistReq(
        email: json["email"],
        date: json["date"],
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "date": date,
      };
}
