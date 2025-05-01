import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:puppal_application/pages/register/registerClinic/registerClinic.dart';
import 'package:puppal_application/pages/register/registerClinic/registerClinicGoogle.dart';
import 'package:puppal_application/pages/register/registerGeneral/registerUser.dart';
import 'package:puppal_application/pages/register/registerGeneral/registerUserGoogle.dart';

class RegistertypePage extends StatefulWidget {
  const RegistertypePage({super.key});

  @override
  State<RegistertypePage> createState() => _RegistertypePageState();
}

class _RegistertypePageState extends State<RegistertypePage> {
  late double screenWidth;
  late double screenHeight;

  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SizedBox(
        width: screenWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                      SizedBox(
                        width: screenWidth * 0.65,
                        child: Text(
                          'สมัครเข้าใช้งานพื่อ แชร์สุนัขของคุณกับผู้ใช้คนอื่นๆ ค้นหาคลินิคใกล้คุณ และทำการจองวันฉีดวัคซีน',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
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
                        SizedBox(
                          width: screenWidth * 0.65,
                          child: Text(
                            'สมัครเข้าใช้งานเพื่อ แชร์คลินิคของ ท่านให้กับเจ้าของสุนัข และทำการรับการขอจองวันฉีดวัคซีนจากผู้ใช้',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void clinicType() {
    if (box.read('email') != '') {
      Get.to(() => RegisterclinicgooglePage());
    } else {
      Get.to(() => RegisterclinicPage());
    }
  }

  void userType() {
    if (box.read('email') != '') {
      Get.to(() => RegisterusergooglePage());
    } else {
      Get.to(() => RegisteruserPage());
    }
  }
}
