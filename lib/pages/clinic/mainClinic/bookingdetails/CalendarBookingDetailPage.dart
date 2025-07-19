import 'dart:convert';
import 'dart:developer';

import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/model/clinicGetInjectionRecord.dart';
import 'package:puppal_application/model/clinicinjectionRecordPost.dart';
import 'package:puppal_application/model/dogdetalisPost.dart';
import 'package:puppal_application/model/generalPost.dart';
import 'package:puppal_application/model/reserveClinicPost.dart';
import 'package:puppal_application/model/reserveUpdateStatusPost.dart';
import 'package:puppal_application/model/reserveclinicfirebase.dart';
import 'package:puppal_application/pages/clinic/mainClinic/addVaccinationRecord/AddVaccinationRecordPage.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;

import 'package:puppal_application/model/clinicGetInjectionRecord.dart'
    as getInjection;

class Calendarbookingdetailpage extends StatefulWidget {
  final String docId;

  const Calendarbookingdetailpage({super.key, required this.docId});

  @override
  State<Calendarbookingdetailpage> createState() =>
      _CalendarbookingdetailpageState();
}

class _CalendarbookingdetailpageState extends State<Calendarbookingdetailpage> {
  String url = '';
  late double screenWidth;
  late double screenHeight;
  bool isNormalSelected = true;
  final box = GetStorage();
  List<DogDetailsPost> dogList = [];
  List<ReserveClinicFirebase> reserveList = [];
  List<ReserveClinicPost> todayList = [];
  List<ReserveClinicPost> yesterdayList = [];
  List<ReserveClinicPost> earlierList = [];
  bool isLoading = true;
  List<ClinicinjectionRecordPost>? vaccineHistory;
  final PageController _vaccinePageController = PageController();
  int _currentVaccineIndex = 0;

  List<getInjection.Datum>? clinicRecord; // เก็บจาก injection list API

