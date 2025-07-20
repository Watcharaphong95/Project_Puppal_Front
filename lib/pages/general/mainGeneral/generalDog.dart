import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/controller/registerDogInjectionHistoryCtl.dart';
import 'package:puppal_application/model/dogsGetEmail.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicMain.dart';
import 'package:puppal_application/pages/clinic/registerClinic/registerClinicGoogle.dart';
import 'package:puppal_application/pages/general/mainGeneral/dogInfo/dogProfile.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalGuide.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalMain.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalNotification.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalSetting.dart';
import 'package:puppal_application/pages/general/recordDog/generalRecord.dart';
import 'package:puppal_application/pages/general/recordDog/generalRecordSearch.dart';
import 'package:puppal_application/pages/general/registerGeneral/dog/registerDog.dart';
import 'package:puppal_application/pages/login/index.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class GeneraldogPage extends StatefulWidget {
  const GeneraldogPage({super.key});

  @override
  State<GeneraldogPage> createState() => _GeneraldogPageState();
}

class _GeneraldogPageState extends State<GeneraldogPage> {
  late double screenWidth;
  late double screenHeight;
  final box = GetStorage();

  bool isLoading = true;

  String url = '';

  List<DogsGetEmail> dogs = [];
  List<DogsGetEmail> filterDogs = [];

  TextEditingController searchDogCtl = TextEditingController();

  @override
  void initState() {
    log(box.read('generalImage'));
    init();
    super.initState();
  }

  void init() async {
    await Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
    });
    await getDogData();
    filterDogs = List<DogsGetEmail>.from(dogs);
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'สุนัขของฉัน',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF916B44),
        actions: [
          IconButton(
              onPressed: () {
                Get.to(() => RegisterdogPage());
              },
              icon: CircleAvatar(
                backgroundColor: Color(0xFFDBA871),
                child: Icon(
                  FontAwesomeIcons.plus,
                  color: Colors.white,
                ),
              ))
        ],
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
                  ),
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
                    }),
                ListTile(
                  leading: Icon(FontAwesomeIcons.dog, color: Color(0xFF916b44)),
                  title: Text('สุนัข',
                      style: TextStyle(
                        color: Color(0xFF916b44),
                        fontWeight: FontWeight.bold,
                      )),
                ),
                ListTile(
                  leading:
                      Icon(FontAwesomeIcons.syringe, color: Color(0xFF916b44)),
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
      body: Container(
        // height: screenHeight * 0.9,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/indexBg.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.2), BlendMode.dstATop)),
        ),
        child: SizedBox(
          width: screenWidth,
          child: Column(
            children: [
              SizedBox(
                height: screenHeight * 0.01,
              ),
              SizedBox(
                width: screenWidth * 0.9,
                child: TextField(
                  controller: searchDogCtl,
                  onChanged: (value) {
                    if (value.isEmpty) {
                      filterDogs = dogs;
                    }
                    filterDogs = dogs.where((dog) {
                      return dog.name
                          .toLowerCase()
                          .contains(value.toLowerCase());
                    }).toList();
                  },
                  decoration: InputDecoration(
                    hintText: 'ค้นหาสุนัข',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(FontAwesomeIcons.magnifyingGlass),
                    suffixIcon: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {
                            searchDogCtl.clear();
                            FocusScope.of(context).unfocus();
                            setState(() {
                              filterDogs = List<DogsGetEmail>.from(dogs);
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (isLoading)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.2),
                  child: Center(
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
                  ),
                )
              else if (filterDogs.isEmpty)
                Expanded(
                  child: SizedBox(
                    width: screenWidth,
                    height: screenHeight * 0.5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'คุณยังไม่มีสุนัขที่ลงทะเบียน',
                          style: TextStyle(fontSize: 32, color: Colors.grey),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'กดปุ่ม ',
                              style:
                                  TextStyle(fontSize: 24, color: Colors.grey),
                            ),
                            CircleAvatar(
                              backgroundColor: Color(0xFFEFD2B1),
                              child: Icon(
                                FontAwesomeIcons.plus,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              ' ขวาบนเพื่อเพิ่มสุนัข',
                              style:
                                  TextStyle(fontSize: 24, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                    child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  children: filterDogs.map((dog) {
                    return SizedBox(
                      height: screenHeight * 0.15,
                      child: Card(
                        color: Color(0xFFF1F1F1),
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  dog.image,
                                  width: screenWidth * 0.2,
                                  height: screenHeight * 0.1,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Shimmer.fromColors(
                                        baseColor: Colors.grey.shade300,
                                        highlightColor: Colors.grey.shade100,
                                        child: Container(
                                          width: screenWidth * 0.2,
                                          height: screenHeight * 0.1,
                                          color: Colors.white,
                                        ));
                                  },
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      dog.name,
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'อายุ ${getDogAge(dog.birthday.toString())}',
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                    Text(
                                      'วันเกิด ${DateFormat('d MMMM y', 'th').format(DateTime.parse(dog.birthday.toString()).toLocal())}...',
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 35,
                                width: 45,
                                decoration: BoxDecoration(
                                  color: Color(0xFFDBA871),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.arrow_forward,
                                      color: Colors.white, size: 25),
                                  onPressed: () {
                                    Get.to(
                                        () => DogprofilePage(dogId: dog.dogId));
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ))
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
