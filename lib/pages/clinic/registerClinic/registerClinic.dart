import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:get/get.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/controller/registerClinicCtl.dart';
import 'package:http/http.dart' as http;
import 'package:puppal_application/pages/clinic/registerClinic/registerClinicLocationSelect.dart';

class RegisterclinicPage extends StatefulWidget {
  const RegisterclinicPage({super.key});

  @override
  State<RegisterclinicPage> createState() => _RegisterclinicPageState();
}

class _RegisterclinicPageState extends State<RegisterclinicPage> {
  late double screenWidth;
  late double screenHeight;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
  List<String> selectedWeekdays = [];
  TimeOfDay? openTime;
  TimeOfDay? closeTime;
  final controller = Get.find<registerClinicCtl>();

  TextEditingController nameCtl = TextEditingController();
  TextEditingController emailCtl = TextEditingController();
  TextEditingController phoneCtl = TextEditingController();
  TextEditingController passwordCtl = TextEditingController();
  TextEditingController confirmPasswordCtl = TextEditingController();
  TextEditingController openCtl = TextEditingController();
  TextEditingController closeCtl = TextEditingController();
  TextEditingController numPerTimeCtl = TextEditingController();
  TextEditingController addressCtl = TextEditingController();

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
        appBar: AppBar(
          title: const Text(
            "สมัครสมาชิกคลินิก",
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
            color: Color(0xFFFAF8F5),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                spacing: 16,
                children: [
                  // ชื่อคลินิก
                  _buildModernTextField(
                    label: 'ชื่อคลินิก',
                    controller: nameCtl,
                    icon: Icons.business,
                    screenHeight: screenHeight,
                  ),

                  // อีเมล
                  _buildModernTextField(
                    label: 'อีเมล',
                    controller: emailCtl,
                    icon: Icons.email_outlined,
                    screenHeight: screenHeight,
                  ),

                  // เบอร์โทรศัพท์
                  _buildModernTextField(
                    label: 'เบอร์โทรศัพท์',
                    controller: phoneCtl,
                    icon: Icons.phone_outlined,
                    screenHeight: screenHeight,
                  ),

                  // รหัสผ่าน
                  _buildPasswordTextField(
                    label: 'รหัสผ่าน',
                    controller: passwordCtl,
                    isObscure: _obscurePassword,
                    onToggleVisibility: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                    screenHeight: screenHeight,
                  ),

                  // ยืนยันรหัสผ่าน
                  _buildPasswordTextField(
                    label: 'ยืนยันรหัสผ่าน',
                    controller: confirmPasswordCtl,
                    isObscure: _obscureConfirmPassword,
                    onToggleVisibility: () {
                      setState(() =>
                          _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                    screenHeight: screenHeight,
                  ),

                  // เลือกวันเปิดทำการ
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          "เลือกวันเปิดทำการ",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF916B44),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20),
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
                        child: Wrap(
                          alignment: WrapAlignment.center, // เพิ่มตรงนี้
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
                                        : Color(0xFFE9CBAF),
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: Color(0xFF916B44)
                                                .withOpacity(0.3),
                                            offset: Offset(0, 2),
                                            blurRadius: 8,
                                            spreadRadius: 0,
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Center(
                                  child: Text(
                                    daysShort[index],
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Color(0xFF916B44),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),

                  // เวลาเปิดคลินิก
                  _buildTimeTextField(
                    label: 'เวลาเปิดคลินิก',
                    controller: openCtl,
                    hintText: "เลือกเวลาเปิดคลินิก",
                    onTap: () => _showCustomTimePicker(isOpen: true),
                    screenHeight: screenHeight,
                  ),

                  // เวลาปิดคลินิก
                  _buildTimeTextField(
                    label: 'เวลาปิดคลินิก',
                    controller: closeCtl,
                    hintText: "เลือกเวลาปิดคลินิก",
                    onTap: () => _showCustomTimePicker(isOpen: false),
                    screenHeight: screenHeight,
                  ),

                  // จำนวนคำขอต่อช่วงเวลา
                  _buildTimeTextField(
                    label: 'จำนวนคำขอต่อช่วงเวลา',
                    controller: numPerTimeCtl,
                    hintText: "เลือกจำนวนคำขอต่อช่วงเวลา",
                    onTap: _showSelectNum,
                    screenHeight: screenHeight,
                  ),

                  // ที่อยู่คลินิก
                  _buildModernTextField(
                    label: 'ที่อยู่คลินิก',
                    controller: addressCtl,
                    icon: Icons.location_on_outlined,
                    screenHeight: screenHeight,
                  ),

                  // ปุ่มถัดไป
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 20, 0, screenHeight * 0.05),
                    child: Container(
                      width: screenWidth * 0.5,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color(0xFF916B44),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF916B44).withOpacity(0.3),
                            offset: Offset(0, 4),
                            blurRadius: 12,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: userRegisterNextButton,
                        child: Text(
                          'ถัดไป',
                          style: TextStyle(
                            fontSize: 18,
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

// Password Text Field Widget
  Widget _buildPasswordTextField({
    required String label,
    required TextEditingController controller,
    required bool isObscure,
    required VoidCallback onToggleVisibility,
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
            obscureText: isObscure,
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
                  Icons.lock_outline,
                  color: Color(0xFF916B44),
                  size: 20,
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  isObscure ? Icons.visibility_off : Icons.visibility,
                  color: Color(0xFF916B44).withOpacity(0.7),
                ),
                onPressed: onToggleVisibility,
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

// Time/Selection Text Field Widget
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

  Future<void> userRegisterNextButton() async {
    showLoadingDialog();
    if (nameCtl.text.trim().isEmpty ||
        emailCtl.text.trim().isEmpty ||
        passwordCtl.text.trim().isEmpty ||
        phoneCtl.text.trim().isEmpty ||
        addressCtl.text.trim().isEmpty ||
        openCtl.text.trim().isEmpty ||
        closeCtl.text.trim().isEmpty ||
        selectedWeekdays.isEmpty ||
        numPerTimeCtl.text.trim().isEmpty) {
      Get.back();
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
    RegExp phoneRegExp = RegExp(r'^[0-9]{10}$');
    if (!phoneRegExp.hasMatch(phoneCtl.text.trim())) {
      Get.back();
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
      Get.back();
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

    final password = passwordCtl.text;
    final hasUpper = RegExp(r'[A-Z]').hasMatch(password);
    final hasLower = RegExp(r'[a-z]').hasMatch(password);
    final hasDigit = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecial =
        RegExp(r'[!@#\$%^&*(),.":{}|_]').hasMatch(password); // ✅ แก้แล้ว

    if (password.length < 8 ||
        !hasUpper ||
        !hasLower ||
        !hasDigit ||
        !hasSpecial) {
      Get.back();

      Get.snackbar(
        'ข้อผิดพลาด',
        'รหัสผ่านควรมีอย่างน้อย 8 ตัวอักษรและประกอบด้วย A-Z, a-z, ตัวเลข และอักขระพิเศษ',
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

// Password match check
    if (passwordCtl.text != confirmPasswordCtl.text) {
      Get.back();
      Get.snackbar(
        'ข้อผิดพลาด',
        'รหัสผ่านไม่ตรงกัน',
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

    controller.name.value = nameCtl.text;
    controller.email.value = emailCtl.text;
    controller.password.value = passwordCtl.text;
    controller.phone.value = phoneCtl.text;
    controller.open.value = openCtl.text;
    controller.close.value = closeCtl.text;
    controller.weekdays.value = selectedWeekdays.join(',');
    controller.numPerTime.value = int.parse(numPerTimeCtl.text);
    controller.address.value = addressCtl.text;

    var res = await http.get(Uri.parse("$url/user/${emailCtl.text}"));
    Get.back();
    if (res.statusCode == 200) {
      Get.snackbar(
        'ข้อผิดพลาด',
        'อีเมลนี้เคยสมัครสมาชิกไปแล้ว\nกรุณาเข้าสู่ระบบหากเป็นผู้ใช้ทั่วไปแล้วต้องการเปลี่ยนไปยังคลินิก',
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
      Get.to(() => CliniclocationselectPage());
    }
    log(res.body);
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
                            // openCtl.text = time;
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

  void _showCustomTimePicker({required bool isOpen}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return TimePickerBottomSheet(
          isOpenTime: isOpen,
          initialTime: isOpen ? openTime : closeTime,
          onTimeSelected: (selected) {
            setState(() {
              if (isOpen) {
                openTime = selected;
                openCtl.text = selected.format(context);
              } else {
                closeTime = selected;
                closeCtl.text = selected.format(context);
              }
            });
          },
        );
      },
    );
  }

  // void _showCloseSelectTime() async {
  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: Colors.white,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (context) {
  //       final List<String> availableTimes = _timeSelect.where((time) {
  //         if (openCtl.text.isEmpty) return true;

  //         final openParts = openCtl.text.split(':').map(int.parse).toList();
  //         final closeParts = time.split(':').map(int.parse).toList();

  //         final openMinutes = openParts[0] * 60 + openParts[1];
  //         final closeMinutes = closeParts[0] * 60 + closeParts[1];

  //         return closeMinutes > openMinutes;
  //       }).toList();

  //       return Container(
  //         height: 350,
  //         padding: EdgeInsets.all(16),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Center(
  //               child: Container(
  //                 width: 40,
  //                 height: 5,
  //                 decoration: BoxDecoration(
  //                   color: Colors.grey[300],
  //                   borderRadius: BorderRadius.circular(10),
  //                 ),
  //               ),
  //             ),
  //             SizedBox(height: 16),
  //             Center(
  //               child: Text(
  //                 'เลือกเวลาปิดคลินิก',
  //                 style: TextStyle(
  //                   fontSize: 22,
  //                   fontWeight: FontWeight.bold,
  //                   color: Color(0xFF916b44), // ใช้สีทองน้ำตาล
  //                 ),
  //               ),
  //             ),
  //             SizedBox(height: 16),
  //             Expanded(
  //               child: ListView.builder(
  //                 itemCount: availableTimes.length,
  //                 itemBuilder: (context, index) {
  //                   final time = availableTimes[index];
  //                   return Card(
  //                     elevation: 2,
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(12),
  //                     ),
  //                     child: ListTile(
  //                       title: Center(
  //                         child: Text(
  //                           time,
  //                           style: TextStyle(
  //                             fontSize: 20,
  //                             fontWeight: FontWeight.bold,
  //                             color: Color(0xFF916b44),
  //                           ),
  //                         ),
  //                       ),
  //                       onTap: () {
  //                         setState(() {
  //                           closeCtl.text = time;
  //                         });
  //                         Navigator.pop(context);
  //                       },
  //                     ),
  //                   );
  //                 },
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  void _showSelectNum() async {
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
                  'เลือกจำนวนคำขอที่รับได้ต่อช่วงเวลา',
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
                  itemCount: _numPerTime.length,
                  itemBuilder: (context, index) {
                    final time = _numPerTime[index];
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
                              color: Color(0xFF916b44), // ใช้สีทองน้ำตาล
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            numPerTimeCtl.text = time;
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
  final TimeOfDay? initialTime;
  final bool isOpenTime;
  final Function(TimeOfDay) onTimeSelected;

  const TimePickerBottomSheet({
    Key? key,
    required this.initialTime,
    required this.isOpenTime,
    required this.onTimeSelected,
  }) : super(key: key);

  @override
  State<TimePickerBottomSheet> createState() => _TimePickerBottomSheetState();
}

class _TimePickerBottomSheetState extends State<TimePickerBottomSheet> {
  late DateTime selectedTime;

  static const Color primaryColor = Color(0xFF916B44);
  static const Color secondaryColor = Color(0xFFDBA871);
  static const Color tertiaryColor = Color(0xFFE9CBAF);

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final time = widget.initialTime ?? TimeOfDay.now();
    selectedTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.isOpenTime ? "เลือกเวลาเปิด" : "เลือกเวลาปิด",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Icon(
                  widget.isOpenTime ? Icons.wb_sunny : Icons.nightlight_round,
                  color: Colors.white,
                ),
              ],
            ),
          ),

          // Time Display
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: tertiaryColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: secondaryColor.withOpacity(0.3),
              ),
            ),
            child: Text(
              "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}",
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Time Picker Spinner
          Expanded(
            child: TimePickerSpinner(
              time: selectedTime,
              is24HourMode: true,
              normalTextStyle: TextStyle(
                fontSize: 18,
                color: primaryColor.withOpacity(0.6),
              ),
              highlightedTextStyle: TextStyle(
                fontSize: 22,
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
              spacing: 40,
              itemHeight: 60,
              isForce2Digits: true,
              minutesInterval: 5,
              onTimeChange: (time) {
                setState(() {
                  selectedTime = time;
                });
              },
            ),
          ),

          // Buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryColor),
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
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onTimeSelected(
                        TimeOfDay.fromDateTime(selectedTime),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
