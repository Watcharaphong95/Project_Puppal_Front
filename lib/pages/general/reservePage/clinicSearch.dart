import 'dart:developer';

import 'package:flutter/material.dart';

class ClinicsearchPage extends StatefulWidget {
  final int dogId;
  const ClinicsearchPage({super.key, required this.dogId});

  @override
  State<ClinicsearchPage> createState() => _ClinicsearchPageState();
}

class _ClinicsearchPageState extends State<ClinicsearchPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    log(widget.dogId.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(),
    );
  }
}
