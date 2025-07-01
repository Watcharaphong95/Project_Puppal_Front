import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/controller/registerDoctorCtl.dart';

import 'package:http/http.dart' as http;
import 'package:puppal_application/model/specialPost.dart';
import 'package:puppal_application/pages/clinic/mainClinic/addDoctors/clinicAddAvatar.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicMain.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicOpeningHours.dart';
import 'package:puppal_application/pages/clinic/mainClinic/reserve/vaccineRequestsPage.dart';
import 'package:puppal_application/pages/clinic/registerClinic/doctor/registerDoctorAvatar.dart';
import 'package:puppal_application/pages/login/index.dart';

class Clinicadddoctor extends StatefulWidget {
  const Clinicadddoctor({super.key});

  @override
  State<Clinicadddoctor> createState() => _ClinicadddoctorState();
}

class _ClinicadddoctorState extends State<Clinicadddoctor> {
  final box = GetStorage();
  late double screenWidth;
  late double screenHeight;
  String url = "";

  final controller = Get.find<registerDoctorCtl>();

  TextEditingController nameCtl = TextEditingController();
  TextEditingController surnameCtl = TextEditingController();
  TextEditingController careerNoCtl = TextEditingController();
  // TextEditingController specialNoCtl = TextEditingController();
  TextEditingController searchController = TextEditingController();

