import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:puppal_application/config/config.dart';
import 'package:http/http.dart' as http;
import 'package:puppal_application/main.dart';
import 'package:puppal_application/model/dogsGetEmail.dart';
import 'package:puppal_application/model/generalLocationPut.dart';
import 'package:puppal_application/model/generalPost.dart';
import 'package:puppal_application/model/generalProfilePost.dart';
import 'package:puppal_application/model/userPost.dart';
import 'package:puppal_application/pages/generalAppNavigator.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalSetting.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditprofilePage extends StatefulWidget {
  const EditprofilePage({super.key});

  @override
  State<EditprofilePage> createState() => _EditprofilePageState();
}

class _EditprofilePageState extends State<EditprofilePage> {
  late double screenWidth;
  late double screenHeight;

  final box = GetStorage();

  String url = '';
  bool _loadingData = true;
  bool _dataChange = false;
  bool _hasMovedByUser = false;

  File? _imageFile;

  late GeneralPost generalData;

  TextEditingController usernameCtl = TextEditingController();
  TextEditingController nameCtl = TextEditingController();
  TextEditingController surnameCtl = TextEditingController();
  TextEditingController emailCtl = TextEditingController();
  TextEditingController phoneCtl = TextEditingController();
  TextEditingController addressCtl = TextEditingController();
  TextEditingController imageCtl = TextEditingController();
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
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'แก้ไขโปรไฟล์',
          style: TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFDBA871),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _loadingData
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFE9CBAF).withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF916B44),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'กำลังโหลดข้อมูล...',
                    style: TextStyle(
                      color: Color(0xFF916B44),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFAF8F5),
                    Color(0xFFF5F0E8),
                  ],
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.03,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Image Section
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF916B44).withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Container(
                          width: screenWidth,
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: selectImage,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Color(0xFFE9CBAF),
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Color(0xFF916B44).withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: _imageFile == null
                                      ? Stack(
                                          children: [
                                            ClipOval(
                                              child: Image.network(
                                                generalData.image,
                                                width: screenWidth * 0.35,
                                                height: screenWidth * 0.35,
                                                fit: BoxFit.cover,
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
                                                  if (loadingProgress == null)
                                                    return child;
                                                  return Shimmer.fromColors(
                                                    baseColor: Color(0xFFE9CBAF)
                                                        .withOpacity(0.3),
                                                    highlightColor:
                                                        Colors.white,
                                                    child: Container(
                                                      width: screenWidth * 0.35,
                                                      height:
                                                          screenWidth * 0.35,
                                                      decoration: BoxDecoration(
                                                        color: Color(0xFFE9CBAF)
                                                            .withOpacity(0.5),
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              right: 0,
                                              child: Container(
                                                padding: EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Color(0xFF916B44),
                                                ),
                                                child: Icon(
                                                  Icons.camera_alt,
                                                  size: 20,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : ClipOval(
                                          child: Image.file(
                                            _imageFile!,
                                            width: screenWidth * 0.35,
                                            height: screenWidth * 0.35,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                ),
                              ),
                              SizedBox(height: 12),
                              Container(
                                width: screenWidth * 0.5,
                                padding: EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal:
                                        12), // เพิ่ม padding เพื่อให้มีช่องว่างภายใน
                                decoration: BoxDecoration(
                                  color: Color(
                                      0xFFFFF4E6), // สีพื้นหลัง (อ่อนๆ เข้ากับ theme น้ำตาลทอง)
                                  border: Border.all(
                                    color: Color(0xFF916B44), // สีของขอบ
                                    width: 0,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(8), // มุมโค้ง
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.mail,
                                      color: Color(0xFF916B44),
                                      size: 16,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      emailCtl.text,
                                      style: TextStyle(
                                        color: Color(0xFF916B44),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow
                                          .ellipsis, // ตัดข้อความด้วย ...
                                      maxLines: 1, // จำกัดบรรทัดที่แสดง
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 24),

                      // Form Fields
                      _buildInputField(
                        label: 'ชื่อผู้ใช้',
                        controller: usernameCtl,
                        icon: Icons.person_rounded,
                        onChanged: (value) {
                          if (usernameCtl.text != generalData.userEmail) {
                            _dataChange = true;
                          } else {
                            _dataChange = false;
                          }
                        },
                      ),

                      SizedBox(height: 16),

                      _buildInputField(
                        label: 'ชื่อ',
                        controller: nameCtl,
                        icon: Icons.badge_rounded,
                        onChanged: (value) {
                          if (nameCtl.text != generalData.name) {
                            _dataChange = true;
                          } else {
                            _dataChange = false;
                          }
                        },
                      ),

                      SizedBox(height: 16),

                      _buildInputField(
                        label: 'นามสกุล',
                        controller: surnameCtl,
                        icon: Icons.badge_rounded,
                        onChanged: (value) {
                          if (surnameCtl.text != generalData.surname) {
                            _dataChange = true;
                          } else {
                            _dataChange = false;
                          }
                        },
                      ),

                      SizedBox(height: 16),

                      _buildInputField(
                        label: 'เบอร์โทรศัพท์',
                        controller: phoneCtl,
                        icon: Icons.phone_rounded,
                        keyboardType: TextInputType.phone,
                        onChanged: (value) {
                          if (phoneCtl.text != generalData.phone) {
                            _dataChange = true;
                          } else {
                            _dataChange = false;
                          }
                        },
                      ),

                      SizedBox(height: 16),

                      _buildInputField(
                        label: 'ที่อยู่',
                        controller: addressCtl,
                        icon: Icons.home_rounded,
                        onChanged: (value) {
                          if (addressCtl.text != generalData.address) {
                            _dataChange = true;
                          } else {
                            _dataChange = false;
                          }
                        },
                      ),

                      SizedBox(height: 24),

                      // Map Section
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF916B44).withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFE9CBAF).withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.location_on_rounded,
                                      color: Color(0xFF916B44),
                                      size: 20,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'ตำแหน่งที่อยู่',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF916B44),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Container(
                                height: screenHeight * 0.4,
                                child: selectedLatLng == null
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFE9CBAF)
                                                    .withOpacity(0.3),
                                                shape: BoxShape.circle,
                                              ),
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  Color(0xFF916B44),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 16),
                                            Text(
                                              'กำลังโหลดแผนที่...',
                                              style: TextStyle(
                                                color: Color(0xFF916B44),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Stack(
                                          children: [
                                            GoogleMap(
                                              onMapCreated: (controller) {
                                                mapController = controller;
                                              },
                                              myLocationEnabled: true,
                                              myLocationButtonEnabled: true,
                                              initialCameraPosition:
                                                  CameraPosition(
                                                target: selectedLatLng!,
                                                zoom: 15,
                                              ),
                                              onCameraMove: (position) {
                                                selectedLatLng =
                                                    position.target;
                                                if (_hasMovedByUser) {
                                                  _dataChange = true;
                                                }
                                              },
                                              onCameraIdle: () {
                                                if (!_hasMovedByUser) {
                                                  _hasMovedByUser = true;
                                                }
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
                                                    const EdgeInsets.fromLTRB(
                                                        0, 0, 0, 35),
                                                child: Icon(
                                                  Icons.location_pin,
                                                  size: 32,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 32),

                      // Confirm Button
                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _dataChange
                              ? Color(0xFF916B44)
                              : Color(0xFFE9CBAF).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _dataChange
                              ? [
                                  BoxShadow(
                                    color: Color(0xFF916B44).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _dataChange ? () => confirmButton() : null,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.save_rounded,
                                color: _dataChange
                                    ? Colors.white
                                    : Color(0xFF916B44),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'บันทึกข้อมูล',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _dataChange
                                      ? Colors.white
                                      : Color(0xFF916B44),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // Helper method for input fields
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
    TextInputType? keyboardType,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF916B44).withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Color(0xFFE9CBAF).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    icon,
                    color: Color(0xFF916B44),
                    size: 16,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF916B44),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: readOnly ? Color(0xFFFAF8F5) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Color(0xFFE9CBAF),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: controller,
                readOnly: readOnly,
                keyboardType: keyboardType,
                onChanged: onChanged,
                style: TextStyle(
                  color: Color(0xFF916B44),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Color(0xFF916B44).withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void confirmButton() {
    showAlert(
        title: 'ต้องการบันทึกข้อมูล?',
        message: 'ข้อมูลเก่าจะถูกลบถาวร',
        onConfirm: () {
          updateGeneralData();
        });
  }

  Future<void> updateGeneralData() async {
    showLoadingDialog();
    if (_imageFile != null) {
      await uploadImage();
    }

    GeneralEditProfilePost generalDataNew = GeneralEditProfilePost(
        username: usernameCtl.text,
        name: nameCtl.text,
        surname: surnameCtl.text,
        phone: phoneCtl.text,
        address: addressCtl.text,
        image: imageCtl.text,
        userEmail: generalData.userEmail);

    var res = await http.put(
      Uri.parse("$url/general"),
      headers: {"Content-Type": "application/json; charset=utf-8"},
      body: generalEditProfilePostToJson(generalDataNew),
    );
    if (res.statusCode == 200) {
      Get.back();
    } else {
      showAlertNoClose(title: 'ผิดพลาด', message: 'กรุณาลองใหม่อีกครั้ง');
    }
    log(res.statusCode.toString());

    await updateLocation();

    setState(() {
      _dataChange = false;
    });
  }

  Future<void> updateLocation() async {
    showLoadingDialog();
    GeneralLocationPut generalNewLocation = GeneralLocationPut(
        email: box.read('email'),
        lat: selectedLatLng!.latitude.toString(),
        lng: selectedLatLng!.longitude.toString());

    var res = await http.put(Uri.parse("$url/general/location"),
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: generalLocationPutToJson(generalNewLocation));
    log(res.statusCode.toString());

    if (res.statusCode == 200) {
      Get.back();
      showAlertNoClose(
          title: 'อัพเดทเสร็จสิ้น',
          message: 'อัพเดทข้อมูลส่วนตัวเรียบร้อยแล้ว',
          onConfirm: () {
            while (Get.isDialogOpen ?? false) {
              Get.back();
            }
            GeneralAppNavigation.off(5);
          });
    } else {
      showAlertNoClose(title: 'ผิดพลาด', message: 'กรุณาลองใหม่อีกครั้ง');
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

      await supabase.storage.from('general-image').remove([imagePath]);

      // Upload to Supabase Storage
      final storageResponse = await Supabase.instance.client.storage
          .from('general-image')
          .uploadBinary(fileName, fileBytes,
              fileOptions: const FileOptions(upsert: true));

      if (storageResponse.isEmpty) {
        log('Upload failed.');
        return;
      }

      // Get the public URL
      final publicUrl = Supabase.instance.client.storage
          .from('general-image')
          .getPublicUrl(fileName);

      log("Confirmed with file: ${_imageFile!.path}");
      log("Public image URL: $publicUrl");
      imageCtl.text = publicUrl;
      box.write('generalImage', publicUrl);
      // await insertToDB();
    } catch (e) {
      log("Error during upload: $e");
    }
  }

  Future<void> selectImage() async {
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
                _dataChange = true;
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
                _dataChange = true;
                setState(() => _imageFile = File(picked.path));
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> getGeneralData() async {
    var resGeneral =
        await http.get(Uri.parse("$url/general/${box.read('email')}"));
    generalData = generalPostFromJson(resGeneral.body);
    usernameCtl.text = generalData.username;
    nameCtl.text = generalData.name;
    surnameCtl.text = generalData.surname;
    emailCtl.text = generalData.userEmail;
    phoneCtl.text = generalData.phone;
    addressCtl.text = generalData.address;
    imageCtl.text = generalData.image;

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

  void showAlert({
    required String title,
    required String message,
    VoidCallback? onConfirm,
  }) {
    Get.defaultDialog(
      title: '',
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.all(16),
      content: Column(
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
