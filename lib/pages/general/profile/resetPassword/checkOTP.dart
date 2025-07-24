import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/model/otpPost.dart';
import 'package:puppal_application/pages/general/profile/resetPassword/newPassword.dart';

class CheckotpPage extends StatefulWidget {
  final String email;
  const CheckotpPage({super.key, required this.email});

  @override
  State<CheckotpPage> createState() => _CheckotpPageState();
}

class _CheckotpPageState extends State<CheckotpPage> {
  late double screenWidth;
  late double screenHeight;
  String url = '';

  final RxInt seconds = 300.obs; // 5 minutes
  Timer? timer;

  TextEditingController otpCtl = TextEditingController();

  @override
  void initState() {
    log(widget.email);
    Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
    });
    startCountdown();
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'เช็ครหัส OTP',
          style: TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFDBA871),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: screenHeight * 0.89,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/indexBg.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.white.withOpacity(0.2), BlendMode.dstATop)),
          ),
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
                    'กรุณาป้อนหมายเลข OTP ที่ส่งไปยังอีเมล',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(widget.email),
                  Obx(() {
                    final m = seconds.value ~/ 60;
                    final s = (seconds.value % 60).toString().padLeft(2, '0');
                    return Text(
                      'ภายในเวลา $m:$s นาที',
                      style: TextStyle(color: Colors.redAccent, fontSize: 18),
                    );
                  }),
                  SizedBox(height: screenHeight * 0.025),
                  TextField(
                    controller: otpCtl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'OTP...',
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.025),
                  ElevatedButton(
                      onPressed: checkOTP,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF916B44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                      child: Text(
                        'ยืนยัน',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      )),
                  TextButton(
                      onPressed: () {
                        sendOTPAgain();
                      },
                      child: Text(
                        'ส่งรหัส OTP อีกครั้ง',
                        style: TextStyle(decoration: TextDecoration.underline),
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void startCountdown() {
    timer?.cancel();
    seconds.value = 300;
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (seconds > 0) {
        seconds.value--;
      } else {
        timer?.cancel();
      }
    });
  }

  Future<void> checkOTP() async {
    showLoadingDialog(message: 'กำลังตรวจสอบรหัส OTP...');

    OtpPost req = OtpPost(
        userEmail: widget.email,
        otp: otpCtl.text,
        expire: DateTime.now().toString());

    var otpRes = await http.post(
      Uri.parse("$url/user/verifyotp"),
      headers: {"Content-Type": "application/json; charset=utf-8"},
      body: otpPostToJson(req),
    );
    if (otpRes.statusCode == 200) {
      Get.back();
      Get.off(() => NewpasswordPage(
            email: widget.email,
          ));
    } else {
      Get.back();
      showAlertNoClose(
          title: 'ผิดพลาด', message: 'รหัส OTP ไม่ถูกต้องหรือหมดเวลา');
    }
  }

  Future<void> sendOTPAgain() async {
    showLoadingDialog(message: 'กำลังส่งรหัส OTP...');
    var otpRes = await http.get(Uri.parse("$url/user/sendotp/${widget.email}"));
    if (otpRes.statusCode == 200) {
      startCountdown();
      Get.back();
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
}
