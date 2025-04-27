import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:puppal_application/controller/registerGeneralCtl.dart';
import 'package:puppal_application/pages/registerUserAvatar.dart';

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
          title: Text('เลือกปักหมุดที่อยู่'),
          backgroundColor: Color(0xFF916B44)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Material(
                elevation: 5,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: screenHeight * 0.55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: selectedLatLng == null
                      ? Center(child: CircularProgressIndicator())
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: GoogleMap(
                            onMapCreated: (controller) {
                              mapController = controller;
                            },
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            initialCameraPosition: CameraPosition(
                              target: selectedLatLng!,
                              zoom: 15,
                            ),
                            onTap: (latLng) {
                              setState(() {
                                selectedLatLng = latLng;
                              });
                            },
                            markers: selectedLatLng != null
                                ? {
                                    Marker(
                                      markerId: MarkerId("selected"),
                                      position: selectedLatLng!,
                                    )
                                  }
                                : {},
                          ),
                        ),
                ),
              ),
              // THIS IS THE LAT LNG FOR ONLY DEBUGGING PURPOSES
              Padding(
                padding: EdgeInsets.fromLTRB(0, screenHeight * 0.01, 0, 0),
                child: SizedBox(
                  width: screenWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: screenWidth * 0.5,
                        child: Card(
                          color: Color(0xFF916B44),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Text(
                                  selectedLatLng != null
                                      ? 'Lat: ${selectedLatLng!.latitude.toStringAsFixed(4)}'
                                      : 'กรุณาเลือกตำแหน่ง',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                                Text(
                                  selectedLatLng != null
                                      ? 'Lng: ${selectedLatLng!.longitude.toStringAsFixed(4)}'
                                      : 'กรุณาเลือกตำแหน่ง',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                              showAlert(
                                  context: context,
                                  title: 'ยืนยันการเลือกตำแหน่ง',
                                  message: 'คุณต้องการยืนยันตำแหน่งนี้หรือไม่?',
                                  onConfirm: onConfirmLocation);
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
    );
  }

  // Function to confirm location //

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

  void showAlert({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFFFFF3F3), // light pink-ish background
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF795548), // brown color
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            color: Colors.black87,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Color(0xFF795548),
            ),
            child: Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (onConfirm != null) onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF795548), // brown
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('ตกลง'),
          ),
        ],
      ),
    );
  }
}
