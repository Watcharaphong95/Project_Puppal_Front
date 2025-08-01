import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/model/dogsGetEmail.dart';
import 'package:puppal_application/pages/generalAppNavigator.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicMain.dart';
import 'package:puppal_application/pages/clinic/registerClinic/registerClinicGoogle.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalDog.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalGuide.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalMain.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalNotification.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalSetting.dart';
import 'package:puppal_application/pages/general/recordDog/generalRecord.dart';
import 'package:puppal_application/pages/login/index.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class GeneralrecordsearchPage extends StatefulWidget {
  const GeneralrecordsearchPage({super.key});

  @override
  State<GeneralrecordsearchPage> createState() =>
      _GeneralrecordsearchPageState();
}

class _GeneralrecordsearchPageState extends State<GeneralrecordsearchPage> {
  late double screenWidth;
  late double screenHeight;
  final box = GetStorage();

  String url = '';

  List<DogsGetEmail> dogs = [];
  List<DogsGetEmail> filterDogs = [];

  bool isLoading = true;

  TextEditingController searchDogCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
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
        // appBar: AppBar(
        //   title: Text(
        //     'ประวัติการฉีดยา',
        //     style: TextStyle(color: Colors.white),
        //   ),
        //   centerTitle: true,
        //   backgroundColor: Color(0xFFDBA871),
        //   iconTheme: IconThemeData(color: Colors.white),
        // ),
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
                      color: Color(0xFFDBA871),
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
                    title: Text('ประวัติการฉีดยา',
                        style: TextStyle(
                          color: Color(0xFF916b44),
                          fontWeight: FontWeight.bold,
                        )),
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
        body: Container(
          height: screenHeight * 0.89,
          // decoration: BoxDecoration(
          //   gradient: LinearGradient(
          //     begin: Alignment.topCenter,
          //     end: Alignment.bottomCenter,
          //     colors: [
          //       Color(0xFFF8F9FA),
          //       Color(0xFFE9ECEF),
          //     ],
          //   ),
          // ),
          color: Color(0xFFFAF8F5),
          child: Column(
            children: [
              // Header Section
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'สุนัขของคุณ',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
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
                          setState(() {});
                        },
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF916B44),
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: Container(
                            margin: EdgeInsets.all(12),
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color(0xFFE9CBAF).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              FontAwesomeIcons.magnifyingGlass,
                              color: Color(0xFF916B44),
                              size: 20,
                            ),
                          ),
                          suffixIcon: searchDogCtl.text.isNotEmpty
                              ? InkWell(
                                  onTap: () {
                                    searchDogCtl.clear();
                                    FocusScope.of(context).unfocus();
                                    setState(() {
                                      filterDogs =
                                          List<DogsGetEmail>.from(dogs);
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.all(12),
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFDBA871).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.clear,
                                      color: Color(0xFF916B44),
                                      size: 20,
                                    ),
                                  ),
                                )
                              : null,
                          border: InputBorder.none,
                          hintText: 'ค้นหาสุนัข',
                          hintStyle: TextStyle(
                            color: Color(0xFF916B44).withOpacity(0.5),
                            fontSize: 16,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content Section
              Expanded(
                child: isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFDBA871)),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'กำลังโหลด...',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : filterDogs.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  FontAwesomeIcons.dog,
                                  size: 64,
                                  color: Colors.grey[300],
                                ),
                                SizedBox(height: 24),
                                Text(
                                  'ไม่มีสุนัขที่ลงทะเบียน',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'เริ่มต้นลงทะเบียนที่หน้าสุนัขของคุณ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.05),
                            child: GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.65,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                              ),
                              itemCount: filterDogs.length,
                              physics: BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                final dog = filterDogs[index];
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 15,
                                        offset: Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Dog Image
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(20),
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(20),
                                            ),
                                            child: Image.network(
                                              dog.image,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Shimmer.fromColors(
                                                  baseColor:
                                                      Colors.grey.shade200,
                                                  highlightColor:
                                                      Colors.grey.shade50,
                                                  child: Container(
                                                    color: Colors.white,
                                                  ),
                                                );
                                              },
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey[100],
                                                  child: Icon(
                                                    FontAwesomeIcons.dog,
                                                    size: 40,
                                                    color: Colors.grey[400],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Dog Info
                                      Expanded(
                                        flex: 1,
                                        child: Padding(
                                          padding: EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                dog.name,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF2D3748),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(
                                                width: double.infinity,
                                                height: screenHeight * 0.045,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    GeneralAppNavigation
                                                        .toWidget(
                                                            GeneralrecordPage(
                                                              index: dog.dogId,
                                                            ),
                                                            title:
                                                                'ประวัติการฉีดยา');
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Color(0xFFDBA871),
                                                    foregroundColor:
                                                        Colors.white,
                                                    elevation: 0,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical:
                                                                screenHeight *
                                                                    0.01),
                                                  ),
                                                  child: Text(
                                                    'ดูประวัติ',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ));
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
