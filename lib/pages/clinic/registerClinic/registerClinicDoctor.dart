import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

  Future<void> getSpecialData(String? doctorspecial) async {
    log("doctor.special.value: ${doctor.special.value}");

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

  // Future<void> insertToDB() async {
  //   showLoadingDialog(context, message: "กำลังโหลด...");
  //   await userAdd();

  //   ClinicPost req2 = ClinicPost(
  //       userEmail: clinic.email.value,
  //       name: clinic.name.value,
  //       phone: clinic.name.value,
  //       address: clinic.address.value,
  //       lat: clinic.lat.value,
  //       lng: clinic.lng.value,
  //       image: clinic.imageUrl.value,
  //       open: clinic.open.value,
  //       close: clinic.close.value,
  //       numPerTime: clinic.numPerTime.value);

  //   var res = await http.post(
  //     Uri.parse("$url/clinic"),
  //     headers: {"Content-Type": "application/json; charset=utf-8"},
  //     body: clinicPostToJson(req2),
  //   );
  //   log(res.statusCode.toString());

  //   for (var doc in doctorListController.doctorList) {
  //     DoctorPost req = DoctorPost(
  //       userEmail: clinic.email.value,
  //       name: doc.name,
  //       surname: doc.surname,
  //       careerNo: doc.careerNo,
  //       image: doc.image,
  //     );

  //     var doctorRes = await http.post(
  //       Uri.parse("$url/doctor"),
  //       headers: {"Content-Type": "application/json; charset=utf-8"},
  //       body: doctorPostToJson(req),
  //     );

  //     log("เพิ่มหมอ ${doc.name} => statusCode: ${doctorRes.statusCode}");

  //     if (doctorRes.statusCode == 200 || doctorRes.statusCode == 201) {
  //       var jsonResponse = json.decode(doctorRes.body);
  //       String doctorId = jsonResponse['doctorId'] ?? doc.careerNo;

  //       for (var sp in special) {
  //         if (sp.specialId == null) {
  //           log("ไม่มีค่า specialId สำหรับสาขานี้ => ข้าม");
  //           continue;
  //         }

  //         log("เชื่อม doctorId: $doctorId กับ specialId: ${sp.specialId}");
  //         await docspecialAdd(
  //           doctorId: doctorId,
  //           specialId: sp.specialId!,
  //         );
  //       }
  //     } else {
  //       log("ไม่สามารถเพิ่มหมอได้: ${doctorRes.statusCode}");
  //     }
  //   }

  //   // Get.back();

  //   if (res.statusCode == 201) {
  //     showDialog(
  //       barrierDismissible: false,
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         backgroundColor: const Color(0xFFFFF3F3),
  //         title: Text(
  //           "สมัครสมาชิกสำเร็จ",
  //           style: const TextStyle(
  //             fontWeight: FontWeight.bold,
  //             color: Color(0xFF795548),
  //           ),
  //         ),
  //         content: Text(
  //           "สมัครสมาชิกคลินิกสำเร็จแล้ว",
  //           style: const TextStyle(color: Colors.black87),
  //         ),
  //         shape:
  //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  //         actions: [
  //           ElevatedButton(
  //             onPressed: () {
  //               Get.to(() => IndexPage());
  //             },
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: const Color(0xFF795548),
  //               foregroundColor: Colors.white,
  //               shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(10)),
  //             ),
  //             child: const Text('ตกลง'),
  //           ),
  //         ],
  //       ),
  //     );
  //   } else {
  //     showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         backgroundColor: const Color(0xFFFFF3F3),
  //         title: Text(
  //           "เกิดข้อผิดพลาด",
  //           style: const TextStyle(
  //             fontWeight: FontWeight.bold,
  //             color: Color(0xFF795548),
  //           ),
  //         ),
  //         content: Text(
  //           "ไม่สามารถสมัครสมาชิกได้ กรุณาลองใหม่อีกครั้ง",
  //           style: const TextStyle(color: Colors.black87),
  //         ),
  //         shape:
  //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  //         actions: [
  //           ElevatedButton(
  //             onPressed: () {
  //               Get.back();
  //             },
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: const Color(0xFF795548),
  //               foregroundColor: Colors.white,
  //               shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(10)),
  //             ),
  //             child: const Text('ตกลง'),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  // }

  // Future<void> doctorAdd() async {
  //   for (var doc in doctorListController.doctorList) {
  //     DoctorPost req = DoctorPost(
  //       userEmail: clinic.email.value,
  //       name: doc.name,
  //       surname: doc.surname,
  //       careerNo: doc.careerNo,
  //       image: doc.image,
  //     );

  //     var res = await http.post(
  //       Uri.parse("$url/doctor"),
  //       headers: {"Content-Type": "application/json; charset=utf-8"},
  //       body: doctorPostToJson(req),
  //     );
  //     log(res.statusCode.toString());
  //   }
  // }

  Future<void> insertToDB() async {
    showLoadingDialog(context, message: "กำลังโหลด...");

    try {
      await userAdd();

      ClinicPost req2 = ClinicPost(
          userEmail: clinic.email.value,
          name: clinic.name.value,
          phone: clinic.phone.value,
          address: clinic.address.value,
          lat: clinic.lat.value,
          lng: clinic.lng.value,
          image: clinic.imageUrl.value,
          open: clinic.open.value,
          close: clinic.close.value,
          numPerTime: clinic.numPerTime.value);

      var clinicRes = await http.post(
        Uri.parse("$url/clinic"),
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: clinicPostToJson(req2),
      );

      log("Clinic creation status: ${clinicRes.statusCode}");

      if (clinicRes.statusCode != 200 && clinicRes.statusCode != 201) {
        throw Exception("Failed to create clinic");
      }

      await doctorAdd();

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
            "สมัครสมาชิกคลินิกและเพิ่มหมอสำเร็จแล้ว",
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
    } catch (e) {
      Get.back();

      log("Error in insertToDB: $e");

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
            "ไม่สามารถสมัครสมาชิกได้ กรุณาลองใหม่อีกครั้ง\nError: $e",
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
    DoctorPost doctorReq = DoctorPost(
      userEmail: clinic.email.value,
      name: doctor.name.value,
      surname: doctor.surname.value,
      careerNo: doctor.careerNo.value,
      image: doctor.image.value,
    );

    var doctorRes = await http.post(
      Uri.parse("$url/doctor"),
      headers: {"Content-Type": "application/json; charset=utf-8"},
      body: doctorPostToJson(doctorReq),
    );

    log("Doctor ${doctor.name} creation status: ${doctorRes.statusCode}");

    if (doctorRes.statusCode == 200 || doctorRes.statusCode == 201) {
      for (var sp in special) {
        if (sp.specialId == null) {
          log("ไม่มีค่า specialId สำหรับสาขานี้ => ข้าม");
          continue;
        }

        log("Adding specialty - doctorId: ${doctor.careerNo}, specialId: ${sp.specialId}");

        await docspecialAdd(
          doctorId: doctor.careerNo.value,
          specialId: sp.specialId!,
        );
      }
    } else {
      log("Failed to add doctor ${doctor.name} ${doctor.surname} - Status: ${doctorRes.statusCode}");
    }
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
