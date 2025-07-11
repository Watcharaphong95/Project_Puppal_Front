import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TestfirestorePage extends StatefulWidget {
  const TestfirestorePage({super.key});

  @override
  State<TestfirestorePage> createState() => _TestfirestorePageState();
}

class _TestfirestorePageState extends State<TestfirestorePage> {
  TextEditingController docCtl = TextEditingController();
  TextEditingController nameCtl = TextEditingController();
  TextEditingController messageCtl = TextEditingController();

  var db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          const Text('Document'),
          TextField(
            controller: docCtl,
          ),
          const Text('Name'),
          TextField(
            controller: nameCtl,
          ),
          const Text('Message'),
          TextField(
            controller: messageCtl,
          ),
          FilledButton(
              onPressed: () {
                // readData();
                var data = {
                  'name': nameCtl.text,
                  'message': messageCtl.text,
                  'createAt': DateTime.timestamp()
                };

                db.collection('reserve').doc(docCtl.text).set(data);
              },
              child: const Text('Add Data'))
        ],
      ),
    );
  }

  void readData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('reserve') // <-- replace with your collection
        .where('clinicEmail', isEqualTo: 'testBoth@gmail.com')
        .get();

    for (var doc in snapshot.docs) {
      log('Document ID: ${doc.id}');
      log('Data: ${doc.data()}');
    }
  }
}
