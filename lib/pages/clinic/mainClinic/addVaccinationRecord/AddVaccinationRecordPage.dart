import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_time_patterns.dart';
import 'package:intl/intl.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/main.dart';
import 'package:puppal_application/model/appointmentClinic.dart';
import 'package:puppal_application/model/appointmentPost.dart';
import 'package:puppal_application/model/clinicinjectionRecordPost.dart';
import 'package:puppal_application/model/doctorPost.dart';
import 'package:puppal_application/model/generalPost.dart';
import 'package:puppal_application/model/reserveUpdateStatusPost.dart';
import 'package:http/http.dart' as http;
import 'package:puppal_application/model/reservebooking.dart';
import 'package:puppal_application/model/reserveclinicfirebase.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicMain.dart';
import 'package:puppal_application/pages/clinicAppNavigator.dart';
import 'package:puppal_application/pages/general/recordDog/generalRecord.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

class AddVaccinationRecordPage extends StatefulWidget {
  final String docId;
  const AddVaccinationRecordPage({super.key, required this.docId});

  @override
  State<AddVaccinationRecordPage> createState() =>
      _AddVaccinationRecordPageState();
}

class _AddVaccinationRecordPageState extends State<AddVaccinationRecordPage> {
  final _formKey = GlobalKey<FormState>();
  String url = '';
  List<ReserveClinicFirebase> reserveList = [];
  List<DoctorPost> doctorList = [];
  static const Color primaryColor = Color(0xFF916B44);
  static const Color secondaryColor = Color(0xFFDBA871);
  static const Color lightColor = Color(0xFFE9CBAF);
  String? selectedVaccine;
  File? _imageFile;
  final box = GetStorage();
  Future<List<DoctorPost>>? _doctorsFuture;
  String? _currentEmail;

  // final controller = Get.find<ClinicinjectionRecordPost>();
  final TextEditingController batchController = TextEditingController();
  TextEditingController vaccineController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController nextDateController = TextEditingController();
  DoctorPost? selectedDoctor;
  TextEditingController doctorController = TextEditingController();

  DateTime? vaccinationDate;
  DateTime? nextAppointmentDate;
  bool _loadingData = true;
  bool vaccineChanged = false;
  bool dateChanged = false;

  late double screenWidth;
  late double screenHeight;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    final config = await Configuration.getConfig();
    url = config['apiEndPoint'];

    await getReserve(widget.docId);

