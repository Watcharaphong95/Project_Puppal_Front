import 'package:cloud_firestore/cloud_firestore.dart';

class NotifyModel {
  final String senderEmail;
  final String receiverEmail;
  final String message;
  final DateTime createAt;

  NotifyModel({
    required this.senderEmail,
    required this.receiverEmail,
    required this.message,
    required this.createAt,
  });

  factory NotifyModel.fromMap(Map<String, dynamic> map) {
    return NotifyModel(
      senderEmail: map['senderEmail'] ?? '',
      receiverEmail: map['receiverEmail'] ?? '',
      message: map['message'] ?? '',
      createAt: (map['createAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderEmail': senderEmail,
      'receiverEmail': receiverEmail,
      'message': message,
      'createAt': createAt,
    };
  }
}
