import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/main.dart';
import 'package:puppal_application/model/dogdetalisPost.dart';
import 'package:puppal_application/model/reserveclinicfirebase.dart';
import 'package:http/http.dart' as http;

class Notificationpage extends StatefulWidget {
  const Notificationpage({super.key});

  @override
  State<Notificationpage> createState() => _NotificationpageState();
}

class _NotificationpageState extends State<Notificationpage> {
  late double screenWidth;
  late double screenHeight;
  final box = GetStorage();
  String url = '';
  bool isLoading = true;
  List<ReserveClinicFirebase> reservebookingListAll = [];
  List<ReserveClinicFirebase> reserveList = [];
  StreamSubscription<QuerySnapshot>? _reserveListener;
  bool _isMounted = true;
  List<NotificationItem> notifications = [];
  Set<int> readNotificationIds = {};
  List<NotificationItem> get unreadNotifications =>
      notifications.where((n) => !readNotificationIds.contains(n.id)).toList();
  String currentFilter = 'ทั้งหมด';
  int get unreadCount => notifications.where((n) => !n.isRead).length;
  List<NotificationItem> get filteredNotifications {
    if (currentFilter == 'ยังไม่อ่าน') {
      return notifications.where((n) => !n.isRead).toList();
    } else if (currentFilter == 'การจองใหม่') {
      return notifications
          .where((n) =>
              n.type == NotificationType.newBooking ||
              n.type == NotificationType.changeBooking ||
              n.type == NotificationType.cancelBooking)
          .toList();
    }
    return notifications;
  }

  @override
  void initState() {
    super.initState();
    initialize(); // Call async method without await
  }

  void main() async {
    await GetStorage.init();
    runApp(MyApp());
  }

  Future<void> initialize() async {
    final config = await Configuration.getConfig();
    url = config['apiEndPoint'];

    startRealtimeGet();
    box.write('type', 'clinic');
    _isMounted = true;
    final storedIds = box.read<List>('readNotificationIds') ?? [];
    readNotificationIds = storedIds
        .map((e) => int.tryParse(e.toString()) ?? -1)
        .where((id) => id != -1)
        .toSet();
  }

