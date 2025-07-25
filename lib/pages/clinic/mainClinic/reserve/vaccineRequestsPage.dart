import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/model/clinicUpdateTypePost.dart';
import 'package:puppal_application/model/dogdetalisPost.dart';
import 'package:puppal_application/model/generalPost.dart';
import 'package:puppal_application/model/reserveClinicPost.dart';
import 'package:puppal_application/model/reserveGeneralPost.dart';
import 'package:puppal_application/model/reserveUpdateStatusPost.dart';
import 'package:puppal_application/model/reservebooking.dart';
import 'package:puppal_application/model/reserveclinicfirebase.dart';
import 'package:puppal_application/pages/appNavigator.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicListDoctors.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicMain.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicNotification/notificationPage.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicOpeningHours.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicSetting.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicVaccineHistory/VaccineHistoryPage.dart';
import 'package:puppal_application/pages/clinic/mainClinic/reserve/acceptRequest.dart';
import 'package:puppal_application/pages/clinic/mainClinic/reserve/bookingDetailPage.dart';
import 'package:puppal_application/pages/clinicAppNavigator.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalMain.dart';
import 'package:puppal_application/pages/general/registerGeneral/registerUserGoogle.dart';
import 'package:puppal_application/pages/login/index.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'dart:convert';

class VaccineRequestsPage extends StatefulWidget {
  const VaccineRequestsPage({super.key});

  @override
  State<VaccineRequestsPage> createState() => _ClinicConfirmRequestState();
}

class _ClinicConfirmRequestState extends State<VaccineRequestsPage> {
  late double screenWidth;
  late double screenHeight;
  bool isNormalSelected = true;

  final box = GetStorage();
  String url = '';
  List<GeneralPost> generalList = [];
  List<DogDetailsPost> dogList = [];
  // List<Reservebooking> reservebookingList = [];
  List<ReserveClinicFirebase> todayList = [];
  List<ReserveClinicFirebase> yesterdayList = [];
  List<ReserveClinicFirebase> earlierList = [];
  var db = FirebaseFirestore.instance;
  List<String> messages = [];
  // bool isLoading = true;
  bool _isPressed = false;
  bool _loadingData = true;

  StreamSubscription? _reserveListener;
  final Color primaryBrown = const Color(0xFF916B44);
  final Color secondaryBrown = const Color(0xFFDBA871);
  final Color lightBrown = const Color(0xFFE9CBAF);

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    await Configuration.getConfig().then((config) {
      if (!mounted) return;
      url = config['apiEndPoint'];
    });
    startRealtimeGet();
    setState(() {
      _loadingData = false;
    });
  }

  @override
  void dispose() {
    stopRealTime(); // ปิด listener ตอน widget ถูกถอดออก
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        // appBar: AppBar(
        //   title: const Text(
        //     "คำขอฉีดวัคซีน",
        //     style: TextStyle(
        //       fontWeight: FontWeight.w600,
        //       fontSize: 24,
        //       color: Colors.white,
        //     ),
        //   ),
        //   backgroundColor: secondaryBrown,
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
        //               color: secondaryBrown,
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
        //               leading: Icon(Icons.medical_services,
        //                   color: Color(0xFF916b44)),
        //               title: Text('เวลาปิด-เปิด'),
        //               onTap: () {
        //                 Get.back();
        //                 Get.to(() => Clinicopeninghours());
        //               }),
        //           ListTile(
        //               leading: Icon(Icons.settings, color: Color(0xFF916b44)),
        //               title: Text('ตั้งค่า'),
        //               onTap: () {
        //                 Get.back();
        //                 Get.to(() => Clinicsetting());
        //               }),
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
                child: Column(
                  children: [
                    // Toggle buttons (existing code)
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9CBAF).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isNormalSelected = true;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isNormalSelected
                                      ? const Color(0xFF916B44)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: isNormalSelected
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF916B44)
                                                .withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : [],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'การจองปกติ',
                                  style: TextStyle(
                                    color: isNormalSelected
                                        ? Colors.white
                                        : const Color(0xFF916B44),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isNormalSelected = false;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isNormalSelected
                                      ? Colors.transparent
                                      : const Color(0xFF916B44),
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: !isNormalSelected
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF916B44)
                                                .withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : [],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'คำขอพิเศษ',
                                  style: TextStyle(
                                    color: isNormalSelected
                                        ? const Color(0xFF916B44)
                                        : Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content with empty state handling
                    Expanded(
                      child: _buildBookingContent(),
                    ),
                  ],
                ),
              ));
  }

