import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:puppal_application/pages/clinic/registerClinic/registerClinic.dart';
import 'package:puppal_application/pages/clinic/registerClinic/registerClinicGoogle.dart';
import 'package:puppal_application/pages/general/registerGeneral/registerUser.dart';
import 'package:puppal_application/pages/general/registerGeneral/registerUserGoogle.dart';

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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
          title: Text(
            'เลือกประเภทผู้ใช้ที่ต้องการสมัคร',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFF916B44)),
      body: PopScope(
        canPop: false,
        child: SingleChildScrollView(
          child: Container(
            // height: screenHeight * 0.9,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/indexBg.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                      Colors.white.withOpacity(0.2), BlendMode.dstATop)),
            ),
            width: screenWidth,
            child: Column(
              children: [
                SizedBox(
                  height: screenHeight * 0.025,
                ),
                GestureDetector(
                  onTap: userType,
                  child: Card(
                    color: Color(0xFF916B44),
                    child: Padding(
                      padding: const EdgeInsets.all(35.0),
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
                        padding: const EdgeInsets.all(35.0),
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
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, screenHeight * 0.05),
                  child: SizedBox(
                    width: screenWidth * 0.5,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.grey.shade400),
                        onPressed: () {
                          if (box.read('emailGoogleRegister') != null) {
                            box.remove('emailGoogleRegister');
                          }
                          Get.back();
                        },
                        child: Text(
                          'กลับ',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        )),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void clinicType() {
    if (box.read('emailGoogleRegister') != null) {
      Get.to(() => RegisterclinicgooglePage());
    } else {
      Get.to(() => RegisterclinicPage());
    }
  }

  void userType() {
    if (box.read('emailGoogleRegister') != null) {
      Get.to(() => RegisterusergooglePage());
    } else {
      Get.to(() => RegisteruserPage());
    }
  }
}
