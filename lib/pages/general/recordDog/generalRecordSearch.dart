import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/model/dogsGetEmail.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalDog.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalGuide.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalMain.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalNotification.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalProfile.dart';
import 'package:puppal_application/pages/general/recordDog/generalRecord.dart';
import 'package:puppal_application/pages/login/index.dart';
import 'package:http/http.dart' as http;

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
          child: SingleChildScrollView(
            child: SizedBox(
              width: screenWidth,
              child: Column(
                children: [
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
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
                      padding:
                          EdgeInsets.symmetric(vertical: screenHeight * 0.2),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio:
                          (screenWidth * 0.9 / 3) / (screenHeight * 0.275),
                      shrinkWrap: true,
                      physics:
                          NeverScrollableScrollPhysics(), // Let parent scroll handle it
                      padding: EdgeInsets.all(12),
                      children: filterDogs.map((dog) {
                        return Card(
                          color: Color(0xFFF1F1F1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    dog.image,
                                    width: double.infinity,
                                    height: screenHeight * 0.12,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  dog.name,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFFDBA871)),
                                    onPressed: () {
                                      Get.to(() => GeneralrecordPage(
                                            index: dog.dogId,
                                          ));
                                    },
                                    child: Text(
                                      'ดูประวัติ',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.white),
                                    ))
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    )
                ],
              ),
            ),
          )),
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
