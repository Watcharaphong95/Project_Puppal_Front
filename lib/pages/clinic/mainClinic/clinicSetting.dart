import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/pages/appNavigator.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicNotification/notificationPage.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicVaccineHistory/VaccineHistoryPage.dart';
import 'package:puppal_application/pages/clinic/mainClinic/profileclinic/clinicProfile.dart';

import 'package:puppal_application/pages/clinic/mainClinic/clinicListDoctors.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicMain.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicOpeningHours.dart';
import 'package:puppal_application/pages/clinic/mainClinic/reserve/vaccineRequestsPage.dart';
import 'package:puppal_application/pages/clinicAppNavigator.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalMain.dart';
import 'package:puppal_application/pages/general/profile/resetPassword/recoveryPassword.dart';
import 'package:puppal_application/pages/general/registerGeneral/registerUserGoogle.dart';
import 'package:puppal_application/pages/login/index.dart';
import 'package:shimmer/shimmer.dart';

class Clinicsetting extends StatefulWidget {
  const Clinicsetting({super.key});

  @override
  State<Clinicsetting> createState() => _ClinicsettingState();
}

class _ClinicsettingState extends State<Clinicsetting> {
  late double screenWidth;
  late double screenHeight;
  final box = GetStorage();
  String url = '';
  String name = '';
  String avatarImage = '';
  bool _loadingData = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    await Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
    });
    log(box.read('email'));
    var resGeneral =
        await http.get(Uri.parse("$url/clinic/name/${box.read('email')}"));
    name = jsonDecode(resGeneral.body)['name'];
    avatarImage = jsonDecode(resGeneral.body)['image'];
    _loadingData = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        // appBar: AppBar(
        //   title: const Text(
        //     "การตั้งค่า",
        //     style: TextStyle(
        //       fontWeight: FontWeight.w600,
        //       color: Colors.white,
        //     ),
        //   ),
        //   backgroundColor: Color(0xFFDBA871),
        //   iconTheme: IconThemeData(color: Colors.white),
        //   elevation: 0,
        //   centerTitle: true,
        //   // leading: IconButton(
        //   //   icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF916B44)),
        //   //   onPressed: () => Navigator.pop(context),
        //   // ),
        // ),

        // drawer: Drawer(
        //   child: Container(
        //     decoration: BoxDecoration(
        //       image: DecorationImage(
        //         image: AssetImage('assets/images/indexBg.png'),
        //         fit: BoxFit.cover,
        //       ),
        //     ),
        //     child: Container(
        //       decoration: BoxDecoration(
        //         color: Colors.white.withOpacity(0.85),
        //         borderRadius: BorderRadius.only(
        //           topRight: Radius.circular(30),
        //           bottomRight: Radius.circular(30),
        //         ),
        //         boxShadow: [
        //           BoxShadow(
        //             color: Colors.black.withOpacity(0.15),
        //             blurRadius: 10,
        //             offset: Offset(2, 2),
        //           ),
        //         ],
        //       ),
        //       child: ListView(
        //         padding: EdgeInsets.zero,
        //         children: [
        //           DrawerHeader(
        //             decoration: BoxDecoration(
        //               color: Color(0xFFDBA871),
        //               borderRadius: BorderRadius.only(
        //                 topRight: Radius.circular(30),
        //               ),
        //             ),
        //             child: Column(
        //               crossAxisAlignment: CrossAxisAlignment.center,
        //               children: [
        //                 ClipOval(
        //                   child: Image.network(
        //                     box.read('clinicImage'),
        //                     width: screenWidth * 0.2,
        //                     height: screenWidth * 0.2,
        //                     fit: BoxFit.cover,
        //                     loadingBuilder: (context, child, loadingProgress) {
        //                       if (loadingProgress == null) return child;
        //                       return Shimmer.fromColors(
        //                         baseColor: Colors.grey[300]!,
        //                         highlightColor: Colors.grey[100]!,
        //                         child: Container(
        //                           width: screenWidth * 0.2,
        //                           height: screenWidth * 0.2,
        //                           color: Colors.white,
        //                         ),
        //                       );
        //                     },
        //                   ),
        //                 ),
        //                 SizedBox(height: 10),
        //                 Text(
        //                   box.read('clinicName') ?? "ผู้ใช้งาน",
        //                   style: TextStyle(
        //                     color: Colors.white,
        //                     fontSize: 20,
        //                     fontWeight: FontWeight.bold,
        //                   ),
        //                 ),
        //               ],
        //             ),
        //           ),
        //           ListTile(
        //             leading: Icon(Icons.home, color: Color(0xFF916b44)),
        //             title: Text('หน้าหลัก'),
        //           ),
        //           ListTile(
        //             leading: Icon(Icons.system_security_update,
        //                 color: Color(0xFF916b44)),
        //             title: Text('คำขอฉีดยา'),
        //             onTap: () {
        //               Get.back();
        //               Get.to(() => VaccineRequestsPage());
        //             },
        //           ),
        //           ListTile(
        //             leading:
        //                 Icon(Icons.notifications, color: Color(0xFF916b44)),
        //             title: Text('แจ้งเตือน'),
        //             onTap: () {
        //               Get.back();
        //               Get.to(() => Notificationpage());
        //             },
        //           ),
        //           ListTile(
        //             leading:
        //                 Icon(Icons.medical_services, color: Color(0xFF916b44)),
        //             title: Text('ประวัติการฉีดยา'),
        //             onTap: () {
        //               Get.back();
        //               Get.to(() => Vaccinehistorypage());
        //             },
        //           ),
        //           ListTile(
        //             leading: Icon(Icons.supervised_user_circle,
        //                 color: Color(0xFF916b44)),
        //             title: Text('หมอประจำคลินิก'),
        //             onTap: () {
        //               Get.back();
        //               Get.to(() => Cliniclistdoctors());
        //             },
        //           ),
        //           ListTile(
        //             leading:
        //                 Icon(Icons.medical_services, color: Color(0xFF916b44)),
        //             title: Text('เวลาปิด-เปิด'),
        //             onTap: () => Get.to(() => Clinicopeninghours()),
        //           ),
        //           ListTile(
        //             leading: Icon(Icons.settings, color: Color(0xFF916b44)),
        //             title: Text('ตั้งค่า'),
        //             onTap: () => Get.to(() => Clinicsetting()),
        //           ),
        //           ListTile(
        //             leading:
        //                 Icon(MdiIcons.accountSwitch, color: Color(0xFF916b44)),
        //             title: Text('สลับโหมด'),
        //             onTap: () async {
        //               var resGeneral = await http.get(
        //                   Uri.parse("$url/general/name/${box.read('email')}"));
        //               if (resGeneral.statusCode == 200) {
        //                 showAlert(
        //                   title: 'สลับไปยังบัญชีผู้ใช้ทั่วไป?',
        //                   message: 'กด ตกลง เพื่อไปยังบัญชีผู้ใช้ทั่วไป',
        //                   onConfirm: () {
        //                     box.write('type', 'general');
        //                     box.write('generalName',
        //                         jsonDecode(resGeneral.body)['username']);
        //                     box.write('generalImage',
        //                         jsonDecode(resGeneral.body)['image']);
        //                     log('Name ${box.read('generalName')}');
        //                     Get.offAll(() => GeneralmainPage());
        //                   },
        //                 );
        //               } else {
        //                 showAlert(
        //                   title: 'คุณยังไม่มีบัญชีผู้ใช้ทั่วไป!',
        //                   message: 'กด ตกลง เพื่อไปยังหน้าสมัครผู้ใช้ทั่วไป',
        //                   onConfirm: () {
        //                     Get.back();
        //                     Get.to(() => RegisterusergooglePage());
        //                   },
        //                 );
        //               }
        //             },
        //           ),
        //           ListTile(
        //             leading: Icon(Icons.logout, color: Colors.redAccent),
        //             title: Text('ออกจากระบบ'),
        //             onTap: () {
        //               showAlert(
        //                 title: 'ออกจากระบบ?',
        //                 message: 'คุณต้องการออกจากระบบใช่หรือไม่',
        //                 onConfirm: () async {
        //                   await FirebaseMessaging.instance.deleteToken();
        //                   box.erase();
        //                   Get.offAll(() => IndexPage());
        //                 },
        //               );
        //             },
        //           ),
        //         ],
        //       ),
        //     ),
        //   ),
        // ),

        body: _loadingData
            ? Container(
                color: Color(0xFFFAF8F5),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF916B44)),
                  ),
                ),
              )
            : Container(
                height: screenHeight,
                decoration: BoxDecoration(
                  color: Color(0xFFFAF8F5),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header Section with Profile
                      SafeArea(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(24, 40, 24, 0),
                          child: Column(
                            children: [
                              // Profile Image
                              Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.network(
                                    avatarImage,
                                    width: screenWidth * 0.32,
                                    height: screenWidth * 0.32,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Shimmer.fromColors(
                                        baseColor: Color(0xFFE9CBAF),
                                        highlightColor: Colors.white,
                                        child: Container(
                                          width: screenWidth * 0.32,
                                          height: screenWidth * 0.32,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                      width: screenWidth * 0.32,
                                      height: screenWidth * 0.32,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFE9CBAF),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 16),

                              // Name
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  name,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF916B44),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Menu Section
                      Padding(
                        padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Column(
                          children: [
                            // Edit Profile
                            _buildModernMenuItem(
                              icon: Icons.edit_outlined,
                              title: 'แก้ไขโปรไฟล์',
                              subtitle: 'จัดการข้อมูลส่วนตัว',
                              onTap: () {
                                Clinicappnavigator.toWidget(Clinicprofile());
                              },
                              screenWidth: screenWidth,
                            ),

                            SizedBox(height: 16),

                            // Change Password
                            _buildModernMenuItem(
                              icon: Icons.lock_outline,
                              title: 'เปลี่ยนรหัสผ่าน',
                              subtitle: 'อัปเดตรหัสผ่านของคุณ',
                              onTap: () {
                                AppNavigation.toWidget(RecoverypasswordPage());
                              },
                              screenWidth: screenWidth,
                            ),

                            SizedBox(height: 16),

                            // Delete Profile
                            _buildModernMenuItem(
                              icon: Icons.delete_outline,
                              title: 'ลบโปรไฟล์',
                              subtitle: 'ลบบัญชีผู้ใช้งาน',
                              onTap: () {},
                              screenWidth: screenWidth,
                              isDangerous: true,
                            ),

                            SizedBox(height: 40),

                            // Logout Button
                            Container(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Handle logout
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Color(0xFF916B44),
                                  elevation: 0,
                                  side: BorderSide(
                                    color: Color(0xFF916B44),
                                    width: 2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.logout,
                                      size: 22,
                                      color: Color(0xFF916B44),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'ออกจากระบบ',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ));
  }

// Modern Menu Item Widget
  Widget _buildModernMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required double screenWidth,
    bool isDangerous = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDangerous
                ? Color(0xFFEF4444).withOpacity(0.2)
                : Color(0xFFE9CBAF),
            width: 1,
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
            // Icon Container
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDangerous
                    ? Color(0xFFEF4444).withOpacity(0.1)
                    : Color(0xFFE9CBAF).withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDangerous ? Color(0xFFEF4444) : Color(0xFF916B44),
                size: 24,
              ),
            ),

            SizedBox(width: 16),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color:
                          isDangerous ? Color(0xFFEF4444) : Color(0xFF916B44),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          (isDangerous ? Color(0xFFEF4444) : Color(0xFF916B44))
                              .withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            // Arrow Icon
            Icon(
              Icons.chevron_right,
              color: isDangerous
                  ? Color(0xFFEF4444).withOpacity(0.5)
                  : Color(0xFFDBA871),
              size: 24,
            ),
          ],
        ),
      ),
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
