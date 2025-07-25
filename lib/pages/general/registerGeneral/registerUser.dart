import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/controller/registerGeneralCtl.dart';
import 'package:puppal_application/pages/general/registerGeneral/registerUserLocationSelect.dart';
import 'package:http/http.dart' as http;

class RegisteruserPage extends StatefulWidget {
  const RegisteruserPage({super.key});

  @override
  State<RegisteruserPage> createState() => _RegisteruserPageState();
}

class _RegisteruserPageState extends State<RegisteruserPage> {
  late double screenWidth;
  late double screenHeight;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String url = "";

  final controller = Get.find<RegisterGeneralCtl>();

  TextEditingController usernameCtl = TextEditingController();
  TextEditingController nameCtl = TextEditingController();
  TextEditingController surnameCtl = TextEditingController();
  TextEditingController emailCtl = TextEditingController();
  TextEditingController phoneCtl = TextEditingController();
  TextEditingController passwordCtl = TextEditingController();
  TextEditingController confirmPasswordCtl = TextEditingController();
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
        centerTitle: true,
        title: const Text('สมัครสมาชิกผู้ใช้ทั่วไป',
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600)),
        backgroundColor: Color(0xFFDBA871),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(color: Color(0xFFFAF8F5)),
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
                            Icons.person_add,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'ข้อมูลผู้ใช้',
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

                  Container(
                    child: Column(
                      children: [
                        // Username Field
                        _buildModernTextField(
                          label: 'ชื่อผู้ใช้',
                          controller: usernameCtl,
                          icon: Icons.account_circle_outlined,
                          screenHeight: screenHeight,
                        ),

                        SizedBox(height: 24),

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

                        // Email Field
                        _buildModernTextField(
                          label: 'อีเมล',
                          controller: emailCtl,
                          icon: Icons.email_outlined,
                          screenHeight: screenHeight,
                          keyboardType: TextInputType.emailAddress,
                        ),

                        SizedBox(height: 24),

                        // Phone Field
                        _buildModernTextField(
                          label: 'เบอร์โทรศัพท์',
                          controller: phoneCtl,
                          icon: Icons.phone_outlined,
                          screenHeight: screenHeight,
                          keyboardType: TextInputType.phone,
                        ),

                        SizedBox(height: 24),

                        // Password Field
                        _buildPasswordField(
                          label: 'รหัสผ่าน',
                          controller: passwordCtl,
                          icon: Icons.lock_outline,
                          screenHeight: screenHeight,
                          obscureText: _obscurePassword,
                          onToggleVisibility: () {
                            setState(
                                () => _obscurePassword = !_obscurePassword);
                          },
                        ),

                        SizedBox(height: 24),

                        // Confirm Password Field
                        _buildPasswordField(
                          label: 'ยืนยันรหัสผ่าน',
                          controller: confirmPasswordCtl,
                          icon: Icons.lock_outline,
                          screenHeight: screenHeight,
                          obscureText: _obscureConfirmPassword,
                          onToggleVisibility: () {
                            setState(() => _obscureConfirmPassword =
                                !_obscureConfirmPassword);
                          },
                        ),

                        SizedBox(height: 24),

                        // Address Field
                        _buildModernTextField(
                          label: 'ที่อยู่',
                          controller: addressCtl,
                          icon: Icons.location_on_outlined,
                          screenHeight: screenHeight,
                          maxLines: 3,
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
                      onPressed: userRegisterNextButton,
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
    String? subtitle,
    required TextEditingController controller,
    required IconData icon,
    required double screenHeight,
    bool isOptional = false,
    TextInputType? keyboardType,
    int maxLines = 1,
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
              if (subtitle != null) ...[
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
            ],
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
            maxLines: maxLines,
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
              hintText: isOptional ? 'กรอก$label (ถ้ามี)' : 'กรอก$label',
              hintStyle: TextStyle(
                color: Color(0xFF916B44).withOpacity(0.5),
                fontSize: 16,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: maxLines > 1 ? 18 : 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Password Field Widget
  Widget _buildPasswordField({
    required String label,
    String? subtitle,
    required TextEditingController controller,
    required IconData icon,
    required double screenHeight,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
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
              if (subtitle != null) ...[
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
            ],
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
            obscureText: obscureText,
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
              suffixIcon: InkWell(
                onTap: onToggleVisibility,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: EdgeInsets.all(12),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFFDBA871).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Color(0xFF916B44),
                    size: 20,
                  ),
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

  Future<void> userRegisterNextButton() async {
    showLoadingDialog();
    // Assuming you have a confirmPasswordCtl for confirming the password.
    if (usernameCtl.text.trim().isEmpty ||
        nameCtl.text.trim().isEmpty ||
        surnameCtl.text.trim().isEmpty ||
        emailCtl.text.trim().isEmpty ||
        passwordCtl.text.trim().isEmpty ||
        phoneCtl.text.trim().isEmpty ||
        addressCtl.text.trim().isEmpty) {
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

    controller.username.value = usernameCtl.text;
    controller.name.value = nameCtl.text;
    controller.surname.value = surnameCtl.text;
    controller.email.value = emailCtl.text;
    controller.password.value = passwordCtl.text;
    controller.phone.value = phoneCtl.text;
    controller.address.value = addressCtl.text;

    var res = await http.get(Uri.parse("$url/user/${emailCtl.text}"));

    Get.back();

    if (res.statusCode == 200) {
      Get.snackbar(
        'ข้อผิดพลาด',
        'อีเมลนี้เคยสมัครสมาชิกไปแล้ว\nกรุณาเข้าสู่ระบบหากเป็นคลินิกแล้วต้องการเปลี่ยนไปยังผู้ใช้ทั่วไป',
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
      Get.to(() => UserlocationselectPage());
    }
    log(res.body);
  }

  void showLoadingDialog({String? message}) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: const Color(0xFFFAF8F5),
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
                    color: Color(0xFFE9CBAF),
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF916B44)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  message ?? "กำลังโหลด...",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF916B44),
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
