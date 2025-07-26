import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/controller/registerClinicCtl.dart';
import 'package:puppal_application/main.dart';
import 'package:puppal_application/model/clinicEditProfilePost.dart';
import 'package:http/http.dart' as http;
import 'package:puppal_application/pages/clinic/mainClinic/profileclinic/clinicProfile.dart';
import 'package:puppal_application/pages/clinic/registerClinic/registerClinicAvatar.dart';
import 'package:puppal_application/pages/general/recordDog/generalRecord.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EitprofilePage extends StatefulWidget {
  const EitprofilePage({super.key});

  @override
  State<EitprofilePage> createState() => _CliniceditprofileState();
}

class _CliniceditprofileState extends State<EitprofilePage> {
  late double screenWidth;
  late double screenHeight;
  String url = "";
  final box = GetStorage();
  List<ClinicEditProfilePost> clinicList = [];

  LatLng? selectedLatLng;
  GoogleMapController? mapController;
  int numPerTime = 1;
  File? _imageFile;
  Set<Marker> markers = {};
  TextEditingController openCtl = TextEditingController();
  TextEditingController closeCtl = TextEditingController();
  TextEditingController nameCtl = TextEditingController();
  TextEditingController phoneCtl = TextEditingController();
  TextEditingController latCtl = TextEditingController();
  TextEditingController lngCtl = TextEditingController();
  TextEditingController addressCtl = TextEditingController();
  TextEditingController imageCtl = TextEditingController();
  TextEditingController numCtl = TextEditingController();
  final controller = Get.find<registerClinicCtl>();
  bool _loadingData = true;

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
            "แก้ไขข้อมูลคลินิก",
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
                                  Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Color(0xFFE9CBAF),
                                            width: 4,
                                          ),
                                        ),
                                        child: ClipOval(
                                          child: _imageFile != null
                                              ? Image.file(
                                                  File(_imageFile!.path),
                                                  height: 120,
                                                  width: 120,
                                                  fit: BoxFit.cover,
                                                )
                                              : (clinic.image.isNotEmpty
                                                  ? Image.network(
                                                      clinic.image,
                                                      height: 120,
                                                      width: 120,
                                                      fit: BoxFit.cover,
                                                      loadingBuilder: (context,
                                                          child,
                                                          loadingProgress) {
                                                        if (loadingProgress ==
                                                            null) return child;
                                                        return Shimmer
                                                            .fromColors(
                                                          baseColor:
                                                              Color(0xFFE9CBAF),
                                                          highlightColor:
                                                              Colors.white,
                                                          child: Container(
                                                            width: 120,
                                                            height: 120,
                                                            decoration:
                                                                const BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      errorBuilder: (context,
                                                              error,
                                                              stackTrace) =>
                                                          Container(
                                                        width: 120,
                                                        height: 120,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color:
                                                              Color(0xFFE9CBAF),
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
                                                        color:
                                                            Color(0xFFE9CBAF),
                                                      ),
                                                      child: const Icon(
                                                        Icons.pets,
                                                        size: 50,
                                                        color: Colors.white,
                                                      ),
                                                    )),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: GestureDetector(
                                          onTap: () {
                                            _pickImage();
                                          },
                                          child: Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: Color(0xFF916B44),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 3,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.camera_alt,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
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

                            // Information Form
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
                                  _buildCleanInfoField(
                                    icon: Icons.person_outline,
                                    label: 'ชื่อ',
                                    controller: nameCtl,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildCleanInfoField(
                                    icon: Icons.phone_outlined,
                                    label: 'เบอร์โทร',
                                    controller: phoneCtl,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildCleanNumberSelector(
                                    icon: Icons.access_time_outlined,
                                    label: 'จำนวนเลขที่รับต่อช่วงเวลา',
                                    selectedValue: numPerTime,
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() {
                                          numPerTime = val;
                                          numCtl.text = val.toString();
                                        });
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  _buildCleanInfoField(
                                    icon: Icons.home_outlined,
                                    label: 'ที่อยู่',
                                    controller: addressCtl,
                                    maxLines: 3,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Map Section
                            Container(
                              height: screenHeight * 0.7,
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
                                    padding: const EdgeInsets.fromLTRB(
                                        24, 24, 24, 16),
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
                                  SingleChildScrollView(
                                    child: Container(
                                      height: screenHeight * 0.6,
                                      // decoration: BoxDecoration(
                                      //   image: DecorationImage(
                                      //       image: AssetImage(
                                      //           'assets/images/indexBg.png'),
                                      //       fit: BoxFit.cover,
                                      //       colorFilter: ColorFilter.mode(
                                      //           Colors.white.withOpacity(0.2),
                                      //           BlendMode.dstATop)),
                                      // ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 10),
                                            Material(
                                              elevation: 5,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Container(
                                                height: screenHeight * 0.55,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: selectedLatLng == null
                                                    ? Center(
                                                        child:
                                                            CircularProgressIndicator())
                                                    : ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        child: Stack(children: [
                                                          GoogleMap(
                                                            onMapCreated:
                                                                (controller) {
                                                              mapController =
                                                                  controller;
                                                            },
                                                            myLocationEnabled:
                                                                true,
                                                            myLocationButtonEnabled:
                                                                true,
                                                            initialCameraPosition:
                                                                CameraPosition(
                                                              target:
                                                                  selectedLatLng!,
                                                              zoom: 15,
                                                            ),
                                                            onCameraMove:
                                                                (position) {
                                                              selectedLatLng =
                                                                  position
                                                                      .target;
                                                            },
                                                            onCameraIdle: () {
                                                              setState(() {});
                                                            },
                                                            markers: markers,
                                                            gestureRecognizers: <Factory<
                                                                OneSequenceGestureRecognizer>>{
                                                              Factory<
                                                                  OneSequenceGestureRecognizer>(
                                                                () =>
                                                                    EagerGestureRecognizer(),
                                                              ),
                                                            },
                                                          ),
                                                          Center(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .fromLTRB(
                                                                      0,
                                                                      0,
                                                                      0,
                                                                      35),
                                                              child: Icon(
                                                                Icons
                                                                    .location_pin,
                                                                size: 40,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                            ),
                                                          )
                                                        ]),
                                                      ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Save Button
                            Container(
                              width: double.infinity,
                              height: 56,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              child: ElevatedButton(
                                onPressed: () {
                                  editProfileClinic(context);
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
                                      Icons.save_outlined,
                                      size: 22,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      "บันทึกการแก้ไขข้อมูล",
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
              ));
  }

  // Modern Info Field Widget (Doctor Registration Style)
  Widget _buildCleanInfoField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
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
          child: TextField(
            controller: controller,
            maxLines: maxLines,
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
              border: InputBorder.none,
              hintText: 'กรอก$label',
              hintStyle: TextStyle(
                color: Color(0xFF916B44).withOpacity(0.5),
                fontSize: 16,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: maxLines > 1 ? 18 : 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

// Modern Number Selector Widget (Doctor Registration Style)
  Widget _buildCleanNumberSelector({
    required IconData icon,
    required String label,
    required int selectedValue,
    required Function(int?) onChanged,
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

              // Label and Controls
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'จำนวน',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF916B44),
                      ),
                    ),
                    Row(
                      children: [
                        // Decrease Button
                        GestureDetector(
                          onTap: () {
                            if (selectedValue > 1) {
                              onChanged(selectedValue - 1);
                            }
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: selectedValue > 1
                                  ? Color(0xFFE9CBAF)
                                  : Color(0xFFE9CBAF).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: selectedValue > 1
                                  ? [
                                      BoxShadow(
                                        color:
                                            Color(0xFF916B44).withOpacity(0.1),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Icon(
                              Icons.remove,
                              color: selectedValue > 1
                                  ? Color(0xFF916B44)
                                  : Color(0xFF916B44).withOpacity(0.5),
                              size: 18,
                            ),
                          ),
                        ),

                        // Number Display
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 16),
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Color(0xFFFAF8F5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Color(0xFFE9CBAF),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            selectedValue.toString(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF916B44),
                            ),
                          ),
                        ),

                        // Increase Button
                        GestureDetector(
                          onTap: () {
                            onChanged(selectedValue + 1);
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Color(0xFF916B44),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF916B44).withOpacity(0.3),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
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

  // Enhanced Info Field Widget
  Widget _buildEnhancedInfoField({
    required IconData icon,
    required String label,
    required double screenHeight,
    required VoidCallback onTap,
    required TextEditingController controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFE9CBAF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(0xFFE9CBAF).withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF916B44), Color(0xFFDBA871)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF916B44).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF916B44),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF916B44),
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'กรอก$label',
                      hintStyle: TextStyle(
                        color: Color(0xFF916B44).withOpacity(0.5),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberSelector({
    required IconData icon,
    required String label,
    required double screenHeight,
    required int selectedValue,
    required Function(int?) onChanged,
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
        Container(
          height: screenHeight * 0.055,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Color(0xFFE9CBAF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Color(0xFFDBA871).withOpacity(0.5),
              width: 1,
            ),
          ),
          child: DropdownButton<int>(
            value: selectedValue,
            isExpanded: true,
            underline: SizedBox(),
            icon: Icon(Icons.arrow_drop_down, color: Color(0xFF916B44)),
            dropdownColor: Colors.white,
            onChanged: onChanged,
            items: List.generate(5, (index) {
              int val = index + 1;
              return DropdownMenuItem(
                value: val,
                child: Text(val.toString()),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required double screenHeight,
    required void Function()? onTap,
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
              child: Icon(icon, color: Color(0xFF916B44), size: 20),
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
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Color(0xFFE9CBAF).withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Color(0xFFDBA871).withOpacity(0.5),
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
      ],
    );
  }

  Widget buildTimePickerField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required double screenHeight,
    required VoidCallback onTap,
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
              child: Icon(icon, color: Color(0xFF916B44), size: 20),
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
          child: GestureDetector(
            onTap: onTap,
            child: AbsorbPointer(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFE9CBAF).withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Color(0xFFDBA871).withOpacity(0.5),
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
        ),
      ],
    );
  }

  Future<void> selectTime(
      BuildContext context, TextEditingController controller) async {
    String timeText = controller.text;
    TimeOfDay initial = TimeOfDay.now();

    if (timeText.isNotEmpty && timeText.contains('.')) {
      try {
        final parts = timeText.split('.');
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);
        initial = TimeOfDay(hour: hour, minute: minute);
      } catch (_) {}
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );

    if (picked != null) {
      final formatted =
          "${picked.hour.toString().padLeft(2, '0')}.${picked.minute.toString().padLeft(2, '0')}";
      controller.text = formatted;
    }
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar('การเข้าถึงตำแหน่ง', 'กรุณาเปิดสิทธิ์ตำแหน่งใน Settings');
    }
  }

  ClinicEditProfilePost clinicEditProfilePostFromJson(String str) =>
      ClinicEditProfilePost.fromJson(json.decode(str)[0]);

  Future<void> searchclinic() async {
    final res =
        await http.get(Uri.parse("$url/clinic/profile/${box.read('email')}"));
    if (res.statusCode == 200) {
      final data = clinicEditProfilePostFromJson(res.body);
      log(data.name);

      if (data != null) {
        nameCtl.text = data.name;
        phoneCtl.text = data.phone;
        latCtl.text = data.lat;
        lngCtl.text = data.lng;
        numCtl.text = data.numPerTime.toString();
        imageCtl.text = data.image;
        addressCtl.text = data.address;

        markers = {
          Marker(
            markerId: MarkerId('selected_location'),
            position: LatLng(double.parse(data.lat), double.parse(data.lng)),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(title: 'ตำแหน่งที่อยู่ของคุณ'),
          ),
        };
      }

      numPerTime = data.numPerTime;

      numCtl.text = numPerTime.toString();

      selectedLatLng = LatLng(
        double.parse(data.lat),
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

  Future<void> editProfileClinic(context) async {
    showLoadingDialog(message: "กำลังโหลด...");
    if (nameCtl.text.isEmpty) nameCtl.text = clinicList[0].name;
    if (phoneCtl.text.isEmpty) phoneCtl.text = clinicList[0].phone;
    if (addressCtl.text.isEmpty) addressCtl.text = clinicList[0].address;
    if (latCtl.text.isEmpty) latCtl.text = clinicList[0].lat;
    if (lngCtl.text.isEmpty) lngCtl.text = clinicList[0].lng;
    if (imageCtl.text.isEmpty) imageCtl.text = clinicList[0].image;
    if (numCtl.text.isEmpty) numCtl.text = clinicList[0].numPerTime.toString();

    if (_imageFile != null) {
      await uploadImage();
    }

    box.write('clinicImage', imageCtl.text);

    ClinicEditProfilePost req = ClinicEditProfilePost(
        userEmail: box.read('email'),
        name: nameCtl.text,
        phone: phoneCtl.text,
        address: addressCtl.text,
        lat: latCtl.text,
        lng: lngCtl.text,
        image: imageCtl.text,
        numPerTime: numPerTime);

    var res = await http.put(
      Uri.parse("$url/clinic/update/${box.read('email')}"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(req.toJson()),
    );
    // ปิด loading dialog ก่อน
    Get.back(); // ปิด dialog โหลด
    showAlertNoClose(
        title: 'อัพเดทเสร็จสิ้น',
        message: 'อัพเดทข้อมูลส่วนตัวเรียบร้อยแล้ว',
        onConfirm: () {
          Get.to(() => Clinicprofile());
        });
    if (res.statusCode == 200) {
      log("Update data clinic success");
      Get.snackbar('Success', 'แก้ไขข้อมูลเรียบร้อย');
    } else {
      log("Failed to update doctor info: ${res.statusCode}");
      Get.snackbar('Error', 'ไม่สามารถแก้ไขข้อมูลได้');
    }
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

  Future<void> uploadImage() async {
    await Supabase.instance.client.auth.signInWithPassword(
      email: '65011212077@msu.ac.th',
      password: '1234',
    );

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      log("User not logged in. Cannot upload.");
      return;
    }
    try {
      final fileBytes = await _imageFile!.readAsBytes();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';

      var imagePathAll = imageCtl.text.split('/');
      var imagePath = imagePathAll.last;

      await supabase.storage.from('clinic-image').remove([imagePath]);

      final storageResponse = await Supabase.instance.client.storage
          .from('clinic-image')
          .uploadBinary(fileName, fileBytes,
              fileOptions: const FileOptions(upsert: true));

      if (storageResponse.isEmpty) {
        log('Upload failed.');
        return;
      }

      final publicUrl = Supabase.instance.client.storage
          .from('clinic-image')
          .getPublicUrl(fileName);

      log("Confirmed with file: ${_imageFile!.path}");
      log("Public image URL: $publicUrl");
      imageCtl.text = publicUrl;

      // await insertToDB();
    } catch (e) {
      log("Error during upload: $e");
    }
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
                final pickedFile =
                    await ImagePicker().pickImage(source: ImageSource.gallery);
                setState(() => _imageFile = File(picked.path));
                _imageFile = File(pickedFile!.path);
              }
            },
          ),
        ],
      ),
    );
  }

  void onConfirmLocation() {
    if (selectedLatLng != null) {
      controller.lat.value = selectedLatLng!.latitude.toString();
      controller.lng.value = selectedLatLng!.longitude.toString();

      log('Selected LatLng: ${selectedLatLng!.latitude.toString()}, ${selectedLatLng!.longitude.toString()}');

      Get.to(() => ClinicavatarPage());
    } else {
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
    }
  }
}
