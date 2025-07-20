import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/main.dart';
import 'package:puppal_application/model/appointmentGetEmail.dart';
import 'package:puppal_application/model/dogAppointmentEmailGet.dart';
import 'package:puppal_application/model/dogRecordGetId.dart';
import 'package:puppal_application/model/dogsIdGet.dart';
import 'package:puppal_application/model/fireStoreReserveGet.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicMain.dart';
import 'package:puppal_application/pages/clinic/registerClinic/registerClinicGoogle.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalDog.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalGuide.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalNotification.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalSetting.dart';
import 'package:puppal_application/pages/general/recordDog/generalRecordSearch.dart';
import 'package:puppal_application/pages/general/reservePage/clinicSearch.dart';
import 'package:puppal_application/pages/general/reservePage/dogSelect.dart';
import 'package:puppal_application/pages/general/reservePage/reserveInfo.dart';
import 'package:puppal_application/pages/login/index.dart';
import 'package:puppal_application/services/changeNotifier.dart';
import 'package:puppal_application/testFireStore.dart';
import 'package:puppal_application/testNotification.dart';
import 'package:shimmer/shimmer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class GeneralmainPage extends StatefulWidget {
  const GeneralmainPage({super.key});

  @override
  State<GeneralmainPage> createState() => _GeneralmainPageState();
}

class _GeneralmainPageState extends State<GeneralmainPage> {
  late double screenWidth;
  late double screenHeight;
  late AppData appData;

  late StreamSubscription listener;

  final box = GetStorage();

  bool _loadingData = true;

  String url = '';

  var _selectedDay = DateTime.now();
  var _focusedDay = DateTime.now();
  var events = [];

  List<DogsIdGet> dogData = [];
  // List<AppointmentGet> appointmentData = [];

  List<AppointmentGetEmail> appointmentAll = [];
  Map<DateTime, List<Dog>> eventMap = {};

