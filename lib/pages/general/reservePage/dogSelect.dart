import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/model/appointmentGetEmail.dart';
import 'package:puppal_application/model/fireStoreReserveGet.dart';
import 'package:puppal_application/model/reserveDogList.dart';
import 'package:puppal_application/model/reserveDogListPostReq.dart';
import 'package:puppal_application/pages/generalAppNavigator.dart';
import 'package:puppal_application/pages/general/reservePage/clinicSearch.dart';
import 'package:shimmer/shimmer.dart';

class DogselectPage extends StatefulWidget {
  final DateTime date;
  final Map<DateTime, List<Dog>> dogData;
  final List<int> dogHasAppointment;

  const DogselectPage({
    super.key,
    required this.date,
    required this.dogData,
    required this.dogHasAppointment,
  });

  @override
  State<DogselectPage> createState() => _DogselectPageState();
}

class _DogselectPageState extends State<DogselectPage> {
  late double screenWidth;
  late double screenHeight;
  final box = GetStorage();

  bool isLoading = true;

  String url = '';

  List<ReserveDoglist> allDogs = [];
  List<ReserveDoglist> filterDogs = [];

  TextEditingController searchDogCtl = TextEditingController();

  @override
  void initState() {
    log(widget.date.toString());
    // log(jsonEncode(widget.dogData.map((date, dogs) => MapEntry(
    //     date.toIso8601String(), dogs.map((d) => d.toJson()).toList()))));
    log('dogHasAppointment JSON: ${jsonEncode(widget.dogHasAppointment)}');
    init();
    super.initState();
  }

