import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/main.dart';
import 'package:puppal_application/model/dogUpdateDataPut.dart';
import 'package:puppal_application/model/dogsGetEmail.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalDog.dart';
import 'package:puppal_application/pages/generalAppNavigator.dart';
import 'package:puppal_application/pages/generalMainBottomNavigate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

class DogprofilePage extends StatefulWidget {
  final int dogId;

  const DogprofilePage({super.key, required this.dogId});

  @override
  State<DogprofilePage> createState() => _DogprofilePageState();
}

class _DogprofilePageState extends State<DogprofilePage> {
  late double screenWidth;
  late double screenHeight;

  final box = GetStorage();

  String url = '';

  List<DogsGetEmail> dog = [];

  var filteredBreeds = [];

  bool _loadingData = true;
  bool _dataChange = false;

  File? _imageFile;

  TextEditingController imageCtl = TextEditingController();
  TextEditingController nameCtl = TextEditingController();
  TextEditingController breedCtl = TextEditingController();
  TextEditingController genderCtl = TextEditingController();
  TextEditingController colorCtl = TextEditingController();
  TextEditingController defectCtl = TextEditingController();
  TextEditingController birthdayCtl = TextEditingController();
  TextEditingController birthdayShowCtl = TextEditingController();
  TextEditingController diseaseCtl = TextEditingController();
  TextEditingController sterilizationCtl = TextEditingController();
  TextEditingController hairCtl = TextEditingController();

