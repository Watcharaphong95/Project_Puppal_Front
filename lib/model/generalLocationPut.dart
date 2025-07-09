// To parse this JSON data, do
//
//     final generalLocationPut = generalLocationPutFromJson(jsonString);

import 'dart:convert';

GeneralLocationPut generalLocationPutFromJson(String str) =>
    GeneralLocationPut.fromJson(json.decode(str));

String generalLocationPutToJson(GeneralLocationPut data) =>
    json.encode(data.toJson());

class GeneralLocationPut {
  String email;
  String lat;
  String lng;

  GeneralLocationPut({
    required this.email,
    required this.lat,
    required this.lng,
  });

  factory GeneralLocationPut.fromJson(Map<String, dynamic> json) =>
      GeneralLocationPut(
        email: json["email"],
        lat: json["lat"],
        lng: json["lng"],
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "lat": lat,
        "lng": lng,
      };
}
