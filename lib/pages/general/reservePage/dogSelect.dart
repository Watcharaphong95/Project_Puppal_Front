import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/model/reserveDogList.dart';
import 'package:puppal_application/model/reserveDogListPostReq.dart';
import 'package:puppal_application/pages/general/reservePage/clinicSearch.dart';
import 'package:shimmer/shimmer.dart';

class DogselectPage extends StatefulWidget {
  final DateTime date;

  const DogselectPage({super.key, required this.date});

  @override
  State<DogselectPage> createState() => _DogselectPageState();
}

class _DogselectPageState extends State<DogselectPage> {
  late double screenWidth;
  late double screenHeight;
  final box = GetStorage();

  bool isLoading = true;

  String url = '';

  List<ReserveDoglist> dogs = [];
  List<ReserveDoglist> filterDogs = [];

  TextEditingController searchDogCtl = TextEditingController();

  @override
  void initState() {
    log(widget.date.toString());
    init();
    super.initState();
  }

  void init() async {
    await Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
    });
    await getDogData();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF916B44),
        ),
        body: Container(
          child: isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xFFDBA871)),
                      SizedBox(height: 16),
                      Text(
                        'กำลังโหลดข้อมูลสุนัข...',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.grey.shade50,
                        Colors.white,
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      // Search Header Section
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'เลือกสุนัขของคุณ',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFDBA871),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'เลือกสุนัขที่ต้องการจองฉีดวัคซีน',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(height: 16),

                            // Search Bar
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: TextField(
                                controller: searchDogCtl,
                                onChanged: (value) {
                                  setState(() {
                                    if (value.isEmpty) {
                                      filterDogs = dogs;
                                    } else {
                                      filterDogs = dogs.where((dog) {
                                        return dog.name
                                            .toLowerCase()
                                            .contains(value.toLowerCase());
                                      }).toList();
                                    }
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'ค้นหาชื่อสุนัข...',
                                  hintStyle:
                                      TextStyle(color: Colors.grey.shade500),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  prefixIcon: Container(
                                    padding: EdgeInsets.all(12),
                                    child: Icon(
                                      FontAwesomeIcons.magnifyingGlass,
                                      color: Color(0xFFDBA871),
                                      size: 20,
                                    ),
                                  ),
                                  suffixIcon: searchDogCtl.text.isNotEmpty
                                      ? Container(
                                          margin: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade300,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.clear,
                                              color: Colors.grey.shade600,
                                              size: 18,
                                            ),
                                            onPressed: () {
                                              searchDogCtl.clear();
                                              FocusScope.of(context).unfocus();
                                              setState(() {
                                                filterDogs =
                                                    List<ReserveDoglist>.from(
                                                        dogs);
                                              });
                                            },
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Content Section
                      Expanded(
                        child: isLoading
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                        color: Color(0xFFDBA871)),
                                    SizedBox(height: 16),
                                    Text(
                                      'กำลังค้นหา...',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : filterDogs.isEmpty
                                ? _buildEmptyState()
                                : _buildDogList(),
                      ),
                    ],
                  ),
                ),
        ));
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              FontAwesomeIcons.dog,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'ยังไม่มีสุนัขที่ลงทะเบียน',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Text(
            'เพิ่มข้อมูลสุนัขของคุณเพื่อเริ่มจองฉีดวัคซีน',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFDBA871).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'กดปุ่ม ',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFFDBA871),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    FontAwesomeIcons.plus,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                Text(
                  ' ด้านบนเพื่อเพิ่มสุนัข',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Dog List Widget
  Widget _buildDogList() {
    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: filterDogs.length,
      itemBuilder: (context, index) {
        final dog = filterDogs[index];
        final isBooked = dog.status == 0;

        return Container(
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isBooked
                  ? null
                  : () {
                      Get.to(() => ClinicsearchPage(
                            dogId: dog.dogId,
                            vaccineName: '',
                            date: widget.date,
                            aid: 0,
                          ));
                    },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Dog Image
                    Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              dog.image,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Shimmer.fromColors(
                                  baseColor: Colors.grey.shade300,
                                  highlightColor: Colors.grey.shade100,
                                  child: Container(color: Colors.white),
                                );
                              },
                            ),
                          ),
                        ),

                        // Booking Status Overlay
                        if (isBooked)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'จองแล้ว',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    SizedBox(width: 16),

                    // Dog Information
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dog.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isBooked
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade800,
                            ),
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.cake,
                                size: 16,
                                color: Colors.grey.shade500,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'อายุ ${getDogAge(dog.birthday)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.grey.shade500,
                              ),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'วันเกิด ${DateFormat('d MMM y', 'th').format(DateTime.parse(dog.birthday).toLocal())}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Action Button
                    if (!isBooked)
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xFFDBA871),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFDBA871).withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 20,
                        ),
                      )
                    else
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> getDogData() async {
    ReserveDoglistReq req = ReserveDoglistReq(
        email: box.read('email'), date: widget.date.toString());

    var res = await http.post(
      Uri.parse("$url/reserve/doglist"),
      headers: {"Content-Type": "application/json; charset=utf-8"},
      body: reserveDoglistReqToJson(req),
    );

    if (res.statusCode == 200) {
      var jsonData = json.decode(res.body);
      dogs = jsonData
          .map<ReserveDoglist>((e) => ReserveDoglist.fromJson(e))
          .toList();
      filterDogs = List<ReserveDoglist>.from(dogs);
      // log(res.body);
    }
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
}
