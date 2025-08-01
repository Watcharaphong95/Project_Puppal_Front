import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/controller/registerGeneralCtl.dart';
import 'package:puppal_application/pages/general/registerGeneral/registerUserLocationSelect.dart';

class RegisterusergooglePage extends StatefulWidget {
  const RegisterusergooglePage({super.key});

  @override
  State<RegisterusergooglePage> createState() => _RegisterusergooglePageState();
}

class _RegisterusergooglePageState extends State<RegisterusergooglePage> {
  late double screenWidth;
  late double screenHeight;

  String url = "";

  final controller = Get.find<RegisterGeneralCtl>();
  final box = GetStorage();

  TextEditingController usernameCtl = TextEditingController();
  TextEditingController nameCtl = TextEditingController();
  TextEditingController surnameCtl = TextEditingController();
  TextEditingController emailCtl = TextEditingController();
  TextEditingController phoneCtl = TextEditingController();
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
        title: const Text('สมัครสมาชิกผู้ใช้ทั่วไป',
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600)),
        backgroundColor: Color(0xFFDBA871),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Container(
          // height: screenHeight * 0.89,
          // decoration: BoxDecoration(
          //   image: DecorationImage(
          //       image: AssetImage('assets/images/indexBg.png'),
          //       fit: BoxFit.cover,
          //       colorFilter: ColorFilter.mode(
          //           Colors.white.withOpacity(0.2), BlendMode.dstATop)),
          // ),
          color: Color(0xFFFAF8F5),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              spacing: 16,
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
                buildInputField(
                  label: 'ชื่อผู้ใช้',
                  controller: usernameCtl,
                  icon: Icons.person,
                ),
                buildInputField(
                  label: 'ชื่อ',
                  controller: nameCtl,
                  icon: Icons.badge,
                ),
                buildInputField(
                  label: 'นามสกุล',
                  controller: surnameCtl,
                  icon: Icons.badge_outlined,
                ),
                buildInputField(
                  label: 'อีเมล',
                  controller: emailCtl,
                  readOnly: true,
                  enable: false,
                  icon: Icons.email,
                ),
                buildInputField(
                  label: 'เบอร์โทรศัพท์',
                  controller: phoneCtl,
                  isPhone: true,
                  icon: Icons.phone,
                ),
                buildInputField(
                  label: 'ที่อยู่',
                  controller: addressCtl,
                  icon: Icons.home,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, screenHeight * 0.05),
                  child: SizedBox(
                    width: screenWidth * 0.5,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Color(0xFF916b44), // Golden Brown for buttons
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 6,
                        shadowColor: Colors.black26,
                      ),
                      onPressed: userRegisterNextButton,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInputField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    bool enable = true,
    bool isPhone = false,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF916B44),
          ),
        ),
        const SizedBox(height: 8),
        Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(16),
          shadowColor: Colors.black12,
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            enabled: enable,
            keyboardType: isPhone ? TextInputType.phone : null,
            style: const TextStyle(color: Color(0xFF916B44)),
            decoration: InputDecoration(
              prefixIcon:
                  icon != null ? Icon(icon, color: Color(0xFF916B44)) : null,
              filled: true,
              fillColor: Colors.white,
              hintText: 'กรอก$label',
              hintStyle: const TextStyle(color: Color(0xFF916B44)),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18.0,
                horizontal: 16.0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE9CBAF)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE9CBAF)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    const BorderSide(color: Color(0xFF916B44), width: 1.5),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Future<void> userRegisterNextButton() async {
    // Assuming you have a confirmPasswordCtl for confirming the password.
    if (usernameCtl.text.trim().isEmpty ||
        nameCtl.text.trim().isEmpty ||
        surnameCtl.text.trim().isEmpty ||
        emailCtl.text.trim().isEmpty ||
        phoneCtl.text.trim().isEmpty ||
        addressCtl.text.trim().isEmpty) {
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

    showLoadingDialog();

    controller.username.value = usernameCtl.text;
    controller.name.value = nameCtl.text;
    controller.surname.value = surnameCtl.text;
    controller.email.value = emailCtl.text;
    controller.password.value = '';
    controller.phone.value = phoneCtl.text;
    controller.address.value = addressCtl.text;

    // var res = await http.get(Uri.parse("$url/user/${emailCtl.text}"));

    Get.back();
    Get.to(() => UserlocationselectPage());

    // if (res.statusCode == 200) {
    //   Get.snackbar(
    //     'ข้อผิดพลาด',
    //     'อีเมลนี้เคยสมัครสมาชิกไปแล้ว\nกรุณาเข้าสู่ระบบหากเป็นคลินิกแล้วต้องการเปลี่ยนไปยังผู้ใช้ทั่วไป',
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
    //   Get.to(() => UserlocationselectPage());
    // }
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
