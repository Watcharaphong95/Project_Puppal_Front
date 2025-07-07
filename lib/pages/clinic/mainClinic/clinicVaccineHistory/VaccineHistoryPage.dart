import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/model/reserveClinicPost.dart';
import 'package:puppal_application/model/reservebooking.dart';
import 'package:http/http.dart' as http;
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
  List<ReserveClinicPost> reserveList = [];
  List<Reservebooking> reservebookingList = [];
  List<Reservebooking> events = [];
  List<Reservebooking> reservebookingListAll = [];

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
                            "การจองวันนี้",
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
                                      color: Color(0xFFE9CBAF).withOpacity(0.3),
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
                                    "ยังไม่มีข้อมูล",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF916B44),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "โปรดเลือกวันที่เพื่อดูข้อมูล",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF916B44).withOpacity(0.6),
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
                                  margin: EdgeInsets.only(bottom: 12),
                                  child: InkWell(
                                    onTap: () {
                                      // _showAppointmentPopup(
                                      //     context, reservebookingList.first);
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0xFF916B44)
                                                .withOpacity(0.08),
                                            blurRadius: 12,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                        border: Border.all(
                                          color: Color(0xFFE9CBAF)
                                              .withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            // Profile Image
                                            Container(
                                              width: 56,
                                              height: 56,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Color(0xFF916B44)
                                                        .withOpacity(0.1),
                                                    blurRadius: 8,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                child: Image.network(
                                                  item.image,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Container(
                                                      decoration: BoxDecoration(
                                                        color: Color(0xFFE9CBAF)
                                                            .withOpacity(0.3),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                      ),
                                                      child: Icon(
                                                        Icons.person,
                                                        color:
                                                            Color(0xFF916B44),
                                                        size: 28,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 16),

                                            // Content
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Name and Time Row
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          item.username,
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Color(
                                                                0xFF916B44),
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                      Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 8,
                                                                vertical: 4),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Color(
                                                                  0xFFE9CBAF)
                                                              .withOpacity(0.3),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        child: Text(
                                                          formatshowTime(
                                                              item.date!),
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Color(
                                                                0xFF916B44),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 8),

                                                  // Vaccine Info
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 6,
                                                        height: 6,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Color(0xFFDBA871),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(3),
                                                        ),
                                                      ),
                                                      SizedBox(width: 8),
                                                      Expanded(
                                                        child: Text(
                                                          item.appointmentName
                                                              .toString(),
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Color(
                                                                    0xFF916B44)
                                                                .withOpacity(
                                                                    0.7),
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Arrow Icon
                                            InkWell(
                                              onTap: () {
                                                Get.to(() =>
                                                    Vaccinehistorydetailspage(
                                                        reserveId:
                                                            item.reserveId));
                                              },
                                              child: Icon(
                                                Icons.arrow_forward_ios,
                                                size: 16,
                                                color: Color(0xFF916B44)
                                                    .withOpacity(0.4),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),

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
      child: TableCalendar<Reservebooking>(
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

  List<Reservebooking> getEventsForDay(DateTime day) {
    final normalizedDay = normalizeDate(day);

    return reservebookingListAll.where((item) {
      final eventDay = normalizeDate(item.date!); // ไม่ต้อง parse แล้ว
      return eventDay == normalizedDay;
    }).toList();
  }

  Future<void> getReserve() async {
    try {
      final res =
          await http.get(Uri.parse("$url/reserve/${box.read("email")}"));
      if (res.statusCode == 200) {
        reserveList = reserveClinicPostFromJson(res.body);
        reservebookingListAll.clear();

        // สร้าง List ของ Future เพื่อรอให้ทุก request เสร็จ
        List<Future<void>> futures = [];
        for (var data in reserveList) {
          futures.add(getReserveBook(data.reserveId));
        }

        // รอให้ทุก Future เสร็จสิ้น
        await Future.wait(futures);

        // Debug: แสดงข้อมูลทั้งหมดที่ได้
        log("Total reservebookingListAll: ${reservebookingListAll.length}");
        for (var booking in reservebookingListAll) {
          log("Booking - ID: ${booking.reserveId}, Date: ${booking.date}, User: ${booking.username}");
        }

        setState(() {
          // events = getEventsForDay(_selectedDay ?? DateTime.now());
          isLoading = false;
        });
      }
    } catch (e) {
      log("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getReserveBook(int reserveID) async {
    try {
      var res = await http.get(Uri.parse("$url/reserve/group/$reserveID"));

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);

        // เคลียร์รายการก่อนเพิ่ม (ถ้าต้องการ)
        reservebookingList.clear();

        decoded.forEach((key, value) {
          // value คือลิสต์ของ reserve
          for (var item in value) {
            final reserve = Reservebooking.fromJson(item);
            reservebookingList.add(reserve);
            reservebookingListAll.add(reserve); // เพิ่มใน list รวม

            // debug logs
            log("reserveId: ${reserve.reserveId}");
            log("date: ${reserve.date}");
            log("username: ${reserve.username}");
          }
        });
      } else {
        log("Failed to load: ${res.statusCode}");
      }
    } catch (e) {
      log("Error in getReserveBook: $e");
    }
  }
}
