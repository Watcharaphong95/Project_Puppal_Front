class ReserveAppointmentFireStore {
  final String docId; // Firestore document ID
  final DateTime date;
  final String dogId;
  final String clinicEmail;
  final String generalEmail;
  final int type;
  final int status;
  final String appointmentAid;

  ReserveAppointmentFireStore({
    required this.docId,
    required this.date,
    required this.dogId,
    required this.clinicEmail,
    required this.generalEmail,
    required this.type,
    required this.status,
    required this.appointmentAid,
  });

  factory ReserveAppointmentFireStore.fromJson(
      Map<String, dynamic> json, String docId) {
    return ReserveAppointmentFireStore(
      docId: docId,
      date: DateTime.parse(json['date']),
      dogId: json['dogDogId'].toString(),
      clinicEmail: json['clinicEmail'],
      generalEmail: json['generalEmail'],
      type: json['type'],
      status: json['status'],
      appointmentAid: json['appointmentAid'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'dogDogId': dogId,
      'clinicEmail': clinicEmail,
      'generalEmail': generalEmail,
      'type': type,
      'status': status,
      'appointmentAid': appointmentAid,
    };
  }
}
