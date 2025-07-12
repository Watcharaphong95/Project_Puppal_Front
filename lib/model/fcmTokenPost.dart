// To parse this JSON data, do
//
//     final fcmTokenPost = fcmTokenPostFromJson(jsonString);

import 'dart:convert';

FcmTokenPost fcmTokenPostFromJson(String str) =>
    FcmTokenPost.fromJson(json.decode(str));

String fcmTokenPostToJson(FcmTokenPost data) => json.encode(data.toJson());

class FcmTokenPost {
  String userEmail;
  String fcmToken;

  FcmTokenPost({
    required this.userEmail,
    required this.fcmToken,
  });

  factory FcmTokenPost.fromJson(Map<String, dynamic> json) => FcmTokenPost(
        userEmail: json["user_email"],
        fcmToken: json["fcmToken"],
      );

  Map<String, dynamic> toJson() => {
        "user_email": userEmail,
        "fcmToken": fcmToken,
      };
}
