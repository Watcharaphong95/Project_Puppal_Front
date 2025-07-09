// To parse this JSON data, do
//
//     final clinicSlotRes = clinicSlotResFromJson(jsonString);

import 'dart:convert';

ClinicSlotRes clinicSlotResFromJson(String str) =>
    ClinicSlotRes.fromJson(json.decode(str));

String clinicSlotResToJson(ClinicSlotRes data) => json.encode(data.toJson());

class ClinicSlotRes {
  String open;
  String close;
  int numPerTime;
  List<String> timeSlots;

  ClinicSlotRes({
    required this.open,
    required this.close,
    required this.numPerTime,
    required this.timeSlots,
  });

  factory ClinicSlotRes.fromJson(Map<String, dynamic> json) => ClinicSlotRes(
        open: json["open"],
        close: json["close"],
        numPerTime: json["numPerTime"],
        timeSlots: List<String>.from(json["timeSlots"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "open": open,
        "close": close,
        "numPerTime": numPerTime,
        "timeSlots": List<dynamic>.from(timeSlots.map((x) => x)),
      };
}
