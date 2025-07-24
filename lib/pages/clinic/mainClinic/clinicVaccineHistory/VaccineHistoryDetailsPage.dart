import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/model/appointmentClinic.dart';
import 'package:puppal_application/model/clinicGetInjectionRecord.dart';
import 'package:puppal_application/model/clinicinjectionRecordPost.dart';
import 'package:puppal_application/model/dogdetalisPost.dart';
import 'package:puppal_application/model/generalPost.dart';
import 'package:puppal_application/model/injectionRecordPost.dart';
import 'package:puppal_application/model/reserveClinicPost.dart';
import 'package:puppal_application/model/reservebooking.dart';
import 'package:puppal_application/model/reserveclinicfirebase.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'package:puppal_application/model/clinicGetInjectionRecord.dart'
    as getInjection;

class Vaccinehistorydetailspage extends StatefulWidget {
  final String docId;
  const Vaccinehistorydetailspage({super.key, required this.docId});

  @override
  State<Vaccinehistorydetailspage> createState() =>
      _VaccinehistorydetailspageState();
}

class _VaccinehistorydetailspageState extends State<Vaccinehistorydetailspage> {
  String url = '';
  late double screenWidth;
  late double screenHeight;
  bool isNormalSelected = true;
  final box = GetStorage();
  List<ReserveClinicFirebase> reserveList = [];
  List<DogDetailsPost> dogList = [];
  List<ClinicGetInjectionRecord> injectionList = [];
  List<GeneralPost> generalList = [];
  List<ClinicinjectionRecordPost>? vaccineHistory;
  final PageController _vaccinePageController = PageController();
  int _currentVaccineIndex = 0;
  List<getInjection.Datum>? clinicRecord;
  bool _loadingData = true;

  List<dynamic> get combinedList {
    final List<dynamic> combined = [];
    if (clinicRecord != null) combined.addAll(clinicRecord!);
    if (vaccineHistory != null) combined.addAll(vaccineHistory!);
    return combined;
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
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    final config = await Configuration.getConfig();
    url = config['apiEndPoint'];
    await getReserve(widget.docId);
    // await initializeData();
    box.write('type', 'clinic');
    setState(() {
      _loadingData = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    final combinedList = [...(clinicRecord ?? []), ...(vaccineHistory ?? [])];
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "รายละเอียดประวัติการฉีดยา",
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
            : SingleChildScrollView(
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
                                                    color:
                                                        const Color(0xFF916B44),
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
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF916B44),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (clinicRecord != null &&
                                                clinicRecord!.isNotEmpty)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF916B44)
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(Icons.swipe_left,
                                                        size: 16,
                                                        color:
                                                            Color(0xFF916B44)),
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
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              IconButton(
                                                onPressed:
                                                    _currentVaccineIndex > 0
                                                        ? _previousVaccinePage
                                                        : null,
                                                icon: Icon(
                                                  Icons.arrow_back_ios,
                                                  color: _currentVaccineIndex >
                                                          0
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
                                                          combinedList.length -
                                                              1
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
                                                    : (item as getInjection
                                                            .Datum)
                                                        .vaccine;

                                                final date = item
                                                        is ClinicinjectionRecordPost
                                                    ? item.date
                                                    : (item as getInjection
                                                            .Datum)
                                                        .date;

                                                final label = item
                                                        is ClinicinjectionRecordPost
                                                    ? item.vaccineLabel
                                                    : (item as getInjection
                                                            .Datum)
                                                        .vaccineLabel;

                                                return Container(
                                                  width: 280,
                                                  margin: const EdgeInsets
                                                      .symmetric(horizontal: 8),
                                                  padding:
                                                      const EdgeInsets.all(16),
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
                                                        offset:
                                                            const Offset(0, 2),
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
                                                                  .circular(16),
                                                          child: Image.network(
                                                            label ?? '',
                                                            width: 200,
                                                            height: 200,
                                                            fit: BoxFit.cover,
                                                            errorBuilder:
                                                                (context, error,
                                                                    stackTrace) {
                                                              return Container(
                                                                width: 200,
                                                                height: 200,
                                                                color: Colors
                                                                    .grey[200],
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
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 4),
                                                height: 8,
                                                width: _currentVaccineIndex ==
                                                        index
                                                    ? 24
                                                    : 8,
                                                decoration: BoxDecoration(
                                                  color: _currentVaccineIndex ==
                                                          index
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
                                                      ConnectionState.waiting) {
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
                                                        _buildInfoRow('นามสกุล',
                                                            general.surname),
                                                        _buildInfoRow(
                                                            'เบอร์โทร',
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

    return '$day $month $year';
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
          // ล้าง reserveList ก่อนถ้าต้องการโหลดใหม่
          reserveList.clear();

          // สร้าง model จากข้อมูลและเพิ่มเข้า list
          reserveList.add(ReserveClinicFirebase.fromJson(data, doc.id));

          final dynamic dogDogIdRaw = data['dogDogId'];
          final String? email = data['generalEmail'];
          final String? date = data['date'];

          // แปลง dogDogId เป็น int
          final int? dogDogId = dogDogIdRaw is int
              ? dogDogIdRaw
              : int.tryParse(dogDogIdRaw?.toString() ?? '');

          if (dogDogId != null && email != null && email.isNotEmpty) {
            await getdog(dogDogId);
            await getGeneral(email);
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

  Future<GeneralPost?> getGeneral(String generalEmail) async {
    try {
      final res = await http.get(Uri.parse("$url/general/$generalEmail"));

      if (res.statusCode == 200) {
        final generalPost = generalPostFromJson(res.body);
        log("✅ Loaded successfully: ${res.statusCode}");
        return generalPost;
      } else {
        log("❌ Failed to load: ${res.statusCode}");
        return null;
      }
    } catch (e) {
      log("Error: $e");
      return null;
    }
  }

  AppointmentClinic appointmentClinicFromJson(String str) {
    final jsonData = json.decode(str);
    if (jsonData is Map && jsonData['data'] != null) {
      return AppointmentClinic.fromJson(
        Map<String, dynamic>.from(jsonData),
      );
    }
    throw Exception("Invalid JSON format");
  }

  Future<AppointmentClinic?> getvaccine(
      String aids, String generalEmail) async {
    try {
      final res = await http
          .get(Uri.parse("$url/appointment/latestdate/$aids/$generalEmail"));

      if (res.statusCode == 200) {
        print('API response body: ${res.body}');
        return appointmentClinicFromJson(res.body);
      } else {
        log("❌ Failed to load vaccine data: ${res.statusCode}");
        return null;
      }
    } catch (e) {
      log("❌ Exception while fetching vaccine info: $e");
      return null;
    }
  }

  Future<List<getInjection.Datum>?> getInjectionList(
      int dogId, String date) async {
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

  // List<ClinicinjectionRecordPost> clinicinjectionRecordPostFromJson(
  //     String str) {
  //   final decoded = json.decode(str);
  //   final List<dynamic> dataList = decoded['data'];
  //   return dataList.map((x) => ClinicinjectionRecordPost.fromJson(x)).toList();
  // }

  // Future<void> getinjection(String reserveID) async {
  //   final res =
  //       await http.get(Uri.parse("$url/clinicinjectionRecord/$reserveID"));

  //   if (res.statusCode == 200) {
  //     injectionList = clinicinjectionRecordPostFromJson(res.body);
  //     for (var data in injectionList) {
  //       log(data.reserveId.toString());
  //     }
  //     setState(() {
  //       isLoading = false;
  //     });
  //   } else {
  //     log("Failed to load: ${res.statusCode}");
  //   }
  // }
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
