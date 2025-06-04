import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:puppal_application/controller/registerDogInjectionHistoryCtl.dart';
import 'package:puppal_application/pages/general/registerGeneral/dog/registerDogAvatar.dart';
import 'package:puppal_application/pages/general/registerGeneral/dog/registerDogInjection.dart';

class RegisterdoginjectionrecordPage extends StatefulWidget {
  const RegisterdoginjectionrecordPage({super.key});

  @override
  State<RegisterdoginjectionrecordPage> createState() =>
      _RegisterdoginjectionrecordPageState();
}

class _RegisterdoginjectionrecordPageState
    extends State<RegisterdoginjectionrecordPage> {
  late double screenWidth;
  late double screenHeight;

  final recordListController = Get.find<injectionRecordList>();

  Map<String, String> vaccineNameMap = {
    '1': 'วัคซีนรวม 5 โรค (DHPPiL)',
    '2': 'วัคซีนพิษสุนัขบ้า',
    '3': 'วัคซีนป้องกันโรคไข้ฉี่หนู',
    '4': 'วัคซีนป้องกันเชื้อ Bordetella bronchiseptica',
    '5': 'วัคซีนป้องกันโรคลายม์',
    '6': 'วัคซีนป้องกันเชื้อโคโรนาไวรัส',
    '7': 'วัคซีนถ่ายพยาธิ',
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('ประวัติการฉีดยา'),
        actions: [
          IconButton(
              onPressed: () {
                Get.to(() => RegisterdoginjectionPage());
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                return Wrap(
                  spacing: 10.0, // Space between items horizontally
                  runSpacing: 10.0, // Space between rows
                  children: [
                    ...recordListController.recordList.map((record) {
                      return SizedBox(
                        width: screenWidth * 0.9,
                        height: screenHeight * 0.12,
                        child: Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(
                              vaccineNameMap[record.vaccineType] ??
                                  'ไม่พบข้อมูลวัคซีน',
                              style: TextStyle(overflow: TextOverflow.ellipsis),
                            ),
                            subtitle: Column(
                              children: [
                                Row(
                                  children: [
                                    Text('ชื่อคลินิก:\t\t\t'),
                                    Text(
                                      record.clinicName != ''
                                          ? record.clinicName
                                          : 'ไม่พบข้อมูล',
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text('วันที่ฉีด:\t\t\t'),
                                    Text(
                                      record.date != ''
                                          ? record.date
                                          : 'ไม่พบข้อมูล',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                showAlert(
                                    context: context,
                                    title:
                                        "คุณต้องการลบประวัติฉีดยารายการนี้ใช่หรือไม่",
                                    message: "ประวัติการฉีดยานี้จะถูกลบ",
                                    onConfirm: () {
                                      setState(() {
                                        recordListController
                                            .removeRecord(record);
                                      });
                                    });
                              },
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(screenHeight * 0.075),
        child: ElevatedButton(
          onPressed: () {
            if (recordListController.recordList.isEmpty) {
              showAlert(
                  context: context,
                  title: 'ไม่มีประวัติการฉีดยา?',
                  message: 'สุนัขของคุณไม่มีประวัติการฉีดยา?',
                  onConfirm: () {
                    Get.to(() => RegisterdogavatarPage());
                  });
              return;
            }

            showAlert(
                context: context,
                title: 'เพิ่มประวัติการฉีดยาครบแล้ว?',
                message: 'หากมีประวัติการฉีดยาโปรดเพิ่ม',
                onConfirm: () {
                  Get.to(() => RegisterdogavatarPage());
                });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF916b44),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size.fromHeight(50),
          ),
          child: const Text(
            'สมัครสมาชิก',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
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
