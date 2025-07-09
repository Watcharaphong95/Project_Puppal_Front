import 'dart:developer';

import 'package:flutter/material.dart';

class ReserveinfoPage extends StatefulWidget {
  final int reserveId;

  const ReserveinfoPage({super.key, required this.reserveId});

  @override
  State<ReserveinfoPage> createState() => _ReserveinfoPageState();
}

class _ReserveinfoPageState extends State<ReserveinfoPage> {
  @override
  void initState() {
    log(widget.reserveId.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'รายละเอียดการจอง',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF916B44),
      ),
      body: Container(),
    );
  }
}
