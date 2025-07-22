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
  int numPerTime;
  String? fcmToken;
  String weekdays;
  String open;
  String close;
  List<DateTime> specialDate;
  double distanceKm;
  bool toDayOpen;
  String distance;
  int special;
  int full;
  List<String> specialties;

  ClinicSearchResponse({
    required this.userEmail,
    required this.name,
    required this.phone,
    required this.address,
    required this.lat,
    required this.lng,
    required this.image,
    required this.numPerTime,
    required this.fcmToken,
    required this.weekdays,
    required this.open,
    required this.close,
    required this.specialDate,
    required this.distanceKm,
    required this.toDayOpen,
    required this.distance,
    required this.special,
    required this.full,
    required this.specialties,
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
        numPerTime: json["numPerTime"],
        fcmToken: json["fcmToken"],
        weekdays: json["weekdays"],
        open: json["open"],
        close: json["close"],
        specialDate: List<DateTime>.from(
            json["special_date"].map((x) => DateTime.parse(x))),
        distanceKm: json["distanceKm"]?.toDouble(),
        toDayOpen: json["toDayOpen"],
        distance: json["distance"],
        special: json["special"],
        full: json["full"],
        specialties: List<String>.from(json["specialties"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "user_email": userEmail,
        "name": name,
        "phone": phone,
        "address": address,
        "lat": lat,
        "lng": lng,
        "image": image,
        "numPerTime": numPerTime,
        "fcmToken": fcmToken,
        "weekdays": weekdays,
        "open": open,
        "close": close,
        "special_date": List<dynamic>.from(specialDate.map((x) =>
            "${x.year.toString().padLeft(4, '0')}-${x.month.toString().padLeft(2, '0')}-${x.day.toString().padLeft(2, '0')}")),
        "distanceKm": distanceKm,
        "toDayOpen": toDayOpen,
        "distance": distance,
        "special": special,
        "full": full,
        "specialties": List<dynamic>.from(specialties.map((x) => x)),
      };
}
