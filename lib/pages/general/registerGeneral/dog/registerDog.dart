import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:puppal_application/controller/registerDogCtl.dart';
import 'package:puppal_application/pages/general/registerGeneral/dog/registerDogAvatar.dart';
import 'package:puppal_application/pages/general/registerGeneral/dog/registerDogInjectionRecord.dart';
import 'package:table_calendar/table_calendar.dart';

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
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text('ลงทะเบียนสุนัข',
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600)),
        backgroundColor: Color(0xFFDBA871),

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
        child: Container(
          decoration: BoxDecoration(color: Color(0xFFFAF8F5)),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                children: [
                  // Header Section
                  Container(
                    margin: EdgeInsets.only(bottom: 32),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFF916B44),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF916B44).withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.pets,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'ข้อมูลสุนัข',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF916B44),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'กรุณากรอกข้อมูลให้ครบถ้วน',
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
                        ),

                        SizedBox(height: 24),

                        // Hair Field
                        _buildModernTextField(
                          label: 'ลักษณะขน',
                          controller: hairCtl,
                          icon: Icons.brush_outlined,
                          screenHeight: screenHeight,
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

                  // Next Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    margin: EdgeInsets.only(bottom: 20),
                    child: ElevatedButton(
                      onPressed: dogRegisterNextButton,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF916B44),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        shadowColor: Color(0xFF916B44).withOpacity(0.3),
                      ).copyWith(
                        elevation: MaterialStateProperty.resolveWith<double>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed))
                              return 0;
                            return 8;
                          },
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ถัดไป',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
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
                height: screenHeight * 0.5,
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

                  // Header styling with Buddhist Era
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: Color(0xFF916B44),
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: Color(0xFF916B44),
                    ),
                    titleTextStyle: TextStyle(
                      color: Color(0xFF916B44),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    titleTextFormatter: (date, locale) {
                      // Convert to Buddhist Era for display
                      int buddhistYear = date.year + 543;
                      String monthName = DateFormat.MMMM('th').format(date);
                      return '$monthName พ.ศ. $buddhistYear';
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

                    this.setState(() {
                      birthdayCtl.text = formattedDate_data;
                      birthdayShowCtl.text = formattedDate;
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

  Future<void> dogRegisterNextButton() async {
    if (nameCtl.text.trim().isEmpty ||
        breedCtl.text.trim().isEmpty ||
        genderCtl.text.trim().isEmpty ||
        colorCtl.text.trim().isEmpty ||
        hairCtl.text.trim().isEmpty ||
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

    Get.to(() => RegisterdogavatarPage());
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
}
