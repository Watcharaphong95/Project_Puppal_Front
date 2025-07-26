import 'dart:async';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:puppal_application/controller/mainClinicNavigateController.dart';
import 'package:puppal_application/controller/mainGeneralNavigateController.dart';
import 'package:puppal_application/controller/registerClinicCtl.dart';
import 'package:puppal_application/controller/registerDoctorCtl.dart';
import 'package:puppal_application/controller/registerDogCtl.dart';
import 'package:puppal_application/controller/registerDogInjectionHistoryCtl.dart';
import 'package:puppal_application/controller/registerGeneralCtl.dart';
import 'package:puppal_application/pages/generalAppNavigator.dart';
import 'package:puppal_application/pages/clinicAppNavigator.dart';
import 'package:puppal_application/pages/generalMainBottomNavigate.dart';
import 'package:puppal_application/pages/login/loadingCheck.dart';
import 'package:puppal_application/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  await GetStorage.init();
  await Firebase.initializeApp();
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.instance.requestPermission(provisional: true);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await NotificationService.initialize();
  await Supabase.initialize(
      url: 'https://ombydonicueujwrhhcnl.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9tYnlkb25pY3VldWp3cmhoY25sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU0OTUwNzIsImV4cCI6MjA2MTA3MTA3Mn0.KafiBfl_6rdE3os66qKn8orpsEecV-SAVq6nRW1IpyQ');
  Get.put(RegisterGeneralCtl());
  Get.put(registerClinicCtl());
  Get.put(registerDoctorCtl());
  Get.put(doctorDataList());
  Get.put(registerDogCtl());
  Get.put(RegisterDogInjectionCtl());
  Get.put(injectionRecordList());
  Get.put(MainNavigationController());
  Get.put(Mainclinicnavigatecontroller());
  Get.put(GeneralMainBottomNavigateController());
  GeneralAppNavigation.initialize();
  Clinicappnavigator.initialize();

  runApp(ChangeNotifierProvider(
    create: (_) => AppData(),
    child: MyApp(),
  ));
}

final supabase = Supabase.instance.client;

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//         fontFamily: GoogleFonts.notoSansThai().fontFamily,
//       ),
//       supportedLocales: const [
//         Locale('th', 'TH'),
//         Locale('en', 'US'),
//       ],
//       localizationsDelegates: [
//         GlobalMaterialLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//       ],
//       home: const LoadingcheckPage(),
//     );
//   }
// }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    FirebaseMessaging.instance.requestPermission();

    FirebaseMessaging.instance.getToken().then((token) {
      log("📲 Device Token: $token");
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('🔔 Notification Received: ${message.notification?.title}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('📨 App opened from notification');
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: GoogleFonts.notoSansThai().fontFamily,
      ),
      supportedLocales: const [
        Locale('th', 'TH'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: const LoadingcheckPage(),
    );
  }
}

class AppData with ChangeNotifier {
  StreamSubscription? listener;
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("🔕 Background message: ${message.notification?.title}");
}
