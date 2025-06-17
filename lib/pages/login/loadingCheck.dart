import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicMain.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalMain.dart';
import 'package:puppal_application/pages/login/index.dart';

class LoadingcheckPage extends StatefulWidget {
  const LoadingcheckPage({super.key});

  @override
  State<LoadingcheckPage> createState() => _LoadingcheckPageState();
}

class _LoadingcheckPageState extends State<LoadingcheckPage> {
  final box = GetStorage();

  @override
  void initState() {
    // box.erase();
    checkLogin();
    super.initState();
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
}
