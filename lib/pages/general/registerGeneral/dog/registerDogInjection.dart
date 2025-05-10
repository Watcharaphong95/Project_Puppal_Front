import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:puppal_application/controller/registerDogInjectionHistoryCtl.dart';
import 'package:puppal_application/model/injectionRecordPost.dart';
import 'package:puppal_application/pages/general/registerGeneral/dog/registerDogInjectionRecord.dart';

class RegisterdoginjectionPage extends StatefulWidget {
  const RegisterdoginjectionPage({super.key});

  @override
  State<RegisterdoginjectionPage> createState() =>
      _RegisterdoginjectionPageState();
}

class _RegisterdoginjectionPageState extends State<RegisterdoginjectionPage> {
  late double screenWidth;
  late double screenHeight;

  final dogInjecRecord = Get.find<RegisterDogInjectionCtl>();
  final recordList = Get.find<injectionRecordList>();

  TextEditingController clinicNameCtl = TextEditingController();
  TextEditingController vaccineTypeCtl = TextEditingController();
  TextEditingController vaccineTypeNameCtl = TextEditingController();
  TextEditingController dateCtl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('เพิ่มประวัติการฉีดยา'),
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
                        Row(
                          children: [
                            Text(
                              'ชื่อคลินิก',
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
                              controller: clinicNameCtl,
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
                          'วัคซีนที่ฉีด',
                          style: TextStyle(fontSize: 20),
                        ),
                        GestureDetector(
                          onTap: _showSelectVaccine,
                          child: Material(
                            elevation: 5,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              height: screenHeight * 0.065,
                              width: screenWidth,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      vaccineTypeNameCtl.text.isEmpty
                                          ? 'เลือกวัคซีนที่ฉีด'
                                          : vaccineTypeNameCtl.text,
                                      style: TextStyle(
                                          color: vaccineTypeNameCtl.text.isEmpty
                                              ? Colors.grey
                                              : Colors.black,
                                          overflow: TextOverflow.ellipsis,
                                          fontSize: 16),
                                      maxLines: 1,
                                    ),
                                  ),
                                  const Icon(FontAwesomeIcons.syringe),
                                ],
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
                          'วันที่ฉีด',
                          style: TextStyle(fontSize: 20),
                        ),
                        Material(
                          elevation: 5,
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            height: screenHeight * 0.055,
                            child: TextField(
                              controller: dateCtl,
                              readOnly: true,
                              onTap: () {
                                _showDatePicker(context);
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                hintText: 'เลือกวันที่ฉีดวัคซีน',
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
                        onPressed: recordAddNextButton,
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

  Future<void> recordAddNextButton() async {
    if (vaccineTypeNameCtl.text.trim().isEmpty || dateCtl.text.trim().isEmpty) {
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

    dogInjecRecord.clinicName.value = clinicNameCtl.text;
    dogInjecRecord.vaccineType.value = vaccineTypeCtl.text;
    dogInjecRecord.date.value = dateCtl.text;

    InjectionRecordPost newRecord = InjectionRecordPost(
        dogId: 0,
        clinicName: dogInjecRecord.clinicName.value,
        vaccineType: dogInjecRecord.vaccineType.value,
        date: dogInjecRecord.date.value);

    recordList.addRecord(newRecord);

    Get.to(() => RegisterdoginjectionrecordPage());
  }

  void _showSelectVaccine() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final List<Map<String, String>> dogVaccines = [
          {'name': 'วัคซีนรวม 5 โรค (DHPPiL)', 'id': '1'},
          {'name': 'วัคซีนพิษสุนัขบ้า', 'id': '2'},
          {'name': 'วัคซีนรวม 6 โรค (DHPPiL + Corona)', 'id': '3'},
          {'name': 'วัคซีนป้องกันโรคหลอดลมอักเสบ (Kennel Cough)', 'id': '4'},
          {'name': 'วัคซีนป้องกันโรคลายม์ (Lyme Disease)', 'id': '5'},
          {
            'name': 'วัคซีนป้องกันเชื้อโคโรนาไวรัสในสุนัข (Canine Coronavirus)',
            'id': '6'
          },
          {'name': 'วัคซีนป้องกันโรคพยาธิในลำไส้', 'id': '7'},
          {'name': 'วัคซีนป้องกันโรคพยาธิหัวใจ (Heartworm)', 'id': '8'},
          {'name': 'วัคซีนป้องกันโรคปอดบวม (Pneumonia)', 'id': '9'},
          {'name': 'วัคซีนป้องกันโรคหัดสุนัข (Canine Distemper)', 'id': '10'},
          {
            'name': 'วัคซีนป้องกันโรคไวรัสตับอักเสบ (Canine Adenovirus)',
            'id': '11'
          },
          {'name': 'วัคซีนป้องกันโรคไข้ทับทิม (Canine Parvovirus)', 'id': '12'},
          {'name': 'วัคซีนป้องกันโรคพยาธิในเลือด (Ehrlichiosis)', 'id': '13'},
        ];

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
                  'เลือกวัคซีนที่ฉีด',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF916b44),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: dogVaccines.map((vaccine) {
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Center(
                            child: Text(
                              textAlign: TextAlign.center,
                              vaccine['name']!,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF916b44),
                              ),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              vaccineTypeNameCtl.text = vaccine['name']!;
                              vaccineTypeCtl.text = vaccine['id']!;
                            });
                            log(vaccineTypeCtl.text);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
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
          String formattedDate = "${date.day}-${date.month}-${date.year}";
          dateCtl.text = formattedDate;
        });
      },
    );
  }
}
