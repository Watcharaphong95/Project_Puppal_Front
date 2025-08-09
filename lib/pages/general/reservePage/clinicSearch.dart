import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/model/appointmentGetEmail.dart';
import 'package:puppal_application/model/clinicSearch.dart';
import 'package:puppal_application/model/clinicSearchRes.dart';
import 'package:puppal_application/model/dogsGetEmail.dart';
import 'package:puppal_application/model/specialDoctorRes.dart';
import 'package:puppal_application/pages/generalAppNavigator.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalMain.dart';
import 'package:puppal_application/pages/general/reservePage/clinicTimeSelect.dart';
import 'package:readmore/readmore.dart';
import 'package:shimmer/shimmer.dart';

class ClinicsearchPage extends StatefulWidget {
  final int dogId;
  final String vaccineName;
  final String? reserveId;
  final DateTime date;
  final List<int> aid;
  final Map<DateTime, List<Dog>>? dogData;

  const ClinicsearchPage(
      {super.key,
      required this.dogId,
      required this.vaccineName,
      required this.reserveId,
      required this.date,
      required this.aid,
      required this.dogData});

  @override
  State<ClinicsearchPage> createState() => _ClinicsearchPageState();
}

class _ClinicsearchPageState extends State<ClinicsearchPage> {
  late double screenWidth;
  late double screenHeight;
  final box = GetStorage();

  List<DogsGetEmail> dog = [];

  List<SpecialDoctorResponse> docSpecial = [];

  List<ClinicSearchResponse> clinics = [];

  List<ClinicSearchResponse> filterClinics = [];

  List<String> selectedSpecialtyNames = [];

  bool _loadingData = true;
  bool _loadingSearchData = true;

  bool _currentPosition = false;
  bool _isDogInfoExpanded = false;

  bool _hasLatestClinic = false;

  String url = '';

  String lastClinic = '';

  TextEditingController searchClinicCtl = TextEditingController();

  List<String> vaccinePastList = [];

  String vaccinePast = '';

  @override
  void initState() {
    log(widget.dogId.toString());
    log(widget.vaccineName);
    log(widget.date.toString());
    log('AID: ${widget.aid.toString()}');
    log('RESERVE: ${widget.reserveId.toString()}');
    log(jsonEncode(widget.dogData?.map((date, dogs) => MapEntry(
        date.toIso8601String(), dogs.map((d) => d.toJson()).toList()))));
    init();
    super.initState();
  }

