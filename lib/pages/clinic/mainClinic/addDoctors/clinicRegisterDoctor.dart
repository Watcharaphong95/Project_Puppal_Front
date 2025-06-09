import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/controller/registerClinicCtl.dart';
import 'package:puppal_application/controller/registerDoctorCtl.dart';
import 'package:puppal_application/model/clinicPost.dart';
import 'package:puppal_application/model/doctorPost.dart';
import 'package:puppal_application/model/specialPost.dart';
import 'package:puppal_application/model/userPost.dart';
import 'package:puppal_application/pages/clinic/mainClinic/addDoctors/clinicAddDoctor.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicConfirmRequest.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicMain.dart';
import 'package:puppal_application/pages/clinic/registerClinic/doctor/registerDocter.dart';
import 'package:puppal_application/pages/login/index.dart';
import 'package:http/http.dart' as http;

class Clinicregisterdoctor extends StatefulWidget {
  const Clinicregisterdoctor({super.key});

  @override
  State<Clinicregisterdoctor> createState() => _ClinicregisterdoctorState();
}

class _ClinicregisterdoctorState extends State<Clinicregisterdoctor> {
  late double screenWidth;
  late double screenHeight;

  String url = "";

  final clinic = Get.find<registerClinicCtl>();
  final doctor = Get.find<registerDoctorCtl>();
  final doctorListController = Get.find<doctorDataList>();
  final box = GetStorage();

  List<SpecialPost> special = [];
  String? selectedSpecialty;

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
      getSpecialData(doctor.special.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(),
      drawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
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
                  leading: Icon(Icons.logout, color: Colors.redAccent),
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'เพิ่มหมอ',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                return Wrap(
                  spacing: 10.0, // Space between items horizontally
                  runSpacing: 10.0, // Space between rows
                  children: [
                    ...doctorListController.doctorList.map((doctor) {
                      return SizedBox(
                        width: screenWidth * 0.9,
                        height: screenHeight * 0.12,
                        child: Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            leading: doctor.image != null
                                ? Image.network(
                                    doctor.image,
                                    width: screenWidth * 0.2,
                                    height: screenHeight * 0.10,
                                    fit: BoxFit.fill,
                                  )
                                : SizedBox(
                                    width: 50,
                                    height: 50), // Default if no image
                            title: Text(doctor.name),
                            subtitle: Text(
                              doctor.special?.isNotEmpty == true
                                  ? doctor.special
                                  : "ไม่มีความสามารถพิเศษ",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                showAlert(
                                    context: context,
                                    title: "คุณต้องการลบคุณหมอใช่หรือไม่",
                                    message: "คุณหมอจะถูกลบออกจากรายการ",
                                    onConfirm: () {
                                      setState(() {
                                        doctorListController
                                            .removeDoctor(doctor);
                                      });
                                    });
                              },
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    SizedBox(
                      width: screenWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: screenWidth * 0.3,
                            child: FloatingActionButton(
                              onPressed: () {
                                Get.to(() => RegisterdocterPage());
                              },
                              backgroundColor: const Color(0xFFd2a679),
                              child: const Icon(Icons.add, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(screenHeight * 0.075),
        child: ElevatedButton(
          onPressed: () {
            if (doctorListController.doctorList.isEmpty) {
              showAlert(
                context: context,
                title: 'ไม่มีคุณหมอ',
                message: 'กรุณาเลือกเพิ่มคุณหมออย่างน้อย 1 คน',
              );
              return;
            }

            showAlert(
                context: context,
                title: 'เพิ่มหมอ?',
                message: 'คุณต้องการเพิ่มหมอทั้งหมดนี้ใช่หรือไม่?',
                onConfirm: doctorAdd);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF916b44),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size.fromHeight(50),
          ),
          child: const Text(
            'เพิ่ม',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Future<void> getSpecialData(String? doctorspecial) async {
    if (doctorspecial == null || doctorspecial.isEmpty) {
      log("doctorspecial is null or empty");
      return;
    }
    log("Fetching specialties for: $doctorspecial");
    try {
      final res =
          await http.get(Uri.parse("$url/special/search?name=$doctorspecial"));

      if (res.statusCode == 200) {
        var jsonData = json.decode(res.body);

        setState(() {
          special =
              (jsonData as List).map((e) => SpecialPost.fromJson(e)).toList();
        });

        for (var s in special) {
          log(s.specialId.toString() + " " + s.name);
        }
      } else {
        log("Failed to load specialties: ${res.statusCode}");
      }
    } catch (e) {
      log("Error fetching specialties: $e");
    }
  }

  void registerClinicAndAddDoctor() {
    doctorAdd();
    doctorListController.doctorList.clear();
  }

  Future<int?> getSpecialIdByName(String specialName) async {
    try {
      final res =
          await http.get(Uri.parse("$url/special/search?name=$specialName"));

      if (res.statusCode == 200) {
        var jsonData = json.decode(res.body);

        List<SpecialPost> specials =
            (jsonData as List).map((e) => SpecialPost.fromJson(e)).toList();

        if (specials.isNotEmpty) {
          return specials[0].specialId;
        }
        return null;
      } else {
        log("Failed to load specialties: ${res.statusCode}");
        return null;
      }
    } catch (e) {
      log("Error fetching specialties: $e");
      return null;
    }
  }

  Future<void> doctorAdd() async {
    showLoadingDialog(context, message: "กำลังโหลด...");

    for (var doc in doctorListController.doctorList) {
      int? specialId = await getSpecialIdByName(doc.special ?? '');

      if (specialId == null) {
        log('ไม่พบ specialId สำหรับชื่อ: ${doc.special}');
        continue;
      }

      DoctorPost req = DoctorPost(
        userEmail: box.read("email"),
        name: doc.name,
        surname: doc.surname,
        special: specialId.toString(),
        careerNo: doc.careerNo,
        image: doc.image,
      );

      var res = await http.post(
        Uri.parse("$url/doctor"),
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: doctorPostToJson(req),
      );

      log(res.statusCode.toString());
    }

    Get.back();

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFF3F3),
        title: Text(
          "สมัครสมาชิกสำเร็จ",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF795548),
          ),
        ),
        content: Text(
          "สมัครสมาชิกคลินิกสำเร็จแล้ว",
          style: const TextStyle(color: Colors.black87),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.to(() => IndexPage());
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

  Future<void> userAdd() async {
    UserPost req = UserPost(
      email: clinic.email.value,
      password: clinic.password.value,
      general: null,
      clinic: 1,
    );

    var res = await http.post(
      Uri.parse("$url/user"),
      headers: {"Content-Type": "application/json; charset=utf-8"},
      body: userPostToJson(req),
    );
    log(res.statusCode.toString());
  }

  void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(message ?? "Loading...",
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        );
      },
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