  @override
  void dispose() {
    _isMounted = false;
    stopRealTime();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Center(
            child: Padding(
          padding: const EdgeInsets.only(right: 35),
          child: const Text(
            'การแจ้งเตือน',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        )),
        // backgroundColor: const Color(0xFF916B44),
        // actions: [
        //   if (unreadCount > 0)
        //     TextButton(
        //       onPressed: () {
        //         setState(() {
        //           for (var notification in notifications) {
        //             notification.isRead = true;
        //           }
        //         });
        //       },
        //       child: const Text(
        //         'อ่านทั้งหมด',
        //         style: TextStyle(
        //           color: Colors.white,
        //           fontWeight: FontWeight.w600,
        //         ),
        //       ),
        //     ),
        // ],
      ),
      body: Column(
        children: [
          // 🔔 Summary Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF916B44), Color(0xFFDBA871)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF916B44).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.notifications_active,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'การแจ้งเตือนล่าสุด',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ยังไม่ได้อ่าน $unreadCount รายการ',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 📌 Filter Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterTab('ทั้งหมด', currentFilter == 'ทั้งหมด'),
                const SizedBox(width: 8),
                _buildFilterTab('ยังไม่อ่าน', currentFilter == 'ยังไม่อ่าน'),
                const SizedBox(width: 8),
                _buildFilterTab('การจอง', currentFilter == 'การจอง'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 📝 Notification List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredNotifications.isEmpty
                    ? const Center(child: Text('ไม่มีการแจ้งเตือน'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredNotifications.length,
                        itemBuilder: (context, index) {
                          final notification = filteredNotifications[index];
                          return _buildNotificationCard(notification);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String title, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() {
          currentFilter = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF916B44) : const Color(0xFFE9CBAF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF916B44),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case NotificationType.newBooking:
        iconData = Icons.calendar_today;
        iconColor = const Color(0xFF4CAF50);
        break;
      case NotificationType.cancelBooking:
        iconData = Icons.cancel;
        iconColor = const Color(0xFFF44336);
        break;
      case NotificationType.changeBooking:
        iconData = Icons.edit_calendar;
        iconColor = const Color(0xFFFF9800);
        break;
      case NotificationType.reminder:
        iconData = Icons.alarm;
        iconColor = const Color(0xFF2196F3);
        break;
      case NotificationType.question:
        iconData = Icons.help_outline;
        iconColor = const Color(0xFF9C27B0);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead
              ? Colors.transparent
              : const Color(0xFFDBA871),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              notification.isRead = true;
              readNotificationIds.add(notification.id);
              box.write('readNotificationIds', readNotificationIds.toList());
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    iconData,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead
                                  ? FontWeight.w600
                                  : FontWeight.bold,
                              fontSize: 16,
                              color: const Color(0xFF916B44),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFDBA871),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            notification.time,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          if (notification.type ==
                                  NotificationType.newBooking ||
                              notification.type ==
                                  NotificationType.changeBooking)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE9CBAF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'ดูรายละเอียด',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF916B44),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  NotificationItem mapFirebaseToNotification(
      Map<String, dynamic> data, int id) {
    final message = data['message'] ?? '';
    final createAt = data['createAt'];
    DateTime createTime = DateTime.now();

    if (createAt != null && createAt is Timestamp) {
      createTime = createAt.toDate();
    }

    // ประเภท
    NotificationType type = NotificationType.question;
    if (message.contains('คลินิกตอบรับ')) {
      type = NotificationType.newBooking;
    } else if (message.contains('ปฏิเสธคำขอฉีดวัคซีนของคุณ')) {
      type = NotificationType.cancelBooking;
    } else if (message.contains('มีคำขอฉีดยาใหม่')) {
      type = NotificationType.changeBooking;
    } else if (message.contains('เตือน') || message.contains('วันนี้')) {
      type = NotificationType.reminder;
    }

    final now = DateTime.now();
    final difference = now.difference(createTime);
    String timeAgo;
    if (difference.inMinutes < 60) {
      timeAgo = '${difference.inMinutes} นาทีที่แล้ว';
    } else if (difference.inHours < 24) {
      timeAgo = '${difference.inHours} ชั่วโมงที่แล้ว';
    } else {
      timeAgo = '${difference.inDays} วันที่แล้ว';
    }

    // ✅ เช็คว่าเคยอ่านไหม
    final isRead = readNotificationIds.contains(id);

    return NotificationItem(
      id: id,
      title: _getTitleFromType(type),
      message: message,
      time: timeAgo,
      type: type,
      isRead: isRead,
    );
  }

  String _getTitleFromType(NotificationType type) {
    switch (type) {
      case NotificationType.newBooking:
        return 'ตอบรับการจอง';
      case NotificationType.cancelBooking:
        return 'ยกเลิกการจอง';
      case NotificationType.changeBooking:
        return 'คำขอจองใหม่';
      case NotificationType.reminder:
        return 'เตือนความจำ';
      case NotificationType.question:
      default:
        return 'คำถามจากลูกค้า';
    }
  }

  void loadNotificationsFromFirebase(List<Map<String, dynamic>> dataList) {
    notifications.clear(); // เคลียร์ของเก่า
    for (int i = 0; i < dataList.length; i++) {
      final notification = mapFirebaseToNotification(dataList[i], i + 1);
      notifications.add(notification);
    }

    setState(() {}); // รีเฟรช UI
  }

  // void startRealtimeGet() {
  //   stopRealTime(); // หยุด listener เดิมก่อน

  //   _reserveListener = FirebaseFirestore.instance
  //       .collection('notify')
  //       .where('receiverEmail', isEqualTo: box.read("email"))
  //       .snapshots()
  //       .listen((snapshot) async {
  //     try {
  //       if (_isMounted) {
  //         setState(() {
  //           isLoading = true;
  //         });
  //       }

  //       // ✅ ตัวอย่างการประมวลผลข้อมูล
  //       final data = snapshot.docs.map((doc) => doc.data()).toList();
  //       log("📥 ได้รับข้อมูลใหม่จาก Firebase: ${data.length} รายการ");
  //       log("📥 ข้อมูล: $data");

  //       if (_isMounted) {
  //         setState(() {
  //           isLoading = false;
  //         });
  //       }
  //     } catch (e) {
  //       log("❌ Error during snapshot handling: $e");
  //       if (_isMounted) {
  //         setState(() {
  //           isLoading = false;
  //         });
  //       }
  //     }
  //   });
  // }

  void startRealtimeGet() {
    stopRealTime();

    final email = box.read("email");
    if (email == null) return;

    _reserveListener = FirebaseFirestore.instance
        .collection('notify')
        .where('receiverEmail', isEqualTo: email)
        .orderBy('createAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      if (!_isMounted) return;

      final dataList = snapshot.docs.map((doc) => doc.data()).toList();

      List<NotificationItem> tempNotifications = [];
      for (int i = 0; i < dataList.length; i++) {
        final dataMap = Map<String, dynamic>.from(dataList[i]);
        final n = mapFirebaseToNotification(dataMap, i + 1);
        tempNotifications.add(n);
      }

      setState(() {
        notifications = tempNotifications;
        isLoading = false;
      });
    });
  }

  void stopRealTime() {
    _reserveListener?.cancel();
    _reserveListener = null;
  }

  String formatThaiDateTime(DateTime date) {
    final localDate = date.toLocal();

    final thaiMonths = [
      '',
      'มกราคม',
      'กุมภาพันธ์',
      'มีนาคม',
      'เมษายน',
      'พฤษภาคม',
      'มิถุนายน',
      'กรกฎาคม',
      'สิงหาคม',
      'กันยายน',
      'ตุลาคม',
      'พฤศจิกายน',
      'ธันวาคม'
    ];

    final day = localDate.day;
    final month = thaiMonths[localDate.month];
    final year = localDate.year + 543;

    return '$day $month $year';
  }

  Future<Map<String, dynamic>?> getReserveBook(
      String generalEmail, DateTime expectedDate) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('reserve')
          .where('generalEmail', isEqualTo: generalEmail)
          .get();

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final timestamp = data['date'];

          if (timestamp is Timestamp) {
            final docDate = timestamp.toDate();

            // เช็คแค่วันที่ (ไม่สนใจเวลา)
            final isSameDay = docDate.year == expectedDate.year &&
                docDate.month == expectedDate.month &&
                docDate.day == expectedDate.day;

            if (isSameDay) {
              data['docId'] = doc.id;
              log('📦 พบข้อมูลที่ตรงกัน: ${jsonEncode(data)}');
              return data;
            } else {
              log('⚠️ date ไม่ตรงกัน (docDate=${docDate.toIso8601String()}, expected=${expectedDate.toIso8601String()})');
            }
          }
        }
      } else {
        log('❌ ไม่พบเอกสารที่มี generalEmail=$generalEmail');
      }
    } catch (e) {
      log('❌ เกิดข้อผิดพลาดขณะดึงข้อมูล: $e');
    }
    return null;
  }

  Future<DogDetailsPost?> getdog(int dogId) async {
    try {
      // log("🐶 Getting dog info for ID: $dogId");
      var res = await http.get(Uri.parse("$url/dog/data/$dogId"));
      if (res.statusCode == 200) {
        final List<DogDetailsPost> dogList = dogDetailsPostFromJson(res.body);
        if (dogList.isNotEmpty) {
          return dogList.first;
        }
        return null; // กรณีไม่มีข้อมูล
      } else {
        log("❌ Failed to load dog: ${res.statusCode}");
        return null;
      }
    } catch (e) {
      log("❌ Exception while fetching dog info: $e");
      return null;
    }
  }
}

// Model classes
class NotificationItem {
  final int id;
  final String title;
  final String message;
  final String time;
  final NotificationType type;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
  });
}

enum NotificationType {
  newBooking,
  cancelBooking,
  changeBooking,
  reminder,
  question,
}
