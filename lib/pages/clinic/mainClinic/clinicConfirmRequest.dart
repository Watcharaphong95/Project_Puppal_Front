import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicAddDoctor.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicMain.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalMain.dart';
import 'package:puppal_application/pages/general/registerGeneral/registerUserGoogle.dart';
import 'package:puppal_application/pages/login/index.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class ClinicConfirmRequest extends StatefulWidget {
  const ClinicConfirmRequest({super.key});

  @override
  State<ClinicConfirmRequest> createState() => _ClinicConfirmRequestState();
}

class _ClinicConfirmRequestState extends State<ClinicConfirmRequest> {
  late double screenWidth;
  late double screenHeight;
  bool isNormalSelected = true;
  final box = GetStorage();
  String url = '';

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
    });
  }

  Widget _buildRequestCard(String status, String name, String time) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: 'คุณ ',
                    children: [
                      TextSpan(
                        text: name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' ได้จองเวลากับคลินิกของคุณ'),
                    ],
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            height: 50,
            width: 50,
            decoration: const BoxDecoration(
              color: Color(0xFFFFB703),
              borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
            ),
            child: const Icon(Icons.arrow_forward, color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/indexBg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Color(0xFF916b44),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipOval(
                        child: Image.network(
                          box.read('clinicImage'),
                          width: screenWidth * 0.2,
                          height: screenWidth * 0.2,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                width: screenWidth * 0.2,
                                height: screenWidth * 0.2,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        box.read('clinicName') ?? "ผู้ใช้งาน",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.home, color: Color(0xFF916b44)),
                  title: Text('หน้าหลัก'),
                  onTap: () {
                    Get.to(() => ClinicmainPage());
                  },
                ),
                ListTile(
                  leading: Icon(Icons.system_security_update,
                      color: Color(0xFF916b44)),
                  title: Text('คำขอฉีดยา'),
                  onTap: () {
                    Get.to(() => ClinicConfirmRequest());
                  },
                ),
                ListTile(
                  leading:
                      Icon(Icons.medical_services, color: Color(0xFF916b44)),
                  title: Text('ประวัติการฉีดยา'),
                ),
                ListTile(
                  leading: Icon(Icons.supervised_user_circle,
                      color: Color(0xFF916b44)),
                  title: Text('หมอประจำคลินิก'),
                  onTap: () {
                    Get.to(() => Clinicadddoctor());
                  },
                ),
                ListTile(
                  leading:
                      Icon(Icons.medical_services, color: Color(0xFF916b44)),
                  title: Text('เวลาปิด-เปิด'),
                ),
                ListTile(
                  leading: Icon(Icons.settings, color: Color(0xFF916b44)),
                  title: Text('ตั้งค่า'),
                  onTap: () {},
                ),
                ListTile(
                  leading:
                      Icon(MdiIcons.accountSwitch, color: Color(0xFF916b44)),
                  title: Text('สลับโหมด'),
                  onTap: () async {
                    var resGeneral = await http.get(
                        Uri.parse("$url/general/name/${box.read('email')}"));
                    if (resGeneral.statusCode == 200) {
                      showAlert(
                        title: 'สลับไปยังบัญชีผู้ใช้ทั่วไป?',
                        message: 'กด ตกลง เพื่อไปยังบัญชีผู้ใช้ทั่วไป',
                        onConfirm: () {
                          box.write('generalName',
                              jsonDecode(resGeneral.body)['username']);
                          box.write('generalImage',
                              jsonDecode(resGeneral.body)['image']);
                          log('Name ${box.read('generalName')}');
                          Get.to(() => GeneralmainPage());
                        },
                      );
                    } else {
                      showAlert(
                        title: 'คุณยังไม่มีบัญชีผู้ใช้ทั่วไป!',
                        message: 'กด ตกลง เพื่อไปยังหน้าสมัครผู้ใช้ทั่วไป',
                        onConfirm: () {
                          Get.to(() => RegisterusergooglePage());
                        },
                      );
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.redAccent),
                  title: Text('ออกจากระบบ'),
                  onTap: () {
                    showAlert(
                      title: 'ออกจากระบบ?',
                      message: 'คุณต้องการออกจากระบบใช่หรือไม่',
                      onConfirm: () {
                        box.erase();
                        Get.offAll(() => IndexPage());
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Tab Switch
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEAEAEA),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isNormalSelected = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isNormalSelected
                            ? const Color(0xFF916B44)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'ปกติ',
                        style: TextStyle(
                          color:
                              isNormalSelected ? Colors.white : Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isNormalSelected = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isNormalSelected
                            ? Colors.transparent
                            : const Color(0xFF916B44),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Special Request',
                        style: TextStyle(
                          color:
                              isNormalSelected ? Colors.black54 : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Section: ล่าสุด
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'ล่าสุด',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          _buildRequestCard(
              'รอตอบรับ', 'นานา นานาเท', 'เวลา 13.00 วันที่ 2 มกราคม 2568'),
          _buildRequestCard(
              'รอตอบรับ', 'นานา นานาเท', 'เวลา 13.00 วันที่ 2 มกราคม 2568'),

          // Section: เมื่อวาน
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'เมื่อวาน',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          _buildRequestCard(
              'รอตอบรับ', 'นานา นานาเท', 'เวลา 13.00 วันที่ 2 มกราคม 2568'),
          _buildRequestCard(
              'รอตอบรับ', 'นานา นานาเท', 'เวลา 13.00 วันที่ 2 มกราคม 2568'),
        ],
      ),
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
      content: Column(
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
      backgroundColor: const Color(0xFFF5F0E8),
      barrierDismissible: false,
      radius: 16,
    );
  }
}
