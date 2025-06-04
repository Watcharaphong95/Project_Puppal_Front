import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/model/dogRecordGetId.dart';
import 'package:puppal_application/model/dogsGetEmail.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalDog.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalGuide.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalNotification.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalProfile.dart';
import 'package:puppal_application/pages/general/recordDog/generalRecordSearch.dart';
import 'package:puppal_application/pages/login/index.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;

class GeneralmainPage extends StatefulWidget {
  const GeneralmainPage({super.key});

  @override
  State<GeneralmainPage> createState() => _GeneralmainPageState();
}

class _GeneralmainPageState extends State<GeneralmainPage> {
  late double screenWidth;
  late double screenHeight;
  final box = GetStorage();

  bool _loadingData = true;

  String url = '';

  var _selectedDay = DateTime.now();
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
      'baby': [6, 9, 12],
      'mature': [0, 3],
      'boost': [52]
    },
    '7': {
      'baby': [8, 11],
      'mature': [0, 3],
      'boost': [26]
    },
  };

  List<DogsGetEmail> dogs = [];
  late DogsGetEmail dogData;

  List<DogsRecordIdGet> dogRecord = [];

  List<DogDataForCalcualtionAppointment> dogDataForCal = [];

  Map<DateTime, List<String>> eventMap = {};
  Map<int, int> dogAgesInWeeks = {};

  @override
  void initState() {
    if (box.read('focusedDay') != null) {
      _focusedDay = box.read('focusedDay');
      _selectedDay = box.read('focusedDay');
    }
    init();
    super.initState();
  }

  void init() async {
    await Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
    });
    await calculateForAppointmentDay();
    events = getEventsForDay(DateTime.now());
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
          child: _loadingData
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFFEF7FF),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
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
                                    color: Color(0xFFE6C29C),
                                    shape: BoxShape.circle),
                                selectedDecoration: BoxDecoration(
                                    color: Color(0xFFDBA871),
                                    shape: BoxShape.circle),
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
                      ),
                      Divider(),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.1,
                            vertical: screenHeight * 0.005),
                        child: Row(
                          children: [
                            Text(
                              DateFormat('d MMMM y', 'th').format(_selectedDay),
                              style: TextStyle(
                                  fontSize: 24, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                      if (events.isNotEmpty)
                        SizedBox(
                          width: screenWidth,
                          height: screenHeight * 0.425,
                          child: Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: events.length,
                                  itemBuilder: (context, index) {
                                    return Card(
                                      elevation: 2,
                                      margin: EdgeInsets.symmetric(
                                          horizontal: screenWidth * 0.05,
                                          vertical: screenHeight * 0.005),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: SizedBox(
                                        height: screenHeight * 0.125,
                                        child: ListTile(
                                          title: SizedBox(
                                            height: screenHeight * 0.11,
                                            child: insideCardShowDogData(index),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
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
                                style:
                                    TextStyle(fontSize: 32, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                    ],
                  ),
                )),
    );
  }

  Row insideCardShowDogData(int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 10,
      children: <Widget>[
        Container(
          width: screenWidth * 0.02,
          height: screenHeight * 0.1,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        for (var item in dogs)
          if (events[index]
                  .toString()
                  .split(', Vaccines:')
                  .first
                  .replaceAll(RegExp(r'[^0-9]'), '') ==
              item.dogId.toString())
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    item.image,
                    width: screenWidth * 0.2,
                    height: screenHeight * 0.1,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return SizedBox(
                        width: screenWidth * 0.2,
                        height: screenHeight * 0.1,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      Text('อายุ ${getDogAge(item.birthday)}'),
                      SizedBox(
                        width: screenWidth * 0.45,
                        child: Text(
                          splitVaccineId(events[index])
                              .map((id) =>
                                  vaccineNameMap[id.trim()] ??
                                  'วัคซีนไม่ทราบชื่อ')
                              .join(', '),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
      ],
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

  Future<void> calculateForAppointmentDay() async {
    await getAllDogData();
    await getAllDogInjectionRecord();
    await getAllDogDataForCalculate();

    for (var dogData in dogDataForCal) {
      log('ID: ${dogData.id}, Vaccine: ${dogData.vaccineId}, Date: ${dogData.date}, Age: ${dogData.age}');
    }

    List<Map<String, dynamic>> vaccineHistory = dogDataForCal
        .map((dogData) => {
              'ID': dogData.id,
              'Vaccine': dogData.vaccineId.toString(),
              'Date': dogData.date.toString() ?? '',
              'Age': dogData.age,
            })
        .toList();

    eventMap = calculateNextAppointmentsForDog(
        vaccineHistory: vaccineHistory,
        vaccineScheduleWeeks: vaccineScheduleWeeks,
        dogAgesInWeeks: dogAgesInWeeks);
  }

  Future<void> getAllDogDataForCalculate() async {
    for (var dog in dogs) {
      Duration difference =
          DateTime.now().difference(DateTime.parse(dog.birthday));
      int ageInWeeks = (difference.inDays / 7).floor();

      dogAgesInWeeks[dog.dogId] = () {
        try {
          DateTime birthday = DateTime.parse(dog.birthday);
          birthday = DateTime(birthday.year, birthday.month, birthday.day);
          DateTime now = DateTime.now();
          DateTime todayOnly = DateTime(now.year, now.month, now.day);
          return todayOnly.difference(birthday).inDays ~/ 7;
        } catch (e) {
          log('Error parsing birthday for dog ${dog.dogId}: $e');
          return 0;
        }
      }();
      log(dogAgesInWeeks.toString());

      // dogDataForCal.add(DogDataForCalcualtionAppointment(
      //     ageInWeeks.toString(), '', dog.dogId.toString(), ''));

      for (var record in dogRecord) {
        if (dog.dogId == record.dogId) {
          dogDataForCal.add(DogDataForCalcualtionAppointment(
              ageInWeeks.toString(),
              record.date,
              dog.dogId.toString(),
              record.vaccineType));
        }
      }
    }
  }

  Future<void> getAllDogData() async {
    var res = await http.get(Uri.parse("$url/dog/${box.read('email')}"));
    if (res.statusCode == 200) {
      var jsonData = json.decode(res.body);
      dogs =
          jsonData.map<DogsGetEmail>((e) => DogsGetEmail.fromJson(e)).toList();
      // log(res.body);
    }
  }

  Future<void> getAllDogInjectionRecord() async {
    var res = await http
        .get(Uri.parse("$url/injectionRecord/all/${box.read('email')}"));
    if (res.statusCode == 200) {
      var jsonData = json.decode(res.body);
      dogRecord = jsonData
          .map<DogsRecordIdGet>((e) => DogsRecordIdGet.fromJson(e))
          .toList();
      // log(res.body);
    }
  }

  Map<DateTime, List<String>> calculateNextAppointmentsForDog({
    required List<Map<String, dynamic>> vaccineHistory,
    required Map<String, Map<String, List<int>>> vaccineScheduleWeeks,
    required Map<int, int> dogAgesInWeeks, // dogId -> current age in weeks
  }) {
    Map<DateTime, Map<int, List<String>>> tempMap = {};
    DateTime today = DateTime.now();
    DateTime todayOnly = DateTime(today.year, today.month, today.day);

    // Store vaccine history for each dog
    Map<int, Map<String, List<DateTime>>> dogVaccineHistory = {};

    // Process vaccine history
    for (var record in vaccineHistory) {
      final idRaw = record['ID'];
      final vaccineRaw = record['Vaccine'];
      final dateRaw = record['Date'];

      if (vaccineRaw == null || vaccineRaw.toString().isEmpty) continue;
      if (dateRaw == null || dateRaw.toString().isEmpty) continue;

      final id = int.parse(idRaw.toString());
      final vaccine = vaccineRaw.toString();
      final date = DateTime.parse(dateRaw.toString());
      final dateOnly = DateTime(date.year, date.month, date.day);

      dogVaccineHistory.putIfAbsent(id, () => {});
      dogVaccineHistory[id]!.putIfAbsent(vaccine, () => []);
      dogVaccineHistory[id]![vaccine]!.add(dateOnly);
    }

    // Sort vaccine dates for each dog and vaccine
    dogVaccineHistory.forEach((dogId, vaccines) {
      vaccines.forEach((vaccine, dates) {
        dates.sort();
      });
    });

    dogAgesInWeeks.forEach((dogId, ageInWeeks) {
      bool isMature = ageInWeeks >= 16;

      vaccineScheduleWeeks.forEach((vaccineId, schedules) {
        List<int> babyWeeks = schedules['baby'] ?? [];
        List<int> matureWeeks = schedules['mature'] ?? [];
        List<int> boostWeeks = schedules['boost'] ?? [];

        // Sort schedules
        babyWeeks.sort();
        matureWeeks.sort();
        boostWeeks.sort();

        List<DateTime> vaccineDates =
            dogVaccineHistory[dogId]?[vaccineId] ?? [];
        int doseCount = vaccineDates.length;

        if (isMature) {
          // Mature dog: use last injection date + mature/boost schedule
          if (doseCount == 0) {
            if (matureWeeks.isNotEmpty) {
              DateTime nextDate = todayOnly;
              tempMap.putIfAbsent(nextDate, () => {});
              tempMap[nextDate]!.putIfAbsent(dogId, () => []).add(vaccineId);
            }
          } else {
            DateTime lastVaccineDate = vaccineDates.last;

            if (doseCount < matureWeeks.length) {
              int intervalWeeks = doseCount == 0
                  ? matureWeeks[0]
                  : matureWeeks[doseCount] - matureWeeks[doseCount - 1];
              DateTime nextDate =
                  lastVaccineDate.add(Duration(days: intervalWeeks * 7));
              if (nextDate.isBefore(todayOnly)) nextDate = todayOnly;

              tempMap.putIfAbsent(nextDate, () => {});
              tempMap[nextDate]!.putIfAbsent(dogId, () => []).add(vaccineId);
            } else {
              if (boostWeeks.isNotEmpty) {
                DateTime nextDate =
                    lastVaccineDate.add(Duration(days: boostWeeks.first * 7));
                if (nextDate.isBefore(todayOnly)) nextDate = todayOnly;

                tempMap.putIfAbsent(nextDate, () => {});
                tempMap[nextDate]!.putIfAbsent(dogId, () => []).add(vaccineId);
              }
            }
          }
        } else {
          // Puppy: use age-based scheduling for baby schedule
          if (doseCount == 0) {
            if (babyWeeks.isNotEmpty) {
              DateTime nextDate;
              int firstWeek = babyWeeks.first;

              if (ageInWeeks >= firstWeek) {
                nextDate = todayOnly;
              } else {
                int waitWeeks = firstWeek - ageInWeeks;
                nextDate = todayOnly.add(Duration(days: waitWeeks * 7));
              }

              tempMap.putIfAbsent(nextDate, () => {});
              tempMap[nextDate]!.putIfAbsent(dogId, () => []).add(vaccineId);
            }
          } else {
            DateTime lastVaccineDate = vaccineDates.last;

            if (doseCount < babyWeeks.length) {
              // Calculate interval from previous dose
              int intervalWeeks = doseCount == 0
                  ? babyWeeks[0]
                  : babyWeeks[doseCount] - babyWeeks[doseCount - 1];
              DateTime nextDate =
                  lastVaccineDate.add(Duration(days: intervalWeeks * 7));
              if (nextDate.isBefore(todayOnly)) nextDate = todayOnly;

              tempMap.putIfAbsent(nextDate, () => {});
              tempMap[nextDate]!.putIfAbsent(dogId, () => []).add(vaccineId);
            } else {
              if (boostWeeks.isNotEmpty) {
                DateTime nextDate =
                    lastVaccineDate.add(Duration(days: boostWeeks.first * 7));
                if (nextDate.isBefore(todayOnly)) nextDate = todayOnly;

                tempMap.putIfAbsent(nextDate, () => {});
                tempMap[nextDate]!.putIfAbsent(dogId, () => []).add(vaccineId);
              }
            }
          }
        }
      });
    });

    // Aggregate results
    Map<DateTime, List<String>> eventMap = {};
    tempMap.forEach((date, dogMap) {
      List<String> grouped = [];
      dogMap.forEach((dogId, vaccines) {
        grouped.add('Dog ID: $dogId, Vaccines: ${vaccines.join(', ')}');
      });
      eventMap[date] = grouped;
    });

    return eventMap;
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

  List<String> splitVaccineId(String str) {
    return str.toString().split('Vaccines:').last.split(',');
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

class DogDataForCalcualtionAppointment {
  final String id;
  final String vaccineId;
  final String date;
  final String age;

  DogDataForCalcualtionAppointment(
      this.age, this.date, this.id, this.vaccineId);
}

class Dog {
  final int dogId;
  final String birthday;

  Dog({required this.dogId, required this.birthday});
}
