import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/main.dart';
import 'package:puppal_application/model/dogsGetEmail.dart';
import 'package:puppal_application/model/generalLocationPut.dart';
import 'package:puppal_application/model/generalPost.dart';
import 'package:puppal_application/model/generalProfilePost.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalSetting.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditadressPage extends StatefulWidget {
  const EditadressPage({super.key});

  @override
  State<EditadressPage> createState() => _EditadressPageState();
}

class _EditadressPageState extends State<EditadressPage> {
  late double screenWidth;
  late double screenHeight;

  final box = GetStorage();

  String url = '';

  bool _loadingData = true;

  late GeneralPost generalData;

  TextEditingController latCtl = TextEditingController();
  TextEditingController lngCtl = TextEditingController();

  LatLng? selectedLatLng;
  GoogleMapController? mapController;

  Future<LatLng> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return LatLng(position.latitude, position.longitude);
  }

  Set<Marker> markers = {};

  @override
  void initState() {
    init();
    _getCurrentLocation().then((latLng) {
      setState(() {
        selectedLatLng = latLng;
      });
    });
    super.initState();
  }

  init() async {
    await Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
    });
    getGeneralData();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'เปลี่ยนที่อยู่',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Color(0xFF916B44),
        ),
        body: SingleChildScrollView(
          child: Container(
            height: screenHeight * 0.89,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/indexBg.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                      Colors.white.withOpacity(0.2), BlendMode.dstATop)),
            ),
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
                                  markers: markers,
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
                                    showAlert(
                                        title: 'ยืนยันการเลือกตำแหน่งใหม่',
                                        message:
                                            'คุณต้องการยืนยันตำแหน่งนี้หรือไม่?',
                                        onConfirm: () {
                                          updateLocation();
                                        });
                                  } else {
                                    showAlertNoClose(
                                        title: 'ผิดพลาด',
                                        message:
                                            'กรุณาใส่ตำแหน่งที่อยู่ของคุณ');
                                  }
                                },
                                child: Text(
                                  'ยืนยันหมุดที่อยู่ใหม่',
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
        ));
  }

  Future<void> getGeneralData() async {
    var resGeneral =
        await http.get(Uri.parse("$url/general/${box.read('email')}"));
    generalData = generalPostFromJson(resGeneral.body);

    markers = {
      Marker(
        markerId: MarkerId('selected_location'),
        position: LatLng(
            double.parse(generalData.lat), double.parse(generalData.lng)),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: 'ตำแหน่งที่อยู่ของคุณ'),
      ),
    };

    _loadingData = false;
    setState(() {});
  }

  Future<void> updateLocation() async {
    showLoadingDialog(message: "กำลังโหลด...");
    GeneralLocationPut generalNewLocation = GeneralLocationPut(
        email: box.read('email'),
        lat: selectedLatLng!.latitude.toString(),
        lng: selectedLatLng!.longitude.toString());

    var res = await http.put(Uri.parse("$url/general/location"),
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: generalLocationPutToJson(generalNewLocation));
    log(res.statusCode.toString());

    Get.back();

    showAlertNoClose(
        title: 'อัพเดทเสร็จสิ้น',
        message: 'อัพเดทข้อมูลส่วนตัวเรียบร้อยแล้ว',
        onConfirm: () {
          Get.off(() => GeneralprofilePage());
        });
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