  List<SpecialPost> special = [];
  // String? selectedSpecialty;
  List<String> selectedSpecialty = [];
  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
      getSpecialData();
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
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: SizedBox(
            height: screenHeight * 0.85,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  spacing: 16,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ชื่อ',
                          style: TextStyle(fontSize: 20),
                        ),
                        Material(
                          elevation: 5,
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            height: screenHeight * 0.055,
                            child: TextField(
                              controller: nameCtl,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'นามสกุล',
                          style: TextStyle(fontSize: 20),
                        ),
                        Material(
                          elevation: 5,
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            height: screenHeight * 0.055,
                            child: TextField(
                              controller: surnameCtl,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'ความเชี่ยวชาญ',
                              style: TextStyle(fontSize: 20),
                            ),
                            Text(
                              '(เช่น ผ่าตัด, ยา)',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.grey),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Material(
                          elevation: 5,
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                              onTap: _showSelectSpecialty,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                height: screenHeight * 0.055,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  selectedSpecialty.isEmpty
                                      ? 'เลือกความเชี่ยวชาญ'
                                      : selectedSpecialty.join(', '),
                                  style: TextStyle(
                                    color: selectedSpecialty.isEmpty
                                        ? Colors.grey
                                        : Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              )),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'เลขใบอนุญาตประกอบวิชาชีพ',
                          style: TextStyle(fontSize: 20),
                        ),
                        Material(
                          elevation: 5,
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            height: screenHeight * 0.055,
                            child: TextField(
                              controller: careerNoCtl,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, screenHeight * 0.05),
                  child: SizedBox(
                    width: screenWidth * 0.5,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Color(0xFF916b44)),
                        onPressed: doctorAddNextButton,
                        child: Text(
                          'ถัดไป',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        )),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> getSpecialData() async {
    try {
      var res = await http.get(Uri.parse("$url/special/"));
      if (res.statusCode == 200) {
        var jsonData = json.decode(res.body);

        setState(() {
          special =
              (jsonData as List).map((e) => SpecialPost.fromJson(e)).toList();
        });

        for (var s in special) {
          log(s.toString());
        }
      } else {
        log("Failed to load specialties: ${res.statusCode}");
      }
    } catch (e) {
      log("Error fetching specialties: $e");
    }
  }

  Future<void> doctorAddNextButton() async {
    if (nameCtl.text.trim().isEmpty ||
        surnameCtl.text.trim().isEmpty ||
        selectedSpecialty == null ||
        careerNoCtl.text.trim().isEmpty) {
      Get.snackbar(
        'ข้อผิดพลาด',
        'กรุณากรอกข้อมูลให้ครบถ้วน',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color.fromARGB(255, 211, 89, 89),
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        snackStyle: SnackStyle.FLOATING,
        isDismissible: true,
      );
      return;
    }
    int? selectedSpecialId;

    onChanged:
    (value) {
      setState(() {
        selectedSpecialId =
            special.firstWhere((sp) => sp.name == value).specialId;
        selectedSpecialty = value;
      });
    };

    controller.name.value = nameCtl.text;
    controller.surname.value = surnameCtl.text;
    controller.special.value = selectedSpecialId?.toString() ?? '';
    controller.special.value = selectedSpecialty.join(', ');
    controller.careerNo.value = careerNoCtl.text;

    var res = await http.get(Uri.parse("$url/doctor/${careerNoCtl.text}"));

    if (res.statusCode == 200) {
      Get.snackbar(
        'ข้อผิดพลาด',
        'หมอคนนี้เคยเป็นสมาชิกของคลินิกอื่นแล้ว',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color.fromARGB(255, 211, 89, 89),
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        snackStyle: SnackStyle.FLOATING,
        isDismissible: true,
      );
      return;
    } else {
      Get.to(() => Clinicaddavatar());
    }
  }

  Future<void> specialAdd(String selectedSpecialty) async {
    SpecialPost req = SpecialPost(
      name: selectedSpecialty,
      specialId: 0,
    );

    final res = await http.post(
      Uri.parse("$url/special"),
      headers: {"Content-Type": "application/json; charset=utf-8"},
      body: specialPostToJson([req]),
    );

    // log("STATUS: ${res.statusCode}");
    // log("BODY: ${res.body}");
  }

  void _showSelectSpecialty() {
    TextEditingController searchController = TextEditingController();
    TextEditingController otherSpecialtyController = TextEditingController();
    List<String> allSpecialties = [...special.map((s) => s.name), "อื่นๆ"];
    List<String> filtered = List<String>.from(allSpecialties);

    bool isOtherSelected = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 16),
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (!isOtherSelected)
                            TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                hintText: 'ค้นหาความเชี่ยวชาญ',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: Icon(Icons.search),
                                suffixIcon: searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(Icons.clear),
                                        onPressed: () {
                                          searchController.clear();
                                          setModalState(() {
                                            filtered = List<String>.from(
                                                allSpecialties);
                                          });
                                        },
                                      )
                                    : null,
                              ),
                              onChanged: (value) {
                                setModalState(() {
                                  filtered = allSpecialties
                                      .where((s) => s
                                          .toLowerCase()
                                          .contains(value.toLowerCase()))
                                      .toList();
                                });
                              },
                            ),
                          SizedBox(height: 16),
                          if (!isOtherSelected)
                            ConstrainedBox(
                              constraints: BoxConstraints(maxHeight: 300),
                              child: filtered.isEmpty
                                  ? Center(child: Text('ไม่พบความเชี่ยวชาญ'))
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: filtered.length,
                                      itemBuilder: (context, index) {
                                        final item = filtered[index];

                                        return Card(
                                          child: item == "อื่นๆ"
                                              ? ListTile(
                                                  title: Text("อื่นๆ"),
                                                  trailing: Icon(
                                                      Icons.arrow_forward_ios),
                                                  onTap: () {
                                                    setModalState(() {
                                                      isOtherSelected = true;
                                                    });
                                                  },
                                                )
                                              : CheckboxListTile(
                                                  title: Text(item),
                                                  value: selectedSpecialty
                                                      .contains(item),
                                                  onChanged: (bool? selected) {
                                                    setModalState(() {
                                                      if (selected == true) {
                                                        selectedSpecialty
                                                            .add(item);
                                                      } else {
                                                        selectedSpecialty
                                                            .remove(item);
                                                      }
                                                    });
                                                  },
                                                ),
                                        );
                                      },
                                    ),
                            ),
                          // ignore: dead_code
                          if (isOtherSelected) ...[
                            TextField(
                              controller: otherSpecialtyController,
                              decoration: InputDecoration(
                                hintText: 'กรอกความเชี่ยวชาญอื่นๆ',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () async {
                                if (isOtherSelected &&
                                    otherSpecialtyController.text
                                        .trim()
                                        .isNotEmpty) {
                                  selectedSpecialty.add(
                                      otherSpecialtyController.text.trim());
                                  await specialAdd(
                                      otherSpecialtyController.text.trim());
                                }

                                setState(() {
                                  selectedSpecialty =
                                      List.from(selectedSpecialty);
                                });

                                Navigator.pop(context);
                              },
                              child: Text("ยืนยัน"),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
