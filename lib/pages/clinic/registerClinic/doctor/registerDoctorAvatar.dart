import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:puppal_application/controller/registerClinicCtl.dart';
import 'package:puppal_application/controller/registerDoctorCtl.dart';
import 'package:puppal_application/model/doctorPost.dart';
import 'package:puppal_application/pages/clinic/registerClinic/registerClinicDoctor.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterdoctoravatarPage extends StatefulWidget {
  const RegisterdoctoravatarPage({super.key});

  @override
  State<RegisterdoctoravatarPage> createState() =>
      _RegisterdoctoravatarPageState();
}

class _RegisterdoctoravatarPageState extends State<RegisterdoctoravatarPage> {
  late double screenWidth;
  late double screenHeight;

  File? _imageFile;

  final controller = Get.find<registerDoctorCtl>();
  final clinic = Get.find<registerClinicCtl>();
  final doctorList = Get.find<doctorDataList>();

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
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
                        : AssetImage('assets/images/userAvatar.png')
                            as ImageProvider,
                    child: _imageFile == null
                        ? const Icon(Icons.add_a_photo,
                            color: Colors.black, size: 50)
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                const Text('อัพโหลดรูปคุณหมอ',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                const Text(
                  'เพิ่มรูปคุณหมอ',
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
                    title: 'ไม่มีรูปคุณหมอ',
                    message: 'กรุณาเลือกรูปก่อนทำการยืนยัน',
                    onConfirm: () {},
                  );
                  return;
                }

                showAlert(
                  context: context,
                  title: 'ยืนยันรูปคุณหมอ',
                  message: 'คุณต้องการยืนยันรูปคุณหมอนี้หรือไม่?',
                  onConfirm: () => confirmAvatarButton(context),
                );
              },
              child: const Text(
                'ยืนยันรูปคุณหมอ',
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

  void confirmAvatarButton(context) async {
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
          .from('doctor-image') // Use your actual bucket name here
          .uploadBinary(fileName, fileBytes,
              fileOptions: const FileOptions(upsert: true));

      if (storageResponse.isEmpty) {
        log('Upload failed.');
        return;
      }

      // Get the public URL
      final publicUrl = Supabase.instance.client.storage
          .from('doctor-image')
          .getPublicUrl(fileName);

      log("Confirmed with file: ${_imageFile!.path}");
      log("Public image URL: $publicUrl");
      controller.image.value = publicUrl;

      DoctorPost newDoctor = DoctorPost(
        userEmail: clinic.email.value,
        name: controller.name.value,
        surname: controller.surname.value,
        careerNo: controller.careerNo.value,
        image: controller.image.value,
      );

      doctorList.addDoctor(newDoctor);

      Get.to(() => RegisterclinicdoctorPage());
    } catch (e) {
      log("Error during upload: $e");
    }
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

  void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF916B44), width: 2),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF916B44),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.hourglass_top, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                "กรุณารอสักครู่",
                style: TextStyle(
                  color: Color(0xFF916B44),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message ?? "กำลังโหลดข้อมูล...",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF916B44),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF916B44)),
              ),
            ],
          ),
        );
      },
    );
  }

  void showAlert({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF916B44), width: 2),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF916B44),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.info_outline, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF916B44),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF916B44),
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actionsPadding: const EdgeInsets.only(bottom: 12, top: 4),
        actions: [
          // ปุ่มยกเลิก
          // ปุ่มยกเลิก
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Colors.white, // เพิ่มพื้นหลังสีขาว
              border: Border.all(
                  color: const Color(0xFF916B44), width: 2), // กรอบสีน้ำตาล
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (onCancel != null) onCancel();
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF916B44), // ข้อความสีน้ำตาล
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                backgroundColor: Colors.white, // พื้นหลังปุ่มสีขาว
              ),
              child: const Text(
                'ยกเลิก',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  // ไม่ต้องกำหนดสีซ้ำที่นี่ เพราะกำหนด foregroundColor ไว้แล้ว
                ),
              ),
            ),
          ),

          // ปุ่มตกลง
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: const Color(0xFF916B44),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF916B44).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (onConfirm != null) onConfirm();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'ตกลง',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showAlertConfirm({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF916B44), width: 2),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF916B44),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.help_outline, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF916B44),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
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
          // ยืนยัน
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: const Color(0xFF916B44),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF916B44).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'ตกลง',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
