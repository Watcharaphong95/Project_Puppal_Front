import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/main.dart';
import 'package:puppal_application/model/dogsGetEmail.dart';
import 'package:puppal_application/model/generalPost.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicMain.dart';
import 'package:puppal_application/pages/clinic/registerClinic/registerClinicGoogle.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalDog.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalGuide.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalMain.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalNotification.dart';
import 'package:puppal_application/pages/general/profile/editAdress.dart';
import 'package:puppal_application/pages/general/profile/editProfile.dart';
import 'package:puppal_application/pages/general/profile/resetPassword/recoveryPassword.dart';
import 'package:puppal_application/pages/general/recordDog/generalRecordSearch.dart';
import 'package:puppal_application/pages/login/index.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GeneralprofilePage extends StatefulWidget {
  const GeneralprofilePage({super.key});

  @override
  State<GeneralprofilePage> createState() => _GeneralprofilePageState();
}

class _GeneralprofilePageState extends State<GeneralprofilePage> {
  late double screenWidth;
  late double screenHeight;
  final box = GetStorage();

  String url = '';
  bool _loadingData = true;

  late GeneralPost generalData;
  List<DogsGetEmail> dogs = [];

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    await Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
    });
    await getGeneralData();
    log(generalData.image);
    _loadingData = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(
      //     'ตั้งค่า',
      //     style: TextStyle(color: Colors.white),
      //   ),
      //   centerTitle: true,
      //   backgroundColor: Color(0xFFDBA871),
      //   iconTheme: IconThemeData(color: Colors.white),
      // ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/indexBg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Color(0xFFDBA871),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipOval(
                        child: Image.network(
                          box.read('generalImage'),
                          width: screenWidth * 0.2,
                          height: screenWidth * 0.2,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                width: screenWidth * 0.2,
                                height: screenWidth * 0.2,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        box.read('generalName') ?? "ผู้ใช้งาน",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(
                    FontAwesomeIcons.house,
                    color: Color(0xFF916b44),
                  ),
                  title: Text(
                    'หน้าหลัก',
                  ),
                  onTap: () {
                    Get.back();
                    Get.to(() => GeneralmainPage());
                  },
                ),
                ListTile(
                    leading: Icon(FontAwesomeIcons.solidBell,
                        color: Color(0xFF916b44)),
                    title: Text('การแจ้งเตือน'),
                    onTap: () {
                      Get.back();
                      Get.to(() => GeneralnotificationPage());
                    }),
                ListTile(
                  leading: Icon(FontAwesomeIcons.dog, color: Color(0xFF916b44)),
                  title: Text('สุนัข'),
                  onTap: () {
                    Get.back();
                    Get.to(() => GeneraldogPage());
                  },
                ),
                ListTile(
                  leading:
                      Icon(FontAwesomeIcons.syringe, color: Color(0xFF916b44)),
                  title: Text('ประวัติการฉีดยา'),
                  onTap: () {
                    Get.back();
                    Get.to(() => GeneralrecordsearchPage());
                  },
                ),
                ListTile(
                  leading: Icon(Icons.menu_book, color: Color(0xFF916b44)),
                  title: Text('คู่มือ'),
                  onTap: () {
                    Get.back();
                    Get.to(() => GeneralguidePage());
                  },
                ),
                ListTile(
                  leading:
                      Icon(FontAwesomeIcons.gear, color: Color(0xFF916b44)),
                  title: Text('ตั้งค่า',
                      style: TextStyle(
                        color: Color(0xFF916b44),
                        fontWeight: FontWeight.bold,
                      )),
                ),
                ListTile(
                  leading:
                      Icon(MdiIcons.accountSwitch, color: Color(0xFF916b44)),
                  title: Text('สลับโหมด'),
                  onTap: () async {
                    var resClinic = await http.get(
                        Uri.parse("$url/clinic/name/${box.read('email')}"));
                    if (resClinic.statusCode == 200) {
                      showAlert(
                        title: 'สลับไปยังบัญชีคลินิก?',
                        message: 'กด ตกลง เพื่อไปยังบัญชีคลินิก',
                        onConfirm: () {
                          box.write('type', 'clinic');
                          box.write(
                              'clinicName', jsonDecode(resClinic.body)['name']);
                          box.write('clinicImage',
                              jsonDecode(resClinic.body)['image']);
                          log('Name ${box.read('clinicName')}');
                          Get.offAll(() => ClinicmainPage());
                        },
                      );
                    } else {
                      showAlert(
                        title: 'คุณยังไม่มีบัญชีคลินิก!',
                        message: 'กด ตกลง เพื่อไปยังหน้าสมัครคลินิก',
                        onConfirm: () {
                          Get.back();
                          Get.to(() => RegisterclinicgooglePage());
                        },
                      );
                    }
                  },
                ),
                ListTile(
                  leading:
                      Icon(FontAwesomeIcons.doorOpen, color: Colors.redAccent),
                  title: Text('ออกจากระบบ'),
                  onTap: () {
                    showAlert(
                      title: 'ออกจากระบบ?',
                      message: 'คุณต้องการออกจากระบบใช่หรือไม่',
                      onConfirm: () async {
                        await FirebaseMessaging.instance.deleteToken();
                        box.erase();
                        Get.offAll(() => IndexPage());
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: _loadingData
          ? SizedBox(
              child: Center(child: CircularProgressIndicator()),
            )
          : Container(
              height: screenHeight,
              color: Color(0xFFFAF8F5),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.05),
                  child: SizedBox(
                    width: screenWidth * 0.9,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Profile Image with enhanced styling
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF916B44).withOpacity(0.15),
                                blurRadius: 15,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.network(
                              generalData.image,
                              width: screenWidth * 0.35,
                              height: screenWidth * 0.35,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: screenWidth * 0.35,
                                    height: screenWidth * 0.35,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        SizedBox(height: 16),

                        // Name with enhanced styling
                        Container(
                          width: screenWidth * 0.7,
                          child: Center(
                            child: Text(
                              generalData.username,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF916B44),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 32),

                        // Settings buttons with enhanced styling
                        Column(
                          children: [
                            // Edit Profile Button
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Container(
                                height: screenHeight * 0.075,
                                width: screenWidth * 0.8,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 10,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Get.to(() => EditprofilePage());
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Color(0xFF916B44),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(
                                        color: Color(0xFFE9CBAF),
                                        width: 1,
                                      ),
                                    ),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Color(0xFFDBA871)
                                                  .withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              Icons.edit_note,
                                              size: screenWidth * 0.07,
                                              color: Color(0xFF916B44),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          const Text(
                                            'แก้ไขโปรไฟล์',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF916B44),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Icon(
                                        FontAwesomeIcons.chevronRight,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Change Password Button
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Container(
                                height: screenHeight * 0.075,
                                width: screenWidth * 0.8,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 10,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Get.to(() => RecoverypasswordPage());
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Color(0xFF916B44),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(
                                        color: Color(0xFFE9CBAF),
                                        width: 1,
                                      ),
                                    ),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Color(0xFFDBA871)
                                                  .withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              Icons.lock,
                                              size: screenWidth * 0.07,
                                              color: Color(0xFF916B44),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          const Text(
                                            'เปลี่ยนรหัสผ่าน',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF916B44),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Icon(
                                        FontAwesomeIcons.chevronRight,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Delete Profile Button
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Container(
                                height: screenHeight * 0.075,
                                width: screenWidth * 0.8,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    showAlert(
                                        title: 'คุณต้องการลบบัญชีผู้ใช้ทั่วไป?',
                                        message:
                                            'ข้อมูลทั้งหมดจะหายไปอย่างถาวร!',
                                        onConfirm: () {
                                          deleteProfile();
                                        });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.red,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(
                                        color: Colors.red.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.red.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              FontAwesomeIcons.trash,
                                              size: screenWidth * 0.06,
                                              color: Color(0xFFEF4444),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          const Text(
                                            'ลบโปรไฟล์',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Icon(
                                        FontAwesomeIcons.chevronRight,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> deleteProfile() async {
    showLoadingDialog();
    var res = await http.delete(Uri.parse("$url/general/${box.read('email')}"));
    await deletePictureSupabase();
    var resUpdateType = await http
        .put(Uri.parse("$url/user/deleteGeneral/${box.read('email')}"));
    Get.back();
    if (res.statusCode == 200 && resUpdateType.statusCode == 200) {
      showAlertNoClose(
          title: 'บัญชีของคุณถูกลบแล้ว',
          message: 'ขอบคุณที่ใช้บริการแอปของเรา',
          onConfirm: () {
            box.erase();
            Get.offAll(() => IndexPage());
          });
    } else {
      showAlertNoClose(title: 'ผิดพลาด', message: 'กรุณาลองใหม่อีกครั้ง');
    }
  }

  Future<void> deletePictureSupabase() async {
    await Supabase.instance.client.auth.signInWithPassword(
      email: '65011212077@msu.ac.th',
      password: '1234',
    );

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      log("User not logged in. Cannot delete.");
      return;
    }
    try {
      var imagePathAll = generalData.image.split('/');
      var imagePath = imagePathAll.lastWhere(
          (e) => e.contains('.jpg') || e.contains('.png'),
          orElse: () => '');

      log('imagePath: $imagePath');

      final deleteRes =
          await supabase.storage.from('general-image').remove([imagePath]);

      if (deleteRes.isEmpty) {
        log('Delete user picture failed.');
        return;
      }

      if (dogs.isNotEmpty) {
        for (var dog in dogs) {
          var dogImagePathAll = dog.image.split('/');
          var dogimagePath = dogImagePathAll.lastWhere(
              (e) => e.contains('.jpg') || e.contains('.png'),
              orElse: () => '');
          var deleteDogImageRes =
              await supabase.storage.from('dog-image').remove([dogimagePath]);
          if (deleteDogImageRes.isEmpty) {
            log('Delete dog picture failed.');
            return;
          }
        }
      }
    } catch (e) {
      log("Error during upload: $e");
    }
  }

  Future<void> getGeneralData() async {
    var resGeneral =
        await http.get(Uri.parse("$url/general/${box.read('email')}"));
    generalData = generalPostFromJson(resGeneral.body);
  }

  Future<void> getDogData() async {
    var res = await http.get(Uri.parse("$url/dog/${box.read('email')}"));
    if (res.statusCode == 200) {
      var jsonData = json.decode(res.body);
      dogs =
          jsonData.map<DogsGetEmail>((e) => DogsGetEmail.fromJson(e)).toList();
      // log(res.body);
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

  void showAlert({
    required String title,
    required String message,
    VoidCallback? onConfirm,
  }) {
    Get.defaultDialog(
      title: '',
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.all(16),
      content: Column(
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
      backgroundColor: const Color(0xFFF5F0E8),
      barrierDismissible: false,
      radius: 16,
    );
  }
}
