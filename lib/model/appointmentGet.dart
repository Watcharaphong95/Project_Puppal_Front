// To parse this JSON data, do
//
//     final appointmentGetDogClinicData = appointmentGetDogClinicDataFromJson(jsonString);

import 'dart:convert';

AppointmentGetDogClinicData appointmentGetDogClinicDataFromJson(String str) =>
    AppointmentGetDogClinicData.fromJson(json.decode(str));

String appointmentGetDogClinicDataToJson(AppointmentGetDogClinicData data) =>
    json.encode(data.toJson());

class AppointmentGetDogClinicData {
  List<Dog> dogs;
  List<Appointment> appointments;
  List<Clinic> clinics;

  AppointmentGetDogClinicData({
    required this.dogs,
    required this.appointments,
    required this.clinics,
  });

  factory AppointmentGetDogClinicData.fromJson(Map<String, dynamic> json) =>
      AppointmentGetDogClinicData(
        dogs: List<Dog>.from(json["dogs"].map((x) => Dog.fromJson(x))),
        appointments: List<Appointment>.from(
            json["appointments"].map((x) => Appointment.fromJson(x))),
        clinics:
            List<Clinic>.from(json["clinics"].map((x) => Clinic.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "dogs": List<dynamic>.from(dogs.map((x) => x.toJson())),
        "appointments": List<dynamic>.from(appointments.map((x) => x.toJson())),
        "clinics": List<dynamic>.from(clinics.map((x) => x.toJson())),
      };
}

class Appointment {
  int aid;
  int dogId;
  String generalUserEmail;
  String vaccine;
  String date;

  Appointment({
    required this.aid,
    required this.dogId,
    required this.generalUserEmail,
    required this.vaccine,
    required this.date,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
        aid: json["aid"],
        dogId: json["dogId"],
        generalUserEmail: json["general_user_email"],
        vaccine: json["vaccine"],
        date: json["date"],
      );

  Map<String, dynamic> toJson() => {
        "aid": aid,
        "dogId": dogId,
        "general_user_email": generalUserEmail,
        "vaccine": vaccine,
        "date": date,
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

class Dog {
  int dogId;
  String userEmail;
  String name;
  String breed;
  String gender;
  String color;
  String defect;
  String birthday;
  String congentialDisease;
  int sterilization;
  String hair;
  String image;

  Dog({
    required this.dogId,
    required this.userEmail,
    required this.name,
    required this.breed,
    required this.gender,
    required this.color,
    required this.defect,
    required this.birthday,
    required this.congentialDisease,
    required this.sterilization,
    required this.hair,
    required this.image,
  });

  factory Dog.fromJson(Map<String, dynamic> json) => Dog(
        dogId: json["dogId"],
        userEmail: json["user_email"],
        name: json["name"],
        breed: json["breed"],
        gender: json["gender"],
        color: json["color"],
        defect: json["defect"],
        birthday: json["birthday"],
        congentialDisease: json["congentialDisease"],
        sterilization: json["sterilization"],
        hair: json["Hair"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "dogId": dogId,
        "user_email": userEmail,
        "name": name,
        "breed": breed,
        "gender": gender,
        "color": color,
        "defect": defect,
        "birthday": birthday,
        "congentialDisease": congentialDisease,
        "sterilization": sterilization,
        "Hair": hair,
        "image": image,
      };
}