    setState(() {
      _loadingData = false;
    });
  }

  // ฟังก์ชันแปลงวันที่เป็นไทย
  String formatThaiDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month;
    final year = date.year + 543; // แปลงเป็นปี พ.ศ.
    return '$day-$month-$year';
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "บันทึกข้อมูลการฉีดวัคซีน",
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
          ? SizedBox(
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryColor, secondaryColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.medical_services,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "บันทึกประวัติการรับวัคซีน",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "กรอกข้อมูลวัคซีนที่ฉีดให้สัตว์เลี้ยง",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Vaccine Selection with Modern Style
                      _buildModernTextField(
                        label: "วัคซีนป้องกันโรค",
                        controller: vaccineController,
                        icon: Icons.vaccines,
                        screenHeight: MediaQuery.of(context).size.height,
                        validator: (value) => value == null || value.isEmpty
                            ? 'กรุณากรอกชื่อวัคซีน'
                            : null,
                      ),

                      const SizedBox(height: 20),

                      // Batch Number with Image
                      _buildModernImageField(
                        title: "หมายเลขชุดวัคซีน",
                        icon: Icons.qr_code,
                      ),

                      const SizedBox(height: 20),

                      // Doctor Dropdown
                      buildDoctorDropdown(),

                      const SizedBox(height: 20),

                      // Vaccination Date
                      _buildModernDateField(
                        label: "วันที่ฉีดวัคซีน",
                        controller: dateController,
                        icon: Icons.calendar_month,
                        screenHeight: MediaQuery.of(context).size.height,
                        onTap: () async {
                          await pickDate(context, vaccinationDate, (date) {
                            setState(() {
                              vaccinationDate = date;
                              dateController.text = formatThaiDateTime(date);
                            });
                          });
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? 'กรุณาเลือกวันที่ฉีดวัคซีน'
                            : null,
                      ),

                      const SizedBox(height: 20),

                      // Next Appointment Date
                      _buildModernDateField(
                        label: "วันนัดครั้งถัดไป",
                        controller: nextDateController,
                        icon: Icons.calendar_month,
                        screenHeight: MediaQuery.of(context).size.height,
                        onTap: () async {
                          await pickDate(context, nextAppointmentDate, (date) {
                            setState(() {
                              nextAppointmentDate = date;
                              nextDateController.text =
                                  formatThaiDateTime(date);
                            });
                          });
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? 'กรุณาเลือกวันนัดครั้งถัดไป'
                            : null,
                      ),

                      const SizedBox(height: 32),

                      // Submit Button
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            showAlert(
                                title: 'บันทึกประวัติการฉีดยา?',
                                message: '',
                                context: context,
                                onConfirm: () {
                                  injectionAdd();
                                });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize:
                                MainAxisSize.min, // ให้ขนาดพอดีกับเนื้อหา
                            children: [
                              Icon(
                                Icons.save,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(
                                  width:
                                      8), // เว้นระยะห่างระหว่างไอคอนกับข้อความ
                              Text(
                                'บันทึกประวัติ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // Helper Methods

  Widget _buildModernTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required double screenHeight,
    String? Function(String?)? validator,
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
          child: TextFormField(
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
              hintText: 'กรอก$label',
              hintStyle: TextStyle(
                color: Color(0xFF916B44).withOpacity(0.5),
                fontSize: 16,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildModernDateField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required double screenHeight,
    required VoidCallback onTap,
    String? Function(String?)? validator,
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
          child: TextFormField(
            controller: controller,
            readOnly: true,
            onTap: onTap,
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
              suffixIcon: Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF916B44),
              ),
              border: InputBorder.none,
              hintText: 'เลือก$label',
              hintStyle: TextStyle(
                color: Color(0xFF916B44).withOpacity(0.5),
                fontSize: 16,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildModernImageField({
    required String title,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF916B44),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          height: 180,
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
          child: ElevatedButton(
            onPressed: _pickImage,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Color(0xFF916B44),
              padding: EdgeInsets.zero,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: (_imageFile != null && _imageFile!.existsSync())
                  ? Image.file(
                      _imageFile!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Color(0xFFE9CBAF).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 32,
                              color: Color(0xFF916B44),
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'แตะเพื่อถ่ายรูป',
                            style: TextStyle(
                              color: Color(0xFF916B44).withOpacity(0.7),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernDropdownField({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
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
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
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
                Expanded(
                  child: Flexible(
                    // หรือจะไม่ใส่ก็ได้ถ้าไม่จำเป็น
                    child: Container(
                      constraints: BoxConstraints(minHeight: 56),
                      padding: EdgeInsets.only(right: 20),
                      child: child,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDoctorDropdown() {
    if (reserveList.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              "เลือกสัตวแพทย์",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF916B44),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
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
            child: Text(
              "กำลังโหลดข้อมูลการจอง...",
              style: TextStyle(
                color: Color(0xFF916B44).withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ),
        ],
      );
    }

    final email = reserveList[0].clinicEmail;
    if (email == null || email.isEmpty) {
      return _buildErrorDropdown("ไม่มีอีเมลสำหรับดึงรายชื่อสัตวแพทย์");
    }

    // Cache the future to prevent rebuilds
    if (_currentEmail != email || _doctorsFuture == null) {
      _currentEmail = email;
      _doctorsFuture = getdoctorList(email);
      // Reset selectedDoctor when email changes
      selectedDoctor = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            "เลือกสัตวแพทย์",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF916B44),
            ),
          ),
        ),
        FutureBuilder<List<DoctorPost>>(
          future: _doctorsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingContainer();
            } else if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return _buildErrorContainer();
            }

            final doctors = snapshot.data!;

            // Validate selectedDoctor exists in current doctors list
            if (selectedDoctor != null &&
                !doctors
                    .any((doc) => doc.careerNo == selectedDoctor!.careerNo)) {
              selectedDoctor = null;
            }

            return Container(
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
              child: Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: Colors.white,
                ),
                child: DropdownButtonFormField<String>(
                  key: ValueKey('doctor_dropdown_${email}_${doctors.length}'),
                  value: selectedDoctor?.careerNo,
                  items: doctors.map((doctor) {
                    return DropdownMenuItem<String>(
                      key: ValueKey(doctor.careerNo),
                      value: doctor.careerNo,
                      child: Text(
                        doctor.name ?? 'ไม่ระบุชื่อ',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF916B44),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newId) {
                    if (newId != null && mounted) {
                      try {
                        final newDoctor = doctors.firstWhere(
                          (doc) => doc.careerNo == newId,
                        );
                        setState(() {
                          selectedDoctor = newDoctor;
                        });
                      } catch (e) {
                        log('Error selecting doctor: $e');
                      }
                    }
                  },
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
                        Icons.person_outline,
                        color: Color(0xFF916B44),
                        size: 20,
                      ),
                    ),
                    border: InputBorder.none,
                    hintText: 'เลือกสัตวแพทย์',
                    hintStyle: TextStyle(
                      color: Color(0xFF916B44).withOpacity(0.5),
                      fontSize: 16,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                  ),
                  dropdownColor: Colors.white,
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF916B44),
                  ),
                  validator: (value) =>
                      value == null ? 'กรุณาเลือกสัตวแพทย์' : null,
                  isExpanded: true,
                  menuMaxHeight: 300,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildErrorDropdown(String message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            "เลือกสัตวแพทย์",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF916B44),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(16),
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
          child: Text(
            message,
            style: TextStyle(
              color: Color(0xFF916B44).withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

// Helper method for loading container
  Widget _buildLoadingContainer() {
    return Container(
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
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.all(12),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFFE9CBAF).withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF916B44)),
                ),
              ),
            ),
            Expanded(
              child: Text(
                "กำลังโหลด...",
                style: TextStyle(
                  color: Color(0xFF916B44).withOpacity(0.5),
                  fontSize: 16,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF916B44),
            ),
          ],
        ),
      ),
    );
  }

// Helper method for error container
  Widget _buildErrorContainer() {
    return Container(
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
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.all(12),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFFE9CBAF).withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.person_outline,
                color: Color(0xFF916B44),
                size: 20,
              ),
            ),
            Expanded(
              child: Text(
                "ไม่พบรายชื่อสัตวแพทย์",
                style: TextStyle(
                  color: Color(0xFF916B44).withOpacity(0.5),
                  fontSize: 16,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF916B44),
            ),
          ],
        ),
      ),
    );
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
                setState(() => _imageFile = File(picked.path));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: lightColor.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // ฟังก์ชันเลือกวัน
  Future<void> pickDate(BuildContext context, DateTime? initialDate,
      Function(DateTime) onPick) async {
    FocusScope.of(context).requestFocus(FocusNode());

    DateTime selectedDate = initialDate ?? DateTime.now();
    DateTime focusedDate = selectedDate;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Color(0xFFFAF8F5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFFDBA871),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'เลือกวันที่',
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
                height: MediaQuery.of(context).size.height * 0.525,
                child: TableCalendar<DateTime>(
                  firstDay: DateTime(2020),
                  lastDay: DateTime.now().add(Duration(days: 365 * 5)),
                  focusedDay: focusedDate,
                  selectedDayPredicate: (day) => isSameDay(selectedDate, day),
                  calendarFormat: CalendarFormat.month,
                  startingDayOfWeek: StartingDayOfWeek.sunday,
                  locale: 'th',
                  // Disable past dates
                  enabledDayPredicate: (day) {
                    DateTime today = DateTime.now();
                    DateTime dayOnly = DateTime(day.year, day.month, day.day);
                    DateTime todayOnly =
                        DateTime(today.year, today.month, today.day);
                    return dayOnly.isAfter(todayOnly) ||
                        dayOnly.isAtSameMomentAs(todayOnly);
                  },

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
                    // Disable past dates
                    disabledTextStyle: TextStyle(
                      color: Colors.grey.withOpacity(0.4),
                      fontWeight: FontWeight.w400,
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
                                if (newDate.isAfter(DateTime(2020, 1, 1))) {
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
                                              DateTime now = DateTime.now();
                                              DateTime newDate = DateTime(
                                                  focusedDate.year,
                                                  newMonth,
                                                  1);

                                              // If selecting current year and a past month, don't allow it
                                              if (focusedDate.year ==
                                                      now.year &&
                                                  newMonth < now.month) {
                                                return; // Don't change if trying to select past month in current year
                                              }

                                              // Ensure the new date doesn't exceed lastDay
                                              DateTime lastDay = DateTime.now()
                                                  .add(Duration(days: 365 * 5));
                                              if (newDate.isAfter(lastDay)) {
                                                newDate = DateTime(lastDay.year,
                                                    lastDay.month, 1);
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
                                            (DateTime.now().year + 10) -
                                                DateTime.now().year +
                                                1,
                                            (index) {
                                              int year =
                                                  DateTime.now().year + index;
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
                                          ), // No reverse needed since we start from current year
                                          onChanged: (int? newYear) {
                                            if (newYear != null) {
                                              DateTime newDate;
                                              DateTime now = DateTime.now();

                                              // If selecting current year, keep current month or later
                                              if (newYear == now.year) {
                                                // Use current month if focused month is earlier than current month
                                                int monthToUse =
                                                    focusedDate.month <
                                                            now.month
                                                        ? now.month
                                                        : focusedDate.month;
                                                newDate = DateTime(
                                                    newYear, monthToUse, 1);
                                              } else {
                                                // For other years, keep the focused month
                                                newDate = DateTime(newYear,
                                                    focusedDate.month, 1);
                                              }

                                              // Ensure the new date doesn't exceed lastDay
                                              DateTime lastDay = DateTime.now()
                                                  .add(Duration(days: 365 * 5));
                                              if (newDate.isAfter(lastDay)) {
                                                newDate = DateTime(lastDay.year,
                                                    lastDay.month, 1);
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
                                DateTime lastDay =
                                    DateTime.now().add(Duration(days: 365 * 5));
                                if (newDate.isBefore(lastDay) ||
                                    isSameDay(newDate, lastDay)) {
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
                    // Only allow selection of today or future dates
                    DateTime today = DateTime.now();
                    DateTime selectedDayOnly = DateTime(
                        selectedDay.year, selectedDay.month, selectedDay.day);
                    DateTime todayOnly =
                        DateTime(today.year, today.month, today.day);

                    if (selectedDayOnly.isAfter(todayOnly) ||
                        selectedDayOnly.isAtSameMomentAs(todayOnly)) {
                      setState(() {
                        selectedDate = selectedDay;
                        focusedDate = focusedDay;
                      });
                    }
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
                  onPressed: () => Navigator.of(context).pop(),
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
                    onPick(selectedDate);
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

  String formatThaiDateTime(DateTime date) {
    final localDate = date.toLocal();

    final thaiMonths = [
      '',
      'มกราคม',
      'กุมภาพันธ์',
      'มีนาคม',
      'เมษายน',
      'พฤษภาคม',
      'มิถุนายน',
      'กรกฎาคม',
      'สิงหาคม',
      'กันยายน',
      'ตุลาคม',
      'พฤศจิกายน',
      'ธันวาคม'
    ];

    final day = localDate.day;
    final month = thaiMonths[localDate.month];
    final year = localDate.year + 543;

    return 'วันที่ $day $month $year';
  }

  Future<void> getReserve(String docId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('reserve')
          .doc(docId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        log('✅ Data for docId=$docId: $data');

        // Clear old data and add new data
        reserveList.clear();
        reserveList.add(ReserveClinicFirebase.fromJson(data, doc.id));

        // Initialize controllers only once
        if (dateController.text.isEmpty) {
          final String? dateStr = data['date'];
          if (dateStr != null) {
            final DateTime? parsedDate = DateTime.tryParse(dateStr);
            if (parsedDate != null) {
              dateController.text = formatThaiDateTime(parsedDate);
            }
          }
        }

        // Fetch additional data
        final String? aidStr = reserveList[0].appointmentAid;
        final String? email = reserveList[0].generalEmail;

        if (aidStr != null &&
            email != null &&
            aidStr.isNotEmpty &&
            email.isNotEmpty) {
          await getvaccine(aidStr, email);
        }

        // Add listeners only if not already added
        if (!vaccineController.hasListeners) {
          vaccineController.addListener(() {
            vaccineChanged = true;
          });
        }

        if (!dateController.hasListeners) {
          dateController.addListener(() {
            dateChanged = true;
          });
        }

        if (mounted) {
          setState(() {
            _loadingData = false;
          });
        }
      } else {
        log('❌ No document found for docId=$docId');
        if (mounted) {
          setState(() {
            _loadingData = false;
          });
        }
      }
    } catch (e) {
      log('❌ Error while fetching document: $e');
      if (mounted) {
        setState(() {
          _loadingData = false;
        });
      }
    }
  }

  AppointmentClinic appointmentClinicFromJson(String str) {
    final jsonData = json.decode(str);
    log("📦 Received JSON: $jsonData");

    if (jsonData is Map && jsonData['data'] != null) {
      return AppointmentClinic.fromJson(
        Map<String, dynamic>.from(jsonData['data']),
      );
    }
    throw Exception("Invalid JSON format");
  }

  Future<AppointmentClinic?> getvaccine(
      String? aids, String? generalEmail) async {
    if (aids == null ||
        aids.trim().isEmpty ||
        generalEmail == null ||
        generalEmail.trim().isEmpty) {
      log("❌ Invalid input: aids or email is null/empty");
      return null;
    }

    log("📥 aids: $aids, email: $generalEmail");

    try {
      final urlStr = "$url/appointment/latestdate/$aids/$generalEmail";
      final res = await http.get(Uri.parse(urlStr));

      if (res.statusCode == 200) {
        // log('📦 API response body: ${res.body}');

        final appointment = appointmentClinicFromJson(res.body);

        if (appointment.data.isNotEmpty) {
          final vaccinesStr = appointment.data.first.vaccines ?? '';
          if (vaccineController.text.trim().isEmpty && vaccinesStr.isNotEmpty) {
            vaccineController.text = vaccinesStr;
          }
        }

        return appointment;
      } else {
        log("❌ Failed to load vaccine data: ${res.statusCode}");
        return null;
      }
    } catch (e) {
      log("❌ Exception while fetching vaccine info: $e");
      return null;
    }
  }

  List<DoctorPost> doctorPostFromJson(String str) => List<DoctorPost>.from(
      json.decode(str).map((x) => DoctorPost.fromJson(x)));

  Future<List<DoctorPost>> getdoctorList(String clinicEmail) async {
    log("📥 clinicEmail: $clinicEmail");

    final doctor = await getdoctor(clinicEmail);
    if (doctor != null) {
      return [doctor];
    } else {
      return [];
    }
  }

  Future<DoctorPost?> getdoctor(String clinicEmail) async {
    log("📥 clinicEmail: $clinicEmail");
    try {
      var res =
          await http.get(Uri.parse("$url/doctor/searchemail/$clinicEmail"));
      if (res.statusCode == 200) {
        final List<DoctorPost> doctorList = doctorPostFromJson(res.body);
        if (doctorList.isNotEmpty) {
          return doctorList.first;
        }
        return null; // กรณีไม่มีข้อมูล
      } else {
        log("❌ Failed to load doctor: ${res.statusCode}");
        return null;
      }
    } catch (e) {
      log("❌ Exception while fetching doctor info: $e");
      return null;
    }
  }

  Future<GeneralPost?> getGeneral(String generalEmail) async {
    try {
      var res = await http.get(Uri.parse("$url/general/$generalEmail"));
      if (res.statusCode == 200) {
        final Map<String, dynamic> jsonMap = json.decode(res.body);
        return GeneralPost.fromJson(jsonMap);
      } else {
        log("❌ Failed to load: ${res.statusCode}");
        return null;
      }
    } catch (e) {
      log("Error: $e");
      return null;
    }
  }

  Future<void> injectionAdd() async {
    showLoadingDialog();
    // เช็คว่า reserveList มีข้อมูลไหม
    if (reserveList.isEmpty) {
      log("⚠️ reserveList is empty");
      showTopNotification(
        context,
        'ไม่สามารถดำเนินการได้: ไม่พบข้อมูลการจอง',
        isSuccess: false,
      );
      return;
    }

    // เช็คว่าข้อมูลครบ (วัคซีน, วันที่, รูปภาพ, วันที่นัดถัดไป)
    if (vaccineController.text.trim().isEmpty ||
        dateController.text.trim().isEmpty ||
        _imageFile == null ||
        nextDateController.text.trim().isEmpty) {
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
      Get.back();
      return;
    }

    // log ตรวจสอบค่า vaccine ก่อนส่ง
    log("📌 vaccineController.text ก่อนส่ง: ${vaccineController.text}");

    // ถามยืนยันจากผู้ใช้
    // bool isConfirmed = await confirmDialog(context);
    // if (!isConfirmed) {
    //   log("ผู้ใช้ยกเลิกการบันทึก");
    //   return;
    // }

    // อัปโหลดรูปภาพและรับ URL
    final imageUrl = await confirmAvatarButton();
    log("imageUrl ก่อนส่ง: $imageUrl");

    if (imageUrl.isEmpty) {
      log("Upload failed, cancel saving.");
      showTopNotification(
        context,
        'การอัปโหลดรูปภาพล้มเหลว',
        isSuccess: false,
      );
      return;
    }

    DateTime parsedThai = DateFormat('วันที่ d MMMM yyyy', 'th_TH')
        .parse(nextDateController.text);
    DateTime nextDate =
        DateTime(parsedThai.year - 543, parsedThai.month, parsedThai.day);

    final String dogIdStr = reserveList[0].dogDogId;
    final int dogId = int.tryParse(dogIdStr) ?? 0;

    AppointmentPost appReq = AppointmentPost(
      dogId: dogId,
      generalUserEmail: reserveList[0].generalEmail,
      vaccine: vaccineController.text,
      date: nextDate,
    );

    await InsertionjectionRecord(appReq, imageUrl, reserveList[0].docId);
  }

  Future<void> InsertionjectionRecord(
      AppointmentPost appReq, String imageUrl, String docId) async {
    try {
      // ✅ log ข้อมูลก่อนส่ง appointment
      final appointmentJson = appReq.toJson();
      log("📤 กำลังส่ง appointment: ${jsonEncode(appointmentJson)}");

      // ✅ POST ไปที่ API /appointment
      var res = await http.post(
        Uri.parse("$url/appointment/"),
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: jsonEncode(appointmentJson),
      );

      // ✅ ตรวจสอบผลลัพธ์
      if (res.statusCode == 200 || res.statusCode == 201) {
        // 2. ดึงข้อมูลของ reserve

        final Map<String, dynamic> appData = jsonDecode(res.body);
        log("📥 ตอบกลับจาก appointment: ${res.body}");

        int aid = appData['insertId'];
        log("✅ บันทึก appointment สำเร็จ aid = $aid");

        // ✅ แปลงวันที่ฉีดจริง (old date)
        DateTime parsedThai = DateFormat('วันที่ d MMMM yyyy', 'th_TH')
            .parse(dateController.text);
        DateTime oldDate =
            DateTime(parsedThai.year - 543, parsedThai.month, parsedThai.day);

        final String? aidStr = reserveList[0].appointmentAid;
        final List<String> aidsStr =
            (aidStr != null && aidStr.isNotEmpty) ? aidStr.split(',') : [];
        final List<int> aids = aidsStr
            .map((e) => int.tryParse(e.trim()) ?? 0)
            .where((id) => id != 0)
            .toList();
        final int oldAid = aids.isNotEmpty ? aids.first : 0;

        // ✅ ใช้ vaccine ที่ผู้ใช้กรอกมา (เพราะ API ไม่ส่งมา)
        final String latestVaccine = vaccineController.text.trim();

        ClinicinjectionRecordPost injReq = ClinicinjectionRecordPost(
          oldAppointmentAid: oldAid == 0 ? null : oldAid,
          nextAppointmentAid: aid,
          clinicEmail: reserveList[0].clinicEmail,
          doctorCareerNo: selectedDoctor?.careerNo ?? '',
          vaccine: latestVaccine,
          date: oldDate,
          vaccineLabel: imageUrl,
          type: reserveList[0].type,
        );

        final jsonBody = clinicinjectionRecordPostToJson([injReq]);
        log("📦 JSON ที่จะส่ง clinicinjectionRecord: $jsonBody");

        var injRes = await http.post(
          Uri.parse("$url/clinicinjectionRecord"),
          headers: {"Content-Type": "application/json; charset=utf-8"},
          body: jsonEncode(injReq.toJson()),
        );

        if (injRes.statusCode == 200 || injRes.statusCode == 201) {
          final doc = await FirebaseFirestore.instance
              .collection('reserve')
              .doc(docId)
              .get();
          if (doc.exists) {
            final data = doc.data();
            final generalEmail = data?['generalEmail'];
            final clinicEmail = data?['clinicEmail'];

            if (generalEmail != null) {
              final generalUser = await getGeneral(generalEmail);
              final userName = generalUser?.name;

              if (userName != null) {
                await sendClinicInjectioncompletedNotification(
                    clinicEmail: clinicEmail,
                    userName: box.read('clinicName'),
                    date: data?['date'] ?? '',
                    generalEmail: generalEmail);
              } else {
                log("⚠️ Missing userName from getGeneral()");
              }
            } else {
              log("⚠️ Missing generalEmail in document");
            }
          }
          log('✅ บันทึก clinicinjectionRecord สำเร็จ');
          await updatestatus(reserveList[0].docId, 3);
          // Navigator.of(context).pushReplacement(
          //     MaterialPageRoute(builder: (_) => ClinicmainPage()));
          // Clinicappnavigator.toWidget(ClinicmainPage());
        } else {
          log("❌ clinicinjectionRecord ล้มเหลว: ${injRes.statusCode} ${injRes.body}");
          showTopNotification(
            context,
            'บันทึกข้อมูลวัคซีนไม่สำเร็จ กรุณาลองใหม่',
            isSuccess: false,
          );
        }
      } else {
        log("❌ บันทึก appointment ไม่สำเร็จ: ${res.statusCode}");
        log("❌ ตอบกลับ: ${res.body}");
        showTopNotification(
          context,
          'บันทึกการนัดหมายล้มเหลว กรุณาลองใหม่',
          isSuccess: false,
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // ปิด dialog ถ้ายังเปิดอยู่
      log("❌ Exception: $e");
      showTopNotification(
        context,
        'เกิดข้อผิดพลาดในการเชื่อมต่อ',
        isSuccess: false,
      );
    }
    Get.back();
  }

  Future<void> sendClinicInjectioncompletedNotification({
    required String clinicEmail,
    required String generalEmail,
    required String userName,
    required String date,
  }) async {
    final apiUrl =
        Uri.parse("$url/reserve/notify/injectioncompleted/clinic-request");

    final Map<String, dynamic> data = {
      'clinicEmail': clinicEmail,
      'generalEmail': generalEmail,
      'userName': userName,
      'date': date,
    };

    try {
      final response = await http.post(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print('✅ ส่งแจ้งเตือนสำเร็จ: ${response.body}');
      } else {
        print('❌ เกิดข้อผิดพลาด: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('❗ ไม่สามารถเชื่อมต่อกับ server: $e');
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

  Future<void> updatestatus(String docId, int status) async {
    if (status == 3) {
      try {
        await FirebaseFirestore.instance
            .collection('reserve')
            .doc(docId)
            .update({
          'status': status,
        });
        Get.back();
        log('✅ Updated status to $status for docId=$docId');
      } catch (e) {
        log('❌ Failed to update status: $e');
      }
    } else {
      log('⚠️ Status not allowed to update: $status');
    }
  }

  void showTopNotification(BuildContext context, String message,
      {bool isSuccess = true}) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => TopNotificationWidget(
        message: message,
        isSuccess: isSuccess,
        onDismiss: () {
          overlayEntry.remove();
        },
      ),
    );

    overlay.insert(overlayEntry);

    // ปิดแจ้งเตือนอัตโนมัติหลัง 3 วินาที
    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  Future<bool> confirmDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          barrierDismissible: false, // ป้องกันการปิดโดยการแตะข้างนอก
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(
                color: Color(0xFF916B44),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center, // กลางแนวนอน
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF916B44),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.vaccines,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "ยืนยันการบันทึก",
                  style: TextStyle(
                    color: Color(0xFF916B44),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "คุณต้องการบันทึกข้อมูลการฉีดวัคซีนหรือไม่?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF916B44),
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.center, // ปุ่มอยู่ตรงกลาง
            actionsPadding: const EdgeInsets.only(bottom: 12, top: 4),
            actions: [
              // ปุ่มยกเลิก
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: const Color(0xFF916B44),
                    width: 1.5,
                  ),
                ),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF916B44),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "ยกเลิก",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // ปุ่มยืนยัน
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  // gradient: const LinearGradient(
                  //   colors: [
                  //     Color(0xFF916B44),
                  //     Color(0xFFDBA871),
                  //   ],
                  //   begin: Alignment.topLeft,
                  //   end: Alignment.bottomRight,
                  // ),
                  color: Color(0xFF916B44),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF916B44).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "ยืนยัน",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<String> confirmAvatarButton() async {
    await Supabase.instance.client.auth.signInWithPassword(
      email: '65011212077@msu.ac.th',
      password: '1234',
    );

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      log("User not logged in. Cannot upload.");
      return '';
    }

    if (_imageFile == null) {
      log("No image to upload.");
      return '';
    }

    try {
      final fileBytes = await _imageFile!.readAsBytes();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';

      final storageResponse = await Supabase.instance.client.storage
          .from('vaccine-label')
          .uploadBinary(fileName, fileBytes,
              fileOptions: const FileOptions(upsert: true));

      if (storageResponse.isEmpty) {
        log('Upload failed.');
        return '';
      }

      final publicUrl = Supabase.instance.client.storage
          .from('vaccine-label')
          .getPublicUrl(fileName);

      log("Upload success. Public URL: $publicUrl");
      return publicUrl;
    } catch (e) {
      log("Error during upload: $e");
      return '';
    }
  }
}

class TopNotificationWidget extends StatefulWidget {
  final String message;
  final bool isSuccess;
  final VoidCallback onDismiss;

  const TopNotificationWidget({
    Key? key,
    required this.message,
    required this.isSuccess,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<TopNotificationWidget> createState() => _TopNotificationWidgetState();
}

class _TopNotificationWidgetState extends State<TopNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: widget.isSuccess
                      ? [
                          const Color(0xFF916B44), // primaryColor
                          const Color(0xFFDBA871), // secondaryColor
                        ]
                      : [
                          Colors.red[400]!,
                          Colors.red[600]!,
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (widget.isSuccess
                            ? const Color(0xFF916B44)
                            : Colors.red[400]!)
                        .withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.isSuccess ? Icons.check_circle : Icons.error,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _dismiss,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
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
}
