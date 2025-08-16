import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/controller/registerDoctorCtl.dart';
import 'package:puppal_application/model/specialPost.dart';
import 'package:puppal_application/pages/clinic/registerClinic/doctor/registerDoctorAvatar.dart';
import 'package:http/http.dart' as http;

class RegisterdocterPage extends StatefulWidget {
  const RegisterdocterPage({super.key});

  @override
  State<RegisterdocterPage> createState() => _RegisterdocterPageState();
}

class _RegisterdocterPageState extends State<RegisterdocterPage> {
  late double screenWidth;
  late double screenHeight;

  String url = "";

  final controller = Get.find<registerDoctorCtl>();

  TextEditingController nameCtl = TextEditingController();
  TextEditingController surnameCtl = TextEditingController();
  TextEditingController careerNoCtl = TextEditingController();
  // TextEditingController specialNoCtl = TextEditingController();

  List<SpecialPost> special = [];
  List<String> selectedSpecialty = [];

  @override
  void initState() {
    super.initState();
    log('testsetests');
    log('Current route: ${Get.currentRoute}');
    log('Previous route: ${Get.previousRoute}');
    init();
  }

  Future<void> init() async {
    await Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
      getSpecialData();
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
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
              // gradient: LinearGradient(
              //   begin: Alignment.topCenter,
              //   end: Alignment.bottomCenter,
              //   colors: [
              //     Color(0xFFFAF8F5),
              //     Colors.white,
              //   ],
              // ),
              color: Color(0xFFFAF8F5)),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                children: [
                  // Header Section
                  Container(
                    margin: EdgeInsets.only(bottom: 32),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFF916B44),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF916B44).withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.medical_services_outlined,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'ข้อมูลสัตวแพทย์',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF916B44),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'กรุณากรอกข้อมูลให้ครบถ้วน',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF916B44).withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // แก้ตรงนี้ 👇
                  Container(
                    // กำหนด max width ได้ถ้าต้องการ
                    child: Column(
                      children: [
                        // Name Field
                        _buildModernTextField(
                          label: 'ชื่อ',
                          controller: nameCtl,
                          icon: Icons.person_outline,
                          screenHeight: screenHeight,
                        ),

                        SizedBox(height: 24),

                        // Surname Field
                        _buildModernTextField(
                          label: 'นามสกุล',
                          controller: surnameCtl,
                          icon: Icons.person_outline,
                          screenHeight: screenHeight,
                        ),

                        SizedBox(height: 24),

                        // Specialty Field
                        _buildSpecialtyField(
                          label: 'ความเชี่ยวชาญ',
                          subtitle: '(เช่น ผ่าตัด, ยา)',
                          selectedSpecialty: selectedSpecialty,
                          onTap: _showSelectSpecialty,
                          screenHeight: screenHeight,
                        ),

                        SizedBox(height: 24),

                        // License Number Field
                        _buildModernTextField(
                            label: 'เลขใบอนุญาตประกอบวิชาชีพ',
                            controller: careerNoCtl,
                            icon: Icons.assignment_outlined,
                            screenHeight: screenHeight,
                            keyboardType: TextInputType.number),

                        SizedBox(height: 40),
                      ],
                    ),
                  ),

                  // Next Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    margin: EdgeInsets.only(bottom: 20),
                    child: ElevatedButton(
                      onPressed: doctorAddNextButton,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF916B44),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        shadowColor: Color(0xFF916B44).withOpacity(0.3),
                      ).copyWith(
                        elevation: MaterialStateProperty.resolveWith<double>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed))
                              return 0;
                            return 8;
                          },
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ถัดไป',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Modern Text Field Widget
  Widget _buildModernTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required double screenHeight,
    TextInputType? keyboardType, // Add this optional parameter
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF916B44),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Color(0xFFE9CBAF),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF916B44).withOpacity(0.05),
                offset: Offset(0, 2),
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType, // Use the parameter here
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF916B44),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              prefixIcon: Container(
                margin: EdgeInsets.all(12),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFFE9CBAF).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: Color(0xFF916B44),
                  size: 20,
                ),
              ),
              border: InputBorder.none,
              hintText: 'กรอก$label',
              hintStyle: TextStyle(
                color: Color(0xFF916B44).withOpacity(0.5),
                fontSize: 16,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> deleteSpecialByObject(String name) async {
    showLoadingDialog(); // แสดง dialog
    try {
      // 1. ค้นหา special_id จากชื่อก่อน
      final response = await http.get(Uri.parse('$url/special/search/$name'));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);

        if (data.isEmpty) {
          log("❌ ไม่พบชื่อ $name ในฐานข้อมูล special");
          return;
        }

        final specialId = data[0]['special_id'];

        // 2. เช็คว่า special_id ถูกใช้งานหรือไม่
        final docSpecialResponse = await http.get(Uri.parse('$url/docspecial'));

        if (docSpecialResponse.statusCode == 200) {
          final List docSpecialData = json.decode(docSpecialResponse.body);

          final isUsed = docSpecialData.any(
            (item) => item['special_id'] == specialId,
          );

          if (isUsed) {
            Get.snackbar(
              "ไม่สามารถลบข้อมูลได้",
              "เพราะความเชี่ยวชาญนี้มีหมอใช้อยู่",
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            log("❌ ไม่สามารถลบ $name เพราะมีหมอใช้อยู่ (special_id: $specialId)");
            return;
          }

          // 3. ลบได้
          final deleteRes =
              await http.delete(Uri.parse('$url/special/$specialId'));

          if (deleteRes.statusCode == 200) {
            log("✅ ลบ $name แล้ว (id: $specialId)");
            Get.snackbar(
              "ลบข้อมูลสำเร็จ",
              "ลบความเชี่ยวชาญ '$name' เรียบร้อยแล้ว",
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
            );
            _init();
          } else {
            log("❌ ลบ $name ไม่ได้ (id: $specialId)");
          }
        } else {
          log("❌ โหลด docspecial ไม่ได้: ${docSpecialResponse.statusCode}");
        }
      } else {
        log("❌ โหลด special ไม่ได้: ${response.statusCode}");
      }
    } catch (e) {
      log("❌ เกิดข้อผิดพลาดในการลบ: $e");
    } finally {
      // ปิด loading dialog เสมอ
      Navigator.of(Get.context!).pop();
    }
  }

  void showLoadingDialog({String? message}) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: const Color(0xFFF5F0E8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFD7CCC8),
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFFA1887F)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  message ?? "กำลังโหลด...",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFFA1887F),
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

