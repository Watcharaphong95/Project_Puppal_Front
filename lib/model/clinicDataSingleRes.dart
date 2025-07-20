// To parse this JSON data, do
//
//     final clinicDataSingleResponse = clinicDataSingleResponseFromJson(jsonString);

import 'dart:convert';

ClinicDataSingleResponse clinicDataSingleResponseFromJson(String str) =>
    ClinicDataSingleResponse.fromJson(json.decode(str));

String clinicDataSingleResponseToJson(ClinicDataSingleResponse data) =>
    json.encode(data.toJson());

class ClinicDataSingleResponse {
  Clinic clinic;
  List<Doctor> doctors;

  ClinicDataSingleResponse({
    required this.clinic,
    required this.doctors,
  });

  factory ClinicDataSingleResponse.fromJson(Map<String, dynamic> json) =>
      ClinicDataSingleResponse(
        clinic: Clinic.fromJson(json["clinic"]),
        doctors:
            List<Doctor>.from(json["doctors"].map((x) => Doctor.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "clinic": clinic.toJson(),
        "doctors": List<dynamic>.from(doctors.map((x) => x.toJson())),
      };
}

class Clinic {
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
  dynamic fcmToken;

  Clinic({
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
    required this.fcmToken,
  });

  factory Clinic.fromJson(Map<String, dynamic> json) => Clinic(
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
        fcmToken: json["fcmToken"],
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
        "fcmToken": fcmToken,
      };
}

class Doctor {
  String careerNo;
  String name;
  String image;
  List<String> specialties;

  Doctor({
    required this.careerNo,
    required this.name,
    required this.image,
    required this.specialties,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) => Doctor(
        careerNo: json["careerNo"],
        name: json["name"],
        image: json["image"],
        specialties: List<String>.from(json["specialties"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "careerNo": careerNo,
        "name": name,
        "image": image,
        "specialties": List<dynamic>.from(specialties.map((x) => x)),
      };
}
