// To parse this JSON data, do
//
//     final clinicSearchResponse = clinicSearchResponseFromJson(jsonString);

import 'dart:convert';

List<ClinicSearchResponse> clinicSearchResponseFromJson(String str) =>
    List<ClinicSearchResponse>.from(
        json.decode(str).map((x) => ClinicSearchResponse.fromJson(x)));

String clinicSearchResponseToJson(List<ClinicSearchResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ClinicSearchResponse {
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
  double distanceKm;
  String distance;

  ClinicSearchResponse({
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
    required this.distanceKm,
    required this.distance,
  });

  factory ClinicSearchResponse.fromJson(Map<String, dynamic> json) =>
      ClinicSearchResponse(
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
        distanceKm: json["distanceKm"]?.toDouble(),
        distance: json["distance"],
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
        "distanceKm": distanceKm,
        "distance": distance,
      };
}
