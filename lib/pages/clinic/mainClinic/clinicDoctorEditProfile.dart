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
import 'package:puppal_application/pages/login/index.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class Clinicdoctoreditprofile extends StatefulWidget {
  final String? name;
  const Clinicdoctoreditprofile({super.key, this.name});

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
  List<SpecialPost> special = [];
  List<GetDocSpecialIdPost> docSpecialList = [];
  List<String> unselectedSpecialties = [];

  File? _imageFile;

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
      searcheDoctor(this.widget.name ?? '');
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
            ? SizedBox(
                child: Center(child: CircularProgressIndicator()),
              )
            : SingleChildScrollView(
                child: Column(
                  children: doctorsList.map((doctor) {
                    return Column(
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(),
                          child: Column(
                            children: doctorsList.map((doctor) {
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
                                          // Profile Image with Pet Border + Add Icon
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  blurRadius: 10,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                            child: Stack(
                                              children: [
                                                ClipOval(
                                                  child: _imageFile != null
                                                      ? Image.file(
                                                          File(
                                                              _imageFile!.path),
                                                          height: 120,
                                                          width: 120,
                                                          fit: BoxFit.cover,
                                                        )
                                                      : (doctor.image.isNotEmpty
                                                          ? Image.network(
                                                              doctor.image,
                                                              height: 120,
                                                              width: 120,
                                                              fit: BoxFit.cover,
                                                              loadingBuilder:
                                                                  (context,
                                                                      child,
                                                                      loadingProgress) {
                                                                if (loadingProgress ==
                                                                    null)
                                                                  return child;
                                                                return Shimmer
                                                                    .fromColors(
                                                                  baseColor: Color(
                                                                      0xFFE9CBAF),
                                                                  highlightColor:
                                                                      Colors
                                                                          .white,
                                                                  child:
                                                                      Container(
                                                                    width: 120,
                                                                    height: 120,
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      color: Colors
                                                                          .white,
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              errorBuilder:
                                                                  (context,
                                                                          error,
                                                                          stackTrace) =>
                                                                      Container(
                                                                width: 120,
                                                                height: 120,
                                                                decoration:
                                                                    const BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                                child:
                                                                    const Icon(
                                                                  Icons.pets,
                                                                  size: 50,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                            )
                                                          : Container(
                                                              width: 120,
                                                              height: 120,
                                                              decoration:
                                                                  const BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                              child: const Icon(
                                                                Icons.pets,
                                                                size: 50,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            )),
                                                ),
                                                Positioned(
                                                  bottom: 0,
                                                  right: 0,
                                                  child: Material(
                                                    color: Colors.transparent,
                                                    shape: CircleBorder(),
                                                    child: InkWell(
                                                      onTap: () {
                                                        _pickImage(); // ✅ ใส่ฟังก์ชันเลือกรูปที่คุณใช้อยู่
                                                      },
                                                      customBorder:
                                                          CircleBorder(),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color:
                                                              Color(0xFF795548),
                                                        ),
                                                        padding:
                                                            EdgeInsets.all(4),
                                                        child: Icon(
                                                          Icons.add,
                                                          color: Colors.white,
                                                          size: 24,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 15),
                                          // Veterinarian Badge
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.9),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.medical_services,
                                                    color: Color(0xFF916B44),
                                                    size: 25),
                                                const SizedBox(width: 8),
                                                Text(
                                                  doctor.careerNo,
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
                                            color: Color(0xFFDBA871)
                                                .withOpacity(0.2),
                                            offset: const Offset(0, 6),
                                            blurRadius: 16,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Name Field
                                          _buildInfoField(
                                            icon: Icons.person,
                                            label: 'ชื่อ',
                                            value: nameCtl.text,
                                            controller: nameCtl,
                                            screenHeight: screenHeight,
                                          ),

                                          const SizedBox(height: 20),

                                          // Surname Field
                                          _buildInfoField(
                                            icon: Icons.badge,
                                            label: 'นามสกุล',
                                            controller: surnameCtl,
                                            value: surnameCtl.text,
                                            screenHeight: screenHeight,
                                          ),

                                          const SizedBox(height: 20),

                                          // Specialty Field
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFFE9CBAF)
                                                          .withOpacity(0.3),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Icon(
                                                      Icons.star,
                                                      color: Color(0xFF916B44),
                                                      size: 20,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'ความเชี่ยวชาญ',
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Color(
                                                                0xFF916B44),
                                                          ),
                                                        ),
                                                        Text(
                                                          '(เช่น การผ่าตัด, การรักษาด้วยยา)',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors
                                                                .grey[600],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              Material(
                                                elevation: 2,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: InkWell(
                                                  onTap: _showSelectSpecialty,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16),
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFFE9CBAF)
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      border: Border.all(
                                                        color: Color(0xFFDBA871)
                                                            .withOpacity(0.5),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            selectedSpecialty
                                                                    .isEmpty
                                                                ? 'เลือกความเชี่ยวชาญ'
                                                                : selectedSpecialty
                                                                    .toSet()
                                                                    .map((e) =>
                                                                        e.toString())
                                                                    .join(', '),
                                                            style: TextStyle(
                                                              color: selectedSpecialty
                                                                      .isEmpty
                                                                  ? Colors
                                                                      .grey[600]
                                                                  : Color(
                                                                      0xFF916B44),
                                                              fontSize: 16,
                                                              fontWeight: selectedSpecialty
                                                                      .isEmpty
                                                                  ? FontWeight
                                                                      .normal
                                                                  : FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                        Icon(
                                                          Icons.arrow_drop_down,
                                                          color:
                                                              Color(0xFF916B44),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 30),

                                    // Edit Button with Pet Theme
                                    Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 24),
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          // updatedataDoctor(doctor.careerNo);
                                          showAlert(
                                              title: 'ต้องการบันทึกข้อมูล?',
                                              message: 'ข้อมูลเก่าจะถูกลบถาวร',
                                              onConfirm: () {
                                                updatedataDoctor(
                                                    doctor.careerNo);
                                              },
                                              context: context);
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
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          elevation: 8,
                                          shadowColor: Color(0xFF916B44)
                                              .withOpacity(0.4),
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
                      ],
                    );
                  }).toList(),
                ),
              ));
  }

  List<DoctorPost> doctorPostFromJson(String str) => List<DoctorPost>.from(
      json.decode(str).map((x) => DoctorPost.fromJson(x)));

  Future<void> searcheDoctor(name) async {
    showLoadingDialog();

    final keyword = name.trim();
    // log("Keyword: $keyword");
    if (keyword.isEmpty) return;

    try {
      final res = await http
          .get(Uri.parse("$url/doctor/searche/${box.read('email')}/$keyword"));
      if (res.statusCode == 200) {
        final data = doctorPostFromJson(res.body);
        for (var doctor in data) {
          // log("ชื่อหมอ: ${doctor.name}");
          // log(doctor.careerNo);
          updatedataDoctor(doctor.careerNo);
          getSearchSpecial(doctor.careerNo);
          if (data.isNotEmpty) {
            nameCtl.text = data[0].name;
            surnameCtl.text = data[0].surname;
            imageCtl.text = data[0].image;
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
    Get.back();
    showAlertNoClose(
      title: 'อัพเดทเสร็จสิ้น',
      message: 'อัพเดทข้อมูลหมอเรียบร้อยแล้ว',
    );
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
  }) {
    Get.defaultDialog(
      title: '',
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.all(16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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

          // Single confirm button
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: () {
                Get.back();
                Get.back();
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

  void _showSelectSpecialty() {
    TextEditingController searchController = TextEditingController();
    TextEditingController otherSpecialtyController = TextEditingController();
    List<String> allSpecialties = [...special.map((s) => s.name), "อื่นๆ"];
    List<String> filtered = List<String>.from(allSpecialties);

    bool isOtherSelected = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 16),
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
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (!isOtherSelected)
                            TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                hintText: 'ค้นหาความเชี่ยวชาญ',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: Icon(Icons.search),
                                suffixIcon: searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(Icons.clear),
                                        onPressed: () {
                                          searchController.clear();
                                          setModalState(() {
                                            filtered = List<String>.from(
                                                allSpecialties);
                                          });
                                        },
                                      )
                                    : null,
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
                          SizedBox(height: 16),
                          if (!isOtherSelected)
                            ConstrainedBox(
                              constraints: BoxConstraints(maxHeight: 300),
                              child: filtered.isEmpty
                                  ? Center(child: Text('ไม่พบความเชี่ยวชาญ'))
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: filtered.length,
                                      itemBuilder: (context, index) {
                                        final item = filtered[index];

                                        return Card(
                                          child: item == "อื่นๆ"
                                              ? ListTile(
                                                  title: Text("อื่นๆ"),
                                                  trailing: Icon(
                                                      Icons.arrow_forward_ios),
                                                  onTap: () {
                                                    setModalState(() {
                                                      isOtherSelected = true;
                                                    });
                                                  },
                                                )
                                              : CheckboxListTile(
                                                  title: Text(item),
                                                  value: selectedSpecialty
                                                      .contains(item),
                                                  onChanged: (bool? selected) {
                                                    setModalState(() {
                                                      if (selected == true) {
                                                        selectedSpecialty
                                                            .add(item);
                                                        unselectedSpecialties
                                                            .remove(item);
                                                        log(unselectedSpecialties
                                                            .toString());
                                                      } else {
                                                        selectedSpecialty
                                                            .remove(item);
                                                        if (!unselectedSpecialties
                                                            .contains(item)) {
                                                          unselectedSpecialties
                                                              .add(item);
                                                          log(unselectedSpecialties
                                                              .toString());
                                                        }
                                                      }
                                                    });
                                                  },
                                                ),
                                        );
                                      },
                                    ),
                            ),
                          // ignore: dead_code
                          if (isOtherSelected) ...[
                            TextField(
                              controller: otherSpecialtyController,
                              decoration: InputDecoration(
                                hintText: 'กรอกความเชี่ยวชาญอื่นๆ',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () async {
                                if (isOtherSelected &&
                                    otherSpecialtyController.text
                                        .trim()
                                        .isNotEmpty) {
                                  selectedSpecialty.add(
                                      otherSpecialtyController.text.trim());
                                  await specialAdd(
                                      otherSpecialtyController.text.trim());
                                }

                                setState(() {
                                  selectedSpecialty =
                                      List.from(selectedSpecialty);
                                });

                                Navigator.pop(context);
                              },
                              child: Text("ยืนยัน"),
                            ),
                          ],
                        ],
                      ),
                    ),
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
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFF3F3),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF795548),
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.black87),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style:
                TextButton.styleFrom(foregroundColor: const Color(0xFF795548)),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (onConfirm != null) onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF795548),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }
}
