import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicMain.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalMain.dart';

class LogintypeselectPage extends StatefulWidget {
  const LogintypeselectPage({super.key});

  @override
  State<LogintypeselectPage> createState() => _LogintypeselectPageState();
}

class _LogintypeselectPageState extends State<LogintypeselectPage> {
  late double screenWidth;
  late double screenHeight;

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SizedBox(
          width: screenWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "กรุณาเลือกประเภทผู้ใช้เพื่อเข้าสู่ระบบ",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: screenHeight * 0.05),
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
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void clinicType() {
    Get.to(() => ClinicmainPage());
  }

  void userType() {
    Get.to(() => GeneralmainPage());
  }
}