  List<dynamic> get combinedList {
    final List<dynamic> combined = [];
    if (clinicRecord != null) combined.addAll(clinicRecord!);
    if (vaccineHistory != null) combined.addAll(vaccineHistory!);
    return combined;
  }

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
      getReserve(widget.docId);
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
        appBar: AppBar(),
        drawer: Drawer(),
        body: SingleChildScrollView(
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
                        color: const Color(0xFF916B44).withOpacity(0.15),
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
                                    borderRadius: BorderRadius.circular(16),
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
                                                BorderRadius.circular(12),
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
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF916B44),
                                        const Color(0xFFDBA871),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(25),
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
                                    borderRadius: BorderRadius.circular(15),
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
                                  const Color(0xFF916B44).withOpacity(0.3),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          /// 🧾 รายการข้อมูลสำคัญ
                          _buildInfoRow(
                              'วันเกิด', formatThaiDateTime(dog.birthday)),
                          _buildInfoRow('สี', dog.color),
                          _buildInfoRow('ตำหนิ', dog.defect),
                          _buildInfoRow('โรคประจำตัว', dog.congentialDisease),
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
                                    const Color(0xFF916B44).withOpacity(0.05),
                                    const Color(0xFFDBA871).withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      const Color(0xFF916B44).withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header Row
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF916B44),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (clinicRecord != null &&
                                          clinicRecord!.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF916B44)
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.swipe_left,
                                                  size: 16,
                                                  color: Color(0xFF916B44)),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${(clinicRecord?.length ?? 0) + (vaccineHistory?.length ?? 0)} รายการ',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF916B44),
                                                  fontWeight: FontWeight.w500,
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
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          onPressed: _currentVaccineIndex > 0
                                              ? _previousVaccinePage
                                              : null,
                                          icon: Icon(
                                            Icons.arrow_back_ios,
                                            color: _currentVaccineIndex > 0
                                                ? const Color(0xFF916B44)
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
                                          onPressed: _currentVaccineIndex <
                                                  combinedList.length - 1
                                              ? _nextVaccinePage
                                              : null,
                                          icon: Icon(
                                            Icons.arrow_forward_ios,
                                            color: _currentVaccineIndex <
                                                    combinedList.length - 1
                                                ? const Color(0xFF916B44)
                                                : Colors.grey[400],
                                          ),
                                        ),
                                      ],
                                    ),

                                    // PageView for Cards
                                    SizedBox(
                                      height: 380,
                                      child: PageView.builder(
                                        controller: _vaccinePageController,
                                        onPageChanged: (index) {
                                          if (mounted) {
                                            setState(() {
                                              _currentVaccineIndex = index;
                                            });
                                          }
                                        },
                                        itemCount: combinedList.length,
                                        itemBuilder: (context, index) {
                                          final item = combinedList[index];

                                          final vaccine =
                                              item is ClinicinjectionRecordPost
                                                  ? item.vaccine
                                                  : (item as Datum).vaccine;

                                          final date =
                                              item is ClinicinjectionRecordPost
                                                  ? item.date
                                                  : (item as Datum).date;

                                          final label = item
                                                  is ClinicinjectionRecordPost
                                              ? item.vaccineLabel
                                              : (item as Datum).vaccineLabel;

                                          return Container(
                                            width: 280,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 8),
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
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _buildInfoRow('วัคซีน',
                                                    vaccine ?? 'ไม่ระบุวัคซีน'),
                                                _buildInfoRow('วันที่',
                                                    formatThaiDateTime(date!)),
                                                const SizedBox(height: 12),
                                                Center(
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    child: Image.network(
                                                      label ?? '',
                                                      width: 200,
                                                      height: 200,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return Container(
                                                          width: 200,
                                                          height: 200,
                                                          color:
                                                              Colors.grey[200],
                                                          child: const Icon(Icons
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
                                          duration:
                                              const Duration(milliseconds: 300),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 4),
                                          height: 8,
                                          width: _currentVaccineIndex == index
                                              ? 24
                                              : 8,
                                          decoration: BoxDecoration(
                                            color: _currentVaccineIndex == index
                                                ? const Color(0xFF916B44)
                                                : const Color(0xFF916B44)
                                                    .withOpacity(0.3),
                                            borderRadius:
                                                BorderRadius.circular(4),
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
                                            Icon(Icons.vaccines_outlined,
                                                size: 48, color: Colors.grey),
                                            SizedBox(height: 12),
                                            Text(
                                              'ไม่มีข้อมูลประวัติการฉีดยา',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontStyle: FontStyle.italic,
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
                                  const Color(0xFFDBA871).withOpacity(0.05),
                                  const Color(0xFF916B44).withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF916B44).withOpacity(0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF916B44),
                                        borderRadius: BorderRadius.circular(8),
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
                                    borderRadius: BorderRadius.circular(12),
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
                                              reserveList[0].generalEmail),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const CircularProgressIndicator();
                                            } else if (snapshot.hasError) {
                                              return Text(
                                                  'Error: ${snapshot.error}');
                                            } else if (!snapshot.hasData) {
                                              return const Text(
                                                  'No data found');
                                            } else if (snapshot.data == null ||
                                                snapshot
                                                    .data!.username.isEmpty) {
                                              return const Text(
                                                  'ไม่มีข้อมูลเจ้าของ');
                                            } else {
                                              final general = snapshot.data!;
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  _buildInfoRow(
                                                      'ชื่อ', general.name),
                                                  _buildInfoRow('นามสกุล',
                                                      general.surname),
                                                  _buildInfoRow('เบอร์โทร',
                                                      general.phone),
                                                  _buildInfoRow('อีเมล',
                                                      general.userEmail),
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
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      // updatestatus(reserve.reserveId, 0);
                                      _showRejectDialog(0);
                                    },
                                    icon: const Icon(Icons.cancel,
                                        color: Colors.white),
                                    label: const Text(
                                      "ยกเลิกการจอง",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      elevation: 8,
                                      shadowColor: Colors.red.withOpacity(0.4),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Get.to(() => AddVaccinationRecordPage(
                                            docId: widget.docId,
                                          ));
                                    },
                                    icon: const Icon(Icons.check_circle,
                                        color: Colors.white),
                                    label: const Text(
                                      "บันทึกประวัติ",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      elevation: 8,
                                      shadowColor:
                                          Colors.green.withOpacity(0.4),
                                    ),
                                  ),
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
        )));
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

      // if (doc.exists) {
      //   final data = doc.data();
      //   log('✅ Data for docId=$docId: $data');

      //   final dynamic dogDogIdRaw = data?['dogDogId'];

      //   // แปลงให้เป็น int ถ้า dogDogIdRaw เป็น String หรือ int
      //   final int? dogDogId = dogDogIdRaw is int
      //       ? dogDogIdRaw
      //       : int.tryParse(dogDogIdRaw?.toString() ?? '');

      //   if (dogDogId != null) {
      //     await getdog(dogDogId);
      //   } else {
      //     log('⚠️ dogDogId is invalid or empty.');
      //   }
      // } else {
      //   log('❌ No document found for docId=$docId');
      // }
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
            // ✅ เปลี่ยนให้รับค่ากลับ แล้วเก็บใส่ตัวแปร
            final latestRecords = await getInjectionList(dogDogId, date!);
            final oldRecords = await gethistoryvaccine(dogDogId, email);

            setState(() {
              clinicRecord = latestRecords;
              vaccineHistory = oldRecords;
            });
          } else {
            log('⚠️ dogDogId หรือ email ไม่ถูกต้องหรือว่าง');
          }
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

  Future<void> getdog(int dogId) async {
    try {
      log("🐶 Getting dog info for ID: $dogId");
      var res = await http.get(Uri.parse("$url/dog/data/$dogId"));
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

  Future<void> updatestatus(String docId, int status) async {
    if (status == 0) {
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

  void _showAcceptDialog() {
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
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context, true);
                      _acceptReservation();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF916B44),
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

  void _showRejectDialog(int status) {
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
                      updatestatus(widget.docId, 0);
                      _rejectReservation();
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
}