  var db = FirebaseFirestore.instance;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appData = context.read<AppData>(); // ✅ safe place
  }

  @override
  void initState() {
    appData = context.read<AppData>();
    if (box.read('focusedDay') != null) {
      _focusedDay = box.read('focusedDay');
      _selectedDay = box.read('focusedDay');
    }
    box.write('type', 'general');
    log('focusDay ${box.read('focusedDay')}');
    log(box.read('generalImage'));
    init();
    startRealtimeGet();
    super.initState();
  }

  @override
  void dispose() {
    stopRealTime(); // 👈 Stop the listener when page is destroyed
    super.dispose();
  }

  void init() async {
    await Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
    });
    await getAppointmentEmail();
    events = getEventsForDay(_selectedDay);
    setState(() {
      _loadingData = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return ChangeNotifierProvider(
      create: (_) {
        var provider = ReserveProvider();
        provider.startListening();
        log(provider.toString());
        return provider;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'หน้าหลัก',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF916B44),
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipOval(
                          child: Image.network(
                            box.read('generalImage'),
                            width: screenWidth * 0.2,
                            height: screenWidth * 0.2,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: screenWidth * 0.2,
                                  height: screenWidth * 0.2,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          box.read('generalName') ?? "ผู้ใช้งาน",
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
                      Get.back();
                      Get.to(() => GeneralnotificationPage());
                    },
                  ),
                  ListTile(
                    leading:
                        Icon(FontAwesomeIcons.dog, color: Color(0xFF916b44)),
                    title: Text('สุนัข'),
                    onTap: () {
                      Get.back();
                      Get.to(() => GeneraldogPage());
                    },
                  ),
                  ListTile(
                    leading: Icon(FontAwesomeIcons.syringe,
                        color: Color(0xFF916b44)),
                    title: Text('ประวัติการฉีดยา'),
                    onTap: () {
                      Get.back();
                      Get.to(() => GeneralrecordsearchPage());
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.menu_book, color: Color(0xFF916b44)),
                    title: Text('คู่มือ'),
                    onTap: () {
                      Get.back();
                      Get.to(() => GeneralguidePage());
                    },
                  ),
                  ListTile(
                    leading:
                        Icon(FontAwesomeIcons.gear, color: Color(0xFF916b44)),
                    title: Text('ตั้งค่า'),
                    onTap: () {
                      Get.back();
                      // it a generalSetting.dart page
                      Get.to(() => GeneralprofilePage());
                    },
                  ),
                  ListTile(
                    leading:
                        Icon(MdiIcons.accountSwitch, color: Color(0xFF916b44)),
                    title: Text('สลับโหมด'),
                    onTap: () async {
                      var resClinic = await http.get(
                          Uri.parse("$url/clinic/name/${box.read('email')}"));
                      if (resClinic.statusCode == 200) {
                        showAlert(
                          title: 'สลับไปยังบัญชีคลินิก?',
                          message: 'กด ตกลง เพื่อไปยังบัญชีคลินิก',
                          onConfirm: () {
                            box.write('type', 'clinic');
                            box.write('clinicName',
                                jsonDecode(resClinic.body)['name']);
                            box.write('clinicImage',
                                jsonDecode(resClinic.body)['image']);
                            log('Name ${box.read('clinicName')}');
                            Get.offAll(() => ClinicmainPage());
                          },
                        );
                      } else {
                        showAlert(
                          title: 'คุณยังไม่มีบัญชีคลินิก!',
                          message: 'กด ตกลง เพื่อไปยังหน้าสมัครคลินิก',
                          onConfirm: () {
                            Get.back();
                            Get.to(() => RegisterclinicgooglePage());
                          },
                        );
                      }
                    },
                  ),
                  ListTile(
                    leading: Icon(FontAwesomeIcons.doorOpen,
                        color: Colors.redAccent),
                    title: Text('ออกจากระบบ'),
                    onTap: () {
                      showAlert(
                        title: 'ออกจากระบบ?',
                        message: 'คุณต้องการออกจากระบบใช่หรือไม่',
                        onConfirm: () async {
                          await FirebaseMessaging.instance.deleteToken();
                          box.erase();
                          Get.offAll(() => IndexPage());
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
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
                      'กำลังโหลด...',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Container(
                  height: screenHeight * 0.9,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/indexBg.png'),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                            Colors.white.withOpacity(0.2), BlendMode.dstATop)),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: screenHeight * 0.01,
                      ),
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
                              calendarBuilders: CalendarBuilders(
                                markerBuilder: (context, date, events) {
                                  if (events.isEmpty) return SizedBox.shrink();

                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: events.map((event) {
                                      Color dotColor;

                                      switch ((event as Dog).status) {
                                        case 0:
                                          dotColor = Colors.red;
                                          break;
                                        case 1:
                                          dotColor = Colors.yellow.shade600;
                                          break;
                                        case 2:
                                          dotColor = Colors.lightBlueAccent;
                                          break;
                                        case 3:
                                          dotColor = Colors.lightGreen.shade400;
                                          break;
                                        default:
                                          dotColor = Colors.grey;
                                      }

                                      return Container(
                                        width: 6,
                                        height: 6,
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 0.5),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: dotColor,
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },

                                /// 👇 Grey out past dates
                                defaultBuilder: (context, day, focusedDay) {
                                  final isPast = day.isBefore(
                                      DateTime.now().subtract(Duration(
                                    hours: DateTime.now().hour,
                                    minutes: DateTime.now().minute,
                                    seconds: DateTime.now().second,
                                  )));

                                  if (isPast) {
                                    return Center(
                                      child: Text(
                                        '${day.day}',
                                        style: TextStyle(
                                            color: Colors.grey.shade400),
                                      ),
                                    );
                                  }

                                  return null; // default rendering
                                },
                              ),
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
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.025),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                                0, 0, 0, screenHeight * 0.05),
                            child: Column(
                              children: [
                                events.isNotEmpty
                                    ? Column(
                                        children: events.map((e) {
                                          return Card(
                                            elevation: 2,
                                            child: InkWell(
                                              onTap: () {
                                                if (DateTime.now()
                                                    .isAfter(_selectedDay)) {
                                                  return;
                                                }

                                                if (e.status != 0) {
                                                  showReserveInfoAlert(
                                                      context, e);
                                                } else {
                                                  Get.to(() => ClinicsearchPage(
                                                        dogId: e.dogId,
                                                        vaccineName: e.vaccines
                                                            .join(', '),
                                                        date: _selectedDay,
                                                        aid: e.aid,
                                                        reserveId: e.reserveId,
                                                      ));
                                                }
                                              },
                                              child: ListTile(
                                                title: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    dogInfoCard(e),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      )
                                    : Row(
                                        children: [
                                          Container(
                                            width: screenWidth * 0.015,
                                            height: screenHeight * 0.03,
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                          ),
                                          Text(
                                            '  ไม่มีนัดวันนี้',
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Color(0xFF916B44)),
                                          ),
                                        ],
                                      ),
                                Card(
                                  elevation: 2,
                                  child: InkWell(
                                    onTap: () {
                                      Get.to(() => DogselectPage(
                                            date: _selectedDay,
                                            dogData: Map.fromEntries(
                                              eventMap.entries
                                                  // 1. Keep only dates before now
                                                  .where((entry) => entry.key
                                                      .isBefore(DateTime.now()))
                                                  // 2. Map to new entries with filtered dog lists (only status == 0)
                                                  .map((entry) => MapEntry(
                                                        entry.key,
                                                        entry.value
                                                            .where((dog) =>
                                                                dog.status == 0)
                                                            .toList(),
                                                      ))
                                                  // 3. Keep only entries where filtered list is not empty
                                                  .where((entry) =>
                                                      entry.value.isNotEmpty),
                                            ),
                                          ));
                                    },
                                    child: ListTile(
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            FontAwesomeIcons.plus,
                                            color: Colors.grey,
                                          ),
                                          Text(
                                            'จองคลินิก',
                                            style:
                                                TextStyle(color: Colors.grey),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
  }

  Widget dogInfoCard(e) {
    bool isDisabled = DateTime.now().isAfter(_selectedDay);

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: IgnorePointer(
        ignoring: isDisabled,
        child: Row(
          children: [
            if (e.status == 0)
              Container(
                width: screenWidth * 0.02,
                height: screenHeight * 0.1,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(50),
                ),
              )
            else if (e.status == 1)
              Container(
                width: screenWidth * 0.02,
                height: screenHeight * 0.1,
                decoration: BoxDecoration(
                  color: Colors.yellow.shade600,
                  borderRadius: BorderRadius.circular(50),
                ),
              )
            else if (e.status == 2)
              Container(
                width: screenWidth * 0.02,
                height: screenHeight * 0.1,
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent,
                  borderRadius: BorderRadius.circular(50),
                ),
              )
            else if (e.status == 3)
              Container(
                width: screenWidth * 0.02,
                height: screenHeight * 0.1,
                decoration: BoxDecoration(
                  color: Colors.lightGreen.shade400,
                  borderRadius: BorderRadius.circular(50),
                ),
              )
            else
              SizedBox.shrink(),
            SizedBox(width: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                e.image,
                width: screenWidth * 0.2,
                height: screenHeight * 0.1,
                fit: BoxFit.cover,
                color: isDisabled
                    ? Colors.grey
                    : null, // optional: greyscale image
                colorBlendMode: isDisabled ? BlendMode.saturation : null,
                loadingBuilder: (context, child, loadingProgress) {
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
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: screenWidth * 0.55,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        e.status != 0
                            ? 'เวลา: ${e.time} - ${addMinutesToTime(e.time, 30)}'
                            : '',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDisabled ? Colors.grey : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDisabled ? Colors.grey : Colors.black,
                      ),
                    ),
                    Text(
                      'อายุ ${getDogAge(e.birthday)}',
                      style: TextStyle(
                        color: isDisabled ? Colors.grey : Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                if (e.vaccines != null &&
                    e.vaccines.isNotEmpty &&
                    e.vaccines
                        .any((vaccine) => vaccine.toString().trim().isNotEmpty))
                  SizedBox(
                    width: screenWidth * 0.5,
                    child: Text(
                      'วัคซีน: ${e.vaccines.where((vaccine) => vaccine.toString().trim().isNotEmpty).join(', ')}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        color: isDisabled ? Colors.grey : Colors.black,
                      ),
                    ),
                  ),
                SizedBox(
                  width: screenWidth * 0.55,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: screenWidth * 0.225,
                        child: Text(
                          e.status != 0 ? 'คลินิก: ${e.clinicName}' : '',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            color:
                                isDisabled ? Colors.grey : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void startRealtimeGet() {
    stopRealTime(); // stop any previous listener

    final colRef = db.collection("reserve").where("generalEmail",
        isEqualTo: box.read("email")); // collection, not doc

    context.read<AppData>().listener = colRef.snapshots().listen(
      (querySnapshot) {
        for (var change in querySnapshot.docChanges) {
          var docId = change.doc.id;
          var data = change.doc.data();

          if (change.type == DocumentChangeType.removed) {
            eventMap.forEach((date, dogList) {
              dogList.removeWhere((dog) => dog.reserveId == docId);
            });
            setState(() {});
          } else if (data != null && data.containsKey('status')) {
            int newStatus = data['status'];
            log("🔄 Change type: ${change.type}");
            eventMap.forEach((date, dogList) {
              for (int i = 0; i < dogList.length; i++) {
                if (dogList[i].reserveId == docId) {
                  dogList[i].status = newStatus;
                  setState(() {});
                  break;
                }
              }
            });
          }
        }
      },
      onError: (error) => log("❌ Listen failed: $error"),
    );
  }

  void stopRealTime() {
    if (appData.listener != null) {
      appData.listener?.cancel().then((_) {
        log('🔕 Listener is stopped');
      }).catchError((e) {
        log('⚠️ Failed to stop listener: $e');
      });
    } else {
      log('ℹ️ No listener was running');
    }
  }

  void showReserveInfoAlert(BuildContext context, dynamic e) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with close button
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFFDBA871).withOpacity(0.2),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ข้อมูลการจอง',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF916B44),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close,
                          color: Color(0xFF916B44).withOpacity(0.7)),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dog Info Card
                      _buildInfoCard(
                        icon: Icons.pets,
                        iconColor: Color(0xFF916B44),
                        title: 'ข้อมูลสัตว์เลี้ยง',
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                e.image,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFDBA871).withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.pets,
                                      color: Color(0xFF916B44)),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.name ?? 'ไม่พบชื่อ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF916B44),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'อายุ ${getDogAge(e.birthday)}',
                                    style: TextStyle(
                                      color: Color(0xFF916B44).withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16),

                      // Clinic Info Card
                      _buildInfoCard(
                        icon: Icons.local_hospital,
                        iconColor: Color(0xFFDBA871),
                        title: 'ข้อมูลคลินิก',
                        child: Column(
                          children: [
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    e.clinicImage,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        color:
                                            Color(0xFFDBA871).withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.local_hospital,
                                          color: Color(0xFF916B44)),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        e.clinicName ?? 'ไม่พบชื่อคลินิก',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF916B44),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.phone,
                                              size: 16,
                                              color: Color(0xFF916B44)
                                                  .withOpacity(0.7)),
                                          SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              e.clinicPhone ?? 'ไม่พบเบอร์โทร',
                                              style: TextStyle(
                                                color: Color(0xFF916B44)
                                                    .withOpacity(0.7),
                                                fontSize: 14,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            // Map Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  openMap(double.parse(e.clinicLat),
                                      double.parse(e.clinicLng));
                                },
                                icon: Icon(Icons.map, size: 20),
                                label: Text('ดูแผนที่คลินิก'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color(0xFFDBA871).withOpacity(0.2),
                                  foregroundColor: Color(0xFF916B44),
                                  elevation: 0,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16),

                      // Time Info Card
                      if (e.time != null)
                        _buildInfoCard(
                          icon: Icons.schedule,
                          iconColor: Color(0xFF916B44),
                          title: 'เวลานัดหมาย',
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(0xFFDBA871).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.access_time,
                                    color: Color(0xFF916B44), size: 20),
                                SizedBox(width: 8),
                                Text(
                                  '${e.time} - ${addMinutesToTime(e.time, 30)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF916B44),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      SizedBox(height: 16),

                      // Vaccines Info Card
                      if (e.vaccines != null && e.vaccines.isNotEmpty)
                        _buildInfoCard(
                          icon: Icons.medical_services,
                          iconColor: Color(0xFFDBA871),
                          title: 'วัคซีนที่จอง',
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: e.vaccines != null &&
                                    e.vaccines.isNotEmpty &&
                                    e.vaccines.any((vaccine) =>
                                        vaccine.toString().trim().isNotEmpty)
                                ? e.vaccines
                                    .map<Widget>(
                                      (vaccine) => Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFDBA871)
                                              .withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                              color: Color(0xFFDBA871)
                                                  .withOpacity(0.5)),
                                        ),
                                        child: Text(
                                          vaccine,
                                          style: TextStyle(
                                            color: Color(0xFF916B44),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList()
                                : [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color:
                                            Color(0xFFDBA871).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                            color: Color(0xFFDBA871)
                                                .withOpacity(0.5)),
                                      ),
                                      child: Text(
                                        'ไม่มี',
                                        style: TextStyle(
                                          color: Color(0xFF916B44),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    )
                                  ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFFDBA871).withOpacity(0.1),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: e.status == 1 || e.status == 2
                            ? () {
                                // Show confirmation dialog for cancellation
                                showAlertRed(
                                  title: 'ยืนยันยกเลิกการจอง?',
                                  message: 'คุณต้องการยกเลิกการจองนี้หรือไม่',
                                  onConfirm: () {
                                    cancleReserve(e.reserveId);
                                  },
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          // foregroundColor: Colors.red.shade600,
                          side: BorderSide(color: Colors.red.shade400),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'ยกเลิกการจอง',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF916B44),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'ปิด',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFDBA871).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFDBA871).withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF916B44),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Future<void> cancleReserve(String reserveId) async {
    showLoadingDialog();

    final docRef =
        FirebaseFirestore.instance.collection('reserve').doc(reserveId);
    final snapshot = await docRef.get();

    if (snapshot.exists) {
      final data = snapshot.data();
      if (data != null &&
          data['status'] != 0 &&
          data['appointmentAid'] == null) {
        await docRef.delete();
      } else if (data != null && data['status'] != 0) {
        await docRef.update({'status': 0});
      } else {
        log("Reserve already cancelled or invalid data");
      }
    } else {
      log("Document not found");
    }
    Get.back();
    Get.back();
  }

  Future<void> openMap(double lat, double lng) async {
    final googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open the map.';
    }
  }

  Future<void> getAppointmentEmail() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('reserve')
        .where('generalEmail', isEqualTo: box.read('email'))
        .get();

    List<ReserveAppointmentFireStore> appointments = snapshot.docs
        .map((doc) => ReserveAppointmentFireStore.fromJson(doc.data(), doc.id))
        .toList();

    final groupedAppointments = groupByDate(appointments);

    List<int> listDogId = [];
    List<int?> listAid = [];
    List<List<int?>> listMutipleAid = [];
    List<String> listClinicEmail = [];

    groupedAppointments.forEach((date, list) {
      for (var app in list) {
        listDogId.add(int.parse(app.dogId));

        if (app.appointmentAid != null) {
          final innerList = app.appointmentAid!
              .split(',')
              .map((e) => int.tryParse(e.trim()))
              .whereType<int>()
              .toList();

          if (innerList.isNotEmpty) {
            listMutipleAid.add(innerList);
          }
        }

        listAid.addAll(app.appointmentAid
            .split(',')
            .map((e) => int.tryParse(e.trim()))
            .whereType<int>());

        listClinicEmail.add(app.clinicEmail);
      }
    });

    log(listAid.toString());

    final resAppointment = await http.post(
      Uri.parse("$url/appointment/dataList"),
      headers: {"Content-Type": "application/json; charset=utf-8"},
      body: json.encode({
        "email": box.read('email'),
        "dogId": listDogId.toList(),
        "aid": listAid.toList(),
        "clinicEmail": listClinicEmail.toList()
      }),
    );
    var jsonData = jsonDecode(resAppointment.body);
    if (appointments.isNotEmpty &&
        jsonData['dogs'] != null &&
        jsonData['appointments'] != null &&
        jsonData['clinics'] != null) {
      appointmentAll = mergeAppointments(
          firestoreData: appointments,
          dogs: jsonData['dogs'],
          appointments: jsonData['appointments'],
          clinics: jsonData['clinics']);
    }

    // for (var a in appointmentAll) {
    //   for (var d in a.dogs) {
    //     log(jsonEncode(d.toJson()));
    //   }
    // }

    buildEventMap(appointmentAll);
  }

  List<AppointmentGetEmail> mergeAppointments({
    required List<ReserveAppointmentFireStore> firestoreData,
    required List<dynamic> dogs,
    required List<dynamic> appointments,
    required List<dynamic> clinics,
  }) {
    // Grouped map by date
    final Map<DateTime, List<Dog>> grouped = {};

    // Helper to truncate datetime to date only
    DateTime toDate(dynamic date,
        {required String source, required String id}) {
      if (date is DateTime) {
        return DateTime(date.year, date.month, date.day);
      }
      if (date is String) {
        final dt = DateTime.tryParse(date);
        if (dt != null) {
          return DateTime(dt.year, dt.month, dt.day);
        }
      }
      log('Invalid date format from $source id=$id');
      return DateTime(2000, 1, 1); // fallback
    }

    // Find existing date key within 1 day difference
    DateTime? findCloseDateKey(DateTime target) {
      for (var key in grouped.keys) {
        if (key.difference(target).inDays.abs() <= 1) {
          final midTimestamp =
              (key.millisecondsSinceEpoch + target.millisecondsSinceEpoch) ~/ 2;
          return DateTime.fromMillisecondsSinceEpoch(midTimestamp);
        }
      }
      return null;
    }

    // Add or merge dog in grouped map
    void addDogToGroup(DateTime date, Dog dog) {
      final closeKey = findCloseDateKey(date);
      final groupKey = closeKey ?? date;

      if (closeKey != null) {
        final keysToRemove = grouped.keys
            .where((k) => k.difference(groupKey).inDays.abs() <= 1)
            .toList();

        final mergedDogs = <Dog>[];
        for (var key in keysToRemove) {
          mergedDogs.addAll(grouped[key]!);
          grouped.remove(key);
        }

        final existingIndex =
            mergedDogs.indexWhere((d) => d.dogId == dog.dogId);
        if (existingIndex != -1) {
          final existingDog = mergedDogs[existingIndex];

          // Merge vaccines
          existingDog.vaccines = {
            ...existingDog.vaccines.where((v) => v.trim().isNotEmpty),
            ...dog.vaccines.where((v) => v.trim().isNotEmpty),
          }.toList();

          // Merge aids
          existingDog.aid ??= [];
          dog.aid ??= [];
          existingDog.aid!.addAll(dog.aid!);
          existingDog.aid = existingDog.aid!.toSet().toList();
        } else {
          mergedDogs.add(dog);
        }

        grouped[groupKey] = mergedDogs;
      } else {
        final existingIndex =
            grouped[groupKey]?.indexWhere((d) => d.dogId == dog.dogId) ?? -1;

        if (existingIndex != -1) {
          final existingDog = grouped[groupKey]![existingIndex];

          // Merge vaccines
          existingDog.vaccines = {
            ...existingDog.vaccines.where((v) => v.trim().isNotEmpty),
            ...dog.vaccines.where((v) => v.trim().isNotEmpty),
          }.toList();

          // Merge aids
          existingDog.aid ??= [];
          dog.aid ??= [];
          existingDog.aid!.addAll(dog.aid!);
          existingDog.aid = existingDog.aid!.toSet().toList();
        } else {
          grouped.putIfAbsent(groupKey, () => []).add(dog);
        }
      }
    }

    // Create lookup maps for fast access
    final dogMap = {for (var d in dogs) d['dogId'] as int: d};
    final appointmentMap = {for (var a in appointments) a['aid'] as int: a};
    final clinicMap = {for (var c in clinics) c['user_email'] as String: c};

    // Process Firestore reserve data
    for (final fs in firestoreData) {
      int? dogId;
      try {
        dogId = int.parse(fs.dogId);
      } catch (e) {
        log('Error parsing dogId: ${fs.dogId} for docId: ${fs.docId}');
        continue;
      }

      final dogData = dogMap[dogId];
      if (dogData == null) {
        log('⚠️ Missing dogData for dogId=$dogId (docId=${fs.docId})');
      }

      int? aid;

      Map<String, dynamic>? appointmentData;

      if (fs.appointmentAid != null) {
        aid = int.tryParse(fs.appointmentAid);
        appointmentData = aid != null ? appointmentMap[aid] : null;
      }
      log('Firestore docId=${fs.docId} aid=$aid appointmentData=$appointmentData');

      final clinicData = clinicMap[fs.clinicEmail];

      final dateTime = fs.date is DateTime
          ? fs.date as DateTime
          : DateTime.tryParse(fs.date as String);
      if (dateTime == null) continue;

      final List<int> aids = parseAids(fs.appointmentAid);

      List<String> vaccines = [];
      List<int> allAids = [];

      for (final aid in aids) {
        final appointmentData = appointmentMap[aid];
        if (appointmentData != null) {
          final vaccine = (appointmentData['vaccine'] as String?)?.trim();
          if (vaccine != null && vaccine.isNotEmpty) {
            vaccines.add(vaccine);
          }
        }
        allAids.add(aid);
      }

      if (vaccines.isEmpty) vaccines = [''];

      final dog = Dog(
        reserveId: fs.docId,
        aid: allAids,
        status: fs.status,
        dogId: dogData != null ? dogData['dogId'] as int : dogId,
        name: dogData != null ? dogData['name'] as String : 'Unknown Dog',
        image: dogData != null ? dogData['image'] as String : '',
        birthday: dogData != null ? dogData['birthday'] as String : '',
        vaccines: vaccines,
        time: DateFormat('HH:mm').format(dateTime),
        clinicName: clinicData != null ? clinicData['name'] as String : '',
        clinicImage: clinicData != null ? clinicData['image'] as String : '',
        clinicPhone: clinicData != null ? clinicData['phone'] as String : '',
        clinicLat: clinicData != null ? clinicData['lat'] as String : '',
        clinicLng: clinicData != null ? clinicData['lng'] as String : '',
      );

      final date = toDate(fs.date, source: 'firestoreData', id: fs.docId);
      addDogToGroup(date, dog);
    }

    final firestoreAidSet = <int>{};

    // Prepare set of Firestore appointment IDs

    for (final fs in firestoreData) {
      final aids = parseAids(fs.appointmentAid);
      firestoreAidSet.addAll(aids);
    }

    // Process normal appointments (non-Firestore)
    for (final appointment in appointments) {
      final aid = appointment['aid'] as int?;
      if (aid != null && firestoreAidSet.contains(aid)) continue;

      final status = appointment['status'] as int? ?? 0;
      if (status != 0) continue;

      final dogData = dogMap[appointment['dogId'] as int];
      if (dogData == null) {
        log('Missing dog data for dogId: ${appointment['dogId']} in appointment aid: $aid');
        continue;
      }

      final clinicEmail = appointment['clinicEmail'] as String?;
      final clinicData = clinicEmail != null ? clinicMap[clinicEmail] : null;

      final dateTime = appointment['date'] is String
          ? DateTime.tryParse(appointment['date'])
          : appointment['date'];
      if (dateTime == null) continue;

      final dog = Dog(
        reserveId: null,
        aid: aid != null ? [aid] : [],
        status: status,
        dogId: dogData['dogId'] as int,
        name: dogData['name'] as String,
        image: dogData['image'] as String,
        birthday: dogData['birthday'] as String,
        vaccines: appointment['vaccine'] != null
            ? [appointment['vaccine'] as String]
            : [''],
        time: '',
        clinicName: clinicData != null ? clinicData['name'] as String : '',
        clinicImage: clinicData != null ? clinicData['image'] as String : '',
        clinicPhone: clinicData != null ? clinicData['phone'] as String : '',
        clinicLat: clinicData != null ? clinicData['lat'] as String : '',
        clinicLng: clinicData != null ? clinicData['lng'] as String : '',
      );

      final date = toDate(appointment['date'],
          source: 'appointments', id: aid?.toString() ?? 'null');
      addDogToGroup(date, dog);
    }

    // Convert grouped to list of AppointmentGetEmail
    return grouped.entries
        .map((e) => AppointmentGetEmail(date: e.key, dogs: e.value))
        .toList();
  }

  List<int> parseAids(String? aidString) {
    if (aidString == null || aidString.trim().isEmpty) return [];
    return aidString
        .split(',')
        .map((e) => int.tryParse(e.trim()))
        .whereType<int>()
        .toList();
  }

  Map<String, List<ReserveAppointmentFireStore>> groupByDate(
      List<ReserveAppointmentFireStore> appointments) {
    final formatter = DateFormat('yyyy-MM-dd');

    Map<String, List<ReserveAppointmentFireStore>> grouped = {};

    for (var appointment in appointments) {
      String dateKey = formatter.format(appointment.date);

      if (grouped.containsKey(dateKey)) {
        grouped[dateKey]!.add(appointment);
      } else {
        grouped[dateKey] = [appointment];
      }
    }

    return grouped;
  }

  List<Dog> getEventsForDay(DateTime day) {
    final dateOnly = DateTime(day.year, day.month, day.day);
    return eventMap[dateOnly] ?? [];
  }

  void buildEventMap(List<AppointmentGetEmail> appointments) {
    eventMap.clear();

    for (var appointment in appointments) {
      // Normalize date to date-only (strip time)
      final dateOnly = DateTime(
        appointment.date.year,
        appointment.date.month,
        appointment.date.day,
      );

      // If this date already exists, add to the existing list
      if (eventMap.containsKey(dateOnly)) {
        eventMap[dateOnly]!.addAll(appointment.dogs);
      } else {
        // First appointment for this date, create new list
        eventMap[dateOnly] = List.from(appointment.dogs);
      }
    }
    eventMap.forEach((date, dogs) {
      dogs.sort((a, b) => a.status.compareTo(b.status));
    });
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

  String addMinutesToTime(String timeStr, int minutesToAdd) {
    // Parse to DateTime using a dummy date
    DateTime time = DateTime.parse("2000-01-01 $timeStr:00");

    // Add the minutes
    DateTime newTime = time.add(Duration(minutes: minutesToAdd));

    // Format back to HH:mm
    String formatted =
        "${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}";

    return formatted;
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
      content: PopScope(
        canPop: false,
        child: Column(
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
      ),
      backgroundColor: const Color(0xFFF5F0E8),
      barrierDismissible: false,
      radius: 16,
    );
  }

  void showAlertRed({
    required String title,
    required String message,
    VoidCallback? onConfirm,
  }) {
    Get.defaultDialog(
      title: '',
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.all(16),
      content: PopScope(
        canPop: false,
        child: Column(
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
                color: const Color(0xFFE57373),
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
      ),
      backgroundColor: const Color(0xFFF5F0E8),
      barrierDismissible: false,
      radius: 16,
    );
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
}
