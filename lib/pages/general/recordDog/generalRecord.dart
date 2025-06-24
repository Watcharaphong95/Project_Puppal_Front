import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/model/dogRecordGetId.dart';
import 'package:puppal_application/model/dogsGetEmail.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicMain.dart';
import 'package:puppal_application/pages/clinic/registerClinic/registerClinicGoogle.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalDog.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalGuide.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalMain.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalNotification.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalSetting.dart';
import 'package:puppal_application/pages/login/index.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class GeneralrecordPage extends StatefulWidget {
  final int? index;
  const GeneralrecordPage({super.key, this.index});

  @override
  State<GeneralrecordPage> createState() => _GeneralrecordPageState();
}

class _GeneralrecordPageState extends State<GeneralrecordPage> {
  late double screenWidth;
  late double screenHeight;
  final box = GetStorage();

  List<DogsGetEmail> dogs = [];
  late DogsGetEmail dogData;

  List<DogsRecordIdGet> dogRecord = [];

  bool isLoading = true;
  bool isLoadingRecord = true;

  String url = '';

  int? selectedIndex;
  late int dogId;
  String dogBirthDay = '';

  Map<String, String> vaccineNameMap = {
    '1': 'วัคซีนรวม 5 โรค (DHPPiL)',
    '2': 'วัคซีนพิษสุนัขบ้า',
    '3': 'วัคซีนป้องกันโรคไข้ฉี่หนู',
    '4': 'วัคซีนป้องกันเชื้อ Bordetella bronchiseptica',
    '5': 'วัคซีนป้องกันโรคลายม์',
    '6': 'วัคซีนป้องกันเชื้อโคโรนาไวรัส',
    '7': 'วัคซีนถ่ายพยาธิ',
  };

