import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/model/userPost.dart';
import 'package:puppal_application/pages/clinicMain.dart';
import 'package:puppal_application/pages/generalMain.dart';
import 'package:puppal_application/pages/login.dart';
import 'package:puppal_application/pages/loginTypeSelect.dart';
import 'package:puppal_application/pages/registerType.dart';
import 'package:http/http.dart' as http;

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  late double screenWidth;
  late double screenHeight;

  String url = '';

  bool isLoading = true;

  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    await Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
    });
    await checkLogout();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/indexBg.png'),
                fit: BoxFit.cover)),
        width: screenWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, screenHeight * 0.1, 0, 0),
              child: Text('PUPPAL',
                  style: TextStyle(
                      fontSize: 65,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 5,
                      fontStyle: FontStyle.italic)),
            ),
            SizedBox(
              width: screenWidth * 0.9,
              height: screenHeight * 0.4,
              child: Card(
                elevation: 5,
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.775),
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            SizedBox(
                              width: screenWidth * 0.7,
                              child: Text(
                                'จองฉีดยาให้กับสุนัขของคุณ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 32, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 7.5),
                              child: SizedBox(
                                width: screenWidth * 0.75,
                                child: ElevatedButton(
                                    onPressed: loginButton,
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      backgroundColor: Color(0xFF916b44),
                                    ),
                                    child: Text(
                                      'ล็อกอิน',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    )),
                              ),
                            ),
                            SizedBox(
                              width: screenWidth * 0.75,
                              child: ElevatedButton(
                                  onPressed: googleLoginButton,
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/googleLoginIcon.png',
                                        width: 30,
                                        height: 30,
                                      ),
                                      Text(
                                        ' เข้าสู่ระบบโดย Google ',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ],
                                  )),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('คุณมีบัญชีผู้ใช้หรือยัง?'),
                                TextButton(
                                    onPressed: registerButton,
                                    child: Text(
                                      'สมัคร',
                                      style: TextStyle(
                                          color: Colors.black,
                                          decoration: TextDecoration.underline),
                                    ))
                              ],
                            )
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void registerButton() {
    Get.to(() => RegistertypePage());
  }

  void googleLoginButton() {}

  void loginButton() {
    Get.to(() => LoginPage());
  }

  Future<void> checkLogout() async {
    if (box.read('email') != "") {
      var res = await http.get(Uri.parse("$url/user/${box.read('email')}"));
      if (res.statusCode == 200) {
        final user = userPostFromJson(res.body);
        if (user.general == 1 && user.clinic == 1) {
          Get.to(() => LogintypeselectPage());
        } else if (user.general == 1) {
          Get.to(() => GeneralmainPage());
        } else if (user.clinic == 1) {
          Get.to(() => ClinicmainPage());
        }
      }
    }
  }
}
