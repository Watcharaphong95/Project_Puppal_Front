import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/controller/registerClinicCtl.dart';
import 'package:puppal_application/model/clinicEditProfilePost.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicDoctorEditProfile.dart';
import 'package:puppal_application/pages/clinic/mainClinic/profileclinic/clinicEditProfile.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;

class Clinicprofile extends StatefulWidget {
  const Clinicprofile({super.key});

  @override
  State<Clinicprofile> createState() => _ClinicprofileState();
}

class _ClinicprofileState extends State<Clinicprofile> {
  late double screenWidth;
  late double screenHeight;
  String url = "";
  final box = GetStorage();
  List<ClinicEditProfilePost> clinicList = [];
  bool _loadingData = true;

  LatLng? selectedLatLng;
  GoogleMapController? mapController;
  // LatLng? selectedLatLng;
  // GoogleMapController? mapController;
  // final controller = Get.find<registerClinicCtl>();

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    final config = await Configuration.getConfig();
    url = config['apiEndPoint'];

    await searchclinic(); // <- เรียกหลังจาก url ได้ค่าแล้ว
    await _requestLocationPermission();

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
        title: const Text(
          "ข้อมูลคลินิก",
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
                decoration: BoxDecoration(
                  color: Color(0xFFFAF8F5),
                ),
                child: Column(
                  children: clinicList.map((clinic) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      child: Column(
                        children: [
                          const SizedBox(height: 30),

                          // Elegant Profile Section
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF916B44).withOpacity(0.08),
                                  offset: Offset(0, 4),
                                  blurRadius: 20,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 40),

                                // Profile Image
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Color(0xFFE9CBAF),
                                      width: 4,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: (clinic.image ?? '').isNotEmpty
                                        ? Image.network(
                                            clinic.image,
                                            height: 120,
                                            width: 120,
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
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
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
                                                shape: BoxShape.circle,
                                                color: Color(0xFFE9CBAF),
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
                                              shape: BoxShape.circle,
                                              color: Color(0xFFE9CBAF),
                                            ),
                                            child: const Icon(
                                              Icons.pets,
                                              size: 50,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Doctor Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFE9CBAF).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.medical_services,
                                        color: Color(0xFF916B44),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        clinic.userEmail,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF916B44),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 30),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Information Display Section
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF916B44).withOpacity(0.08),
                                  offset: Offset(0, 4),
                                  blurRadius: 20,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ข้อมูลคลินิก',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF916B44),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _buildCleanInfoDisplay(
                                  icon: Icons.person_outline,
                                  label: 'ชื่อ',
                                  value: clinic.name ?? '',
                                ),
                                const SizedBox(height: 20),
                                _buildCleanInfoDisplay(
                                  icon: Icons.phone_outlined,
                                  label: 'เบอร์โทร',
                                  value: clinic.phone,
                                ),
                                const SizedBox(height: 20),
                                _buildCleanNumberDisplay(
                                  icon: Icons.access_time_outlined,
                                  label: 'จำนวนเลขที่รับต่อช่วงเวลา',
                                  value: clinic.numPerTime ?? 0,
                                ),
                                const SizedBox(height: 20),
                                _buildCleanInfoDisplay(
                                  icon: Icons.home_outlined,
                                  label: 'ที่อยู่',
                                  value: clinic.address,
                                  maxLines: 3,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Map Section
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF916B44).withOpacity(0.08),
                                  offset: Offset(0, 4),
                                  blurRadius: 20,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(24, 24, 24, 16),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        color: Color(0xFF916B44),
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'ตำแหน่งคลินิก',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF916B44),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 10),
                                      Material(
                                        elevation: 5,
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          height: 300,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: GoogleMap(
                                              onMapCreated: (controller) {
                                                mapController = controller;
                                              },
                                              myLocationEnabled: true,
                                              myLocationButtonEnabled: true,
                                              initialCameraPosition:
                                                  CameraPosition(
                                                target: selectedLatLng ??
                                                    LatLng(0, 0),
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
                                                        markerId: MarkerId(
                                                            "selected"),
                                                        position:
                                                            selectedLatLng!,
                                                      )
                                                    }
                                                  : {},
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Edit Button
                          Container(
                            width: double.infinity,
                            height: 56,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: ElevatedButton(
                              onPressed: () {
                                Get.to(() => (EitprofilePage()));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF916B44),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.edit,
                                    size: 22,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "แก้ไขข้อมูล",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
    );
  }

// Clean Info Display Widget (แสดงข้อมูลเฉพาะ)
  Widget _buildCleanInfoDisplay({
    required IconData icon,
    required String label,
    required String value,
    int maxLines = 1,
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
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
          child: Row(
            children: [
              Container(
                margin: EdgeInsets.only(right: 20),
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
              Expanded(
                child: Text(
                  value.isEmpty ? 'ไม่ระบุ' : value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF916B44),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

// Clean Number Display Widget (แสดงตัวเลข)
  Widget _buildCleanNumberDisplay({
    required IconData icon,
    required String label,
    required int value,
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
          padding: EdgeInsets.all(20),
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
          child: Row(
            children: [
              // Icon Container
              Container(
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

              const SizedBox(width: 16),

              // Label and Value
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'จำนวน',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF916B44),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        value.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF916B44),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      // แนะนำให้ไปเปิดใน settings
      Get.snackbar('การเข้าถึงตำแหน่ง', 'กรุณาเปิดสิทธิ์ตำแหน่งใน Settings');
    }
  }

  ClinicEditProfilePost clinicEditProfilePostFromJson(String str) =>
      ClinicEditProfilePost.fromJson(json.decode(str)[0]);

  Future<void> searchclinic() async {
    log(box.read('email'));
    final res =
        await http.get(Uri.parse("$url/clinic/profile/${box.read('email')}"));
    if (res.statusCode == 200) {
      final data = clinicEditProfilePostFromJson(res.body);
      log(data.userEmail);

      // controller.lat.value = data.lat.toString();
      // controller.lng.value = data.lng.toString();

      // log(controller.lat.value);
      selectedLatLng = LatLng(
        double.parse(data.lat), // ถ้า lat เป็น String
        double.parse(data.lng),
      );

      setState(() {
        clinicList = [data];
        _loadingData = false;
      });
    } else {
      setState(() {
        _loadingData = false;
      });
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
}
