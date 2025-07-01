import 'dart:convert';
import 'dart:developer';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/model/reserveClinicPost.dart';
import 'package:http/http.dart' as http;
import 'package:puppal_application/model/reserveUpdateStatusPost.dart';
import 'package:puppal_application/model/reservebooking.dart';
import 'package:puppal_application/pages/clinic/mainClinic/reserve/acceptRequest.dart';
import 'package:shimmer/shimmer.dart';

class BookingdetailPage extends StatefulWidget {
  final int reserveID;
  const BookingdetailPage({super.key, required this.reserveID});

  @override
  State<BookingdetailPage> createState() => _BookingdetailPageState();
}

class _BookingdetailPageState extends State<BookingdetailPage> {
  String url = '';
  late double screenWidth;
  late double screenHeight;
  bool isNormalSelected = true;
  final box = GetStorage();
  List<Reservebooking> reserveList = [];
  List<ReserveClinicPost> todayList = [];
  List<ReserveClinicPost> yesterdayList = [];
  List<ReserveClinicPost> earlierList = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
      getReserve(widget.reserveID.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(),
        drawer: Drawer(),
        body: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(),
            child: Column(
              children: reserveList.map((reserve) {
                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Profile Header with Pet Theme
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // color: Colors.white,
                          boxShadow: [
                            // BoxShadow(
                            //   color: Colors.black.withOpacity(0.1),
                            //   blurRadius: 10,
                            //   spreadRadius: 2,
                            // ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Profile Image with Pet Border
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
                                  child: reserve.image.isNotEmpty
                                      ? Image.network(
                                          reserve.image,
                                          height: 150,
                                          width: 250,
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
                            const SizedBox(height: 15),
                            // Veterinarian Badge
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Information Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Color(0xFFE9CBAF),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFDBA871).withOpacity(0.2),
                              offset: const Offset(0, 6),
                              blurRadius: 16,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoField(
                              icon: Icons.pets_outlined,
                              label: 'ชื่อสุนัข',
                              value: reserve.name,
                              screenHeight: screenHeight,
                            ),
                            const SizedBox(height: 20),
                            _buildInfoField(
                              icon: Icons.badge,
                              label: 'พันธุ์',
                              value: reserve.breed,
                              screenHeight: screenHeight,
                            ),
                            const SizedBox(height: 20),
                            _buildInfoField(
                              icon: Icons.fire_extinguisher,
                              label: 'เพศ',
                              value: reserve.gender,
                              screenHeight: screenHeight,
                            ),
                            const SizedBox(height: 20),
                            _buildInfoField(
                              icon: Icons.badge,
                              label: 'สี',
                              value: reserve.color,
                              screenHeight: screenHeight,
                            ),
                            const SizedBox(height: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color:
                                            Color(0xFFE9CBAF).withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.star,
                                        color: Color(0xFF916B44),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'ตำหนิ',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF916B44),
                                            ),
                                          ),
                                          Text(
                                            '(เช่น รอยแผลเป็นต่างๆ, จุดบกพร่องของสุนัข)',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                _buildInfoFieldSingle(
                                  value: reserve.defect,
                                  screenHeight: screenHeight,
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildInfoField(
                              icon: Icons.badge,
                              label: 'วันเกิด',
                              value: formatThaiDateTime(reserve.birthday),
                              screenHeight: screenHeight,
                            ),
                            const SizedBox(height: 20),
                            _buildInfoField(
                              icon: Icons.badge,
                              label: 'โรคประจำตัว',
                              value: reserve.congentialDisease,
                              screenHeight: screenHeight,
                            ),
                            const SizedBox(height: 20),
                            _buildInfoField(
                              icon: Icons.badge,
                              label: 'ประวัติการฉีดยา',
                              value: reserve.breed,
                              screenHeight: screenHeight,
                            ),
                            const SizedBox(height: 20),
                            _buildInfoField(
                              icon: Icons.badge,
                              label: 'การทำหมัน',
                              value: reserve.sterilization.toString(),
                              screenHeight: screenHeight,
                            ),
                            const SizedBox(height: 20),
                            _buildInfoField(
                              icon: Icons.badge,
                              label: 'ลักษณะสุนัข',
                              value: reserve.hair,
                              screenHeight: screenHeight,
                            ),
                            const SizedBox(height: 20),
                            _buildInfoField(
                              icon: Icons.person,
                              label: 'ชื่อเจ้าของสุนัข',
                              value: reserve.username,
                              screenHeight: screenHeight,
                            ),
                            const SizedBox(height: 20),
                            _buildInfoField(
                              icon: Icons.phone,
                              label: 'เบอร์โทร',
                              value: reserve.phone,
                              screenHeight: screenHeight,
                            ),
                            const SizedBox(height: 20),
                            _buildInfoField(
                              icon: Icons.email,
                              label: 'อีเมล',
                              value: reserve.generalEmail,
                              screenHeight: screenHeight,
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Edit Button with Pet Theme
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  acceptrequest(
                                      reserve.reserveId, 3); // ปฏิเสธ = 3
                                },
                                icon: const Icon(Icons.cancel,
                                    color: Colors.white),
                                label: const Text(
                                  "ปฏิเสธคำขอ",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  elevation: 8,
                                  shadowColor: Colors.red.withOpacity(0.4),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  acceptrequest(
                                      reserve.reserveId, 2); // ยืนยัน = 2
                                },
                                icon: const Icon(Icons.check_circle,
                                    color: Colors.white),
                                label: const Text(
                                  "ยืนยันการจอง",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  elevation: 8,
                                  shadowColor: Colors.green.withOpacity(0.4),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ));
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

  Future<void> getReserve(String reserveID) async {
    var res = await http.get(Uri.parse("$url/reserve/search_id/$reserveID"));
    if (res.statusCode == 200) {
      reserveList = reservebookingFromJson(res.body);
      for (var data in reserveList) {
        log(data.reserveId.toString());
      }
      setState(() {
        isLoading = false;
      });
    } else {
      log("Failed to load: ${res.statusCode}");
    }
  }

  Future<void> acceptrequest(int reserveID, int status) async {
    if (status == 2) {
      _showAcceptDialog();
      ReserveUpdateStatusPost req =
          ReserveUpdateStatusPost(reserveId: reserveID, status: status);
      var res = await http.put(
        Uri.parse("$url/reserve/$reserveID"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(req.toJson()),
      );
      if (res.statusCode == 200) {
        log("Update data clinic success");
      } else {
        log("Failed to update doctor info: ${res.statusCode}");
      }
    } else if (status == 3) {
      _showRejectDialog();
      ReserveUpdateStatusPost req =
          ReserveUpdateStatusPost(reserveId: reserveID, status: status);
      var res = await http.put(
        Uri.parse("$url/reserve/$reserveID"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(req.toJson()),
      );
      if (res.statusCode == 200) {
        log("Update data clinic success");
      } else {
        log("Failed to update doctor info: ${res.statusCode}");
      }
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

  void _showRejectDialog() {
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
