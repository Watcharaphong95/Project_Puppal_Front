import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/controller/registerDoctorCtl.dart';
import 'package:puppal_application/main.dart';
import 'package:puppal_application/model/docspecialPost.dart';
import 'package:puppal_application/model/doctorPost.dart';
import 'package:puppal_application/model/getdocspecialID.dart';
import 'package:puppal_application/model/putDoctorDataPost.dart';
import 'package:puppal_application/model/seacrhspecialPost.dart';
import 'package:puppal_application/model/specialPost.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicListDoctors.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicMain.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicOpeningHours.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicDoctorProfile.dart';
import 'package:puppal_application/pages/clinicMainBottomNavigate.dart';
import 'package:puppal_application/pages/login/index.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class Clinicdoctoreditprofile extends StatefulWidget {
  final String? careerNo;
  const Clinicdoctoreditprofile({super.key, this.careerNo});

  @override
  State<Clinicdoctoreditprofile> createState() =>
      _ClinicdoctoreditprofileState();
}

class _ClinicdoctoreditprofileState extends State<Clinicdoctoreditprofile> {
  TextEditingController nameCtl = TextEditingController();
  TextEditingController surnameCtl = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController imageCtl = TextEditingController();

  final controller = Get.find<registerDoctorCtl>();
  final doctorListController = Get.find<doctorDataList>();
  final doctor = Get.find<registerDoctorCtl>();

  late double screenWidth;
  late double screenHeight;
  final box = GetStorage();
  String url = "";
  List<DoctorPost> doctorsList = [];
  bool _loadingData = true;
  List<String> selectedSpecialty = [];
  List<String> tempSelectSpecial = [];
  List<SpecialPost> special = [];
  List<GetDocSpecialIdPost> docSpecialList = [];
  List<String> unselectedSpecialties = [];

  File? _imageFile;

  bool dataChange = false;

