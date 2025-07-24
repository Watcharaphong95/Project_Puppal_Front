import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/controller/registerDogCtl.dart';
import 'package:puppal_application/controller/registerDogInjectionHistoryCtl.dart';
import 'package:puppal_application/model/dogPost.dart';
import 'package:puppal_application/model/injectionRecordPost.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalDog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class RegisterdogavatarPage extends StatefulWidget {
  const RegisterdogavatarPage({super.key});

  @override
  State<RegisterdogavatarPage> createState() => _RegisterdogavatarPageState();
}

class _RegisterdogavatarPageState extends State<RegisterdogavatarPage> {
  late double screenWidth;
  late double screenHeight;

  File? _imageFile;

  String url = "";
  late int dogID;

  final box = GetStorage();

  final dogCtl = Get.find<registerDogCtl>();
  final recordListCtl = Get.find<injectionRecordList>();

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
    });
    log(dogCtl.birthday.value);
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'เพิ่มรูปภาพสุนัข',
          style: TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Color(0xFFDBA871),
      ),
      body: SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 80,
                    backgroundColor: const Color(0xFF916b44),
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : AssetImage('assets/images/dogAvatar.png')
                            as ImageProvider,
                    child: _imageFile == null
                        ? const Icon(Icons.add_a_photo,
                            color: Colors.black54, size: 50)
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                const Text('อัพโหลดรูปสุนัขของคุณ',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                const Text(
                  'เพิ่มรูปโปรไฟล์สุนัขของคุณ',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.1),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                backgroundColor: const Color(0xFF916b44),
              ),
              onPressed: () {
                if (_imageFile == null) {
                  showAlertNoClose(
                    title: 'ไม่มีรูปโปรไฟล์',
                    message: 'กรุณาเลือกรูปก่อนทำการยืนยัน',
                  );
                  return;
                }

                showAlert(
                  title: 'ยืนยันรูปโปรไฟล์',
                  message: 'คุณต้องการยืนยันรูปโปรไฟล์นี้หรือไม่?',
                  onConfirm: confirmAvatarButton,
                );
              },
              child: const Text(
                'ยืนยันรูปโปรไฟล์',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void confirmAvatarButton() async {
    showLoadingDialog();
    await Supabase.instance.client.auth.signInWithPassword(
      email: '65011212077@msu.ac.th',
      password: '1234',
    );

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      log("User not logged in. Cannot upload.");
      return;
    }
    try {
      final fileBytes = await _imageFile!.readAsBytes();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';

      // Upload to Supabase Storage
      final storageResponse = await Supabase.instance.client.storage
          .from('dog-image') // Use your actual bucket name here
          .uploadBinary(fileName, fileBytes,
              fileOptions: const FileOptions(upsert: true));

      if (storageResponse.isEmpty) {
        log('Upload failed.');
        return;
      }

      // Get the public URL
      final publicUrl = Supabase.instance.client.storage
          .from('dog-image')
          .getPublicUrl(fileName);

      log("Confirmed with file: ${_imageFile!.path}");
      log("Public image URL: $publicUrl");
      dogCtl.image.value = publicUrl;

      await insertDogAndInjectRecord();
    } catch (e) {
      log("Error during upload: $e");
    }
  }

  Future<void> insertDogAndInjectRecord() async {
    await dogInsert();
    if (recordListCtl.recordList.isNotEmpty) {
      await recordInsert();
      recordListCtl.recordList.clear();
    }
  }

  Future<void> dogInsert() async {
    if (dogCtl.sterilization.value == 'ทำแล้ว') {
      dogCtl.sterilization.value = '1';
    } else {
      dogCtl.sterilization.value = '0';
    }

    DogPost req = DogPost(
        userEmail: box.read('email'),
        name: dogCtl.name.value,
        breed: dogCtl.breed.value,
        gender: dogCtl.gender.value,
        color: dogCtl.color.value,
        defect: dogCtl.defect.value,
        birthday: convertThaiDateToISO(dogCtl.birthday.value),
        congentialDisease: dogCtl.disease.value,
        sterilization: dogCtl.sterilization.value,
        hair: dogCtl.hair.value,
        image: dogCtl.image.value);

    var res = await http.post(
      Uri.parse("$url/dog"),
      headers: {"Content-Type": "application/json; charset=utf-8"},
      body: dogPostToJson(req),
    );
    log(res.body.toString());
    RegExp regExp = RegExp(r'\d+');
    String? number = regExp.firstMatch(res.body.toString())?.group(0);
    dogID = int.parse(number!);

    if (recordListCtl.recordList.isEmpty) {
      Get.back();

      if (res.statusCode == 201) {
        showAlertNoClose(
            title: 'เพิ่มสุนัขสำเร็จแล้ว',
            message: 'กดตกลงเพื่อกลับไปยังหน้าสุนัขของคุณ',
            onConfirm: () {
              Get.to(() => GeneraldogPage());
            });
      } else {
        showAlertNoClose(
            title: 'เกิดข้อผิดพลาด', message: 'กรุณาลองใหม่อีกครั้ง');
      }
    }

    if (res.statusCode != 201) {
      showAlertNoClose(
          title: 'เกิดข้อผิดพลาด', message: 'กรุณาลองใหม่อีกครั้ง');
    }
  }

  String convertThaiDateToISO(String thaiDate) {
    Map<String, String> thaiMonths = {
      'มกราคม': '01',
      'กุมภาพันธ์': '02',
      'มีนาคม': '03',
      'เมษายน': '04',
      'พฤษภาคม': '05',
      'มิถุนายน': '06',
      'กรกฎาคม': '07',
      'สิงหาคม': '08',
      'กันยายน': '09',
      'ตุลาคม': '10',
      'พฤศจิกายน': '11',
      'ธันวาคม': '12',
    };

    // แยกวันที่ เดือน และปี
    List<String> parts = thaiDate.split('-');
    if (parts.length != 3) return ''; // เช็คความถูกต้อง

    String day = parts[0].padLeft(2, '0'); // เติม 0 หน้าเลขวันถ้าจำเป็น
    String monthName = parts[1];
    String year = parts[2];

    String? month = thaiMonths[monthName];
    if (month == null) return ''; // ถ้าเดือนไม่ตรงกับที่กำหนด

    return "$year-$month-$day";
  }

  Future<void> recordInsert() async {
    var resCode = "";
    for (var re in recordListCtl.recordList) {
      InjectionRecordPost req = InjectionRecordPost(
          dogId: dogID,
          clinicName: re.clinicName,
          vaccineType: re.vaccineType,
          date: re.date,
          status: re.status);
      log(injectionRecordPostToJson(req));
      var res = await http.post(
        Uri.parse("$url/injectionRecord"),
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: injectionRecordPostToJson(req),
      );

      log(res.statusCode.toString());
      resCode = res.statusCode.toString();
    }
    Get.back();
    if (resCode == '201') {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFFFFF3F3),
          title: Text(
            "เพิ่มสุนัขสำเร็จ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF795548),
            ),
          ),
          content: Text(
            "เพิ่มสุนัขสำเร็จแล้ว",
            style: const TextStyle(color: Colors.black87),
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          actions: [
            ElevatedButton(
              onPressed: () {
                Get.to(() => GeneraldogPage());
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
    } else {
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
            "ไม่สามารถเพิ่มสุนัขได้ กรุณาลองใหม่อีกครั้ง",
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

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFFF3F3),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Color(0xFF795548)),
            title: const Text('ถ่ายรูปด้วยกล้อง'),
            onTap: () async {
              Navigator.pop(context);
              final picked = await ImagePicker()
                  .pickImage(source: ImageSource.camera, imageQuality: 80);
              if (picked != null) {
                setState(() => _imageFile = File(picked.path));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library, color: Color(0xFF795548)),
            title: const Text('เลือกรูปจากคลัง'),
            onTap: () async {
              Navigator.pop(context);
              final picked = await ImagePicker()
                  .pickImage(source: ImageSource.gallery, imageQuality: 80);
              if (picked != null) {
                setState(() => _imageFile = File(picked.path));
              }
            },
          ),
        ],
      ),
    );
  }

  void showAlert({
    required String title,
    required String message,
    VoidCallback? onConfirm,
  }) {
    Get.defaultDialog(
      title: '',
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.all(16),
      content: PopScope(
        canPop: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with subtle animation potential
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFD7CCC8),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.info_outline_rounded,
                size: 24,
                color: const Color(0xFFA1887F),
              ),
            ),

            const SizedBox(height: 16),

            // Title with better typography
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Color(0xFF8D6E63),
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Message with improved readability
            Text(
              message,
              style: const TextStyle(
                color: Color(0xFFA1887F),
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // Enhanced button row
            Row(
              children: [
                // Cancel button
                Expanded(
                  child: Container(
                    height: 40,
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF8D6E63),
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: const Color(0xFFD7CCC8),
                            width: 1,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'ยกเลิก',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Confirm button
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xFF795548),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFA1887F).withOpacity(0.3),
                          offset: const Offset(0, 2),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        if (onConfirm != null) onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'ตกลง',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF5F0E8),
      barrierDismissible: false,
      radius: 16,
    );
  }

  void showAlertNoClose({
    required String title,
    required String message,
    VoidCallback? onConfirm, // Optional action
  }) {
    Get.defaultDialog(
      title: '',
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.all(16),
      content: PopScope(
        canPop: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFD7CCC8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                size: 24,
                color: Color(0xFFA1887F),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Color(0xFF8D6E63),
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                color: Color(0xFFA1887F),
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  if (onConfirm != null) {
                    onConfirm();
                  } else {
                    Get.back(); // Default action
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF795548),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'ตกลง',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF5F0E8),
      barrierDismissible: false,
      radius: 16,
    );
  }
}
