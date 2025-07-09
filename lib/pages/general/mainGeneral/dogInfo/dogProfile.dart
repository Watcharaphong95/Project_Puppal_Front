import 'dart:convert';
import 'dart:developer';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/model/dogsGetEmail.dart';

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

  bool _loadingData = true;

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
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: Color(0xFF916B44)),
        body: _loadingData
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
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
                                // onTap: _showSelectBreed,
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
                                // onTap: _showSelectGender,
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
                                  // _showDatePicker(context);
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
                                // onTap: _showSelectSterilization,
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
                                    // dogRegisterNextButton
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
                                  onPressed: () {
                                    // dogRegisterNextButton
                                  },
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

  Future<void> getDogData() async {
    var res = await http.get(Uri.parse("$url/dog/data/${widget.dogId}"));
    if (res.statusCode == 200) {
      var jsonData = json.decode(res.body);
      dog =
          jsonData.map<DogsGetEmail>((e) => DogsGetEmail.fromJson(e)).toList();

      nameCtl.text = dog[0].name;
      breedCtl.text = dog[0].breed;
      genderCtl.text = dog[0].gender;
      colorCtl.text = dog[0].color;
      hairCtl.text = dog[0].hair;
      defectCtl.text = dog[0].defect;
      birthdayCtl.text = dog[0].birthday;
      diseaseCtl.text = dog[0].congentialDisease;
      sterilizationCtl.text = dog[0].sterilization.toString();
      // log(dog[0].name);
    }
  }
}
