import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/controller/registerDoctorCtl.dart';
import 'package:puppal_application/model/specialPost.dart';
import 'package:puppal_application/pages/clinic/registerClinic/doctor/registerDoctorAvatar.dart';
import 'package:http/http.dart' as http;

class RegisterdocterPage extends StatefulWidget {
  const RegisterdocterPage({super.key});

  @override
  State<RegisterdocterPage> createState() => _RegisterdocterPageState();
}

class _RegisterdocterPageState extends State<RegisterdocterPage> {
  late double screenWidth;
  late double screenHeight;

  String url = "";

  final controller = Get.find<registerDoctorCtl>();

  TextEditingController nameCtl = TextEditingController();
  TextEditingController surnameCtl = TextEditingController();
  TextEditingController careerNoCtl = TextEditingController();
  // TextEditingController specialNoCtl = TextEditingController();

  List<SpecialPost> special = [];
  List<String> selectedSpecialty = [];

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
      getSpecialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'เพิ่มหมอ',
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: SizedBox(
            height: screenHeight * 0.85,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
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
                          'นามสกุล',
                          style: TextStyle(fontSize: 20),
                        ),
                        Material(
                          elevation: 5,
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            height: screenHeight * 0.055,
                            child: TextField(
                              controller: surnameCtl,
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
                              'ความเชี่ยวชาญ',
                              style: TextStyle(fontSize: 20),
                            ),
                            Text(
                              '(เช่น ผ่าตัด, ยา)',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.grey),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Material(
                          elevation: 5,
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                              onTap: _showSelectSpecialty,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                height: screenHeight * 0.055,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  selectedSpecialty.isEmpty
                                      ? 'เลือกความเชี่ยวชาญ'
                                      : selectedSpecialty.join(', '),
                                  style: TextStyle(
                                    color: selectedSpecialty.isEmpty
                                        ? Colors.grey
                                        : Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              )),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'เลขใบอนุญาตประกอบวิชาชีพ',
                          style: TextStyle(fontSize: 20),
                        ),
                        Material(
                          elevation: 5,
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            height: screenHeight * 0.055,
                            child: TextField(
                              controller: careerNoCtl,
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
                        onPressed: doctorAddNextButton,
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
      ),
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
          log(s.toString());
        }
      } else {
        print("Failed to load specialties: ${res.statusCode}");
      }
    } catch (e) {
      print("Error fetching specialties: $e");
    }
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

  void _showSelectSpecialty() {
    TextEditingController searchController = TextEditingController();
    TextEditingController otherSpecialtyController = TextEditingController();
    List<String> allSpecialties = [...special.map((s) => s.name), "อื่นๆ"];
    List<String> filtered = List<String>.from(allSpecialties);

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
                // color: Color(0xFFE9CBAF),
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 16),
                      // Handle Bar
                      Container(
                        width: 50,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Color(0xFF916B44).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Header
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
                            // Search Field
                            if (!isOtherSelected)
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
                                    hintStyle: TextStyle(
                                      color: Color(0xFF916B44).withOpacity(0.5),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: Color(0xFF916B44),
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: Color(0xFF916B44),
                                    ),
                                    suffixIcon: searchController.text.isNotEmpty
                                        ? IconButton(
                                            icon: Icon(
                                              Icons.clear,
                                              color: Color(0xFF916B44),
                                            ),
                                            onPressed: () {
                                              searchController.clear();
                                              setModalState(() {
                                                filtered = List<String>.from(
                                                    allSpecialties);
                                              });
                                            },
                                          )
                                        : null,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
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

                            // List Container
                            if (!isOtherSelected)
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
                                          padding: EdgeInsets.zero,
                                          itemCount: filtered.length,
                                          itemBuilder: (context, index) {
                                            final item = filtered[index];
                                            bool isSelected = selectedSpecialty
                                                .contains(item);

                                            return Container(
                                              margin: EdgeInsets.only(
                                                top: index == 0 ? 8 : 0,
                                                bottom:
                                                    index == filtered.length - 1
                                                        ? 8
                                                        : 0,
                                              ),
                                              child: item == "อื่นๆ"
                                                  ? Container(
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Color(0xFFDBA871)
                                                            .withOpacity(0.3),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: ListTile(
                                                        title: Text(
                                                          "อื่นๆ",
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xFF916B44),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        trailing: Icon(
                                                          Icons
                                                              .arrow_forward_ios,
                                                          color:
                                                              Color(0xFF916B44),
                                                          size: 16,
                                                        ),
                                                        onTap: () {
                                                          setModalState(() {
                                                            isOtherSelected =
                                                                true;
                                                          });
                                                        },
                                                      ),
                                                    )
                                                  : Container(
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: isSelected
                                                            ? Color(0xFFDBA871)
                                                                .withOpacity(
                                                                    0.2)
                                                            : Colors
                                                                .transparent,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        border: isSelected
                                                            ? Border.all(
                                                                color: Color(
                                                                        0xFF916B44)
                                                                    .withOpacity(
                                                                        0.3),
                                                                width: 1,
                                                              )
                                                            : null,
                                                      ),
                                                      child: CheckboxListTile(
                                                        title: Text(
                                                          item,
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xFF916B44),
                                                            fontWeight:
                                                                isSelected
                                                                    ? FontWeight
                                                                        .w500
                                                                    : FontWeight
                                                                        .w400,
                                                          ),
                                                        ),
                                                        value: isSelected,
                                                        activeColor:
                                                            Color(0xFF916B44),
                                                        checkColor:
                                                            Colors.white,
                                                        onChanged:
                                                            (bool? selected) {
                                                          setModalState(() {
                                                            if (selected ==
                                                                true) {
                                                              selectedSpecialty
                                                                  .add(item);
                                                            } else {
                                                              selectedSpecialty
                                                                  .remove(item);
                                                            }
                                                          });
                                                        },
                                                      ),
                                                    ),
                                            );
                                          },
                                        ),
                                ),
                              ),

                            // Other Specialty Input
                            if (isOtherSelected) ...[
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
                                  controller: otherSpecialtyController,
                                  decoration: InputDecoration(
                                    hintText: 'กรอกความเชี่ยวชาญอื่นๆ',
                                    hintStyle: TextStyle(
                                      color: Color(0xFF916B44).withOpacity(0.5),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: Color(0xFF916B44),
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),

                              // Action Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 48,
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
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            side: BorderSide(
                                              color: Color(0xFF916B44),
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          "ยกเลิก",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Container(
                                      height: 48,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          if (isOtherSelected &&
                                              otherSpecialtyController.text
                                                  .trim()
                                                  .isNotEmpty) {
                                            selectedSpecialty.add(
                                                otherSpecialtyController.text
                                                    .trim());
                                            await specialAdd(
                                                otherSpecialtyController.text
                                                    .trim());
                                          }

                                          setState(() {
                                            selectedSpecialty =
                                                List.from(selectedSpecialty);
                                          });

                                          Navigator.pop(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF916B44),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: Text(
                                          "บันทึก",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
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
              ),
            );
          },
        );
      },
    );
  }

  Future<void> doctorAddNextButton() async {
    if (nameCtl.text.trim().isEmpty ||
        surnameCtl.text.trim().isEmpty ||
        selectedSpecialty == null ||
        careerNoCtl.text.trim().isEmpty) {
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
    int? selectedSpecialId;

    onChanged:
    (value) {
      setState(() {
        selectedSpecialId =
            special.firstWhere((sp) => sp.name == value).specialId;
        selectedSpecialty = value;
      });
    };

    controller.name.value = nameCtl.text;
    controller.surname.value = surnameCtl.text;
    controller.special.value = selectedSpecialId?.toString() ?? '';
    controller.special.value = selectedSpecialty.join(', ');
    controller.careerNo.value = careerNoCtl.text;

    var res = await http.get(Uri.parse("$url/doctor/${careerNoCtl.text}"));

    if (res.statusCode == 200) {
      Get.snackbar(
        'ข้อผิดพลาด',
        'หมอคนนี้เคยเป็นสมาชิกของคลินิกอื่นแล้ว',
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
    } else {
      Get.to(() => RegisterdoctoravatarPage());
    }
  }
}
