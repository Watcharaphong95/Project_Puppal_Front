import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/controller/registerClinicCtl.dart';
import 'package:http/http.dart' as http;
import 'package:puppal_application/pages/clinic/mainClinic/clinicOpeningHours.dart';
import 'package:puppal_application/pages/clinic/registerClinic/registerClinicLocationSelect.dart';

class RegisterclinicgooglePage extends StatefulWidget {
  const RegisterclinicgooglePage({super.key});

  @override
  State<RegisterclinicgooglePage> createState() =>
      _RegisterclinicgooglePageState();
}

class _RegisterclinicgooglePageState extends State<RegisterclinicgooglePage> {
  late double screenWidth;
  late double screenHeight;

  String url = "";

  final List<String> _timeSelect = List.generate(48, (index) {
    final hour = (index ~/ 2).toString().padLeft(2, '0');
    final minute = (index % 2 == 0) ? '00' : '30';
    return '$hour:$minute';
  });

  final List<String> _numPerTime = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10'
  ];

  final controller = Get.find<registerClinicCtl>();
  final box = GetStorage();
  List<String> selectedWeekdays = [];
  TimeOfDay? openTime;
  TimeOfDay? closeTime;

  TextEditingController nameCtl = TextEditingController();
  TextEditingController emailCtl = TextEditingController();
  TextEditingController phoneCtl = TextEditingController();
  TextEditingController openCtl = TextEditingController();
  TextEditingController closeCtl = TextEditingController();
  TextEditingController numPerTimeCtl = TextEditingController();
  TextEditingController addressCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
    if (box.read('emailGoogleRegister') != null) {
      emailCtl.text = box.read('emailGoogleRegister');
    } else {
      emailCtl.text = box.read('email');
    }
  }

  void init() async {
    await Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
    });
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'สมัครคลินิก',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF916B44),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          child: Container(
            color: Color(0xFFFAF8F5),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
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
                            Icons.person_add,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'ข้อมูลคลินิก',
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
                  // ชื่อคลินิก (ใช้ _buildModernTextField)
                  _buildModernTextField(
                    label: 'ชื่อคลินิก',
                    controller: nameCtl,
                    icon: Icons.local_hospital_outlined,
                    screenHeight: screenHeight,
                  ),

                  SizedBox(height: 16),

                  // อีเมล (readOnly + ใช้ _buildModernTextField)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          'อีเมล',
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
                          controller: emailCtl,
                          enabled: false,
                          readOnly: true,
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
                                Icons.email_outlined,
                                color: Color(0xFF916B44),
                                size: 20,
                              ),
                            ),
                            border: InputBorder.none,
                            hintText: 'กรอกอีเมล',
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
                  ),

                  SizedBox(height: 16),

                  // เบอร์โทรศัพท์
                  _buildModernTextField(
                      label: 'เบอร์โทรศัพท์',
                      controller: phoneCtl,
                      icon: Icons.phone_outlined,
                      screenHeight: screenHeight,
                      keyboardType: TextInputType.phone),

                  SizedBox(height: 24),

                  // เลือกวันเปิดทำการ (ยังคงโค้ดเดิม)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "เลือกวันเปิดทำการ",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF916B44),
                        ),
                      ),
                      SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(7, (index) {
                          final days = [
                            'Monday',
                            'Tuesday',
                            'Wednesday',
                            'Thursday',
                            'Friday',
                            'Saturday',
                            'Sunday'
                          ];
                          final daysShort = [
                            'จ',
                            'อ',
                            'พ',
                            'พฤ',
                            'ศ',
                            'ส',
                            'อา'
                          ];
                          final day = days[index];
                          final isSelected = selectedWeekdays.contains(day);

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  selectedWeekdays.remove(day);
                                } else {
                                  selectedWeekdays.add(day);
                                }
                              });
                            },
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Color(0xFF916B44)
                                    : Colors.white,
                                border: Border.all(
                                  color: isSelected
                                      ? Color(0xFF916B44)
                                      : Colors.grey,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  daysShort[index],
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Color(0xFF916B44),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  _buildTimeTextField(
                    label: 'เวลาเปิดคลินิก',
                    controller: openCtl,
                    hintText: "เลือกเวลาเปิดคลินิก",
                    onTap: () => _showCustomTimePicker(isOpen: true),
                    screenHeight: screenHeight,
                  ),
                  SizedBox(height: 24),
// เวลาปิดคลินิก
                  _buildTimeTextField(
                    label: 'เวลาปิดคลินิก',
                    controller: closeCtl,
                    hintText: "เลือกเวลาปิดคลินิก",
                    onTap: () => _showCustomTimePicker(isOpen: false),
                    screenHeight: screenHeight,
                  ),
                  SizedBox(height: 24),

                  // จำนวนคำขอต่อช่วงเวลา
                  _buildTimeTextField(
                    label: 'จำนวนคำขอต่อช่วงเวลา',
                    controller: numPerTimeCtl,
                    hintText: "เลือกจำนวนคำขอต่อช่วงเวลา",
                    onTap: _showSelectNum,
                    screenHeight: screenHeight,
                  ),

                  SizedBox(height: 24),

                  // ที่อยู่คลินิก
                  _buildModernTextField(
                    label: 'ที่อยู่คลินิก',
                    controller: addressCtl,
                    icon: Icons.location_on_outlined,
                    screenHeight: screenHeight,
                  ),

                  SizedBox(height: 40),

                  // ปุ่มถัดไป
                  Padding(
                    padding: EdgeInsets.only(bottom: screenHeight * 0.05),
                    child: SizedBox(
                      width: screenWidth * 0.5,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Color(0xFF916B44),
                        ),
                        onPressed: userRegisterNextButton,
                        child: Text(
                          'ถัดไป',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildTimeTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required VoidCallback onTap,
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
                    Icons.access_time,
                    color: Color(0xFF916B44),
                    size: 20,
                  ),
                ),
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? hintText : controller.text,
                    style: TextStyle(
                      color: controller.text.isEmpty
                          ? Color(0xFF916B44).withOpacity(0.5)
                          : Color(0xFF916B44),
                      fontSize: 16,
                      fontWeight: controller.text.isEmpty
                          ? FontWeight.normal
                          : FontWeight.w500,
                    ),
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

// Modern Text Field Widget
  Widget _buildModernTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required double screenHeight,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters, // ✅ เพิ่มตรงนี้
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
            keyboardType: keyboardType,
            inputFormatters: inputFormatters, // ✅ เพิ่มตรงนี้
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

  // Method สำหรับแสดง Time Picker
  void _showCustomTimePicker({required bool isOpen}) async {
    final result = await showModalBottomSheet<TimeOfDay>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TimePickerBottomSheet(
        isOpenTime: isOpen,
        initialTime: isOpen
            ? (openCtl.text.isNotEmpty
                ? _parseTimeString(openCtl.text)
                : TimeOfDay(hour: 8, minute: 0))
            : (closeCtl.text.isNotEmpty
                ? _parseTimeString(closeCtl.text)
                : _parseTimeString(openCtl.text)),
        openTime: !isOpen && openCtl.text.isNotEmpty
            ? _parseTimeString(openCtl.text)
            : null, // Pass opening time for closing picker
        onTimeSelected: (time) {
          setState(() {
            if (isOpen) {
              openCtl.text =
                  "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

              // Clear closing time if it's now invalid (earlier than or equal to opening time)
              if (closeCtl.text.isNotEmpty) {
                final closeTime = _parseTimeString(closeCtl.text);
                if (_isTimeEarlierOrEqual(closeTime, time)) {
                  closeCtl.text = '';
                }
              }
            } else {
              closeCtl.text =
                  "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
            }
          });
        },
      ),
    );
  }

