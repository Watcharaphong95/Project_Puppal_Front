import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/controller/registerClinicCtl.dart';
import 'package:puppal_application/controller/registerDoctorCtl.dart';
import 'package:puppal_application/model/clinicPost.dart';
import 'package:puppal_application/model/doctorPost.dart';
import 'package:puppal_application/model/userPost.dart';
import 'package:puppal_application/pages/login/index.dart';
import 'package:puppal_application/pages/clinic/registerClinic/doctor/registerDocter.dart';
import 'package:http/http.dart' as http;

class RegisterclinicdoctorPage extends StatefulWidget {
  const RegisterclinicdoctorPage({super.key});

  @override
  State<RegisterclinicdoctorPage> createState() =>
      _RegisterclinicdoctorPageState();
}

class _RegisterclinicdoctorPageState extends State<RegisterclinicdoctorPage> {
  late double screenWidth;
  late double screenHeight;

  String url = "";

  final clinic = Get.find<registerClinicCtl>();
  final doctor = Get.find<registerDoctorCtl>();
  final doctorListController = Get.find<doctorDataList>();

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
                title: 'สมัครสมาชิก?',
                message: 'คุณหมอสามารถเพิ่มภายหลังได้',
                onConfirm: registerClinicAndAddDoctor);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF916b44),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size.fromHeight(50),
          ),
          child: const Text(
            'สมัครสมาชิก',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }

  void registerClinicAndAddDoctor() {
    insertToDB();
    doctorListController.doctorList.clear();
  }

  Future<void> insertToDB() async {
    showLoadingDialog(context, message: "กำลังโหลด...");
    await userAdd();

    ClinicPost req2 = ClinicPost(
        userEmail: clinic.email.value,
        name: clinic.name.value,
        phone: clinic.name.value,
        address: clinic.address.value,
        lat: clinic.lat.value,
        lng: clinic.lng.value,
        image: clinic.imageUrl.value,
        open: clinic.open.value,
        close: clinic.close.value,
        numPerTime: clinic.numPerTime.value);

    var res = await http.post(
      Uri.parse("$url/clinic"),
      headers: {"Content-Type": "application/json; charset=utf-8"},
      body: clinicPostToJson(req2),
    );
    log(res.statusCode.toString());

    await doctorAdd();

    Get.back();

    if (res.statusCode == 201) {
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFFFFF3F3),
          title: Text(
            "เกิดข้อผิดพลาด",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF795548),
            ),
          ),
          content: Text(
            "ไม่สามารถสมัครสมาชิกได้ กรุณาลองใหม่อีกครั้ง",
            style: const TextStyle(color: Colors.black87),
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          actions: [
            ElevatedButton(
              onPressed: () {
                Get.back();
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

  Future<void> doctorAdd() async {
    for (var doc in doctorListController.doctorList) {
      DoctorPost req = DoctorPost(
        userEmail: clinic.email.value,
        name: doc.name,
        surname: doc.surname,
        special: doc.special,
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
