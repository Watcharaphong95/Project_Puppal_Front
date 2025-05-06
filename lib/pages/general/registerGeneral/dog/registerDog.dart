import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:puppal_application/controller/registerDogCtl.dart';
import 'package:puppal_application/pages/general/registerGeneral/dog/registerDogInjectionRecord.dart';

class RegisterdogPage extends StatefulWidget {
  const RegisterdogPage({super.key});

  @override
  State<RegisterdogPage> createState() => _RegisterdogPageState();
}

class _RegisterdogPageState extends State<RegisterdogPage> {
  late double screenWidth;
  late double screenHeight;

  final dogCtl = Get.find<registerDogCtl>();

  var filteredBreeds = [];

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
    super.initState();
    filteredBreeds = List<String>.from(breedOptions);
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('ลงทะเบียนสุนัข'),
        // ADD LINE UNDER APPBAR IF WANT TO USE
        // bottom: PreferredSize(
        //   preferredSize: Size.fromHeight(1.0),
        //   child: Container(
        //     color: Colors.grey,
        //     height: 0.5,
        //   ),
        // ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            spacing: 16,
            children: [
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
                  Text(
                    'ตำหนิ',
                    style: TextStyle(fontSize: 20),
                  ),
                  Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: screenHeight * 0.055,
                      child: TextField(
                        controller: defectCtl,
                        keyboardType: TextInputType.phone,
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
                        style: TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                    ],
                  ),
                  Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: screenHeight * 0.055,
                      child: TextField(
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
                padding: EdgeInsets.fromLTRB(0, 0, 0, screenHeight * 0.05),
                child: SizedBox(
                  width: screenWidth * 0.5,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Color(0xFF916b44)),
                      onPressed: dogRegisterNextButton,
                      child: Text(
                        'ถัดไป',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      )),
                ),
              )
            ],
          ),
        ),
      ),
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
          String formattedDate = "${date.day}/${date.month}/${date.year}";
          birthdayCtl.text = formattedDate;
        });
      },
    );
  }

  Future<void> dogRegisterNextButton() async {
    if (nameCtl.text.trim().isEmpty ||
        breedCtl.text.trim().isEmpty ||
        genderCtl.text.trim().isEmpty ||
        colorCtl.text.trim().isEmpty ||
        hairCtl.text.trim().isEmpty ||
        defectCtl.text.trim().isEmpty ||
        birthdayCtl.text.trim().isEmpty ||
        sterilizationCtl.text.trim().isEmpty) {
      Get.snackbar(
        'ข้อผิดพลาด',
        'กรุณากรอกข้อมูลให้ครบถ้วน',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color.fromARGB(255, 211, 89, 89),
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        snackStyle: SnackStyle.FLOATING,
        isDismissible: true,
      );
      return;
    }

    dogCtl.name.value = nameCtl.text;
    dogCtl.breed.value = breedCtl.text;
    dogCtl.gender.value = genderCtl.text;
    dogCtl.color.value = colorCtl.text;
    dogCtl.hair.value = hairCtl.text;
    dogCtl.birthday.value = birthdayCtl.text;
    dogCtl.defect.value = defectCtl.text;
    dogCtl.disease.value = diseaseCtl.text;
    dogCtl.sterilization.value = sterilizationCtl.text;

    Get.to(() => RegisterdoginjectionrecordPage());
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

  void _showSelectGender() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final List<String> genderOptions = ['ชาย', 'หญิง']; // Inlined list

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
}
