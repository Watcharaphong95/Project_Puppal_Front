import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/controller/registerClinicCtl.dart';
import 'package:puppal_application/controller/registerDoctorCtl.dart';
import 'package:puppal_application/model/ClinicGetSchedule.dart';
import 'package:puppal_application/model/ClinicSchedulePost.dart';
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
  List<int> doctorSpecial = [];
  String? selectedSpecialty;

  String? get specialName => null;

  @override
  void initState() {
    super.initState();
    log('Current route: ${Get.currentRoute}');
    log('Previous route: ${Get.previousRoute}');
    Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
      getSpecialData(doctor.special.value);
      log(clinic.email.value);
      log(clinic.weekdays.value);
      log(clinic.open.value);
      log(clinic.close.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "เพิ่มคุณหมอ",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFFDBA871),
        iconTheme: IconThemeData(color: Colors.white),

        elevation: 0,
        centerTitle: true,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF916B44)),
        //   onPressed: () => Navigator.pop(context),
        // ),
      ),
      body: Container(
        color: const Color(0xFFFAF8F5),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Header

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

            showAlertConfirm(
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

  Future<void> registerClinicAndAddDoctor() async {
    await insertToDB();
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
          // open: clinic.open.value,
          // close: clinic.close.value,
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
      await addSchedule();

      Get.back();

      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFFFFF3F3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF795548), width: 1.5),
          ),
          title: Center(
            child: Text(
              "สมัครสมาชิกสำเร็จ",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Color(0xFF795548),
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(height: 8),
              Icon(Icons.check_circle, color: Color(0xFF795548), size: 50),
              SizedBox(height: 16),
              Text(
                "สมัครสมาชิกคลินิกและเพิ่มหมอสำเร็จแล้ว",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.only(bottom: 12),
          actions: [
            ElevatedButton(
              onPressed: () {
                Get.offAll(() => IndexPage());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF795548),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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

  String formatTimeOfDayToHHmmss(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00'; // ส่งแบบนี้ไป MySQL TIME field
  }

  String clinicGetScheduleToJson(ClinicGetSchedule data) =>
      json.encode(data.toJson());

  Future<void> addSchedule() async {
    // แปลง open / close (String -> TimeOfDay -> HH:mm:00)
    TimeOfDay parseTime(String time) {
      final parts = time.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    String openFormatted =
        formatTimeOfDayToHHmmss(parseTime(clinic.open.value));
    String closeFormatted =
        formatTimeOfDayToHHmmss(parseTime(clinic.close.value));

    ClinicGetSchedule req = ClinicGetSchedule(
      clinicEmail: clinic.email.value,
      weekdays: clinic.weekdays.value,
      openTime: openFormatted,
      closeTime: closeFormatted,
    );

    final res = await http.post(
      Uri.parse("$url/schedule"),
      headers: {"Content-Type": "application/json; charset=utf-8"},
      body: clinicGetScheduleToJson(req),
    );

    if (res.statusCode == 201) {
      log("✅ เพิ่มเวลาเปิดคลินิกสำเร็จ");
    } else {
      log("❌ เพิ่มเวลาเปิดคลินิกล้มเหลว: ${res.statusCode}, ${res.body}");
    }
  }

  Future<void> doctorAdd() async {
    // showLoadingDialog(context)
    for (var doc in doctorListController.doctorList) {
      DoctorPost req = DoctorPost(
        userEmail: clinic.email.value,
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
        if (doc.special != null && doc.special!.isNotEmpty) {
          // แยกตาม comma แล้ว trim ช่องว่าง
          List<String> specialNames = doc.special!
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();

          for (var name in specialNames) {
            final id = await getSpecialIdByName(name);
            if (id != null) {
              doctorSpecial.add(id);
            } else {
              log("ไม่พบ specialId สำหรับ '$name'");
            }
          }
        }
        for (var special in doctorSpecial) {
          if (special == null) {
            log("ไม่มีค่า specialId สำหรับสาขานี้ => ข้าม");
            continue;
          }
          log("doctorId: ${doc.careerNo}, specialId: ${special}");

          await docspecialAdd(
            doctorId: doc.careerNo,
            specialId: special,
          );
        }
      } else {
        log("Failed to add doctor ${doc.name} ${doc.surname}");
      }
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF916B44), width: 2),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF916B44),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.info_outline, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF916B44),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF916B44),
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(bottom: 12, top: 4),
        actions: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: const Color(0xFF916B44),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF916B44).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (onConfirm != null) onConfirm();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'ตกลง',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showAlertConfirm({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF916B44), width: 2),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF916B44),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.help_outline, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF916B44),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF916B44),
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(bottom: 12, top: 4),
        actions: [
          // ยกเลิก
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Color(0xFF916B44), width: 1.5),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF916B44),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'ยกเลิก',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // ยืนยัน
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: const Color(0xFF916B44),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF916B44).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'ยืนยัน',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