// Specialty Field Widget
  Widget _buildSpecialtyField({
    required String label,
    required String subtitle,
    required List<String> selectedSpecialty,
    required VoidCallback onTap,
    required double screenHeight,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF916B44),
                ),
              ),
              SizedBox(width: 8),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF916B44).withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Color(0xFFE9CBAF),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF916B44).withOpacity(0.05),
                  offset: Offset(0, 2),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.only(right: 16),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFFE9CBAF).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.medical_information_outlined,
                    color: Color(0xFF916B44),
                    size: 20,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (selectedSpecialty.isEmpty)
                        Text(
                          'เลือกความเชี่ยวชาญ',
                          style: TextStyle(
                            color: Color(0xFF916B44).withOpacity(0.5),
                            fontSize: 16,
                          ),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: selectedSpecialty.map((specialty) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFF916B44).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Color(0xFF916B44).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                specialty,
                                style: TextStyle(
                                  color: Color(0xFF916B44),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFFDBA871),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
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
        print("Failed to load specialties: ${res.statusCode}");
      }
    } catch (e) {
      print("Error fetching specialties: $e");
    }
  }

  Future<void> specialAdd(String selectedSpecialty) async {
    bool confirmed = await confirmDialog(context);
    if (!confirmed) return;

    // ✅ ดึงรายชื่อความเชี่ยวชาญทั้งหมด
    final checkRes = await http.get(Uri.parse("$url/special"));
    if (checkRes.statusCode == 200) {
      final List<dynamic> existingList = jsonDecode(checkRes.body);
      bool isDuplicate = existingList.any((item) =>
          item['name'].toString().toLowerCase() ==
          selectedSpecialty.toLowerCase());

      if (isDuplicate) {
        Get.snackbar(
            snackPosition: SnackPosition.TOP,
            "ไม่สามารถบันทึกข้อมูลได้",
            "ชื่อความเชี่ยวชาญนี้มีอยู่แล้ว",
            backgroundColor: Colors.orange,
            colorText: Colors.white);
        return; // ❌ หยุดบันทึก
      }
    } else {
      log("ไม่สามารถตรวจสอบความซ้ำได้: ${checkRes.statusCode}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("ไม่สามารถตรวจสอบความซ้ำได้"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ✅ แสดงโหลดหมุน
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF916B44)),
      ),
    );

    try {
      SpecialPost req = SpecialPost(
        name: selectedSpecialty,
        specialId: 0,
      );

      final res = await http.post(
        Uri.parse("$url/special"),
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: specialPostToJson([req]),
      );

      Navigator.of(context, rootNavigator: true).pop(); // ✅ ปิดโหลด

      if (res.statusCode == 200 || res.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "บันทึกสำเร็จ",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color(0xFF916B44),
          ),
        );

        _init(); // รีโหลดข้อมูล
      } else {
        log("📥 Status Code: ${res.statusCode}");
        log("📥 Response Body: ${res.body}");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("เกิดข้อผิดพลาด (${res.statusCode})"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop(); // ปิดโหลดถ้า error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("เกิดข้อผิดพลาด"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> confirmDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(
                color: Color(0xFF916B44),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF916B44),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.vaccines,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "ยืนยันการบันทึก",
                  style: TextStyle(
                    color: Color(0xFF916B44),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "คุณต้องการบันทึกข้อมูลความเชี่ยวชาญหรือไม่?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
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
                  border: Border.all(
                    color: const Color(0xFF916B44),
                    width: 1.5,
                  ),
                ),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF916B44),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "ยกเลิก",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF916B44),
                      Color(0xFFDBA871),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF916B44).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "ยืนยัน",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> confirmDeleteSpecialDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(
                color: Color(0xFF916B44),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.delete_forever,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "ยืนยันการลบข้อมูล",
                  style: TextStyle(
                    color: Color(0xFF916B44),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "คุณต้องการลบข้อมูลความเชี่ยวชาญหรือไม่?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
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
                  border: Border.all(
                    color: const Color(0xFF916B44),
                    width: 1.5,
                  ),
                ),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF916B44),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "ยกเลิก",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Color(0xFF916B44),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF916B44).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "ยืนยัน",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _init() {
    getSpecialData();
    setState(() {});
  }

  void _showSelectSpecialty() {
    TextEditingController searchController = TextEditingController();
    TextEditingController otherSpecialtyController = TextEditingController();
    List<String> allSpecialties = [...special.map((s) => s.name), "อื่นๆ"];
    List<String> filtered = List<String>.from(allSpecialties);
    List<String> tempSelected = List<String>.from(selectedSpecialty);
    bool isOtherSelected = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 16),
                    Container(
                      width: 50,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Color(0xFF916B44).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      isOtherSelected
                          ? 'เพิ่มความเชี่ยวชาญใหม่'
                          : 'เลือกความเชี่ยวชาญ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF916B44),
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          if (!isOtherSelected) ...[
                            // Selected Tags
                            if (tempSelected.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: tempSelected.toSet().map((item) {
                                  return Chip(
                                    label: Text(item),
                                    backgroundColor: Color(0xFFFAF8F5),
                                    deleteIcon: Icon(Icons.close, size: 18),
                                    onDeleted: () {
                                      setModalState(() {
                                        tempSelected.remove(item);
                                      });
                                    },
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        color:
                                            Color(0xFF916B44), // กรอบสีน้ำตาล
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  );
                                }).toList(),
                              ),

                            if (tempSelected.isNotEmpty)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () async {
                                    final confirm =
                                        await confirmDeleteSpecialDialog(
                                            context);
                                    if (!confirm)
                                      return; // ถ้าไม่ยืนยัน ให้หยุดการทำงาน

                                    for (final item in tempSelected) {
                                      await deleteSpecialByObject(item);
                                    }

                                    setState(() {
                                      selectedSpecialty.removeWhere((item) =>
                                          tempSelected.contains(item));
                                    });

                                    tempSelected.clear();
                                    Navigator.pop(context); // ปิด modal
                                  },
                                  icon: Icon(Icons.delete_forever,
                                      color: Colors.red),
                                  label: Text('ลบทั้งหมด',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ),
                            SizedBox(height: 10),

                            // Search Field
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF916B44).withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: searchController,
                                decoration: InputDecoration(
                                  hintText: 'ค้นหาความเชี่ยวชาญ',
                                  prefixIcon: Icon(Icons.search,
                                      color: Color(0xFF916B44)),
                                  suffixIcon: searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(Icons.clear,
                                              color: Color(0xFF916B44)),
                                          onPressed: () {
                                            searchController.clear();
                                            setModalState(() {
                                              filtered =
                                                  List.from(allSpecialties);
                                            });
                                          },
                                        )
                                      : null,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 16),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
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
                            ),
                            SizedBox(height: 20),

                            // List of specialties
                            Container(
                              constraints: BoxConstraints(maxHeight: 350),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF916B44).withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: filtered.isEmpty
                                    ? Container(
                                        height: 100,
                                        child: Center(
                                          child: Text(
                                            'ไม่พบความเชี่ยวชาญ',
                                            style: TextStyle(
                                              color: Color(0xFF916B44)
                                                  .withOpacity(0.6),
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      )
                                    : ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: filtered.length,
                                        itemBuilder: (context, index) {
                                          final item = filtered[index];
                                          final isSelected =
                                              tempSelected.contains(item);
                                          return item == "อื่นๆ"
                                              ? ListTile(
                                                  title: Text("อื่นๆ",
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xFF916B44),
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                  trailing: Icon(
                                                      Icons.arrow_forward_ios,
                                                      size: 16,
                                                      color: Color(0xFF916B44)),
                                                  onTap: () {
                                                    setModalState(() {
                                                      isOtherSelected = true;
                                                    });
                                                  },
                                                )
                                              : CheckboxListTile(
                                                  title: Text(item),
                                                  value: isSelected,
                                                  onChanged: (val) {
                                                    setModalState(() {
                                                      if (val == true) {
                                                        tempSelected.add(item);
                                                      } else {
                                                        tempSelected
                                                            .remove(item);
                                                      }
                                                    });
                                                  },
                                                  activeColor:
                                                      Color(0xFF916B44),
                                                );
                                        },
                                      ),
                              ),
                            ),
                            SizedBox(height: 20),

                            // Confirm Button
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        selectedSpecialty =
                                            List.from(tempSelected);
                                      });
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF916B44),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text("ตกลง",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500)),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          // กรอกอื่นๆ
                          if (isOtherSelected) ...[
                            TextField(
                              controller: otherSpecialtyController,
                              decoration: InputDecoration(
                                hintText: 'กรอกความเชี่ยวชาญอื่นๆ',
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF916B44), // สีน้ำตาล
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color:
                                        Color(0xFF916B44), // สีน้ำตาลเหมือนกัน
                                    width: 2,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF916B44),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setModalState(() {
                                        isOtherSelected = false;
                                        otherSpecialtyController.clear();
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Color(0xFF916B44),
                                      side:
                                          BorderSide(color: Color(0xFF916B44)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text("ยกเลิก"),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      final other =
                                          otherSpecialtyController.text.trim();
                                      if (other.isNotEmpty) {
                                        setState(() {
                                          selectedSpecialty.add(other);
                                        });
                                        await specialAdd(other);
                                      }
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF916B44),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text("บันทึก"),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> doctorAddNextButton() async {
    if (nameCtl.text.trim().isEmpty ||
        surnameCtl.text.trim().isEmpty ||
        selectedSpecialty == null ||
        careerNoCtl.text.trim().isEmpty ||
        selectedSpecialty.isEmpty) {
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

    if (careerNoCtl.text.trim().isEmpty || careerNoCtl.text.trim().length < 5) {
      Get.snackbar(
        'ข้อผิดพลาด',
        'กรุณากรอกเลขใบอนุญาตประกอบวิชาชีพให้ครบ 5 หลัก',
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
      Get.to(() => RegisterdoctoravatarPage());
    }
  }
}