  void init() async {
    await Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
    });
    await getDogData();
    await addDogData(widget.dogData);
    filterDogs
        .removeWhere((dog) => widget.dogHasAppointment.contains(dog.dogId));
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        // appBar: AppBar(
        //   backgroundColor: Color(0xFFDBA871),
        //   centerTitle: true,
        //   title: Text(
        //     'เลือกสุนัข',
        //     style: TextStyle(
        //         fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
        //   ),
        //   iconTheme: IconThemeData(color: Colors.white),
        // ),
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
              // decoration: BoxDecoration(
              //   gradient: LinearGradient(
              //     begin: Alignment.topCenter,
              //     end: Alignment.bottomCenter,
              //     colors: [
              //       Colors.grey.shade50,
              //       Colors.white,
              //     ],
              //   ),
              // ),
              color: Color(0xFFFAF8F5),
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
                                  filterDogs = allDogs;
                                } else {
                                  filterDogs = allDogs.where((dog) {
                                    return dog.name
                                        .toLowerCase()
                                        .contains(value.toLowerCase());
                                  }).toList();
                                }
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'ค้นหาชื่อสุนัข...',
                              hintStyle: TextStyle(color: Colors.grey.shade500),
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
                                        borderRadius: BorderRadius.circular(8),
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
                                                    allDogs);
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
      child: SingleChildScrollView(
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
        final isPast = dog.status == 2;

        return Container(
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isPast ? Color(0xFFFFF8E1) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isPast
                ? Border.all(color: Color(0xFFDBA871), width: 1.5)
                : null,
            boxShadow: [
              BoxShadow(
                color: isPast
                    ? Color(0xFFDBA871).withOpacity(0.15)
                    : Colors.black.withOpacity(0.08),
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
                  : isPast
                      ? () {
                          GeneralAppNavigation.toWidget(ClinicsearchPage(
                            dogId: dog.dogId,
                            vaccineName: dog.vaccine,
                            date: widget.date,
                            aid: dog.aid,
                            reserveId: dog.reserveId,
                            dogData: null,
                          ));
                        }
                      : () {
                          GeneralAppNavigation.toWidget(ClinicsearchPage(
                            dogId: dog.dogId,
                            vaccineName: '',
                            date: widget.date,
                            aid: [0],
                            reserveId: null,
                            dogData: null,
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

                        // Priority Badge for Past Dates
                        if (isPast)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Color(0xFFDBA871),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'ด่วน',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
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
                              color: isPast
                                  ? Color(0xFFDBA871)
                                  : isBooked
                                      ? Colors.grey.shade600
                                      : Colors.grey.shade800,
                            ),
                          ),
                          // Priority message for past dates
                          if (isPast)
                            Container(
                              margin: EdgeInsets.only(top: 1, bottom: 1),
                              child: Text(
                                'วันนัดเดิม ${dog.date!.split(',').map((d) => DateFormat('d MMM y', 'th').format(DateTime.parse(d).toLocal())).join(', ')}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFDBA871),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          if (isPast)
                            Container(
                              margin: EdgeInsets.only(top: 1, bottom: 1),
                              child: Text(
                                'ควรจองโดยเร็ว',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFDBA871),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          SizedBox(height: 6),
                          isPast
                              ? Row(
                                  children: [
                                    Icon(
                                      Icons.cake,
                                      size: 16,
                                      color: isPast
                                          ? Color(0xFFDBA871)
                                          : Colors.grey.shade500,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'อายุ ${getDogAge(dog.birthday)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isPast
                                            ? Color(0xFFB8956B)
                                            : Colors.grey.shade600,
                                        fontWeight: isPast
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Icon(
                                      Icons.cake,
                                      size: 16,
                                      color: isPast
                                          ? Color(0xFFDBA871)
                                          : Colors.grey.shade500,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'อายุ ${getDogAge(dog.birthday)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isPast
                                            ? Color(0xFFB8956B)
                                            : Colors.grey.shade600,
                                        fontWeight: isPast
                                            ? FontWeight.w600
                                            : FontWeight.normal,
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
                                  'วันเกิด ${DateFormat('d MMMM', 'th').format(DateTime.parse(dog.birthday.toString()).toLocal())} ${DateTime.parse(dog.birthday.toString()).toLocal().year + 543}',
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
                    if (!isBooked && isPast)
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.priority_high,
                          color: Colors.white,
                          size: 20,
                        ),
                      )
                    else if (!isBooked)
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

  Future<void> addDogData(Map<DateTime, List<Dog>> dogData) async {
    // Map เก็บข้อมูลชั่วคราว เพื่อรวม aid และ vaccine ของ dogId เดียวกัน
    Map<int, ReserveDoglist> mergedDogs = {};

    dogData.forEach((date, dogs) {
      for (var dog in dogs) {
        // หา template จาก filterDogs (ข้อมูลพื้นฐานที่ต้องคัดลอก)
        var templateDogs =
            filterDogs.where((f) => f.dogId == dog.dogId).toList();

        if (templateDogs.isEmpty) {
          // ถ้าไม่มีข้อมูลใน filterDogs ข้ามไป
          continue;
        }

        var templateDog = templateDogs.first;

        if (mergedDogs.containsKey(dog.dogId)) {
          // ถ้าเจอ dogId นี้แล้ว ให้รวม aid และ vaccine และ concat วันที่ด้วย
          var existing = mergedDogs[dog.dogId]!;

          // รวม aid ไม่ให้ซ้ำ
          var newAid = {...?existing.aid, ...?dog.aid}.toList();
          existing.aid = newAid;

          // รวม vaccine ไม่ให้ซ้ำ
          var existingVaccines = existing.vaccine
              .split(',')
              .where((v) => v.trim().isNotEmpty)
              .toSet();
          var newVaccines = dog.vaccines.toSet();
          existing.vaccine = [...existingVaccines.union(newVaccines)].join(',');

          // รวมวันที่ (concat string ด้วย comma)
          existing.date = (existing.date ?? '') + ',${date.toString()}';

          // ถ้า reserveId ยังไม่มี ให้ใส่จาก dog ตัวใหม่
          if (existing.reserveId == null && dog.reserveId != null) {
            existing.reserveId = dog.reserveId;
          }
        } else {
          // สร้าง ReserveDoglist ใหม่ (copy ข้อมูลจาก template + ข้อมูลใหม่)
          mergedDogs[dog.dogId] = ReserveDoglist(
            dogId: templateDog.dogId,
            userEmail: templateDog.userEmail,
            name: templateDog.name,
            breed: templateDog.breed,
            gender: templateDog.gender,
            color: templateDog.color,
            defect: templateDog.defect,
            birthday: templateDog.birthday,
            congentialDisease: templateDog.congentialDisease,
            sterilization: templateDog.sterilization,
            hair: templateDog.hair,
            image: templateDog.image,
            aid: dog.aid ?? [0],
            date: date.toIso8601String(),
            status: 2,
            vaccine: dog.vaccines.join(','),
            reserveId: dog.reserveId,
          );
        }
      }
    });

    for (var dogId in mergedDogs.keys) {
      filterDogs.removeWhere((d) => d.dogId == dogId);
    }

    // นำข้อมูลที่ merge เสร็จแล้วใส่เข้า filterDogs (แทนการเพิ่มทีละอัน)
    filterDogs.addAll(mergedDogs.values);

    // อัพเดต status สำหรับรายการที่ไม่ได้อัพเดต
    for (var f in filterDogs) {
      if (f.status != 2) {
        f.status = 1;
      }
    }

    // เรียงลำดับ filterDogs ตามวันที่
    filterDogs.sort((a, b) {
      DateTime parseDate(String? dateStr) {
        if (dateStr == null || dateStr.isEmpty) {
          return widget.date;
        }

        // แยกและเอาวันแรก
        final firstDate = dateStr.split(',').first.trim();
        return DateTime.tryParse(firstDate) ?? widget.date;
      }

      final dateA = parseDate(a.date);
      final dateB = parseDate(b.date);

      return dateA.compareTo(dateB);
    });
  }

  Future<void> getDogData() async {
    var res = await http.get(
      Uri.parse("$url/dog/${box.read('email')}"),
    );

    if (res.statusCode == 200) {
      var jsonData = json.decode(res.body);
      allDogs = jsonData
          .map<ReserveDoglist>((e) => ReserveDoglist.fromJson(e))
          .toList();
      filterDogs = List<ReserveDoglist>.from(allDogs);
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('reserve')
        .where('generalEmail', isEqualTo: box.read('email'))
        .get();

    List<ReserveAppointmentFireStore> appointments = snapshot.docs
        .map((doc) => ReserveAppointmentFireStore.fromJson(doc.data(), doc.id))
        .toList();

    updateDogStatusByDate(allDogs, appointments, widget.date);
  }

  void updateDogStatusByDate(List<ReserveDoglist> dogs,
      List<ReserveAppointmentFireStore> appointments, DateTime selectedDate) {
    for (var dog in dogs) {
      // Check if this dog has an appointment on selectedDate
      bool hasAppointment = appointments.any((appointment) {
        return appointment.dogId == dog.dogId.toString() &&
            appointment.date.toLocal().year == selectedDate.year &&
            appointment.date.toLocal().month == selectedDate.month &&
            appointment.date.toLocal().day == selectedDate.day;
      });

      dog.status = hasAppointment ? 0 : 1;
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
