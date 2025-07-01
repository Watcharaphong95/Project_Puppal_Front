import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:puppal_application/config/config.dart';
import 'package:puppal_application/model/reservebooking.dart';

class Acceptrequest extends StatefulWidget {
  final int reserveID;
  const Acceptrequest({super.key, required this.reserveID});

  @override
  State<Acceptrequest> createState() => _AcceptrequestState();
}

class _AcceptrequestState extends State<Acceptrequest> {
  String url = '';

  final box = GetStorage();
  List<Reservebooking> reserveList = [];
  bool isLoading = true;

  // Minimal Color Palette
  final Color primaryBrown = const Color(0xFF916B44);
  final Color secondaryBrown = const Color(0xFFDBA871);
  final Color lightBrown = const Color(0xFFE9CBAF);

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
      getReserve(widget.reserveID.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryBrown),
        title: Text(
          'Appointment Requests',
          style: TextStyle(
            color: primaryBrown,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: isLoading ? _buildLoadingWidget() : _buildRequestsList(),
      floatingActionButton: reserveList.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () =>
                  _showAppointmentPopup(context, reserveList.first),
              backgroundColor: primaryBrown,
              icon: const Icon(Icons.visibility, color: Colors.white),
              label: const Text(
                'View Details',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(primaryBrown),
        strokeWidth: 2,
      ),
    );
  }

  Widget _buildRequestsList() {
    if (reserveList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No appointment found',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Simple preview card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () => _showAppointmentPopup(context, reserveList.first),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: lightBrown.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      Icons.pets,
                      color: primaryBrown,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reserveList.first.name ?? 'Unknown Pet',
                          style: TextStyle(
                            color: primaryBrown,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Appointment Request #${reserveList.first.reserveId}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tap "View Details" to see full information',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Pop-up Dialog Method
  void _showAppointmentPopup(BuildContext context, Reservebooking reservation) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Close Button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.grey[600],
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),

                // Card Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: lightBrown.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '#${reservation.reserveId}',
                              style: TextStyle(
                                color: primaryBrown,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.pets_outlined,
                            color: primaryBrown.withOpacity(0.7),
                            size: 24,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Pet Name - Main Focus
                      Text(
                        reservation.name ?? 'Unknown Pet',
                        style: TextStyle(
                          color: primaryBrown,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        reservation.breed ?? 'Mixed Breed',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Divider
                      Container(
                        height: 1,
                        width: 50,
                        color: lightBrown.withOpacity(0.5),
                      ),

                      const SizedBox(height: 24),

                      // Details
                      _buildPopupDetailRow(
                          'Owner', reservation.username ?? 'Not specified'),
                      _buildPopupDetailRow(
                          'Phone', reservation.phone ?? 'Not specified'),
                      _buildPopupDetailRow('Vaccine',
                          reservation.typeVaccine ?? 'Not specified'),
                      _buildPopupDetailRow(
                          'Date', _formatDate(reservation.date)),
                      _buildPopupDetailRow('Time',
                          reservation.date.toString() ?? 'Not specified'),

                      const SizedBox(height: 32),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: _buildPopupActionButton(
                              label: 'Decline',
                              onPressed: () {
                                Navigator.pop(context);
                                _showRejectDialog();
                              },
                              isPrimary: false,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildPopupActionButton(
                              label: 'Accept',
                              onPressed: () {
                                Navigator.pop(context);
                                _showAcceptDialog();
                              },
                              isPrimary: true,
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
        );
      },
    );
  }

  Widget _buildPopupDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopupActionButton({
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return Container(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? primaryBrown : Colors.grey[100],
          foregroundColor: isPrimary ? Colors.white : Colors.grey[700],
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: isPrimary
                ? BorderSide.none
                : BorderSide(color: Colors.grey[300]!, width: 1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not specified';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showAcceptDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: primaryBrown.withOpacity(0.1),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(
                Icons.check,
                color: primaryBrown,
                size: 32,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Accept Appointment?',
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This appointment will be confirmed',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _acceptReservation();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBrown,
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(
                Icons.close,
                color: Colors.red,
                size: 32,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Decline Appointment?',
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This action cannot be undone',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _rejectReservation();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    child: const Text('Decline'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _acceptReservation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Appointment accepted successfully'),
        backgroundColor: primaryBrown,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _rejectReservation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Appointment declined'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> getReserve(String reserveID) async {
    var res = await http.get(Uri.parse("$url/reserve/search_id/$reserveID"));
    if (res.statusCode == 200) {
      reserveList = reservebookingFromJson(res.body);
      for (var data in reserveList) {
        log(data.reserveId.toString());
      }
      setState(() {
        isLoading = false;
      });
    } else {
      log("Failed to load: ${res.statusCode}");
    }
  }
}
