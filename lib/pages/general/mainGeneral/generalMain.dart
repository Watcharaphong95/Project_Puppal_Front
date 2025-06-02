import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalDog.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalGuide.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalNotification.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalProfile.dart';
import 'package:puppal_application/pages/general/recordDog/generalRecordSearch.dart';
import 'package:puppal_application/pages/login/index.dart';
import 'package:table_calendar/table_calendar.dart';

class GeneralmainPage extends StatefulWidget {
  const GeneralmainPage({super.key});

  @override
  State<GeneralmainPage> createState() => _GeneralmainPageState();
}

class _GeneralmainPageState extends State<GeneralmainPage> {
  late double screenWidth;
  late double screenHeight;
  final box = GetStorage();

  var _selectedDay;
  var _focusedDay = DateTime.now();
  var events = [];

  Map<String, String> vaccineNameMap = {
    '1': 'วัคซีนรวม 5 โรค (DHPPiL)',
    '2': 'วัคซีนพิษสุนัขบ้า',
    '3': 'วัคซีนป้องกันโรคไข้ฉี่หนู',
    '4': 'วัคซีนป้องกันเชื้อ Bordetella bronchiseptica',
    '5': 'วัคซีนป้องกันโรคลายม์',
    '6': 'วัคซีนป้องกันเชื้อโคโรนาไวรัส',
    '7': 'วัคซีนถ่ายพยาธิ',
  };

  Map<String, Map<String, List<int>>> vaccineScheduleWeeks = {
    '1': {
      'baby': [8, 12, 16], // age if dog no need to + birthday if dog not mature
      'mature': [0, 3], //need birthday + week for next vacination
      'boost': [52] // 52 every year, 26 6 month
    },
    '2': {
      'baby': [12],
      'mature': [0],
      'boost': [52]
    },
    '3': {
      'baby': [8, 11],
      'mature': [0, 3],
      'boost': [52]
    },
    '4': {
      'baby': [8, 12, 16],
      'mature': [0, 3],
      'boost': [52]
    },
    '5': {
      'baby': [12, 15],
      'mature': [0, 3],
      'boost': [52]
    },
    '6': {
      'baby': [9, 12],
      'mature': [0, 3],
      'boost': [52]
    },
    '7': {
      'baby': [8, 11],
      'mature': [0, 3],
      'boost': [26]
    },
  };

  final Map<DateTime, List<String>> eventMap = {
    DateTime(2025, 6, 5): ['Meeting', 'Birthday'],
    DateTime(2025, 6, 10): ['Conference'],
    DateTime(2025, 6, 15): ['Workshop'],
  };

  @override
  void initState() {
    if (box.read('focusedDay') != null) {
      _focusedDay = box.read('focusedDay');
      _selectedDay = box.read('focusedDay');
      events = getEventsForDay(_selectedDay);
      log(_focusedDay.toString());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('หน้าหลัก'),
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/indexBg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Color(0xFF916b44),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.person, size: 50, color: Colors.white),
                      SizedBox(height: 10),
                      Text(
                        box.read('email') ?? "ผู้ใช้งาน",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(
                    FontAwesomeIcons.house,
                    color: Color(0xFF916b44),
                  ),
                  title: Text(
                    'หน้าหลัก',
                    style: TextStyle(
                      color: Color(0xFF916b44),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(FontAwesomeIcons.solidBell,
                      color: Color(0xFF916b44)),
                  title: Text('การแจ้งเตือน'),
                  onTap: () {
                    Get.to(() => GeneralnotificationPage());
                  },
                ),
                ListTile(
                  leading: Icon(FontAwesomeIcons.dog, color: Color(0xFF916b44)),
                  title: Text('สุนัข'),
                  onTap: () {
                    Get.to(() => GeneraldogPage());
                  },
                ),
                ListTile(
                  leading:
                      Icon(FontAwesomeIcons.syringe, color: Color(0xFF916b44)),
                  title: Text('ประวัติการฉีดยา'),
                  onTap: () {
                    Get.to(() => GeneralrecordsearchPage());
                  },
                ),
                ListTile(
                  leading: Icon(FontAwesomeIcons.userLarge,
                      color: Color(0xFF916b44)),
                  title: Text('โปรไฟล์'),
                  onTap: () {
                    Get.to(() => GeneralprofilePage());
                  },
                ),
                ListTile(
                  leading: Icon(Icons.menu_book, color: Color(0xFF916b44)),
                  title: Text('คู่มือ'),
                  onTap: () {
                    Get.to(() => GeneralguidePage());
                  },
                ),
                ListTile(
                  leading:
                      Icon(FontAwesomeIcons.doorOpen, color: Colors.redAccent),
                  title: Text('ออกจากระบบ'),
                  onTap: () {
                    showAlert(
                      context: context,
                      title: 'ออกจากระบบ?',
                      message: 'คุณต้องการออกจากระบบใช่หรือไม่',
                      onConfirm: () {
                        box.erase();
                        Get.to(() => IndexPage());
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: PopScope(
          canPop: false,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: SizedBox(
                    width: screenWidth * 0.9,
                    child: TableCalendar(
                      locale: 'th_TH',
                      firstDay: DateTime(2020, 1, 1),
                      lastDay: DateTime(DateTime.now().year + 10),
                      focusedDay: _focusedDay,
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                            color: Color(0xFFE6C29C), shape: BoxShape.circle),
                        selectedDecoration: BoxDecoration(
                            color: Color(0xFFDBA871), shape: BoxShape.circle),
                      ),
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _focusedDay = focusedDay;
                          _selectedDay = selectedDay;
                          box.write('focusedDay', focusedDay);
                          events = getEventsForDay(_selectedDay);
                        });
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                      eventLoader: getEventsForDay,
                    ),
                  ),
                ),
                if (events.isNotEmpty)
                  SizedBox(
                    width: screenWidth,
                    height: screenHeight * 0.5,
                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          // physics: NeverScrollableScrollPhysics(),
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: Icon(Icons.event),
                              title: Text(events[index]),
                            );
                          },
                        )
                      ],
                    ),
                  )
                else
                  SizedBox(
                    width: screenWidth,
                    height: screenHeight * 0.5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ไม่มีข้อมูลในวันนี้',
                          style: TextStyle(fontSize: 32, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
              ],
            ),
          )),
    );
  }

  List<String> getEventsForDay(DateTime day) {
    final events = eventMap.entries
        .where((entry) =>
            entry.key.year == day.year &&
            entry.key.month == day.month &&
            entry.key.day == day.day)
        .expand((entry) => entry.value)
        .toList();

    return events;
  }

  void showAlert({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFF3F3),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF795548),
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.black87),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style:
                TextButton.styleFrom(foregroundColor: const Color(0xFF795548)),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (onConfirm != null) onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF795548),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }
}
