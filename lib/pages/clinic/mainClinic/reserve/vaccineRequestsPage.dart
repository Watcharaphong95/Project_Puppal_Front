import 'dart:convert';
import 'dart:developer';

import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:puppal_application/pages/clinic/mainClinic/clinicListDoctors.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicMain.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicOpeningHours.dart';
import 'package:puppal_application/pages/clinic/mainClinic/reserve/acceptRequest.dart';
import 'package:puppal_application/pages/clinic/mainClinic/reserve/bookingDetailPage.dart';
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
  List<Reservebooking> reservebookingList = [];
  List<ReserveClinicFirebase> todayList = [];
  List<ReserveClinicFirebase> yesterdayList = [];
  List<ReserveClinicFirebase> earlierList = [];
  var db = FirebaseFirestore.instance;
  List<String> messages = [];
  bool isLoading = true;
  final Color primaryBrown = const Color(0xFF916B44);
  final Color secondaryBrown = const Color(0xFFDBA871);
  final Color lightBrown = const Color(0xFFE9CBAF);

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
      // getReserve();
      fetchReserveData();
      _init();
    });
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
                    onTap: () {
                      Get.to(() => ClinicmainPage());
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.system_security_update,
                        color: Color(0xFF916b44)),
                    title: Text('คำขอฉีดยา'),
                    onTap: () {
                      Get.to(() => VaccineRequestsPage());
                    },
                  ),
                  ListTile(
                    leading:
                        Icon(Icons.medical_services, color: Color(0xFF916b44)),
                    title: Text('ประวัติการฉีดยา'),
                  ),
                  ListTile(
                    leading: Icon(Icons.supervised_user_circle,
                        color: Color(0xFF916b44)),
                    title: Text('หมอประจำคลินิก'),
                    onTap: () {
                      Get.to(() => Cliniclistdoctors());
                    },
                  ),
                  ListTile(
                    leading:
                        Icon(Icons.medical_services, color: Color(0xFF916b44)),
                    title: Text('เวลาปิด-เปิด'),
                    onTap: () {
                      Get.to(() => Clinicopeninghours());
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.settings, color: Color(0xFF916b44)),
                    title: Text('ตั้งค่า'),
                    onTap: () {},
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
                            box.write('generalName',
                                jsonDecode(resGeneral.body)['username']);
                            box.write('generalImage',
                                jsonDecode(resGeneral.body)['image']);
                            log('Name ${box.read('generalName')}');
                            Get.to(() => GeneralmainPage());
                          },
                        );
                      } else {
                        showAlert(
                          title: 'คุณยังไม่มีบัญชีผู้ใช้ทั่วไป!',
                          message: 'กด ตกลง เพื่อไปยังหน้าสมัครผู้ใช้ทั่วไป',
                          onConfirm: () {
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
        body: Column(children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isNormalSelected
                            ? const Color(0xFF916B44)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: isNormalSelected
                            ? [
                                BoxShadow(
                                  color:
                                      const Color(0xFF916B44).withOpacity(0.3),
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isNormalSelected
                            ? Colors.transparent
                            : const Color(0xFF916B44),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: !isNormalSelected
                            ? [
                                BoxShadow(
                                  color:
                                      const Color(0xFF916B44).withOpacity(0.3),
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
          Column(
            children: [
              if (todayList
                  .where((data) => data.type == (isNormalSelected ? 0 : 1))
                  .isNotEmpty)
                _buildDateHeader('วันนี้'),
              ...todayList
                  .where((data) => data.type == (isNormalSelected ? 0 : 1))
                  .map((data) => _buildRequestCard(
                        data.status == 1 ? 'รอตอบรับ' : 'เสร็จสิ้น',
                        data.generalEmail ?? '-',
                        formatshowTime(data.date.toString()),
                        data.docId,
                      )),
              if (yesterdayList
                  .where((data) => data.type == (isNormalSelected ? 0 : 1))
                  .isNotEmpty)
                _buildDateHeader('เมื่อวาน'),
              ...yesterdayList
                  .where((data) => data.type == (isNormalSelected ? 0 : 1))
                  .map((data) => _buildRequestCard(
                        data.status == 1 ? 'รอตอบรับ' : 'เสร็จสิ้น',
                        data.generalEmail ?? '-',
                        formatshowTime(data.date.toString()),
                        data.docId,
                      )),
              if (earlierList
                  .where((data) => data.type == (isNormalSelected ? 0 : 1))
                  .isNotEmpty)
                _buildDateHeader('ก่อนหน้านี้'),
              ...earlierList
                  .where((data) => data.type == (isNormalSelected ? 0 : 1))
                  .map((data) => _buildRequestCard(
                        data.status == 1 ? 'รอตอบรับ' : 'เสร็จสิ้น',
                        data.generalEmail ?? '-',
                        formatshowTime(data.date.toString()),
                        data.docId,
                      )),
              if (todayList
                      .where((data) => data.type == (isNormalSelected ? 0 : 1))
                      .isEmpty &&
                  yesterdayList
                      .where((data) => data.type == (isNormalSelected ? 0 : 1))
                      .isEmpty &&
                  earlierList
                      .where((data) => data.type == (isNormalSelected ? 0 : 1))
                      .isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(FontAwesomeIcons.syringe,
                            color: Color(0xFF916B44)),
                        Text(
                          'ไม่มีคำขอจองฉีดวัคซีน',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ]));
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

  // void readData() async {
  //   var query = db.collection("reserve").where("name");
  //   var result = await query.get();

  //   List<String> newMessages =
  //       result.docs.map((doc) => doc['message'] as String).toList();

  //   setState(() {
  //     messages = newMessages;
  //   });
  // }

  Future<void> fetchReserveData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('reserve')
        .where('clinicEmail', isEqualTo: box.read("email"))
        .get();

    List<ReserveClinicFirebase> allData = snapshot.docs.map((doc) {
      return ReserveClinicFirebase.fromJson(doc.data(), doc.id);
    }).toList();

    allData.sort((a, b) => b.date.compareTo(a.date));

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

    todayList.sort((a, b) => b.date.compareTo(a.date));
    yesterdayList.sort((a, b) => b.date.compareTo(a.date));
    earlierList.sort((a, b) => b.date.compareTo(a.date));

    setState(() {
      // อัปเดต state
      todayList = todayList;
      yesterdayList = yesterdayList;
      earlierList = earlierList;
    });

    // ดึง reserveBook จาก doc แรกที่เจอ
    if (todayList.isNotEmpty) {
      await getReserveBook(todayList[0].docId);
      await getGeneral(todayList[0].generalEmail);
    } else if (yesterdayList.isNotEmpty) {
      await getReserveBook(yesterdayList[0].docId);
      await getGeneral(todayList[0].generalEmail);
    } else if (earlierList.isNotEmpty) {
      await getReserveBook(earlierList[0].docId);
      await getGeneral(todayList[0].generalEmail);
    } else {
      log("ℹ️ No reserve data to fetch reserveBook.");
    }
  }

  Widget _buildRequestCard(
      String status, String name, String time, String docid) {
    return GestureDetector(
      onTap: () async {
        log("📋 กำลังดึงข้อมูล docid: $docid");

        final reserveData = await getReserveBook(docid);

        if (reserveData != null) {
          final generalEmail = reserveData['generalEmail'];
          final dogDogIdRaw = reserveData['dogDogId'];
          final dogDogId = dogDogIdRaw is int
              ? dogDogIdRaw
              : int.tryParse(dogDogIdRaw.toString()) ??
                  0; // หรือ handle กรณีแปลงไม่ได้

          final dogDetails = await getdog(dogDogId); // ได้ DogDetailsPost?

          if (generalEmail != null && generalEmail.isNotEmpty) {
            await getGeneral(generalEmail);
          }

          _showAppointmentPopup(
              context, reserveData, dogDetails, reserveData['docId']);
        } else {
          log("⚠️ ไม่มีข้อมูลการจองใน reserveData");
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(9.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          text: 'คุณ ',
                          children: [
                            TextSpan(
                              text: name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(text: ' ได้จองเวลากับคลินิกของคุณ'),
                          ],
                        ),
                      ),
                      Text(
                        time,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              ClipRRect(
                borderRadius:
                    const BorderRadius.horizontal(right: Radius.circular(12)),
                child: GestureDetector(
                  onTap: () {
                    _openBookingDetail(docid);
                  },
                  child: Container(
                    color: const Color(0xFFFFB703),
                    width: 60,
                    alignment: Alignment.center,
                    child: const Icon(Icons.arrow_forward, color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
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
                              onPressed: () {
                                Navigator.pop(context);
                                _showRejectDialog(docId);
                              },
                              isPrimary: false,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildPopupActionButton(
                              label: 'ยืนยันการจอง',
                              onPressed: () {
                                Navigator.pop(context);
                                _showAcceptDialog(docId);
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
    if (status == 0 || status == 2) {
      try {
        await FirebaseFirestore.instance
            .collection('reserve')
            .doc(docId)
            .update({
          'status': status,
        });

        log('✅ Updated status to $status for docId=$docId');
      } catch (e) {
        log('❌ Failed to update status: $e');
      }
    } else {
      log('⚠️ Status not allowed to update: $status');
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

  void _showAcceptDialog(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Color(0xFF916B44).withOpacity(0.1),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(
                Icons.check,
                color: Color(0xFF916B44),
                size: 32,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'คุณต้องการยืนยันการนัดหมายนี้หรือไม่?',
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'เมื่อตกลง การนัดหมายนี้จะถือว่ายืนยันแล้ว',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'ยกเลิก',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFF916B44)),
                          );
                        },
                      );

                      await Future.delayed(const Duration(seconds: 3));

                      Navigator.of(context, rootNavigator: true).pop();

                      Navigator.pop(context, true);

                      acceptrequest(docId, 2);
                      // _acceptReservation();
                      _init();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF916B44),
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    child: const Text('ตกลง'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(
                Icons.close,
                color: Colors.red,
                size: 32,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'คุณต้องการปฏิเสธการนัดหมายนี้หรือไม่?',
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'โปรดทราบว่าการดำเนินการนี้ไม่สามารถย้อนกลับได้',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'ยกเลิก',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context, true);
                      acceptrequest(docId, 0);
                      // _rejectReservation();
                      _init();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    child: const Text('ตกลง'),
                  ),
                ),
              ],
            ),
          ],
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

  Future<void> getGeneral(String generalEmail) async {
    try {
      var res = await http.get(Uri.parse("$url/general/$generalEmail"));
      if (res.statusCode == 200) {
        generalList = generalPostFromJson(res.body);

        if (generalList.isNotEmpty) {
          log(generalList[0].name);
          log(generalList[0].phone);
          log(generalList[0].image);
        } else {
          log("⚠️ generalList is empty");
        }

        setState(() {
          isLoading = false;
        });
        log("✅ Loaded successfully: ${res.statusCode}");
      } else {
        log("❌ Failed to load: ${res.statusCode}");
      }
    } catch (e) {
      log("Error: $e");
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

  Future<void> _init() async {
    final config = await Configuration.getConfig();
    url = config['apiEndPoint'];
    // await getReserve();
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
