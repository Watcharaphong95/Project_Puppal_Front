import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/controller/registerClinicCtl.dart';
import 'package:puppal_application/controller/registerDoctorCtl.dart';
import 'package:puppal_application/model/clinicPost.dart';
import 'package:puppal_application/model/docspecialPost.dart';
import 'package:puppal_application/model/doctorPost.dart';
import 'package:puppal_application/model/specialPost.dart';
import 'package:puppal_application/model/userPost.dart';
import 'package:puppal_application/pages/clinic/mainClinic/addDoctors/clinicAddDoctor.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicListDoctors.dart';

import 'package:puppal_application/pages/clinic/mainClinic/clinicMain.dart';
import 'package:puppal_application/pages/clinic/mainClinic/reserve/vaccineRequestsPage.dart';
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

  String? get specialName => null;

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
                    Get.to(() => VaccineRequestsPage());
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
      body: Container(
        color: const Color(0xFFE9CBAF).withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Header
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF916B44),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.medical_services,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'เพิ่มหมอ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF916B44),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Doctor List
              Expanded(
                child: Obx(() {
                  return ListView(
                    children: [
                      ...doctorListController.doctorList.map((doctors) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE9CBAF),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Doctor Image
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFFE9CBAF).withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: doctors.image != null
                                      ? Image.network(
                                          doctors.image,
                                          fit: BoxFit.cover,
                                        )
                                      : Icon(
                                          Icons.person,
                                          color: const Color(0xFF916B44)
                                              .withOpacity(0.6),
                                          size: 30,
                                        ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Doctor Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${doctors.name} ${doctors.surname}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: const Color(0xFF916B44),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'เลขที่: ${doctors.careerNo}',
                                      style: const TextStyle(
                                        color: Color(0xFF916B44),
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFDBA871)
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        doctor.special.value,
                                        style: TextStyle(
                                          color: const Color(0xFF916B44),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Delete Button
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Colors.red[400],
                                  size: 20,
                                ),
                                onPressed: () {
                                  showAlert(
                                    context: context,
                                    title: "คุณต้องการลบคุณหมอใช่หรือไม่",
                                    message: "คุณหมอจะถูกลบออกจากรายการ",
                                    onConfirm: () {
                                      setState(() {
                                        doctorListController
                                            .removeDoctor(doctors);
                                      });
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                      // Add Doctor Button
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Get.to(() => RegisterdocterPage());
                              },
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF916B44),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'เพิ่มหมอใหม่',
                              style: const TextStyle(
                                color: Color(0xFF916B44),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
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
      ),

      // Bottom Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
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
              onConfirm: doctorAdd,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF916B44),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_add,
                size: 20,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              const Text(
                'เพิ่มหมอทั้งหมด',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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

    final names = doctorspecial.split(',').map((e) => e.trim()).toList();
    log("Fetching specialties for: ${names.join(', ')}");

    try {
      List<SpecialPost> allResults = [];

      for (var name in names) {
        final res = await http.get(Uri.parse("$url/special/search?name=$name"));

        if (res.statusCode == 200) {
          var jsonData = json.decode(res.body);
          final result =
              (jsonData as List).map((e) => SpecialPost.fromJson(e)).toList();

          allResults.addAll(result);
        } else {
          log("Failed to load specialty for $name: ${res.statusCode}");
        }
      }

      setState(() {
        special = allResults;
      });

      for (var s in special) {
        log("${s.specialId} ${s.name}");
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
      DoctorPost req = DoctorPost(
        userEmail: box.read("email"),
        name: doc.name,
        surname: doc.surname,
        careerNo: doc.careerNo,
        image: doc.image,
      );

      var res = await http.post(
        Uri.parse("$url/doctor"),
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: doctorPostToJson(req),
      );

      log(res.statusCode.toString());

      if (res.statusCode == 200 || res.statusCode == 201) {
        var jsonResponse = json.decode(res.body);
        String doctorId = jsonResponse['doctorId'] ?? doc.careerNo;

        for (var special in special) {
          if (special.specialId == null) {
            log("ไม่มีค่า specialId สำหรับสาขานี้ => ข้าม");
            continue;
          }
          log("doctorId: ${doc.careerNo}, specialId: ${special.specialId}");

          await docspecialAdd(
            doctorId: doc.careerNo,
            specialId: special.specialId!,
          );
        }
      } else {
        log("Failed to add doctor ${doc.name} ${doc.surname}");
      }
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
              Get.to(() => Cliniclistdoctors());
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

  Future<void> docspecialAdd({
    required String doctorId,
    required int specialId,
  }) async {
    final req = DocSpecialPost(
      doctorId: doctorId,
      specialId: specialId,
    );

    final res = await http.post(
      Uri.parse("$url/docspecial"),
      headers: {"Content-Type": "application/json; charset=utf-8"},
      body: jsonEncode(req),
    );

    log("ส่ง doctorId: $doctorId, specialId: $specialId => status: ${res.statusCode}");
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
