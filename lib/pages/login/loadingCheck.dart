import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/model/fcmTokenPost.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicMain.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalMain.dart';
import 'package:puppal_application/pages/login/index.dart';
import 'package:http/http.dart' as http;

class LoadingcheckPage extends StatefulWidget {
  const LoadingcheckPage({super.key});

  @override
  State<LoadingcheckPage> createState() => _LoadingcheckPageState();
}

class _LoadingcheckPageState extends State<LoadingcheckPage> {
  final box = GetStorage();

  String url = '';

  @override
  void initState() {
    // box.erase();
    // log(box.read('type').toString());
    init();
    checkLogin();
    super.initState();
  }

  void init() async {
    await Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
    });
    if (box.read('email') != null) {
      await updateFcm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<void> checkLogin() async {
    await Future.delayed(Duration(seconds: 1));
    if (box.read('email') == null) {
      Get.to(() => IndexPage());
    } else {
      if (box.read('type') == 'general') {
        Get.offAll(() => GeneralmainPage());
      } else {
        Get.offAll(() => ClinicmainPage());
      }
    }
  }

  Future<void> updateFcm() async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    FcmTokenPost token =
        FcmTokenPost(userEmail: box.read('email'), fcmToken: fcmToken!);

    var tokenUpdate = await http.put(
      Uri.parse("$url/user/fcmToken"),
      headers: {"Content-Type": "application/json; charset=utf-8"},
      body: fcmTokenPostToJson(token),
    );
  }
}
