import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:puppal_application/pages/clinic/registerClinic/registerClinic.dart';
import 'package:puppal_application/pages/clinic/registerClinic/registerClinicGoogle.dart';
import 'package:puppal_application/pages/general/registerGeneral/registerUser.dart';
import 'package:puppal_application/pages/general/registerGeneral/registerUserGoogle.dart';

const Color primaryBrown = Color(0xFF916B44);
const Color goldenBrown = Color(0xFFDBA871);
const Color lightBeige = Color(0xFFFAF8F5);
const Color cream = Color(0xFFE9CBAF);
const Color white = Colors.white;

class RegistertypePage extends StatefulWidget {
  const RegistertypePage({super.key});

  @override
  State<RegistertypePage> createState() => _RegistertypePageState();
}

class _RegistertypePageState extends State<RegistertypePage> {
  final box = GetStorage();
  late double screenWidth;
  late double screenHeight;

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: lightBeige,
      appBar: AppBar(
        title: const Text(
          'เลือกประเภทผู้ใช้ที่ต้องการสมัคร',
          style: TextStyle(color: white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: goldenBrown,
      ),
      body: PopScope(
        canPop: false,
        child: SingleChildScrollView(
          child: Container(
            width: screenWidth,
            color: Color(0xFFFAF8F5),
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              children: [
                _buildUserCard(),
                const SizedBox(height: 20),
                _buildClinicCard(),
                const SizedBox(height: 40),
                SizedBox(
                  width: screenWidth * 0.5,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cream,
                      foregroundColor: primaryBrown,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      if (box.read('emailGoogleRegister') != null) {
                        box.remove('emailGoogleRegister');
                      }
                      Get.back();
                    },
                    child: const Text(
                      'กลับ',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryBrown),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard() {
    return GestureDetector(
      onTap: userType,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 5,
        color: primaryBrown, // <- Changed to primary brown
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Image.asset('assets/images/userType.png'),
              const SizedBox(height: 12),
              const Text(
                'เจ้าของสุนัข',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // <- White text
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: screenWidth * 0.75,
                child: const Text(
                  'สมัครเข้าใช้งานเพื่อ แชร์สุนัขของคุณกับผู้ใช้คนอื่นๆ ค้นหาคลินิกใกล้คุณ และทำการจองวันฉีดวัคซีน',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white, // <- White text
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClinicCard() {
    return GestureDetector(
      onTap: clinicType,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 5,
        color: primaryBrown, // <- Same color
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Image.asset('assets/images/clinicType.png'),
              const SizedBox(height: 12),
              const Text(
                'คลินิก',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // <- White text
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: screenWidth * 0.75,
                child: const Text(
                  'สมัครเข้าใช้งานเพื่อ แชร์คลินิกของท่านให้กับเจ้าของสุนัข และรับการขอจองวันฉีดวัคซีนจากผู้ใช้',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white, // <- White text
                  ),
                ),
              ),
            ],
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
