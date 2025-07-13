import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_time_patterns.dart';
import 'package:intl/intl.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/main.dart';
import 'package:puppal_application/model/appointmentClinic.dart';
import 'package:puppal_application/model/appointmentPost.dart';
import 'package:puppal_application/model/clinicinjectionRecordPost.dart';
import 'package:puppal_application/model/reserveUpdateStatusPost.dart';
import 'package:http/http.dart' as http;
import 'package:puppal_application/model/reservebooking.dart';
import 'package:puppal_application/model/reserveclinicfirebase.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicMain.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddVaccinationRecordPage extends StatefulWidget {
  final String docId;
  const AddVaccinationRecordPage({super.key, required this.docId});

  @override
  State<AddVaccinationRecordPage> createState() =>
      _AddVaccinationRecordPageState();
}

class _AddVaccinationRecordPageState extends State<AddVaccinationRecordPage> {
  final _formKey = GlobalKey<FormState>();
  String url = '';
  List<ReserveClinicFirebase> reserveList = [];
  static const Color primaryColor = Color(0xFF916B44);
  static const Color secondaryColor = Color(0xFFDBA871);
  static const Color lightColor = Color(0xFFE9CBAF);
  String? selectedVaccine;
  File? _imageFile;
  // final controller = Get.find<ClinicinjectionRecordPost>();
  final TextEditingController batchController = TextEditingController();
  TextEditingController vaccineController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController nextDateController = TextEditingController();

  DateTime? vaccinationDate;
  DateTime? nextAppointmentDate;
  bool isLoading = true;
  bool vaccineChanged = false;
  bool dateChanged = false;

  late double screenWidth;
  late double screenHeight;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    final config = await Configuration.getConfig();
    url = config['apiEndPoint'];

    await getReserve(widget.docId);

