import 'dart:convert';
import 'dart:developer';

import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/controller/mainClinicNavigateController.dart';
import 'package:puppal_application/controller/mainGeneralNavigateController.dart';
import 'package:puppal_application/pages/appNavigator.dart';
import 'package:puppal_application/pages/clinic/mainClinic/addDoctors/clinicAddDoctor.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicListDoctors.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicMain.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicNotification/notificationPage.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicSetting.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicVaccineHistory/VaccineHistoryPage.dart';
import 'package:puppal_application/pages/clinic/mainClinic/reserve/vaccineRequestsPage.dart';
import 'package:puppal_application/pages/clinic/registerClinic/registerClinicGoogle.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalMain.dart';
import 'package:puppal_application/pages/general/registerGeneral/dog/registerDog.dart';
import 'package:puppal_application/pages/general/registerGeneral/registerUserGoogle.dart';
import 'package:puppal_application/pages/login/index.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;

class Clinicmainbottomnavigate extends StatefulWidget {
  final int indexPage;

  const Clinicmainbottomnavigate({super.key, required this.indexPage});

  @override
  State<Clinicmainbottomnavigate> createState() =>
      _ClinicmainbottomnavigateState();
}

class ClinicmainbottomnavigateController extends GetxController {
  final Mainclinicnavigatecontroller navController =
      Get.find<Mainclinicnavigatecontroller>();

  int addDynamicPage(Widget page, {String? title}) {
    return navController.addDynamicPage(page, title: title);
  }
}

class _ClinicmainbottomnavigateState extends State<Clinicmainbottomnavigate> {
  late double screenWidth;
  late double screenHeight;
  final box = GetStorage();

  final navController = Get.find<MainNavigationController>();

  String url = '';

  // Remove this line - we'll use the controller's instance
  // late NotchBottomBarController notchBottomBarController;
  int currentIndex = 1;

  final notchBottomBarController =
      NotchBottomBarController(index: 1); // <<== เพิ่มตรงนี้ด้วย
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final List<Widget> pages = [
    VaccineRequestsPage(),
    ClinicmainPage(),
    Notificationpage(),
    Cliniclistdoctors(),
    Vaccinehistorypage(),
    Clinicsetting(),
  ];

  final List<String> appBarTitles = [
    'คำขอ',
    'PUPPAL',
    'การแจ้งเตือน',
    'หมอ',
    'ประวัติการฉีดยา',
    'ตั้งค่า',
  ];

  final List<BottomBarItem> bottomBarItems = [
    BottomBarItem(
      inActiveItem:
          Center(child: Icon(FontAwesomeIcons.syringe, color: Colors.white)),
      activeItem: Icon(FontAwesomeIcons.syringe, color: Color(0xFFDBA871)),
      itemLabel: 'คำขอ',
    ),
    BottomBarItem(
      inActiveItem:
          Center(child: Icon(FontAwesomeIcons.calendar, color: Colors.white)),
      activeItem: Icon(FontAwesomeIcons.calendar, color: Color(0xFFDBA871)),
      itemLabel: 'PUPPAL',
    ),
    BottomBarItem(
      inActiveItem: Center(
        child: Icon(FontAwesomeIcons.bell, color: Colors.white),
      ),
      activeItem: Center(
        child: Icon(FontAwesomeIcons.bell, color: Color(0xFFDBA871)),
      ),
      itemLabel: 'แจ้งเตือน',
    ),
  ];

  @override
  void initState() {
    log(widget.indexPage.toString());
    init();
    super.initState();
    currentIndex = widget.indexPage;

    // Use the controller's method to update the index properly
    navController.updateIndex(currentIndex);
  }

