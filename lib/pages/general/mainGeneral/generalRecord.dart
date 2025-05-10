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
import 'package:puppal_application/pages/general/mainGeneral/generalMain.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalNotification.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalProfile.dart';
import 'package:puppal_application/pages/login/index.dart';
import 'package:http/http.dart' as http;

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
    '3': 'วัคซีนรวม 6 โรค (DHPPiL + Corona)',
    '4': 'วัคซีนป้องกันโรคหลอดลมอักเสบ (Kennel Cough)',
    '5': 'วัคซีนป้องกันโรคลายม์ (Lyme Disease)',
    '6': 'วัคซีนป้องกันเชื้อโคโรนาไวรัสในสุนัข (Canine Coronavirus)',
    '7': 'วัคซีนป้องกันโรคพยาธิในลำไส้',
    '8': 'วัคซีนป้องกันโรคพยาธิหัวใจ (Heartworm)',
    '9': 'วัคซีนป้องกันโรคปอดบวม (Pneumonia)',
    '10': 'วัคซีนป้องกันโรคหัดสุนัข (Canine Distemper)',
    '11': 'วัคซีนป้องกันโรคไวรัสตับอักเสบ (Canine Adenovirus)',
    '12': 'วัคซีนป้องกันโรคไข้ทับทิม (Canine Parvovirus)',
    '13': 'วัคซีนป้องกันโรคพยาธิในเลือด (Ehrlichiosis)',
  };

  final Map<String, IconData> vaccineIcons = {
    '1': FontAwesomeIcons.shieldHeart,
    '2': FontAwesomeIcons.shieldDog,
    '3': FontAwesomeIcons.shieldDog,
    '4': FontAwesomeIcons.wind,
    '5': FontAwesomeIcons.bug,
    '6': FontAwesomeIcons.virus,
    '7': FontAwesomeIcons.dna,
    '8': FontAwesomeIcons.heartCircleBolt,
    '9': FontAwesomeIcons.lungs,
    '10': FontAwesomeIcons.headSideCough,
    '11': FontAwesomeIcons.virusCovid,
    '12': FontAwesomeIcons.virusSlash,
    '13': FontAwesomeIcons.droplet,
  };

  final Map<RangeValues, List<String>> vaccineSchedule = {
    RangeValues(6, 8): ['1'],
    RangeValues(9, 11): ['1', '6', '4'],
    RangeValues(12, 15): ['1', '2', '5'],
    RangeValues(16, 20): ['1'],
    RangeValues(24, 51): ['8', '13'],
    RangeValues(52, 999): ['1', '2', '6', '4', '5', '8', '13'],
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
        title: Text('ประวัติการฉีดยา'),
        centerTitle: true,
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
                  leading:
                      Icon(FontAwesomeIcons.house, color: Color(0xFF916b44)),
                  title: Text('หน้าหลัก'),
                  onTap: () {
                    Get.to(() => GeneralmainPage());
                  },
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
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
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
                                            'ต้องได้รับ ${vaccineNext.map((id) => vaccineNameMap[id] ?? 'วัคซีนไม่ทราบชื่อ').join(', ')}',
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
                                              vaccineName,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            subtitle: Text(
                                              "วันที่ฉีด: ${DateFormat('d MMMM y', 'th').format(DateTime.parse(record.date).toLocal())}",
                                              style: TextStyle(fontSize: 15),
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
      for (var record in dogRecord) {
        givenVacId.add(record.vaccineType);
      }
      log(givenVacId.toString());

      vaccineNext = getNextVaccines(
          birthDate: DateTime.parse(dogBirthDay), givenVaccineIds: givenVacId);
      log(vaccineNext.toString());
      log('${vaccineNext.map((id) => vaccineNameMap[id] ?? 'วัคซีนไม่ทราบชื่อ').join(', ')}');
    }
  }

  List<String> getNextVaccines({
    required DateTime birthDate,
    required List<String> givenVaccineIds,
  }) {
    final Map<String, List<String>> vaccineCoverage = {
      '1': ['1', '10', '11', '12', '7'], // DHPPiL
      '3': ['3', '1', '10', '11', '12', '7', '6'], // DHPPiL + Corona
      '2': ['2'],
      '4': ['4'],
      '5': ['5'],
      '6': ['6'],
      '7': ['7'],
      '8': ['8'],
      '9': ['9'],
      '10': ['10'],
      '11': ['11'],
      '12': ['12'],
      '13': ['13'],
    };

    final now = DateTime.now();
    final ageInWeeks = now.difference(birthDate).inDays ~/ 7;

    final Set<String> givenSet = {};
    for (final id in givenVaccineIds) {
      givenSet.addAll(vaccineCoverage[id] ?? [id]);
    }

    for (var entry in vaccineSchedule.entries) {
      final range = entry.key;
      final vaccines = entry.value;

      if (ageInWeeks >= range.start && ageInWeeks <= range.end) {
        final remaining =
            vaccines.where((id) => !givenSet.contains(id)).toList();
        return remaining;
      }
    }

    return [];
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
