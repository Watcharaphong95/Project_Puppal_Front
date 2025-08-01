import 'dart:convert';
import 'dart:developer';

import 'package:curved_navigation_bar/curved_navigation_bar.dart'; // NEW IMPORT
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/controller/mainGeneralNavigateController.dart';
import 'package:puppal_application/pages/clinicMainBottomNavigate.dart';
import 'package:puppal_application/pages/generalAppNavigator.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicMain.dart';
import 'package:puppal_application/pages/clinic/registerClinic/registerClinicGoogle.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalDog.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalGuide.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalMain.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalNotification.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalSetting.dart';
import 'package:puppal_application/pages/general/recordDog/generalRecordSearch.dart';
import 'package:http/http.dart' as http;
import 'package:puppal_application/pages/general/registerGeneral/dog/registerDog.dart';
import 'package:puppal_application/pages/login/index.dart';
import 'package:shimmer/shimmer.dart';

class GeneralMainBottomNavigate extends StatefulWidget {
  final int indexPage;

  const GeneralMainBottomNavigate({
    super.key,
    required this.indexPage,
  });

  @override
  State<GeneralMainBottomNavigate> createState() =>
      _GeneralMainBottomNavigateState();
}

class GeneralMainBottomNavigateController extends GetxController {
  final MainNavigationController navController =
      Get.find<MainNavigationController>();

  int addDynamicPage(Widget page, {String? title}) {
    return navController.addDynamicPage(page, title: title);
  }
}

class _GeneralMainBottomNavigateState extends State<GeneralMainBottomNavigate> {
  late double screenWidth;
  late double screenHeight;
  final box = GetStorage();

  final navController = Get.find<MainNavigationController>();

  String url = '';

  int currentIndex = 1;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Remove the old bottomBarItems - we'll define the curved nav items directly

  @override
  void initState() {
    log(widget.indexPage.toString());
    super.initState();
    currentIndex = widget.indexPage;
    init();
  }