// Helper method to build content with empty state
  Widget _buildBookingContent() {
    final filteredTodayList = todayList
        .where((data) =>
            data.type == (isNormalSelected ? 0 : 1) && data.status == 1)
        .toList();

    final filteredYesterdayList = yesterdayList
        .where((data) =>
            data.type == (isNormalSelected ? 0 : 1) && data.status == 1)
        .toList();

    final filteredEarlierList = earlierList
        .where((data) =>
            data.type == (isNormalSelected ? 0 : 1) && data.status == 1)
        .toList();

    // Check if all lists are empty
    final hasNoBookings = filteredTodayList.isEmpty &&
        filteredYesterdayList.isEmpty &&
        filteredEarlierList.isEmpty;

    if (hasNoBookings) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Today's bookings
          if (filteredTodayList.isNotEmpty) ...[
            _buildDateHeader('วันนี้'),
            ...filteredTodayList.map((data) => _buildRequestCard(
                  data.status == 1 ? 'รอตอบรับ' : 'เสร็จสิ้น',
                  data.generalEmail ?? '-',
                  formatshowTime(data.date.toString()),
                  data.docId,
                )),
          ],

          // Yesterday's bookings
          if (filteredYesterdayList.isNotEmpty) ...[
            _buildDateHeader('เมื่อวาน'),
            ...filteredYesterdayList.map((data) => _buildRequestCard(
                  data.status == 1 ? 'รอตอบรับ' : 'เสร็จสิ้น',
                  data.generalEmail ?? '-',
                  formatshowTime(data.date.toString()),
                  data.docId,
                )),
          ],

          // Earlier bookings
          if (filteredEarlierList.isNotEmpty) ...[
            _buildDateHeader('ก่อนหน้านี้'),
            ...filteredEarlierList.map((data) => _buildRequestCard(
                  data.status == 1 ? 'รอตอบรับ' : 'เสร็จสิ้น',
                  data.generalEmail ?? '-',
                  formatshowTime(data.date.toString()),
                  data.docId,
                )),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDateHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFE9CBAF).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.calendar_today_outlined,
                size: 48,
                color: const Color(0xFF916B44).withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'ไม่มีข้อมูลการจอง${isNormalSelected ? 'ปกติ' : 'พิเศษ'}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF916B44),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ยังไม่มีการจองฉีดวัคซีนในช่วงเวลานี้',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // void readData() async {
  //   var query = db.collection("reserve").where("name");
  //   var result = await query.get();

  //   List<String> newMessages =
  //       result.docs.map((doc) => doc['message'] as String).toList();

  //   setState(() {
  //     messages = newMessages;
  //   });
  // }

  void startRealtimeGet() {
    showLoadingDialog();

    stopRealTime(); // หยุดก่อนถ้ามี listener เดิม

    _reserveListener = FirebaseFirestore.instance
        .collection('reserve')
        .where('clinicEmail', isEqualTo: box.read("email"))
        .snapshots()
        .listen((snapshot) async {
      try {
        if (!mounted) return;

        List<ReserveClinicFirebase> allData = snapshot.docs
            .map((doc) => ReserveClinicFirebase.fromJson(doc.data(), doc.id))
            .where((e) => e.status != 3)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

        // เคลียร์ลิสต์เก่า
        todayList.clear();
        yesterdayList.clear();
        earlierList.clear();

        for (var item in allData) {
          final date = item.date.toLocal();
          if (isToday(date)) {
            todayList.add(item);
          } else if (isYesterday(date)) {
            yesterdayList.add(item);
          } else {
            earlierList.add(item);
          }
        }

        if (!mounted) return;
        setState(() {}); // ✅ อัปเดตก็ต่อเมื่อ widget ยังอยู่

        // ✅ ตรวจสอบ mounted ก่อนและหลัง await แต่ละตัว
        if (todayList.isNotEmpty) {
          if (!mounted) return;
          await getReserveBook(todayList[0].docId);
          if (!mounted) return;
          await getGeneral(todayList[0].generalEmail);
        } else if (yesterdayList.isNotEmpty) {
          if (!mounted) return;
          await getReserveBook(yesterdayList[0].docId);
          if (!mounted) return;
          await getGeneral(yesterdayList[0].generalEmail);
        } else if (earlierList.isNotEmpty) {
          if (!mounted) return;
          await getReserveBook(earlierList[0].docId);
          if (!mounted) return;
          await getGeneral(earlierList[0].generalEmail);
        } else {
          log("ℹ️ No reserve data found.");
        }
      } catch (e) {
        log("❌ Error in realtime listener: $e");
      }
    });

    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  void stopRealTime() {
    _reserveListener?.cancel();
  }

  // Enhanced _buildRequestCard with minimal design
  Widget _buildRequestCard(
    String status,
    String fallbackName,
    String time,
    String docId,
  ) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: getReserveBook(docId),
      builder: (context, reserveSnap) {
        if (reserveSnap.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard();
        }
        if (!reserveSnap.hasData || reserveSnap.data == null) {
          return _buildErrorCard();
        }

        final reserve = reserveSnap.data!;
        final indicatorColor = status == 'รอตอบรับ'
            ? const Color(0xFFDBA871)
            : const Color(0xFF916B44);
        final email = reserve['generalEmail'] as String? ?? '';
        return FutureBuilder<String>(
          future: email.isNotEmpty ? getGeneralName(email) : Future.value(''),
          builder: (context, nameSnap) {
            Widget nameText;

            if (nameSnap.connectionState == ConnectionState.waiting) {
              nameText = const Text(
                'กำลังโหลดชื่อ...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              );
            } else if (nameSnap.hasError) {
              nameText = const Text(
                'โหลดชื่อผิดพลาด',
                style: TextStyle(color: Colors.red, fontSize: 14),
              );
            } else {
              final name = nameSnap.data?.trim();
              nameText = Text(
                name != null && name.isNotEmpty ? name : 'ไม่มีชื่อ',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: name != null && name.isNotEmpty
                      ? const Color(0xFF916B44)
                      : Colors.grey[600],
                  fontStyle: name != null && name.isNotEmpty
                      ? FontStyle.normal
                      : FontStyle.italic,
                ),
              );
            }
            return StatefulBuilder(
              builder: (context, setState) {
                bool pressed = false;

                return GestureDetector(
                  onTapDown: (_) => setState(() => pressed = true),
                  onTapUp: (_) => setState(() => pressed = false),
                  onTapCancel: () => setState(() => pressed = false),
                  onTap: () async {
                    showLoadingDialog();

                    final reserveData = await getReserveBook(docId);

                    if (reserveData != null) {
                      final generalEmail = reserveData['generalEmail'];
                      final dogDogIdRaw = reserveData['dogDogId'];
                      final dogDogId = dogDogIdRaw is int
                          ? dogDogIdRaw
                          : int.tryParse(dogDogIdRaw.toString()) ?? 0;

                      final dogDetails = await getdog(dogDogId);

                      if (generalEmail != null && generalEmail.isNotEmpty) {
                        await getGeneral(generalEmail);
                      }

                      // ✅ ปิด loading ก่อนเปิด popup
                      if (Get.isDialogOpen ?? false) {
                        Get.back();
                      }

                      _showAppointmentPopup(
                        context,
                        reserveData,
                        dogDetails,
                        reserveData['docId'],
                      );
                    } else {
                      if (Get.isDialogOpen ?? false) {
                        Get.back();
                      }

                      log("⚠️ ไม่พบข้อมูล reserve สำหรับ docId: $docId");
                      // สามารถใช้ Get.snackbar หรือแสดง AlertDialog แจ้งเตือนได้
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: pressed
                          ? const LinearGradient(
                              colors: [Color(0xFF5E3D23), Color(0xFF916B44)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: pressed ? null : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE9CBAF).withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF916B44).withOpacity(0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // indicator bar
                          Container(
                            width: 4,
                            decoration: BoxDecoration(
                              color: indicatorColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: indicatorColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      color: indicatorColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      color: Color(0xFF2D2D2D),
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                    children: [
                                      const TextSpan(text: 'คุณ '),
                                      TextSpan(
                                        text: nameText is Text
                                            ? (nameText as Text).data
                                            : 'ไม่ระบุ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF916B44),
                                        ),
                                      ),
                                      const TextSpan(
                                          text: ' ได้จองเวลากับคลินิกของคุณ'),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.schedule_outlined,
                                        size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      time,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // arrow button
                          GestureDetector(
                            onTap: () {
                              Clinicappnavigator.toWidget(
                                BookingdetailPage(docid: docId),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE9CBAF).withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      const Color(0xFFDBA871).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(Icons.arrow_forward_ios,
                                  size: 16, color: Color(0xFF916B44)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingCard() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorCard() {
    return const Center(
      child: Text('ไม่พบข้อมูล'),
    );
  }

// Pop-up Dialog Method - ปรับปรุงให้รับ Map แทน Reservebooking object
  void _showAppointmentPopup(
      BuildContext context,
      Map<String, dynamic> reserveData,
      DogDetailsPost? dogDetails,
      String docId) {
    final ownerName = generalList.isNotEmpty ? generalList[0].name : 'ไม่ระบุ';
    final ownerPhone =
        generalList.isNotEmpty ? generalList[0].phone : 'ไม่ระบุ';
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Close Button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 38,
                        decoration: BoxDecoration(
                          color: lightBrown,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.close,
                          color: primaryBrown,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),

                // Card Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "คำขอจองฉีดวัคซีนจากคุณ",
                            style: TextStyle(
                              color: primaryBrown,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            ownerName, // ใช้ชื่อจาก getGeneral
                            style: TextStyle(
                              color: primaryBrown,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        child: Padding(padding: EdgeInsets.only(bottom: 15)),
                      ),

                      const SizedBox(height: 24),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dogDetails!.name, // ชื่อเจ้าของจาก getGeneral
                                  style: TextStyle(
                                    color: primaryBrown,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  dogDetails!.breed, // เบอร์โทรจาก getGeneral
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: dogDetails!.image.isNotEmpty
                                      ? Image.network(
                                          dogDetails!
                                              .image, // รูปภาพจาก getGeneral
                                          height: 90,
                                          width: 120,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Shimmer.fromColors(
                                              baseColor: Color(0xFFE9CBAF),
                                              highlightColor: Colors.white,
                                              child: Container(
                                                width: 120,
                                                height: 120,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                            );
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.grey,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.person,
                                              size: 50,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      : Container(
                                          width: 120,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.person,
                                            size: 50,
                                            color: Colors.white,
                                          ),
                                        ),
                                )),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Divider
                      Container(
                        height: 2,
                        width: 500,
                        color: lightBrown.withOpacity(0.5),
                      ),

                      const SizedBox(height: 24),

                      // Details - ใช้ข้อมูลจาก reserveData
                      _buildPopupDetailRow('ผู้ใช้', ownerName),
                      _buildPopupDetailRow('เบอร์โทร', ownerPhone),
                      _buildPopupDetailRow(
                          'วัคซีน',
                          reserveData['appointmentAid']?.toString() ??
                              'ไม่ระบุ'),
                      _buildPopupDetailRow(
                          'วันที่จอง', _formatDateString(reserveData['date'])),
                      _buildPopupDetailRow(
                          'เวลาที่จอง', _formatDate(reserveData['date'])),
                      _buildPopupDetailRow('รหัสสุนัข',
                          reserveData['dogDogId']?.toString() ?? 'ไม่ระบุ'),
                      _buildPopupDetailRow('ประเภทการจอง',
                          reserveData['type']?.toString() ?? 'ไม่ระบุ'),

                      const SizedBox(height: 32),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: _buildPopupActionButton(
                              label: 'ปฏิเสธการจอง',
                              onPressed: () async {
                                Navigator.pop(context);
                                bool isConfirmed =
                                    await RejectDialog(context, docId);
                                if (!isConfirmed) {
                                  log("ผู้ใช้ยกเลิกการบันทึก");
                                  return;
                                }
                              },
                              isPrimary: false,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildPopupActionButton(
                              label: 'ยืนยันการจอง',
                              onPressed: () async {
                                Navigator.pop(context);
                                bool isConfirmed =
                                    await confirmDialog(context, docId);
                                if (!isConfirmed) {
                                  log("ผู้ใช้ยกเลิกการบันทึก");
                                  return;
                                }
                                // _showAcceptDialog(docId);
                              },
                              isPrimary: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> acceptrequest(String docId, int status) async {
    showLoadingDialog();
    if (status == 0 || status == 2) {
      try {
        await FirebaseFirestore.instance
            .collection('reserve')
            .doc(docId)
            .update({
          'status': status,
        });
        // 2. ดึงข้อมูลของ reserve
        final doc = await FirebaseFirestore.instance
            .collection('reserve')
            .doc(docId)
            .get();

        if (doc.exists) {
          final data = doc.data();
          final generalEmail = data?['generalEmail'];
          final clinicEmail = data?['clinicEmail'];

          if (generalEmail != null) {
            final generalUser = await getGeneral(generalEmail);
            final userName = generalUser?.name;

            if (userName != null) {
              if (status == 2) {
                await sendNotificationAccept(generalEmail, userName);
                await sendClinicAcceptNotification(
                    clinicEmail: clinicEmail,
                    userName: box.read('clinicName'),
                    date: data?['date'] ?? '',
                    generalEmail: generalEmail);
              } else if (status == 0) {
                final doc = await FirebaseFirestore.instance
                    .collection('reserve')
                    .doc(docId)
                    .delete();
                await sendNotificationRefuse(generalEmail, userName);
                await sendClinicRefuseNotification(
                    clinicEmail: clinicEmail,
                    userName: box.read('clinicName'),
                    date: data?['date'] ?? '',
                    generalEmail: generalEmail);
              }
            } else {
              log("⚠️ Missing userName from getGeneral()");
            }
          } else {
            log("⚠️ Missing generalEmail in document");
          }
        }
        log('Updated status to $status for docId=$docId');
      } catch (e) {
        log('❌ Failed to update status: $e');
      }
    } else {
      log('Status not allowed to update: $status');
    }
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  Widget _buildPopupDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopupActionButton({
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          if (isPrimary)
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              offset: Offset(0, 4),
              blurRadius: 10,
              spreadRadius: 1,
            ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? primaryBrown : Colors.grey[100],
          foregroundColor: isPrimary ? Colors.white : Colors.grey[700],
          elevation: 0, // ปิด elevation ของ ElevatedButton เอง
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: isPrimary
                ? BorderSide.none
                : BorderSide(color: Colors.grey[300]!, width: 1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _acceptReservation() {
    Flushbar(
      message: 'ยืนยันการนัดหมายเรียบร้อยแล้ว',
      duration: const Duration(seconds: 4), // นานขึ้น
      backgroundColor: Color(0xFF916B44),
      flushbarPosition: FlushbarPosition.TOP, // แสดงด้านบน
      borderRadius: BorderRadius.circular(8),
      margin: const EdgeInsets.all(16),
      animationDuration: const Duration(milliseconds: 500), // แสดงขึ้นช้ากว่า
    ).show(context);
  }

  void _rejectReservation() {
    Flushbar(
      message: 'ปฏิเสธการนัดหมายแล้ว',
      duration: const Duration(seconds: 4),
      backgroundColor: Colors.red,
      flushbarPosition: FlushbarPosition.TOP,
      borderRadius: BorderRadius.circular(8),
      margin: const EdgeInsets.all(16),
      animationDuration: const Duration(milliseconds: 500),
    ).show(context);
  }

  bool isToday(DateTime date) {
    final now = DateTime.now();
    final local = date.toLocal();
    return now.year == local.year &&
        now.month == local.month &&
        now.day == local.day;
  }

  bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final local = date.toLocal();
    return yesterday.year == local.year &&
        yesterday.month == local.month &&
        yesterday.day == local.day;
  }

  List<GeneralPost> generalPostFromJson(String str) {
    final jsonData = json.decode(str);
    if (jsonData is List) {
      return jsonData
          .map((item) => GeneralPost.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } else if (jsonData is Map) {
      return [GeneralPost.fromJson(Map<String, dynamic>.from(jsonData))];
    } else {
      throw Exception("Unexpected JSON format");
    }
  }

  Future<DogDetailsPost?> getdog(int dogId) async {
    try {
      log("🐶 Getting dog info for ID: $dogId");
      var res = await http.get(Uri.parse("$url/dog/getdog/$dogId"));
      if (res.statusCode == 200) {
        final List<DogDetailsPost> dogList = dogDetailsPostFromJson(res.body);
        if (dogList.isNotEmpty) {
          return dogList.first;
        }
        return null; // กรณีไม่มีข้อมูล
      } else {
        log("❌ Failed to load dog: ${res.statusCode}");
        return null;
      }
    } catch (e) {
      log("❌ Exception while fetching dog info: $e");
      return null;
    }
  }

  Future<String> getGeneralName(String email) async {
    try {
      final res = await http.get(Uri.parse("$url/general/$email"));
      if (res.statusCode == 200) {
        final list = generalPostFromJson(res.body); // <= list<GeneralPost>
        if (list.isNotEmpty) return list[0].name;
      }
    } catch (e) {
      log('getGeneralName error: $e');
    }
    return ''; // ไม่เจอชื่อ
  }

  Future<GeneralPost?> getGeneral(String generalEmail) async {
    try {
      var res = await http.get(Uri.parse("$url/general/$generalEmail"));
      if (res.statusCode == 200) {
        final Map<String, dynamic> jsonMap = json.decode(res.body);
        return GeneralPost.fromJson(jsonMap);
      } else {
        log("❌ Failed to load: ${res.statusCode}");
        return null;
      }
    } catch (e) {
      log("Error: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getReserveBook(String docId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('reserve')
          .doc(docId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          data['docId'] = doc.id;
          return data;
        }
      } else {
        log('❌ No document found for docId=$docId');
      }
    } catch (e) {
      log('❌ Error while fetching document: $e');
    }
    return null;
  }

  String formatshowTime(String isoDate) {
    final date = DateTime.parse(isoDate).toLocal();

    final thaiMonths = [
      '',
      'มกราคม',
      'กุมภาพันธ์',
      'มีนาคม',
      'เมษายน',
      'พฤษภาคม',
      'มิถุนายน',
      'กรกฎาคม',
      'สิงหาคม',
      'กันยายน',
      'ตุลาคม',
      'พฤศจิกายน',
      'ธันวาคม'
    ];

    final day = date.day;
    final month = thaiMonths[date.month];
    final year = date.year + 543;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return 'เวลา $hour:$minute วันที่ $day $month $year';
  }

  String _formatDateString(dynamic dateValue) {
    try {
      if (dateValue == null) return 'ไม่ระบุ';

      DateTime dateTime;
      if (dateValue is String) {
        dateTime = DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        dateTime = dateValue;
      } else if (dateValue is Timestamp) {
        dateTime = dateValue.toDate();
      } else {
        return 'รูปแบบวันที่ไม่ถูกต้อง';
      }

      return formatThaiDateTime(dateTime); // ใช้ฟังก์ชันที่มีอยู่
    } catch (e) {
      log("❌ Error formatting date: $e");
      return 'ไม่สามารถแสดงวันที่ได้';
    }
  }

  String _formatDate(dynamic dateValue) {
    try {
      if (dateValue == null) return 'ไม่ระบุ';

      DateTime dateTime;
      if (dateValue is String) {
        dateTime = DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        dateTime = dateValue;
      } else if (dateValue is Timestamp) {
        dateTime = dateValue.toDate();
      } else {
        return 'รูปแบบเวลาไม่ถูกต้อง';
      }

      String hour = dateTime.hour.toString().padLeft(2, '0');
      String minute = dateTime.minute.toString().padLeft(2, '0');

      return '$hour:$minute น.';
    } catch (e) {
      log("❌ Error formatting time: $e");
      return 'ไม่สามารถแสดงเวลาได้';
    }
  }

  String formatThaiDateTime(DateTime date) {
    final localDate = date.toLocal();

    final thaiMonths = [
      '',
      'มกราคม',
      'กุมภาพันธ์',
      'มีนาคม',
      'เมษายน',
      'พฤษภาคม',
      'มิถุนายน',
      'กรกฎาคม',
      'สิงหาคม',
      'กันยายน',
      'ตุลาคม',
      'พฤศจิกายน',
      'ธันวาคม'
    ];

    final day = localDate.day;
    final month = thaiMonths[localDate.month];
    final year = localDate.year + 543;

    return '$day $month $year';
  }

  Future<void> _openBookingDetail(String docid) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BookingdetailPage(docid: docid)),
    );
    if (result == true) {
      // await getReserve();
      setState(() {});
    }
  }

  Future<bool> confirmDialog(BuildContext context, String docId) async {
    return await showDialog(
          context: context,
          barrierDismissible: false, // ป้องกันการปิดโดยการแตะข้างนอก
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
              crossAxisAlignment: CrossAxisAlignment.center, // กลางแนวนอน
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
                  "ยืนยันการขอจอง",
                  style: TextStyle(
                    color: Color(0xFF916B44),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "คุณต้องการยืนยันการขอจองนี้หรือไม่?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF916B44),
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.center, // ปุ่มอยู่ตรงกลาง
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
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF916B44),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "ยกเลิก",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // ปุ่มยืนยัน
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Color(0xFF916B44),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF916B44).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextButton(
                  onPressed: () {
                    // Navigator.of(context).pop(true);
                    Navigator.pop(context);
                    Navigator.of(context).pop(true);
                    acceptrequest(docId, 2);
                    // _rejectReservation();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "ยืนยัน",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> RejectDialog(BuildContext context, String docId) async {
    return await showDialog(
          context: context,
          barrierDismissible: false, // ป้องกันการปิดโดยการแตะข้างนอก
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(
                color: const Color.fromARGB(255, 203, 22, 9),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center, // กลางแนวนอน
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 203, 22, 9),
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
                  "ปฏิเสธการขอจอง!!!",
                  style: TextStyle(
                    color: const Color.fromARGB(255, 203, 22, 9),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "คุณต้องการปฏิเสธการขอจองนี้หรือไม่?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 203, 22, 9),
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.center, // ปุ่มอยู่ตรงกลาง
            actionsPadding: const EdgeInsets.only(bottom: 12, top: 4),
            actions: [
              // ปุ่มยกเลิก
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: const Color.fromARGB(255, 203, 22, 9),
                    width: 1.5,
                  ),
                ),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 203, 22, 9),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "ยกเลิก",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // ปุ่มยืนยัน
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: const Color.fromARGB(255, 203, 22, 9),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 203, 22, 9)
                          .withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextButton(
                  onPressed: () {
                    // Navigator.of(context).pop(true);
                    Navigator.pop(context);
                    Navigator.of(context).pop(true);
                    acceptrequest(docId, 0);
                    // _rejectReservation();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "ยืนยัน",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
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

  Future<void> sendClinicAcceptNotification({
    required String clinicEmail,
    required String generalEmail,
    required String userName,
    required String date,
  }) async {
    final apiUrl = Uri.parse("$url/reserve/notify/clinicaccept/clinic-request");

    final Map<String, dynamic> data = {
      'clinicEmail': clinicEmail,
      'generalEmail': generalEmail,
      'userName': userName,
      'date': date,
    };

    try {
      final response = await http.post(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print('✅ ส่งแจ้งเตือนสำเร็จ: ${response.body}');
      } else {
        print('❌ เกิดข้อผิดพลาด: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('❗ ไม่สามารถเชื่อมต่อกับ server: $e');
    }
  }

  Future<void> sendClinicRefuseNotification({
    required String clinicEmail,
    required String generalEmail,
    required String userName,
    required String date,
  }) async {
    final apiUrl = Uri.parse("$url/reserve/notify/clinicrefuse/clinic-request");

    final Map<String, dynamic> data = {
      'clinicEmail': clinicEmail,
      'generalEmail': generalEmail,
      'userName': userName,
      'date': date,
    };

    try {
      final response = await http.post(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print('✅ ส่งแจ้งเตือนสำเร็จ: ${response.body}');
      } else {
        print('❌ เกิดข้อผิดพลาด: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('❗ ไม่สามารถเชื่อมต่อกับ server: $e');
    }
  }

  Future<void> sendNotificationAccept(
      String generalEmail, String userName) async {
    final sql = Uri.parse("$url/reserve/notify/accept/general-reponse");

    try {
      final res = await http.post(
        sql,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'generalEmail': generalEmail,
          'userName': userName,
        }),
      );

      if (res.statusCode == 200) {
        log("✅ Notification sent successfully");
      } else {
        log("❌ Failed to send notification: ${res.statusCode} - ${res.body}");
      }
    } catch (e) {
      log("❌ Error sending notification: $e");
    }
  }

  Future<void> sendNotificationRefuse(
      String generalEmail, String userName) async {
    final sql = Uri.parse("$url/reserve/notify/refuse/general-reponse");

    try {
      final res = await http.post(
        sql,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'generalEmail': generalEmail,
          'userName': userName,
        }),
      );

      if (res.statusCode == 200) {
        log("✅ Notification sent successfully");
      } else {
        log("❌ Failed to send notification: ${res.statusCode} - ${res.body}");
      }
    } catch (e) {
      log("❌ Error sending notification: $e");
    }
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
