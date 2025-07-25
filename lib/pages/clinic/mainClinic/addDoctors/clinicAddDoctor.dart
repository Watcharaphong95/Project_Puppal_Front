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
  TextEditingController specialNoCtl = TextEditingController();
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
                        ),

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
    // controller.special.value = selectedSpecialId?.toString() ?? '';
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
    bool confirmed = await confirmDialog(context);
    if (!confirmed) return;

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
            content: Text("บันทึกสำเร็จ"),
            backgroundColor: Color(0xFF916B44),
          ),
        );

        _init(); // หรือ setState(() {...}) เพื่อรีโหลดข้อมูล
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

  void _init() {
    getSpecialData();
    setState(() {});
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

  void _showSelectSpecialty() {
    TextEditingController searchController = TextEditingController();
    TextEditingController otherSpecialtyController = TextEditingController();
    List<String> allSpecialties = [...special.map((s) => s.name), "อื่นๆ"];
    List<String> filtered = List<String>.from(allSpecialties);

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
                // color: Color(0xFFE9CBAF),
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 16),
                      // Handle Bar
                      Container(
                        width: 50,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Color(0xFF916B44).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Header
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
                            // Search Field
                            if (!isOtherSelected)
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
                                    hintStyle: TextStyle(
                                      color: Color(0xFF916B44).withOpacity(0.5),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: Color(0xFF916B44),
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: Color(0xFF916B44),
                                    ),
                                    suffixIcon: searchController.text.isNotEmpty
                                        ? IconButton(
                                            icon: Icon(
                                              Icons.clear,
                                              color: Color(0xFF916B44),
                                            ),
                                            onPressed: () {
                                              searchController.clear();
                                              setModalState(() {
                                                filtered = List<String>.from(
                                                    allSpecialties);
                                              });
                                            },
                                          )
                                        : null,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
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

                            // List Container
                            if (!isOtherSelected)
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
                                          padding: EdgeInsets.zero,
                                          itemCount: filtered.length,
                                          itemBuilder: (context, index) {
                                            final item = filtered[index];
                                            bool isSelected = selectedSpecialty
                                                .contains(item);

                                            return Container(
                                              margin: EdgeInsets.only(
                                                top: index == 0 ? 8 : 0,
                                                bottom:
                                                    index == filtered.length - 1
                                                        ? 8
                                                        : 0,
                                              ),
                                              child: item == "อื่นๆ"
                                                  ? Container(
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Color(0xFFDBA871)
                                                            .withOpacity(0.3),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: ListTile(
                                                        title: Text(
                                                          "อื่นๆ",
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xFF916B44),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        trailing: Icon(
                                                          Icons
                                                              .arrow_forward_ios,
                                                          color:
                                                              Color(0xFF916B44),
                                                          size: 16,
                                                        ),
                                                        onTap: () {
                                                          setModalState(() {
                                                            isOtherSelected =
                                                                true;
                                                          });
                                                        },
                                                      ),
                                                    )
                                                  : Container(
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: isSelected
                                                            ? Color(0xFFDBA871)
                                                                .withOpacity(
                                                                    0.2)
                                                            : Colors
                                                                .transparent,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        border: isSelected
                                                            ? Border.all(
                                                                color: Color(
                                                                        0xFF916B44)
                                                                    .withOpacity(
                                                                        0.3),
                                                                width: 1,
                                                              )
                                                            : null,
                                                      ),
                                                      child: CheckboxListTile(
                                                        title: Text(
                                                          item,
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xFF916B44),
                                                            fontWeight:
                                                                isSelected
                                                                    ? FontWeight
                                                                        .w500
                                                                    : FontWeight
                                                                        .w400,
                                                          ),
                                                        ),
                                                        value: isSelected,
                                                        activeColor:
                                                            Color(0xFF916B44),
                                                        checkColor:
                                                            Colors.white,
                                                        onChanged:
                                                            (bool? selected) {
                                                          setModalState(() {
                                                            if (selected ==
                                                                true) {
                                                              selectedSpecialty
                                                                  .add(item);
                                                            } else {
                                                              selectedSpecialty
                                                                  .remove(item);
                                                            }
                                                          });
                                                        },
                                                      ),
                                                    ),
                                            );
                                          },
                                        ),
                                ),
                              ),

                            // Other Specialty Input
                            if (isOtherSelected) ...[
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
                                  controller: otherSpecialtyController,
                                  decoration: InputDecoration(
                                    hintText: 'กรอกความเชี่ยวชาญอื่นๆ',
                                    hintStyle: TextStyle(
                                      color: Color(0xFF916B44).withOpacity(0.5),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: Color(0xFF916B44),
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),

                              // Action Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 48,
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
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            side: BorderSide(
                                              color: Color(0xFF916B44),
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          "ยกเลิก",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Container(
                                      height: 48,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          if (isOtherSelected &&
                                              otherSpecialtyController.text
                                                  .trim()
                                                  .isNotEmpty) {
                                            selectedSpecialty.add(
                                                otherSpecialtyController.text
                                                    .trim());
                                            await specialAdd(
                                                otherSpecialtyController.text
                                                    .trim());
                                          }

                                          setState(() {
                                            selectedSpecialty =
                                                List.from(selectedSpecialty);
                                          });

                                          Navigator.pop(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF916B44),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: Text(
                                          "บันทึก",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
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
