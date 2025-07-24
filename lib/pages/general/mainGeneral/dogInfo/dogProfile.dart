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
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
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
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    spacing: 16,
                    children: [
                      GestureDetector(
                        onTap: selectImage,
                        child: _imageFile == null
                            ? ClipOval(
                                child: Image.network(
                                  imageCtl.text,
                                  width: screenWidth * 0.35,
                                  height: screenWidth * 0.35,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(
                                        width: screenWidth * 0.35,
                                        height: screenWidth * 0.35,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                ),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ชื่อ',
                            style: TextStyle(fontSize: 20),
                          ),
                          Material(
                            elevation: 5,
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              height: screenHeight * 0.055,
                              child: TextField(
                                onChanged: (value) {
                                  _dataChange =
                                      value.trim() != dog[0].name.trim();
                                },
                                controller: nameCtl,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'พันธุ์',
                            style: TextStyle(fontSize: 20),
                          ),
                          Material(
                            elevation: 5,
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              height: screenHeight * 0.055,
                              child: TextField(
                                onTap: _showSelectBreed,
                                // onChanged: (value) {
                                //   if (breedCtl.text != dog[0].breed) {
                                //     _dataChange = true;
                                //   } else {
                                //     _dataChange = false;
                                //   }
                                // },
                                readOnly: true,
                                controller: breedCtl,
                                decoration: InputDecoration(
                                  hintText: 'เลือกพันธุ์',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  suffixIcon: const Icon(FontAwesomeIcons.paw),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'เพศ',
                            style: TextStyle(fontSize: 20),
                          ),
                          Material(
                            elevation: 5,
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              height: screenHeight * 0.055,
                              child: TextField(
                                onTap: _showSelectGender,
                                readOnly: true,
                                controller: genderCtl,
                                decoration: InputDecoration(
                                  hintText: 'เลือกเพศ',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  suffixIcon: const Icon(FontAwesomeIcons.mars),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'สี',
                            style: TextStyle(fontSize: 20),
                          ),
                          Material(
                            elevation: 5,
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              height: screenHeight * 0.055,
                              child: TextField(
                                onChanged: (value) {
                                  _dataChange =
                                      value.trim() != dog[0].color.trim();
                                },
                                controller: colorCtl,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ลักษณะขน',
                            style: TextStyle(fontSize: 20),
                          ),
                          Material(
                            elevation: 5,
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              height: screenHeight * 0.055,
                              child: TextField(
                                onChanged: (value) {
                                  _dataChange =
                                      value.trim() != dog[0].hair.trim();
                                },
                                controller: hairCtl,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'ตำหนิ',
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                '(ถ้ามี)',
                                style:
                                    TextStyle(fontSize: 20, color: Colors.grey),
                              ),
                            ],
                          ),
                          Material(
                            elevation: 5,
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              height: screenHeight * 0.055,
                              child: TextField(
                                onChanged: (value) {
                                  _dataChange =
                                      value.trim() != dog[0].defect.trim();
                                },
                                controller: defectCtl,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'วันเกิด',
                            style: TextStyle(fontSize: 20),
                          ),
                          Material(
                            elevation: 5,
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              height: screenHeight * 0.055,
                              child: TextField(
                                controller: birthdayCtl,
                                readOnly: true,
                                onTap: () {
                                  _showDatePicker(context);
                                },
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: 'เลือกวันเกิด',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  suffixIcon: const Icon(Icons.calendar_today),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'โรคประจำตัว',
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                '(ถ้ามี)',
                                style:
                                    TextStyle(fontSize: 20, color: Colors.grey),
                              ),
                            ],
                          ),
                          Material(
                            elevation: 5,
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              height: screenHeight * 0.055,
                              child: TextField(
                                onChanged: (value) {
                                  _dataChange =
                                      value.trim() != dog[0].defect.trim();
                                },
                                controller: diseaseCtl,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'การทำหมัน',
                            style: TextStyle(fontSize: 20),
                          ),
                          Material(
                            elevation: 5,
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              height: screenHeight * 0.055,
                              child: TextField(
                                onTap: _showSelectSterilization,
                                readOnly: true,
                                controller: sterilizationCtl,
                                decoration: InputDecoration(
                                  hintText: 'เลือกสถานะการทำหมัน',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  suffixIcon: const Icon(FontAwesomeIcons.dna),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding:
                            EdgeInsets.fromLTRB(0, 0, 0, screenHeight * 0.05),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(
                              width: screenWidth * 0.4,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      backgroundColor: Color(0xFFEF4444)),
                                  onPressed: () {
                                    showAlert(
                                        title: 'คุณต้องการลบสุนัขของคุณ?',
                                        message:
                                            'ข้อมูลสุนัขของคุณจะหายไปอย่างถาวร',
                                        onConfirm: () {
                                          dogDelete();
                                        });
                                  },
                                  child: Text(
                                    'ลบสุนัข',
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  )),
                            ),
                            SizedBox(
                              width: screenWidth * 0.4,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      backgroundColor: Color(0xFF916b44)),
                                  onPressed: _dataChange
                                      ? () {
                                          showAlert(
                                              title: 'อัพเดทข้อมูลสุนัข?',
                                              message:
                                                  'ข้อมูลเก่าจะหายอย่างถาวร!',
                                              onConfirm: () {
                                                dogUpdate();
                                              });
                                        }
                                      : null,
                                  child: Text(
                                    'แก้ไข',
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  )),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ));
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
            Get.offAll(() => GeneraldogPage());
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

    String thaiToIsoDate(String thaiDate) {
      final parts = thaiDate.split('-');
      final day = parts[0].padLeft(2, '0');
      final month = thaiMonthMap[parts[1]] ?? '01';
      final year = parts[2];
      return '$year-$month-$day';
    }

    DogsUpdateDataPut req = DogsUpdateDataPut(
        dogId: dog[0].dogId,
        userEmail: dog[0].userEmail,
        name: nameCtl.text,
        breed: breedCtl.text,
        gender: genderCtl.text,
        color: colorCtl.text,
        defect: defectCtl.text,
        birthday: thaiToIsoDate(birthdayCtl.text),
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
          Get.to(() => GeneraldogPage());
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
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

        return Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: Container(
            height: screenHeight * 0.5,
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Center(
                  child: Text(
                    'เลือกพันธุ์',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF916b44),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'ค้นหาพันธุ์สุนัข',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear),
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
                SizedBox(height: 16),
                Expanded(
                  child: filteredBreeds.isEmpty
                      ? Center(
                          child: Text(
                            'ไม่พบพันธุ์สุนัข',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredBreeds.length,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                title: Center(
                                  child: Text(
                                    filteredBreeds[index],
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF916b44),
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    breedCtl.text = filteredBreeds[index];
                                    if (nameCtl.text != dog[0].name) {
                                      _dataChange = true;
                                    } else {
                                      _dataChange = false;
                                    }
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
        );
      },
    );
  }

  void _showDatePicker(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
    picker.DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: DateTime(2000, 1, 1),
      maxTime: DateTime.now(),
      locale: picker.LocaleType.th,
      theme: picker.DatePickerTheme(
          backgroundColor: Colors.white,
          headerColor: Color(0xFF916b44),
          itemStyle: TextStyle(
            color: Color(0xFF916b44),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          doneStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          cancelStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          )),
      onConfirm: (date) {
        setState(() {
          String formattedDate =
              "${date.day}-${DateFormat.MMMM('th').format(date)}-${date.year}";
          birthdayCtl.text = formattedDate;
          if (birthdayCtl.text != dog[0].birthday) {
            _dataChange = true;
          } else {
            _dataChange = false;
          }
        });
      },
    );
  }

  void _showSelectGender() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final List<String> genderOptions = ['ชาย', 'หญิง'];

        return Container(
          height: 300,
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Text(
                  'เลือกเพศ',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF916b44),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: Column(
                  children: genderOptions.map((gender) {
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Center(
                          child: Text(
                            gender,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF916b44),
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            genderCtl.text = gender;
                            if (genderCtl.text != dog[0].gender) {
                              _dataChange = true;
                            } else {
                              _dataChange = false;
                            }
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
        );
      },
    );
  }

  void _showSelectSterilization() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final List<String> sterilizationOptions = ['ทำแล้ว', 'ยังไม่ทำ'];

        return Container(
          height: 300,
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Text(
                  'สุนัขทำหมันมาแล้ว?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF916b44),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: Column(
                  children: sterilizationOptions.map((sterilization) {
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Center(
                          child: Text(
                            sterilization,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF916b44),
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            sterilizationCtl.text = sterilization;
                            _dataChange = sterilizationCtl.text !=
                                ((dog[0].sterilization.toString() == '1')
                                    ? 'ทำแล้ว'
                                    : 'ยังไม่ทำ');
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