  final List<String> breedOptions = [
    // กลุ่ม "ก"
    'เกรตเดน',
    'เกรทไพรีนีส',
    'เกรทเทอร์สวิสส์เมาน์เทนด๊อก',
    'เกรย์ฮาวนด์',
    'แกมเพอร์ด็อก',
    'โกลเดินริทรีฟเวอร์',

    // กลุ่ม "ข"

    // กลุ่ม "ค"
    'คลัมเบอร์สแปเนียล',
    'คอลลี',
    'คะเนเดียนเอสกิโมด็อก',
    'คาอิเคน',
    'คิชู',
    'คันกัล',
    'แคทาลันชีปด็อก',
    'แคร์นเทร์เรียร์',
    'แควาเลียร์คิงชาลส์สแปเนียล',
    'โคมอนดอร์',
    'โคเรียนชินโด',
    'เคนคอร์โซ่',
    'คุนหมิงวูลฟ์ด็อก',
    'คอเคเซียนเชเพิร์ดด็อก',
    'คอร์กี',
    'คลีไค',

    // กลุ่ม "จ"
    'แจ็กรัสเซลล์เทร์เรียร์',
    'แจพานีสชิน',
    'แจพานีสเทร์เรียร์',
    'แจพานีสสปิตซ์',

    // กลุ่ม "ช"
    'ชาผี',
    'ชิโกะกุ',
    'ชิบะอินุ',
    'ชิวาวา',
    'เชตแลนด์ชีปด็อก',
    'เชเพิร์ด',
    'เชาเชา',
    'ไชนีสเครสติดด็อก',

    // กลุ่ม "ซ"
    'ซามอยิด',
    'ซาลูกี',
    'ซือจื่อ',
    'เซนต์เบอร์นาร์ด',
    'ไซบีเรียนฮัสกี',

    // กลุ่ม "ด"
    'แด็กซันด์',
    'แดนดีดินมอนต์เทร์เรียร์',
    'แดลเมเชียน',
    'โดโกอาร์เฆนติโน',
    'โดเบอร์แมนพินเชอร์',
    'ด็อจเดบอร์โดซ์',
    'ดัตช์เชเพิร์ด',

    // กลุ่ม "ต"

    // กลุ่ม "ท"
    'ทิเบตันแมสติฟฟ์',
    'ไทยบางแก้ว',
    'ไทยหลังอาน',
    'โทสะอินุ',
    'เทร์เรียร์',

    // กลุ่ม "น"
    'นโปเลียนแมสติฟฟ์',

    // กลุ่ม "บ"
    'บรักโกอีตาเลียโน',
    'บรักแซ็ง-แฌร์แม็ง',
    'บรักโดแวร์ญ',
    'บรักดูว์บูร์บอแน',
    'บรักดูว์ปุย',
    'บรักฟร็องแซ',
    'บรัสเซิลส์กริฟฟัน',
    'บราซิเลียนเทร์เรียร์',
    'บริตทานี',
    'บรีแกกรีฟงว็องเดแอ็ง',
    'บรีอาร์ด',
    'บรูโนจูราฮาวนด์',
    'บลัดฮาวนด์',
    'บลูทิกคูนฮาวนด์',
    'บลูพอลเทร์เรียร์',
    'บลูเลซี',
    'บ็อกเซอร์',
    'บอยคินสแปเนียล',
    'บอร์ซอย',
    'บอสเนียคอร์ส-แฮด์ฮาวนด์',
    'บาคาร์วัลด็อก',
    'บาแซกรีฟงว็องเดแอ็ง',
    'บาแซเบลอเดอกัสกอญ',
    'บาแซโฟฟว์เดอเบรอตาญ',
    'บาแซอาร์เตเซียงนอร์ม็อง',
    'บาร์แบ',
    'บาแวเรียนเมาน์เทนฮาวนด์',
    'บาเซนจี',
    'บิยานูโกเดลัสเองการ์ตาซิโอเนส',
    'บิวเซรอน',
    'บีเกิล',
    'บีชันฟรีส',
    'บีลี',
    'บุลล์แมสติฟฟ์',
    'บุลล์แอนด์เทร์เรียร์',
    'บุลเลินไบส์เซอร์',
    'บูลด็อก',
    'บูร์บุล',
    'บูวีเยเดซาร์แดน',
    'บูวีเยเดฟล็องดร์',
    'เบลเจียนเชเพิร์ดด็อก',
    'เบลอเดอกัสกอญ',
    'เบอร์นีสเมาน์เทนด็อก',
    'แบร์เฌบล็องซุอิส',
    'แบร์เฌปีการ์',
    'แบร์เนอร์นีเดอร์เลาฟ์ฮุนท์',
    'แบล็กนอร์วีเจียนเอลก์ฮาวนด์',
    'แบล็กเมาท์เคอร์',
    'แบล็กแอนด์แทนคูนฮาวนด์',
    'แบล็กแอนด์แทนเวอร์จิเนียฟอกซ์ฮาวนด์',
    'แบสซิตฮาวนด์',
    'โบรฮอลเมอร์',
    'โบสรง',
    'โบโลญเญเซ',

    // กลุ่ม "ป"
    'ปั๊ก',
    'ปักกิ่ง',
    'ปาปียง',
    'เปรูเวียนแฮร์เลสสด็อก',
    'เปอร์โรเดอร์ปรีซ่าคานาริโอ',

    // กลุ่ม "พ"
    'พอเมอเรเนียน',
    'พินเชอร์',
    'พอยน์เตอร์',
    'พูเดิล',

    // กลุ่ม "ฟ"
    'ฟิล่าบราซิเลียโร',
    'ฟอกซ์ฮาวนด์',

    // กลุ่ม "ม"
    'มอลทีส',
    'มาเรมมาชีปด็อก',
    'มินะเจอร์ชเนาเซอร์',
    'มาสติฟฟ์',
    'เม็กซิกันแฮร์เลสสด็อก',
    'แมละมิวต์, อะแลสกันแมละมิวต์',

    // กลุ่ม "ย"

    // กลุ่ม "ร"
    'รอทท์ไวเลอร์',
    'ริทรีฟเวอร์',

    // กลุ่ม "ล"
    'ลาซาแอปโซ',
    'เลิฟเชิน',

    // กลุ่ม "ว"
    'วิฌลอ',
    'วิปพิต',
    'ไวมาราเนอร์',

    // กลุ่ม "ส"
    'สแปเนียล',
    'สกอตติชเดียร์ฮาวนด์',
    'สแตฟฟอร์ดเชอร์เทร์เรียร์',

    // กลุ่ม "อ"
    'อเมริกันคอกเกอร์สแปเนียล',
    'อเมริกันบูลด็อก',
    'อเมริกันพิตบุลล์เทร์เรียร์',
    'อเมริกันฟอกซ์ฮาวนด์',
    'อเมริกันวอเตอร์สแปเนียล',
    'อเมริกันเอสกิโมด็อก',
    'อ็องกลอ-ฟร็องแซเดอเปอติตเวเนอรี',
    'ออสเตรเลียนเคลพี',
    'ออสเตรเลียนแคตเทิลด็อก',
    'ออสเตรเลียนสตัมปีเทลแคตเทิลด็อก',
    'อะกิตะอินุ',
    'อักบัช',
    'อัพเพินเซ็ลเลอร์เซ็นเนินฮุนท์',
    'อาซาวัก',
    'อาร์ตัวฮาวนด์',
    'อาร์ม็อง',
    'อารีเยฌัว',
    'อาลาโนเอสปัญญอล',
    'อาอีดี',
    'อิงกลิชคอกเกอร์สแปเนียล',
    'อิงกลิชเซตเตอร์',

    // กลุ่ม "ฮ"
    'ฮกไกโด',
    'ฮาวนด์',
    'แฮร์เลสส์',
    'แฮร์เรียร์'
  ];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    log(widget.dogId.toString());
    init();
    super.initState();
  }

  void init() async {
    await Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
    });
    await getDogData();
    // filterDogs = List<DogsGetEmail>.from(dogs);
    filteredBreeds = List<String>.from(breedOptions);
    setState(() => _loadingData = false);
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
          title: Text(
            'โปรไฟล์สุนัข',
            style: TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Color(0xFFDBA871)),
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
                decoration: BoxDecoration(color: Color(0xFFFAF8F5)),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 20.0),
                    child: Column(
                      children: [
                        // Header Section
                        Container(
                          margin: EdgeInsets.only(bottom: 32),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: selectImage,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Color(0xFF916B44).withOpacity(0.3),
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: _imageFile == null
                                      ? Stack(
                                          children: [
                                            ClipOval(
                                              child: Image.network(
                                                imageCtl.text,
                                                width: screenWidth * 0.35,
                                                height: screenWidth * 0.35,
                                                fit: BoxFit.cover,
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
                                                  if (loadingProgress == null)
                                                    return child;
                                                  return Shimmer.fromColors(
                                                    baseColor:
                                                        Colors.grey[300]!,
                                                    highlightColor:
                                                        Colors.grey[100]!,
                                                    child: Container(
                                                      width: screenWidth * 0.35,
                                                      height:
                                                          screenWidth * 0.35,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
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
                              SizedBox(height: 16),
                              Text(
                                'โปรไฟล์สุนัข',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF916B44),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'แก้ไขข้อมูลส่วนตัว',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF916B44).withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          child: Column(
                            children: [
                              // Name Field
                              _buildModernTextField(
                                label: 'ชื่อ',
                                controller: nameCtl,
                                icon: Icons.pets_outlined,
                                screenHeight: screenHeight,
                                onChanged: (value) {
                                  _dataChange =
                                      value.trim() != dog[0].name.trim();
                                },
                              ),

                              SizedBox(height: 24),

                              // Breed Field
                              _buildBreedField(
                                label: 'พันธุ์',
                                controller: breedCtl,
                                icon: Icons.category_outlined,
                                hintText: 'กรอกหรือเลือกพันธุ์',
                                onTap: _showSelectBreed,
                                screenHeight: screenHeight,
                              ),

                              SizedBox(height: 24),

                              // Gender Field
                              _buildSelectField(
                                label: 'เพศ',
                                controller: genderCtl,
                                icon: Icons.wc_outlined,
                                hintText: 'เลือกเพศ',
                                onTap: _showSelectGender,
                                screenHeight: screenHeight,
                              ),

                              SizedBox(height: 24),

                              // Color Field
                              _buildModernTextField(
                                label: 'สี',
                                controller: colorCtl,
                                icon: Icons.palette_outlined,
                                screenHeight: screenHeight,
                                onChanged: (value) {
                                  _dataChange =
                                      value.trim() != dog[0].color.trim();
                                },
                              ),

                              SizedBox(height: 24),

                              // Hair Field
                              _buildModernTextField(
                                label: 'ลักษณะขน',
                                controller: hairCtl,
                                icon: Icons.brush_outlined,
                                screenHeight: screenHeight,
                                onChanged: (value) {
                                  _dataChange =
                                      value.trim() != dog[0].hair.trim();
                                },
                              ),

                              SizedBox(height: 24),

                              // Defect Field
                              _buildModernTextField(
                                label: 'ตำหนิ',
                                subtitle: '(ถ้ามี)',
                                controller: defectCtl,
                                icon: Icons.info_outline,
                                screenHeight: screenHeight,
                                isOptional: true,
                                onChanged: (value) {
                                  _dataChange =
                                      value.trim() != dog[0].defect.trim();
                                },
                              ),

                              SizedBox(height: 24),

                              // Birthday Field
                              _buildSelectField(
                                label: 'วันเกิด',
                                controller: birthdayShowCtl,
                                icon: Icons.cake_outlined,
                                hintText: 'เลือกวันเกิด',
                                onTap: () => _showDatePicker(context),
                                screenHeight: screenHeight,
                              ),

                              SizedBox(height: 24),

                              // Disease Field
                              _buildModernTextField(
                                label: 'โรคประจำตัว',
                                subtitle: '(ถ้ามี)',
                                controller: diseaseCtl,
                                icon: Icons.local_hospital_outlined,
                                screenHeight: screenHeight,
                                isOptional: true,
                                onChanged: (value) {
                                  _dataChange = value.trim() !=
                                      dog[0].congentialDisease.trim();
                                },
                              ),

                              SizedBox(height: 24),

                              // Sterilization Field
                              _buildSelectField(
                                label: 'การทำหมัน',
                                controller: sterilizationCtl,
                                icon: Icons.medical_services_outlined,
                                hintText: 'เลือกสถานะการทำหมัน',
                                onTap: _showSelectSterilization,
                                screenHeight: screenHeight,
                              ),

                              SizedBox(height: 40),
                            ],
                          ),
                        ),

                        // Action Buttons Row
                        Row(
                          children: [
                            // Delete Button
                            Expanded(
                              child: Container(
                                height: 56,
                                margin: EdgeInsets.only(right: 8),
                                child: ElevatedButton(
                                  onPressed: () {
                                    showAlert(
                                      title: 'คุณต้องการลบสุนัขของคุณ?',
                                      message:
                                          'ข้อมูลสุนัขของคุณจะหายไปอย่างถาวร',
                                      onConfirm: () {
                                        dogDelete();
                                      },
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFEF4444),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    shadowColor:
                                        Color(0xFFEF4444).withOpacity(0.3),
                                  ).copyWith(
                                    elevation: MaterialStateProperty
                                        .resolveWith<double>(
                                      (Set<MaterialState> states) {
                                        if (states.contains(
                                            MaterialState.pressed)) return 0;
                                        return 8;
                                      },
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'ลบสุนัข',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Update Button
                            Expanded(
                              child: Container(
                                height: 56,
                                margin: EdgeInsets.only(left: 8),
                                child: ElevatedButton(
                                  onPressed: _dataChange
                                      ? () {
                                          showAlert(
                                            title: 'อัพเดทข้อมูลสุนัข?',
                                            message:
                                                'ข้อมูลเก่าจะหายอย่างถาวร!',
                                            onConfirm: () {
                                              dogUpdate();
                                            },
                                          );
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _dataChange
                                        ? Color(0xFF916B44)
                                        : Color(0xFF916B44).withOpacity(0.5),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    shadowColor:
                                        Color(0xFF916B44).withOpacity(0.3),
                                  ).copyWith(
                                    elevation: MaterialStateProperty
                                        .resolveWith<double>(
                                      (Set<MaterialState> states) {
                                        if (states.contains(
                                                MaterialState.pressed) ||
                                            states.contains(
                                                MaterialState.disabled))
                                          return 0;
                                        return 8;
                                      },
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.save_outlined,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'แก้ไข',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  // Modern Text Field Widget
  Widget _buildModernTextField({
    required String label,
    String? subtitle,
    required TextEditingController controller,
    required IconData icon,
    required double screenHeight,
    bool isOptional = false,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF916B44),
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(width: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF916B44).withOpacity(0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
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
            onChanged: onChanged,
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
              hintText: isOptional ? 'กรอก$label (ถ้ามี)' : 'กรอก$label',
              hintStyle: TextStyle(
                color: Color(0xFF916B44).withOpacity(0.5),
                fontSize: 16,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

// Select Field Widget (for dropdown-like fields)
  Widget _buildSelectField({
    required String label,
    String? subtitle,
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    required VoidCallback onTap,
    required double screenHeight,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF916B44),
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(width: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF916B44).withOpacity(0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
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
                  margin: EdgeInsets.only(right: 16),
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
                    controller.text.isNotEmpty ? controller.text : hintText,
                    style: TextStyle(
                      color: controller.text.isNotEmpty
                          ? Color(0xFF916B44)
                          : Color(0xFF916B44).withOpacity(0.5),
                      fontSize: 16,
                      fontWeight: controller.text.isNotEmpty
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFFDBA871),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Breed Field Widget (allows both typing and selecting)
  Widget _buildBreedField({
    required String label,
    String? subtitle,
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    required VoidCallback onTap,
    required double screenHeight,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF916B44),
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(width: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF916B44).withOpacity(0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
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
              suffixIcon: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: EdgeInsets.all(12),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFFDBA871).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF916B44),
                    size: 20,
                  ),
                ),
              ),
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: TextStyle(
                color: Color(0xFF916B44).withOpacity(0.5),
                fontSize: 16,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
          ),
        ),
      ],
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

      await supabase.storage.from('dog-image').remove([imagePath]);

      // Upload to Supabase Storage
      final storageResponse = await Supabase.instance.client.storage
          .from('dog-image')
          .uploadBinary(fileName, fileBytes,
              fileOptions: const FileOptions(upsert: true));

      if (storageResponse.isEmpty) {
        log('Upload failed.');
        return;
      }

      // Get the public URL
      final publicUrl = Supabase.instance.client.storage
          .from('dog-image')
          .getPublicUrl(fileName);

      log("Confirmed with file: ${_imageFile!.path}");
      log("Public image URL: $publicUrl");
      imageCtl.text = publicUrl;

      // await dogUpdate();
    } catch (e) {
      log("Error during upload: $e");
    }
  }

  Future<void> dogDelete() async {
    showLoadingDialog();
    await deletePictureSupabase();
    await deleteDogFireStore(dog[0].dogId.toString());
    var res = await http.delete(Uri.parse("$url/dog/${dog[0].dogId}"));
    Get.back();
    if (res.statusCode == 200) {
      showAlertNoClose(
          title: 'สุนัขของคุณถูกลบแล้ว',
          message: '',
          onConfirm: () {
            while (Get.isDialogOpen ?? false) {
              Get.back();
            }
            Get.off(() => GeneralMainBottomNavigate(indexPage: 0));
          });
    } else {
      showAlertNoClose(title: 'ผิดพลาด', message: 'กรุณาลองใหม่อีกครั้ง');
    }
  }

  Future<void> deleteDogFireStore(String dogId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('reserve')
        .where('dogDogId', isEqualTo: dogId)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> deletePictureSupabase() async {
    await Supabase.instance.client.auth.signInWithPassword(
      email: '65011212077@msu.ac.th',
      password: '1234',
    );

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      log("User not logged in. Cannot delete.");
      return;
    }
    try {
      var imagePathAll = imageCtl.text.split('/');
      var imagePath = imagePathAll.lastWhere(
          (e) => e.contains('.jpg') || e.contains('.png'),
          orElse: () => '');

      log('imagePath: $imagePath');

      final deleteRes =
          await supabase.storage.from('dog-image').remove([imagePath]);

      if (deleteRes.isEmpty) {
        log('Delete user picture failed.');
        return;
      }
    } catch (e) {
      log("Error during upload: $e");
    }
  }

  Future<void> dogUpdate() async {
    showLoadingDialog();
    if (_imageFile != null) {
      await uploadImage();
    }
    if (sterilizationCtl.text == 'ทำแล้ว') {
      sterilizationCtl.text = '1';
    } else {
      sterilizationCtl.text = '0';
    }

    final thaiMonthMap = {
      'มกราคม': '01',
      'กุมภาพันธ์': '02',
      'มีนาคม': '03',
      'เมษายน': '04',
      'พฤษภาคม': '05',
      'มิถุนายน': '06',
      'กรกฎาคม': '07',
      'สิงหาคม': '08',
      'กันยายน': '09',
      'ตุลาคม': '10',
      'พฤศจิกายน': '11',
      'ธันวาคม': '12',
    };

    String parseDateToIso(String input) {
      if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(input.trim())) {
        // ถ้าเป็น yyyy-MM-dd อยู่แล้ว
        return input;
      } else {
        // คาดว่าเป็นวัน-เดือนไทย-ปี เช่น 1-มกราคม-2566
        final parts = input.split('-');
        if (parts.length != 3) return '2000-01-01'; // fallback
        final day = parts[0].padLeft(2, '0');
        final month = thaiMonthMap[parts[1].trim()] ?? '01';
        final year = parts[2];
        return '$year-$month-$day';
      }
    }

    DogsUpdateDataPut req = DogsUpdateDataPut(
        dogId: dog[0].dogId,
        userEmail: dog[0].userEmail,
        name: nameCtl.text,
        breed: breedCtl.text,
        gender: genderCtl.text,
        color: colorCtl.text,
        defect: defectCtl.text,
        birthday: parseDateToIso(birthdayCtl.text),
        congentialDisease: diseaseCtl.text,
        sterilization: int.parse(sterilizationCtl.text),
        hair: hairCtl.text,
        image: imageCtl.text);

    var res = await http.put(
      Uri.parse("$url/dog"),
      headers: {"Content-Type": "application/json; charset=utf-8"},
      body: dogsUpdateDataPutToJson(req),
    );

    Get.back();

    setState(() {
      _dataChange = false;
    });

    showAlertNoClose(
        title: 'อัพเดทเสร็จสิ้น',
        message: 'อัพเดทข้อมูลส่วนตัวเรียบร้อยแล้ว',
        onConfirm: () {
          while (Get.isDialogOpen ?? false) {
            Get.back();
          }
          Get.off(() => GeneralMainBottomNavigate(indexPage: 0));
        });
  }

  Future<void> getDogData() async {
    var res = await http.get(Uri.parse("$url/dog/data/${widget.dogId}"));
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      dog = data.map((e) => DogsGetEmail.fromJson(e)).toList();

      imageCtl.text = dog[0].image;
      nameCtl.text = dog[0].name;
      breedCtl.text = dog[0].breed;
      genderCtl.text = dog[0].gender;
      colorCtl.text = dog[0].color;
      hairCtl.text = dog[0].hair;
      defectCtl.text = dog[0].defect;
      birthdayShowCtl.text = dog[0].birthday.toString().replaceFirstMapped(
          RegExp(r'(\d{4})$'), (m) => '${int.parse(m[1]!) + 543}');
      birthdayCtl.text = dog[0].birthday.toString();
      diseaseCtl.text = dog[0].congentialDisease;
      sterilizationCtl.text =
          (dog[0].sterilization.toString() == '1') ? 'ทำแล้ว' : 'ยังไม่ทำ';
      // log(dog[0].name);
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

  void _showSelectBreed() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

        return Container(
          decoration: BoxDecoration(
            color: Color(0xFFFAF8F5), // Light Beige background
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Container(
              height: screenHeight * 0.5,
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle indicator
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Color(0xFFE9CBAF), // Cream/Light Brown
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Title with pet icon
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.pets,
                          color: Color(0xFF916B44), // Primary Brown
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'เลือกพันธุ์',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF916B44), // Primary Brown
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Search field with themed styling
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Color(0xFFE9CBAF), // Cream/Light Brown border
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'ค้นหาพันธุ์สุนัข',
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Color(0xFF916B44), // Primary Brown
                          size: 22,
                        ),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Color(0xFF916B44), // Primary Brown
                                  size: 20,
                                ),
                                onPressed: () {
                                  searchController.clear();
                                  FocusScope.of(context).unfocus();
                                  setState(() {
                                    filteredBreeds =
                                        List<String>.from(breedOptions);
                                  });
                                },
                              )
                            : null,
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF916B44), // Primary Brown
                      ),
                      onChanged: (value) {
                        setState(() {
                          log(value);
                          if (value.isEmpty) {
                            filteredBreeds = List<String>.from(breedOptions);
                          } else {
                            filteredBreeds = breedOptions
                                .where((breed) => breed
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                .toList();
                          }
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 20),

                  // Breed list
                  Expanded(
                    child: filteredBreeds.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.pets,
                                  color: Colors.grey[400],
                                  size: 48,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'ไม่พบพันธุ์สุนัข',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredBreeds.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color:
                                        Color(0xFFE9CBAF), // Cream/Light Brown
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                  leading: Icon(
                                    Icons.pets,
                                    color: Color(0xFFDBA871), // Golden Brown
                                    size: 20,
                                  ),
                                  title: Text(
                                    filteredBreeds[index],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF916B44), // Primary Brown
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    color: Color(0xFFDBA871), // Golden Brown
                                    size: 16,
                                  ),
                                  onTap: () {
                                    setState(() {
                                      breedCtl.text = filteredBreeds[index];
                                      _dataChange = true;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                              );
                            },
                          ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDatePicker(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());

    DateTime selectedDate = DateTime.now();
    DateTime focusedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Color(0xFFFAF8F5), // Light Beige background
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFFDBA871), // Golden Brown header
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'เลือกวันเกิด',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              content: Container(
                width: double.maxFinite,
                height: screenHeight * 0.525,
                child: TableCalendar<DateTime>(
                  firstDay: DateTime(2000, 1, 1),
                  lastDay: DateTime.now(),
                  focusedDay: focusedDate,
                  selectedDayPredicate: (day) {
                    return isSameDay(selectedDate, day);
                  },
                  calendarFormat: CalendarFormat.month,
                  startingDayOfWeek: StartingDayOfWeek.sunday,
                  locale: 'th',

                  // Calendar styling
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    weekendTextStyle: TextStyle(
                      color: Color(0xFF916B44),
                      fontWeight: FontWeight.w600,
                    ),
                    defaultTextStyle: TextStyle(
                      color: Color(0xFF916B44),
                      fontWeight: FontWeight.w600,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Color(0xFFDBA871),
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Color(0xFF916B44).withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: Color(0xFFDBA871),
                      shape: BoxShape.circle,
                    ),
                  ),

                  // Custom header with year/month selectors
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    leftChevronVisible: false, // Hide default chevrons
                    rightChevronVisible: false,
                    titleTextStyle: TextStyle(
                      color: Color(0xFF916B44),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Custom header builder with dropdowns
                  calendarBuilders: CalendarBuilders(
                    headerTitleBuilder: (context, day) {
                      return Container(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Previous month button
                            IconButton(
                              onPressed: () {
                                DateTime newDate = DateTime(
                                    focusedDate.year, focusedDate.month - 1, 1);
                                // Ensure new date doesn't exceed bounds
                                if (newDate.isAfter(DateTime(2000, 1, 1))) {
                                  setState(() {
                                    focusedDate = newDate;
                                  });
                                }
                              },
                              icon: Icon(
                                Icons.chevron_left,
                                color: Color(0xFF916B44),
                                size: 20,
                              ),
                            ),

                            // Month and Year dropdowns
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Month dropdown
                                  Flexible(
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 4),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Color(0xFF916B44)
                                                .withOpacity(0.3)),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<int>(
                                          value: focusedDate.month,
                                          style: TextStyle(
                                            color: Color(0xFF916B44),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          dropdownColor: Colors.white,
                                          isExpanded: true,
                                          items: List.generate(12, (index) {
                                            int month = index + 1;
                                            return DropdownMenuItem<int>(
                                              value: month,
                                              child: Text(
                                                DateFormat.MMMM('th').format(
                                                    DateTime(2024, month)),
                                                style: TextStyle(
                                                    color: Color(0xFF916B44),
                                                    fontSize: 12),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          }),
                                          onChanged: (int? newMonth) {
                                            if (newMonth != null) {
                                              DateTime newDate = DateTime(
                                                  focusedDate.year,
                                                  newMonth,
                                                  1);
                                              // Ensure the new date doesn't exceed lastDay
                                              DateTime now = DateTime.now();
                                              if (newDate.isAfter(now)) {
                                                newDate = DateTime(
                                                    now.year, now.month, 1);
                                              }
                                              setState(() {
                                                focusedDate = newDate;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: 4),

                                  // Year dropdown
                                  Flexible(
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 4),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Color(0xFF916B44)
                                                .withOpacity(0.3)),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<int>(
                                          value: focusedDate.year,
                                          style: TextStyle(
                                            color: Color(0xFF916B44),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          dropdownColor: Colors.white,
                                          isExpanded: true,
                                          items: List.generate(
                                            DateTime.now().year - 2000 + 1,
                                            (index) {
                                              int year = 2000 + index;
                                              int buddhistYear = year + 543;
                                              return DropdownMenuItem<int>(
                                                value: year,
                                                child: Text(
                                                  'พ.ศ. $buddhistYear',
                                                  style: TextStyle(
                                                      color: Color(0xFF916B44),
                                                      fontSize: 12),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              );
                                            },
                                          )
                                              .reversed
                                              .toList(), // Show recent years first
                                          onChanged: (int? newYear) {
                                            if (newYear != null) {
                                              DateTime newDate = DateTime(
                                                  newYear,
                                                  focusedDate.month,
                                                  1);
                                              // Ensure the new date doesn't exceed lastDay
                                              DateTime now = DateTime.now();
                                              if (newDate.isAfter(now)) {
                                                newDate = DateTime(
                                                    now.year, now.month, 1);
                                              }
                                              setState(() {
                                                focusedDate = newDate;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Next month button
                            IconButton(
                              onPressed: () {
                                DateTime newDate = DateTime(
                                    focusedDate.year, focusedDate.month + 1, 1);
                                // Ensure new date doesn't exceed bounds
                                DateTime now = DateTime.now();
                                if (newDate.isBefore(now) ||
                                    isSameDay(newDate, now)) {
                                  setState(() {
                                    focusedDate = newDate;
                                  });
                                }
                              },
                              icon: Icon(
                                Icons.chevron_right,
                                color: Color(0xFF916B44),
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Day of week styling
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      color: Color(0xFF916B44),
                      fontWeight: FontWeight.w600,
                    ),
                    weekendStyle: TextStyle(
                      color: Color(0xFF916B44),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      selectedDate = selectedDay;
                      focusedDate = focusedDay;
                    });
                  },

                  onPageChanged: (focusedDay) {
                    setState(() {
                      focusedDate = focusedDay;
                    });
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'ยกเลิก',
                    style: TextStyle(
                      color: Color(0xFF916B44),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Format date for display with Buddhist Era but keep actual date in CE
                    String formattedDate =
                        "${selectedDate.day}-${DateFormat.MMMM('th').format(selectedDate)}-${selectedDate.year + 543}";

                    String formattedDate_data =
                        "${selectedDate.day}-${DateFormat.MMMM('th').format(selectedDate)}-${selectedDate.year}";

                    setState(() {
                      birthdayCtl.text = formattedDate_data;
                      birthdayShowCtl.text = formattedDate;
                      _dataChange = true;
                    });

                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFDBA871),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'ตกลง',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

// Helper function to compare dates
  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return false;
    }
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _showSelectGender() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final List<Map<String, dynamic>> genderOptions = [
          {
            'label': 'ชาย',
            'icon': Icons.male,
          },
          {
            'label': 'หญิง',
            'icon': Icons.female,
          },
        ];

        return Container(
          decoration: BoxDecoration(
            color: Color(0xFFFAF8F5), // Light Beige background
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Container(
            height: 300,
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle indicator
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Color(0xFFE9CBAF), // Cream/Light Brown
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Title with pet icon
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.pets,
                        color: Color(0xFF916B44), // Primary Brown
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'เลือกเพศ',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF916B44), // Primary Brown
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // Gender options
                Expanded(
                  child: Column(
                    children: genderOptions.map((genderOption) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Color(0xFFE9CBAF), // Cream/Light Brown
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          leading: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color(0xFFDBA871).withOpacity(
                                  0.1), // Golden Brown with opacity
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              genderOption['icon'],
                              color: Color(0xFFDBA871), // Golden Brown
                              size: 24,
                            ),
                          ),
                          title: Text(
                            genderOption['label'],
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF916B44), // Primary Brown
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: Color(0xFFDBA871), // Golden Brown
                            size: 16,
                          ),
                          onTap: () {
                            setState(() {
                              genderCtl.text = genderOption['label'];
                              _dataChange = true;
                            });
                            Navigator.pop(context);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSelectSterilization() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final List<Map<String, dynamic>> sterilizationOptions = [
          {
            'label': 'ทำแล้ว',
            'icon': Icons.check_circle,
            'color': Colors.green,
          },
          {
            'label': 'ยังไม่ทำ',
            'icon': Icons.cancel,
            'color': Colors.orange,
          },
        ];

        return Container(
          decoration: BoxDecoration(
            color: Color(0xFFFAF8F5), // Light Beige background
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Container(
            height: 300,
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle indicator
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Color(0xFFE9CBAF), // Cream/Light Brown
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Title with medical icon
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.medical_services,
                        color: Color(0xFF916B44), // Primary Brown
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'สุนัขทำหมันมาแล้ว?',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF916B44), // Primary Brown
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // Sterilization options
                Expanded(
                  child: Column(
                    children: sterilizationOptions.map((option) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Color(0xFFE9CBAF), // Cream/Light Brown
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          leading: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: option['color'].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              option['icon'],
                              color: option['color'],
                              size: 24,
                            ),
                          ),
                          title: Text(
                            option['label'],
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF916B44), // Primary Brown
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: Color(0xFFDBA871), // Golden Brown
                            size: 16,
                          ),
                          onTap: () {
                            setState(() {
                              sterilizationCtl.text = option['label'];
                            });
                            Navigator.pop(context);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
}
