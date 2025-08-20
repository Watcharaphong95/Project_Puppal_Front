import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/model/appointmentClinic.dart';
import 'package:puppal_application/model/clinicGetInjectionRecord.dart';
import 'package:puppal_application/model/clinicinjectionRecordPost.dart';
import 'package:puppal_application/model/dogdetalisPost.dart';
import 'package:puppal_application/model/generalPost.dart';
import 'package:puppal_application/model/injectionRecordPost.dart';
import 'package:puppal_application/model/nextAppointmentGet.dart';
import 'package:puppal_application/model/reserveClinicPost.dart';
import 'package:puppal_application/model/reservebooking.dart';
import 'package:puppal_application/model/reserveclinicfirebase.dart';
import 'package:puppal_application/pages/clinicMainBottomNavigate.dart';
import 'package:puppal_application/pages/general/recordDog/generalRecord.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'package:puppal_application/model/clinicGetInjectionRecord.dart'
    as getInjection;
import 'package:table_calendar/table_calendar.dart';

class Vaccinehistorydetailspage extends StatefulWidget {
  final String docId;
  final DateTime? selectedDate;
  const Vaccinehistorydetailspage({
    Key? key,
    required this.docId,
    this.selectedDate,
  }) : super(key: key);

  @override
  State<Vaccinehistorydetailspage> createState() =>
      _VaccinehistorydetailspageState();
}

class _VaccinehistorydetailspageState extends State<Vaccinehistorydetailspage> {
  static const Color primaryColor = Color(0xFF916B44);
  static const Color secondaryColor = Color(0xFFDBA871);
  static const Color lightColor = Color(0xFFE9CBAF);

  final Color primaryBrown = const Color(0xFF916B44);
  final Color secondaryBrown = const Color(0xFFDBA871);
  final Color lightBrown = const Color(0xFFE9CBAF);

  String nextAid = '';
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

  late NextAppointmentGet nextAppointData;