  void init() async {
    await Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
    });
    // No need to set notchBottomBarController anymore
    navController.currentIndex.value = currentIndex;
  }

  @override
  void dispose() {
    // No controller to dispose
    super.dispose();
  }

  void onTap(int index) {
    setState(() {
      currentIndex = index;
      // GeneralAppNavigation.clearStack();
      navController.updateIndex(index);
    });
    GeneralAppNavigation.printStack();
    log('Index: ${currentIndex.toString()}');
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Obx(() => Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFFDBA871),
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.white),
            title: Text(
              navController.getPageTitle(navController.currentIndex.value),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600),
            ),
            actions: (navController.currentIndex.value == 0 ||
                    navController.currentIndex.value == 6)
                ? [
                    IconButton(
                      onPressed: () {
                        Get.to(() => RegisterdogPage());
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
                            child: (box.read('generalImage') != null &&
                                    (box.read('generalImage') as String)
                                        .isNotEmpty)
                                ? Image.network(
                                    box.read('generalImage'),
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
                                  )
                                : Container(
                                    width: screenWidth * 0.2,
                                    height: screenWidth * 0.2,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.person,
                                        size: 40, color: Colors.white),
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
                      leading: SizedBox(
                        width: 40,
                        child: Icon(FontAwesomeIcons.syringe,
                            color: Color(0xFF916b44)),
                      ),
                      title: Text('ประวัติการฉีดวัคซีน'),
                      onTap: () {
                        setState(() {
                          Get.back();
                          onTap(3);
                        });
                      },
                    ),
                    ListTile(
                      leading: SizedBox(
                          width: 40,
                          child:
                              Icon(Icons.menu_book, color: Color(0xFF916b44))),
                      title: Text('คู่มือ'),
                      onTap: () {
                        setState(() {
                          Get.back();
                          onTap(4);
                        });
                      },
                    ),
                    ListTile(
                      leading: SizedBox(
                          width: 40,
                          child: Icon(FontAwesomeIcons.gear,
                              color: Color(0xFF916b44))),
                      title: Text('ตั้งค่า'),
                      onTap: () {
                        setState(() {
                          Get.back();
                          onTap(5);
                        });
                      },
                    ),
                    ListTile(
                      leading: SizedBox(
                        width: 40,
                        child: Icon(MdiIcons.accountSwitch,
                            color: Color(0xFF916b44)),
                      ),
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
                              Get.offAll(
                                  () => Clinicmainbottomnavigate(indexPage: 1));
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
                      leading: SizedBox(
                        width: 40,
                        child: Icon(FontAwesomeIcons.doorOpen,
                            color: Colors.redAccent),
                      ),
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
          // NEW CURVED NAVIGATION BAR
          body: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop) {
                final handled = GeneralAppNavigation.handleSystemBack();
                if (!handled) {
                  showAlert(
                      title: 'คุณต้องการออกจากแอปใช่หรือไม่',
                      message: '',
                      onConfirm: () {
                        Get.back();
                      });
                }
              }
            },
            child: SafeArea(
              child: Stack(
                children: [
                  // Main page content - full screen
                  Container(
                    color: Color(0xFFFAF8F5),
                    height: screenHeight,
                    padding:
                        EdgeInsets.fromLTRB(0, 0, 0, screenHeight * 0.0725),
                    child: SafeArea(bottom: false, child: getCurrentPage()),
                  ),
                  // Floating bottom navigation bar
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: navController.currentIndex.value > 2
                        ? // Custom navigation bar when index > 2 (all buttons unselected)
                        Container(
                            height: 60.0,
                            decoration: BoxDecoration(
                              color: Color(0xFFDBA871)
                                  .withOpacity(0.9), // Semi-transparent
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Dog button - unselected
                                GestureDetector(
                                  onTap: () => onTap(0),
                                  child: Container(
                                    padding: EdgeInsets.all(12),
                                    child: Icon(
                                      FontAwesomeIcons.dog,
                                      size: 30,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                // Calendar button - unselected
                                GestureDetector(
                                  onTap: () => onTap(1),
                                  child: Container(
                                    padding: EdgeInsets.all(12),
                                    child: Icon(
                                      FontAwesomeIcons.calendar,
                                      size: 30,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                // Bell button - unselected
                                GestureDetector(
                                  onTap: () => onTap(2),
                                  child: Container(
                                    padding: EdgeInsets.all(12),
                                    child: Icon(
                                      FontAwesomeIcons.bell,
                                      size: 30,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : // Normal CurvedNavigationBar when index <= 2
                        CurvedNavigationBar(
                            index: navController.currentIndex.value,
                            height: 60.0,
                            items: <Widget>[
                              Icon(FontAwesomeIcons.dog,
                                  size: 30, color: Colors.white),
                              Icon(FontAwesomeIcons.calendar,
                                  size: 30, color: Colors.white),
                              Icon(FontAwesomeIcons.bell,
                                  size: 30, color: Colors.white),
                            ],
                            color: Color(0xFFDBA871)
                                .withOpacity(0.9), // Semi-transparent
                            buttonBackgroundColor:
                                Color(0xFFE9CBAF).withOpacity(0.9),
                            backgroundColor: Colors.transparent,
                            animationCurve: Curves.easeInOut,
                            animationDuration: Duration(milliseconds: 500),
                            onTap: (index) {
                              onTap(index);
                            },
                            letIndexChange: (index) => true,
                          ),
                  ),
                ],
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

    // Regular pages
    switch (index) {
      case 0:
        return GeneraldogPage();
      case 1:
        return GeneralmainPage();
      case 2:
        return GeneralnotificationPage();
      case 3:
        return GeneralrecordsearchPage();
      case 4:
        return GeneralguidePage();
      case 5:
        return GeneralprofilePage();
      default:
        return GeneralmainPage();
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
