import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicMain.dart';
import 'package:puppal_application/pages/clinic/registerClinic/registerClinicGoogle.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalDog.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalMain.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalNotification.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalSetting.dart';
import 'package:puppal_application/pages/general/recordDog/generalRecordSearch.dart';
import 'package:puppal_application/pages/login/index.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class GeneralguidePage extends StatefulWidget {
  const GeneralguidePage({super.key});

  @override
  State<GeneralguidePage> createState() => _GeneralguidePageState();
}

class _GeneralguidePageState extends State<GeneralguidePage> {
  late double screenWidth;
  late double screenHeight;
  final box = GetStorage();
  String url = '';

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
    });
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(
      //     'คู่มือการเลี้ยงสุนัข',
      //     style: TextStyle(
      //         color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
      //   ),
      //   centerTitle: true,
      //   iconTheme: IconThemeData(color: Colors.white),
      //   backgroundColor: Color(0xFFDBA871),
      //   elevation: 0,
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
                  title: Text('ประวัติการฉีดยา'),
                  onTap: () {
                    Get.back();
                    Get.to(() => GeneralrecordsearchPage());
                  },
                ),
                ListTile(
                  leading: Icon(Icons.menu_book, color: Color(0xFF916b44)),
                  title: Text('คู่มือ',
                      style: TextStyle(
                        color: Color(0xFF916b44),
                        fontWeight: FontWeight.bold,
                      )),
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF8E1),
              Color(0xFFF5F5DC),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFDBA871), Color(0xFFF5D9A0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      FontAwesomeIcons.dog,
                      size: 40,
                      color: Colors.white,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'คู่มือการดูแลสุนัขอย่างถูกต้อง',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'เรียนรู้การดูแลสุนัขของคุณให้มีสุขภาพดี',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Vaccination Schedule Table
              _buildVaccinationTable(),

              SizedBox(height: 20),

              // Guide Categories
              _buildGuideSection(
                icon: FontAwesomeIcons.utensils,
                title: 'การให้อาหาร',
                subtitle: 'แนวทางการให้อาหารที่ถูกต้อง',
                content:
                    'ให้อาหารสุนัขคุณภาพดี วันละ 2-3 มื้อ ปริมาณตามน้ำหนักและอายุ หลีกเลี่ยงอาหารที่เป็นอันตราย เช่น ช็อกโกแลต หัวหอม องุ่น',
                readMoreUrl: 'https://www.pedigree.co.th/caring',
              ),

              _buildGuideSection(
                icon: FontAwesomeIcons.shower,
                title: 'การอาบน้ำและทำความสะอาด',
                subtitle: 'รักษาความสะอาดให้สุนัข',
                content:
                    'อาบน้ำสัปดาห์ละ 1-2 ครั้ง ใช้แชมพูสำหรับสุนัข แปรงขนทุกวัน ตัดเล็บ ทำความสะอาดหู และแปรงฟันเป็นประจำ',
                readMoreUrl:
                    'https://www.purina.co.th/articles/dogs/puppy/welcoming/take-care-new-puppies',
              ),

              _buildGuideSection(
                icon: FontAwesomeIcons.dumbbell,
                title: 'การออกกำลังกาย',
                subtitle: 'กิจกรรมสำหรับสุขภาพที่ดี',
                content:
                    'พาเดินเล่นวันละ 30-60 นาที เล่นเกมกับสุนัข ให้วิ่งเล่นในพื้นที่ปลอดภัย การออกกำลังกายช่วยลดความเครียดและเสริมสร้างความแข็งแรง',
                readMoreUrl:
                    'https://th.iams.asia/dog/dog-articles/puppy-care-guide',
              ),

              _buildGuideSection(
                icon: FontAwesomeIcons.stethoscope,
                title: 'การดูแลสุขภาพ',
                subtitle: 'การป้องกันโรคและตรวจสุขภาพ',
                content:
                    'ฉีดวัคซีนป้องกันโรคตามกำหนด ถ่ายพยาธิทุก 3-6 เดือน ตรวจสุขภาพประจำปี สังเกตอาการผิดปกติ หากมีปัญหาควรพบสัตวแพทย์',
                readMoreUrl:
                    'https://smileinsure.co.th/blogs/วิธีดูแลสุนัขที่ถูกต้องสัตว์เลี้ยง',
              ),

              _buildGuideSection(
                icon: FontAwesomeIcons.brain,
                title: 'การฝึกพฤติกรรม',
                subtitle: 'สอนมารยาทและพฤติกรรมที่ดี',
                content:
                    'ฝึกคำสั่งพื้นฐาน เช่น นั่ง เดิน หยุด ใช้การเสริมแรงเชิงบวก ใจเย็นและสม่ำเสมอ ฝึกการเข้าสังคมกับคนและสุนัขตัวอื่น',
                readMoreUrl:
                    'https://www.apthai.com/th/blog/living-series/lifeandliving-how-to-train-your-dogs',
              ),

              _buildGuideSection(
                icon: FontAwesomeIcons.home,
                title: 'การจัดสภาพแวดล้อม',
                subtitle: 'สร้างพื้นที่ที่ปลอดภัยและสะดวกสบาย',
                content:
                    'จัดพื้นที่นอนที่อบอุ่น มีของเล่นที่ปลอดภัย ปิดบังสิ่งอันตราย มีน้ำสะอาดให้ดื่มตลอดเวลา และพื้นที่สำหรับขับถ่าย',
                readMoreUrl:
                    'https://www.heropomeranian.com/article/20/วิธีการเลี้ยงสุนัขอย่างถูกต้อง',
              ),

              SizedBox(height: 20),

              // Emergency Tips Card
              // Container(
              //   width: double.infinity,
              //   padding: EdgeInsets.all(20),
              //   decoration: BoxDecoration(
              //     color: Colors.red.shade50,
              //     borderRadius: BorderRadius.circular(15),
              //     border: Border.all(color: Colors.red.shade200),
              //   ),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Row(
              //         children: [
              //           Icon(
              //             FontAwesomeIcons.triangleExclamation,
              //             color: Colors.red.shade600,
              //             size: 20,
              //           ),
              //           SizedBox(width: 10),
              //           Text(
              //             'เหตุฉุกเฉิน',
              //             style: TextStyle(
              //               fontSize: 18,
              //               fontWeight: FontWeight.bold,
              //               color: Colors.red.shade700,
              //             ),
              //           ),
              //         ],
              //       ),
              //       SizedBox(height: 10),
              //       Text(
              //         'หากสุนัขมีอาการป่วยฉับพลัน เช่น อาเจียนติดต่อกัน ท้องเสีย เบื่ออาหาร ชัก หรือหายใจลำบาก ให้รีบพาไปพบสัตวแพทย์ทันที',
              //         style: TextStyle(
              //           fontSize: 14,
              //           color: Colors.red.shade700,
              //           height: 1.4,
              //         ),
              //       ),
              //       SizedBox(height: 15),
              //       SizedBox(
              //         width: double.infinity,
              //         child: Container(
              //           padding: EdgeInsets.symmetric(vertical: 12),
              //           decoration: BoxDecoration(
              //             color: Colors.red.shade600,
              //             borderRadius: BorderRadius.circular(10),
              //           ),
              //           child: Row(
              //             mainAxisAlignment: MainAxisAlignment.center,
              //             children: [
              //               Icon(FontAwesomeIcons.phone,
              //                   size: 16, color: Colors.white),
              //               SizedBox(width: 8),
              //               Text(
              //                 'เบอร์ฉุกเฉิน 1669',
              //                 style: TextStyle(color: Colors.white),
              //               ),
              //             ],
              //           ),
              //         ),
              //       )
              //     ],
              //   ),
              // ),

              SizedBox(height: 30),

              // Footer
              Center(
                child: Text(
                  'ดูแลสุนัขของคุณด้วยความรักและความรับผิดชอบ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF916B44),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVaccinationTable() {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF916B44).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    FontAwesomeIcons.syringe,
                    color: Color(0xFF916B44),
                    size: 20,
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ตารางการฉีดวัคซีนสุนัข',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF916B44),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'กำหนดการฉีดวัคซีนป้องกันโรคตามอายุ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Table(
                border: TableBorder.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
                children: [
                  // Header row
                  TableRow(
                    decoration: BoxDecoration(
                      color: Color(0xFF916B44).withOpacity(0.1),
                    ),
                    children: [
                      _buildTableCell('อายุ', isHeader: true),
                      _buildTableCell('วัคซีน', isHeader: true),
                      _buildTableCell('โรคที่ป้องกัน', isHeader: true),
                    ],
                  ),
                  // Data rows
                  TableRow(
                    children: [
                      _buildTableCell('6-8 สัปดาห์'),
                      _buildTableCell('DHPP'),
                      _buildTableCell('โรคพิษสุนัข, ไฟ, ปอด, พาร์โว'),
                    ],
                  ),
                  TableRow(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                    ),
                    children: [
                      _buildTableCell('10-12 สัปดาห์'),
                      _buildTableCell('DHPP + โรคพิษสุนัขบ้า'),
                      _buildTableCell('เสริมภูมิคุ้มกัน + โรคพิษสุนัขบ้า'),
                    ],
                  ),
                  TableRow(
                    children: [
                      _buildTableCell('14-16 สัปดาห์'),
                      _buildTableCell('DHPP + โรคพิษสุนัขบ้า'),
                      _buildTableCell('เสริมภูมิคุ้มกันครั้งสุดท้าย'),
                    ],
                  ),
                  TableRow(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                    ),
                    children: [
                      _buildTableCell('1 ปี'),
                      _buildTableCell('DHPP + โรคพิษสุนัขบ้า'),
                      _buildTableCell('บูสเตอร์ประจำปี'),
                    ],
                  ),
                  TableRow(
                    children: [
                      _buildTableCell('ทุก 1-3 ปี'),
                      _buildTableCell('ตามคำแนะนำสัตวแพทย์'),
                      _buildTableCell('รักษาภูมิคุ้มกัน'),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    FontAwesomeIcons.lightbulb,
                    color: Colors.blue.shade600,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'หมายเหตุ: DHPP = Distemper, Hepatitis, Parvovirus, Parainfluenza ควรปรึกษาสัตวแพทย์สำหรับกำหนดการที่เหมาะสม',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isHeader ? 14 : 12,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? Color(0xFF916B44) : Colors.grey.shade700,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildGuideSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required String content,
    required String readMoreUrl,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF916B44).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Color(0xFF916B44),
                    size: 20,
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF916B44),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _launchURL(readMoreUrl),
                icon: Icon(
                  FontAwesomeIcons.externalLinkAlt,
                  size: 14,
                ),
                label: Text('อ่านเพิ่มเติม'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Color(0xFF916B44),
                  side: BorderSide(color: Color(0xFF916B44)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
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