// Helper method สำหรับแปลง string เป็น TimeOfDay
  TimeOfDay _parseTimeString(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  // Helper method to check if time1 is earlier than or equal to time2
  bool _isTimeEarlierOrEqual(TimeOfDay time1, TimeOfDay time2) {
    if (time1.hour < time2.hour) return true;
    if (time1.hour > time2.hour) return false;
    return time1.minute <= time2.minute;
  }

// Method สำหรับเลือกจำนวนคำขอ (ปรับปรุงแล้ว)
  void _showSelectNum() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 12),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Header
              Container(
                padding: EdgeInsets.all(20),
                child: Text(
                  'เลือกจำนวนคำขอที่รับได้ต่อช่วงเวลา',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF916B44),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Options list
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: ListView.builder(
                    itemCount: _numPerTime.length,
                    itemBuilder: (context, index) {
                      final time = _numPerTime[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
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
                              blurRadius: 8,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              numPerTimeCtl.text = time;
                            });
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: Text(
                                time,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF916B44),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> userRegisterNextButton() async {
    if (nameCtl.text.trim().isEmpty ||
        emailCtl.text.trim().isEmpty ||
        phoneCtl.text.trim().isEmpty ||
        addressCtl.text.trim().isEmpty ||
        // openCtl.text.trim().isEmpty ||
        // closeCtl.text.trim().isEmpty ||
        numPerTimeCtl.text.trim().isEmpty) {
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

    // Phone number format check (simple 10-digit validation).
    RegExp phoneRegExp = RegExp(r'^0[0-9]{9}$');
    if (!phoneRegExp.hasMatch(phoneCtl.text.trim())) {
      Get.snackbar(
        'ข้อผิดพลาด',
        'กรุณากรอกหมายเลขโทรศัพท์ที่ถูกต้อง',
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

    // Email format check
    RegExp emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(emailCtl.text.trim())) {
      Get.snackbar(
        'ข้อผิดพลาด',
        'กรุณากรอกอีเมลที่ถูกต้อง',
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

    showLoadingDialog();

    controller.name.value = nameCtl.text;
    controller.email.value = emailCtl.text;
    controller.password.value = '';
    controller.phone.value = phoneCtl.text;
    controller.open.value = openCtl.text;
    controller.close.value = closeCtl.text;
    controller.weekdays.value = selectedWeekdays.join(',');
    controller.numPerTime.value = int.parse(numPerTimeCtl.text);
    controller.address.value = addressCtl.text;

    // var res = await http.get(Uri.parse("$url/user/${emailCtl.text}"));
    Get.back();
    Get.to(() => CliniclocationselectPage());
    // if (res.statusCode == 200) {
    //   Get.snackbar(
    //     'ข้อผิดพลาด',
    //     'อีเมลนี้เคยสมัครสมาชิกไปแล้ว\nกรุณาเข้าสู่ระบบหากเป็นผู้ใช้ทั่วไปแล้วต้องการเปลี่ยนไปยังคลินิก',
    //     snackPosition: SnackPosition.TOP,
    //     backgroundColor: const Color.fromARGB(255, 211, 89, 89),
    //     colorText: Colors.white,
    //     borderRadius: 12,
    //     margin: const EdgeInsets.all(16),
    //     duration: const Duration(seconds: 2),
    //     snackStyle: SnackStyle.FLOATING,
    //     isDismissible: true,
    //   );
    //   return;
    // } else {
    //   Get.to(() => CliniclocationselectPage());
    // }
  }

  void _showOpenSelectTime() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: 350,
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              SizedBox(height: 16),
              Center(
                child: Text(
                  'เลือกเวลาเปิดคลินิก',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF916b44), // สีเดียวกับปุ่ม
                  ),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _timeSelect.length,
                  itemBuilder: (context, index) {
                    final time = _timeSelect[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Center(
                          child: Text(
                            time,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF916b44), // สีตัวหนังสือ
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            openCtl.text = time;
                          });
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCloseSelectTime() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final List<String> availableTimes = _timeSelect.where((time) {
          if (openCtl.text.isEmpty) return true;

          final openParts = openCtl.text.split(':').map(int.parse).toList();
          final closeParts = time.split(':').map(int.parse).toList();

          final openMinutes = openParts[0] * 60 + openParts[1];
          final closeMinutes = closeParts[0] * 60 + closeParts[1];

          return closeMinutes > openMinutes;
        }).toList();

        return Container(
          height: 350,
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              SizedBox(height: 16),
              Center(
                child: Text(
                  'เลือกเวลาปิดคลินิก',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF916b44), // ใช้สีทองน้ำตาล
                  ),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: availableTimes.length,
                  itemBuilder: (context, index) {
                    final time = availableTimes[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Center(
                          child: Text(
                            time,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF916b44),
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            closeCtl.text = time;
                          });
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
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
}

// Time Picker Bottom Sheet using time_picker_spinner package
class TimePickerBottomSheet extends StatefulWidget {
  final bool isOpenTime;
  final TimeOfDay? initialTime;
  final Function(TimeOfDay) onTimeSelected;
  final TimeOfDay?
      openTime; // Add this parameter to pass opening time for closing picker

  const TimePickerBottomSheet({
    Key? key,
    required this.isOpenTime,
    this.initialTime,
    required this.onTimeSelected,
    this.openTime, // Optional opening time for validation
  }) : super(key: key);

  @override
  State<TimePickerBottomSheet> createState() => _TimePickerBottomSheetState();
}

class _TimePickerBottomSheetState extends State<TimePickerBottomSheet> {
  late int selectedHour;
  late int selectedMinute;

  static const Color primaryColor = Color(0xFF916B44);
  static const Color secondaryColor = Color(0xFFDBA871);
  static const Color tertiaryColor = Color(0xFFE9CBAF);

  // เวลาที่เหมาะสมสำหรับคลินิก
  List<int> get availableHours {
    if (widget.isOpenTime) {
      // เวลาเปิด: แสดงทุกชั่วโมง 0-23
      return List.generate(24, (index) => index); // 0,1,2,...,23
    } else {
      // เวลาปิด: แสดงเฉพาะชั่วโมงที่มากกว่าเวลาเปิด
      if (widget.openTime != null) {
        final openHour = widget.openTime!.hour;
        final openMinute = widget.openTime!.minute;

        List<int> hours = [];

        // Add hours after opening hour
        for (int hour = openHour + 1; hour <= 23; hour++) {
          hours.add(hour);
        }

        // If opening minute is 0, also allow same hour with 30 minutes
        if (openMinute == 0) {
          hours.insert(0, openHour);
        }

        return hours.isEmpty ? [openHour + 1] : hours;
      } else {
        // Default fallback if no opening time provided
        return List.generate(
            11, (index) => 12 + index); // 12,13,14,15,16,17,18,19,20,21,22
      }
    }
  }

  // นาทีทีละ 30 นาที
  List<int> get availableMinutes {
    if (!widget.isOpenTime && widget.openTime != null) {
      final openHour = widget.openTime!.hour;
      final openMinute = widget.openTime!.minute;

      // If selected hour is same as opening hour, only show minutes after opening minute
      if (selectedHour == openHour) {
        if (openMinute == 0) {
          return [30]; // Only 30 minutes available
        } else {
          return []; // No available minutes if opening is at 30
        }
      }
    }
    return [0, 30]; // Default: 0 and 30 minutes
  }

  @override
  void initState() {
    super.initState();
    final time = widget.initialTime ??
        (widget.isOpenTime
            ? TimeOfDay(hour: 8, minute: 0)
            : TimeOfDay(hour: 17, minute: 0));

    selectedHour = time.hour;
    selectedMinute = time.minute;

    // ปรับให้อยู่ในช่วงที่เหมาะสม
    if (!availableHours.contains(selectedHour)) {
      selectedHour = availableHours.first;
    }

    // Update available minutes after setting hour
    final currentAvailableMinutes = availableMinutes;
    if (!currentAvailableMinutes.contains(selectedMinute)) {
      selectedMinute = currentAvailableMinutes.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.isOpenTime
                      ? "เลือกเวลาเปิดคลินิก"
                      : "เลือกเวลาปิดคลินิก",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Icon(
                  widget.isOpenTime ? Icons.wb_sunny : Icons.nightlight_round,
                  color: Colors.white,
                  size: 28,
                ),
              ],
            ),
          ),

          // Time Display
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: tertiaryColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: secondaryColor.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Text(
              "${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}",
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: primaryColor,
                letterSpacing: 2,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: 20),

          // Beautiful Time Picker with Cream Highlight
          Expanded(
            child: Column(
              children: [
                SizedBox(height: 10),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Color(0xFFFAF2EA), // สีครีมอ่อน
                      border: Border.all(
                        color: secondaryColor.withOpacity(0.5),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.1),
                          blurRadius: 15,
                          offset: Offset(0, 5),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Cream highlight bar ครอบทั้งชั่วโมงและนาที
                        Positioned.fill(
                          child: Center(
                            child: Container(
                              height: 55,
                              margin: EdgeInsets.symmetric(horizontal: 15),
                              decoration: BoxDecoration(
                                color: Color(0xFFE9CBAF)
                                    .withOpacity(0.6), // สีครีมเข้มขึ้น
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: primaryColor.withOpacity(0.2),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Time Pickers Row
                        Row(
                          children: [
                            // Hour Picker
                            Expanded(
                              flex: 2,
                              child: ListWheelScrollView.useDelegate(
                                itemExtent: 50,
                                diameterRatio: 2.5,
                                perspective: 0.002,
                                squeeze: 1.0,
                                physics: FixedExtentScrollPhysics(),
                                controller: FixedExtentScrollController(
                                  initialItem:
                                      availableHours.contains(selectedHour)
                                          ? availableHours.indexOf(selectedHour)
                                          : 0,
                                ),
                                onSelectedItemChanged: (index) {
                                  setState(() {
                                    selectedHour = availableHours[index];

                                    // Update minutes when hour changes (for closing time)
                                    final currentAvailableMinutes =
                                        availableMinutes;
                                    if (!currentAvailableMinutes
                                        .contains(selectedMinute)) {
                                      selectedMinute =
                                          currentAvailableMinutes.isNotEmpty
                                              ? currentAvailableMinutes.first
                                              : 0;
                                    }
                                  });
                                },
                                childDelegate: ListWheelChildBuilderDelegate(
                                  childCount: availableHours.length,
                                  builder: (context, index) {
                                    if (index < 0 ||
                                        index >= availableHours.length)
                                      return null;
                                    final hour = availableHours[index];
                                    final isSelected = hour == selectedHour;

                                    return Opacity(
                                      opacity: (index -
                                                      availableHours.indexOf(
                                                          selectedHour))
                                                  .abs() <=
                                              1
                                          ? 1.0
                                          : 0.3,
                                      child: Center(
                                        child: Text(
                                          hour.toString().padLeft(2, '0'),
                                          style: TextStyle(
                                            fontSize: isSelected ? 28 : 22,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? primaryColor
                                                : primaryColor.withOpacity(0.6),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            // Colon separator (:)
                            Container(
                              width: 20,
                              child: Center(
                                child: Text(
                                  ':',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ),

                            // Minute Picker
                            Expanded(
                              flex: 2,
                              child: availableMinutes.isNotEmpty
                                  ? ListWheelScrollView.useDelegate(
                                      itemExtent: 50,
                                      diameterRatio: 2.5,
                                      perspective: 0.002,
                                      squeeze: 1.0,
                                      physics: FixedExtentScrollPhysics(),
                                      controller: FixedExtentScrollController(
                                        initialItem: availableMinutes
                                                .contains(selectedMinute)
                                            ? availableMinutes
                                                .indexOf(selectedMinute)
                                            : 0,
                                      ),
                                      onSelectedItemChanged: (index) {
                                        setState(() {
                                          selectedMinute =
                                              availableMinutes[index];
                                        });
                                      },
                                      childDelegate:
                                          ListWheelChildBuilderDelegate(
                                        childCount: availableMinutes.length,
                                        builder: (context, index) {
                                          if (index < 0 ||
                                              index >= availableMinutes.length)
                                            return null;
                                          final minute =
                                              availableMinutes[index];
                                          final isSelected =
                                              minute == selectedMinute;

                                          return Opacity(
                                            opacity: (index -
                                                            availableMinutes
                                                                .indexOf(
                                                                    selectedMinute))
                                                        .abs() <=
                                                    1
                                                ? 1.0
                                                : 0.3,
                                            child: Center(
                                              child: Text(
                                                minute
                                                    .toString()
                                                    .padLeft(2, '0'),
                                                style: TextStyle(
                                                  fontSize:
                                                      isSelected ? 28 : 22,
                                                  fontWeight: isSelected
                                                      ? FontWeight.bold
                                                      : FontWeight.w500,
                                                  color: isSelected
                                                      ? primaryColor
                                                      : primaryColor
                                                          .withOpacity(0.6),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        '00',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor.withOpacity(0.3),
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),

          // Buttons
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryColor, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "ยกเลิก",
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: availableMinutes.isNotEmpty
                          ? () {
                              widget.onTimeSelected(
                                TimeOfDay(
                                    hour: selectedHour, minute: selectedMinute),
                              );
                              Navigator.pop(context);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "ตกลง",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
