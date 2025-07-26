import 'dart:convert';
import 'dart:developer';

import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/model/clinicGetInjectionRecord.dart';
import 'package:puppal_application/model/clinicUpdateTypePost.dart';
import 'package:puppal_application/model/clinicinjectionRecordPost.dart';
import 'package:puppal_application/model/doctorPost.dart';
import 'package:puppal_application/model/dogPost.dart';
import 'package:puppal_application/model/dogdetalisPost.dart';
import 'package:puppal_application/model/generalPost.dart';
import 'package:puppal_application/model/reserveClinicPost.dart';
import 'package:http/http.dart' as http;
import 'package:puppal_application/model/reserveUpdateStatusPost.dart';
import 'package:puppal_application/model/reservebooking.dart';
import 'package:puppal_application/model/reserveclinicfirebase.dart';
import 'package:puppal_application/pages/clinic/mainClinic/reserve/acceptRequest.dart';
import 'package:shimmer/shimmer.dart';
import 'package:puppal_application/model/clinicGetInjectionRecord.dart'
    as getInjection;

class BookingdetailPage extends StatefulWidget {
  final String docid;
  const BookingdetailPage({super.key, required this.docid});

  @override
  State<BookingdetailPage> createState() => _BookingdetailPageState();
}

class _BookingdetailPageState extends State<BookingdetailPage> {
  String url = '';
  late double screenWidth;
  late double screenHeight;
  bool isNormalSelected = true;
  final box = GetStorage();
  List<ReserveClinicFirebase> reserveList = [];
  // ClinicGetInjectionRecord? clinicRecord;
  List<DogDetailsPost> dogList = [];
  List<ReserveClinicPost> todayList = [];
  List<ReserveClinicPost> yesterdayList = [];
  List<ReserveClinicPost> earlierList = [];
  bool _loadingData = true;
  List<ClinicinjectionRecordPost>? vaccineHistory;
  final PageController _vaccinePageController = PageController();
  int _currentVaccineIndex = 0;
  final Color primaryBrown = const Color(0xFF916B44);
  final Color secondaryBrown = const Color(0xFFDBA871);
  final Color lightBrown = const Color(0xFFE9CBAF);
  List<getInjection.Datum>? clinicRecord; // เก็บจาก injection list API

