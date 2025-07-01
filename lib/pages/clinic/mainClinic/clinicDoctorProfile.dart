import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/model/doctorPost.dart';
import 'package:puppal_application/model/seacrhspecialPost.dart';
import 'package:puppal_application/model/specialPost.dart';
import 'package:puppal_application/pages/clinic/mainClinic/addDoctors/clinicAddDoctor.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicDoctorEditProfile.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicListDoctors.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicMain.dart';
import 'package:puppal_application/pages/clinic/mainClinic/reserve/vaccineRequestsPage.dart';
import 'package:puppal_application/pages/login/index.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class Clinicdoctorprofile extends StatefulWidget {
  final String? name;
  const Clinicdoctorprofile({super.key, this.name});

  @override
  State<Clinicdoctorprofile> createState() => _ClinicdoctorprofileState();
}

class _ClinicdoctorprofileState extends State<Clinicdoctorprofile> {
  late double screenWidth;
  late double screenHeight;
  final box = GetStorage();
  String url = "";
  List<DoctorPost> doctorsList = [];
  bool isLoading = true;
  List<String> selectedSpecialty = [];
  List<SpecialPost> special = [];

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
      searcheDoctor(this.widget.name ?? '');
      getSpecialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        drawer: Drawer(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/indexBg.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Color(0xFF916b44),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipOval(
                          child: Image.network(
                            box.read('clinicImage'),
                            width: screenWidth * 0.2,
                            height: screenWidth * 0.2,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: screenWidth * 0.2,
                                  height: screenWidth * 0.2,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          box.read('clinicName') ?? "ผู้ใช้งาน",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.home, color: Color(0xFF916b44)),
                    title: Text('หน้าหลัก'),
                    onTap: () {
                      Get.to(() => ClinicmainPage());
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.system_security_update,
                        color: Color(0xFF916b44)),
                    title: Text('คำขอฉีดยา'),
                    onTap: () {
                      Get.to(() => VaccineRequestsPage());
                    },
                  ),
                  ListTile(
                    leading:
                        Icon(Icons.medical_services, color: Color(0xFF916b44)),
                    title: Text('ประวัติการฉีดยา'),
                  ),
                  ListTile(
                    leading: Icon(Icons.supervised_user_circle,
                        color: Color(0xFF916b44)),
                    title: Text('หมอประจำคลินิก'),
                    onTap: () {
                      Get.to(() => Cliniclistdoctors());
                    },
                  ),
                  ListTile(
                    leading:
                        Icon(Icons.medical_services, color: Color(0xFF916b44)),
                    title: Text('เวลาปิด-เปิด'),
                  ),
                  ListTile(
                    leading: Icon(Icons.settings, color: Color(0xFF916b44)),
                    title: Text('ตั้งค่า'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.redAccent),
                    title: Text('ออกจากระบบ'),
                    onTap: () {
                      showAlert(
                        context: context,
                        title: 'ออกจากระบบ?',
                        message: 'คุณต้องการออกจากระบบใช่หรือไม่',
                        onConfirm: () {
                          box.erase();
                          Get.to(() => IndexPage());
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(),
            child: Column(
              children: doctorsList.map((doctor) {
                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                child: doctor.image.isNotEmpty
                                    ? Image.network(
                                        doctor.image,
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
                            // Name Field
                            _buildInfoField(
                              icon: Icons.person,
                              label: 'ชื่อ',
                              value: doctor.name,
                              screenHeight: screenHeight,
                            ),

                            const SizedBox(height: 20),

                            // Surname Field
                            _buildInfoField(
                              icon: Icons.badge,
                              label: 'นามสกุล',
                              value: doctor.surname,
                              screenHeight: screenHeight,
                            ),

                            const SizedBox(height: 20),

                            // Specialty Field
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color:
                                            Color(0xFFE9CBAF).withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(8),
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
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'ความเชี่ยวชาญ',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF916B44),
                                            ),
                                          ),
                                          Text(
                                            '(เช่น การผ่าตัด, การรักษาด้วยยา)',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
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
                                  borderRadius: BorderRadius.circular(12),
                                  child: InkWell(
                                    // onTap: _showSelectSpecialty,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color:
                                            Color(0xFFE9CBAF).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
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
                                              selectedSpecialty.isEmpty
                                                  ? 'เลือกความเชี่ยวชาญ'
                                                  : selectedSpecialty
                                                      .toSet()
                                                      .map((e) => e.toString())
                                                      .join(', '),
                                              style: TextStyle(
                                                color: selectedSpecialty.isEmpty
                                                    ? Colors.grey[600]
                                                    : Color(0xFF916B44),
                                                fontSize: 16,
                                                fontWeight:
                                                    selectedSpecialty.isEmpty
                                                        ? FontWeight.normal
                                                        : FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_drop_down,
                                            color: Color(0xFF916B44),
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
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.to(() =>
                                Clinicdoctoreditprofile(name: doctor.name));
                          },
                          icon: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 22,
                          ),
                          label: Text(
                            "แก้ไขข้อมูล",
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
        ));
  }

  Widget _buildInfoField({
    required IconData icon,
    required String label,
    required String value,
    required double screenHeight,
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
              enabled: false,
              controller: TextEditingController(text: value),
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

  List<DoctorPost> doctorPostFromJson(String str) => List<DoctorPost>.from(
      json.decode(str).map((x) => DoctorPost.fromJson(x)));

  Future<void> searcheDoctor(name) async {
    final keyword = name.trim();
    log("Keyword: $keyword");
    if (keyword.isEmpty) return;

    try {
      final res = await http
          .get(Uri.parse("$url/doctor/searche/${box.read('email')}/$keyword"));
      if (res.statusCode == 200) {
        final data =
            doctorPostFromJson(res.body); // แปลง JSON → List<DoctorPost>

        for (var doctor in data) {
          // log("ชื่อหมอ: ${doctor.name}");
          log(doctor.careerNo);
          // getSearchSpecial(doctor.careerNo);
        }
        setState(() {
          doctorsList = data;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
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
                                                      } else {
                                                        selectedSpecialty
                                                            .remove(item);
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
