import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReserveProvider with ChangeNotifier {
  late StreamSubscription<QuerySnapshot> _listener;
  List<Map<String, dynamic>> _reserveData = [];

  List<Map<String, dynamic>> get reserveData => _reserveData;

  void startListening() {
    _listener = FirebaseFirestore.instance
        .collection('reserve')
        .snapshots()
        .listen((snapshot) {
      _reserveData = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      log('Firestore listener received ${_reserveData.length} documents'); // <-- Log here
      for (var doc in _reserveData) {
        log('Doc data: $doc');
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _listener.cancel();
    super.dispose();
  }
}
