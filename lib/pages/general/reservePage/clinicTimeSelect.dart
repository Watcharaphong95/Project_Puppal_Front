import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/model/clinicDataSingleRes.dart';
import 'package:puppal_application/model/clinicSlotPost.dart';
import 'package:puppal_application/model/clinicSlotsReq.dart';
import 'package:puppal_application/model/clinicSlotsRes.dart';
import 'package:puppal_application/model/reserveSpecialCheck.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalMain.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class ClinictimeselectPage extends StatefulWidget {
  final String email;
  final int dogId;
  final double distance;
  final DateTime date;
  final String vaccineName;
  final int aid;

  const ClinictimeselectPage({
    super.key,
    required this.email,
    required this.dogId,
    required this.distance,
    required this.date,
    required this.vaccineName,
    required this.aid,
  });

  @override
  State<ClinictimeselectPage> createState() => _ClinictimeselectPageState();
}

class _ClinictimeselectPageState extends State<ClinictimeselectPage> {
  late double screenWidth;
  late double screenHeight;
  final box = GetStorage();

  String url = '';

  bool _loadingData = true;

  late ClinicDataSingleResponse clinic;
  late ClinicSlotRes slot;
  late ClinicSlotRes slotFilled;

  bool special = false;

  List<String> morningSlots = [];
  List<String> afternoonSlots = [];

  @override
  void initState() {
    log(widget.dogId.toString());
    log(widget.email);
    log(widget.date.toString());
    log(widget.aid.toString());
    init();
    super.initState();
  }

