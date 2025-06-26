import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/utils/firebase_data.dart';
import 'package:flutter_application_1/utils/app_theme.dart';
import 'package:flutter_application_1/utils/app_localizations.dart';
import 'package:flutter_application_1/screens/Auth/login_screen.dart';

class BookingData {
  final Property property;
  final DateTime selectedDate;
  final String selectedRoom;
  final String selectedTime;
  final String selectedDuration;
  final int totalPrice;

  BookingData({
    required this.property,
    required this.selectedDate,
    required this.selectedRoom,
    required this.selectedTime,
    required this.selectedDuration,
    required this.totalPrice,
  });
}

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final CollectionReference _bookings =
      FirebaseFirestore.instance.collection('bookings');
  bool _isLoading = true;
  String? _selectedRoomFilter;
  final List<String> _roomTypes = ['Co Working', 'Meeting Room', 'Room Event'];

  @override
  void initState() {
    super.initState();
    _fetchInitialOrders();
  }

  Future<void> _fetchInitialOrders() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.translate('please_login') ?? 'Please login'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: l10n.translate('login') ?? 'Login',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ),
        );
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Stream<List<BookingData>> _fetchOrders() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _bookings
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final propertyData = data['property'] as Map<String, dynamic>;
        return BookingData(
          property: Property.fromJson(
            propertyData['id'],
            propertyData,
          ),
          selectedDate: DateTime.parse(data['selectedDate']),
          selectedRoom: data['selectedRoom'] ?? 'Unknown',
          selectedTime: data['selectedTime'] ?? 'Unknown',
          selectedDuration: data['selectedDuration'] ?? '0',
          totalPrice: (data['totalPrice'] as num?)?.toInt() ?? 0,
        );
      }).toList();
    }).handleError((e) {
      final l10n = AppLocalizations.of(context);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.translate('failed_to_load_orders',
                      args: {'error': e.toString()}) ??
                  'Failed to load orders: $e',
            ),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: l10n.translate('retry') ?? 'Retry',
              onPressed: () => setState(() {}),
            ),
          ),
        );
      });
    });
  }

  // Method untuk mendapatkan room types yang tersedia berdasarkan data
  List<String> _getAvailableRoomTypes(List<BookingData> orders) {
    final availableRooms =
        orders.map((order) => order.selectedRoom).toSet().toList();
    return _roomTypes
        .where((roomType) => availableRooms.contains(roomType))
        .toList();
  }

  // Method untuk mengecek apakah room type memiliki data
  bool _hasDataForRoomType(List<BookingData> orders, String roomType) {
    return orders.any((order) => order.selectedRoom == roomType);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          l10n.translate('my_orders') ?? 'My Orders',
          style: AppTheme.headingStyle(size: 18),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<BookingData>>(
              stream: _fetchOrders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.translate('error_loading_orders') ??
                              'Error loading orders',
                          style: AppTheme.contentStyle(
                            size: 16,
                            color: Colors.red.shade600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            l10n.translate('retry') ?? 'Retry',
                            style: AppTheme.headingStyle(
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                final orders = snapshot.data ?? [];

                // Cek jika filter yang dipilih tidak memiliki data, reset ke "All"
                if (_selectedRoomFilter != null &&
                    !_hasDataForRoomType(orders, _selectedRoomFilter!)) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _selectedRoomFilter = null;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n.translate('no_data_for_room_type') ??
                              'No data available for this room type. Showing all orders.',
                        ),
                        backgroundColor: Colors.orange,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  });
                }

                final filteredOrders = _selectedRoomFilter == null
                    ? orders
                    : orders
                        .where(
                          (order) => order.selectedRoom == _selectedRoomFilter,
                        )
                        .toList();

                if (orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.translate('no_orders') ?? 'No orders found',
                          style: AppTheme.contentStyle(
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final availableRoomTypes = _getAvailableRoomTypes(orders);

                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildTab(
                              l10n.translate('all') ?? 'All',
                              _selectedRoomFilter == null,
                              null,
                              true, // Always enabled
                            ),
                            const SizedBox(width: 16),
                            ..._roomTypes.map(
                              (room) {
                                final hasData =
                                    _hasDataForRoomType(orders, room);
                                return Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: _buildTab(
                                    l10n.translate(
                                          room
                                              .toLowerCase()
                                              .replaceAll(' ', '_'),
                                        ) ??
                                        room,
                                    _selectedRoomFilter == room,
                                    room,
                                    hasData, // Only enabled if has data
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          final bookingData = filteredOrders[index];
                          return _buildOrderCard(context, bookingData, l10n);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    BookingData bookingData,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMM d, yyyy').format(bookingData.selectedDate),
                style: AppTheme.contentStyle(
                  size: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.translate('active_booking') ?? 'Active',
                  style: AppTheme.contentStyle(size: 10, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            bookingData.property.nameProperty,
            style: AppTheme.headingStyle(size: 16),
          ),
          Text(
            bookingData.property.addressProperty ??
                l10n.translate('unknown_location') ??
                'Unknown location',
            style: AppTheme.contentStyle(size: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildDetailChip(
                l10n.translate('room') ?? 'Room',
                bookingData.selectedRoom,
              ),
              _buildDetailChip(
                l10n.translate('time') ?? 'Time',
                bookingData.selectedTime,
              ),
              _buildDetailChip(
                l10n.translate('duration') ?? 'Duration',
                l10n.translate('hours',
                        args: {'count': bookingData.selectedDuration}) ??
                    '${bookingData.selectedDuration} hours',
              ),
              _buildDetailChip(
                l10n.translate('price') ?? 'Price',
                'Rp${bookingData.totalPrice}',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n.translate('reschedule_not_implemented') ??
                              'Reschedule not implemented',
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    l10n.translate('reschedule') ?? 'Reschedule',
                    style: AppTheme.contentStyle(size: 14, color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _showBookingDetail(context, bookingData, l10n);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    l10n.translate('view_details') ?? 'View Details',
                    style: AppTheme.headingStyle(size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info, color: Colors.amber, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    bookingData.property.description ??
                        l10n.translate('no_description') ??
                        'No description',
                    style: AppTheme.contentStyle(
                      size: 12,
                      color: Colors.amber.shade800,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingDetail(
    BuildContext context,
    BookingData bookingData,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.translate('booking_details') ?? 'Booking Details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.translate('property') ?? 'Property'}: ${bookingData.property.nameProperty}',
                ),
                Text(
                  '${l10n.translate('location') ?? 'Location'}: ${bookingData.property.addressProperty ?? l10n.translate('unknown_location') ?? 'Unknown location'}',
                ),
                Text(
                  '${l10n.translate('date') ?? 'Date'}: ${DateFormat('MMM d, yyyy').format(bookingData.selectedDate)}',
                ),
                Text(
                  '${l10n.translate('room') ?? 'Room'}: ${bookingData.selectedRoom}',
                ),
                Text(
                  '${l10n.translate('time') ?? 'Time'}: ${bookingData.selectedTime}',
                ),
                Text(
                  '${l10n.translate('duration') ?? 'Duration'}: ${l10n.translate('hours', args: {
                            'count': bookingData.selectedDuration
                          }) ?? '${bookingData.selectedDuration} hours'}',
                ),
                Text(
                  '${l10n.translate('total_price') ?? 'Total Price'}: Rp${bookingData.totalPrice}',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.translate('close') ?? 'Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTab(
      String title, bool isActive, String? roomType, bool isEnabled) {
    return GestureDetector(
      onTap: isEnabled
          ? () {
              setState(() {
                _selectedRoomFilter = roomType;
              });
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.amber
              : isEnabled
                  ? Colors.transparent
                  : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: isActive
              ? null
              : Border.all(
                  color:
                      isEnabled ? Colors.grey.shade300 : Colors.grey.shade200),
        ),
        child: Text(
          title,
          style: AppTheme.contentStyle(
            size: 12,
            color: isActive
                ? Colors.white
                : isEnabled
                    ? Colors.grey.shade600
                    : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTheme.contentStyle(size: 10, color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: AppTheme.contentStyle(size: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
