import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/main.dart';
import 'package:puppal_application/model/dogdetalisPost.dart';
import 'package:puppal_application/model/notificationModelRes.dart';
import 'package:puppal_application/model/reserveclinicfirebase.dart';
import 'package:http/http.dart' as http;
import 'package:puppal_application/pages/clinic/mainClinic/clinicListDoctors.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicMain.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicOpeningHours.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicSetting.dart';
import 'package:puppal_application/pages/clinic/mainClinic/clinicVaccineHistory/VaccineHistoryPage.dart';
import 'package:puppal_application/pages/general/mainGeneral/generalMain.dart';
import 'package:puppal_application/pages/general/registerGeneral/registerUserGoogle.dart';
import 'package:puppal_application/pages/login/index.dart';
import 'package:shimmer/shimmer.dart';

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
  bool _loadingData = true;

  List<ReserveClinicFirebase> reservebookingListAll = [];
  List<ReserveClinicFirebase> reserveList = [];
  StreamSubscription<QuerySnapshot>? _reserveListener;

  bool _isMounted = true;
  List<NotificationItem> notifications = [];
  Set<int> readNotificationIds = {};
  List<NotifyModel> notifyList = [];

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
    await Future.delayed(Duration(milliseconds: 500));
    // getNotification();
    box.write('type', 'clinic');
    _isMounted = true;
    final storedIds = box.read<List>('readNotificationIds') ?? [];
    readNotificationIds = storedIds
        .map((e) => int.tryParse(e.toString()) ?? -1)
        .where((id) => id != -1)
        .toSet();
    setState(() {
      _loadingData = false;
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    stopRealTime();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      // appBar: AppBar(
      //   title: const Text(
      //     "คำขอฉีดวัคซีน",
      //     style: TextStyle(
      //       fontWeight: FontWeight.w600,
      //       fontSize: 24,
      //       color: Colors.white,
      //     ),
      //   ),
      //   backgroundColor: Color(0xFFDBA871),
      //   iconTheme: IconThemeData(color: Colors.white),
      //   elevation: 0,
      //   centerTitle: true,
      //   // leading: IconButton(
      //   //   icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF916B44)),
      //   //   onPressed: () => Navigator.pop(context),
      //   // ),
      // ),
      // drawer: Drawer(
      //   child: Container(
      //     decoration: BoxDecoration(
      //       image: DecorationImage(
      //         image: AssetImage('assets/images/indexBg.png'),
      //         fit: BoxFit.cover,
      //       ),
      //     ),
      //     child: Container(
      //       decoration: BoxDecoration(
      //         color: Colors.white.withOpacity(0.85),
      //         borderRadius: BorderRadius.only(
      //           topRight: Radius.circular(30),
      //           bottomRight: Radius.circular(30),
      //         ),
      //         boxShadow: [
      //           BoxShadow(
      //             color: Colors.black.withOpacity(0.15),
      //             blurRadius: 10,
      //             offset: Offset(2, 2),
      //           ),
      //         ],
      //       ),
      //       child: ListView(
      //         padding: EdgeInsets.zero,
      //         children: [
      //           DrawerHeader(
      //             decoration: BoxDecoration(
      //               color: Color(0xFFDBA871),
      //               borderRadius: BorderRadius.only(
      //                 topRight: Radius.circular(30),
      //               ),
      //             ),
      //             child: Column(
      //               crossAxisAlignment: CrossAxisAlignment.center,
      //               children: [
      //                 ClipOval(
      //                   child: Image.network(
      //                     box.read('clinicImage'),
      //                     width: screenWidth * 0.2,
      //                     height: screenWidth * 0.2,
      //                     fit: BoxFit.cover,
      //                     loadingBuilder: (context, child, loadingProgress) {
      //                       if (loadingProgress == null) return child;
      //                       return Shimmer.fromColors(
      //                         baseColor: Colors.grey[300]!,
      //                         highlightColor: Colors.grey[100]!,
      //                         child: Container(
      //                           width: screenWidth * 0.2,
      //                           height: screenWidth * 0.2,
      //                           color: Colors.white,
      //                         ),
      //                       );
      //                     },
      //                   ),
      //                 ),
      //                 SizedBox(height: 10),
      //                 Text(
      //                   box.read('clinicName') ?? "ผู้ใช้งาน",
      //                   style: TextStyle(
      //                     color: Colors.white,
      //                     fontSize: 20,
      //                     fontWeight: FontWeight.bold,
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ),
      //           ListTile(
      //             leading: Icon(Icons.home, color: Color(0xFF916b44)),
      //             title: Text('หน้าหลัก'),
      //             onTap: () {
      //               Get.back();
      //               Get.to(() => ClinicmainPage());
      //             },
      //           ),
      //           ListTile(
      //             leading: Icon(Icons.system_security_update,
      //                 color: Color(0xFF916b44)),
      //             title: Text('คำขอฉีดยา'),
      //             onTap: () {
      //               Get.back();
      //               Get.to(() => VaccineRequestsPage());
      //             },
      //           ),
      //           ListTile(
      //             leading: Icon(Icons.notifications, color: Color(0xFF916b44)),
      //             title: Text('แจ้งเตือน'),
      //             onTap: () {
      //               Get.back();
      //               Get.to(() => Notificationpage());
      //             },
      //           ),
      //           ListTile(
      //             leading:
      //                 Icon(Icons.medical_services, color: Color(0xFF916b44)),
      //             title: Text('ประวัติการฉีดยา'),
      //             onTap: () {
      //               Get.back();
      //               Get.to(() => Vaccinehistorypage());
      //             },
      //           ),
      //           ListTile(
      //             leading: Icon(Icons.supervised_user_circle,
      //                 color: Color(0xFF916b44)),
      //             title: Text('หมอประจำคลินิก'),
      //             onTap: () {
      //               Get.back();
      //               Get.to(() => Cliniclistdoctors());
      //             },
      //           ),
      //           ListTile(
      //               leading:
      //                   Icon(Icons.medical_services, color: Color(0xFF916b44)),
      //               title: Text('เวลาปิด-เปิด'),
      //               onTap: () {
      //                 Get.back();
      //                 Get.to(() => Clinicopeninghours());
      //               }),
      //           ListTile(
      //               leading: Icon(Icons.settings, color: Color(0xFF916b44)),
      //               title: Text('ตั้งค่า'),
      //               onTap: () {
      //                 Get.back();
      //                 Get.to(() => Clinicsetting());
      //               }),
      //           ListTile(
      //             leading:
      //                 Icon(MdiIcons.accountSwitch, color: Color(0xFF916b44)),
      //             title: Text('สลับโหมด'),
      //             onTap: () async {
      //               var resGeneral = await http.get(
      //                   Uri.parse("$url/general/name/${box.read('email')}"));
      //               if (resGeneral.statusCode == 200) {
      //                 showAlert(
      //                   title: 'สลับไปยังบัญชีผู้ใช้ทั่วไป?',
      //                   message: 'กด ตกลง เพื่อไปยังบัญชีผู้ใช้ทั่วไป',
      //                   onConfirm: () {
      //                     box.write('type', 'general');
      //                     box.write('generalName',
      //                         jsonDecode(resGeneral.body)['username']);
      //                     box.write('generalImage',
      //                         jsonDecode(resGeneral.body)['image']);
      //                     log('Name ${box.read('generalName')}');
      //                     Get.offAll(() => GeneralmainPage());
      //                   },
      //                 );
      //               } else {
      //                 showAlert(
      //                   title: 'คุณยังไม่มีบัญชีผู้ใช้ทั่วไป!',
      //                   message: 'กด ตกลง เพื่อไปยังหน้าสมัครผู้ใช้ทั่วไป',
      //                   onConfirm: () {
      //                     Get.back();
      //                     Get.to(() => RegisterusergooglePage());
      //                   },
      //                 );
      //               }
      //             },
      //           ),
      //           ListTile(
      //             leading: Icon(Icons.logout, color: Colors.redAccent),
      //             title: Text('ออกจากระบบ'),
      //             onTap: () {
      //               showAlert(
      //                 title: 'ออกจากระบบ?',
      //                 message: 'คุณต้องการออกจากระบบใช่หรือไม่',
      //                 onConfirm: () async {
      //                   await FirebaseMessaging.instance.deleteToken();
      //                   box.erase();
      //                   Get.offAll(() => IndexPage());
      //                 },
      //               );
      //             },
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
      // ),
      body: _loadingData
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFDBA871),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'กำลังโหลด...',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : Container(
              height: screenHeight * 0.9,
              // decoration: BoxDecoration(
              //   image: DecorationImage(
              //     image: AssetImage('assets/images/indexBg.png'),
              //     fit: BoxFit.cover,
              //     colorFilter: ColorFilter.mode(
              //         Colors.white.withOpacity(0.2), BlendMode.dstATop),
              //   ),
              // ),
              color: Color(0xFFFAF8F5),
              child: notifyList.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: notifyList.length,
                      itemBuilder: (context, index) {
                        final notification = notifyList[index];

                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: InkWell(
                            onTap: () {
                              // Handle notification tap if needed
                              // _showNotificationDetail(notification);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Notification Icon
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFDBA871)
                                              .withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          FontAwesomeIcons.bell,
                                          color: Color(0xFF916B44),
                                          size: 18,
                                        ),
                                      ),

                                      SizedBox(width: 12),

                                      // Content
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Title/Sender info
                                            if (notification.receiverEmail !=
                                                null)
                                              Text(
                                                'จาก: ${notification.receiverEmail}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF916B44)
                                                      .withOpacity(0.7),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),

                                            SizedBox(height: 4),

                                            // Message
                                            Text(
                                              notification.message,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF5D4037),
                                                fontWeight: FontWeight.w500,
                                                height: 1.4,
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),

                                            SizedBox(height: 8),

                                            // Timestamp
                                            Text(
                                              _formatDateTime(
                                                  notification.createAt),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // More options or read status
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        color:
                                            Color(0xFF916B44).withOpacity(0.5),
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    // Format time as HH:MM
    String formatTime(DateTime dt) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'เมื่อวาน ${formatTime(dateTime)}';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} วันที่แล้ว';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${formatTime(dateTime)}';
      }
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ชั่วโมงที่แล้ว';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} นาทีที่แล้ว';
    } else {
      return 'เมื่อสักครู่';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Color(0xFFDBA871).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              FontAwesomeIcons.bell,
              size: 48,
              color: Color(0xFF916B44).withOpacity(0.5),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'ไม่มีการแจ้งเตือน',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5D4037),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'คุณจะได้รับการแจ้งเตือนที่นี่\nเมื่อมีข้อมูลสำคัญ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.4,
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

    final userEmail = box.read('email');
    if (userEmail == null) {
      log('User email is null. Cannot fetch notifications.');
      return;
    }

    log('Start listening realtime notifications for user: $userEmail');

    _reserveListener = FirebaseFirestore.instance
        .collection('clinicNotifications')
        .where('receiverEmail', isEqualTo: userEmail)
        .orderBy('createAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      log('Realtime update - total notifications: ${snapshot.docs.length}');

      notifyList = snapshot.docs.map((doc) {
        log('Doc ID: ${doc.id}');
        log('Doc data: ${doc.data()}');
        return NotifyModel.fromMap(doc.data());
      }).toList();

      for (var n in notifyList) {
        log('Notification message: ${n.message}');
        log('Notification created at: ${n.createAt}');
      }
      setState(() {});

      // ถ้าคุณต้องการให้ UI รีเฟรช ให้เรียก setState() ใน StatefulWidget หรือแจ้ง listener ที่เหมาะสมที่นี่
    }, onError: (error) {
      log('Error listening to notifications: $error');
    });
  }

  void stopRealTime() {
    _reserveListener?.cancel();
    _reserveListener = null;
    log('Stopped realtime notification listener.');
  }

  String _cleanMessageText(String message) {
    // Replace timestamps like "11:00:00.000" with "11:00"
    return message.replaceAllMapped(
      RegExp(r'(\d{1,2}):(\d{2}):\d{2}\.\d{3}'),
      (match) => '${match.group(1)}:${match.group(2)}',
    );
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
