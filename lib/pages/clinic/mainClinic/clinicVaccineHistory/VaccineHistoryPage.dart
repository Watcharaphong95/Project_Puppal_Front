import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/model/appointmentClinic.dart';
import 'package:puppal_application/model/appointmentPost.dart';
import 'package:puppal_application/model/dogdetalisPost.dart';
import 'package:puppal_application/model/generalPost.dart';
import 'package:puppal_application/model/reserveClinicPost.dart';
import 'package:puppal_application/model/reservebooking.dart';
import 'package:http/http.dart' as http;
import 'package:puppal_application/model/reserveclinicfirebase.dart';
import 'package:puppal_application/pages/clinic/mainClinic/bookingdetails/CalendarBookingDetailPage.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicVaccineHistory/VaccineHistoryDetailsPage.dart';
import 'package:table_calendar/table_calendar.dart';

class Vaccinehistorypage extends StatefulWidget {
  const Vaccinehistorypage({super.key});

  @override
  State<Vaccinehistorypage> createState() => _VaccinehistorypageState();
}

class _VaccinehistorypageState extends State<Vaccinehistorypage> {
  late double screenWidth;
  late double screenHeight;
  final box = GetStorage();
  String url = '';
  bool isLoading = true;
  final Color primaryBrown = const Color(0xFF916B44);
  final Color secondaryBrown = const Color(0xFFDBA871);
  final Color lightBrown = const Color(0xFFE9CBAF);
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<ReserveClinicFirebase> reserveList = [];
  List<ReserveClinicFirebase> reservebookingList = [];
  List<ReserveClinicFirebase> events = [];
  List<ReserveClinicFirebase> reservebookingListAll = [];

  @override
  void initState() {
    super.initState();
    initialize(); // Call async method without await
  }