  void init() async {
    await Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
    });
  }

  @override
  void dispose() {
    // Don't dispose here since we're using the controller's instance
    // notchBottomBarController.dispose();
    super.dispose();
  }

  void onTap(int index) {
    setState(() {
      currentIndex = index;
      // Use the controller's method to update properly
      navController.updateIndex(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final name = box.read('clinicName') ?? 'ผู้ใช้งาน';
    final image = box.read('clinicImage') ?? 'default_image_url_or_placeholder';

    return Obx(() => Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFFDBA871),
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.white),
            title: Text(
              navController.currentIndex.value < appBarTitles.length
                  ? appBarTitles[navController.currentIndex.value]
                  : '',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: navController.currentIndex.value == 3
                ? [
                    IconButton(
                      onPressed: () {
                        AppNavigation.toWidget(Clinicadddoctor());
                      },
                      icon: CircleAvatar(
                        backgroundColor: Color(0xFFE9CBAF),
                        child: Icon(
                          FontAwesomeIcons.plus,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ]
                : null,
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
                              image,
                              width: screenWidth * 0.2,
                              height: screenWidth * 0.2,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
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
                            name,
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
                      leading: Icon(FontAwesomeIcons.syringe,
                          color: Color(0xFF916b44)),
                      title: Text('หมอประจำคลินิก'),
                      onTap: () {
                        setState(() {
                          Get.back();
                          onTap(3);
                        });
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.menu_book, color: Color(0xFF916b44)),
                      title: Text('ประวัติการฉีดวัคซีน'),
                      onTap: () {
                        setState(() {
                          Get.back();
                          onTap(4);
                        });
                      },
                    ),
                    ListTile(
                      leading:
                          Icon(FontAwesomeIcons.gear, color: Color(0xFF916b44)),
                      title: Text('ตั้งค่า'),
                      onTap: () {
                        setState(() {
                          Get.back();
                          onTap(5);
                        });
                      },
                    ),
                    ListTile(
                      leading: Icon(MdiIcons.accountSwitch,
                          color: Color(0xFF916b44)),
                      title: Text('สลับโหมด'),
                      onTap: () async {
                        var resGeneral = await http.get(Uri.parse(
                            "$url/general/name/${box.read('email')}"));
                        if (resGeneral.statusCode == 200) {
                          showAlert(
                            title: 'สลับไปยังบัญชีผู้ใช้ทั่วไป?',
                            message: 'กด ตกลง เพื่อไปยังบัญชีผู้ใช้ทั่วไป',
                            onConfirm: () {
                              box.write('type', 'general');
                              box.write('generalName',
                                  jsonDecode(resGeneral.body)['username']);
                              box.write('generalImage',
                                  jsonDecode(resGeneral.body)['image']);
                              Get.offAll(() => GeneralmainPage());
                            },
                          );
                        } else {
                          showAlert(
                            title: 'คุณยังไม่มีบัญชีผู้ใช้ทั่วไป!',
                            message: 'กด ตกลง เพื่อไปยังหน้าสมัครผู้ใช้ทั่วไป',
                            onConfirm: () async {
                              await FirebaseMessaging.instance.deleteToken();
                              Get.back();
                              Get.to(() => RegisterusergooglePage());
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
          extendBody: true,
          bottomNavigationBar: Container(
            height: screenHeight * 0.1,
            decoration: BoxDecoration(
              color: Colors.transparent,
            ),
            child: AnimatedNotchBottomBar(
              showTopRadius: true,
              showBottomRadius: false,
              elevation: 0,
              removeMargins: true,
              notchBottomBarController: navController.notchBottomBarController,
              bottomBarItems: bottomBarItems,
              onTap: (index) {
                if (index <= 2) {
                  onTap(index);
                }
              },
              kIconSize: 20,
              kBottomRadius: 0,
              itemLabelStyle: TextStyle(color: Colors.white),
              color: Color(0xFFDBA871),
              durationInMilliSeconds: 500,
            ),
          ),
          body: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop) {
                final handled = AppNavigation.handleSystemBack();
                if (!handled) {
                  showAlert(
                    title: 'คุณต้องการออกจากแอปใช่หรือไม่',
                    message: '',
                    onConfirm: () {
                      Get.back();
                    },
                  );
                }
              }
            },
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, screenHeight * 0.075),
              child: SafeArea(
                bottom: false,
                child: getCurrentPage(),
              ),
            ),
          ),
        ));
  }

  Widget getCurrentPage() {
    final index = navController.currentIndex.value;

    // Check if it's a dynamic page
    if (navController.dynamicPages.containsKey(index)) {
      return navController.dynamicPages[index]!;
    }
    if (index >= 0 && index < pages.length) {
      return pages[index];
    }
    // Regular pages
    switch (index) {
      case 0:
        return VaccineRequestsPage();
      case 1:
        return ClinicmainPage();
      case 2:
        return Notificationpage();
      case 3:
        return Cliniclistdoctors();
      case 4:
        return Vaccinehistorypage();
      case 5:
        return Clinicsetting();
      default:
        return ClinicmainPage();
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
}
