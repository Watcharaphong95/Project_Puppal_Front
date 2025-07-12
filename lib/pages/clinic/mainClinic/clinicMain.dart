import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/model/dogdetalisPost.dart';
import 'package:puppal_application/model/generalPost.dart';
import 'package:puppal_application/model/reserveClinicPost.dart';
import 'package:puppal_application/model/reserveUpdateStatusPost.dart';
import 'package:puppal_application/model/reservebooking.dart';
import 'package:puppal_application/model/reserveclinicfirebase.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicVaccineHistory/VaccineHistoryPage.dart';
import 'package:puppal_application/pages/clinic/mainClinic/addVaccinationRecord/AddVaccinationRecordPage.dart';
import 'package:puppal_application/pages/clinic/mainClinic/bookingdetails/CalendarBookingDetailPage.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicListDoctors.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicOpeningHours.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicSetting.dart';
import 'package:puppal_application/pages/clinic/mainClinic/reserve/vaccineRequestsPage.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalMain.dart';
import 'package:puppal_application/pages/general/registerGeneral/registerUserGoogle.dart';
import 'package:puppal_application/pages/login/index.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:table_calendar/table_calendar.dart';

class ClinicmainPage extends StatefulWidget {
  const ClinicmainPage({super.key});

  @override
  State<ClinicmainPage> createState() => _ClinicmainPageState();
}

class _ClinicmainPageState extends State<ClinicmainPage> {
  late double screenWidth;
  late double screenHeight;
  final box = GetStorage();
  String url = '';
  bool isLoading = true;
  final Color primaryBrown = const Color(0xFF916B44);
  final Color secondaryBrown = const Color(0xFFDBA871);
  final Color lightBrown = const Color(0xFFE9CBAF);

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late GeneralPost generalData;
  List<GeneralPost> generalList = [];
  List<ReserveClinicFirebase> reserveList = [];
  List<ReserveClinicFirebase> reservebookingList = [];
  List<ReserveClinicFirebase> events = [];
  List<ReserveClinicFirebase> reservebookingListAll = [];

  @override
  void initState() {
    super.initState();
    initialize(); // Call async method without await
  }

