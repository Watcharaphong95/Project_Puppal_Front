import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/main.dart';
import 'package:puppal_application/model/clinicEditProfilePost.dart';
import 'package:http/http.dart' as http;
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
  bool isLoading = true;
  LatLng? selectedLatLng;
  GoogleMapController? mapController;
  int numPerTime = 1;
  File? _imageFile;

  TextEditingController openCtl = TextEditingController();
  TextEditingController closeCtl = TextEditingController();
  TextEditingController nameCtl = TextEditingController();
  TextEditingController phoneCtl = TextEditingController();
  TextEditingController latCtl = TextEditingController();
  TextEditingController lngCtl = TextEditingController();
  TextEditingController addressCtl = TextEditingController();
  TextEditingController imageCtl = TextEditingController();
  TextEditingController numCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
      searchclinic();
      _requestLocationPermission();
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
            children: clinicList.map((clinic) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                              child: clinic.image.isNotEmpty
                                  ? Image.network(
                                      clinic.image,
                                      height: 120,
                                      width: 120,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Shimmer.fromColors(
                                          baseColor: Color(0xFFE9CBAF),
                                          highlightColor: Colors.white,
                                          child: Container(
                                            width: 120,
                                            height: 120,
                                            decoration: const BoxDecoration(
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
                            screenHeight: screenHeight,
                            onTap: () {},
                            controller: nameCtl,
                          ),
                          const SizedBox(height: 20),
                          _buildInfoField(
                            icon: Icons.phone_android,
                            label: 'เบอร์โทร',
                            screenHeight: screenHeight,
                            onTap: () {},
                            controller: phoneCtl,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: buildTimePickerField(
                                  icon: Icons.timer,
                                  label: 'เวลาเปิดคลินิก',
                                  controller: openCtl,
                                  screenHeight: screenHeight,
                                  onTap: () => selectTime(context, openCtl),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: buildTimePickerField(
                                  icon: Icons.timer,
                                  label: 'เวลาปิดคลินิก',
                                  controller: closeCtl,
                                  screenHeight: screenHeight,
                                  onTap: () => selectTime(context, closeCtl),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildNumberSelector(
                            icon: Icons.timelapse_outlined,
                            label: 'จำนวนเลขที่รับต่อช่วงเวลา',
                            screenHeight: screenHeight,
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
                          _buildInfoField(
                            icon: Icons.home,
                            label: 'ที่อยู่',
                            screenHeight: screenHeight,
                            onTap: () {},
                            controller: addressCtl,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (addressCtl.text.isNotEmpty) {
                          moveToAddress(addressCtl.text);
                        }
                      },
                      child: Text("ค้นหาที่อยู่บนแผนที่"),
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
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          editProfileClinic();
                        },
                        icon: Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 22,
                        ),
                        label: Text(
                          "บันทึกการแก้ไขข้อมูล",
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

  Future<void> moveToAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        LatLng latLng = LatLng(locations[0].latitude, locations[0].longitude);

        if (mapController != null) {
          mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(latLng, 15),
          );

          setState(() {
            selectedLatLng = latLng;
          });

          log("📍 ย้ายแผนที่ไปที่: $latLng");
        } else {
          print("⚠️ mapController ยังไม่ถูกกำหนดค่า");
        }
      } else {
        print("❌ ไม่พบพิกัดจากที่อยู่ที่ระบุ");
      }
    } catch (e) {
      print("❌ ไม่สามารถค้นหาที่อยู่ได้: $e");
    }
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
      ClinicEditProfilePost.fromJson(json.decode(str));

  Future<void> searchclinic() async {
    final res =
        await http.get(Uri.parse("$url/clinic/data/${box.read('email')}"));
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
        openCtl.text = data.open;
        closeCtl.text = data.close;
      }

      numPerTime = data.numPerTime;

      numCtl.text = numPerTime.toString();

      selectedLatLng = LatLng(
        double.parse(data.lat),
        double.parse(data.lng),
      );

      setState(() {
        clinicList = [data];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> editProfileClinic() async {
    if (nameCtl.text.isEmpty) nameCtl.text = clinicList[0].name;
    if (phoneCtl.text.isEmpty) phoneCtl.text = clinicList[0].phone;
    if (addressCtl.text.isEmpty) addressCtl.text = clinicList[0].address;
    if (latCtl.text.isEmpty) latCtl.text = clinicList[0].lat;
    if (lngCtl.text.isEmpty) lngCtl.text = clinicList[0].lng;
    if (imageCtl.text.isEmpty) imageCtl.text = clinicList[0].image;
    if (openCtl.text.isEmpty) openCtl.text = clinicList[0].open;
    if (closeCtl.text.isEmpty) closeCtl.text = clinicList[0].close;
    if (numCtl.text.isEmpty) numCtl.text = clinicList[0].numPerTime.toString();

    ClinicEditProfilePost req = ClinicEditProfilePost(
        userEmail: box.read('email'),
        name: nameCtl.text,
        phone: phoneCtl.text,
        address: addressCtl.text,
        lat: latCtl.text,
        lng: lngCtl.text,
        image: imageCtl.text,
        open: openCtl.text,
        close: closeCtl.text,
        numPerTime: numPerTime);

    var res = await http.put(
      Uri.parse("$url/clinic/update/${box.read('email')}"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(req.toJson()),
    );
    if (res.statusCode == 200) {
      log("Update data clinic success");
    } else {
      log("Failed to update doctor info: ${res.statusCode}");
    }
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
}
