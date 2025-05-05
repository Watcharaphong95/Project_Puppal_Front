import 'dart:developer';

import 'package:flutter/material.dart';
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

  TextEditingController nameCtl = TextEditingController();
  TextEditingController breedCtl = TextEditingController();
  TextEditingController genderCtl = TextEditingController();
  TextEditingController colorCtl = TextEditingController();
  TextEditingController defectCtl = TextEditingController();
  TextEditingController birthdayCtl = TextEditingController();
  TextEditingController diseaseCtl = TextEditingController();
  TextEditingController sterilizationCtl = TextEditingController();
  TextEditingController hairCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('ลงทะเบียนสุนัข'),
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
                        controller: breedCtl,
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
                    'เพศ',
                    style: TextStyle(fontSize: 20),
                  ),
                  Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(5),
                    child: SizedBox(
                      height: screenHeight * 0.055,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: DropdownButton<String>(
                          value:
                              genderCtl.text.isNotEmpty ? genderCtl.text : null,
                          hint: const Text(
                            'เลือกเพศ',
                            style: TextStyle(color: Colors.grey),
                          ),
                          isExpanded: true,
                          onChanged: (String? newValue) {
                            setState(() {
                              genderCtl.text = newValue ?? '';
                            });
                            log(genderCtl.text);
                          },
                          items: <String>['ชาย', 'หญิง']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
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
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                            locale: const Locale("th", "TH"),
                          );

                          if (pickedDate != null) {
                            String formattedDate =
                                "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                            birthdayCtl.text = formattedDate;
                          }
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'เลือกวันเกิด',
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
                    'ทำหมัน',
                    style: TextStyle(fontSize: 20),
                  ),
                  Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: screenHeight * 0.055,
                      child: DropdownButton<String>(
                        value: sterilizationCtl.text.isNotEmpty
                            ? sterilizationCtl.text
                            : null,
                        hint: const Text('เลือกสถานะทำหมัน'),
                        isExpanded: true,
                        onChanged: (String? newValue) {
                          setState(() {
                            sterilizationCtl.text = newValue ?? '';
                          });
                        },
                        items: <String>['ทำแล้ว', 'ยังไม่ทำ']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
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
}
