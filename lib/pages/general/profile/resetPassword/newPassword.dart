import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/model/userPasswordChange.dart';
import 'package:http/http.dart' as http;
import 'package:puppal_application/pages/clinicAppNavigator.dart';
import 'package:puppal_application/pages/clinicMainBottomNavigate.dart';
import 'package:puppal_application/pages/generalAppNavigator.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalSetting.dart';
import 'package:puppal_application/pages/generalMainBottomNavigate.dart';
import 'package:puppal_application/pages/login/index.dart';

class NewpasswordPage extends StatefulWidget {
  final String email;
  const NewpasswordPage({super.key, required this.email});

  @override
  State<NewpasswordPage> createState() => _NewpasswordPageState();
}

class _NewpasswordPageState extends State<NewpasswordPage> {
  late double screenWidth;
  late double screenHeight;
  String url = '';

  final box = GetStorage();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  TextEditingController passwordCtl = TextEditingController();
  TextEditingController confirmPasswordCtl = TextEditingController();

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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'เปลี่ยนรหัสผ่าน',
          style: TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFDBA871),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: screenHeight,
          // decoration: BoxDecoration(
          //   image: DecorationImage(
          //       image: AssetImage('assets/images/indexBg.png'),
          //       fit: BoxFit.cover,
          //       colorFilter: ColorFilter.mode(
          //           Colors.white.withOpacity(0.2), BlendMode.dstATop)),
          // ),
          color: Color(0xFFFAF8F5),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05, vertical: screenHeight * 0.05),
            child: SizedBox(
              width: screenWidth * 0.9,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.grey.shade700, width: 3)),
                    child: Icon(
                      MdiIcons.lock,
                      size: screenWidth * 0.25,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.025),
                  Text(
                    'กรุณาป้อนรหัสใหม่',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(widget.email),
                  SizedBox(height: screenHeight * 0.025),
                  Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(10),
                    child: TextField(
                      controller: passwordCtl,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'รหัสผ่าน...',
                        filled: true,
                        fillColor: Colors.grey.shade200,
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
                  SizedBox(height: screenHeight * 0.025),
                  Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(10),
                    child: TextField(
                      controller: confirmPasswordCtl,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        hintText: 'ยืนยันรหัสผ่าน...',
                        filled: true,
                        fillColor: Colors.grey.shade200,
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
                  SizedBox(height: screenHeight * 0.025),
                  ElevatedButton(
                      onPressed: () {
                        showAlert(
                          title: 'เปลี่ยนรหัสผ่าน?',
                          message: 'คุณแน่ใจใช่หรือไม่?',
                          onConfirm: () {
                            confirmButton();
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF916B44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                      child: Text(
                        'ยืนยัน',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> confirmButton() async {
    final password = passwordCtl.text;
    final hasUpper = RegExp(r'[A-Z]').hasMatch(password);
    final hasLower = RegExp(r'[a-z]').hasMatch(password);
    final hasDigit = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecial = RegExp(r'[!@#\$%^&*(),.":{}|_]').hasMatch(password);

    if (password.length < 8 ||
        !hasUpper ||
        !hasLower ||
        !hasDigit ||
        !hasSpecial) {
      Get.snackbar(
        'ข้อผิดพลาด',
        'รหัสผ่านควรมีอย่างน้อย 8 ตัวอักษรและประกอบด้วย A-Z, a-z, ตัวเลข และอักขระพิเศษ',
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

    showLoadingDialog();

    UserPasswordChange req =
        UserPasswordChange(email: widget.email, password: passwordCtl.text);

    var res = await http.put(
      Uri.parse("$url/user/password"),
      headers: {"Content-Type": "application/json; charset=utf-8"},
      body: userPasswordChangeToJson(req),
    );
    log(res.statusCode.toString());

    Get.back();

    if (res.statusCode == 200) {
      showAlertNoClose(
          title: 'เสร็จสิ้น',
          message: 'อัพเดทรหัสผ่านสำเร็จแล้ว',
          onConfirm: () {
            if (box.read('email') == null) {
              Get.offAll(() => IndexPage());
            } else {
              if (box.read('type') == 'general') {
                while (Get.isDialogOpen ?? false) {
                  Get.back();
                }
                Get.offAll(() => GeneralMainBottomNavigate(indexPage: 1));
              } else if (box.read('type') == 'clinic') {
                while (Get.isDialogOpen ?? false) {
                  Get.back();
                }
                Get.offAll(() => Clinicmainbottomnavigate(indexPage: 1));
              }
            }
          });
    } else {
      showAlertNoClose(title: 'ผิดพลาด', message: 'กรุณาลองใหม่อีกครั้ง');
    }
  }

  void showAlertNoClose({
    required String title,
    required String message,
    VoidCallback? onConfirm, // Optional action
  }) {
    Get.defaultDialog(
      title: '',
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.all(16),
      content: PopScope(
        canPop: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFD7CCC8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                size: 24,
                color: Color(0xFFA1887F),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Color(0xFF8D6E63),
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                color: Color(0xFFA1887F),
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  if (onConfirm != null) {
                    onConfirm();
                  } else {
                    Get.back(); // Default action
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF795548),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'ตกลง',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF5F0E8),
      barrierDismissible: false,
      radius: 16,
    );
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

  void showAlert({
    required String title,
    required String message,
    VoidCallback? onConfirm,
  }) {
    Get.defaultDialog(
      title: '',
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.all(16),
      content: PopScope(
        canPop: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with subtle animation potential
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFD7CCC8),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.info_outline_rounded,
                size: 24,
                color: const Color(0xFFA1887F),
              ),
            ),

            const SizedBox(height: 16),

            // Title with better typography
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Color(0xFF8D6E63),
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Message with improved readability
            Text(
              message,
              style: const TextStyle(
                color: Color(0xFFA1887F),
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // Enhanced button row
            Row(
              children: [
                // Cancel button
                Expanded(
                  child: Container(
                    height: 40,
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF8D6E63),
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: const Color(0xFFD7CCC8),
                            width: 1,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'ยกเลิก',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Confirm button
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xFF795548),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFA1887F).withOpacity(0.3),
                          offset: const Offset(0, 2),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        if (onConfirm != null) onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'ตกลง',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF5F0E8),
      barrierDismissible: false,
      radius: 16,
    );
  }
}
