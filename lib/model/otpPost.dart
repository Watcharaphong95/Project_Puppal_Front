// To parse this JSON data, do
//
//     final otpPost = otpPostFromJson(jsonString);

import 'dart:convert';

OtpPost otpPostFromJson(String str) => OtpPost.fromJson(json.decode(str));

String otpPostToJson(OtpPost data) => json.encode(data.toJson());

class OtpPost {
  String userEmail;
  String otp;
  String expire;

  OtpPost({
    required this.userEmail,
    required this.otp,
    required this.expire,
  });

  factory OtpPost.fromJson(Map<String, dynamic> json) => OtpPost(
        userEmail: json["user_email"],
        otp: json["otp"],
        expire: json["expire"],
      );

  Map<String, dynamic> toJson() => {
        "user_email": userEmail,
        "otp": otp,
        "expire": expire,
      };
}
