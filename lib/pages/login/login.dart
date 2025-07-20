import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/model/fcmTokenPost.dart';
import 'package:puppal_application/model/userPost.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicMain.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalMain.dart';
import 'package:puppal_application/pages/login/loginTypeSelect.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late double screenWidth;
  late double screenHeight;

  final box = GetStorage();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String url = '';

  TextEditingController emailCtl = TextEditingController();
  TextEditingController passwordCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
    });
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: screenHeight,
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
                child: Text('เข้าสู่ระบบ',
                    style: TextStyle(
                        fontSize: 65,
                        fontWeight: FontWeight.w900,
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
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'อีเมล',
                                  style: TextStyle(fontSize: 20),
                                ),
                                Material(
                                  elevation: 5,
                                  borderRadius: BorderRadius.circular(10),
                                  child: SizedBox(
                                    height: screenHeight * 0.055,
                                    child: TextField(
                                      controller: emailCtl,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'รหัสผ่าน',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    Material(
                                      elevation: 5,
                                      borderRadius: BorderRadius.circular(10),
                                      child: SizedBox(
                                        height: screenHeight * 0.055,
                                        child: TextField(
                                          controller: passwordCtl,
                                          obscureText: _obscurePassword,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide.none,
                                            ),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _obscurePassword
                                                    ? Icons.visibility_off
                                                    : Icons.visibility,
                                              ),
                                              onPressed: () {
                                                setState(() =>
                                                    _obscurePassword =
                                                        !_obscurePassword);
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: forgetPasswordButton,
                                    child: Text.rich(
                                      TextSpan(
                                        text: 'ลืมรหัสผ่าน?',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.lightBlue,
                                          decoration: TextDecoration.underline,
                                          decorationColor: Colors.lightBlue,
                                          decorationThickness: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: screenWidth * 0.5,
                                height: screenHeight * 0.055,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        backgroundColor: Color(0xFF916b44)),
                                    onPressed: loginButton,
                                    child: Text(
                                      'เข้าสู่ระบบ',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    )),
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> loginButton() async {
    if (emailCtl.text.trim().isEmpty ||
        passwordCtl.text.trim().isEmpty ||
        emailCtl.text.contains(' ') ||
        passwordCtl.text.contains(' ')) {
      Get.snackbar(
        'ข้อผิดพลาด',
        'กรุณากรอกข้อมูลให้ถูกต้อง ห้ามเว้นวรรค',
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

    UserPost req = UserPost(
        email: emailCtl.text,
        password: passwordCtl.text,
        general: null,
        clinic: null);

    var res = await http.post(
      Uri.parse("$url/user/login"),
      headers: {"Content-Type": "application/json; charset=utf-8"},
      body: userPostToJson(req),
    );

    if (res.statusCode == 200) {
      final user = userPostFromJson(res.body);
      box.write('email', user.email);
      if (user.general == 1 && user.clinic == 1) {
        Get.to(() => LogintypeselectPage());
      } else if (user.general == 1) {
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
      } else if (user.clinic == 1) {
        var resClinic =
            await http.get(Uri.parse("$url/clinic/name/${box.read('email')}"));
        box.write('type', 'clinic');
        box.write('clinicName', jsonDecode(resClinic.body)['name']);
        box.write('clinicImage', jsonDecode(resClinic.body)['image']);

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
    } else {
      Get.snackbar(
        'ข้อผิดพลาด',
        'กรุณากรอกอีเมลและรหัสผ่านที่ถูกต้อง',
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

  void forgetPasswordButton() {}
}
