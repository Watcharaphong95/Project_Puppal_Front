import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/model/ClinicGetSchedule.dart';
import 'package:puppal_application/model/ClinicSchedulePost.dart';

class Clinicopeninghours extends StatefulWidget {
  const Clinicopeninghours({super.key});

  @override
  State<Clinicopeninghours> createState() => _ClinicOpeningHoursState();
}

class _ClinicOpeningHoursState extends State<Clinicopeninghours> {
  final List<String> weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  List<String> selectedWeekdays = [];

  TimeOfDay? openTime;
  TimeOfDay? closeTime;

  final List<DateTime> specialHolidays = [];
  String url = '';
  final box = GetStorage();
  List<ClinicGetSchedule> scheduleList = [];

  void _pickTime({required bool isOpenTime}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isOpenTime
          ? (openTime ?? TimeOfDay.now())
          : (closeTime ?? TimeOfDay.now()),
    );
    if (picked != null) {
      setState(() {
        if (isOpenTime) {
          openTime = picked;
        } else {
          closeTime = picked;
        }
      });
    }
  }

  void _pickHolidayDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && !specialHolidays.contains(picked)) {
      setState(() => specialHolidays.add(picked));
    }
  }

  // void _submit() {
  //   final data = {
  //     "weekdays": selectedWeekdays.toList(),
  //     "open_time": openTime?.format(context),
  //     "close_time": closeTime?.format(context),
  //     "special_holidays":
  //         specialHolidays.map((d) => d.toIso8601String()).toList(),
  //   };

  //   // TODO: ส่งข้อมูลไป backend/MySQL
  //   debugPrint("📤 ส่งข้อมูล: $data");
  // }

  @override
  void initState() {
    super.initState();
    initialize(); // Call async method without await
  }

  Future<void> initialize() async {
    final config = await Configuration.getConfig();
    url = config['apiEndPoint'];
    // await getReserve();
    await getClinicSchedule();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("กำหนดเวลาเปิด-ปิดคลินิก")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("เลือกวันเปิดทำการ",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 10,
              children: weekdays.map((day) {
                final selected = selectedWeekdays.contains(day);
                return FilterChip(
                  label: Text(day),
                  selected: selected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        selectedWeekdays.add(day);
                      } else {
                        selectedWeekdays.remove(day);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text("เวลาเปิด"),
                    subtitle: Text(openTime?.format(context) ?? "-"),
                    onTap: () => _pickTime(isOpenTime: true),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text("เวลาปิด"),
                    subtitle: Text(closeTime?.format(context) ?? "-"),
                    onTap: () => _pickTime(isOpenTime: false),
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("วันหยุดพิเศษ",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: _pickHolidayDate,
                  icon: const Icon(Icons.date_range),
                  label: const Text("เพิ่มวันหยุด"),
                ),
              ],
            ),
            if (specialHolidays.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("ยังไม่มีวันหยุดพิเศษ",
                    style: TextStyle(color: Colors.grey)),
              )
            else
              Column(
                children: specialHolidays.map((d) {
                  return ListTile(
                    title: Text("${d.day}/${d.month}/${d.year}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          setState(() => specialHolidays.remove(d)),
                    ),
                  );
                }).toList(),
              ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => updateSchedule(scheduleList[0].sid),
              child: const Text("บันทึก"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getClinicSchedule() async {
    final clinicEmail = box.read('email');
    log(clinicEmail);
    final res = await http.get(Uri.parse("$url/schedule/$clinicEmail"));

    if (res.statusCode == 200) {
      scheduleList = clinicGetScheduleFromJson(res.body);

      if (scheduleList.isNotEmpty) {
        final schedule = scheduleList.first;

        // ✅ กำหนดค่าให้กับ state UI
        setState(() {
          selectedWeekdays.clear();
          selectedWeekdays.addAll(schedule.weekdays.split(','));

          final openParts = schedule.openTime.split(":");
          final closeParts = schedule.closeTime.split(":");

          openTime = TimeOfDay(
            hour: int.parse(openParts[0]),
            minute: int.parse(openParts[1]),
          );

          closeTime = TimeOfDay(
            hour: int.parse(closeParts[0]),
            minute: int.parse(closeParts[1]),
          );
        });
      }
    } else {
      log("❌ ไม่สามารถดึงข้อมูลตารางเวลาได้: ${res.statusCode}");
    }
  }

  Future<void> updateSchedule(int id) async {
    final clinicEmail = box.read('email');
    ClinicSchedulePost req = ClinicSchedulePost(
        clinicEmail: clinicEmail,
        weekdays: selectedWeekdays.join(','),
        openTime:
            "${openTime!.hour.toString().padLeft(2, '0')}:${openTime!.minute.toString().padLeft(2, '0')}",
        closeTime:
            "${closeTime!.hour.toString().padLeft(2, '0')}:${closeTime!.minute.toString().padLeft(2, '0')}");
    final res = await http.put(
      Uri.parse("$url/schedule/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(req),
    );

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("บันทึกสำเร็จ")),
      );
    } else {
      log("❌ บันทึกข้อมูลไม่สำเร็จ: ${res.statusCode}");
    }
  }

  // Future<void> _submit() async {
  //   final clinicEmail = box.read('email');

  //   final body = {
  //     "clinic_email": clinicEmail,
  //     "weekdays": selectedWeekdays.join(','),
  //     "open_time":
  //         "${openTime!.hour.toString().padLeft(2, '0')}:${openTime!.minute.toString().padLeft(2, '0')}",
  //     "close_time":
  //         "${closeTime!.hour.toString().padLeft(2, '0')}:${closeTime!.minute.toString().padLeft(2, '0')}",
  //     "special_holidays": specialHolidays
  //         .map((d) => DateFormat("yyyy-MM-dd").format(d))
  //         .toList(),
  //   };

  //   final res = await http.put(
  //     Uri.parse("$url/schedule/update"),
  //     headers: {"Content-Type": "application/json"},
  //     body: jsonEncode(body),
  //   );

  //   if (res.statusCode == 200) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("บันทึกสำเร็จ")),
  //     );
  //   } else {
  //     log("❌ บันทึกข้อมูลไม่สำเร็จ: ${res.statusCode}");
  //   }
  // }
}
