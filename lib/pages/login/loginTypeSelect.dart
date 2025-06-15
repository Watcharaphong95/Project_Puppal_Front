import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicMain.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalMain.dart';
import 'package:http/http.dart' as http;

class LogintypeselectPage extends StatefulWidget {
  const LogintypeselectPage({super.key});

  @override
  State<LogintypeselectPage> createState() => _LogintypeselectPageState();
}

class _LogintypeselectPageState extends State<LogintypeselectPage> {
  late double screenWidth;
  late double screenHeight;

  String url = '';
  final box = GetStorage();

  @override
  void initState() {
    Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return PopScope(
      canPop: true,
      child: Scaffold(
        body: SizedBox(
          width: screenWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "กรุณาเลือกประเภทผู้ใช้เพื่อเข้าสู่ระบบ",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: screenHeight * 0.05),
              GestureDetector(
                onTap: userType,
                child: Card(
                  color: Color(0xFF916B44),
                  child: Padding(
                    padding: const EdgeInsets.all(50.0),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/userType.png',
                        ),
                        Text('เจ้าของสุนัข',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                child: GestureDetector(
                  onTap: clinicType,
                  child: Card(
                    color: Color(0xFF916B44),
                    child: Padding(
                      padding: const EdgeInsets.all(50.0),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/clinicType.png',
                          ),
                          Text('คลินิก',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> clinicType() async {
    var resClinic =
        await http.get(Uri.parse("$url/clinic/name/${box.read('email')}"));
    log(resClinic.body);
    box.write('clinicName', jsonDecode(resClinic.body)['name']);
    box.write('clinicImage', jsonDecode(resClinic.body)['image']);
    log('Name ${box.read('clinicName')}');
    Get.offAll(() => ClinicmainPage());
  }

  Future<void> userType() async {
    var resGeneral =
        await http.get(Uri.parse("$url/general/name/${box.read('email')}"));
    box.write('generalName', jsonDecode(resGeneral.body)['username']);
    box.write('generalImage', jsonDecode(resGeneral.body)['image']);
    log('Name ${box.read('generalName')}');
    Get.offAll(() => GeneralmainPage());
  }
}
