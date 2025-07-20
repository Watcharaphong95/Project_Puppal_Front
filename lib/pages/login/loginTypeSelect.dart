import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/model/fcmTokenPost.dart';
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
    showLoadingDialog();
    var resClinic =
        await http.get(Uri.parse("$url/clinic/name/${box.read('email')}"));
    log(resClinic.body);
    box.write('clinicName', jsonDecode(resClinic.body)['name']);
    box.write('clinicImage', jsonDecode(resClinic.body)['image']);
    box.write('type', 'clinic');
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    FcmTokenPost token =
        FcmTokenPost(userEmail: box.read('email'), fcmToken: fcmToken!);

    var tokenUpdate = await http.put(
      Uri.parse("$url/user/fcmToken"),
      headers: {"Content-Type": "application/json; charset=utf-8"},
      body: fcmTokenPostToJson(token),
    );
    if (tokenUpdate.statusCode == 201) {
      log('Name ${box.read('clinicName')}');
      Get.offAll(() => ClinicmainPage());
    } else {
      Get.snackbar(
        'ข้อผิดพลาด',
        'กรุณาลองใหม่อีกครั้ง',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color.fromARGB(255, 211, 89, 89),
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        snackStyle: SnackStyle.FLOATING,
        isDismissible: true,
      );
      return;
    }
  }

  Future<void> userType() async {
    showLoadingDialog();
    var resGeneral =
        await http.get(Uri.parse("$url/general/name/${box.read('email')}"));
    box.write('type', 'general');
    box.write('generalName', jsonDecode(resGeneral.body)['username']);
    box.write('generalImage', jsonDecode(resGeneral.body)['image']);

    String? fcmToken = await FirebaseMessaging.instance.getToken();
    FcmTokenPost token =
        FcmTokenPost(userEmail: box.read('email'), fcmToken: fcmToken!);

    var tokenUpdate = await http.put(
      Uri.parse("$url/user/fcmToken"),
      headers: {"Content-Type": "application/json; charset=utf-8"},
      body: fcmTokenPostToJson(token),
    );
    if (tokenUpdate.statusCode == 201) {
      log('Name ${box.read('generalName')}');
      Get.offAll(() => GeneralmainPage());
    } else {
      Get.snackbar(
        'ข้อผิดพลาด',
        'กรุณาลองใหม่อีกครั้ง',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color.fromARGB(255, 211, 89, 89),
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        snackStyle: SnackStyle.FLOATING,
        isDismissible: true,
      );
      return;
    }
  }

  void showLoadingDialog({String? message}) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: const Color(0xFFF5F0E8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFD7CCC8),
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFFA1887F)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  message ?? "กำลังโหลด...",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFFA1887F),
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