  String? initialName;
  String? initialSurname;
  String? initialImage;
  List<String> initialSpecialties = [];

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
      searcheDoctor(this.widget.careerNo);
      getSpecialData();
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
      appBar: AppBar(
        backgroundColor: Color(0xFFDBA871),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "แก้ไขโปรไฟล์คุณหมอ",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _loadingData
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFFDBA871),
                ),
              ),
            )
          : SingleChildScrollView(
              child: Container(
                color: Color(0xFFFAF8F5),
                child: Column(
                  children: doctorsList.map((doctor) {
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          // Profile Image Section
                          Stack(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[300],
                                ),
                                child: _imageFile != null
                                    ? ClipOval(
                                        child: Image.file(
                                          File(_imageFile!.path),
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : (doctor.image.isNotEmpty
                                        ? ClipOval(
                                            child: Image.network(
                                              doctor.image,
                                              width: 120,
                                              height: 120,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Icon(
                                                Icons.person,
                                                size: 60,
                                                color: Colors.white,
                                              ),
                                            ),
                                          )
                                        : Icon(
                                            Icons.person,
                                            size: 60,
                                            color: Colors.white,
                                          )),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFFDBA871),
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          // Career Number
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Color(0xFFDBA871),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.badge,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  doctor.careerNo,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Career Number
                          Container(
                            // กำหนด max width ได้ถ้าต้องการ
                            child: Column(
                              children: [
                                // Name Field
                                _buildModernTextField(
                                    label: 'ชื่อ',
                                    controller: nameCtl,
                                    icon: Icons.person_outline,
                                    screenHeight: screenHeight,
                                    onChanged: (value) {
                                      if (nameCtl.text != initialName) {
                                        dataChange = true;
                                      } else {
                                        dataChange = false;
                                      }
                                    }),

                                SizedBox(height: 24),

                                // Surname Field
                                _buildModernTextField(
                                    label: 'นามสกุล',
                                    controller: surnameCtl,
                                    icon: Icons.person_outline,
                                    screenHeight: screenHeight,
                                    onChanged: (value) {
                                      if (surnameCtl.text != initialSurname) {
                                        dataChange = true;
                                      } else {
                                        dataChange = false;
                                      }
                                    }),

                                SizedBox(height: 24),

                                // Specialty Field
                                _buildSpecialtyField(
                                  label: 'ความเชี่ยวชาญ',
                                  subtitle: '(เช่น ผ่าตัด, ยา)',
                                  selectedSpecialty: selectedSpecialty,
                                  onTap: _showSelectSpecialty,
                                  screenHeight: screenHeight,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 60),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final confirm =
                                        await confirmDeleteDoctorDialog(
                                            context);
                                    if (!confirm)
                                      return; // ถ้าไม่ยืนยัน ให้หยุดการทำงาน
                                    deleteDoctor(doctor.careerNo);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Color.fromARGB(255, 220, 0, 0),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'ลบหมอ',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: dataChange
                                      ? () {
                                          showAlert(
                                            title: 'ต้องการบันทึกข้อมูล?',
                                            message: 'ข้อมูลเก่าจะถูกลบถาวร',
                                            onConfirm: () {
                                              updatedataDoctor(doctor.careerNo);
                                            },
                                          );
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF916B44),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.save,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'บันทึก',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
    );
  }

  Widget _buildModernTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required double screenHeight,
    void Function(String)? onChanged, // ✅ เพิ่ม parameter optional
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
            onChanged: onChanged, // ✅ เพิ่ม onChanged ที่นี่
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
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialtyField({
    required String label,
    required String subtitle,
    required List<String> selectedSpecialty,
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
                    Icons.medical_information_outlined,
                    color: Color(0xFF916B44),
                    size: 20,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (selectedSpecialty.isEmpty)
                        Text(
                          'เลือกความเชี่ยวชาญ',
                          style: TextStyle(
                            color: Color(0xFF916B44).withOpacity(0.5),
                            fontSize: 16,
                          ),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: selectedSpecialty.toSet().map((specialty) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Color(0xFF916B44).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Color(0xFF916B44).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                specialty,
                                style: TextStyle(
                                  color: Color(0xFF916B44),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
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

  // Helper Methods
  Widget _buildSimpleField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
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
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: Offset(0, 1),
                blurRadius: 3,
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: Colors.grey[400],
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialtySimpleField({
    required String label,
    required String subtitle,
    required List<String> selectedSpecialty,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            '$label $subtitle',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: Offset(0, 1),
                  blurRadius: 3,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.medical_information_outlined,
                  color: Colors.grey[400],
                  size: 20,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: selectedSpecialty.isEmpty
                      ? Text(
                          'สัตวแพทย์ทั่วไป, สัตวแพทย์ต่างประเทศ',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                        )
                      : Text(
                          selectedSpecialty.join(', '),
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
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

  List<DoctorPost> doctorPostFromJson(String str) => List<DoctorPost>.from(
      json.decode(str).map((x) => DoctorPost.fromJson(x)));

  Future<void> searcheDoctor(careerNo) async {
    showLoadingDialog();

    try {
      final res =
          await http.get(Uri.parse("$url/doctor/searcheCareer/$careerNo"));
      if (res.statusCode == 200) {
        final data = doctorPostFromJson(res.body);
        for (var doctor in data) {
          // log("ชื่อหมอ: ${doctor.name}");
          // log(doctor.careerNo);
          // updatedataDoctor(doctor.careerNo);
          getSearchSpecial(doctor.careerNo);
          if (data.isNotEmpty) {
            nameCtl.text = data[0].name;
            surnameCtl.text = data[0].surname;
            imageCtl.text = data[0].image;

            initialName = data[0].name;
            initialSurname = data[0].surname;
            initialImage = data[0].image;
          }
        }
        setState(() {
          doctorsList = data;
          _loadingData = false;
        });
      } else {
        setState(() {
          _loadingData = false;
        });
      }
    } catch (e) {
      setState(() {
        _loadingData = false;
      });
    }
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  Future<void> searchnamedocspecial(String name) async {
    log("Unselected and searching: $name");
    docSpecialList = [];
    if (name.isEmpty) {
      log("Name is empty, skipping search");
      return;
    }
    var res = await http.get(Uri.parse("$url/docspecial/getnamespecial/$name"));
    if (res.statusCode == 200) {
      docSpecialList = (json.decode(res.body) as List)
          .map((e) => GetDocSpecialIdPost.fromJson(e))
          .toList();
    } else {
      log("Failed to load specialties: ${res.statusCode}");
    }
  }

  Widget _buildInfoField({
    required IconData icon,
    required String label,
    required String value,
    required double screenHeight,
    required TextEditingController controller,
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
              // controller: TextEditingController(text: value),
              controller: controller,
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

  Future<void> updatedataDoctor(String careerNo) async {
    if (nameCtl.text.isEmpty || surnameCtl.text.isEmpty) {
      if (doctorsList.isNotEmpty) {
        if (nameCtl.text.isEmpty) nameCtl.text = doctorsList[0].name;
        if (surnameCtl.text.isEmpty) surnameCtl.text = doctorsList[0].surname;
      } else {
        log("doctorsList is empty — cannot assign name/surname");
        return;
      }
    }
    showLoadingDialog(message: "กำลังโหลด...");
    if (_imageFile != null) {
      await uploadImage();
    }
    PutDoctorDataPost req = PutDoctorDataPost(
      name: nameCtl.text,
      surname: surnameCtl.text,
      image: imageCtl.text,
    );

    var res = await http.put(
      Uri.parse("$url/doctor/editprofile/$careerNo"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(req.toJson()),
    );

    if (res.statusCode == 200) {
      log("Update doctor name and surname success");
    } else {
      log("Failed to update doctor info: ${res.statusCode}");
    }

    for (var name in unselectedSpecialties) {
      await searchnamedocspecial(name);
      if (docSpecialList.isEmpty) {
        log("ไม่มีข้อมูล docspecial สำหรับชื่อ $name");
      }
      for (var item in docSpecialList) {
        log("กำลังลบ docspecialId: ${item.docspecialId}");
        await deletedocspecial(item.docspecialId.toString());
      }
    }

    for (var item in selectedSpecialty) {
      final matchedSpecial = special.firstWhere(
        (s) => s.name == item,
        orElse: () => SpecialPost(name: '', specialId: 0),
      );

      if (matchedSpecial.specialId != 0) {
        final checkRes = await http.get(
          Uri.parse(
              "$url/docspecial/check/${careerNo}/${matchedSpecial.specialId}"),
        );

        if (checkRes.statusCode == 200) {
          final jsonData = json.decode(checkRes.body);
          final exists = jsonData['exists'] == true;

          if (exists) {
            log("ข้าม '${item}' เพราะมีอยู่แล้วในระบบ");
            continue;
          } else {
            await docspecialAdd(
              doctorId: careerNo,
              specialId: matchedSpecial.specialId!,
            );
          }
        } else {
          log("เช็คไม่สำเร็จสำหรับ ${item} => status: ${checkRes.statusCode}");
        }
      } else {
        log("ไม่พบ specialId สำหรับ '${item}'");
      }
    }
    unselectedSpecialties.clear();
    dataChange = false;
    Get.back();
    showAlertNoClose(
      title: 'อัพเดทเสร็จสิ้น',
      message: 'อัพเดทข้อมูลหมอเรียบร้อยแล้ว',
    );
  }

  Future<void> deleteDoctor(String careerNo) async {
    showLoadingDialog();

    try {
      final response = await http.delete(Uri.parse("$url/doctor/$careerNo"));

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
        var imagePathAll = imageCtl.text.split('/');
        var imagePath = imagePathAll.last;

        await supabase.storage.from('doctor-image').remove([imagePath]);
      } catch (e) {
        log("Error during upload: $e");
      }

      if (response.statusCode == 200) {
        showAlertNoClose(
            title: 'ลบหมอเสร็จสิ้น',
            message: '',
            onConfirm: () {
              Get.off(() => Clinicmainbottomnavigate(indexPage: 3));
            });
      } else {
        showAlertNoClose(
            title: 'เกิดข้อผิดพลาด', message: 'กรุณาลองใหม่อีกครั้ง');
      }
    } catch (e) {
      print('❌ error: $e');
      Get.snackbar("ข้อผิดพลาด", "ลบข้อมูลล้มเหลว: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> deletedocspecial(String docspecialID) async {
    var res = await http.delete(Uri.parse("$url/docspecial/$docspecialID"));
    if (res.statusCode == 200) {
      var data = jsonDecode(res.body);
      log("Deleted docspecial: $docspecialID, Response: $data");
    } else {
      log("Failed to delete docspecial: $docspecialID, Status: ${res.statusCode}");
    }
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

  Future<void> docspecialAdd({
    required String doctorId,
    required int specialId,
  }) async {
    final req = DocSpecialPost(
      doctorId: doctorId,
      specialId: specialId,
    );

    log("Sending doctorId: $doctorId, specialId: $specialId");
    final res = await http.post(
      Uri.parse("$url/docspecial"),
      headers: {"Content-Type": "application/json; charset=utf-8"},
      body: jsonEncode(req),
    );

    log("ส่ง doctorId: $doctorId, specialId: $specialId => status: ${res.statusCode}");
  }

  Future<void> deleteSpecialByObject(String name) async {
    showLoadingDialog(); // แสดง dialog
    try {
      // 1. ค้นหา special_id จากชื่อก่อน
      final response = await http.get(Uri.parse('$url/special/search/$name'));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);

        if (data.isEmpty) {
          log("❌ ไม่พบชื่อ $name ในฐานข้อมูล special");
          return;
        }

        final specialId = data[0]['special_id'];

        // 2. เช็คว่า special_id ถูกใช้งานหรือไม่
        final docSpecialResponse = await http.get(Uri.parse('$url/docspecial'));

        if (docSpecialResponse.statusCode == 200) {
          final List docSpecialData = json.decode(docSpecialResponse.body);

          final isUsed = docSpecialData.any(
            (item) => item['special_id'] == specialId,
          );

          if (isUsed) {
            Get.snackbar(
              "ไม่สามารถลบข้อมูลได้",
              "เพราะความเชี่ยวชาญนี้มีหมอใช้อยู่",
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            log("❌ ไม่สามารถลบ $name เพราะมีหมอใช้อยู่ (special_id: $specialId)");
            return;
          }

          // 3. ลบได้
          final deleteRes =
              await http.delete(Uri.parse('$url/special/$specialId'));

          if (deleteRes.statusCode == 200) {
            log("✅ ลบ $name แล้ว (id: $specialId)");
            Get.snackbar(
              "ลบข้อมูลสำเร็จ",
              "ลบความเชี่ยวชาญ '$name' เรียบร้อยแล้ว",
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
            );
            _init();
          } else {
            log("❌ ลบ $name ไม่ได้ (id: $specialId)");
          }
        } else {
          log("❌ โหลด docspecial ไม่ได้: ${docSpecialResponse.statusCode}");
        }
      } else {
        log("❌ โหลด special ไม่ได้: ${response.statusCode}");
      }
    } catch (e) {
      log("❌ เกิดข้อผิดพลาดในการลบ: $e");
    } finally {
      // ปิด loading dialog เสมอ
      Navigator.of(Get.context!).pop();
    }
  }

  Future<bool> confirmDeleteSpecialDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          barrierDismissible: false,
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.delete_forever,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "ยืนยันการลบข้อมูล",
                  style: TextStyle(
                    color: Color(0xFF916B44),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "คุณต้องการลบข้อมูลความเชี่ยวชาญหรือไม่?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF916B44),
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.center,
            actionsPadding: const EdgeInsets.only(bottom: 12, top: 4),
            actions: [
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
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
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

  Future<bool> confirmDeleteDoctorDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          barrierDismissible: false,
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.delete_forever,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "ยืนยันการลบข้อมูล",
                  style: TextStyle(
                    color: Color(0xFF916B44),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "คุณต้องการลบข้อมูลคุณหมอหรือไม่?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF916B44),
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.center,
            actionsPadding: const EdgeInsets.only(bottom: 12, top: 4),
            actions: [
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
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
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

  void _init() {
    getSpecialData();
    setState(() {});
  }

  void _showSelectSpecialty() {
    TextEditingController searchController = TextEditingController();
    TextEditingController otherSpecialtyController = TextEditingController();
    List<String> allSpecialties = [...special.map((s) => s.name), "อื่นๆ"];
    List<String> filtered = List<String>.from(allSpecialties);
    List<String> tempSelected = List<String>.from(selectedSpecialty);
    bool isOtherSelected = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 16),
                    Container(
                      width: 50,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Color(0xFF916B44).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      isOtherSelected
                          ? 'เพิ่มความเชี่ยวชาญใหม่'
                          : 'เลือกความเชี่ยวชาญ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF916B44),
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          if (!isOtherSelected) ...[
                            // Selected Tags
                            if (tempSelected.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: tempSelected.toSet().map((item) {
                                  return Chip(
                                    label: Text(item),
                                    backgroundColor: Color(0xFFFAF8F5),
                                    deleteIcon: Icon(Icons.close, size: 18),
                                    onDeleted: () {
                                      setModalState(() {
                                        tempSelected.remove(item);
                                      });
                                    },
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        color:
                                            Color(0xFF916B44), // กรอบสีน้ำตาล
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  );
                                }).toList(),
                              ),

                            if (tempSelected.isNotEmpty)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () async {
                                    final confirm =
                                        await confirmDeleteSpecialDialog(
                                            context);
                                    if (!confirm)
                                      return; // ถ้าไม่ยืนยัน ให้หยุดการทำงาน

                                    for (final item in tempSelected) {
                                      await deleteSpecialByObject(item);
                                    }

                                    setState(() {
                                      selectedSpecialty.removeWhere((item) =>
                                          tempSelected.contains(item));
                                    });

                                    tempSelected.clear();
                                    Navigator.pop(context); // ปิด modal
                                  },
                                  icon: Icon(Icons.delete_forever,
                                      color: Colors.red),
                                  label: Text('ลบทั้งหมด',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ),
                            SizedBox(height: 10),

                            // Search Field
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF916B44).withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: searchController,
                                decoration: InputDecoration(
                                  hintText: 'ค้นหาความเชี่ยวชาญ',
                                  prefixIcon: Icon(Icons.search,
                                      color: Color(0xFF916B44)),
                                  suffixIcon: searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(Icons.clear,
                                              color: Color(0xFF916B44)),
                                          onPressed: () {
                                            searchController.clear();
                                            setModalState(() {
                                              filtered =
                                                  List.from(allSpecialties);
                                            });
                                          },
                                        )
                                      : null,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 16),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                onChanged: (value) {
                                  setModalState(() {
                                    filtered = allSpecialties
                                        .where((s) => s
                                            .toLowerCase()
                                            .contains(value.toLowerCase()))
                                        .toList();
                                  });
                                },
                              ),
                            ),
                            SizedBox(height: 20),

                            // List of specialties
                            Container(
                              constraints: BoxConstraints(maxHeight: 350),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF916B44).withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: filtered.isEmpty
                                    ? Container(
                                        height: 100,
                                        child: Center(
                                          child: Text(
                                            'ไม่พบความเชี่ยวชาญ',
                                            style: TextStyle(
                                              color: Color(0xFF916B44)
                                                  .withOpacity(0.6),
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      )
                                    : ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: filtered.length,
                                        itemBuilder: (context, index) {
                                          final item = filtered[index];
                                          final isSelected =
                                              tempSelected.contains(item);
                                          return item == "อื่นๆ"
                                              ? ListTile(
                                                  title: Text("อื่นๆ",
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xFF916B44),
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                  trailing: Icon(
                                                      Icons.arrow_forward_ios,
                                                      size: 16,
                                                      color: Color(0xFF916B44)),
                                                  onTap: () {
                                                    setModalState(() {
                                                      isOtherSelected = true;
                                                    });
                                                  },
                                                )
                                              : CheckboxListTile(
                                                  title: Text(item),
                                                  value: isSelected,
                                                  onChanged: (val) {
                                                    setModalState(() {
                                                      if (val == true) {
                                                        tempSelected.add(item);
                                                      } else {
                                                        tempSelected
                                                            .remove(item);
                                                      }
                                                    });
                                                  },
                                                  activeColor:
                                                      Color(0xFF916B44),
                                                );
                                        },
                                      ),
                              ),
                            ),
                            SizedBox(height: 20),

                            // Confirm Button
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        selectedSpecialty =
                                            List.from(tempSelected);
                                        log("selected: ${selectedSpecialty.join(',')}");
                                        log("temp: ${tempSelectSpecial.join(',')}");

                                        final a = Set.from(selectedSpecialty);
                                        final b = Set.from(tempSelectSpecial);

                                        final isChanged =
                                            a.length != b.length ||
                                                !a.containsAll(b);
                                        dataChange = isChanged;
                                      });
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF916B44),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text("ตกลง",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500)),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          // กรอกอื่นๆ
                          if (isOtherSelected) ...[
                            TextField(
                              controller: otherSpecialtyController,
                              decoration: InputDecoration(
                                hintText: 'กรอกความเชี่ยวชาญอื่นๆ',
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF916B44), // สีน้ำตาล
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color:
                                        Color(0xFF916B44), // สีน้ำตาลเหมือนกัน
                                    width: 2,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF916B44),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setModalState(() {
                                        isOtherSelected = false;
                                        otherSpecialtyController.clear();
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Color(0xFF916B44),
                                      side:
                                          BorderSide(color: Color(0xFF916B44)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text("ยกเลิก"),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      final other =
                                          otherSpecialtyController.text.trim();
                                      if (other.isNotEmpty) {
                                        setState(() {
                                          selectedSpecialty.add(other);
                                        });
                                        await specialAdd(other);
                                      }
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF916B44),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text("บันทึก"),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> getSpecialData() async {
    try {
      var res = await http.get(Uri.parse("$url/special/"));
      if (res.statusCode == 200) {
        var jsonData = json.decode(res.body);

        setState(() {
          special =
              (jsonData as List).map((e) => SpecialPost.fromJson(e)).toList();
        });

        for (var s in special) {
          // log(s.toString());
        }
      } else {
        log("Failed to load specialties: ${res.statusCode}");
      }
    } catch (e) {
      log("Error fetching specialties: $e");
    }
  }

  Future<void> getSearchSpecial(String careerNo) async {
    // log(careerNo);
    var res =
        await http.get(Uri.parse("$url/docspecial/search_doctorID/$careerNo"));
    if (res.statusCode == 200) {
      var jsonData = getSpecialDataPostFromJson(res.body);
      for (var data in jsonData) {
        // log("ชื่อสาขา: ${data.specialName}");
        // log("รหัสสาขา: ${data.specialId}");
      }
      setState(() {
        selectedSpecialty = jsonData.map((e) => e.specialName).toList();
        tempSelectSpecial = selectedSpecialty;
      });
    } else {
      log("Failed to load specialties: ${res.statusCode}");
    }
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Future<void> specialAdd(String selectedSpecialty) async {
    SpecialPost req = SpecialPost(
      name: selectedSpecialty,
      specialId: 0,
    );

    final res = await http.post(
      Uri.parse("$url/special"),
      headers: {"Content-Type": "application/json; charset=utf-8"},
      body: specialPostToJson([req]),
    );

    // log("STATUS: ${res.statusCode}");
    // log("BODY: ${res.body}");
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

      await supabase.storage.from('doctor-image').remove([imagePath]);

      // Upload to Supabase Storage
      final storageResponse = await Supabase.instance.client.storage
          .from('doctor-image') // Use your actual bucket name here
          .uploadBinary(fileName, fileBytes,
              fileOptions: const FileOptions(upsert: true));

      if (storageResponse.isEmpty) {
        log('Upload failed.');
        return;
      }

      // Get the public URL
      final publicUrl = Supabase.instance.client.storage
          .from('doctor-image')
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
                dataChange = true;
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
}