  TextEditingController appointmentDateController = TextEditingController();

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
                                  height: 500,
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
                                        // Content Area
                                        if (combinedList.isNotEmpty) ...[
                                          const SizedBox(height: 12),

                                          // การ์ดเดียว (เอาอันแรกสุด หรือจะเปลี่ยนเป็น last ก็ได้)
                                          Builder(
                                            builder: (context) {
                                              final item = combinedList
                                                  .first; // หรือใช้ combinedList.last;

                                              final vaccine = item
                                                      is ClinicinjectionRecordPost
                                                  ? item.vaccine
                                                  : (item as getInjection.Datum)
                                                      .vaccine;

                                              final date = item
                                                      is ClinicinjectionRecordPost
                                                  ? item.date
                                                  : (item as getInjection.Datum)
                                                      .date;

                                              final label = item
                                                      is ClinicinjectionRecordPost
                                                  ? item.vaccineLabel
                                                  : (item as getInjection.Datum)
                                                      .vaccineLabel;

                                              return Container(
                                                width: double.infinity,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                padding:
                                                    const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
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
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    _buildInfoRow(
                                                        'วัคซีน',
                                                        vaccine ??
                                                            'ไม่ระบุวัคซีน'),
                                                    _buildInfoRow(
                                                        'วันที่',
                                                        formatThaiDateTime(
                                                            date!)),
                                                    const SizedBox(height: 12),
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
                                                  if (snapshot.hasError) {
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

                                _buildModernDateField(
                                  label: "วันนัดครั้งถัดไป",
                                  controller: appointmentDateController,
                                  icon: Icons.calendar_month,
                                  screenHeight:
                                      MediaQuery.of(context).size.height,
                                  onTap: () async {
                                    if (nextAppointData.date != null &&
                                        nextAppointData.date.isNotEmpty &&
                                        nextAppointData.date != "0000-00-00") {
                                      await pickDate(context,
                                          DateTime.parse(nextAppointData.date),
                                          (date) {
                                        setState(() {
                                          appointmentDateController.text =
                                              formatThaiDateTime(date);
                                        });
                                      });
                                    } else {
                                      // Optionally show a default date picker starting from today
                                      await pickDate(context, DateTime.now(),
                                          (date) {
                                        setState(() {
                                          appointmentDateController.text =
                                              formatThaiDateTime(date);
                                        });
                                      });
                                    }
                                  },
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                          ? 'กรุณาเลือกวันที่ฉีดวัคซีน'
                                          : null,
                                ),

                                const SizedBox(height: 30),

                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: _buildPopupActionButton(
                                          label: "ยกเลิกวันนัด",
                                          onPressed: () async {
                                            bool isConfirmed =
                                                await RejectDialog(
                                                    context, nextAid);
                                            if (!isConfirmed) {
                                              log("ผู้ใช้ยกเลิกการบันทึก");
                                              return;
                                            }
                                          },
                                          isPrimary:
                                              false, // ปุ่มสีเทาแบบ secondary
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: _buildPopupActionButton(
                                          label: "บันทึก",
                                          onPressed: () {
                                            showAlert(
                                                title: 'บันทึกวันนัดใหม่?',
                                                message: '',
                                                context: context,
                                                onConfirm: () async {
                                                  await updateNewAppointment();
                                                });
                                          },
                                          isPrimary:
                                              true, // ปุ่ม primary สีน้ำตาล (primaryBrown)
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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

  Future<void> updateNewAppointment() async {
    showLoadingDialog();
    DateTime parsedThai = DateFormat('d MMMM yyyy', 'th_TH')
        .parse(appointmentDateController.text);
    DateTime nextDate =
        DateTime(parsedThai.year - 543, parsedThai.month, parsedThai.day);

    String nextDateString =
        "${nextDate.year}-${nextDate.month.toString().padLeft(2, '0')}-${nextDate.day.toString().padLeft(2, '0')}";

    final body = jsonEncode({"nextDate": nextDateString});

    final res = await http.put(
      Uri.parse("$url/clinicinjectionRecord/nextAppointmentEdit/$nextAid"),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (res.statusCode == 200) {
      log("Appointment updated successfully");
      Get.back();
      showAlertNoClose(title: 'แก้ไขวันนัดแล้ว', message: '');
    } else {
      log("API Error: ${res.statusCode} - ${res.body}");
    }
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
          elevation: 5,
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

  Widget _buildModernDateField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required double screenHeight,
    required VoidCallback onTap,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF916B44),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Color(0xFFE9CBAF),
              width: 1.5,
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
          child: TextFormField(
            controller: controller,
            readOnly: true,
            onTap: onTap,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF916B44),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              prefixIcon: Container(
                margin: EdgeInsets.all(12),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFFE9CBAF).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: Color(0xFF916B44),
                  size: 20,
                ),
              ),
              suffixIcon: Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF916B44),
              ),
              border: InputBorder.none,
              hintText: 'เลือก$label',
              hintStyle: TextStyle(
                color: Color(0xFF916B44).withOpacity(0.5),
                fontSize: 16,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
            validator: validator,
          ),
        ),
      ],
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
              maxLines: 1, // จำกัด 1 บรรทัด
              overflow: TextOverflow.clip, // ตัดข้อความเกินโดยไม่เติม '...'
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
          final String? generalEmail = data['generalEmail'];
          final String? clinicEmail = data['clinicEmail'];
          final String? date = data['date'];

          // แปลง dogDogId เป็น int
          final int? dogDogId = dogDogIdRaw is int
              ? dogDogIdRaw
              : int.tryParse(dogDogIdRaw?.toString() ?? '');

          if (dogDogId != null &&
              generalEmail != null &&
              generalEmail.isNotEmpty) {
            await getdog(dogDogId);
            await getGeneral(generalEmail);
            // final latestRecords = await getInjectionList(dogDogId, date!);
            final oldRecords = await gethistoryvaccine(dogDogId, clinicEmail!);

            setState(() {
              // clinicRecord = latestRecords;
              // vaccineHistory = oldRecords;
              vaccineHistory = oldRecords != null ? [oldRecords] : [];
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

  ClinicinjectionRecordPost clinicinjectionRecordPostFromJson(String str) =>
      ClinicinjectionRecordPost.fromJson(json.decode(str)['data']);

  Future<ClinicinjectionRecordPost?> gethistoryvaccine(
      int dogId, String clinicEmail) async {
    if (widget.selectedDate == null) return null;

    String onlyDate =
        widget.selectedDate!.toUtc().toIso8601String().substring(0, 10);

    log("Selected date: $onlyDate");

    try {
      final res = await http.get(Uri.parse(
          "$url/clinicinjectionRecord/newhistory/$dogId/$onlyDate/$clinicEmail"));

      if (res.statusCode == 200) {
        log('API response body: ${res.body}');
        final Map<String, dynamic> decoded = jsonDecode(res.body);

        // Access 'nextAppointment_aid' directly
        nextAid = decoded['data']['nextAppointment_aid']!.toString();

        if (nextAid != null && nextAid.isNotEmpty) {
          await getNextAppointmentDate(nextAid);
        } else {
          log("nextAppointmentAid is null, skipping API call");
        }

        return clinicinjectionRecordPostFromJson(res.body); // single object
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

  Future<void> getNextAppointmentDate(String next) async {
    var res = await http
        .get(Uri.parse("$url/clinicinjectionRecord/nextAppointment/$next"));
    if (res.statusCode == 200) {
      var body = jsonDecode(res.body) as List;
      if (body.isNotEmpty) {
        nextAppointData = NextAppointmentGet.fromJson(body[0]);
        appointmentDateController.text = (nextAppointData.date == null ||
                nextAppointData.date.isEmpty ||
                nextAppointData.date == "0000-00-00")
            ? "ไม่มีวันนัด"
            : formatThaiDateTime(DateTime.parse(nextAppointData.date));
        log(nextAppointData.date);
      } else {
        log("No appointment found");
      }
    } else {
      log("API Error: ${res.statusCode} - ${res.body}");
    }
    log(nextAppointData.toString());
  }

  Future<bool> RejectDialog(BuildContext context, String aid) async {
    return await showDialog<bool>(
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
              crossAxisAlignment: CrossAxisAlignment.center,
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
                  "ยกเลิกวันนัดครั้งถัดไป?",
                  style: TextStyle(
                    color: Color(0xFF916B44),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "คุณต้องการยกเลิกวันนัดครั้งถัดไปหรือไม่?",
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
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.grey.shade500,
                    width: 1.5,
                  ),
                ),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
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
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: const Color(0xFF916B44),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF916B44).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextButton(
                  onPressed: () async {
                    showLoadingDialog();
                    var res = await http.put(Uri.parse(
                        "$url/clinicinjectionRecord/nextAppointmentRemove/$aid"));
                    await getReserve(widget.docId);
                    Get.back();
                    Get.back();
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

  Future<void> pickDate(BuildContext context, DateTime? initialDate,
      Function(DateTime) onPick) async {
    FocusScope.of(context).requestFocus(FocusNode());

    DateTime selectedDate = initialDate ?? DateTime.now();
    DateTime focusedDate = selectedDate;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Color(0xFFFAF8F5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFFDBA871),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'เลือกวันที่',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              content: Container(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height * 0.525,
                child: TableCalendar<DateTime>(
                  firstDay: DateTime(2020),
                  lastDay: DateTime.now().add(Duration(days: 365 * 5)),
                  focusedDay: focusedDate,
                  selectedDayPredicate: (day) => isSameDay(selectedDate, day),
                  calendarFormat: CalendarFormat.month,
                  startingDayOfWeek: StartingDayOfWeek.sunday,
                  locale: 'th',
                  // Disable past dates
                  enabledDayPredicate: (day) {
                    DateTime today = DateTime.now();
                    DateTime dayOnly = DateTime(day.year, day.month, day.day);
                    DateTime todayOnly =
                        DateTime(today.year, today.month, today.day);
                    return dayOnly.isAfter(todayOnly) ||
                        dayOnly.isAtSameMomentAs(todayOnly);
                  },

                  // Calendar styling
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    weekendTextStyle: TextStyle(
                      color: Color(0xFF916B44),
                      fontWeight: FontWeight.w600,
                    ),
                    defaultTextStyle: TextStyle(
                      color: Color(0xFF916B44),
                      fontWeight: FontWeight.w600,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Color(0xFFDBA871),
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Color(0xFF916B44).withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: Color(0xFFDBA871),
                      shape: BoxShape.circle,
                    ),
                    // Disable past dates
                    disabledTextStyle: TextStyle(
                      color: Colors.grey.withOpacity(0.4),
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  // Custom header with year/month selectors
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    leftChevronVisible: false, // Hide default chevrons
                    rightChevronVisible: false,
                    titleTextStyle: TextStyle(
                      color: Color(0xFF916B44),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Custom header builder with dropdowns
                  calendarBuilders: CalendarBuilders(
                    headerTitleBuilder: (context, day) {
                      return Container(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Previous month button
                            IconButton(
                              onPressed: () {
                                DateTime newDate = DateTime(
                                    focusedDate.year, focusedDate.month - 1, 1);
                                // Ensure new date doesn't exceed bounds
                                if (newDate.isAfter(DateTime(2020, 1, 1))) {
                                  setState(() {
                                    focusedDate = newDate;
                                  });
                                }
                              },
                              icon: Icon(
                                Icons.chevron_left,
                                color: Color(0xFF916B44),
                                size: 20,
                              ),
                            ),

                            // Month and Year dropdowns
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Month dropdown
                                  Flexible(
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 4),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Color(0xFF916B44)
                                                .withOpacity(0.3)),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<int>(
                                          value: focusedDate.month,
                                          style: TextStyle(
                                            color: Color(0xFF916B44),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          dropdownColor: Colors.white,
                                          isExpanded: true,
                                          items: List.generate(12, (index) {
                                            int month = index + 1;
                                            return DropdownMenuItem<int>(
                                              value: month,
                                              child: Text(
                                                DateFormat.MMMM('th').format(
                                                    DateTime(2024, month)),
                                                style: TextStyle(
                                                    color: Color(0xFF916B44),
                                                    fontSize: 12),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          }),
                                          onChanged: (int? newMonth) {
                                            if (newMonth != null) {
                                              DateTime now = DateTime.now();
                                              DateTime newDate = DateTime(
                                                  focusedDate.year,
                                                  newMonth,
                                                  1);

                                              // If selecting current year and a past month, don't allow it
                                              if (focusedDate.year ==
                                                      now.year &&
                                                  newMonth < now.month) {
                                                return; // Don't change if trying to select past month in current year
                                              }

                                              // Ensure the new date doesn't exceed lastDay
                                              DateTime lastDay = DateTime.now()
                                                  .add(Duration(days: 365 * 5));
                                              if (newDate.isAfter(lastDay)) {
                                                newDate = DateTime(lastDay.year,
                                                    lastDay.month, 1);
                                              }
                                              setState(() {
                                                focusedDate = newDate;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: 4),

                                  // Year dropdown
                                  Flexible(
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 4),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Color(0xFF916B44)
                                                .withOpacity(0.3)),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<int>(
                                          value: focusedDate.year,
                                          style: TextStyle(
                                            color: Color(0xFF916B44),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          dropdownColor: Colors.white,
                                          isExpanded: true,
                                          items: List.generate(
                                            (DateTime.now().year + 10) -
                                                DateTime.now().year +
                                                1,
                                            (index) {
                                              int year =
                                                  DateTime.now().year + index;
                                              int buddhistYear = year + 543;
                                              return DropdownMenuItem<int>(
                                                value: year,
                                                child: Text(
                                                  'พ.ศ. $buddhistYear',
                                                  style: TextStyle(
                                                      color: Color(0xFF916B44),
                                                      fontSize: 12),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              );
                                            },
                                          ), // No reverse needed since we start from current year
                                          onChanged: (int? newYear) {
                                            if (newYear != null) {
                                              DateTime newDate;
                                              DateTime now = DateTime.now();

                                              // If selecting current year, keep current month or later
                                              if (newYear == now.year) {
                                                // Use current month if focused month is earlier than current month
                                                int monthToUse =
                                                    focusedDate.month <
                                                            now.month
                                                        ? now.month
                                                        : focusedDate.month;
                                                newDate = DateTime(
                                                    newYear, monthToUse, 1);
                                              } else {
                                                // For other years, keep the focused month
                                                newDate = DateTime(newYear,
                                                    focusedDate.month, 1);
                                              }

                                              // Ensure the new date doesn't exceed lastDay
                                              DateTime lastDay = DateTime.now()
                                                  .add(Duration(days: 365 * 5));
                                              if (newDate.isAfter(lastDay)) {
                                                newDate = DateTime(lastDay.year,
                                                    lastDay.month, 1);
                                              }
                                              setState(() {
                                                focusedDate = newDate;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Next month button
                            IconButton(
                              onPressed: () {
                                DateTime newDate = DateTime(
                                    focusedDate.year, focusedDate.month + 1, 1);
                                // Ensure new date doesn't exceed bounds
                                DateTime lastDay =
                                    DateTime.now().add(Duration(days: 365 * 5));
                                if (newDate.isBefore(lastDay) ||
                                    isSameDay(newDate, lastDay)) {
                                  setState(() {
                                    focusedDate = newDate;
                                  });
                                }
                              },
                              icon: Icon(
                                Icons.chevron_right,
                                color: Color(0xFF916B44),
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      color: Color(0xFF916B44),
                      fontWeight: FontWeight.w600,
                    ),
                    weekendStyle: TextStyle(
                      color: Color(0xFF916B44),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  onDaySelected: (selectedDay, focusedDay) {
                    // Only allow selection of today or future dates
                    DateTime today = DateTime.now();
                    DateTime selectedDayOnly = DateTime(
                        selectedDay.year, selectedDay.month, selectedDay.day);
                    DateTime todayOnly =
                        DateTime(today.year, today.month, today.day);

                    if (selectedDayOnly.isAfter(todayOnly) ||
                        selectedDayOnly.isAtSameMomentAs(todayOnly)) {
                      setState(() {
                        selectedDate = selectedDay;
                        focusedDate = focusedDay;
                      });
                    }
                  },

                  onPageChanged: (focusedDay) {
                    setState(() {
                      focusedDate = focusedDay;
                    });
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'ยกเลิก',
                    style: TextStyle(
                      color: Color(0xFF916B44),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    onPick(selectedDate);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFDBA871),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'ตกลง',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
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
