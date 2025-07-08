// To parse this JSON data, do
//
//     final clinicDataSingleResponse = clinicDataSingleResponseFromJson(jsonString);

import 'dart:convert';

ClinicDataSingleResponse clinicDataSingleResponseFromJson(String str) =>
    ClinicDataSingleResponse.fromJson(json.decode(str));

String clinicDataSingleResponseToJson(ClinicDataSingleResponse data) =>
    json.encode(data.toJson());

class ClinicDataSingleResponse {
  String userEmail;
  String name;
  String phone;
  String address;
  String lat;
  String lng;
  String image;
  String open;
  String close;
  int numPerTime;

  ClinicDataSingleResponse({
    required this.userEmail,
    required this.name,
    required this.phone,
    required this.address,
    required this.lat,
    required this.lng,
    required this.image,
    required this.open,
    required this.close,
    required this.numPerTime,
  });

  factory ClinicDataSingleResponse.fromJson(Map<String, dynamic> json) =>
      ClinicDataSingleResponse(
        userEmail: json["user_email"],
        name: json["name"],
        phone: json["phone"],
        address: json["address"],
        lat: json["lat"],
        lng: json["lng"],
        image: json["image"],
        open: json["open"],
        close: json["close"],
        numPerTime: json["numPerTime"],
      );

  Map<String, dynamic> toJson() => {
        "user_email": userEmail,
        "name": name,
        "phone": phone,
        "address": address,
        "lat": lat,
        "lng": lng,
        "image": image,
        "open": open,
        "close": close,
        "numPerTime": numPerTime,
      };
}
