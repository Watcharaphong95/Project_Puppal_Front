import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/controller/registerDoctorCtl.dart';
import 'package:puppal_application/pages/registerDoctorAvatar.dart';
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
  TextEditingController specialNoCtl = TextEditingController();

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
        title: Text(
          'เพิ่มหมอ',
        ),
        backgroundColor: Color(0xFF916B44),
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
                            Text('(เช่น ผ่าตัด, ยา)',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.grey)),
                          ],
                        ),
                        Material(
                          elevation: 5,
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            height: screenHeight * 0.055,
                            child: TextField(
                              controller: specialNoCtl,
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

  Future<void> doctorAddNextButton() async {
    if (nameCtl.text.trim().isEmpty ||
        surnameCtl.text.trim().isEmpty ||
        specialNoCtl.text.trim().isEmpty ||
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

    controller.name.value = nameCtl.text;
    controller.surname.value = surnameCtl.text;
    controller.special.value = specialNoCtl.text;
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
