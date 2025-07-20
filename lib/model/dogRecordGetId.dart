// To parse this JSON data, do
//
//     final dogsRecordIdGet = dogsRecordIdGetFromJson(jsonString);

import 'dart:convert';

List<DogsRecordIdGet> dogsRecordIdGetFromJson(String str) =>
    List<DogsRecordIdGet>.from(
        json.decode(str).map((x) => DogsRecordIdGet.fromJson(x)));

String dogsRecordIdGetToJson(List<DogsRecordIdGet> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DogsRecordIdGet {
  String dogName;
  String dogBreed;
  String dogGender;
  String dogColor;
  String dogDefect;
  String dogBirthday;
  String dogCongentialDisease;
  int dogSterilization;
  String dogHair;
  String dogImage;
  int rid;
  String injectionVaccine;
  String injectionDate;
  String vaccineLabel;
  int recordType;
  String careerNo;
  String doctorName;
  String doctorSurname;
  String doctorImage;
  String clinicEmail;
  String clinicName;
  String phone;
  String address;
  String open;
  String close;
  String clinicImage;
  int? oldAid;
  String? oldDate;
  String? oldVaccine;
  int? nextAid;
  String? nextDate;
  String? nextVaccine;

  DogsRecordIdGet({
    required this.dogName,
    required this.dogBreed,
    required this.dogGender,
    required this.dogColor,
    required this.dogDefect,
    required this.dogBirthday,
    required this.dogCongentialDisease,
    required this.dogSterilization,
    required this.dogHair,
    required this.dogImage,
    required this.rid,
    required this.injectionVaccine,
    required this.injectionDate,
    required this.vaccineLabel,
    required this.recordType,
    required this.careerNo,
    required this.doctorName,
    required this.doctorSurname,
    required this.doctorImage,
    required this.clinicEmail,
    required this.clinicName,
    required this.phone,
    required this.address,
    required this.open,
    required this.close,
    required this.clinicImage,
    required this.oldAid,
    required this.oldDate,
    required this.oldVaccine,
    required this.nextAid,
    required this.nextDate,
    required this.nextVaccine,
  });

  factory DogsRecordIdGet.fromJson(Map<String, dynamic> json) =>
      DogsRecordIdGet(
        dogName: json["dogName"],
        dogBreed: json["dogBreed"],
        dogGender: json["dogGender"],
        dogColor: json["dogColor"],
        dogDefect: json["dogDefect"],
        dogBirthday: json["dogBirthday"],
        dogCongentialDisease: json["dogCongentialDisease"],
        dogSterilization: json["dogSterilization"],
        dogHair: json["dogHair"],
        dogImage: json["dog_image"],
        rid: json["rid"],
        injectionVaccine: json["injectionVaccine"],
        injectionDate: json["injectionDate"],
        vaccineLabel: json["vaccine_label"],
        recordType: json["recordType"],
        careerNo: json["careerNo"],
        doctorName: json["doctorName"],
        doctorSurname: json["doctorSurname"],
        doctorImage: json["doctor_image"],
        clinicEmail: json["clinicEmail"],
        clinicName: json["clinicName"],
        phone: json["phone"],
        address: json["address"],
        open: json["open"],
        close: json["close"],
        clinicImage: json["clinic_image"],
        oldAid: json["old_aid"],
        oldDate: json["old_date"],
        oldVaccine: json["old_vaccine"],
        nextAid: json["next_aid"],
        nextDate: json["next_date"],
        nextVaccine: json["next_vaccine"],
      );

  Map<String, dynamic> toJson() => {
        "dogName": dogName,
        "dogBreed": dogBreed,
        "dogGender": dogGender,
        "dogColor": dogColor,
        "dogDefect": dogDefect,
        "dogBirthday": dogBirthday,
        "dogCongentialDisease": dogCongentialDisease,
        "dogSterilization": dogSterilization,
        "dogHair": dogHair,
        "dog_image": dogImage,
        "rid": rid,
        "injectionVaccine": injectionVaccine,
        "injectionDate": injectionDate,
        "vaccine_label": vaccineLabel,
        "recordType": recordType,
        "careerNo": careerNo,
        "doctorName": doctorName,
        "doctorSurname": doctorSurname,
        "doctor_image": doctorImage,
        "clinicEmail": clinicEmail,
        "clinicName": clinicName,
        "phone": phone,
        "address": address,
        "open": open,
        "close": close,
        "clinic_image": clinicImage,
        "old_aid": oldAid,
        "old_date": oldDate,
        "old_vaccine": oldVaccine,
        "next_aid": nextAid,
        "next_date": nextDate,
        "next_vaccine": nextVaccine,
      };
}
