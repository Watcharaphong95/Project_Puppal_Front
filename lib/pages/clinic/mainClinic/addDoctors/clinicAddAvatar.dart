import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:puppal_application/controller/registerClinicCtl.dart';
import 'package:puppal_application/controller/registerDoctorCtl.dart';
import 'package:puppal_application/model/doctorPost.dart';
import 'package:puppal_application/pages/clinic/mainClinic/addDoctors/clinicAddDoctor.dart';
import 'package:puppal_application/pages/clinic/mainClinic/addDoctors/clinicRegisterDoctor.dart';

import 'package:puppal_application/pages/clinic/mainClinic/clinicMain.dart';
import 'package:puppal_application/pages/clinic/mainClinic/reserve/vaccineRequestsPage.dart';
import 'package:puppal_application/pages/login/index.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Clinicaddavatar extends StatefulWidget {
  const Clinicaddavatar({super.key});

  @override
  State<Clinicaddavatar> createState() => _ClinicaddavatarState();
}

class _ClinicaddavatarState extends State<Clinicaddavatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final box = GetStorage();
  late double screenWidth;
  late double screenHeight;

  final controller = Get.find<registerDoctorCtl>();
  final clinic = Get.find<registerClinicCtl>();
  final doctorList = Get.find<doctorDataList>();

  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "เพิ่มรูปภาพคุณหมอ",
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
              onPressed: () async {
                if (_imageFile == null) {
                  showAlert(
                    context: context,
                    title: 'ไม่มีรูปคุณหมอ',
                    message: 'กรุณาเลือกรูปก่อนทำการยืนยัน',
                  );
                  return;
                }

                bool confirmed = await confirmDialog(context);

                if (confirmed) {
                  // ถ้าผู้ใช้กดยืนยัน
                  confirmAvatarButton(); // <-- ใส่ฟังก์ชันที่คุณต้องการทำหลังจากยืนยัน
                }
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

  void confirmAvatarButton() async {
    confirmDialog(
      context,
    );
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

      Get.to(() => Clinicregisterdoctor());
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

  // void showLoadingDialog(BuildContext context, {String? message}) {
  //   showDialog(
  //     barrierDismissible: false,
  //     context: context,
  //     builder: (context) {
  //       return Dialog(
  //         backgroundColor: Colors.white,
  //         shape:
  //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //         child: Padding(
  //           padding: const EdgeInsets.all(20.0),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               const CircularProgressIndicator(),
  //               const SizedBox(height: 20),
  //               Text(message ?? "Loading...",
  //                   style: const TextStyle(fontSize: 16)),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

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
                  "ยืนยันการเลือกรูปภาพ",
                  style: TextStyle(
                    color: Color(0xFF916B44),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "คุณต้องการยืนยันการเลือกรูปภาพนี้หรือไม่?",
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
              // ปุ่มยกเลิก
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
                  child: const Text("ยกเลิก"),
                ),
              ),
              const SizedBox(width: 12),
              // ปุ่มยืนยัน
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Color(0xFF916B44),
                ),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    "ยืนยัน",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
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

  // void showAlertConfirm({
  //   required BuildContext context,
  //   required String title,
  //   required String message,
  //   VoidCallback? onConfirm,
  // }) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       backgroundColor: const Color(0xFFFFF3F3),
  //       title: Text(
  //         title,
  //         style: const TextStyle(
  //           fontWeight: FontWeight.bold,
  //           color: Color(0xFF795548),
  //         ),
  //       ),
  //       content: Text(
  //         message,
  //         style: const TextStyle(color: Colors.black87),
  //       ),
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  //       actions: [
  //         ElevatedButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             if (onConfirm != null) onConfirm();
  //           },
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: const Color(0xFF795548),
  //             foregroundColor: Colors.white,
  //             shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(10)),
  //           ),
  //           child: const Text('ตกลง'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
