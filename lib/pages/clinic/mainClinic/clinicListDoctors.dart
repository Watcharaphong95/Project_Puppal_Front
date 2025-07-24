import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/model/doctorPost.dart';
import 'package:puppal_application/pages/appNavigator.dart';
import 'package:puppal_application/pages/clinic/mainClinic/addDoctors/clinicAddDoctor.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicMain.dart';
import 'package:http/http.dart' as http;
import 'package:puppal_application/pages/clinic/mainClinic/clinicNotification/notificationPage.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicOpeningHours.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicDoctorProfile.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicSetting.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicVaccineHistory/VaccineHistoryPage.dart';
import 'package:puppal_application/pages/clinic/mainClinic/reserve/vaccineRequestsPage.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalMain.dart';
import 'package:puppal_application/pages/general/registerGeneral/registerUserGoogle.dart';
import 'package:puppal_application/pages/login/index.dart';
import 'package:shimmer/shimmer.dart';

class Cliniclistdoctors extends StatefulWidget {
  const Cliniclistdoctors({super.key});

  @override
  State<Cliniclistdoctors> createState() => _CliniclistdoctorsState();
}

class _CliniclistdoctorsState extends State<Cliniclistdoctors> {
  late double screenWidth;
  late double screenHeight;
  TextEditingController names = TextEditingController();
  // List<SpecialPost> special = [];
  List<DoctorPost> doctorsList = [];
  bool _loadingData = true;

  String url = "";
  final box = GetStorage();

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    final config = await Configuration.getConfig();
    url = config['apiEndPoint'];

    if (url == null || url.isEmpty) {
      log('❌ URL not loaded properly from config');
      return;
    }

    await getDoctor();

    setState(() {
      _loadingData = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        // appBar: AppBar(
        //   leading: Builder(
        //     builder: (context) => IconButton(
        //       icon: Icon(Icons.menu, size: 30),
        //       onPressed: () {
        //         Scaffold.of(context).openDrawer();
        //       },
        //     ),
        //   ),
        //   title: const Text(
        //     "คุณหมอประจำคลินิก",
        //     style: TextStyle(
        //       fontWeight: FontWeight.w600,
        //       fontSize: 24,
        //       color: Colors.white,
        //     ),
        //   ),
        //   backgroundColor: Color(0xFFDBA871),
        //   iconTheme: IconThemeData(color: Colors.white),
        //   centerTitle: true,
        //   actions: [
        //     IconButton(
        //       icon: Icon(
        //         Icons.add_circle,
        //         color: Colors.white,
        //         size: 45,
        //       ),
        //       onPressed: () {
        //         Get.to(() => Clinicadddoctor());
        //       },
        //     ),
        //   ],
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
        //             onTap: () {
        //               Get.back();
        //               Get.to(() => ClinicmainPage());
        //             },
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
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFDBA871),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'กำลังโหลด...',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            : Container(
                color: Color(0xFFFAF8F5),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (text) {
                          if (text.trim().isEmpty) {
                            getDoctor();
                          } else {
                            searcheDoctor(names);
                          }
                        },
                        controller: names,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'ค้นหา',
                          prefixIcon: const Icon(Icons.search,
                              color: Color(0xFF916B44)),
                          hintStyle: const TextStyle(color: Color(0xFF916B44)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFFDBA871)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFF916B44), width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                          child: _loadingData
                              ? const Center(
                                  child: CircularProgressIndicator(
                                      color: Color(0xFF916B44)))
                              : doctorsList.isEmpty
                                  ? const Center(
                                      child: Text(
                                        "ไม่พบข้อมูลคุณหมอ",
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: Color(0xFF916B44)),
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: GridView.count(
                                        crossAxisCount: 2, // จาก 3 เป็น 2
                                        crossAxisSpacing: 25,
                                        mainAxisSpacing: 15,
                                        childAspectRatio:
                                            0.75, // ปรับสัดส่วนให้ดูไม่แคบเกินไป
                                        children: doctorsList.map((doctor) {
                                          return Card(
                                            elevation: 5,
                                            color: const Color.fromARGB(
                                                255, 246, 234, 224),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              side: const BorderSide(
                                                  color: Color(0xFFDBA871),
                                                  width: 1),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                      horizontal: 8),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  ClipOval(
                                                    child: doctor
                                                            .image.isNotEmpty
                                                        ? Image.network(
                                                            doctor.image,
                                                            height: 80,
                                                            width: 80,
                                                            fit: BoxFit.cover,
                                                            loadingBuilder:
                                                                (context, child,
                                                                    loadingProgress) {
                                                              if (loadingProgress ==
                                                                  null)
                                                                return child;
                                                              return Shimmer
                                                                  .fromColors(
                                                                baseColor:
                                                                    Colors.grey[
                                                                        300]!,
                                                                highlightColor:
                                                                    Colors.grey[
                                                                        100]!,
                                                                child:
                                                                    Container(
                                                                  width: 80,
                                                                  height: 80,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              );
                                                            },
                                                            errorBuilder: (context,
                                                                    error,
                                                                    stackTrace) =>
                                                                const Icon(Icons
                                                                    .error),
                                                          )
                                                        : Image.asset(
                                                            'assets/images/indexBg.png',
                                                            height: 80,
                                                            width: 80,
                                                            fit: BoxFit.cover,
                                                          ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    doctor.name,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                      color: Color(0xFF916B44),
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  const SizedBox(height: 10),
                                                  ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          const Color(
                                                              0xFFDBA871),
                                                      foregroundColor:
                                                          Colors.white,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      elevation: 2,
                                                    ),
                                                    onPressed: () {
                                                      AppNavigation.toWidget(
                                                        Clinicdoctorprofile(
                                                            name: doctor.name),
                                                      );
                                                    },
                                                    child: const Text(
                                                      'ดูประวัติ',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    )),
                    ],
                  ),
                ),
              ));
  }

  List<DoctorPost> doctorPostFromJson(String str) => List<DoctorPost>.from(
      json.decode(str).map((x) => DoctorPost.fromJson(x)));

  Future<void> getDoctor() async {
    var res = await http
        .get(Uri.parse("$url/doctor/searchemail/${box.read('email')}"));
    if (res.statusCode == 200) {
      var data = doctorPostFromJson(res.body);
      setState(() {
        doctorsList = data;
        _loadingData = false;
      });
    } else {
      setState(() {
        _loadingData = false;
      });
    }
  }

  Future<void> searcheDoctor(TextEditingController nams) async {
    final keyword = nams.text.trim();
    if (keyword.isEmpty) return;

    try {
      final res = await http
          .get(Uri.parse("$url/doctor/searche/${box.read('email')}/$keyword"));
      if (res.statusCode == 200) {
        final data = doctorPostFromJson(res.body);
        setState(() {
          doctorsList = data;
          _loadingData = false;
        });
      } else {
        setState(() {
          _loadingData = false;
        });
      }
    } catch (e) {
      setState(() {
        _loadingData = false;
      });
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