  void init() async {
    await Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
    });
    await getDogData();
    await getLastestClinic();
    await getSpecialDoctorData();
    if (_currentPosition) {
      await searchClinicCurrentPosition();
    } else {
      await searchClinic();
    }

    setState(() {
      _loadingData = false;
      _loadingSearchData = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // appBar: AppBar(
      //   title: Text(
      //     'เลือกคลินิก',
      //     style: TextStyle(
      //         color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
      //   ),
      //   centerTitle: true,
      //   backgroundColor: Color(0xFFDBA871),
      //   iconTheme: IconThemeData(color: Colors.white),
      // ),
      body: _loadingData
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFDBA871),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'กำลังค้นหาคลินิก...',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : Container(
              // height: screenHeight * 0.7,
              // decoration: BoxDecoration(
              //   gradient: LinearGradient(
              //     begin: Alignment.topCenter,
              //     end: Alignment.bottomCenter,
              //     colors: [
              //       Colors.blue.shade50,
              //       Colors.white,
              //       Colors.orange.shade50,
              //     ],
              //   ),
              //   image: DecorationImage(
              //     image: AssetImage('assets/images/indexBg.png'),
              //     fit: BoxFit.cover,
              //     colorFilter: ColorFilter.mode(
              //         Colors.white.withOpacity(0.1), BlendMode.dstATop),
              //   ),
              // ),
              color: Color(0xFFFAF8F5),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: SizedBox(
                  width: screenWidth,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Dog Profile Card with minimize functionality
                            Container(
                              width: screenWidth * 0.9,
                              margin: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white,
                                    Color(0xFFF8F4F0),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 15,
                                    spreadRadius: 0,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Header with minimize button
                                  Container(
                                    padding: EdgeInsets.fromLTRB(20, 16, 16, 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'ข้อมูลสุนัข',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2C3E50),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            _isDogInfoExpanded
                                                ? Icons.keyboard_arrow_up
                                                : Icons.keyboard_arrow_down,
                                            color: Color(0xFFDBA871),
                                            size: 28,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _isDogInfoExpanded =
                                                  !_isDogInfoExpanded;
                                            });
                                          },
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Expandable content
                                  AnimatedSize(
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    child: _isDogInfoExpanded
                                        ? dogInfoExpanded()
                                        : SizedBox.shrink(),
                                  ),

                                  // Minimized view
                                  if (!_isDogInfoExpanded) dogInfoMinimized(),
                                ],
                              ),
                            ),

                            SizedBox(height: 20),

                            // Location Toggle and Search Section
                            Container(
                              width: screenWidth * 0.9,
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    spreadRadius: 0,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Location Toggle
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'ค้นหาตามตำแหน่งปัจจุบัน',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2C3E50),
                                        ),
                                      ),
                                      Switch(
                                        value: _currentPosition,
                                        onChanged: (value) async {
                                          setState(() {
                                            _currentPosition = value;
                                            if (_currentPosition) {
                                              searchClinicCurrentPosition();
                                            } else {
                                              searchClinic();
                                            }
                                          });
                                        },
                                        activeColor: Color(0xFFDBA871),
                                        inactiveThumbColor:
                                            Colors.grey.shade400,
                                        inactiveTrackColor:
                                            Colors.grey.shade300,
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 16),

                                  // Search Field
                                  searchBox(context),
                                ],
                              ),
                            ),

                            SizedBox(height: 16),

                            // Results Section
                            if (_loadingSearchData)
                              SizedBox(
                                height: _isDogInfoExpanded
                                    ? screenHeight * 0.19
                                    : screenHeight * 0.35,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Color(0xFFDBA871),
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'กำลังค้นหาคลินิก...',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              showClinicResult(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  SafeArea showClinicResult() {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: _isDogInfoExpanded ? screenHeight * 0.5 : screenHeight * 0.5,
        child: clinics.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'ไม่พบคลินิกที่ค้นหา',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'ลองค้นหาด้วยคำค้นอื่น',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: filterClinics.length,
                itemBuilder: (context, index) {
                  final clinic = filterClinics[index];
                  final isSpecial = clinic.special == 1;
                  final isFull = clinic.full == 1;
                  final isDisabled = isFull && !isSpecial;
                  final hasSpecialties = clinic.specialties != null &&
                      clinic.specialties.isNotEmpty;

                  final isLastClinic =
                      clinic.userEmail == lastClinic && _hasLatestClinic;

                  // Determine if clinic is interactable (closed clinics are not clickable)
                  final isClinicInteractable =
                      filterClinics[index].toDayOpen && !isDisabled;

                  // Format opening days
                  String formatOpeningDays(String weekdays) {
                    if (weekdays == null || weekdays.isEmpty) return '';

                    List<String> days = weekdays.split(',');
                    Map<String, String> dayMap = {
                      'Monday': 'จ',
                      'Tuesday': 'อ',
                      'Wednesday': 'พ',
                      'Thursday': 'พฤ',
                      'Friday': 'ศ',
                      'Saturday': 'ส',
                      'Sunday': 'อา',
                    };

                    // Convert to Thai abbreviations
                    List<String> thaiDays =
                        days.map((day) => dayMap[day] ?? day).toList();

                    // Check for consecutive weekdays pattern
                    List<String> weekdayOrder = [
                      'จ',
                      'อ',
                      'พ',
                      'พฤ',
                      'ศ',
                      'ส',
                      'อา'
                    ];

                    // Check if it's Monday to Friday
                    if (thaiDays.length == 5 &&
                        thaiDays.contains('จ') &&
                        thaiDays.contains('อ') &&
                        thaiDays.contains('พ') &&
                        thaiDays.contains('พฤ') &&
                        thaiDays.contains('ศ')) {
                      return 'จ-ศ';
                    }

                    // Check if it's Monday to Saturday
                    if (thaiDays.length == 6 &&
                        thaiDays.contains('จ') &&
                        thaiDays.contains('อ') &&
                        thaiDays.contains('พ') &&
                        thaiDays.contains('พฤ') &&
                        thaiDays.contains('ศ') &&
                        thaiDays.contains('ส')) {
                      return 'จ-ส';
                    }

                    // Check if it's all 7 days
                    if (thaiDays.length == 7) {
                      return 'ทุกวัน';
                    }

                    // Otherwise, return individual days
                    return thaiDays.join(', ');
                  }

                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: !filterClinics[index].toDayOpen
                          ? Colors.grey.shade100
                          : isDisabled
                              ? Colors.grey.shade200
                              : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: !filterClinics[index].toDayOpen
                          ? Border.all(color: Colors.red.shade300, width: 1)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(!filterClinics[index].toDayOpen
                                  ? 0.02
                                  : isDisabled
                                      ? 0.04
                                      : 0.08),
                          blurRadius: 12,
                          spreadRadius: 0,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: isClinicInteractable
                            ? () {
                                GeneralAppNavigation.toWidget(
                                    ClinictimeselectPage(
                                  email: clinic.userEmail,
                                  dogId: widget.dogId,
                                  distance: clinic.distanceKm,
                                  date: widget.date,
                                  vaccineName: widget.vaccineName,
                                  aid: widget.aid,
                                  reserveId: widget.reserveId,
                                  special: isSpecial,
                                ));
                              }
                            : null,
                        child: Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Clinic Image
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          spreadRadius: 0,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: ColorFiltered(
                                            colorFilter: ColorFilter.mode(
                                              !filterClinics[index].toDayOpen ||
                                                      isDisabled
                                                  ? Colors.grey
                                                  : Colors.transparent,
                                              !filterClinics[index].toDayOpen ||
                                                      isDisabled
                                                  ? BlendMode.saturation
                                                  : BlendMode.multiply,
                                            ),
                                            child: Image.network(
                                              clinic.image,
                                              width: screenWidth * 0.22,
                                              height: screenHeight * 0.1,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Shimmer.fromColors(
                                                  baseColor:
                                                      Colors.grey.shade300,
                                                  highlightColor:
                                                      Colors.grey.shade100,
                                                  child: Container(
                                                    width: screenWidth * 0.22,
                                                    height: screenHeight * 0.1,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        // Closed overlay
                                        if (!filterClinics[index].toDayOpen)
                                          Positioned.fill(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color:
                                                    Colors.red.withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Center(
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red.shade600,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Text(
                                                    'ปิด',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        // Full overlay (existing)
                                        else if (isFull && !isSpecial)
                                          Positioned.fill(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.3),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(width: 16),

                                  // Clinic Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          clinic.name,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                !filterClinics[index].toDayOpen
                                                    ? Colors.grey.shade500
                                                    : isDisabled
                                                        ? Colors.grey.shade600
                                                        : Color(0xFF2C3E50),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 6),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color:
                                                !filterClinics[index].toDayOpen
                                                    ? Colors.red.shade50
                                                    : isDisabled
                                                        ? Colors.grey.shade100
                                                        : Colors.blue.shade50,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.pin_drop,
                                                color: !filterClinics[index]
                                                        .toDayOpen
                                                    ? Colors.red.shade400
                                                    : isDisabled
                                                        ? Colors.grey.shade500
                                                        : Colors.blue.shade600,
                                                size: 16,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                '${clinic.distanceKm.toStringAsFixed(3)} กม.',
                                                style: TextStyle(
                                                  color: !filterClinics[index]
                                                          .toDayOpen
                                                      ? Colors.red.shade400
                                                      : isDisabled
                                                          ? Colors.grey.shade500
                                                          : Colors
                                                              .blue.shade600,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.access_time,
                                              color: !filterClinics[index]
                                                      .toDayOpen
                                                  ? Colors.red.shade600
                                                  : isDisabled
                                                      ? Colors.grey.shade500
                                                      : Colors.green.shade600,
                                              size: 16,
                                            ),
                                            SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                filterClinics[index].toDayOpen
                                                    ? 'เปิด ${clinic.open.substring(0, 5)} - ${clinic.close.substring(0, 5)}'
                                                    : 'ปิดวันนี้',
                                                style: TextStyle(
                                                  color: !filterClinics[index]
                                                          .toDayOpen
                                                      ? Colors.red.shade600
                                                      : isDisabled
                                                          ? Colors.grey.shade500
                                                          : Colors
                                                              .green.shade600,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        // Add opening days information
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today,
                                              color: !filterClinics[index]
                                                      .toDayOpen
                                                  ? Colors.grey.shade400
                                                  : isDisabled
                                                      ? Colors.grey.shade500
                                                      : Colors.purple.shade600,
                                              size: 16,
                                            ),
                                            SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                formatOpeningDays(
                                                    clinic.weekdays),
                                                style: TextStyle(
                                                  color: !filterClinics[index]
                                                          .toDayOpen
                                                      ? Colors.grey.shade400
                                                      : isDisabled
                                                          ? Colors.grey.shade500
                                                          : Colors
                                                              .purple.shade600,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Show specialties if available
                                        if (hasSpecialties) ...[
                                          SizedBox(height: 4),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.medical_services,
                                                color: !filterClinics[index]
                                                        .toDayOpen
                                                    ? Colors.grey.shade400
                                                    : isDisabled
                                                        ? Colors.grey.shade500
                                                        : Colors
                                                            .orange.shade600,
                                                size: 16,
                                              ),
                                              SizedBox(width: 4),
                                              Expanded(
                                                child: Row(
                                                  children:
                                                      clinic.specialties
                                                          .take(3)
                                                          .map<Widget>(
                                                              (specialty) {
                                                    return Container(
                                                      width:
                                                          screenWidth * 0.175,
                                                      margin: EdgeInsets.only(
                                                          right: 3),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        horizontal: 4,
                                                        vertical: 1,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: !filterClinics[
                                                                    index]
                                                                .toDayOpen
                                                            ? Colors
                                                                .grey.shade50
                                                            : isDisabled
                                                                ? Colors.grey
                                                                    .shade100
                                                                : Colors.orange
                                                                    .shade50,
                                                        border: Border.all(
                                                          color: !filterClinics[
                                                                      index]
                                                                  .toDayOpen
                                                              ? Colors
                                                                  .grey.shade300
                                                              : isDisabled
                                                                  ? Colors.grey
                                                                      .shade400
                                                                  : Colors
                                                                      .orange
                                                                      .shade600,
                                                          width: 1,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(3),
                                                      ),
                                                      child: Text(
                                                        specialty,
                                                        style: TextStyle(
                                                          color: !filterClinics[
                                                                      index]
                                                                  .toDayOpen
                                                              ? Colors
                                                                  .grey.shade400
                                                              : isDisabled
                                                                  ? Colors.grey
                                                                      .shade500
                                                                  : Colors
                                                                      .orange
                                                                      .shade600,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    );
                                                  }).toList()
                                                        ..addAll(clinic
                                                                    .specialties
                                                                    .length >
                                                                3
                                                            ? [
                                                                Container(
                                                                  width:
                                                                      screenWidth *
                                                                          0.15,
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          right:
                                                                              3),
                                                                  padding:
                                                                      EdgeInsets
                                                                          .symmetric(
                                                                    horizontal:
                                                                        4,
                                                                    vertical: 1,
                                                                  ),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: !filterClinics[index]
                                                                            .toDayOpen
                                                                        ? Colors
                                                                            .grey
                                                                            .shade100
                                                                        : isDisabled
                                                                            ? Colors.grey.shade200
                                                                            : Colors.orange.shade100,
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: !filterClinics[index]
                                                                              .toDayOpen
                                                                          ? Colors
                                                                              .grey
                                                                              .shade300
                                                                          : isDisabled
                                                                              ? Colors.grey.shade400
                                                                              : Colors.orange.shade600,
                                                                      width: 1,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                  ),
                                                                  child: Text(
                                                                    '+${clinic.specialties.length - 3}',
                                                                    style:
                                                                        TextStyle(
                                                                      color: !filterClinics[index]
                                                                              .toDayOpen
                                                                          ? Colors
                                                                              .grey
                                                                              .shade400
                                                                          : isDisabled
                                                                              ? Colors.grey.shade500
                                                                              : Colors.orange.shade600,
                                                                      fontSize:
                                                                          10,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                    ),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  ),
                                                                ),
                                                              ]
                                                            : []),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),

                                  // Arrow Button
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors:
                                            !filterClinics[index].toDayOpen ||
                                                    isDisabled
                                                ? [
                                                    Colors.grey.shade400,
                                                    Colors.grey.shade500,
                                                  ]
                                                : [
                                                    Color(0xFFDBA871),
                                                    Color(0xFFCD9A5B),
                                                  ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (!filterClinics[index]
                                                          .toDayOpen ||
                                                      isDisabled
                                                  ? Colors.grey.shade400
                                                  : Color(0xFFDBA871))
                                              .withOpacity(0.3),
                                          blurRadius: 8,
                                          spreadRadius: 0,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      !filterClinics[index].toDayOpen
                                          ? Icons.schedule
                                          : Icons.arrow_forward_ios,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Badges positioning
                            if (!filterClinics[index].toDayOpen)
                              // Closed Badge (takes priority)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade600,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.red.shade600
                                            .withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.schedule,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'ปิดวันนี้',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            // Special and Full Badges (when clinic is open)
                            else if (isSpecial && isFull)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Special Badge
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFDBA871),
                                            Color(0xFFCD9A5B),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0xFFDBA871)
                                                .withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.star,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'พิเศษ',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    // Full Badge
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade600,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.orange.shade600
                                                .withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.people,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'เต็ม',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            // Only Full Badge when not special (and clinic is open)
                            else if (isFull)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade600,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.red.shade600
                                            .withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.block,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'เต็ม',
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
                            if (isLastClinic)
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.shade600,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.purple.shade600
                                            .withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.history,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'จอง',
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
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Container searchBox(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: searchClinicCtl,
        onChanged: (value) {
          filterClinics = clinics.where((clinic) {
            return clinic.name.toLowerCase().contains(value.toLowerCase());
          }).toList();
          setState(() {});
        },
        decoration: InputDecoration(
          hintText: 'ค้นหาคลินิก',
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 16,
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Color(0xFFDBA871),
              width: 2,
            ),
          ),
          prefixIcon: Container(
            padding: EdgeInsets.all(12),
            child: Icon(
              FontAwesomeIcons.magnifyingGlass,
              color: Color(0xFFDBA871),
              size: 20,
            ),
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Filter button
              Container(
                margin: EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(
                    FontAwesomeIcons.filter,
                    color: Color(0xFFDBA871),
                    size: 18,
                  ),
                  onPressed: () {
                    _showFilterBottomSheet(context);
                  },
                ),
              ),
              // Clear button (only show when text is not empty)
              if (searchClinicCtl.text.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                    onPressed: () {
                      searchClinicCtl.clear();
                      FocusScope.of(context).unfocus();
                      setState(() {
                        filterClinics = clinics;
                      });
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

// Filter bottom sheet method
  void _showFilterBottomSheet(BuildContext context) {
    // Create a copy of selected names for local state management
    List<String> tempSelectedNames = List.from(selectedSpecialtyNames);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Title
                  Text(
                    'เลือกความเชี่ยวชาญ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFDBA871),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Show selected count
                  if (tempSelectedNames.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Color(0xFFDBA871).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(0xFFDBA871).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.check,
                            color: Color(0xFFDBA871),
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'เลือกแล้ว: ${tempSelectedNames.length} รายการ',
                            style: TextStyle(
                              color: Color(0xFFDBA871),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Clear all button
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 16),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setBottomSheetState(() {
                          tempSelectedNames.clear();
                          filterClinics = clinics.where((clinic) {
                            return clinic.name
                                .toLowerCase()
                                .contains(searchClinicCtl.text.toLowerCase());
                          }).toList();
                          log('clear: ${jsonEncode(filterClinics.map((e) => e.toJson()).toList())}');
                        });
                      },
                      icon: Icon(
                        Icons.clear_all,
                        color: Colors.grey.shade600,
                        size: 18,
                      ),
                      label: Text(
                        'ล้างการเลือกทั้งหมด',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  // Specialty list
                  Expanded(
                    child: ListView.builder(
                      itemCount: docSpecial.length,
                      itemBuilder: (context, index) {
                        final specialty = docSpecial[index];
                        final specialtyName = specialty.name ?? 'Unknown';
                        final isSelected =
                            tempSelectedNames.contains(specialtyName);

                        return Container(
                          margin: EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Color(0xFFDBA871).withOpacity(0.05)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(
                                    color: Color(0xFFDBA871).withOpacity(0.3),
                                    width: 1)
                                : null,
                          ),
                          child: CheckboxListTile(
                            value: isSelected,
                            onChanged: (bool? value) {
                              setBottomSheetState(() {
                                if (value == true) {
                                  if (!tempSelectedNames
                                      .contains(specialtyName)) {
                                    tempSelectedNames.add(specialtyName);
                                  }
                                } else {
                                  tempSelectedNames.remove(specialtyName);
                                }
                              });
                            },
                            title: Text(
                              specialtyName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Color(0xFFDBA871)
                                    : Colors.black87,
                              ),
                            ),
                            secondary: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Color(0xFFDBA871).withOpacity(0.1)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                FontAwesomeIcons.userDoctor,
                                color: isSelected
                                    ? Color(0xFFDBA871)
                                    : Colors.grey.shade400,
                                size: 18,
                              ),
                            ),
                            activeColor: Color(0xFFDBA871),
                            checkColor: Colors.white,
                            controlAffinity: ListTileControlAffinity.trailing,
                          ),
                        );
                      },
                    ),
                  ),
                  // Action buttons
                  Container(
                    padding: EdgeInsets.only(top: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              'ยกเลิก',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedSpecialtyNames =
                                    List.from(tempSelectedNames);

                                for (var s in selectedSpecialtyNames) {
                                  log(s);
                                }

                                if (selectedSpecialtyNames.isEmpty) {
                                  filterClinics = clinics.where((clinic) {
                                    return clinic.name.toLowerCase().contains(
                                        searchClinicCtl.text.toLowerCase());
                                  }).toList();

                                  return;
                                }

                                // log('before: ${jsonEncode(filterClinics.map((e) => e.toJson()).toList())}');

                                filterClinics = clinics.where((clinic) {
                                  final nameMatch = clinic.name
                                      .toLowerCase()
                                      .contains(
                                          searchClinicCtl.text.toLowerCase());

                                  final clinicSpecs = clinic.specialties
                                      .map((s) => s.trim().toLowerCase())
                                      .toList();
                                  final selectedSpecs = selectedSpecialtyNames
                                      .map((s) => s.trim().toLowerCase());

                                  final specMatch = selectedSpecs.every(
                                      (selected) =>
                                          clinicSpecs.contains(selected));

                                  return nameMatch && specMatch;
                                }).toList();

                                // log('after: ${jsonEncode(filterClinics.map((e) => e.toJson()).toList())}');
                              });
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFDBA871),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                            child: Text(
                              'ตกลง',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> getLastestClinic() async {
    final docRef = FirebaseFirestore.instance
        .collection('reserve')
        .where('generalEmail', isEqualTo: box.read('email'))
        .orderBy('createAt', descending: true)
        .limit(1);

    final snapshot = await docRef.get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      final data = doc.data();
      lastClinic = data['clinicEmail'];
      log(lastClinic);
      _hasLatestClinic = true;
    }
  }

  Container dogInfoMinimized() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                dog[0].image,
                width: screenWidth * 0.15,
                height: screenWidth * 0.15,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      width: screenWidth * 0.15,
                      height: screenWidth * 0.15,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dog[0].name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: 4),
                Text(
                  'อายุ ${getDogAge(DateFormat('yyyy-MM-dd').format(DateFormat('d-MMMM-y', 'th').parse(dog[0].birthday)))}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFDBA871),
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ClipRect dogInfoExpanded() {
    return ClipRect(
      child: Align(
        alignment: Alignment.topCenter,
        heightFactor: _isDogInfoExpanded ? 1.0 : 0.0,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dog Image with enhanced styling
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    dog[0].image,
                    width: screenWidth * 0.4,
                    height: screenHeight * 0.18,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          width: screenWidth * 0.4,
                          height: screenHeight * 0.18,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              SizedBox(height: 12),

              // Dog Info
              Container(
                width: double.infinity,
                child: Text(
                  dog[0].name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFFDBA871).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'อายุ ${getDogAge((DateFormat('yyyy-MM-dd').format(DateFormat('d-MMMM-y', 'th').parse(dog[0].birthday))))}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFDBA871),
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 12),

              // Vaccine Info
              Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  maxHeight: screenHeight * 0.15,
                ),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // แสดงวัคซีนปัจจุบัน
                      widget.vaccineName.trim().isNotEmpty
                          ? ReadMoreText(
                              widget.vaccineName
                                  .split(',')
                                  .map((e) => '• ${e.trim()}')
                                  .join('\n'),
                              trimMode: TrimMode.Line,
                              trimLines: 3,
                              colorClickableText: Colors.transparent,
                              trimCollapsedText: 'แสดงเพิ่มเติม',
                              trimExpandedText: '\n\nย่อข้อความ',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.green.shade700,
                              ),
                              moreStyle: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade600,
                              ),
                              lessStyle: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade600,
                              ),
                            )
                          : Text(
                              "ไม่มีวัคซีน",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.green.shade700,
                              ),
                            ),

                      SizedBox(height: 12),

                      // แสดงวัคซีนเก่า
                      vaccinePast.trim().isNotEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "วัคซีนที่เลยกำหนด:",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                ReadMoreText(
                                  vaccinePast
                                      .split(',')
                                      .map((e) => '• ${e.trim()}')
                                      .join('\n'),
                                  trimMode: TrimMode.Line,
                                  trimLines: 3,
                                  colorClickableText: Colors.transparent,
                                  trimCollapsedText: 'แสดงเพิ่มเติม',
                                  trimExpandedText: '\n\nย่อข้อความ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                  moreStyle: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade600,
                                  ),
                                  lessStyle: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade600,
                                  ),
                                ),
                              ],
                            )
                          : SizedBox.shrink()
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> searchClinic() async {
    _loadingSearchData = true;
    ClinicSearch req = ClinicSearch(
        email: box.read('email'),
        word: searchClinicCtl.text,
        date: widget.date.toString());

    var res = await http.post(
      Uri.parse("$url/clinic/search"),
      headers: {"Content-Type": "application/json; charset=utf-8"},
      body: clinicSearchToJson(req),
    );

    var jsonData = json.decode(res.body);
    clinics = jsonData
        .map<ClinicSearchResponse>((e) => ClinicSearchResponse.fromJson(e))
        .toList();

    // log(lastClinic);
    clinics.sort((a, b) {
      final an = a.userEmail.toLowerCase().trim();
      final bn = b.userEmail.toLowerCase().trim();
      final lc = lastClinic.toLowerCase().trim();

      if (an == lc) return -1;
      if (bn == lc) return 1;
      return 0;
    });

    setState(() {
      filterClinics = clinics;
      _loadingSearchData = false;
    });
    // log('clinic: ${jsonEncode(clinics.map((e) => e.toJson()).toList())}');
  }

  Future<void> searchClinicCurrentPosition() async {
    _loadingSearchData = true;
    // Check and request permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return; // return -1 or any sentinel value to indicate failure
      }
    }

    // Get current location
    Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    ClinicSearch req = ClinicSearch(
        email: box.read('email'),
        word: searchClinicCtl.text,
        date: widget.date.toString());

    var res = await http.post(
      Uri.parse("$url/clinic/search"),
      headers: {"Content-Type": "application/json; charset=utf-8"},
      body: clinicSearchToJson(req),
    );

    var jsonData = json.decode(res.body);
    clinics = jsonData
        .map<ClinicSearchResponse>((e) => ClinicSearchResponse.fromJson(e))
        .toList();

    for (var c in clinics) {
      c.distanceKm = Geolocator.distanceBetween(
              currentPosition.latitude,
              currentPosition.longitude,
              double.parse(c.lat),
              double.parse(c.lng)) /
          1000;
    }

    // Sort by distance (ascending)
    clinics.sort((a, b) {
      final an = a.userEmail.toLowerCase().trim();
      final bn = b.userEmail.toLowerCase().trim();
      final lc = lastClinic.toLowerCase().trim();

      if (an == lc) return -1;
      if (bn == lc) return 1;
      return 0;
    });

    setState(() {
      filterClinics = clinics;
      _loadingSearchData = false;
    });
    // log('clinic: ${jsonEncode(clinics.map((e) => e.toJson()).toList())}');
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

      // log(dog[0].name);
      if (widget.dogData != null) {
        for (var entry in widget.dogData!.entries) {
          List<Dog> dogData = entry.value;
          for (var v in dogData) {
            vaccinePastList
                .addAll(v.vaccines.where((e) => e.trim().isNotEmpty));
            if (v.aid != null) {
              widget.aid.addAll(v.aid ?? []);
            }
          }
        }
      }
      vaccinePast = vaccinePastList.join(', ');
    }
  }

  Future<void> getSpecialDoctorData() async {
    var res = await http.get(Uri.parse("$url/clinic/allSpecial"));
    if (res.statusCode == 200) {
      var jsonData = json.decode(res.body);
      docSpecial = jsonData
          .map<SpecialDoctorResponse>((e) => SpecialDoctorResponse.fromJson(e))
          .toList();

      // log('docSpecial: ${jsonEncode(docSpecial.map((e) => e.toJson()).toList())}');
    } else {
      // log(res.body);
    }
  }
}
