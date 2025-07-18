import 'package:flutter/material.dart';

class Notificationpage extends StatefulWidget {
  const Notificationpage({super.key});

  @override
  State<Notificationpage> createState() => _NotificationpageState();
}

class _NotificationpageState extends State<Notificationpage> {
  // Sample notification data
  List<NotificationItem> notifications = [
    NotificationItem(
      id: 1,
      title: 'การจองใหม่',
      message:
          'คุณสมชาย ได้จองฉีดวัคซีนสำหรับสุนัขชื่อ "มิโกะ" วันที่ 20 ก.ค. 2567 เวลา 10:00',
      time: '2 นาทีที่แล้ว',
      type: NotificationType.newBooking,
      isRead: false,
    ),
    NotificationItem(
      id: 2,
      title: 'ยกเลิกการจอง',
      message:
          'คุณสมหญิง ได้ยกเลิกการจองฉีดวัคซีนสำหรับสุนัขชื่อ "โชโค" วันที่ 21 ก.ค. 2567',
      time: '15 นาทีที่แล้ว',
      type: NotificationType.cancelBooking,
      isRead: false,
    ),
    NotificationItem(
      id: 3,
      title: 'เปลี่ยนแปลงการจอง',
      message: 'คุณสมศรี ได้เปลี่ยนเวลาการจองฉีดวัคซีนจาก 14:00 เป็น 16:00 น.',
      time: '1 ชั่วโมงที่แล้ว',
      type: NotificationType.changeBooking,
      isRead: true,
    ),
    NotificationItem(
      id: 4,
      title: 'การจองใหม่',
      message:
          'คุณสมปอง ได้จองฉีดวัคซีนสำหรับสุนัขชื่อ "บูลลี่" วันที่ 22 ก.ค. 2567 เวลา 09:30',
      time: '2 ชั่วโมงที่แล้ว',
      type: NotificationType.newBooking,
      isRead: true,
    ),
    NotificationItem(
      id: 5,
      title: 'เตือนความจำ',
      message: 'มีการจองฉีดวัคซีนวันนี้ 3 รายการ กรุณาตรวจสอบรายละเอียด',
      time: '3 ชั่วโมงที่แล้ว',
      type: NotificationType.reminder,
      isRead: true,
    ),
    NotificationItem(
      id: 6,
      title: 'คำถามจากลูกค้า',
      message: 'คุณสมใจ ได้ส่งคำถามเกี่ยวกับการดูแลหลังฉีดวัคซีน',
      time: '1 วันที่แล้ว',
      type: NotificationType.question,
      isRead: true,
    ),
  ];

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
          // backgroundColor: const Color(0xFF916B44),
          // foregroundColor: Colors.white,
          // title: const Text(
          //   'การแจ้งเตือน',
          //   style: TextStyle(
          //     fontWeight: FontWeight.bold,
          //     fontSize: 18,
          //   ),
          // ),
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
          // Summary Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF916B44),
                  const Color(0xFFDBA871),
                ],
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

          // Filter Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterTab('ทั้งหมด', true),
                const SizedBox(width: 8),
                _buildFilterTab('ยังไม่อ่าน', false),
                const SizedBox(width: 8),
                _buildFilterTab('การจอง', false),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Notification List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationCard(notification);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String title, bool isActive) {
    return Container(
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