  List<dynamic> get combinedList {
    final List<dynamic> combined = [];
    if (clinicRecord != null) combined.addAll(clinicRecord!);
    if (vaccineHistory != null) combined.addAll(vaccineHistory!);
    return combined;
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
    });
    await getReserve(widget.docid);
    setState(() {
      _loadingData = false;
    });
  }

  @override
  void dispose() {
    _vaccinePageController.dispose();
    super.dispose();
  }

  void _previousVaccinePage() {
    if (mounted &&
        _vaccinePageController.hasClients &&
        _currentVaccineIndex > 0) {
      _vaccinePageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextVaccinePage() {
    if (mounted &&
        _vaccinePageController.hasClients &&
        _currentVaccineIndex < combinedList.length - 1) {
      _vaccinePageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    final combinedList = [...(clinicRecord ?? []), ...(vaccineHistory ?? [])];
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "รายละเอียดสุนัข",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 24,
              color: Colors.white,
            ),
          ),
          backgroundColor: secondaryBrown,
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {
              Get.back();
            },
          ),
        ),
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
            : Padding(
                padding: const EdgeInsets.only(top: 28),
                child: SingleChildScrollView(
                    child: Container(
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: dogList.map((dog) {
                        return Container(
                          width: screenWidth * 0.88,
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9CBAF)
                                .withOpacity(0.2), // ✅ สีพื้นไม่ไล่
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              // เงาด้านล่าง ขอบเข้ม
                              BoxShadow(
                                color:
                                    const Color(0xFF916B44).withOpacity(0.15),
                                blurRadius: 20,
                                offset: const Offset(6, 6),
                                spreadRadius: 1,
                              ),
                              // เงาด้านบน ขอบอ่อน
                              BoxShadow(
                                color: Colors.white.withOpacity(0.8),
                                blurRadius: 10,
                                offset: const Offset(-6, -6),
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            gradient: LinearGradient(
                                              colors: [
                                                const Color(0xFF916B44)
                                                    .withOpacity(0.1),
                                                const Color(0xFFDBA871)
                                                    .withOpacity(0.1),
                                              ],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF916B44)
                                                    .withOpacity(0.2),
                                                blurRadius: 12,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          padding: const EdgeInsets.all(4),
                                          child: dog.image.isNotEmpty
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: Image.network(
                                                    dog.image,
                                                    width: 200,
                                                    height: 150,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : Container(
                                                  width: 200,
                                                  height: 150,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        const Color(0xFF916B44)
                                                            .withOpacity(0.1),
                                                        const Color(0xFFDBA871)
                                                            .withOpacity(0.1),
                                                      ],
                                                    ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.pets,
                                                    size: 80,
                                                    color: Color(0xFF916B44),
                                                  ),
                                                ),
                                        ),
                                        const SizedBox(height: 16),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF916B44),
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF916B44)
                                                    .withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            dog.name,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE9CBAF)
                                                .withOpacity(0.3),
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            border: Border.all(
                                              color: const Color(0xFF916B44)
                                                  .withOpacity(0.2),
                                            ),
                                          ),
                                          child: Text(
                                            'พันธุ์: ${dog.breed}   เพศ: ${dog.gender}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF916B44),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Container(
                                    height: 2,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          const Color(0xFF916B44)
                                              .withOpacity(0.3),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  /// 🧾 รายการข้อมูลสำคัญ
                                  _buildInfoRow('วันเกิด',
                                      formatThaiDateTime(dog.birthday)),
                                  _buildInfoRow('สี', dog.color),
                                  _buildInfoRow('ตำหนิ', dog.defect),
                                  _buildInfoRow(
                                      'โรคประจำตัว', dog.congentialDisease),
                                  _buildInfoRow(
                                    'การทำหมัน',
                                    (dog.sterilization.toString() == '1' ||
                                            dog.sterilization
                                                    .toString()
                                                    .toLowerCase() ==
                                                'true')
                                        ? 'ทำหมันแล้ว'
                                        : 'ยังไม่ทำหมัน',
                                  ),
                                  _buildInfoRow('ลักษณะขน', dog.hair),
                                  const SizedBox(height: 20),

                                  /// 💉 ประวัติการฉีดยา
                                  SizedBox(
                                    height: 550,
                                    width: double.infinity,
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFF916B44)
                                                .withOpacity(0.05),
                                            const Color(0xFFDBA871)
                                                .withOpacity(0.05),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFF916B44)
                                              .withOpacity(0.2),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Header Row
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFF916B44),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: const Icon(
                                                      Icons.history,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  const Text(
                                                    'ประวัติการฉีดยา',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF916B44),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (clinicRecord != null &&
                                                  clinicRecord!.isNotEmpty)
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFF916B44)
                                                            .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const Icon(
                                                          Icons.swipe_left,
                                                          size: 16,
                                                          color: Color(
                                                              0xFF916B44)),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${(clinicRecord?.length ?? 0) + (vaccineHistory?.length ?? 0)} รายการ',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Color(0xFF916B44),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),

                                          // Content Area
                                          if (combinedList.isNotEmpty) ...[
                                            // Navigation Controls
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                IconButton(
                                                  onPressed:
                                                      _currentVaccineIndex > 0
                                                          ? _previousVaccinePage
                                                          : null,
                                                  icon: Icon(
                                                    Icons.arrow_back_ios,
                                                    color:
                                                        _currentVaccineIndex > 0
                                                            ? const Color(
                                                                0xFF916B44)
                                                            : Colors.grey[400],
                                                  ),
                                                ),
                                                Text(
                                                  '${_currentVaccineIndex + 1} / ${combinedList.length}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFF916B44),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed:
                                                      _currentVaccineIndex <
                                                              combinedList
                                                                      .length -
                                                                  1
                                                          ? _nextVaccinePage
                                                          : null,
                                                  icon: Icon(
                                                    Icons.arrow_forward_ios,
                                                    color: _currentVaccineIndex <
                                                            combinedList
                                                                    .length -
                                                                1
                                                        ? const Color(
                                                            0xFF916B44)
                                                        : Colors.grey[400],
                                                  ),
                                                ),
                                              ],
                                            ),

                                            // PageView for Cards
                                            SizedBox(
                                              height: 380,
                                              child: PageView.builder(
                                                controller:
                                                    _vaccinePageController,
                                                onPageChanged: (index) {
                                                  if (mounted) {
                                                    setState(() {
                                                      _currentVaccineIndex =
                                                          index;
                                                    });
                                                  }
                                                },
                                                itemCount: combinedList.length,
                                                itemBuilder: (context, index) {
                                                  final item =
                                                      combinedList[index];

                                                  final vaccine = item
                                                          is ClinicinjectionRecordPost
                                                      ? item.vaccine
                                                      : (item as Datum).vaccine;

                                                  final date = item
                                                          is ClinicinjectionRecordPost
                                                      ? item.date
                                                      : (item as Datum).date;

                                                  final label = item
                                                          is ClinicinjectionRecordPost
                                                      ? item.vaccineLabel
                                                      : (item as Datum)
                                                          .vaccineLabel;

                                                  return Container(
                                                    width: 280,
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8),
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: const Color(
                                                                  0xFF916B44)
                                                              .withOpacity(0.1),
                                                          blurRadius: 8,
                                                          offset: const Offset(
                                                              0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        _buildInfoRow(
                                                            'วัคซีน',
                                                            vaccine ??
                                                                'ไม่ระบุวัคซีน'),
                                                        _buildInfoRow(
                                                            'วันที่',
                                                            formatThaiDateTime(
                                                                date!)),
                                                        const SizedBox(
                                                            height: 12),
                                                        Center(
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16),
                                                            child:
                                                                Image.network(
                                                              label ?? '',
                                                              width: 200,
                                                              height: 200,
                                                              fit: BoxFit.cover,
                                                              errorBuilder:
                                                                  (context,
                                                                      error,
                                                                      stackTrace) {
                                                                return Container(
                                                                  width: 200,
                                                                  height: 200,
                                                                  color: Colors
                                                                          .grey[
                                                                      200],
                                                                  child: const Icon(
                                                                      Icons
                                                                          .image_not_supported),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),

                                            const SizedBox(height: 12),

                                            // Page Indicators
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: List.generate(
                                                combinedList.length,
                                                (index) => AnimatedContainer(
                                                  duration: const Duration(
                                                      milliseconds: 300),
                                                  margin: const EdgeInsets
                                                      .symmetric(horizontal: 4),
                                                  height: 8,
                                                  width: _currentVaccineIndex ==
                                                          index
                                                      ? 24
                                                      : 8,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        _currentVaccineIndex ==
                                                                index
                                                            ? const Color(
                                                                0xFF916B44)
                                                            : const Color(
                                                                    0xFF916B44)
                                                                .withOpacity(
                                                                    0.3),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ] else
                                            Expanded(
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: const [
                                                    Icon(
                                                        Icons.vaccines_outlined,
                                                        size: 48,
                                                        color: Colors.grey),
                                                    SizedBox(height: 12),
                                                    Text(
                                                      'ไม่มีข้อมูลประวัติการฉีดยา',
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  /// 👨‍⚕️ ข้อมูลเจ้าของ
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFFDBA871)
                                              .withOpacity(0.05),
                                          const Color(0xFF916B44)
                                              .withOpacity(0.05),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFF916B44)
                                            .withOpacity(0.2),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF916B44),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.person,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Text(
                                              'ข้อมูลเจ้าของ',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF916B44),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF916B44)
                                                    .withOpacity(0.1),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: (reserveList.isEmpty)
                                              ? const Text('ไม่มีข้อมูลจอง')
                                              : FutureBuilder<GeneralPost?>(
                                                  future: getGeneral(
                                                      reserveList[0]
                                                          .generalEmail),
                                                  builder: (context, snapshot) {
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return const CircularProgressIndicator();
                                                    } else if (snapshot
                                                        .hasError) {
                                                      return Text(
                                                          'Error: ${snapshot.error}');
                                                    } else if (!snapshot
                                                        .hasData) {
                                                      return const Text(
                                                          'No data found');
                                                    } else if (snapshot.data ==
                                                            null ||
                                                        snapshot.data!.username
                                                            .isEmpty) {
                                                      return const Text(
                                                          'ไม่มีข้อมูลเจ้าของ');
                                                    } else {
                                                      final general =
                                                          snapshot.data!;
                                                      return Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          _buildInfoRow('ชื่อ',
                                                              general.name),
                                                          _buildInfoRow(
                                                              'นามสกุล',
                                                              general.surname),
                                                          _buildInfoRow(
                                                              'เบอร์โทร',
                                                              general.phone),
                                                          _buildInfoRow(
                                                              'อีเมล',
                                                              general
                                                                  .userEmail),
                                                        ],
                                                      );
                                                    }
                                                  },
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 30),

                                  // Edit Button with Pet Theme
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildPopupActionButton(
                                          label: 'ปฏิเสธการจอง',
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            bool isConfirmed =
                                                await RejectDialog(
                                                    context, widget.docid);
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
                                                await confirmDialog(
                                                    context, widget.docid);
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

                                  const SizedBox(height: 30),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                )),
              ));
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
          elevation: 5, // ปิด elevation ของ ElevatedButton เอง
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

  Widget _buildInfoRow(String label, String? value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF916B44).withOpacity(0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF916B44).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF916B44),
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value?.isNotEmpty == true ? value! : '-',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
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

    return 'วันที่ $day $month $year';
  }

  Widget _buildInfoFieldSingle({
    required String value,
    required double screenHeight,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: screenHeight * 0.055,
            child: TextField(
              enabled: false,
              controller: TextEditingController(text: value),
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFFE9CBAF).withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Color(0xFFDBA871).withOpacity(0.5),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Color(0xFFDBA871).withOpacity(0.5),
                    width: 1,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Color(0xFFDBA871).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: TextStyle(
                color: Color(0xFF916B44),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoField({
    required IconData icon,
    required String label,
    required String value,
    required double screenHeight,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFFE9CBAF).withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Color(0xFF916B44),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF916B44),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: screenHeight * 0.055,
            child: TextField(
              enabled: false,
              controller: TextEditingController(text: value),
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFFE9CBAF).withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Color(0xFFDBA871).withOpacity(0.5),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Color(0xFFDBA871).withOpacity(0.5),
                    width: 1,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Color(0xFFDBA871).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: TextStyle(
                color: Color(0xFF916B44),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> getReserve(String docId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('reserve')
          .doc(docId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        log('✅ Data for docId=$docId: $data');

        if (data != null) {
          reserveList.clear(); // เคลียร์ก่อนใส่ใหม่

          // ✅ ใช้ model ที่ตรง
          reserveList.add(ReserveClinicFirebase.fromJson(data, doc.id));

          final dynamic dogDogIdRaw = data['dogDogId'];
          final String? email = data['generalEmail'];
          final String? date = data['date'];

          final int? dogDogId = dogDogIdRaw is int
              ? dogDogIdRaw
              : int.tryParse(dogDogIdRaw?.toString() ?? '');

          if (dogDogId != null && email != null && email.isNotEmpty) {
            await getdog(dogDogId);
            await getGeneral(email);
          } else {
            log('⚠️ dogDogId หรือ email ไม่ถูกต้องหรือว่าง');
          }
          final latestRecords = await getInjectionList(dogDogId!, date!);
          final oldRecords = await gethistoryvaccine(dogDogId, email!);

          setState(() {
            clinicRecord = latestRecords;
            vaccineHistory = oldRecords;
          });
        }
      } else {
        log('❌ No document found for docId=$docId');
      }
    } catch (e) {
      log('❌ Error while fetching document: $e');
    }
  }

  List<ClinicinjectionRecordPost> clinicinjectionRecordPostFromJson(
      String str) {
    final jsonData = json.decode(str);
    final list = jsonData['data'] as List;
    return list.map((x) => ClinicinjectionRecordPost.fromJson(x)).toList();
  }

  Future<List<ClinicinjectionRecordPost>?> gethistoryvaccine(
      int dogId, String generalEmail) async {
    try {
      final res = await http.get(
          Uri.parse("$url/clinicinjectionRecord/history/$dogId/$generalEmail"));
      if (res.statusCode == 200) {
        print('API response body: ${res.body}');
        return clinicinjectionRecordPostFromJson(res.body);
      } else {
        log("❌ Failed to load vaccine data: ${res.statusCode}");
        return null;
      }
    } catch (e) {
      log("❌ Exception while fetching vaccine info: $e");
      return null;
    }
  }

  Future<List<Datum>?> getInjectionList(int dogId, String date) async {
    log("$dogId");
    try {
      final res =
          await http.get(Uri.parse("$url/clinicinjectionRecord/$dogId/$date"));
      if (res.statusCode == 200) {
        final recordResponse = clinicGetInjectionRecordFromJson(res.body);
        return recordResponse.data; // คืนค่า List<Datum>
      } else {
        log("❌ Failed to load injection list: ${res.statusCode}");
        return null;
      }
    } catch (e) {
      log("❌ Exception while fetching vaccine info: $e");
      return null;
    }
  }

  // List<DogPost> AboutDialog(String str) =>
  //     List<DogPost>.from(json.decode(str).map((x) => DogPost.fromJson(x)));
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

  Future<void> getdog(int dogId) async {
    try {
      log("🐶 Getting dog info for ID: $dogId");
      var res = await http.get(Uri.parse("$url/dog/getdog/$dogId"));
      if (res.statusCode == 200) {
        dogList = dogDetailsPostFromJson(res.body);
        setState(() {});
      } else {
        log("❌ Failed to load dog: ${res.statusCode}");
      }
    } catch (e) {
      log("❌ Exception while fetching dog info: $e");
    }
  }

  DateTime? parseThaiDate(String dateStr) {
    const Map<String, int> thaiMonths = {
      'มกราคม': 1,
      'กุมภาพันธ์': 2,
      'มีนาคม': 3,
      'เมษายน': 4,
      'พฤษภาคม': 5,
      'มิถุนายน': 6,
      'กรกฎาคม': 7,
      'สิงหาคม': 8,
      'กันยายน': 9,
      'ตุลาคม': 10,
      'พฤศจิกายน': 11,
      'ธันวาคม': 12,
    };

    try {
      final parts = dateStr.split('-');
      if (parts.length != 3) return null;

      final day = int.parse(parts[0]);
      final month = thaiMonths[parts[1].trim()];
      final year = int.parse(parts[2]);

      if (month == null) return null;

      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }

  Future<void> acceptrequest(String docId, int status) async {
    showLoadingDialog();

    if (status == 0 || status == 2) {
      try {
        // 1. อัปเดต status
        await FirebaseFirestore.instance
            .collection('reserve')
            .doc(docId)
            .update({'status': status});

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

        log('✅ Updated status to $status for docId=$docId');
      } catch (e) {
        log('❌ Failed to update status: $e');
      }
    } else {
      log('⚠️ Status not allowed to update: $status');
    }
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
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
  // Future<void> updateType(int reserveID, int status) async {
  //   ClinicUpdateTypePost req =
  //       ClinicUpdateTypePost(reserveId: reserveID, type: status);
  //   var res = await http.put(
  //     Uri.parse("$url/reserve/type/$reserveID"),
  //     headers: {"Content-Type": "application/json"},
  //     body: json.encode(req.toJson()),
  //   );
  //   if (res.statusCode == 200) {
  //     log("Update data clinic success");
  //   } else {
  //     log("Failed to update doctor info: ${res.statusCode}");
  //   }
  // }

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
}
