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
    super.initState();
    Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
      searchclinic();
      _requestLocationPermission();
      setState(() {
        _loadingData = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(),
      body: _loadingData
          ? SizedBox(
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(),
                child: Column(
                  children: clinicList.map((clinic) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
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
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
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
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.grey,
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
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.grey,
                                            ),
                                            child: const Icon(
                                              Icons.pets,
                                              size: 50,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                // Veterinarian Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.medical_services,
                                          color: Color(0xFF916B44), size: 25),
                                      const SizedBox(width: 8),
                                      Text(
                                        clinic.userEmail,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF916B44),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

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
                                  icon: Icons.person,
                                  label: 'ชื่อ',
                                  value: clinic.name ?? '',
                                  screenHeight: screenHeight,
                                ),
                                const SizedBox(height: 20),
                                _buildInfoField(
                                  icon: Icons.phone_android,
                                  label: 'เบอร์โทร',
                                  value: clinic.phone,
                                  screenHeight: screenHeight,
                                ),
                                const SizedBox(height: 20),
                                _buildInfoField(
                                  icon: Icons.timelapse_outlined,
                                  label: 'จำนวนเลขที่รับต่อช่วงเวลา',
                                  value: clinic.numPerTime?.toString() ?? '0',
                                  screenHeight: screenHeight,
                                ),
                                const SizedBox(height: 20),
                                _buildInfoField(
                                  icon: Icons.home,
                                  label: 'ที่อยู่',
                                  value: clinic.address,
                                  screenHeight: screenHeight,
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),
                          Column(
                            children: [
                              Container(
                                height: 300,
                                child: GoogleMap(
                                  onMapCreated: (controller) {
                                    mapController = controller;
                                  },
                                  myLocationEnabled: true,
                                  myLocationButtonEnabled: true,
                                  initialCameraPosition: CameraPosition(
                                    target: selectedLatLng ?? LatLng(0, 0),
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
                            ],
                          ),
                          const SizedBox(height: 30),

                          // Edit Button with Pet Theme
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Get.to(() => EitprofilePage());
                              },
                              icon: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 22,
                              ),
                              label: Text(
                                "แก้ไขข้อมูล",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF916B44),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 8,
                                shadowColor: Color(0xFF916B44).withOpacity(0.4),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
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
    showLoadingDialog();
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
    if (Get.isDialogOpen ?? false) {
      Get.back();
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