    setState(() {
      isLoading = false;
    });
  }

  // ฟังก์ชันแปลงวันที่เป็นไทย
  String formatThaiDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month;
    final year = date.year + 543; // แปลงเป็นปี พ.ศ.
    return '$day-$month-$year';
  }

  // ฟังก์ชันเลือกวัน
  Future<void> pickDate(BuildContext context, DateTime? initialDate,
      Function(DateTime) onPick) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      locale: const Locale('th', 'TH'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: primaryColor,
              secondary: secondaryColor,
            ),
            dialogBackgroundColor: Colors.white,
            textTheme: const TextTheme(
              headlineSmall: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
              titleMedium: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
              bodyLarge: TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white,
              headerBackgroundColor: primaryColor,
              headerForegroundColor: Colors.white,
              dayForegroundColor: MaterialStateColor.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.white;
                }
                return Colors.black87;
              }),
              dayBackgroundColor: MaterialStateColor.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return primaryColor;
                }
                return Colors.transparent;
              }),
              todayForegroundColor: MaterialStateColor.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.white;
                }
                return primaryColor;
              }),
              todayBackgroundColor: MaterialStateColor.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return primaryColor;
                }
                return lightColor.withOpacity(0.3);
              }),
              yearForegroundColor: MaterialStateColor.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.white;
                }
                return Colors.black87;
              }),
              yearBackgroundColor: MaterialStateColor.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return primaryColor;
                }
                return Colors.transparent;
              }),
              rangeSelectionBackgroundColor: lightColor.withOpacity(0.3),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onPick(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "เพิ่มข้อมูลวัคซีน",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.medical_services,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "บันทึกประวัติการรับวัคซีน",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "กรอกข้อมูลวัคซีนที่ฉีดให้สัตว์เลี้ยง",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Vaccine Selection
                _buildFormCard(
                  title: "วัคซีนป้องกันโรค",
                  icon: Icons.vaccines,
                  child: TextFormField(
                    controller: vaccineController,
                    decoration: InputDecoration(
                      hintText: vaccineController.text,
                      filled: true,
                      fillColor: lightColor.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'กรุณากรอกชื่อวัคซีน'
                        : null,
                  ),
                ),
                const SizedBox(height: 16),

                // Batch Number
                _buildFormCard(
                  title: "หมายเลขชุดวัคซีน",
                  icon: Icons.qr_code,
                  child: SizedBox(
                    width: double.infinity,
                    height: 180,
                    child: ElevatedButton(
                      onPressed: _pickImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightColor.withOpacity(0.5),
                        foregroundColor: Colors.black87,
                        padding: EdgeInsets.zero,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: (_imageFile != null && _imageFile!.existsSync())
                            ? Image.file(
                                _imageFile!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: lightColor.withOpacity(0.3),
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 48,
                                  color: Color(0xFF916B44),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                _buildFormCard(
                  title: "วันที่ฉีดวัคซีน",
                  icon: Icons.calendar_month,
                  child: TextFormField(
                    controller: dateController,
                    readOnly: true,
                    onTap: () async {
                      await pickDate(context, vaccinationDate, (date) {
                        setState(() {
                          vaccinationDate = date;
                          dateController.text = formatThaiDateTime(date);
                        });
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'เลือกวันที่ฉีด',
                      filled: true,
                      fillColor: lightColor.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      suffixIcon: Icon(
                        Icons.calendar_month,
                        color: primaryColor,
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'กรุณาเลือกวันที่ฉีดวัคซีน'
                        : null,
                  ),
                ),

                const SizedBox(height: 16),
                _buildFormCard(
                    title: "วันนัดครั้งถัดไป",
                    icon: Icons.calendar_month,
                    child: TextFormField(
                      controller: nextDateController,
                      readOnly: true,
                      onTap: () async {
                        await pickDate(context, nextAppointmentDate, (date) {
                          setState(() {
                            nextAppointmentDate = date;
                            nextDateController.text = formatThaiDateTime(date);
                          });
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'เลือกวันนัดครั้งถัดไป',
                        filled: true,
                        fillColor: lightColor.withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor, width: 2),
                        ),
                        suffixIcon:
                            Icon(Icons.calendar_month, color: primaryColor),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'กรุณาเลือกวันนัดครั้งถัดไป'
                          : null,
                    )),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, secondaryColor],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      injectionAdd();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'บันทึกประวัติ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFFF3F3),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Color(0xFF795548)),
            title: const Text('ถ่ายรูปด้วยกล้อง'),
            onTap: () async {
              Navigator.pop(context);
              final picked = await ImagePicker()
                  .pickImage(source: ImageSource.camera, imageQuality: 80);
              if (picked != null) {
                setState(() => _imageFile = File(picked.path));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library, color: Color(0xFF795548)),
            title: const Text('เลือกรูปจากคลัง'),
            onTap: () async {
              Navigator.pop(context);
              final picked = await ImagePicker()
                  .pickImage(source: ImageSource.gallery, imageQuality: 80);
              if (picked != null) {
                setState(() => _imageFile = File(picked.path));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: lightColor.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
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

  Future<void> getReserve(String docId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('reserve')
          .doc(docId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        log('✅ Data for docId=$docId: $data');

        final dynamic dogDogIdRaw = data?['dogDogId'];

        if (data?['date'] != null) {
          final String dateStr = data?['date'];
          final DateTime? parsedDate = DateTime.tryParse(dateStr);

          if (parsedDate != null && dateController.text.trim().isEmpty) {
            dateController.text = formatThaiDateTime(parsedDate);
          }
        }
        final aid =
            data?['appointmentAid']?.toString(); // 👈 ใช้ aid ที่ API ต้องการ
        final email = data?['generalEmail']?.toString();

        if (aid != null &&
            email != null &&
            aid.isNotEmpty &&
            email.isNotEmpty) {
          await getvaccine(aid, email);
        } else {
          log('⚠️ Missing aid or generalEmail for vaccine fetch');
        }

        for (var data in reserveList) {
          log(data.docId.toString());
          if (data != null) {
            // vaccineController.text = data.appointme ?? '';
            dateController.text = formatThaiDateTime(data.date);
            vaccineController.addListener(() {
              vaccineChanged = true;
            });

            dateController.addListener(() {
              dateChanged = true;
            });
          } else {
            vaccineController.text = '';
          }
        }

        if (doc.exists) {
          final data = doc.data()!;
          log('✅ Data for docId=$docId: $data');

          // ล้างข้อมูลเก่าก่อน (ถ้าต้องการ)
          reserveList.clear();

          // สร้าง model จากข้อมูลและเพิ่มเข้า list
          reserveList.add(ReserveClinicFirebase.fromJson(data, doc.id));

          // จากนั้นค่อยใช้ reserveList
          if (reserveList.isNotEmpty) {
            final firstReserve = reserveList[0];

            if (firstReserve.date != null &&
                dateController.text.trim().isEmpty) {
              dateController.text = formatThaiDateTime(firstReserve.date);
            }
            // และอื่นๆ ตามต้องการ
          }

          setState(() {
            isLoading = false;
          });
        }
      } else {
        log('❌ No document found for docId=$docId');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      log('❌ Error while fetching document: $e');
      setState(() {
        isLoading = false;
      });
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
      String? aids, String? generalEmail) async {
    if (aids == null ||
        aids.trim().isEmpty ||
        generalEmail == null ||
        generalEmail.trim().isEmpty) {
      log("❌ Invalid input: aids or email is null/empty");
      return null;
    }

    log("📥 aids: $aids, email: $generalEmail");

    try {
      final urlStr = "$url/appointment/latestdate/$aids/$generalEmail";
      final res = await http.get(Uri.parse(urlStr));

      if (res.statusCode == 200) {
        // log('📦 API response body: ${res.body}');

        final appointment = appointmentClinicFromJson(res.body);

        if (appointment.data.isNotEmpty) {
          final vaccinesStr = appointment.data.first.vaccines ?? '';
          if (vaccineController.text.trim().isEmpty && vaccinesStr.isNotEmpty) {
            vaccineController.text = vaccinesStr;
          }
        }

        return appointment;
      } else {
        log("❌ Failed to load vaccine data: ${res.statusCode}");
        return null;
      }
    } catch (e) {
      log("❌ Exception while fetching vaccine info: $e");
      return null;
    }
  }

  Future<void> injectionAdd() async {
    if (reserveList.isEmpty) {
      log("⚠️ reserveList is empty");
      showTopNotification(
        context,
        'ไม่สามารถดำเนินการได้: ไม่พบข้อมูลการจอง',
        isSuccess: false,
      );
      return;
    }
    if (vaccineChanged ||
        dateChanged ||
        _imageFile == null ||
        nextDateController.text.trim().isEmpty) {
      Get.snackbar(
        'ข้อผิดพลาด',
        'กรุณากรอกข้อมูลให้ครบถ้วน',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color.fromARGB(255, 211, 89, 89),
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        snackStyle: SnackStyle.FLOATING,
        isDismissible: true,
      );
      return;
    }
    bool isConfirmed = await confirmDialog(context);
    if (!isConfirmed) {
      log("ผู้ใช้ยกเลิกการบันทึก");
      return;
    }
    final imageUrl = await confirmAvatarButton();
    log("imageUrl ก่อนส่ง: $imageUrl");

    if (imageUrl.isEmpty) {
      log("Upload failed, cancel saving.");
      showTopNotification(
        context,
        'การอัปโหลดรูปภาพล้มเหลว',
        isSuccess: false,
      );
      return;
    }
    DateTime parsedThai = DateFormat('วันที่ d MMMM yyyy', 'th_TH')
        .parse(nextDateController.text);
    DateTime NextDate =
        DateTime(parsedThai.year - 543, parsedThai.month, parsedThai.day);

    final String dogIdStr = reserveList[0].dogDogId;
    final int dogId =
        int.tryParse(dogIdStr) ?? 0; // แปลง ถ้าแปลงไม่ได้ใช้ 0 แทน

    AppointmentPost appReq = AppointmentPost(
      dogId: dogId,
      generalUserEmail: reserveList[0].generalEmail,
      vaccine: vaccineController.text,
      date: NextDate,
    );

    try {
      var res = await http.post(
        Uri.parse("$url/appointment/"),
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: jsonEncode(appReq.toJson()),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final Map<String, dynamic> appData = jsonDecode(res.body);
        int aid = appData['insertId'];

        DateTime parsedThai = DateFormat('วันที่ d MMMM yyyy', 'th_TH')
            .parse(dateController.text);
        DateTime OldDate =
            DateTime(parsedThai.year - 543, parsedThai.month, parsedThai.day);

        final String? aidStr = reserveList[0].appointmentAid;
        final int aidInt =
            int.tryParse(aidStr ?? '') ?? 0; // แปลงถ้าแปลงไม่ได้ให้ 0

        ClinicinjectionRecordPost injReq = ClinicinjectionRecordPost(
            oldAppointmentAid: aidInt,
            nextAppointmentAid: aid,
            clinicEmail: reserveList[0].clinicEmail,
            vaccine: vaccineController.text,
            date: OldDate,
            vaccineLabel: imageUrl,
            type: reserveList[0].type);

        var injRes = await http.post(
          Uri.parse("$url/clinicinjectionRecord/"),
          headers: {"Content-Type": "application/json; charset=utf-8"},
          body: jsonEncode(injReq.toJson()),
        );

        if (injRes.statusCode == 200 || injRes.statusCode == 201) {
          updatestatus(reserveList[0].docId, 3);
          showTopNotification(
            context,
            'บันทึกข้อมูลการฉีดวัคซีนเรียบร้อย ✨',
            isSuccess: true,
          );
        } else {
          showTopNotification(
            context,
            'บันทึกข้อมูลการฉีดวัคซีนล้มเหลว',
            isSuccess: false,
          );
          log("บันทึกข้อมูลการฉีดวัคซีนไม่สำเร็จ: ${injRes.statusCode} ${injRes.body}");
        }

        // ✅ แสดง loading และเปลี่ยนหน้า
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF916B44)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'กำลังเตรียมข้อมูล...',
                    style: TextStyle(
                      color: Color(0xFF916B44),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        await Future.delayed(const Duration(seconds: 1));
        Navigator.of(context).pop(); // ปิด loading
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ClinicmainPage()),
        );
      } else {
        log("บันทึกข้อมูลไม่สำเร็จ รหัสสถานะ: ${res.statusCode}");
        log("ข้อความตอบกลับ: ${res.body}");

        showTopNotification(
          context,
          'บันทึกข้อมูลไม่สำเร็จ กรุณาลองใหม่อีกครั้ง',
          isSuccess: false,
        );
      }

      // ⏳ เพิ่มการนัดรอบถัดไป (ภายหลังจากบันทึกสำเร็จ)
      // appointmentAdd();
      // updatestatus(reserveList[0].reserveId, 3);
    } catch (e) {
      log("เกิดข้อผิดพลาดในการบันทึก: $e");
      showTopNotification(
        context,
        'เกิดข้อผิดพลาดในการเชื่อมต่อ',
        isSuccess: false,
      );
    }
  }

  Future<void> updatestatus(String docId, int status) async {
    if (status == 3) {
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

  void showTopNotification(BuildContext context, String message,
      {bool isSuccess = true}) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => TopNotificationWidget(
        message: message,
        isSuccess: isSuccess,
        onDismiss: () {
          overlayEntry.remove();
        },
      ),
    );

    overlay.insert(overlayEntry);

    // ปิดแจ้งเตือนอัตโนมัติหลัง 3 วินาที
    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  Future<bool> confirmDialog(BuildContext context) async {
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
                  "ยืนยันการบันทึก",
                  style: TextStyle(
                    color: Color(0xFF916B44),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "คุณต้องการบันทึกข้อมูลการฉีดวัคซีนหรือไม่?",
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
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF916B44),
                      Color(0xFFDBA871),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF916B44).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
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

  Future<void> appointmentAdd() async {
    DateTime parsedThai = DateFormat('วันที่ d MMMM yyyy', 'th_TH')
        .parse(nextDateController.text);
    DateTime parsedDate =
        DateTime(parsedThai.year - 543, parsedThai.month, parsedThai.day);

    String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
    // log(parsedThai.toString());
    // log(formattedDate);
    final String dogIdStr = reserveList[0].dogDogId;
    final int dogId =
        int.tryParse(dogIdStr) ?? 0; // แปลง ถ้าแปลงไม่ได้ใช้ 0 แทน
    AppointmentPost req = AppointmentPost(
        dogId: dogId,
        generalUserEmail: reserveList[0].generalEmail,
        vaccine: vaccineController.text,
        date: parsedDate);

    try {
      var res = await http.post(
        Uri.parse("$url/appointment/"),
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: jsonEncode(req.toJson()),
      );

      if (res.statusCode == 201) {
        log("บันทึกข้อมูลการฉีดวัคซีนเรียบร้อย");
      } else {
        log("บันทึกข้อมูลไม่สำเร็จ รหัสสถานะ: ${res.statusCode}");
        log("ข้อความตอบกลับ: ${res.body}");
      }
    } catch (e) {
      log("เกิดข้อผิดพลาดในการบันทึก: $e");
    }
  }

  // Future<void> updatestatus(int reserveID, int status) async {
  //   if (status == 3) {
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

  Future<String> confirmAvatarButton() async {
    await Supabase.instance.client.auth.signInWithPassword(
      email: '65011212077@msu.ac.th',
      password: '1234',
    );

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      log("User not logged in. Cannot upload.");
      return '';
    }

    if (_imageFile == null) {
      log("No image to upload.");
      return '';
    }

    try {
      final fileBytes = await _imageFile!.readAsBytes();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';

      final storageResponse = await Supabase.instance.client.storage
          .from('vaccine-label')
          .uploadBinary(fileName, fileBytes,
              fileOptions: const FileOptions(upsert: true));

      if (storageResponse.isEmpty) {
        log('Upload failed.');
        return '';
      }

      final publicUrl = Supabase.instance.client.storage
          .from('vaccine-label')
          .getPublicUrl(fileName);

      log("Upload success. Public URL: $publicUrl");
      return publicUrl;
    } catch (e) {
      log("Error during upload: $e");
      return '';
    }
  }
}

class TopNotificationWidget extends StatefulWidget {
  final String message;
  final bool isSuccess;
  final VoidCallback onDismiss;

  const TopNotificationWidget({
    Key? key,
    required this.message,
    required this.isSuccess,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<TopNotificationWidget> createState() => _TopNotificationWidgetState();
}

class _TopNotificationWidgetState extends State<TopNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: widget.isSuccess
                      ? [
                          const Color(0xFF916B44), // primaryColor
                          const Color(0xFFDBA871), // secondaryColor
                        ]
                      : [
                          Colors.red[400]!,
                          Colors.red[600]!,
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (widget.isSuccess
                            ? const Color(0xFF916B44)
                            : Colors.red[400]!)
                        .withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.isSuccess ? Icons.check_circle : Icons.error,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _dismiss,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
