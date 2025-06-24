import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/model/dogsGetEmail.dart';
import 'package:readmore/readmore.dart';
import 'package:shimmer/shimmer.dart';

class ClinicsearchPage extends StatefulWidget {
  final int dogId;
  final String vaccineName;
  const ClinicsearchPage(
      {super.key, required this.dogId, required this.vaccineName});

  @override
  State<ClinicsearchPage> createState() => _ClinicsearchPageState();
}

class _ClinicsearchPageState extends State<ClinicsearchPage> {
  late double screenWidth;
  late double screenHeight;
  final box = GetStorage();

  List<DogsGetEmail> dog = [];

  bool _loadingData = true;

  String url = '';

  Map<String, String> vaccineNameMap = {
    '1': 'วัคซีนรวม 5 โรค (DHPPiL)',
    '2': 'วัคซีนพิษสุนัขบ้า',
    '3': 'วัคซีนป้องกันโรคไข้ฉี่หนู',
    '4': 'วัคซีนป้องกันเชื้อ Bordetella bronchiseptica',
    '5': 'วัคซีนป้องกันโรคลายม์',
    '6': 'วัคซีนป้องกันเชื้อโคโรนาไวรัส',
    '7': 'วัคซีนถ่ายพยาธิ',
  };

  @override
  void initState() {
    // TODO: implement initState
    log(widget.dogId.toString());
    log(widget.vaccineName);
    init();
    super.initState();
  }

  void init() async {
    await Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
    });
    await getDogData();
    setState(() {
      _loadingData = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF916B44),
      ),
      body: _loadingData
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: SizedBox(
                width: screenWidth,
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              dog[0].image,
                              width: screenWidth * 0.45,
                              height: screenHeight * 0.225,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                return Shimmer.fromColors(
                                  baseColor: Colors.grey.shade300,
                                  highlightColor: Colors.grey.shade100,
                                  child: Container(
                                    width: screenWidth * 0.2,
                                    height: screenHeight * 0.1,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Container(
                          width: screenWidth * 0.7,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 250, 200, 150),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(2, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                dog[0].name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'อายุ ${getDogAge(dog[0].birthday)}',
                                style: const TextStyle(fontSize: 15),
                              ),
                              const SizedBox(height: 4),
                              ReadMoreText(
                                widget.vaccineName
                                    .split(',')
                                    .map((e) => '• ${e.trim()}')
                                    .join('\n'),
                                trimMode: TrimMode.Line,
                                trimLines: 3,
                                colorClickableText: Colors.transparent,
                                trimCollapsedText: 'แสดงเพิ่มเติม',
                                trimExpandedText: '\n\nย่อข้อความ',
                                style: const TextStyle(fontSize: 15),
                                moreStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                                lessStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }

  String getDogAge(String birthday) {
    DateTime birthDate = DateTime.parse(birthday).toLocal();
    DateTime today = DateTime.now();

    int ageInDays = today.difference(birthDate).inDays;
    int ageInWeeks = ageInDays ~/ 7;

    // Show weeks if less than 12 weeks old
    if (ageInWeeks < 12) {
      return '$ageInWeeks สัปดาห์';
    }

    int years = today.year - birthDate.year;
    int months = today.month - birthDate.month;

    if (today.day < birthDate.day) {
      months -= 1;
    }
    if (months < 0) {
      years -= 1;
      months += 12;
    }

    if (years > 0 && months > 0) {
      return '$years ปี $months เดือน';
    } else if (years > 0) {
      return '$years ปี';
    } else {
      return '$months เดือน';
    }
  }

  Future<void> getDogData() async {
    var res =
        await http.get(Uri.parse("$url/dog/data/${widget.dogId.toString()}"));
    if (res.statusCode == 200) {
      var jsonData = json.decode(res.body);
      dog =
          jsonData.map<DogsGetEmail>((e) => DogsGetEmail.fromJson(e)).toList();

      log(dog[0].name);
    }
  }
}
