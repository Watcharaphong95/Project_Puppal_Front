import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/controller/registerGeneralCtl.dart';
import 'package:puppal_application/pages/index.dart';
import 'package:puppal_application/pages/userLocationSelect.dart';
import 'package:http/http.dart' as http;

class RegisteruserPage extends StatefulWidget {
  const RegisteruserPage({super.key});

  @override
  State<RegisteruserPage> createState() => _RegisteruserPageState();
}

class _RegisteruserPageState extends State<RegisteruserPage> {
  late double screenWidth;
  late double screenHeight;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String url = "";

  final controller = Get.find<RegisterGeneralCtl>();

  TextEditingController usernameCtl = TextEditingController();
  TextEditingController nameCtl = TextEditingController();
  TextEditingController surnameCtl = TextEditingController();
  TextEditingController emailCtl = TextEditingController();
  TextEditingController phoneCtl = TextEditingController();
  TextEditingController passwordCtl = TextEditingController();
  TextEditingController confirmPasswordCtl = TextEditingController();
  TextEditingController addressCtl = TextEditingController();

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
      appBar: AppBar(
        title: Text(
          'สมัครสมาชิกผู้ใช้ทั่วไป',
        ),
        backgroundColor: Color(0xFF916B44),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            spacing: 16,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ชื่อผู้ใช้',
                    style: TextStyle(fontSize: 20),
                  ),
                  Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: screenHeight * 0.055,
                      child: TextField(
                        controller: usernameCtl,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ชื่อ',
                    style: TextStyle(fontSize: 20),
                  ),
                  Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: screenHeight * 0.055,
                      child: TextField(
                        controller: nameCtl,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'นามสกุล',
                    style: TextStyle(fontSize: 20),
                  ),
                  Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: screenHeight * 0.055,
                      child: TextField(
                        controller: surnameCtl,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
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
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'เบอร์โทรศัพท์',
                    style: TextStyle(fontSize: 20),
                  ),
                  Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: screenHeight * 0.055,
                      child: TextField(
                        controller: phoneCtl,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
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
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(
                                  () => _obscurePassword = !_obscurePassword);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ยืนยันรหัสผ่าน',
                    style: TextStyle(fontSize: 20),
                  ),
                  Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: screenHeight * 0.055,
                      child: TextField(
                        controller: confirmPasswordCtl,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() => _obscureConfirmPassword =
                                  !_obscureConfirmPassword);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ที่อยู่',
                    style: TextStyle(fontSize: 20),
                  ),
                  Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: screenHeight * 0.055,
                      child: TextField(
                        controller: addressCtl,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
                          backgroundColor: Color(0xFF916b44)),
                      onPressed: userRegisterNextButton,
                      child: Text(
                        'ถัดไป',
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
    );
  }

  Future<void> userRegisterNextButton() async {
    // Assuming you have a confirmPasswordCtl for confirming the password.
    if (usernameCtl.text.trim().isEmpty ||
        nameCtl.text.trim().isEmpty ||
        surnameCtl.text.trim().isEmpty ||
        emailCtl.text.trim().isEmpty ||
        passwordCtl.text.trim().isEmpty ||
        phoneCtl.text.trim().isEmpty ||
        addressCtl.text.trim().isEmpty) {
      Get.snackbar(
        'ข้อผิดพลาด',
        'กรุณากรอกข้อมูลให้ครบถ้วน',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF8B5E3C),
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        snackStyle: SnackStyle.FLOATING,
        isDismissible: true,
      );
      return;
    }

// Phone number format check (simple 10-digit validation).
    RegExp phoneRegExp = RegExp(r'^[0-9]{10}$');
    if (!phoneRegExp.hasMatch(phoneCtl.text.trim())) {
      Get.snackbar(
        'ข้อผิดพลาด',
        'กรุณากรอกหมายเลขโทรศัพท์ที่ถูกต้อง',
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

// Password match check
    if (passwordCtl.text != confirmPasswordCtl.text) {
      Get.snackbar(
        'ข้อผิดพลาด',
        'รหัสผ่านไม่ตรงกัน',
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

    controller.username.value = usernameCtl.text;
    controller.name.value = nameCtl.text;
    controller.surname.value = surnameCtl.text;
    controller.email.value = emailCtl.text;
    controller.password.value = passwordCtl.text;
    controller.phone.value = phoneCtl.text;
    controller.address.value = addressCtl.text;

    // var res = await http.get(Uri.parse("$url/general/${emailCtl.text}"));

    var res = await http.get(Uri.parse("$url/user/${emailCtl.text}"));

    if (res.statusCode == 200) {
      Get.snackbar(
        'ข้อผิดพลาด',
        'อีเมลนี้เคยสมัครสมาชิกไปแล้ว\nกรุณาเข้าสู่ระบบหากเป็นคลินิกแล้วต้องการเปลี่ยนไปยังผู้ใช้ทั่วไป',
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
    } else {
      Get.to(() => UserlocationselectPage());
    }
    log(res.body);
  }
}