  Future<void> initialize() async {
    final config = await Configuration.getConfig();
    url = config['apiEndPoint'];
    await getReserve();
    box.write('type', 'clinic');
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(),
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
                      color: Color(0xFF916b44),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipOval(
                          child: Image.network(
                            box.read('clinicImage'),
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
                          box.read('clinicName') ?? "ผู้ใช้งาน",
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
                    leading: Icon(Icons.home, color: Color(0xFF916b44)),
                    title: Text('หน้าหลัก'),
                  ),
                  ListTile(
                    leading: Icon(Icons.system_security_update,
                        color: Color(0xFF916b44)),
                    title: Text('คำขอฉีดยา'),
                    onTap: () {
                      Get.back();
                      Get.to(() => VaccineRequestsPage());
                    },
                  ),
                  ListTile(
                    leading:
                        Icon(Icons.notifications, color: Color(0xFF916b44)),
                    title: Text('แจ้งเตือน'),
                    onTap: () {
                      Get.back();
                      // Get.to(() => );
                    },
                  ),
                  ListTile(
                    leading:
                        Icon(Icons.medical_services, color: Color(0xFF916b44)),
                    title: Text('ประวัติการฉีดยา'),
                    onTap: () {
                      Get.back();
                      Get.to(() => Vaccinehistorypage());
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.supervised_user_circle,
                        color: Color(0xFF916b44)),
                    title: Text('หมอประจำคลินิก'),
                    onTap: () {
                      Get.back();
                      Get.to(() => Cliniclistdoctors());
                    },
                  ),
                  ListTile(
                    leading:
                        Icon(Icons.medical_services, color: Color(0xFF916b44)),
                    title: Text('เวลาปิด-เปิด'),
                    onTap: () => Get.to(() => Clinicopeninghours()),
                  ),
                  ListTile(
                    leading: Icon(Icons.settings, color: Color(0xFF916b44)),
                    title: Text('ตั้งค่า'),
                    onTap: () => Get.to(() => Clinicsetting()),
                  ),
                  ListTile(
                    leading:
                        Icon(MdiIcons.accountSwitch, color: Color(0xFF916b44)),
                    title: Text('สลับโหมด'),
                    onTap: () async {
                      var resGeneral = await http.get(
                          Uri.parse("$url/general/name/${box.read('email')}"));
                      if (resGeneral.statusCode == 200) {
                        showAlert(
                          title: 'สลับไปยังบัญชีผู้ใช้ทั่วไป?',
                          message: 'กด ตกลง เพื่อไปยังบัญชีผู้ใช้ทั่วไป',
                          onConfirm: () {
                            box.write('type', 'general');
                            box.write('generalName',
                                jsonDecode(resGeneral.body)['username']);
                            box.write('generalImage',
                                jsonDecode(resGeneral.body)['image']);
                            log('Name ${box.read('generalName')}');
                            Get.offAll(() => GeneralmainPage());
                          },
                        );
                      } else {
                        showAlert(
                          title: 'คุณยังไม่มีบัญชีผู้ใช้ทั่วไป!',
                          message: 'กด ตกลง เพื่อไปยังหน้าสมัครผู้ใช้ทั่วไป',
                          onConfirm: () {
                            Get.back();
                            Get.to(() => RegisterusergooglePage());
                          },
                        );
                      }
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.redAccent),
                    title: Text('ออกจากระบบ'),
                    onTap: () {
                      showAlert(
                        title: 'ออกจากระบบ?',
                        message: 'คุณต้องการออกจากระบบใช่หรือไม่',
                        onConfirm: () {
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
        body: Container(
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF916B44)),
                    strokeWidth: 3,
                  ),
                )
              : Column(
                  children: [
                    // Calendar Section with Modern Card Design
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: buildCalendar(
                        focusedDay: _focusedDay,
                        selectedDay: _selectedDay,
                        onDaySelected: (selected, focused) {
                          setState(() {
                            _focusedDay = focused;
                            _selectedDay = selected;
                            events = List.from(reservebookingListAll);
                            isLoading = false;
                          });
                        },
                        onPageChanged: (focused) {
                          setState(() {
                            _focusedDay = focused;
                          });
                        },
                        eventLoader: getEventsForDay,
                      ),
                    ),

                    // Section Header
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Color(0xFF916B44),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            "การจองวันนี้",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF916B44),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Events List
                    Expanded(
                      child: events.isEmpty
                          ? Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFE9CBAF).withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: Icon(
                                      Icons.calendar_today_outlined,
                                      size: 40,
                                      color: Color(0xFF916B44),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    "ยังไม่มีข้อมูล",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF916B44),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "โปรดเลือกวันที่เพื่อดูข้อมูล",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF916B44).withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              itemCount: events.length,
                              itemBuilder: (context, index) {
                                final item = events[index];
                                if (item.status != 2) {
                                  return const SizedBox.shrink();
                                }

                                return Container(
                                  margin: EdgeInsets.only(bottom: 12),
                                  child: InkWell(
                                    onTap: () async {
                                      final reserveData = await getReserveBook(
                                          reserveList[0].docId);
                                      final generalEmail =
                                          reserveData?['generalEmail'];

                                      if (reserveData != null) {
                                        final generalEmail =
                                            reserveData['generalEmail'];
                                        final dogDogIdRaw =
                                            reserveData['dogDogId'];

                                        if (generalEmail != null &&
                                            generalEmail.isNotEmpty) {
                                          // final reserveData =
                                          //     await getReserveBook(
                                          //         reserveList[0].docId);

                                          final dogDogId = dogDogIdRaw is int
                                              ? dogDogIdRaw
                                              : int.tryParse(
                                                      dogDogIdRaw.toString()) ??
                                                  0; // หรือ handle กรณีแปลงไม่ได้
                                          final dogDetails = await getdog(
                                              dogDogId); // ได้ DogDetailsPost?
                                          final generalData = await getGeneral(
                                              generalEmail); // ✅ ไม่มี error แล้ว
                                          if (generalData != null) {
                                            final docIdStr =
                                                reserveData['docId'].toString();

                                            _showAppointmentPopup(
                                              context,
                                              reserveData,
                                              dogDetails,
                                              docIdStr,
                                              generalData,
                                            );
                                          }
                                        }
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0xFF916B44)
                                                .withOpacity(0.08),
                                            blurRadius: 12,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                        border: Border.all(
                                          color: Color(0xFFE9CBAF)
                                              .withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            // Profile Image
                                            Container(
                                              width: 56,
                                              height: 56,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Color(0xFF916B44)
                                                        .withOpacity(0.1),
                                                    blurRadius: 8,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                child: Image.network(
                                                  item.dogDogId,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Container(
                                                      decoration: BoxDecoration(
                                                        color: Color(0xFFE9CBAF)
                                                            .withOpacity(0.3),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                      ),
                                                      child: Icon(
                                                        Icons.person,
                                                        color:
                                                            Color(0xFF916B44),
                                                        size: 28,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 16),

                                            // Content
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Name and Time Row
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          item.generalEmail,
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Color(
                                                                0xFF916B44),
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                      Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 8,
                                                                vertical: 4),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Color(
                                                                  0xFFE9CBAF)
                                                              .withOpacity(0.3),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        child: Text(
                                                          formatshowTime(
                                                              item.date!),
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Color(
                                                                0xFF916B44),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 8),

                                                  // Vaccine Info
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 6,
                                                        height: 6,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Color(0xFFDBA871),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(3),
                                                        ),
                                                      ),
                                                      SizedBox(width: 8),
                                                      Expanded(
                                                        child: Text(
                                                          item.appointmentAid
                                                              .toString(),
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Color(
                                                                    0xFF916B44)
                                                                .withOpacity(
                                                                    0.7),
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Arrow Icon
                                            InkWell(
                                              onTap: () {
                                                Get.to(() =>
                                                    Calendarbookingdetailpage(
                                                        docId: item.docId));
                                              },
                                              child: Icon(
                                                Icons.arrow_forward_ios,
                                                size: 16,
                                                color: Color(0xFF916B44)
                                                    .withOpacity(0.4),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),

                    // Bottom Safe Area
                    SizedBox(height: 16),
                  ],
                ),
        ));
  }

  // Pop-up Dialog Method
  void _showAppointmentPopup(
    BuildContext context,
    Map<String, dynamic> reserveData,
    DogDetailsPost? dogDetails,
    String docId,
    GeneralPost generalData,
  ) {
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
                            generalData.username,
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

                      // Pet Name - Main Focus
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Text(
                                  generalData.name,
                                  style: TextStyle(
                                    color: primaryBrown,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  dogDetails!.breed,
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
                                  // shape: BoxShape.circle,
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
                                  child: dogDetails.image.isNotEmpty
                                      ? Image.network(
                                          dogDetails.image,
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
                                              Icons.pets,
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
                                            Icons.pets,
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

                      // Details
                      _buildPopupDetailRow('ผู้ใช้', generalData.username),
                      _buildPopupDetailRow('เบอร์โทร', generalData.phone),
                      // _buildPopupDetailRow(
                      //     'วัคซีน', reservation.appointmentAid.toString()),
                      _buildPopupDetailRow(
                          'วันที่จอง', _formatDateString(reserveData['date'])),
                      _buildPopupDetailRow(
                          'เวลาที่จอง', _formatDate(reserveData['date'])),

                      const SizedBox(height: 32),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: _buildPopupActionButton(
                              label: 'ยกเลิกการจอง',
                              onPressed: () {
                                Navigator.pop(context);
                                // updatestatus(reservation.reserveId, 0);
                                // _showRejectDialog();
                              },
                              isPrimary: false,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildPopupActionButton(
                              label: 'บันทึกประวัติ',
                              onPressed: () {
                                // acceptrequest(reservation.reserveId, 2);
                                Navigator.pop(context);
                                Get.to(() => AddVaccinationRecordPage(
                                    docId: reserveList[0].docId));
                                // _showAcceptDialog();
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

  Widget _buildPopupActionButton({
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return Container(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? primaryBrown : Colors.grey[100],
          foregroundColor: isPrimary ? Colors.white : Colors.grey[700],
          elevation: 0,
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

  String formatshowTime(DateTime isoDate) {
    final date = isoDate.toLocal();

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

  Widget buildCalendar({
    required DateTime focusedDay,
    required DateTime? selectedDay,
    required Function(DateTime selected, DateTime focused) onDaySelected,
    required Function(DateTime focused) onPageChanged,
    required List<dynamic> Function(DateTime day) eventLoader,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEF7FF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: TableCalendar<ReserveClinicFirebase>(
        locale: 'th_TH',
        firstDay: DateTime(2020, 1, 1),
        lastDay: DateTime(DateTime.now().year + 10),
        focusedDay: focusedDay,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        onDaySelected: (selected, focused) {
          setState(() {
            _focusedDay = focused;
            _selectedDay = selected;
            events = getEventsForDay(selected);
          });
        },
        onPageChanged: onPageChanged,
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            // ✅ กรองเฉพาะ event ที่มี status == 2
            final validEvents = events.where((e) => e.status == 2).toList();

            if (validEvents.isEmpty)
              return const SizedBox.shrink(); // ❌ ไม่มี status 2 = ไม่แสดงจุด

            final markerCount = validEvents.length > 3 ? 3 : validEvents.length;

            return Padding(
              padding: const EdgeInsets.only(top: 28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(markerCount, (index) {
                  return Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    decoration: const BoxDecoration(
                      color: Colors.red, // จะใช้สีอื่นก็ได้ เช่น deepOrange
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            );
          },
        ),
        eventLoader: (day) {
          final dayOnly = DateTime(day.year, day.month, day.day);

          final dayEvents = reservebookingListAll.where((item) {
            final bookingDate =
                DateTime.parse(item.date.toString()).toLocal(); // <-- แก้ตรงนี้
            final bookingDateOnly =
                DateTime(bookingDate.year, bookingDate.month, bookingDate.day);
            return bookingDateOnly == dayOnly;
          }).toList();

          final buddhistYear = day.year + 543;
          final thaiMonths = {
            1: 'มกราคม',
            2: 'กุมภาพันธ์',
            3: 'มีนาคม',
            4: 'เมษายน',
            5: 'พฤษภาคม',
            6: 'มิถุนายน',
            7: 'กรกฎาคม',
            8: 'สิงหาคม',
            9: 'กันยายน',
            10: 'ตุลาคม',
            11: 'พฤศจิกายน',
            12: 'ธันวาคม',
          };
          final thaiDate = "${day.day} ${thaiMonths[day.month]} $buddhistYear";

          // log("📅 วันที่ $thaiDate: มี ${dayEvents.length} รายการ");

          return dayEvents;
        },
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
        calendarStyle: const CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Color(0xFFE6C29C),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Color(0xFFDBA871),
            shape: BoxShape.circle,
          ),
          markersMaxCount: 3,
          markerDecoration: BoxDecoration(
            color: Colors.deepOrange,
            shape: BoxShape.circle,
          ),
          markerSize: 6.0,
        ),
      ),
    );
  }

  Future<void> getReserve() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('reserve')
          .where('clinicEmail', isEqualTo: box.read("email"))
          .get();

      List<ReserveClinicFirebase> allData = snapshot.docs.map((doc) {
        return ReserveClinicFirebase.fromJson(doc.data(), doc.id);
      }).toList();

      allData.sort((a, b) => b.date.compareTo(a.date));
      reserveList = allData; // ตั้งค่า reserveList แทนที่เวอร์ชัน HTTP
      reservebookingListAll.clear();

      List<Future<void>> futures = [];

      for (var data in reserveList) {
        futures.add(getReserveBook(data.docId).then((bookingData) {
          if (bookingData != null) {
            try {
              final booking =
                  ReserveClinicFirebase.fromJson(bookingData, data.docId);
              reservebookingListAll.add(booking);
              log("✅ Added: ${booking.docId}");
            } catch (e) {
              log("❌ Error parsing ReserveClinicFirebase: $e");
            }
          } else {
            log("⚠️ No booking data for docId=${data.docId}");
          }
        }));
      }

      // if (allData.isNotEmpty &&
      //     (allData[0].status == 1 || allData[0].type == 1)) {
      await Future.wait(futures);

      log("Total reservebookingListAll: ${reservebookingListAll.length}");
      for (var booking in reservebookingListAll) {
        log("Booking - ID: ${booking.docId}, Date: ${booking.date}, User: ${booking.clinicEmail}");
      }
      // }
      // getGeneral(allData[0].generalEmail);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      log("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<DogDetailsPost?> getdog(int dogId) async {
    try {
      log("🐶 Getting dog info for ID: $dogId");
      var res = await http.get(Uri.parse("$url/dog/data/$dogId"));
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

  GeneralPost generalPostFromJson(String str) {
    final Map<String, dynamic> data = json.decode(str);
    return GeneralPost.fromJson(data);
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

  // Future<void> updatestatus(int reserveID, int status) async {
  //   if (status == 0) {
  //     ReserveUpdateStatusPost req =
  //         ReserveUpdateStatusPost(reserveId: reserveID, status: status);
  //     var res = await http.put(
  //       Uri.parse("$url/reserve/$reserveID"),
  //       headers: {"Content-Type": "application/json"},
  //       body: json.encode(req.toJson()),
  //     );
  //     if (res.statusCode == 200) {
  //       log("Update data clinic success");
  //     } else {
  //       log("Failed to update doctor info: ${res.statusCode}");
  //     }
  //   }
  // }

  List<ReserveClinicFirebase> getEventsForDay(DateTime day) {
    final normalizedDay = normalizeDate(day);

    return reservebookingListAll.where((item) {
      final eventDay = normalizeDate(item.date!); // ไม่ต้อง parse แล้ว
      return eventDay == normalizedDay;
    }).toList();
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
