import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:puppal_application/controller/registerClinicCtl.dart';
import 'package:puppal_application/controller/registerDoctorCtl.dart';
import 'package:puppal_application/controller/registerGeneralCtl.dart';
import 'package:puppal_application/pages/index.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  await GetStorage.init();
  await Supabase.initialize(
      url: 'https://ombydonicueujwrhhcnl.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9tYnlkb25pY3VldWp3cmhoY25sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU0OTUwNzIsImV4cCI6MjA2MTA3MTA3Mn0.KafiBfl_6rdE3os66qKn8orpsEecV-SAVq6nRW1IpyQ');
  Get.put(RegisterGeneralCtl());
  Get.put(registerClinicCtl());
  Get.put(registerDoctorCtl());
  Get.put(doctorDataList());

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: GoogleFonts.notoSansThai().fontFamily,
      ),
      home: const IndexPage(),
    );
  }
}
