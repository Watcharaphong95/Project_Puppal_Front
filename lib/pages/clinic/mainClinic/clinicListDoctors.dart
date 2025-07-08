import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/model/doctorPost.dart';
import 'package:puppal_application/pages/clinic/mainClinic/addDoctors/clinicAddDoctor.dart';

import 'package:puppal_application/pages/clinic/mainClinic/clinicConfirmRequest.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicMain.dart';
import 'package:http/http.dart' as http;
import 'package:puppal_application/pages/clinic/mainClinic/clinicOpeningHours.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicDoctorProfile.dart';
import 'package:puppal_application/pages/login/index.dart';
import 'package:shimmer/shimmer.dart';

class Cliniclistdoctors extends StatefulWidget {
  const Cliniclistdoctors({super.key});

  @override
  State<Cliniclistdoctors> createState() => _CliniclistdoctorsState();
}

class _CliniclistdoctorsState extends State<Cliniclistdoctors> {
  late double screenWidth;
  late double screenHeight;
  TextEditingController names = TextEditingController();
  // List<SpecialPost> special = [];
  List<DoctorPost> doctorsList = [];

  String url = "";
  bool isLoading = true;
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
      getDoctor();
    });
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, size: 30),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          title: const Text('คุณหมอประจำคลินิก'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                Icons.add_circle,
                color: Color(0xFF916b44),
                size: 45,
              ),
              onPressed: () {
                Get.to(() => Clinicadddoctor());
              },
            ),
          ],
        ),
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
                      Get.to(() => Cliniclistdoctors());
                    },
                  ),
                  ListTile(
                    leading:
                        Icon(Icons.medical_services, color: Color(0xFF916b44)),
                    title: Text('เวลาปิด-เปิด'),
                    onTap: () => Get.to(() => Clinicopeninghours()),
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
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              TextField(
                onChanged: (text) {
                  if (text.trim().isEmpty) {
                    getDoctor();
                  } else {
                    searcheDoctor(names);
                  }
                },
                controller: names,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'ค้นหา',
                  prefixIcon:
                      const Icon(Icons.search, color: Color(0xFF916B44)),
                  hintStyle: const TextStyle(color: Color(0xFF916B44)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFDBA871)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF916B44), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF916B44)))
                      : doctorsList.isEmpty
                          ? const Center(
                              child: Text(
                                "ไม่พบข้อมูลคุณหมอ",
                                style: TextStyle(
                                    fontSize: 20, color: Color(0xFF916B44)),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(10),
                              child: GridView.count(
                                crossAxisCount: 2, // จาก 3 เป็น 2
                                crossAxisSpacing: 25,
                                mainAxisSpacing: 15,
                                childAspectRatio:
                                    0.75, // ปรับสัดส่วนให้ดูไม่แคบเกินไป
                                children: doctorsList.map((doctor) {
                                  return Card(
                                    elevation: 5,
                                    color: const Color.fromARGB(
                                        255, 246, 234, 224),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: const BorderSide(
                                          color: Color(0xFFDBA871), width: 1),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 8),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ClipOval(
                                            child: doctor.image.isNotEmpty
                                                ? Image.network(
                                                    doctor.image,
                                                    height: 80,
                                                    width: 80,
                                                    fit: BoxFit.cover,
                                                    loadingBuilder: (context,
                                                        child,
                                                        loadingProgress) {
                                                      if (loadingProgress ==
                                                          null) return child;
                                                      return Shimmer.fromColors(
                                                        baseColor:
                                                            Colors.grey[300]!,
                                                        highlightColor:
                                                            Colors.grey[100]!,
                                                        child: Container(
                                                          width: 80,
                                                          height: 80,
                                                          color: Colors.white,
                                                        ),
                                                      );
                                                    },
                                                    errorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        const Icon(Icons.error),
                                                  )
                                                : Image.asset(
                                                    'assets/images/indexBg.png',
                                                    height: 80,
                                                    width: 80,
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            doctor.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Color(0xFF916B44),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 10),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFFDBA871),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              elevation: 2,
                                            ),
                                            onPressed: () {
                                              Get.to(() => Clinicdoctorprofile(
                                                  name: doctor.name));
                                            },
                                            child: const Text(
                                              'ดูประวัติ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            )),
            ],
          ),
        ));
  }

  List<DoctorPost> doctorPostFromJson(String str) => List<DoctorPost>.from(
      json.decode(str).map((x) => DoctorPost.fromJson(x)));

  Future<void> getDoctor() async {
    var res = await http
        .get(Uri.parse("$url/doctor/searchemail/${box.read('email')}"));
    if (res.statusCode == 200) {
      var data = doctorPostFromJson(res.body);
      setState(() {
        doctorsList = data;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> searcheDoctor(TextEditingController nams) async {
    final keyword = nams.text.trim();
    if (keyword.isEmpty) return;

    try {
      final res = await http
          .get(Uri.parse("$url/doctor/searche/${box.read('email')}/$keyword"));
      if (res.statusCode == 200) {
        final data = doctorPostFromJson(res.body);
        setState(() {
          doctorsList = data;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
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
