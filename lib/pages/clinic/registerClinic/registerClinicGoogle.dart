import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/controller/registerClinicCtl.dart';
import 'package:http/http.dart' as http;
import 'package:puppal_application/pages/clinic/mainClinic/clinicOpeningHours.dart';
import 'package:puppal_application/pages/clinic/registerClinic/registerClinicLocationSelect.dart';

class RegisterclinicgooglePage extends StatefulWidget {
  const RegisterclinicgooglePage({super.key});

  @override
  State<RegisterclinicgooglePage> createState() =>
      _RegisterclinicgooglePageState();
}

class _RegisterclinicgooglePageState extends State<RegisterclinicgooglePage> {
  late double screenWidth;
  late double screenHeight;

  String url = "";

  final List<String> _timeSelect = List.generate(48, (index) {
    final hour = (index ~/ 2).toString().padLeft(2, '0');
    final minute = (index % 2 == 0) ? '00' : '30';
    return '$hour:$minute';
  });

  final List<String> _numPerTime = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10'
  ];

  final controller = Get.find<registerClinicCtl>();
  final box = GetStorage();
  List<String> selectedWeekdays = [];
  TimeOfDay? openTime;
  TimeOfDay? closeTime;

  TextEditingController nameCtl = TextEditingController();
  TextEditingController emailCtl = TextEditingController();
  TextEditingController phoneCtl = TextEditingController();
  TextEditingController openCtl = TextEditingController();
  TextEditingController closeCtl = TextEditingController();
  TextEditingController numPerTimeCtl = TextEditingController();
  TextEditingController addressCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
    });
    emailCtl.text = box.read('emailGoogleRegister');
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'สมัครคลินิก',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF916B44),
      ),
      body: SingleChildScrollView(
          child: Container(
        // height: screenHeight * 0.9,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/indexBg.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.2), BlendMode.dstATop)),
        ),
        child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              spacing: 16,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ชื่อคลินิก',
                      style: TextStyle(fontSize: 20),
                    ),
                    Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        height: screenHeight * 0.055,
                        child: TextField(
                          controller: nameCtl,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'อีเมล',
                      style: TextStyle(fontSize: 20),
                    ),
                    Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        height: screenHeight * 0.055,
                        child: TextField(
                          readOnly: true,
                          controller: emailCtl,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'เบอร์โทรศัพท์',
                      style: TextStyle(fontSize: 20),
                    ),
                    Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        height: screenHeight * 0.055,
                        child: TextField(
                          controller: phoneCtl,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "เลือกวันเปิดทำการ",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(7, (index) {
                        final days = [
                          'Monday',
                          'Tuesday',
                          'Wednesday',
                          'Thursday',
                          'Friday',
                          'Saturday',
                          'Sunday'
                        ];
                        final daysShort = ['จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'];
                        final day = days[index];
                        final isSelected = selectedWeekdays.contains(day);

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                selectedWeekdays.remove(day);
                              } else {
                                selectedWeekdays.add(day);
                              }
                            });
                          },
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.brown : Colors.white,
                              border: Border.all(
                                  color:
                                      isSelected ? Colors.brown : Colors.grey),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                daysShort[index],
                                style: TextStyle(
                                  color:
                                      isSelected ? Colors.white : Colors.brown,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'เวลาเปิดคลินิก',
                      style: TextStyle(fontSize: 20),
                    ),
                    Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        height: screenHeight * 0.055,
                        child: TextField(
                          controller: openCtl,
                          readOnly: true,
                          decoration: InputDecoration(
                            suffixIcon: Icon(Icons.arrow_drop_down),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            hintText: "เลือกเวลาเปิดคลินิก",
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          onTap: () => _showCustomTimePicker(isOpen: true),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'เวลาปิดคลินิก',
                      style: TextStyle(fontSize: 20),
                    ),
                    Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        height: screenHeight * 0.055,
                        child: TextField(
                          controller: closeCtl,
                          readOnly: true,
                          decoration: InputDecoration(
                            suffixIcon: Icon(Icons.arrow_drop_down),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            hintText: "เลือกเวลาปิดคลินิก",
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          onTap: () => _showCustomTimePicker(isOpen: false),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'จำนวนคำขอต่อช่วงเวลา',
                      style: TextStyle(fontSize: 20),
                    ),
                    Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        height: screenHeight * 0.055,
                        child: TextField(
                          readOnly: true,
                          controller: numPerTimeCtl,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            hintText: "เลือกจำนวนคำขอต่อช่วงเวลา",
                            hintStyle: TextStyle(color: Colors.grey),
                            suffixIcon: Icon(Icons.arrow_drop_down),
                          ),
                          onTap: _showSelectNum,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ที่อยู่คลินิก',
                      style: TextStyle(fontSize: 20),
                    ),
                    Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        height: screenHeight * 0.055,
                        child: TextField(
                          controller: addressCtl,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, screenHeight * 0.05),
                  child: SizedBox(
                    width: screenWidth * 0.5,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Color(0xFF916b44)),
                        onPressed: userRegisterNextButton,
                        child: Text(
                          'ถัดไป',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        )),
                  ),
                )
              ],
            )),
      )),
    );
  }

  void _showCustomTimePicker({required bool isOpen}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return TimePickerBottomSheet(
          isOpenTime: isOpen,
          initialTime: isOpen ? openTime : closeTime,
          onTimeSelected: (selected) {
            setState(() {
              if (isOpen) {
                openTime = selected;
                openCtl.text = selected.format(context);
              } else {
                closeTime = selected;
                closeCtl.text = selected.format(context);
              }
            });
          },
        );
      },
    );
  }

  Future<void> userRegisterNextButton() async {
    if (nameCtl.text.trim().isEmpty ||
        emailCtl.text.trim().isEmpty ||
        phoneCtl.text.trim().isEmpty ||
        addressCtl.text.trim().isEmpty ||
        // openCtl.text.trim().isEmpty ||
        // closeCtl.text.trim().isEmpty ||
        numPerTimeCtl.text.trim().isEmpty) {
      Get.snackbar(
        'ข้อผิดพลาด',
        'กรุณากรอกข้อมูลให้ครบถ้วน',
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

    // Phone number format check (simple 10-digit validation).
    RegExp phoneRegExp = RegExp(r'^[0-9]{10}$');
    if (!phoneRegExp.hasMatch(phoneCtl.text.trim())) {
      Get.snackbar(
        'ข้อผิดพลาด',
        'กรุณากรอกหมายเลขโทรศัพท์ที่ถูกต้อง',
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

    // Email format check
    RegExp emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(emailCtl.text.trim())) {
      Get.snackbar(
        'ข้อผิดพลาด',
        'กรุณากรอกอีเมลที่ถูกต้อง',
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

    controller.name.value = nameCtl.text;
    controller.email.value = emailCtl.text;
    controller.password.value = '';
    controller.phone.value = phoneCtl.text;
    controller.open.value = openCtl.text;
    controller.close.value = closeCtl.text;
    controller.weekdays.value = selectedWeekdays.join(',');
    controller.numPerTime.value = int.parse(numPerTimeCtl.text);
    controller.address.value = addressCtl.text;

    var res = await http.get(Uri.parse("$url/user/${emailCtl.text}"));

    if (res.statusCode == 200) {
      Get.snackbar(
        'ข้อผิดพลาด',
        'อีเมลนี้เคยสมัครสมาชิกไปแล้ว\nกรุณาเข้าสู่ระบบหากเป็นผู้ใช้ทั่วไปแล้วต้องการเปลี่ยนไปยังคลินิก',
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
    } else {
      Get.to(() => CliniclocationselectPage());
    }
  }

  void _showOpenSelectTime() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: 350,
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Text(
                  'เลือกเวลาเปิดคลินิก',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF916b44), // สีเดียวกับปุ่ม
                  ),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _timeSelect.length,
                  itemBuilder: (context, index) {
                    final time = _timeSelect[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Center(
                          child: Text(
                            time,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF916b44), // สีตัวหนังสือ
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            openCtl.text = time;
                          });
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCloseSelectTime() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final List<String> availableTimes = _timeSelect.where((time) {
          if (openCtl.text.isEmpty) return true;

          final openParts = openCtl.text.split(':').map(int.parse).toList();
          final closeParts = time.split(':').map(int.parse).toList();

          final openMinutes = openParts[0] * 60 + openParts[1];
          final closeMinutes = closeParts[0] * 60 + closeParts[1];

          return closeMinutes > openMinutes;
        }).toList();

        return Container(
          height: 350,
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Text(
                  'เลือกเวลาปิดคลินิก',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF916b44), // ใช้สีทองน้ำตาล
                  ),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: availableTimes.length,
                  itemBuilder: (context, index) {
                    final time = availableTimes[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Center(
                          child: Text(
                            time,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF916b44),
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            closeCtl.text = time;
                          });
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSelectNum() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: 350,
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Text(
                  'เลือกจำนวนคำขอที่รับได้ต่อช่วงเวลา',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF916b44), // ใช้สีทองน้ำตาล
                  ),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _numPerTime.length,
                  itemBuilder: (context, index) {
                    final time = _numPerTime[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Center(
                          child: Text(
                            time,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF916b44), // ใช้สีทองน้ำตาล
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            numPerTimeCtl.text = time;
                          });
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Time Picker Bottom Sheet using time_picker_spinner package
class TimePickerBottomSheet extends StatefulWidget {
  final TimeOfDay? initialTime;
  final bool isOpenTime;
  final Function(TimeOfDay) onTimeSelected;

  const TimePickerBottomSheet({
    Key? key,
    required this.initialTime,
    required this.isOpenTime,
    required this.onTimeSelected,
  }) : super(key: key);

  @override
  State<TimePickerBottomSheet> createState() => _TimePickerBottomSheetState();
}

class _TimePickerBottomSheetState extends State<TimePickerBottomSheet> {
  late DateTime selectedTime;

  static const Color primaryColor = Color(0xFF916B44);
  static const Color secondaryColor = Color(0xFFDBA871);
  static const Color tertiaryColor = Color(0xFFE9CBAF);

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final time = widget.initialTime ?? TimeOfDay.now();
    selectedTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.isOpenTime ? "เลือกเวลาเปิด" : "เลือกเวลาปิด",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Icon(
                  widget.isOpenTime ? Icons.wb_sunny : Icons.nightlight_round,
                  color: Colors.white,
                ),
              ],
            ),
          ),

          // Time Display
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: tertiaryColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: secondaryColor.withOpacity(0.3),
              ),
            ),
            child: Text(
              "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}",
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Time Picker Spinner
          Expanded(
            child: TimePickerSpinner(
              time: selectedTime,
              is24HourMode: true,
              normalTextStyle: TextStyle(
                fontSize: 18,
                color: primaryColor.withOpacity(0.6),
              ),
              highlightedTextStyle: TextStyle(
                fontSize: 22,
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
              spacing: 40,
              itemHeight: 60,
              isForce2Digits: true,
              minutesInterval: 5,
              onTimeChange: (time) {
                setState(() {
                  selectedTime = time;
                });
              },
            ),
          ),

          // Buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "ยกเลิก",
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onTimeSelected(
                        TimeOfDay.fromDateTime(selectedTime),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "ตกลง",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
