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
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('เพิ่มรูปภาพสุนัข'),
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
                  showAlertConfirm(
                    context: context,
                    title: 'ไม่มีรูปโปรไฟล์',
                    message: 'กรุณาเลือกรูปก่อนทำการยืนยัน',
                  );
                  return;
                }

                showAlert(
                  context: context,
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
    showLoadingDialog(context, message: "กำลังโหลด...");
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
        gender: dogCtl.breed.value,
        color: dogCtl.color.value,
        defect: dogCtl.defect.value,
        birthday: dogCtl.birthday.value,
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
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFFFFF3F3),
            title: Text(
              "สมัครสมาชิกสำเร็จ",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF795548),
              ),
            ),
            content: Text(
              "สมัครสมาชิกทั่วไปสำเร็จแล้ว",
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
              "ไม่สามารถสมัครสมาชิกได้ กรุณาลองใหม่อีกครั้ง",
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

    if (res.statusCode != 201) {
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
            "ไม่สามารถสมัครสมาชิกได้ กรุณาลองใหม่อีกครั้ง",
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

  Future<void> recordInsert() async {
    var resCode = "";
    for (var re in recordListCtl.recordList) {
      InjectionRecordPost req = InjectionRecordPost(
          dogId: dogID,
          clinicName: re.clinicName,
          vaccineType: re.vaccineType,
          date: re.date);
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
            "สมัครสมาชิกสำเร็จ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF795548),
            ),
          ),
          content: Text(
            "สมัครสมาชิกทั่วไปสำเร็จแล้ว",
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
            "ไม่สามารถสมัครสมาชิกได้ กรุณาลองใหม่อีกครั้ง",
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

  void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(message ?? "Loading...",
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        );
      },
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

  void showAlertConfirm({
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
