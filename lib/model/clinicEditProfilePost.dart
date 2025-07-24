// To parse this JSON data, do
//
//     final clinicEditProfilePost = clinicEditProfilePostFromJson(jsonString);

import 'dart:convert';

List<ClinicEditProfilePost> clinicEditProfilePostFromJson(String str) =>
    List<ClinicEditProfilePost>.from(
        json.decode(str).map((x) => ClinicEditProfilePost.fromJson(x)));

String clinicEditProfilePostToJson(List<ClinicEditProfilePost> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ClinicEditProfilePost {
  String userEmail;
  String name;
  String phone;
  String address;
  String lat;
  String lng;
  String image;
  int numPerTime;

  ClinicEditProfilePost({
    required this.userEmail,
    required this.name,
    required this.phone,
    required this.address,
    required this.lat,
    required this.lng,
    required this.image,
    required this.numPerTime,
  });

  factory ClinicEditProfilePost.fromJson(Map<String, dynamic> json) =>
      ClinicEditProfilePost(
        userEmail: json["user_email"],
        name: json["name"],
        phone: json["phone"],
        address: json["address"],
        lat: json["lat"],
        lng: json["lng"],
        image: json["image"],
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
        "numPerTime": numPerTime,
      };
}
