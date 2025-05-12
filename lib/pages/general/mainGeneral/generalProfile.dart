import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalDog.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalGuide.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalMain.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalNotification.dart';
import 'package:puppal_application/pages/general/recordDog/generalRecord.dart';
import 'package:puppal_application/pages/general/recordDog/generalRecordSearch.dart';
import 'package:puppal_application/pages/login/index.dart';

class GeneralprofilePage extends StatefulWidget {
  const GeneralprofilePage({super.key});

  @override
  State<GeneralprofilePage> createState() => _GeneralprofilePageState();
}

class _GeneralprofilePageState extends State<GeneralprofilePage> {
  final box = GetStorage();
  @override
  Widget build(BuildContext context) {
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.person, size: 50, color: Colors.white),
                      SizedBox(height: 10),
                      Text(
                        box.read('email') ?? "ผู้ใช้งาน",
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
                  leading:
                      Icon(FontAwesomeIcons.house, color: Color(0xFF916b44)),
                  title: Text('หน้าหลัก'),
                  onTap: () {
                    Get.to(() => GeneralmainPage());
                  },
                ),
                ListTile(
                  leading: Icon(FontAwesomeIcons.solidBell,
                      color: Color(0xFF916b44)),
                  title: Text('การแจ้งเตือน'),
                  onTap: () {
                    Get.to(() => GeneralnotificationPage());
                  },
                ),
                ListTile(
                  leading: Icon(FontAwesomeIcons.dog, color: Color(0xFF916b44)),
                  title: Text('สุนัข'),
                  onTap: () {
                    Get.to(() => GeneraldogPage());
                  },
                ),
                ListTile(
                  leading:
                      Icon(FontAwesomeIcons.syringe, color: Color(0xFF916b44)),
                  title: Text('ประวัติการฉีดยา'),
                  onTap: () {
                    Get.to(() => GeneralrecordsearchPage());
                  },
                ),
                ListTile(
                  leading: Icon(FontAwesomeIcons.userLarge,
                      color: Color(0xFF916b44)),
                  title: Text(
                    'โปรไฟล์',
                    style: TextStyle(
                      color: Color(0xFF916b44),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.menu_book, color: Color(0xFF916b44)),
                  title: Text('คู่มือ'),
                  onTap: () {
                    Get.to(() => GeneralguidePage());
                  },
                ),
                ListTile(
                  leading:
                      Icon(FontAwesomeIcons.doorOpen, color: Colors.redAccent),
                  title: Text('ออกจากระบบ'),
                  onTap: () {
                    showAlert(
                      context: context,
                      title: 'ออกจากระบบ?',
                      message: 'คุณต้องการออกจากระบบใช่หรือไม่',
                      onConfirm: () {
                        box.erase();
                        Get.to(() => IndexPage());
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: PopScope(canPop: false, child: Container()),
    );
  }

  void showAlert({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFF3F3),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF795548),
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.black87),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style:
                TextButton.styleFrom(foregroundColor: const Color(0xFF795548)),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (onConfirm != null) onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF795548),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }
}