  void init() async {
    await Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
    });
    await getClinicData();
    await getClinicTimeSlot();
    setState(() {
      _loadingData = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF916B44),
      ),
      body: _loadingData
          ? Center(child: CircularProgressIndicator(color: Color(0xFFDBA871)))
          : CustomScrollView(
              slivers: [
                // Hero Image Section
                SliverAppBar(
                  expandedHeight: screenHeight * 0.35,
                  pinned: true,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          clinic.image,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: Container(color: Colors.white),
                            );
                          },
                        ),
                        // Gradient overlay for better text readability
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.3),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Main Content
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Clinic Info Card
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  clinic.name,
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFDBA871),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 12),

                                // Phone and Distance Row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        Icon(Icons.phone,
                                            color: Color(0xFFDBA871), size: 20),
                                        SizedBox(height: 4),
                                        Text(
                                          clinic.phone,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: 40,
                                      width: 1,
                                      color: Colors.grey.shade300,
                                    ),
                                    Column(
                                      children: [
                                        Icon(Icons.location_on,
                                            color: Color(0xFFDBA871), size: 20),
                                        SizedBox(height: 4),
                                        Text(
                                          '${widget.distance.toStringAsFixed(3)} กม.',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                SizedBox(height: 16),

                                // View Location Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      openMap(double.parse(clinic.lat),
                                          double.parse(clinic.lng));
                                    },
                                    icon: Icon(Icons.map, size: 20),
                                    label: Text('ดูที่อยู่บนแผนที่'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFFDBA871),
                                      foregroundColor: Colors.white,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 24),

                          // Date & Time Selection Header
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Color(0xFFDBA871).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.access_time,
                                        color: Color(0xFFDBA871), size: 24),
                                    SizedBox(width: 8),
                                    Text(
                                      'เลือกเวลา',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFDBA871),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFDBA871),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    DateFormat('d MMM y', 'th')
                                        .format(widget.date),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20),

                          // Morning Slots
                          if (morningSlots.isNotEmpty) ...[
                            Row(
                              children: [
                                Icon(Icons.wb_sunny,
                                    color: Colors.orange, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'ช่วงเช้า',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: morningSlots.map((slot) {
                                final isFilled =
                                    slotFilled.timeSlots.contains(slot);
                                return buildTimeButton(slot, isFilled);
                              }).toList(),
                            ),
                          ],

                          // Afternoon Slots
                          if (afternoonSlots.isNotEmpty) ...[
                            SizedBox(height: 24),
                            Row(
                              children: [
                                Icon(Icons.wb_sunny_outlined,
                                    color: Colors.orange.shade300, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'ช่วงบ่าย',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: afternoonSlots.map((slot) {
                                final isFilled =
                                    slotFilled.timeSlots.contains(slot);
                                return buildTimeButton(slot, isFilled);
                              }).toList(),
                            ),
                          ],

                          // Special Request Section
                          if (special) ...[
                            SizedBox(height: 32),
                            Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border:
                                    Border.all(color: Colors.orange.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.info_outline,
                                          color: Colors.orange, size: 24),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'คำขอพิเศษ',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'การจองของคลินิกเต็มแล้ว',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange.shade800,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'คุณมีสุนัขที่จองฉีดยากับทางคลินิกแล้ว หากคุณต้องการเพิ่มสุนัขในการฉีดยา สามารถส่งคำขอพิเศษกับทางคลินิกได้',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                      height: 1.4,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        showAlert(
                                          title:
                                              'ต้องการส่งคำขอพิเศษใช่หรือไม่?',
                                          message:
                                              'คุณต้องการส่งคำขอพิเศษใช่หรือไม่\nหากส่งแล้วจะไม่สามารถเลือกคลินิกอื่นได้',
                                          onConfirm: () async {
                                            await sendSpecialRequestToClinic(
                                                '00:00');
                                          },
                                        );
                                      },
                                      icon:
                                          Icon(FontAwesomeIcons.plus, size: 16),
                                      label: Text('ส่งคำขอพิเศษ'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                        foregroundColor: Colors.white,
                                        padding:
                                            EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        elevation: 2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          SizedBox(height: 40), // Bottom padding
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget buildTimeButton(String slot, bool isFilled) {
    return InkWell(
      onTap: !isFilled
          ? null
          : () {
              showAlert(
                title: 'ต้องการจองเวลา $slot ?',
                message:
                    'คุณต้องการส่งคำขอเวลานี้ใช่หรือไม่\nไม่สามารถส่งซ้ำได้',
                onConfirm: () async {
                  await sendRequestToClinic(slot);
                },
              );
            },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isFilled ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isFilled ? Color(0xFFDBA871) : Colors.grey.shade300,
            width: isFilled ? 2 : 1,
          ),
          boxShadow: isFilled
              ? [
                  BoxShadow(
                    color: Color(0xFFDBA871).withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          slot,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isFilled ? Color(0xFFDBA871) : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  Future<void> sendRequestToClinic(String time) async {
    showLoadingDialog();

    DateTime date = widget.date;
    List<String> parts = time.split(":");
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    DateTime combined = DateTime(date.year, date.month, date.day, hour, minute);

    log(combined.toString());

    ClinicSlotReq req;

    if (widget.aid == 0) {
      req = ClinicSlotReq(
          generalEmail: box.read('email'),
          clinicEmail: widget.email,
          dogDogId: widget.dogId.toString(),
          status: 1,
          appointmentAid: null,
          date: combined.toString(),
          type: 0);
    } else {
      req = ClinicSlotReq(
          generalEmail: box.read('email'),
          clinicEmail: widget.email,
          dogDogId: widget.dogId.toString(),
          appointmentAid: widget.aid.toString(),
          status: 1,
          date: combined.toString(),
          type: 0);
    }

    var res = await http.post(
      Uri.parse("$url/reserve/addRequest"),
      headers: {"Content-Type": "application/json; charset=utf-8"},
      body: clinicSlotReqToJson(req),
    );
    Get.back();
    if (res.statusCode == 201) {
      showAlertNoClose(
          title: 'ส่งคำขอเรียบร้อยแล้ว',
          message: 'กรุณารอทางคลินิกตอบรับคำขอขของคุณ',
          onConfirm: () {
            Get.off(() => GeneralmainPage());
          });
    } else {
      showAlertNoClose(
          title: 'ไม่สามารถส่งคำขอได้',
          message:
              'คุณสามารถส่งคำขอได้เพียง 1 ครั้งต่อสุนัข 1 ตัว กรุณายกเลิกคำขอเก่าก่อนหากคุณต้องการส่งคำขอจองไปยังคลินิกใหม่');
    }
  }

  Future<void> openMap(double lat, double lng) async {
    final googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open the map.';
    }
  }

  Future<void> sendSpecialRequestToClinic(String time) async {
    showLoadingDialog();

    DateTime date = widget.date;

    DateTime combined = DateTime(date.year, date.month, date.day);

    log(combined.toString());

    ClinicSlotReq req = ClinicSlotReq(
        generalEmail: box.read('email'),
        clinicEmail: widget.email,
        dogDogId: widget.dogId.toString(),
        appointmentAid: widget.aid.toString(),
        date: combined.toString(),
        status: 1,
        type: 1);

    var res = await http.post(
      Uri.parse("$url/reserve/addRequest"),
      headers: {"Content-Type": "application/json; charset=utf-8"},
      body: clinicSlotReqToJson(req),
    );
    Get.back();
    if (res.statusCode == 201) {
      showAlertNoClose(
          title: 'ส่งคำขอพิเศษเรียบร้อยแล้ว',
          message: 'กรุณารอทางคลินิกตอบรับคำขอขของคุณ',
          onConfirm: () {
            Get.off(() => GeneralmainPage());
          });
    } else {
      showAlertNoClose(
          title: 'ไม่สามารถส่งคำขอได้',
          message:
              'คุณสามารถส่งคำขอได้เพียง 1 ครั้งต่อสุนัข 1 ตัว กรุณายกเลิกคำขอเก่าก่อนหากคุณต้องการส่งคำขอจองไปยังคลินิกใหม่');
    }
  }

  Future<void> getClinicData() async {
    var res = await http.get(Uri.parse("$url/clinic/data/${widget.email}"));
    if (res.statusCode == 200) {
      clinic = ClinicDataSingleResponse.fromJson(jsonDecode(res.body));

      log(clinic.name);
    }
  }

  Future<void> getReserveCheckSpecial() async {
    ReserveSpecialCheck req = ReserveSpecialCheck(
        clinicEmail: widget.email,
        generalEmail: box.read('email'),
        date: widget.date.toString());

    var res = await http.post(
      Uri.parse("$url/reserve/checkSpecial"),
      headers: {"Content-Type": "application/json; charset=utf-8"},
      body: reserveSpecialCheckToJson(req),
    );
    special = res.body.toLowerCase() == 'true';
  }

  Future<void> getClinicTimeSlot() async {
    ClinicSlotPost req =
        ClinicSlotPost(email: widget.email, date: widget.date.toString());

    var resSlotFilled = await http.post(
      Uri.parse("$url/clinic/slot"),
      headers: {"Content-Type": "application/json; charset=utf-8"},
      body: clinicSlotPostToJson(req),
    );

    slotFilled = ClinicSlotRes.fromJson(jsonDecode(resSlotFilled.body));
    // for (var e in slotFilled.timeSlots) {
    //   log(e);
    // }

    var res = await http.get(Uri.parse("$url/clinic/slotAll/${widget.email}"));
    if (res.statusCode == 200) {
      slot = ClinicSlotRes.fromJson(jsonDecode(res.body));

      morningSlots =
          slot.timeSlots.where((slot) => slot.compareTo("12:00") < 0).toList();

      afternoonSlots =
          slot.timeSlots.where((slot) => slot.compareTo("13:00") >= 0).toList();
    }

    if (slotFilled.timeSlots.isEmpty) {
      await getReserveCheckSpecial();
    } else {
      log('Slot remain');
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

  void showAlert({
    required String title,
    required String message,
    VoidCallback? onConfirm,
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
      ),
      backgroundColor: const Color(0xFFF5F0E8),
      barrierDismissible: false,
      radius: 16,
    );
  }
}