  final Map<String, IconData> vaccineIcons = {
    '1': FontAwesomeIcons.shieldHeart,
    '2': FontAwesomeIcons.shieldDog,
    '3': FontAwesomeIcons.shieldDog,
    '4': FontAwesomeIcons.wind,
    '5': FontAwesomeIcons.bug,
    '6': FontAwesomeIcons.virus,
    '7': FontAwesomeIcons.worm,
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

  List<String> vaccineNext = [];

  @override
  void initState() {
    super.initState();
    if (widget.index != null) {
      selectedIndex = widget.index;
    } else {
      selectedIndex = 0;
    }
    init();
  }

  void init() async {
    await Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
    });
    await getDogData();
    for (int i = 0; i < dogs.length; i++) {
      if (dogs[i].dogId == selectedIndex!) {
        selectedIndex = i;
      }
    }
    dogData = dogs[selectedIndex!];
    dogId = dogData.dogId;
    dogBirthDay = dogData.birthday;
    await getDogRecordData();
    setState(() {
      isLoading = false;
      isLoadingRecord = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ประวัติการฉีดยา',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
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
                  leading:
                      Icon(FontAwesomeIcons.house, color: Color(0xFF916b44)),
                  title: Text('หน้าหลัก'),
                  onTap: () {
                    Get.back();
                    Get.to(() => GeneralmainPage());
                  },
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
                  leading: Icon(FontAwesomeIcons.dog, color: Color(0xFF916b44)),
                  title: Text('สุนัข'),
                  onTap: () {
                    Get.back();
                    Get.to(() => GeneraldogPage());
                  },
                ),
                ListTile(
                  leading:
                      Icon(FontAwesomeIcons.syringe, color: Color(0xFF916b44)),
                  title: Text(
                    'ประวัติการฉีดยา',
                    style: TextStyle(
                      color: Color(0xFF916b44),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(FontAwesomeIcons.userLarge,
                      color: Color(0xFF916b44)),
                  title: Text('โปรไฟล์'),
                  onTap: () {
                    Get.back();
                    Get.to(() => GeneralprofilePage());
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
                  leading: Icon(Icons.settings, color: Color(0xFF916b44)),
                  title: Text('ตั้งค่า'),
                  onTap: () {},
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
                          box.write(
                              'clinicName', jsonDecode(resClinic.body)['name']);
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
                  leading:
                      Icon(FontAwesomeIcons.doorOpen, color: Colors.redAccent),
                  title: Text('ออกจากระบบ'),
                  onTap: () {
                    showAlert(
                      title: 'ออกจากระบบ?',
                      message: 'คุณต้องการออกจากระบบใช่หรือไม่',
                      onConfirm: () {
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
              child: Container(
                height: screenHeight * 0.89,
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
                      height: screenHeight * 0.16,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: dogs.length,
                        itemBuilder: (context, index) {
                          final dog = dogs[index];
                          final isSelected = selectedIndex == index;

                          return GestureDetector(
                            onTap: () async {
                              setState(() {
                                isLoadingRecord = true;
                                selectedIndex = index;
                                dogData = dog;
                                dogId = dog.dogId;
                                dogBirthDay = dog.birthday;
                              });
                              await getDogRecordData();
                              setState(() {
                                isLoadingRecord = false;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 8),
                              child: Column(
                                children: [
                                  Stack(alignment: Alignment.center, children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(150),
                                      child: Image.network(
                                        dog.image,
                                        width: screenWidth * 0.25,
                                        height: screenHeight * 0.125,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, progress) {
                                          if (progress == null) return child;
                                          return Center(
                                              child:
                                                  CircularProgressIndicator());
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Center(
                                          child: Icon(Icons.error),
                                        ),
                                      ),
                                    ),
                                    if (isSelected) ...[
                                      Container(
                                        width: screenWidth * 0.25,
                                        height: screenHeight * 0.125,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withAlpha(102),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Icon(FontAwesomeIcons.check,
                                          color: Colors.black54, size: 32),
                                    ]
                                  ]),
                                  Text(
                                    dog.name,
                                    maxLines: 1,
                                    style: TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Column(
                      children: [
                        SizedBox(
                            child: vaccineNext.isEmpty
                                ? Column(
                                    children: [
                                      Divider(),
                                      Card(
                                        color: Color(0xFFF1F1F1),
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: ListTile(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                          leading: FaIcon(
                                            FontAwesomeIcons.syringe,
                                          ),
                                          title: Text(
                                            "อายุ: ${getDogAge(dogBirthDay)}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.redAccent),
                                          ),
                                          subtitle: Text(
                                            'ไม่มีวัคซีนต้องได้รับในขณะนี้',
                                            style: TextStyle(
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ),
                                          trailing: Icon(Icons.chevron_right),
                                          onTap: () {
                                            // Add your tap logic here
                                          },
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      Divider(),
                                      Card(
                                        color: Color(0xFFF1F1F1),
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: ListTile(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                          leading: FaIcon(
                                            FontAwesomeIcons.syringe,
                                          ),
                                          title: Text(
                                            "อายุ: ${getDogAge(dogBirthDay)}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.redAccent),
                                          ),
                                          subtitle: Text(
                                            'ต้องได้รับ ${vaccineNext.join(', ')}',
                                            style: TextStyle(
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ),
                                          trailing: Icon(Icons.chevron_right),
                                          onTap: () {
                                            // Add your tap logic here
                                          },
                                        ),
                                      ),
                                    ],
                                  )),
                      ],
                    ),
                    Divider(),
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          if (isLoadingRecord)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.2),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else
                            SizedBox(
                              height: screenHeight * 0.5,
                              child: dogRecord.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          FaIcon(
                                            FontAwesomeIcons.dog,
                                            size: 50,
                                            color: Colors.grey.shade500,
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            'ไม่พบประวัติการฉีดวัคซีน',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey.shade700,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: dogRecord.length,
                                      itemBuilder: (context, index) {
                                        final record = dogRecord[index];
                                        String vaccineName = vaccineNameMap[
                                                record.vaccineType] ??
                                            'ข้อมูลวัคซีนไม่พบ';
                                        return Card(
                                          color: Color(0xFFF1F1F1),
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          elevation: 4,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: ListTile(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12),
                                            leading: FaIcon(
                                              vaccineIcons[
                                                      record.vaccineType] ??
                                                  FontAwesomeIcons.syringe,
                                            ),
                                            title: Text(
                                              record.clinicName.isNotEmpty
                                                  ? record.clinicName
                                                  : 'ไม่มีคลินิก',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  vaccineName,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  "วันที่ฉีด: ${DateFormat('d MMMM y', 'th').format(DateTime.parse(record.date).toLocal())}",
                                                ),
                                              ],
                                            ),
                                            trailing: Icon(Icons.chevron_right),
                                            onTap: () {
                                              // Add your tap logic here
                                            },
                                          ),
                                        );
                                      },
                                    ),
                            ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> getDogData() async {
    var res = await http.get(Uri.parse("$url/dog/${box.read('email')}"));
    if (res.statusCode == 200) {
      var jsonData = json.decode(res.body);
      dogs =
          jsonData.map<DogsGetEmail>((e) => DogsGetEmail.fromJson(e)).toList();
      // log(res.body);
    }
  }

  Future<void> getDogRecordData() async {
    var res = await http.get(Uri.parse("$url/injectionRecord/$dogId"));
    if (res.statusCode == 200) {
      var jsonData = json.decode(res.body);
      dogRecord = jsonData
          .map<DogsRecordIdGet>((e) => DogsRecordIdGet.fromJson(e))
          .toList();
      // log(res.body);

      List<String> givenVacId = [];
      Map<String, DateTime> givenVacDate = {};
      for (var record in dogRecord) {
        givenVacId.add(record.vaccineType);
        givenVacDate[record.vaccineType] = (DateTime.parse(record.date));
      }

      vaccineNext = nextVaccineForDog(dogBirthDay, givenVacId);
    }
  }

  List<String> nextVaccineForDog(String birthday, List<String> givenVaccineId) {
    List<String> nextVaccine = [];
    int dogAge = dogAgeInWeeks(birthday);
    Map<int, int> countsVaccinePerType = {};
    Map<int, int> countsGiven = {};
    for (var num in givenVaccineId) {
      countsGiven[int.parse(num)] = (countsGiven[int.parse(num)] ?? 0) + 1;
    }
    // log(givenVaccineId.toString());

    if (dogAge < 16) {
      vaccineScheduleWeeks.forEach((vaccineId, schedule) {
        List<int>? babySchedule = schedule['baby'];
        if (babySchedule != null) {
          for (var week in babySchedule) {
            countsVaccinePerType[int.parse(vaccineId)] =
                (countsVaccinePerType[int.parse(vaccineId)] ?? 0) + 1;
            if (dogAge > week) {
              if (!nextVaccine.contains(vaccineId)) {
                nextVaccine.add(vaccineId);
              }
            }
          }

          for (var id in nextVaccine.toList()) {
            final totalCount = countsVaccinePerType[int.parse(id)];
            final givenCount = countsGiven[int.parse(id)];

            if (totalCount != null && givenCount != null) {
              if (givenCount >= totalCount) {
                nextVaccine.remove(id); // ลบออกถ้าให้ครบแล้ว
              }
            }
          }
        }
      });
    } else {
      vaccineScheduleWeeks.forEach((vaccineId, schedule) {
        List<int>? matureSchedule = schedule['mature'];
        if (matureSchedule != null) {
          for (var week in matureSchedule) {
            countsVaccinePerType[int.parse(vaccineId)] =
                (countsVaccinePerType[int.parse(vaccineId)] ?? 0) + 1;
            if (dogAge > week) {
              if (!nextVaccine.contains(vaccineId)) {
                nextVaccine.add(vaccineId);
              }
            }
          }

          for (var id in nextVaccine.toList()) {
            final totalCount = countsVaccinePerType[int.parse(id)];
            final givenCount = countsGiven[int.parse(id)];

            if (totalCount != null && givenCount != null) {
              if (givenCount >= totalCount) {
                nextVaccine.remove(id); // ลบออกถ้าให้ครบแล้ว
              }
            }
          }
        }
      });
    }
    List<String> matchedNames = nextVaccine
        .map((id) => vaccineNameMap[id] ?? 'ไม่พบชื่อวัคซีน')
        .toList();
    return matchedNames;
  }

  String getDogAge(String birthday) {
    DateTime birthDate = DateTime.parse(birthday).toLocal();
    DateTime today = DateTime.now();

    int ageInDays = today.difference(birthDate).inDays;
    int ageInWeeks = ageInDays ~/ 7;

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

  int dogAgeInWeeks(String birthDate) {
    final now = DateTime.now();
    final duration = now.difference(DateTime.parse(birthDate));
    return duration.inDays ~/ 7;
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
