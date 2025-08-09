import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/model/ClinicGetSchedule.dart';
import 'package:puppal_application/model/ClinicGetSpecialSchedulePost.dart';
import 'package:puppal_application/model/ClinicSchedulePost.dart';
import 'package:puppal_application/model/clinicSpecialSchedulePost.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicListDoctors.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicNotification/notificationPage.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicSetting.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicVaccineHistory/VaccineHistoryPage.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalMain.dart';
import 'package:puppal_application/pages/general/registerGeneral/registerUserGoogle.dart';
import 'package:puppal_application/pages/login/index.dart';
import 'package:shimmer/shimmer.dart';
import 'package:table_calendar/table_calendar.dart';

class Clinicopeninghours extends StatefulWidget {
  const Clinicopeninghours({super.key});

  @override
  State<Clinicopeninghours> createState() => _ClinicOpeningHoursState();
}

class _ClinicOpeningHoursState extends State<Clinicopeninghours>
    with SingleTickerProviderStateMixin {
  final List<String> weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  final List<String> weekdaysShort = ['จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'];

  final List<String> weekdaysThai = [
    'จันทร์',
    'อังคาร',
    'พุธ',
    'พฤหัสบดี',
    'ศุกร์',
    'เสาร์',
    'อาทิตย์'
  ];

  late double screenWidth;
  late double screenHeight;
  List<String> selectedWeekdays = [];
  TimeOfDay? openTime;
  TimeOfDay? closeTime;
  final List<DateTime> specialHolidays = [];
  String url = '';
  final box = GetStorage();
  List<ClinicGetSchedule> scheduleList = [];
  List<ClinicGetSpecialSchedulePost> specialScheduleList = [];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Colors
  static const Color primaryColor = Color(0xFF916B44);
  static const Color secondaryColor = Color(0xFFDBA871);
  static const Color tertiaryColor = Color(0xFFE9CBAF);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    initialize();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> initialize() async {
    final config = await Configuration.getConfig();
    url = config['apiEndPoint'];
    await getClinicSchedule();
    await getspecialSchedule();
  }

  void _showCustomTimePicker({required bool isOpenTime}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => TimePickerBottomSheet(
        initialTime: isOpenTime ? openTime : closeTime,
        isOpenTime: isOpenTime,
        onTimeSelected: (time) {
          setState(() {
            if (isOpenTime) {
              openTime = time;
            } else {
              closeTime = time;
            }
          });
        },
      ),
    );
  }

  void _pickHolidayDate() {
    FocusScope.of(context).requestFocus(FocusNode());

    DateTime selectedDate = DateTime.now();
    DateTime focusedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Color(0xFFFAF8F5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFFDBA871),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'เลือกวันหยุดพิเศษ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              content: Container(
                width: double.maxFinite,
                height: screenHeight * 0.525,
                child: TableCalendar<DateTime>(
                  firstDay: DateTime.now().subtract(Duration(days: 365)),
                  lastDay: DateTime.now().add(Duration(days: 365)),
                  focusedDay: focusedDate,
                  selectedDayPredicate: (day) {
                    return isSameDay(selectedDate, day);
                  },
                  calendarFormat: CalendarFormat.month,
                  startingDayOfWeek: StartingDayOfWeek.sunday,
                  locale: 'th',
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    weekendTextStyle: TextStyle(
                      color: Color(0xFF916B44),
                      fontWeight: FontWeight.w600,
                    ),
                    defaultTextStyle: TextStyle(
                      color: Color(0xFF916B44),
                      fontWeight: FontWeight.w600,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Color(0xFFDBA871),
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Color(0xFF916B44).withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: Color(0xFF916B44),
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: Color(0xFF916B44),
                    ),
                    titleTextStyle: TextStyle(
                      color: Color(0xFF916B44),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    titleTextFormatter: (date, locale) {
                      int buddhistYear = date.year + 543;
                      String monthName = DateFormat.MMMM('th').format(date);
                      return '$monthName พ.ศ. $buddhistYear';
                    },
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      color: Color(0xFF916B44),
                      fontWeight: FontWeight.w600,
                    ),
                    weekendStyle: TextStyle(
                      color: Color(0xFF916B44),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      selectedDate = selectedDay;
                      focusedDate = focusedDay;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    setState(() {
                      focusedDate = focusedDay;
                    });
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'ยกเลิก',
                    style: TextStyle(
                      color: Color(0xFF916B44),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final cleanedDate = DateTime(selectedDate.year,
                        selectedDate.month, selectedDate.day);
                    if (!specialHolidays.contains(cleanedDate)) {
                      this.setState(() => specialHolidays.add(cleanedDate));
                    }
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFDBA871),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'เพิ่มวันหยุด',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: tertiaryColor.withOpacity(0.3),
      appBar: AppBar(
        title: const Text(
          "กำหนดเวลาเปิด-ปิดคลินิก",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: secondaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF916B44)),
        //   onPressed: () => Navigator.pop(context),
        // ),
      ),
      // drawer: Drawer(
      //   child: Container(
      //     decoration: BoxDecoration(
      //       image: DecorationImage(
      //         image: AssetImage('assets/images/indexBg.png'),
      //         fit: BoxFit.cover,
      //       ),
      //     ),
      //     child: Container(
      //       decoration: BoxDecoration(
      //         color: Colors.white.withOpacity(0.85),
      //         borderRadius: BorderRadius.only(
      //           topRight: Radius.circular(30),
      //           bottomRight: Radius.circular(30),
      //         ),
      //         boxShadow: [
      //           BoxShadow(
      //             color: Colors.black.withOpacity(0.15),
      //             blurRadius: 10,
      //             offset: Offset(2, 2),
      //           ),
      //         ],
      //       ),
      //       child: ListView(
      //         padding: EdgeInsets.zero,
      //         children: [
      //           DrawerHeader(
      //             decoration: BoxDecoration(
      //               color: secondaryColor,
      //               borderRadius: BorderRadius.only(
      //                 topRight: Radius.circular(30),
      //               ),
      //             ),
      //             child: Column(
      //               crossAxisAlignment: CrossAxisAlignment.center,
      //               children: [
      //                 ClipOval(
      //                   child: Image.network(
      //                     box.read('clinicImage'),
      //                     width: screenWidth * 0.2,
      //                     height: screenWidth * 0.2,
      //                     fit: BoxFit.cover,
      //                     loadingBuilder: (context, child, loadingProgress) {
      //                       if (loadingProgress == null) return child;
      //                       return Shimmer.fromColors(
      //                         baseColor: Colors.grey[300]!,
      //                         highlightColor: Colors.grey[100]!,
      //                         child: Container(
      //                           width: screenWidth * 0.2,
      //                           height: screenWidth * 0.2,
      //                           color: Colors.white,
      //                         ),
      //                       );
      //                     },
      //                   ),
      //                 ),
      //                 SizedBox(height: 10),
      //                 Text(
      //                   box.read('clinicName') ?? "ผู้ใช้งาน",
      //                   style: TextStyle(
      //                     color: Colors.white,
      //                     fontSize: 20,
      //                     fontWeight: FontWeight.bold,
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ),
      //           ListTile(
      //             leading: Icon(Icons.home, color: Color(0xFF916b44)),
      //             title: Text('หน้าหลัก'),
      //           ),
      //           ListTile(
      //             leading: Icon(Icons.system_security_update,
      //                 color: Color(0xFF916b44)),
      //             title: Text('คำขอฉีดยา'),
      //             onTap: () {
      //               Get.back();
      //               Get.to(() => VaccineRequestsPage());
      //             },
      //           ),
      //           ListTile(
      //             leading: Icon(Icons.notifications, color: Color(0xFF916b44)),
      //             title: Text('แจ้งเตือน'),
      //             onTap: () {
      //               Get.back();
      //               Get.to(() => Notificationpage());
      //             },
      //           ),
      //           ListTile(
      //             leading:
      //                 Icon(Icons.medical_services, color: Color(0xFF916b44)),
      //             title: Text('ประวัติการฉีดยา'),
      //             onTap: () {
      //               Get.back();
      //               Get.to(() => Vaccinehistorypage());
      //             },
      //           ),
      //           ListTile(
      //             leading: Icon(Icons.supervised_user_circle,
      //                 color: Color(0xFF916b44)),
      //             title: Text('หมอประจำคลินิก'),
      //             onTap: () {
      //               Get.back();
      //               Get.to(() => Cliniclistdoctors());
      //             },
      //           ),
      //           ListTile(
      //             leading:
      //                 Icon(Icons.medical_services, color: Color(0xFF916b44)),
      //             title: Text('เวลาปิด-เปิด'),
      //             onTap: () => Get.to(() => Clinicopeninghours()),
      //           ),
      //           ListTile(
      //             leading: Icon(Icons.settings, color: Color(0xFF916b44)),
      //             title: Text('ตั้งค่า'),
      //             onTap: () => Get.to(() => Clinicsetting()),
      //           ),
      //           ListTile(
      //             leading:
      //                 Icon(MdiIcons.accountSwitch, color: Color(0xFF916b44)),
      //             title: Text('สลับโหมด'),
      //             onTap: () async {
      //               var resGeneral = await http.get(
      //                   Uri.parse("$url/general/name/${box.read('email')}"));
      //               if (resGeneral.statusCode == 200) {
      //                 showAlert(
      //                   title: 'สลับไปยังบัญชีผู้ใช้ทั่วไป?',
      //                   message: 'กด ตกลง เพื่อไปยังบัญชีผู้ใช้ทั่วไป',
      //                   onConfirm: () {
      //                     box.write('type', 'general');
      //                     box.write('generalName',
      //                         jsonDecode(resGeneral.body)['username']);
      //                     box.write('generalImage',
      //                         jsonDecode(resGeneral.body)['image']);
      //                     log('Name ${box.read('generalName')}');
      //                     Get.offAll(() => GeneralmainPage());
      //                   },
      //                 );
      //               } else {
      //                 showAlert(
      //                   title: 'คุณยังไม่มีบัญชีผู้ใช้ทั่วไป!',
      //                   message: 'กด ตกลง เพื่อไปยังหน้าสมัครผู้ใช้ทั่วไป',
      //                   onConfirm: () {
      //                     Get.back();
      //                     Get.to(() => RegisterusergooglePage());
      //                   },
      //                 );
      //               }
      //             },
      //           ),
      //           ListTile(
      //             leading: Icon(Icons.logout, color: Colors.redAccent),
      //             title: Text('ออกจากระบบ'),
      //             onTap: () {
      //               showAlert(
      //                 title: 'ออกจากระบบ?',
      //                 message: 'คุณต้องการออกจากระบบใช่หรือไม่',
      //                 onConfirm: () async {
      //                   await FirebaseMessaging.instance.deleteToken();
      //                   box.erase();
      //                   Get.offAll(() => IndexPage());
      //                 },
      //               );
      //             },
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
      // ),

      body: Container(
        color: Color(0xFFFAF8F5),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWeekdaysSection(),
                const SizedBox(height: 24),
                _buildTimeSection(),
                const SizedBox(height: 24),
                _buildHolidaySection(),
                const SizedBox(height: 32),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeekdaysSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                "เลือกวันเปิดทำการ",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(weekdays.length, (index) {
              final day = weekdays[index];
              final dayThai = weekdaysThai[index];
              final dayShort = weekdaysShort[index];
              final selected = selectedWeekdays.contains(day);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (selected) {
                      selectedWeekdays.remove(day);
                    } else {
                      selectedWeekdays.add(day);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: selected ? primaryColor : Colors.white,
                    border: Border.all(
                      color: selected
                          ? primaryColor
                          : secondaryColor.withOpacity(0.5),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayShort,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: selected ? Colors.white : primaryColor,
                        ),
                      ),
                      Text(
                        dayThai.substring(0, 2),
                        style: TextStyle(
                          fontSize: 10,
                          color: selected
                              ? Colors.white.withOpacity(0.8)
                              : primaryColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time,
                color: primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                "กำหนดเวลาทำการ",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTimeCard(
                  title: "เวลาเปิด",
                  time: openTime,
                  icon: Icons.wb_sunny,
                  onTap: () => _showCustomTimePicker(isOpenTime: true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimeCard(
                  title: "เวลาปิด",
                  time: closeTime,
                  icon: Icons.nightlight_round,
                  onTap: () => _showCustomTimePicker(isOpenTime: false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard({
    required String title,
    required TimeOfDay? time,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              tertiaryColor,
              tertiaryColor.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: secondaryColor.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: primaryColor,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: primaryColor.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time?.format(context) ?? "กำหนดเวลา",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHolidaySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.event_busy,
                    color: primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "วันหยุดพิเศษ",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _pickHolidayDate,
                icon: const Icon(
                  Icons.add,
                  size: 20,
                  color: Colors.white,
                ),
                label: const Text(
                  "เพิ่มวันหยุด",
                  style: TextStyle(fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryColor,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (specialHolidays.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: tertiaryColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: secondaryColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: primaryColor.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "ยังไม่มีวันหยุดพิเศษ",
                    style: TextStyle(
                      color: primaryColor.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: List.generate(specialHolidays.length, (index) {
                final d = specialHolidays[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: tertiaryColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: secondaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.calendar_month,
                        color: primaryColor,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      formatThaiDateTime(d),
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      onPressed: () async {
                        if (index < specialScheduleList.length) {
                          final id =
                              specialScheduleList[index].specialScheduleId;
                          await deleteSpecialSchedule(id);
                          setState(() {
                            specialScheduleList.removeAt(index);
                            specialHolidays.removeAt(index);
                          });
                        } else {
                          setState(() {
                            specialHolidays.removeAt(index);
                          });
                        }
                      },
                    ),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        // gradient: LinearGradient(
        //   colors: [primaryColor, secondaryColor],
        //   begin: Alignment.centerLeft,
        //   end: Alignment.centerRight,
        // ),
        color: primaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => updateSchedule(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.save,
              color: Colors.white,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              "บันทึกการตั้งค่า",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Keep all your existing methods (getClinicSchedule, updateSchedule, etc.)
  Future<void> getClinicSchedule() async {
    final clinicEmail = box.read('email');
    log(clinicEmail);
    final res = await http.get(Uri.parse("$url/schedule/$clinicEmail"));

    if (res.statusCode == 200) {
      scheduleList = clinicGetScheduleFromJson(res.body);

      if (scheduleList.isNotEmpty) {
        final schedule = scheduleList.first;
        setState(() {
          selectedWeekdays.clear();
          selectedWeekdays.addAll(schedule.weekdays.split(','));

          final openParts = schedule.openTime.split(":");
          final closeParts = schedule.closeTime.split(":");

          openTime = TimeOfDay(
            hour: int.parse(openParts[0]),
            minute: int.parse(openParts[1]),
          );

          closeTime = TimeOfDay(
            hour: int.parse(closeParts[0]),
            minute: int.parse(closeParts[1]),
          );
        });
      }
      await deleteSpecialScheduleExpired();
    } else {
      log("❌ ไม่สามารถดึงข้อมูลตารางเวลาได้: ${res.statusCode}");
    }
  }

  Future<void> updateSchedule() async {
    showLoadingDialog();

    bool isConfirmed = await confirmDialog(context);
    if (!isConfirmed) {
      log("ผู้ใช้ยกเลิกการบันทึก");
      return;
    }
    final clinicEmail = box.read('email');
    ClinicSchedulePost req = ClinicSchedulePost(
      weekdays: selectedWeekdays.join(','),
      openTime:
          "${openTime!.hour.toString().padLeft(2, '0')}:${openTime!.minute.toString().padLeft(2, '0')}",
      closeTime:
          "${closeTime!.hour.toString().padLeft(2, '0')}:${closeTime!.minute.toString().padLeft(2, '0')}",
    );

    final res = await http.put(
      Uri.parse("$url/schedule/$clinicEmail"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(req),
    );

    if (res.statusCode == 200) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: const Text("บันทึกสำเร็จ"),
      //     backgroundColor: primaryColor,
      //     behavior: SnackBarBehavior.floating,
      //     shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(8),
      //     ),
      //   ),
      // );

      if (specialHolidays.isNotEmpty) {
        await insertSpecialSchedule();
      }
      Get.back();
    } else {
      log("❌ บันทึกข้อมูลไม่สำเร็จ: ${res.statusCode}");
    }
  }

  Future<void> getspecialSchedule() async {
    final clinicEmail = box.read('email');
    final res = await http.get(Uri.parse("$url/specialschedule/$clinicEmail"));

    if (res.statusCode == 200) {
      specialScheduleList = clinicGetSpecialSchedulePostFromJson(res.body);
      specialHolidays.clear();
      for (var item in specialScheduleList) {
        final localDate = item.date.toLocal();
        final cleanedDate =
            DateTime(localDate.year, localDate.month, localDate.day);
        specialHolidays.add(cleanedDate);
        formatThaiDateTime(localDate);
      }

      setState(() {});
    } else {
      log("❌ ไม่สามารถดึงวันหยุดพิเศษได้: ${res.statusCode}");
    }
  }

  Future<void> insertSpecialSchedule() async {
    final clinicEmail = box.read('email');

    final existingDates = specialScheduleList.map((e) {
      final local = e.date.toLocal();
      return DateTime(local.year, local.month, local.day);
    }).toSet();

    for (DateTime holiday in specialHolidays) {
      final cleaned = DateTime(holiday.year, holiday.month, holiday.day);
      if (!existingDates.contains(cleaned)) {
        final req = ClinicSpecialSchedulePost(
          clinicEmail: clinicEmail,
          date: cleaned,
        );

        final res = await http.post(
          Uri.parse("$url/specialschedule"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(req),
        );

        if (res.statusCode == 200 || res.statusCode == 201) {
          log("✅ เพิ่มวันหยุดพิเศษสำเร็จ: $cleaned");
        } else {
          log("❌ เพิ่มวันหยุดพิเศษล้มเหลว: ${res.statusCode}");
        }
      }
    }
  }

  Future<void> deleteSpecialSchedule(int id) async {
    final res = await http.delete(
      Uri.parse("$url/specialschedule/$id"),
    );

    if (res.statusCode == 200) {
      log("✅ ลบวันหยุดพิเศษสำเร็จ: $id");
      setState(() {});
    } else {
      log("❌ ลบวันหยุดพิเศษล้มเหลว: ${res.statusCode}");
    }
  }

  Future<void> deleteSpecialScheduleExpired() async {
    try {
      final res = await http.delete(
        Uri.parse("$url/specialschedule/expired"),
      );

      if (res.statusCode == 200) {
        log("✅ ลบวันหยุดพิเศษสำเร็จ");
        setState(() {}); // ถ้ามีการแสดงผล list ก็รีเฟรชได้
      } else {
        log("❌ ลบวันหยุดพิเศษล้มเหลว: ${res.statusCode}");
      }
    } catch (e) {
      log("❌ เกิดข้อผิดพลาดขณะลบวันหยุดพิเศษ: $e");
    }
  }

  String formatThaiDateTime(DateTime date) {
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

    final localDate = date.toLocal();
    final day = localDate.day;
    final month = thaiMonths[localDate.month];
    final year = localDate.year + 543;

    return '$day $month $year';
  }

  Future<bool> confirmDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          barrierDismissible: false, // ป้องกันการปิดโดยการแตะข้างนอก
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(
                color: Color(0xFF916B44),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center, // กลางแนวนอน
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF916B44),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.timelapse,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "ยืนยันการบันทึก",
                  style: TextStyle(
                    color: Color(0xFF916B44),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "คุณต้องการบันทึกข้อมูลการฉีดวัคซีนหรือไม่?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF916B44),
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.center, // ปุ่มอยู่ตรงกลาง
            actionsPadding: const EdgeInsets.only(bottom: 12, top: 4),
            actions: [
              // ปุ่มยกเลิก
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: const Color(0xFF916B44),
                    width: 1.5,
                  ),
                ),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF916B44),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "ยกเลิก",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // ปุ่มยืนยัน
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF916B44),
                      Color(0xFFDBA871),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF916B44).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "ยืนยัน",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  void showLoadingDialog({String? message}) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: const Color(0xFFF5F0E8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFD7CCC8),
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFFA1887F)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  message ?? "กำลังโหลด...",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFFA1887F),
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void showAlert({
    required String title,
    required String message,
    VoidCallback? onConfirm,
  }) {
    Get.defaultDialog(
      title: '',
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.all(16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon with subtle animation potential
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFD7CCC8),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.info_outline_rounded,
              size: 24,
              color: const Color(0xFFA1887F),
            ),
          ),

          const SizedBox(height: 16),

          // Title with better typography
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Color(0xFF8D6E63),
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Message with improved readability
          Text(
            message,
            style: const TextStyle(
              color: Color(0xFFA1887F),
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Enhanced button row
          Row(
            children: [
              // Cancel button
              Expanded(
                child: Container(
                  height: 40,
                  child: TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF8D6E63),
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: const Color(0xFFD7CCC8),
                          width: 1,
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'ยกเลิก',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),
              // Confirm button
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xFF795548),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFA1887F).withOpacity(0.3),
                        offset: const Offset(0, 2),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      if (onConfirm != null) onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'ตกลง',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F0E8),
      barrierDismissible: false,
      radius: 16,
    );
  }
}

// Time Picker Bottom Sheet using time_picker_spinner package
class TimePickerBottomSheet extends StatefulWidget {
  final bool isOpenTime;
  final TimeOfDay? initialTime;
  final Function(TimeOfDay) onTimeSelected;

  const TimePickerBottomSheet({
    Key? key,
    required this.isOpenTime,
    this.initialTime,
    required this.onTimeSelected,
  }) : super(key: key);

  @override
  State<TimePickerBottomSheet> createState() => _TimePickerBottomSheetState();
}

class _TimePickerBottomSheetState extends State<TimePickerBottomSheet> {
  late int selectedHour;
  late int selectedMinute;

  static const Color primaryColor = Color(0xFF916B44);
  static const Color secondaryColor = Color(0xFFDBA871);
  static const Color tertiaryColor = Color(0xFFE9CBAF);

  // เวลาที่เหมาะสมสำหรับคลินิก
  List<int> get availableHours {
    if (widget.isOpenTime) {
      // เวลาเปิด: 6:00 - 12:00
      return List.generate(7, (index) => 6 + index); // 6,7,8,9,10,11,12
    } else {
      // เวลาปิด: 12:00 - 22:00
      return List.generate(
          11, (index) => 12 + index); // 12,13,14,15,16,17,18,19,20,21,22
    }
  }

  // นาทีทีละ 30 นาที
  List<int> get availableMinutes => [0, 30];

  @override
  void initState() {
    super.initState();
    final time = widget.initialTime ??
        (widget.isOpenTime
            ? TimeOfDay(hour: 8, minute: 0)
            : TimeOfDay(hour: 17, minute: 0));

    selectedHour = time.hour;
    selectedMinute = time.minute;

    // ปรับให้อยู่ในช่วงที่เหมาะสม
    if (!availableHours.contains(selectedHour)) {
      selectedHour = availableHours.first;
    }
    if (!availableMinutes.contains(selectedMinute)) {
      selectedMinute = availableMinutes.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.isOpenTime
                      ? "เลือกเวลาเปิดคลินิก"
                      : "เลือกเวลาปิดคลินิก",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Icon(
                  widget.isOpenTime ? Icons.wb_sunny : Icons.nightlight_round,
                  color: Colors.white,
                  size: 28,
                ),
              ],
            ),
          ),

          // Time Display
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: tertiaryColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: secondaryColor.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Text(
              "${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}",
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: primaryColor,
                letterSpacing: 2,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: 20),

          // Beautiful Time Picker with Cream Highlight
          Expanded(
            child: Column(
              children: [
                // SizedBox(height: 10),
                // Text(
                //   'เลือกเวลา',
                //   style: TextStyle(
                //     fontSize: 18,
                //     fontWeight: FontWeight.bold,
                //     color: primaryColor,
                //   ),
                // ),
                SizedBox(height: 10),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Color(0xFFFAF2EA), // สีครีมอ่อน
                      border: Border.all(
                        color: secondaryColor.withOpacity(0.5),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.1),
                          blurRadius: 15,
                          offset: Offset(0, 5),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Cream highlight bar ครอบทั้งชั่วโมงและนาที
                        Positioned.fill(
                          child: Center(
                            child: Container(
                              height: 55,
                              margin: EdgeInsets.symmetric(horizontal: 15),
                              decoration: BoxDecoration(
                                color: Color(0xFFE9CBAF)
                                    .withOpacity(0.6), // สีครีมเข้มขึ้น
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: primaryColor.withOpacity(0.2),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Time Pickers Row
                        Row(
                          children: [
                            // Hour Picker
                            Expanded(
                              flex: 2,
                              child: ListWheelScrollView.useDelegate(
                                itemExtent: 50,
                                diameterRatio: 2.5,
                                perspective: 0.002,
                                squeeze: 1.0,
                                physics: FixedExtentScrollPhysics(),
                                controller: FixedExtentScrollController(
                                  initialItem:
                                      availableHours.indexOf(selectedHour),
                                ),
                                onSelectedItemChanged: (index) {
                                  setState(() {
                                    selectedHour = availableHours[index];
                                  });
                                },
                                childDelegate: ListWheelChildBuilderDelegate(
                                  childCount: availableHours.length,
                                  builder: (context, index) {
                                    if (index < 0 ||
                                        index >= availableHours.length)
                                      return null;
                                    final hour = availableHours[index];
                                    final isSelected = hour == selectedHour;

                                    return Opacity(
                                      opacity: (index -
                                                      availableHours.indexOf(
                                                          selectedHour))
                                                  .abs() <=
                                              1
                                          ? 1.0
                                          : 0.3,
                                      child: Center(
                                        child: Text(
                                          hour.toString().padLeft(2, '0'),
                                          style: TextStyle(
                                            fontSize: isSelected ? 28 : 22,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? primaryColor
                                                : primaryColor.withOpacity(0.6),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            // Colon separator (:)
                            Container(
                              width: 20,
                              child: Center(
                                child: Text(
                                  ':',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ),

                            // Minute Picker
                            Expanded(
                              flex: 2,
                              child: ListWheelScrollView.useDelegate(
                                itemExtent: 50,
                                diameterRatio: 2.5,
                                perspective: 0.002,
                                squeeze: 1.0,
                                physics: FixedExtentScrollPhysics(),
                                controller: FixedExtentScrollController(
                                  initialItem:
                                      availableMinutes.indexOf(selectedMinute),
                                ),
                                onSelectedItemChanged: (index) {
                                  setState(() {
                                    selectedMinute = availableMinutes[index];
                                  });
                                },
                                childDelegate: ListWheelChildBuilderDelegate(
                                  childCount: availableMinutes.length,
                                  builder: (context, index) {
                                    if (index < 0 ||
                                        index >= availableMinutes.length)
                                      return null;
                                    final minute = availableMinutes[index];
                                    final isSelected = minute == selectedMinute;

                                    return Opacity(
                                      opacity: (index -
                                                      availableMinutes.indexOf(
                                                          selectedMinute))
                                                  .abs() <=
                                              1
                                          ? 1.0
                                          : 0.3,
                                      child: Center(
                                        child: Text(
                                          minute.toString().padLeft(2, '0'),
                                          style: TextStyle(
                                            fontSize: isSelected ? 28 : 22,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? primaryColor
                                                : primaryColor.withOpacity(0.6),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),

          // Buttons
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      // backgroundColor: Colors.grey.shade,
                      side: BorderSide(color: primaryColor, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "ยกเลิก",
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: primaryColor,
                      // gradient: LinearGradient(
                      //   colors:primaryColor,
                      // ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onTimeSelected(
                          TimeOfDay(hour: selectedHour, minute: selectedMinute),
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "ตกลง",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
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
  }
}
