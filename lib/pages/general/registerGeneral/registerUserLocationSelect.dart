import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:puppal_application/controller/registerGeneralCtl.dart';
import 'package:puppal_application/pages/general/registerGeneral/registerUserAvatar.dart';

class UserlocationselectPage extends StatefulWidget {
  const UserlocationselectPage({super.key});

  @override
  State<UserlocationselectPage> createState() => _UserlocationselectPageState();
}

class _UserlocationselectPageState extends State<UserlocationselectPage> {
  late double screenWidth;
  late double screenHeight;

  final controller = Get.find<RegisterGeneralCtl>();

  LatLng? selectedLatLng;
  GoogleMapController? mapController;

  Future<LatLng> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return LatLng(position.latitude, position.longitude);
  }

  TextEditingController latCtl = TextEditingController();
  TextEditingController lngCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation().then((latLng) {
      setState(() {
        selectedLatLng = latLng;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
          title: Text(
            'เลือกปักหมุดที่อยู่',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Color(0xFF916B44)),
      body: SingleChildScrollView(
        child: Container(
          height: screenHeight * 0.89,
          // decoration: BoxDecoration(
          //   image: DecorationImage(
          //       image: AssetImage('assets/images/indexBg.png'),
          //       fit: BoxFit.cover,
          //       colorFilter: ColorFilter.mode(
          //           Colors.white.withOpacity(0.2), BlendMode.dstATop)),
          // ),
          color: Color(0xFFFAF8F5),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Material(
                  color: Colors.white,
                  elevation: 5,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: screenHeight * 0.55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: selectedLatLng == null
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
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(children: [
                              GoogleMap(
                                onMapCreated: (controller) {
                                  mapController = controller;
                                },
                                myLocationEnabled: true,
                                myLocationButtonEnabled: true,
                                initialCameraPosition: CameraPosition(
                                  target: selectedLatLng!,
                                  zoom: 15,
                                ),
                                onCameraMove: (position) {
                                  selectedLatLng = position.target;
                                },
                                onCameraIdle: () {
                                  setState(() {});
                                },
                              ),
                              Center(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 0, 35),
                                  child: Icon(
                                    Icons.location_pin,
                                    size: 40,
                                    color: Colors.red,
                                  ),
                                ),
                              )
                            ]),
                          ),
                  ),
                ),
                // THIS IS THE LAT LNG FOR ONLY DEBUGGING PURPOSES
                // Padding(
                //   padding: EdgeInsets.fromLTRB(0, screenHeight * 0.01, 0, 0),
                //   child: SizedBox(
                //     width: screenWidth,
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.center,
                //       children: [
                //         SizedBox(
                //           width: screenWidth * 0.5,
                //           child: Card(
                //             color: Color(0xFF916B44),
                //             child: Padding(
                //               padding: const EdgeInsets.all(20.0),
                //               child: Column(
                //                 children: [
                //                   Text(
                //                     selectedLatLng != null
                //                         ? 'Lat: ${selectedLatLng!.latitude.toStringAsFixed(4)}'
                //                         : 'กรุณาเลือกตำแหน่ง',
                //                     style: TextStyle(
                //                         fontSize: 16, color: Colors.white),
                //                   ),
                //                   Text(
                //                     selectedLatLng != null
                //                         ? 'Lng: ${selectedLatLng!.longitude.toStringAsFixed(4)}'
                //                         : 'กรุณาเลือกตำแหน่ง',
                //                     style: TextStyle(
                //                         fontSize: 16, color: Colors.white),
                //                   ),
                //                 ],
                //               ),
                //             ),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, screenHeight * 0.075, 0, 0),
                  child: SizedBox(
                    width: screenWidth,
                    child: Column(
                      children: [
                        SizedBox(
                          height: screenHeight * 0.06,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  backgroundColor: Color(0xFF916b44)),
                              onPressed: () {
                                if (selectedLatLng != null) {
                                  confirmDialog(context);
                                } else {
                                  showAlertNoClose(
                                      title: 'ผิดพลาด',
                                      message: 'กรุณาใส่ตำแหน่งที่อยู่ของคุณ');
                                }
                              },
                              child: Text(
                                'ยืนยันหมุดที่อยู่',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Function to confirm location //

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
                  child: Icon(
                    MdiIcons.home,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "ยืนยันที่อยู่",
                  style: TextStyle(
                    color: Color(0xFF916B44),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "คุณต้องการยืนยันที่อยู่นี้หรือไม่?",
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
                    onConfirmLocation();

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

  void onConfirmLocation() {
    // ตรวจสอบว่า selectedLatLng ไม่เป็น null ก่อน
    if (selectedLatLng != null) {
      controller.lat.value = selectedLatLng!.latitude.toString();
      controller.lng.value = selectedLatLng!.longitude.toString();

      log('Selected LatLng: ${selectedLatLng!.latitude.toString()}, ${selectedLatLng!.longitude.toString()}');

      // ไปที่หน้าถัดไป
      Get.to(() => UseravatarPage());
    } else {
      // ถ้า selectedLatLng เป็น null ให้แสดง Snackbar
      Get.snackbar(
        'เลือกตำแหน่ง',
        'กรุณาเลือกตำแหน่งก่อน',
        snackPosition: SnackPosition.TOP,
        backgroundColor:
            const Color.fromARGB(255, 211, 89, 89), // สีเดียวกับธีมของคุณ
        colorText: Colors.white, // สีข้อความ
        borderRadius: 10, // มุมโค้งมน
        margin: EdgeInsets.all(16), // ระยะห่างจากขอบ
        padding:
            EdgeInsets.symmetric(horizontal: 20, vertical: 12), // ระยะห่างภายใน
        duration: Duration(seconds: 2), // ระยะเวลาแสดง
      );
      log('Selected LatLng is null. Please select a valid location.');
    }
  }

  // Function to show alert dialog //

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