  Future<void> initialize() async {
    final config = await Configuration.getConfig();
    url = config['apiEndPoint'];
    await getReserve();
    // await initializeData();
    box.write('type', 'clinic');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        drawer: Drawer(),
        body: Container(
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF916B44)),
                    strokeWidth: 3,
                  ),
                )
              : Column(
                  children: [
                    // Calendar Section with Modern Card Design
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: buildCalendar(
                        focusedDay: _focusedDay,
                        selectedDay: _selectedDay,
                        onDaySelected: (selected, focused) {
                          setState(() {
                            _focusedDay = focused;
                            _selectedDay = selected;
                            events = List.from(reservebookingListAll);
                            isLoading = false;
                          });
                        },
                        onPageChanged: (focused) {
                          setState(() {
                            _focusedDay = focused;
                          });
                        },
                        eventLoader: getEventsForDay,
                      ),
                    ),

                    // Section Header
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Color(0xFF916B44),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            "ประวัติการฉีดวัคซีนวันนี้",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF916B44),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Events List
                    Expanded(
                        child: events.isEmpty
                            ? Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color:
                                            Color(0xFFE9CBAF).withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(40),
                                      ),
                                      child: Icon(
                                        Icons.calendar_today_outlined,
                                        size: 40,
                                        color: Color(0xFF916B44),
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      "ไม่มีข้อมูลประวัติการฉีดวัคซีนของวันนี้",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF916B44),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "โปรดเลือกวันอื่นเพื่อดูข้อมูล",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color:
                                            Color(0xFF916B44).withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                itemCount: events.length,
                                itemBuilder: (context, index) {
                                  final item = events[index];
                                  if (item.status != 3) {
                                    return const SizedBox.shrink();
                                  }
                                  return Container(
                                    margin: EdgeInsets.only(bottom: 16),
                                    child: InkWell(
                                      onTap: () async {},
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          // gradient: LinearGradient(
                                          //   begin: Alignment.topLeft,
                                          //   end: Alignment.bottomRight,
                                          //   colors: [
                                          //     Colors.white,
                                          //     Color(0xFFE9CBAF)
                                          //         .withOpacity(0.05),
                                          //   ],
                                          // ),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(0xFF916B44)
                                                  .withOpacity(0.08),
                                              blurRadius: 16,
                                              offset: Offset(0, 6),
                                              spreadRadius: 0,
                                            ),
                                            BoxShadow(
                                              color: Color(0xFF916B44)
                                                  .withOpacity(0.04),
                                              blurRadius: 6,
                                              offset: Offset(0, 2),
                                              spreadRadius: 0,
                                            ),
                                          ],
                                          border: Border.all(
                                            color: Color(0xFFE9CBAF)
                                                .withOpacity(0.2),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(20),
                                          child: Row(
                                            children: [
                                              // Enhanced Profile Image with Gradient Border
                                              Container(
                                                padding: EdgeInsets.all(3),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      Color(0xFF916B44),
                                                      Color(0xFFDBA871),
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Container(
                                                  width: 64,
                                                  height: 64,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            17),
                                                    color: Colors.white,
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            17),
                                                    child: FutureBuilder<
                                                        DogDetailsPost?>(
                                                      future: getdog(
                                                        item.dogDogId is int
                                                            ? item.dogDogId
                                                                as int
                                                            : int.tryParse(item
                                                                    .dogDogId
                                                                    .toString()) ??
                                                                0,
                                                      ),
                                                      builder:
                                                          (context, snapshot) {
                                                        if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              gradient:
                                                                  LinearGradient(
                                                                begin: Alignment
                                                                    .topLeft,
                                                                end: Alignment
                                                                    .bottomRight,
                                                                colors: [
                                                                  Color(0xFFE9CBAF)
                                                                      .withOpacity(
                                                                          0.3),
                                                                  Color(0xFFE9CBAF)
                                                                      .withOpacity(
                                                                          0.1),
                                                                ],
                                                              ),
                                                            ),
                                                            child: Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                                valueColor:
                                                                    AlwaysStoppedAnimation<
                                                                        Color>(
                                                                  Color(
                                                                      0xFF916B44),
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                        if (!snapshot.hasData ||
                                                            snapshot.data ==
                                                                null ||
                                                            snapshot.data!
                                                                    .image ==
                                                                null) {
                                                          return Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              gradient:
                                                                  LinearGradient(
                                                                begin: Alignment
                                                                    .topLeft,
                                                                end: Alignment
                                                                    .bottomRight,
                                                                colors: [
                                                                  Color(0xFFE9CBAF)
                                                                      .withOpacity(
                                                                          0.3),
                                                                  Color(0xFFE9CBAF)
                                                                      .withOpacity(
                                                                          0.1),
                                                                ],
                                                              ),
                                                            ),
                                                            child: Icon(
                                                              Icons.pets,
                                                              size: 32,
                                                              color: Color(
                                                                  0xFF916B44),
                                                            ),
                                                          );
                                                        }

                                                        final dogImageUrl =
                                                            snapshot
                                                                .data!.image!;
                                                        return Image.network(
                                                          dogImageUrl,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (context,
                                                                  error,
                                                                  stackTrace) =>
                                                              Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              gradient:
                                                                  LinearGradient(
                                                                begin: Alignment
                                                                    .topLeft,
                                                                end: Alignment
                                                                    .bottomRight,
                                                                colors: [
                                                                  Color(0xFFE9CBAF)
                                                                      .withOpacity(
                                                                          0.3),
                                                                  Color(0xFFE9CBAF)
                                                                      .withOpacity(
                                                                          0.1),
                                                                ],
                                                              ),
                                                            ),
                                                            child: Icon(
                                                              Icons
                                                                  .broken_image,
                                                              size: 32,
                                                              color: Color(
                                                                  0xFF916B44),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 8),

                                              Expanded(
                                                child: Stack(
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        // ชื่อผู้จอง
                                                        FutureBuilder<
                                                            GeneralPost?>(
                                                          future: getGeneral(
                                                              item.generalEmail),
                                                          builder: (context,
                                                              snapshot) {
                                                            if (snapshot
                                                                    .connectionState ==
                                                                ConnectionState
                                                                    .waiting) {
                                                              return Container(
                                                                height: 20,
                                                                width: 100,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  gradient:
                                                                      LinearGradient(
                                                                    colors: [
                                                                      Color(0xFFE9CBAF)
                                                                          .withOpacity(
                                                                              0.3),
                                                                      Color(0xFFE9CBAF)
                                                                          .withOpacity(
                                                                              0.1),
                                                                    ],
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                ),
                                                              );
                                                            } else if (snapshot
                                                                .hasError) {
                                                              return Text(
                                                                'เกิดข้อผิดพลาด',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              );
                                                            } else if (!snapshot
                                                                    .hasData ||
                                                                snapshot.data ==
                                                                    null) {
                                                              return Text(
                                                                'ไม่ระบุชื่อ',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Color(
                                                                      0xFF916B44),
                                                                ),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              );
                                                            } else {
                                                              final general =
                                                                  snapshot
                                                                      .data!;
                                                              return Text.rich(
                                                                TextSpan(
                                                                  children: [
                                                                    TextSpan(
                                                                      text:
                                                                          'คุณ ',
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        color: Color(0xFF916B44)
                                                                            .withOpacity(0.8),
                                                                      ),
                                                                    ),
                                                                    TextSpan(
                                                                      text: general
                                                                              .name ??
                                                                          'ไม่ระบุชื่อ',
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w700,
                                                                        color: Color(
                                                                            0xFF916B44),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 15,
                                                                  height: 1.2,
                                                                ),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                maxLines: 1,
                                                              );
                                                            }
                                                          },
                                                        ),

                                                        // SizedBox(height: 12),

                                                        // กล่องข้อมูลวัคซีน
                                                        Container(
                                                          margin: EdgeInsets.only(
                                                              top:
                                                                  6), // ระยะห่างจากชื่อด้านบน
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 6),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Color(
                                                                    0xFFE9CBAF)
                                                                .withOpacity(
                                                                    0.06),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            border: Border.all(
                                                              color: Color(
                                                                      0xFFE9CBAF)
                                                                  .withOpacity(
                                                                      0.2),
                                                              width: 1,
                                                            ),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                width: 8,
                                                                height: 8,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  gradient:
                                                                      LinearGradient(
                                                                    colors: [
                                                                      Color(
                                                                          0xFF916B44),
                                                                      Color(
                                                                          0xFFDBA871),
                                                                    ],
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width: 8),
                                                              Expanded(
                                                                child: (item.appointmentAid ==
                                                                        null)
                                                                    ? Text(
                                                                        'ไม่มีข้อมูลวัคซีน',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          color:
                                                                              Color(0xFF916B44).withOpacity(0.6),
                                                                          fontStyle:
                                                                              FontStyle.italic,
                                                                        ),
                                                                      )
                                                                    : FutureBuilder<
                                                                        List<
                                                                            dynamic>>(
                                                                        future:
                                                                            Future.wait([
                                                                          getvaccine(
                                                                              item.appointmentAid.toString(),
                                                                              item.generalEmail),
                                                                          getdog(
                                                                            item.dogDogId is int
                                                                                ? item.dogDogId as int
                                                                                : int.tryParse(item.dogDogId.toString()) ?? 0,
                                                                          ),
                                                                        ]),
                                                                        builder:
                                                                            (context,
                                                                                snapshot) {
                                                                          if (snapshot.connectionState ==
                                                                              ConnectionState.waiting) {
                                                                            return Container(
                                                                              height: 16,
                                                                              width: 120,
                                                                              decoration: BoxDecoration(
                                                                                gradient: LinearGradient(
                                                                                  colors: [
                                                                                    Color(0xFFE9CBAF).withOpacity(0.3),
                                                                                    Color(0xFFE9CBAF).withOpacity(0.1),
                                                                                  ],
                                                                                ),
                                                                                borderRadius: BorderRadius.circular(8),
                                                                              ),
                                                                            );
                                                                          } else if (snapshot.hasError) {
                                                                            return Text(
                                                                              'เกิดข้อผิดพลาด',
                                                                              style: TextStyle(
                                                                                fontSize: 13,
                                                                                color: Colors.red,
                                                                                fontWeight: FontWeight.w500,
                                                                              ),
                                                                            );
                                                                          }

                                                                          final appointmentData =
                                                                              snapshot.data?[0] as AppointmentClinic?;
                                                                          final dogData =
                                                                              snapshot.data?[1] as DogDetailsPost?;

                                                                          if (appointmentData == null ||
                                                                              appointmentData.data.isEmpty) {
                                                                            return Text(
                                                                              'ไม่มีข้อมูลวัคซีน',
                                                                              style: TextStyle(
                                                                                fontSize: 13,
                                                                                fontWeight: FontWeight.w500,
                                                                                color: Color(0xFF916B44).withOpacity(0.6),
                                                                                fontStyle: FontStyle.italic,
                                                                              ),
                                                                            );
                                                                          }

                                                                          final vaccineName =
                                                                              appointmentData.data.first.vaccines ?? '';
                                                                          final dogName =
                                                                              dogData?.name ?? 'ไม่ระบุชื่อสุนัข';

                                                                          return Row(
                                                                            children: [
                                                                              Flexible(
                                                                                child: Text(
                                                                                  '(${dogName}) - $vaccineName',
                                                                                  style: TextStyle(
                                                                                    fontSize: 13,
                                                                                    fontWeight: FontWeight.w600,
                                                                                    color: Color(0xFF916B44),
                                                                                    height: 1.2,
                                                                                  ),
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          );
                                                                        },
                                                                      ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),

                                                        Align(
                                                          alignment: Alignment
                                                              .topRight,
                                                          child: Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical:
                                                                        4),
                                                            margin:
                                                                EdgeInsets.only(
                                                                    top: 6),
                                                            decoration:
                                                                BoxDecoration(
                                                              gradient:
                                                                  LinearGradient(
                                                                begin: Alignment
                                                                    .topLeft,
                                                                end: Alignment
                                                                    .bottomRight,
                                                                colors: [
                                                                  Color(0xFFDBA871)
                                                                      .withOpacity(
                                                                          0.15),
                                                                  Color(0xFFE9CBAF)
                                                                      .withOpacity(
                                                                          0.1),
                                                                ],
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              border:
                                                                  Border.all(
                                                                color: Color(
                                                                        0xFFDBA871)
                                                                    .withOpacity(
                                                                        0.3),
                                                                width: 1,
                                                              ),
                                                            ),
                                                            child: Text(
                                                              formatshowTime(
                                                                  item.date!),
                                                              style: TextStyle(
                                                                fontSize: 11,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Color(
                                                                    0xFF916B44),
                                                                letterSpacing:
                                                                    0.3,
                                                                height: 1.2,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),

                                                    // เวลา อยู่ขวาบน
                                                  ],
                                                ),
                                              ),

                                              SizedBox(width: 12),

                                              // Enhanced Arrow Icon with Gradient Background
                                              Container(
                                                width: 36,
                                                height: 36,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      Color(0xFFE9CBAF)
                                                          .withOpacity(0.15),
                                                      Color(0xFFE9CBAF)
                                                          .withOpacity(0.05),
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                  border: Border.all(
                                                    color: Color(0xFFE9CBAF)
                                                        .withOpacity(0.3),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: InkWell(
                                                  onTap: () {
                                                    Get.to(() =>
                                                        Vaccinehistorydetailspage(
                                                            docId: item.docId));
                                                  },
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.arrow_forward_ios,
                                                      size: 16,
                                                      color: Color(0xFF916B44),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )),

                    // Bottom Safe Area
                    SizedBox(height: 16),
                  ],
                ),
        ));
  }

  Widget buildCalendar({
    required DateTime focusedDay,
    required DateTime? selectedDay,
    required Function(DateTime selected, DateTime focused) onDaySelected,
    required Function(DateTime focused) onPageChanged,
    required List<dynamic> Function(DateTime day) eventLoader,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEF7FF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: TableCalendar<ReserveClinicFirebase>(
        locale: 'th_TH',
        firstDay: DateTime(2020, 1, 1),
        lastDay: DateTime(DateTime.now().year + 10),
        focusedDay: focusedDay,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        onDaySelected: (selected, focused) {
          setState(() {
            _focusedDay = focused;
            _selectedDay = selected;
            events = getEventsForDay(selected);
          });
        },
        onPageChanged: onPageChanged,
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            // ✅ กรองเฉพาะ event ที่มี status == 2
            final validEvents = events.where((e) => e.status == 3).toList();

            if (validEvents.isEmpty)
              return const SizedBox.shrink(); // ❌ ไม่มี status 2 = ไม่แสดงจุด

            final markerCount = validEvents.length > 3 ? 3 : validEvents.length;

            return Padding(
              padding: const EdgeInsets.only(top: 28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(markerCount, (index) {
                  return Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    decoration: const BoxDecoration(
                      color: Colors.red, // จะใช้สีอื่นก็ได้ เช่น deepOrange
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            );
          },
        ),
        eventLoader: (day) {
          final dayOnly = DateTime(day.year, day.month, day.day);

          final dayEvents = reservebookingListAll.where((item) {
            final bookingDate =
                DateTime.parse(item.date.toString()).toLocal(); // <-- แก้ตรงนี้
            final bookingDateOnly =
                DateTime(bookingDate.year, bookingDate.month, bookingDate.day);
            return bookingDateOnly == dayOnly;
          }).toList();

          final buddhistYear = day.year + 543;
          final thaiMonths = {
            1: 'มกราคม',
            2: 'กุมภาพันธ์',
            3: 'มีนาคม',
            4: 'เมษายน',
            5: 'พฤษภาคม',
            6: 'มิถุนายน',
            7: 'กรกฎาคม',
            8: 'สิงหาคม',
            9: 'กันยายน',
            10: 'ตุลาคม',
            11: 'พฤศจิกายน',
            12: 'ธันวาคม',
          };
          final thaiDate = "${day.day} ${thaiMonths[day.month]} $buddhistYear";

          // log("📅 วันที่ $thaiDate: มี ${dayEvents.length} รายการ");

          return dayEvents;
        },
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
        calendarStyle: const CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Color(0xFFE6C29C),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Color(0xFFDBA871),
            shape: BoxShape.circle,
          ),
          markersMaxCount: 3,
          markerDecoration: BoxDecoration(
            color: Colors.deepOrange,
            shape: BoxShape.circle,
          ),
          markerSize: 6.0,
        ),
      ),
    );
  }

  Future<DogDetailsPost?> getdog(int dogId) async {
    try {
      // log("🐶 Getting dog info for ID: $dogId");
      var res = await http.get(Uri.parse("$url/dog/data/$dogId"));
      if (res.statusCode == 200) {
        final List<DogDetailsPost> dogList = dogDetailsPostFromJson(res.body);
        if (dogList.isNotEmpty) {
          return dogList.first;
        }
        return null; // กรณีไม่มีข้อมูล
      } else {
        log("❌ Failed to load dog: ${res.statusCode}");
        return null;
      }
    } catch (e) {
      log("❌ Exception while fetching dog info: $e");
      return null;
    }
  }

  AppointmentClinic appointmentClinicFromJson(String str) {
    final jsonData = json.decode(str);
    if (jsonData is Map && jsonData['data'] != null) {
      return AppointmentClinic.fromJson(
        Map<String, dynamic>.from(jsonData),
      );
    }
    throw Exception("Invalid JSON format");
  }

  Future<AppointmentClinic?> getvaccine(
      String aids, String generalEmail) async {
    try {
      final res = await http
          .get(Uri.parse("$url/appointment/latestdate/$aids/$generalEmail"));

      if (res.statusCode == 200) {
        print('API response body: ${res.body}');
        return appointmentClinicFromJson(res.body);
      } else {
        log("❌ Failed to load vaccine data: ${res.statusCode}");
        return null;
      }
    } catch (e) {
      log("❌ Exception while fetching vaccine info: $e");
      return null;
    }
  }

  String formatshowTime(DateTime isoDate) {
    final date = isoDate.toLocal();

    final thaiMonths = [
      '',
      'มกราคม',
      'กุมภาพันธ์',
      'มีนาคม',
      'เมษายน',
      'พฤษภาคม',
      'มิถุนายน',
      'กรกฎาคม',
      'สิงหาคม',
      'กันยายน',
      'ตุลาคม',
      'พฤศจิกายน',
      'ธันวาคม'
    ];

    final day = date.day;
    final month = thaiMonths[date.month];
    final year = date.year + 543;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return 'เวลา $hour:$minute วันที่ $day $month $year';
  }

  List<ReserveClinicFirebase> getEventsForDay(DateTime day) {
    final normalizedDay = normalizeDate(day);

    return reservebookingListAll.where((item) {
      final eventDay = normalizeDate(item.date!); // ไม่ต้อง parse แล้ว
      return eventDay == normalizedDay;
    }).toList();
  }

  GeneralPost generalPostFromJson(String str) {
    final Map<String, dynamic> data = json.decode(str);
    return GeneralPost.fromJson(data);
  }

  Future<GeneralPost?> getGeneral(String generalEmail) async {
    try {
      var res = await http.get(Uri.parse("$url/general/$generalEmail"));
      if (res.statusCode == 200) {
        final Map<String, dynamic> jsonMap = json.decode(res.body);
        return GeneralPost.fromJson(jsonMap);
      } else {
        log("❌ Failed to load: ${res.statusCode}");
        return null;
      }
    } catch (e) {
      log("Error: $e");
      return null;
    }
  }

  Future<void> getReserve() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('reserve')
          .where('clinicEmail', isEqualTo: box.read("email"))
          .get();

      List<ReserveClinicFirebase> allData = snapshot.docs.map((doc) {
        return ReserveClinicFirebase.fromJson(doc.data(), doc.id);
      }).toList();

      allData.sort((a, b) => b.date.compareTo(a.date));
      reserveList = allData; // ตั้งค่า reserveList แทนที่เวอร์ชัน HTTP
      reservebookingListAll.clear();

      List<Future<void>> futures = [];

      for (var data in reserveList) {
        futures.add(getReserveBook(data.docId).then((bookingData) {
          if (bookingData != null) {
            try {
              final booking =
                  ReserveClinicFirebase.fromJson(bookingData, data.docId);
              reservebookingListAll.add(booking);
              log("✅ Added: ${booking.docId}");
            } catch (e) {
              log("❌ Error parsing ReserveClinicFirebase: $e");
            }
          } else {
            log("⚠️ No booking data for docId=${data.docId}");
          }
        }));
      }

      // if (allData.isNotEmpty &&
      //     (allData[0].status == 1 || allData[0].type == 1)) {
      await Future.wait(futures);

      log("Total reservebookingListAll: ${reservebookingListAll.length}");
      for (var booking in reservebookingListAll) {
        log("Booking - ID: ${booking.docId}, Date: ${booking.date}, User: ${booking.clinicEmail}");
      }
      // }
      // getGeneral(allData[0].generalEmail);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      log("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>?> getReserveBook(String docId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('reserve')
          .doc(docId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          data['docId'] = doc.id;
          return data;
        }
      } else {
        log('❌ No document found for docId=$docId');
      }
    } catch (e) {
      log('❌ Error while fetching document: $e');
    }
    return null;
  }
}
