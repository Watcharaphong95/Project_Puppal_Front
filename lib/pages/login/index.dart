import 'dart:convert';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/main.dart';
import 'package:puppal_application/model/fcmTokenPost.dart';
import 'package:puppal_application/model/userPost.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicMain.dart';
import 'package:puppal_application/pages/clinicMainBottomNavigate.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalMain.dart';
import 'package:puppal_application/pages/generalMainBottomNavigate.dart';
import 'package:puppal_application/pages/login/login.dart';
import 'package:puppal_application/pages/login/loginTypeSelect.dart';
import 'package:puppal_application/pages/login/registerType.dart';
import 'package:http/http.dart' as http;

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  late double screenWidth;
  late double screenHeight;

  String url = '';

  bool isLoading = true;

  final box = GetStorage();
  final GoogleSignIn _google = GoogleSignIn(
    scopes: ['email'],
  );

  @override
  void initState() {
    // box.erase();

    if (box.read('emailGoogleRegister') != null) {
      log(box.read('emailGoogleRegister'));
      box.remove('emailGoogleRegister');
    }
    _setupNotifications();
    init();
    super.initState();
  }

  void init() async {
    await Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
    });
    await checkLogout();
    if (box.read('email') != null) {
      await updateFcm();
    }
    stopRealTime();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/indexBg.png'),
                fit: BoxFit.cover)),
        width: screenWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, screenHeight * 0.1, 0, 0),
              child: Text('PUPPAL',
                  style: TextStyle(
                      fontSize: 65,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 5,
                      fontStyle: FontStyle.italic)),
            ),
            SizedBox(
              width: screenWidth * 0.9,
              height: screenHeight * 0.4,
              child: Card(
                elevation: 5,
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.775),
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            SizedBox(
                              width: screenWidth * 0.7,
                              child: Text(
                                'จองฉีดยาให้กับสุนัขของคุณ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 32, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 7.5),
                              child: SizedBox(
                                width: screenWidth * 0.75,
                                child: ElevatedButton(
                                    onPressed: loginButton,
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      backgroundColor: Color(0xFF916b44),
                                    ),
                                    child: Text(
                                      'ล็อกอิน',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    )),
                              ),
                            ),
                            SizedBox(
                              width: screenWidth * 0.75,
                              child: ElevatedButton(
                                  onPressed: googleLoginButton,
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/googleLoginIcon.png',
                                        width: 30,
                                        height: 30,
                                      ),
                                      Text(
                                        ' เข้าสู่ระบบโดย Google ',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ],
                                  )),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('คุณมีบัญชีผู้ใช้หรือยัง?'),
                                TextButton(
                                    onPressed: registerButton,
                                    child: Text(
                                      'สมัคร',
                                      style: TextStyle(
                                          color: Colors.black,
                                          decoration: TextDecoration.underline),
                                    ))
                              ],
                            )
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> updateFcm() async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    FcmTokenPost token =
        FcmTokenPost(userEmail: box.read('email'), fcmToken: fcmToken!);

    var tokenUpdate = await http.put(
      Uri.parse("$url/user/fcmToken"),
      headers: {"Content-Type": "application/json; charset=utf-8"},
      body: fcmTokenPostToJson(token),
    );
  }

  void registerButton() {
    Get.to(() => RegistertypePage());
  }

  Future<void> googleLoginButton() async {
    _google.signOut();
    box.erase();
    try {
      final GoogleSignInAccount? account = await _google.signIn();
      if (account != null) {
        showLoadingDialog();
        var res =
            await http.get(Uri.parse("$url/user/google/${account.email}"));
        Get.back();
        if (res.statusCode == 200) {
          final user = userPostFromJson(res.body);
          box.write('email', user.email);
          if (user.general == 1 && user.clinic == 1) {
            Get.to(() => LogintypeselectPage());
          } else if (user.general == 1) {
            showLoadingDialog();
            var resGeneral = await http
                .get(Uri.parse("$url/general/name/${box.read('email')}"));
            box.write('type', 'general');
            box.write('generalName', jsonDecode(resGeneral.body)['username']);
            box.write('generalImage', jsonDecode(resGeneral.body)['image']);
            box.write(
                'generalUsername', jsonDecode(resGeneral.body)['username']);
            String? fcmToken = await FirebaseMessaging.instance.getToken();
            FcmTokenPost token =
                FcmTokenPost(userEmail: box.read('email'), fcmToken: fcmToken!);

            var tokenUpdate = await http.put(
              Uri.parse("$url/user/fcmToken"),
              headers: {"Content-Type": "application/json; charset=utf-8"},
              body: fcmTokenPostToJson(token),
            );
            if (tokenUpdate.statusCode == 201) {
              log('Name ${box.read('generalName')}');
              Get.back();
              Get.offAll(() => GeneralMainBottomNavigate(indexPage: 1));
            } else {
              Get.snackbar(
                'ข้อผิดพลาด',
                'กรุณาลองใหม่อีกครั้ง',
                snackPosition: SnackPosition.TOP,
                backgroundColor: const Color.fromARGB(255, 211, 89, 89),
                colorText: Colors.white,
                borderRadius: 12,
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 2),
                snackStyle: SnackStyle.FLOATING,
                isDismissible: true,
              );
              return;
            }
          } else if (user.clinic == 1) {
            showLoadingDialog();
            var resClinic = await http
                .get(Uri.parse("$url/clinic/name/${box.read('email')}"));
            box.write('type', 'clinic');
            box.write('clinicName', jsonDecode(resClinic.body)['name']);
            box.write('clinicImage', jsonDecode(resClinic.body)['image']);
            String? fcmToken = await FirebaseMessaging.instance.getToken();
            FcmTokenPost token =
                FcmTokenPost(userEmail: box.read('email'), fcmToken: fcmToken!);

            var tokenUpdate = await http.put(
              Uri.parse("$url/user/fcmToken"),
              headers: {"Content-Type": "application/json; charset=utf-8"},
              body: fcmTokenPostToJson(token),
            );
            if (tokenUpdate.statusCode == 201) {
              log('Name ${box.read('clinicName')}');
              Get.back();
              Get.offAll(() => Clinicmainbottomnavigate(
                    indexPage: 1,
                  ));
            } else {
              Get.snackbar(
                'ข้อผิดพลาด',
                'กรุณาลองใหม่อีกครั้ง',
                snackPosition: SnackPosition.TOP,
                backgroundColor: const Color.fromARGB(255, 211, 89, 89),
                colorText: Colors.white,
                borderRadius: 12,
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 2),
                snackStyle: SnackStyle.FLOATING,
                isDismissible: true,
              );
              return;
            }
          }
        } else {
          showLoadingDialog();
          var res = await http.get(Uri.parse("$url/user/${account.email}"));
          Get.back();
          if (res.statusCode == 200) {
            showAlertNoClose(
                title: 'อีเมลนี้ถูกใช้แล้ว!',
                message: 'กรุณาล็อคอินให้ถูกวิธี');
          } else {
            box.write('emailGoogleRegister', account.email);
            Get.to(() => RegistertypePage());
          }
        }
      }
    } catch (error) {
      log("Google Sign-In error: $error");
    }
  }

  void loginButton() {
    Get.to(() => LoginPage());
  }

  void _setupNotifications() async {
    await Firebase.initializeApp();
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    log('🔔 Notification permission: ${settings.authorizationStatus}');
  }

  void stopRealTime() {
    final appData = context.read<AppData>();

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

  void showAlertNoClose({
    required String title,
    required String message,
    VoidCallback? onConfirm, // Optional action
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFD7CCC8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                size: 24,
                color: Color(0xFFA1887F),
              ),
            ),
            const SizedBox(height: 16),
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
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  if (onConfirm != null) {
                    onConfirm();
                  } else {
                    Get.back(); // Default action
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF795548),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
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

  Future<void> checkLogout() async {
    if (box.read('email') != null && box.read('email') != '') {
      var res = await http.get(Uri.parse("$url/user/${box.read('email')}"));
      if (res.statusCode == 200) {
        final user = userPostFromJson(res.body);
        if (user.general == 1 && user.clinic == 1) {
          Get.to(() => LogintypeselectPage());
        } else if (user.general == 1) {
          var resGeneral = await http
              .get(Uri.parse("$url/general/name/${box.read('email')}"));
          box.write('type', 'general');
          box.write('generalName', jsonDecode(resGeneral.body)['username']);
          box.write('generalImage', jsonDecode(resGeneral.body)['image']);
          log('Name ${box.read('generalName')}');
          Get.offAll(() => GeneralMainBottomNavigate(indexPage: 1));
        } else if (user.clinic == 1) {
          var resClinic = await http
              .get(Uri.parse("$url/clinic/name/${box.read('email')}"));
          box.write('type', 'clinic');
          box.write('clinicName', jsonDecode(resClinic.body)['name']);
          box.write('clinicImage', jsonDecode(resClinic.body)['image']);
          log('Name ${box.read('clinicName')}');
          Get.offAll(() => Clinicmainbottomnavigate(indexPage: 1));
        }
      }
    }
  }
}
