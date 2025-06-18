import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/screens/home/data/property_data.dart';

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
  List<BookingData> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  Stream<List<BookingData>> _fetchOrders() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan login untuk melihat pesanan.'),
            backgroundColor: Colors.red,
          ),
        );
      });
      return Stream.value([]);
    }

    final firestore = FirebaseFirestore.instance;
    final ordersRef =
        firestore.collection('orders').doc(user.uid).collection('user_orders');

    return ordersRef.snapshots().map((snapshot) {
      setState(() {
        _isLoading = false;
      });
      return snapshot.docs.map((doc) {
        final orderData = doc.data();
        final propertyData = Map<String, dynamic>.from(orderData['property']);
        return BookingData(
          property: Property(
            id: propertyData['id'] ?? 'default_id',
            name: propertyData['name'] ?? 'Unknown',
            location: propertyData['location'] ?? 'Unknown',
            description: propertyData['description'] ?? '',
            imageUrl: propertyData['imageUrl'] ?? '',
            price: propertyData['price'] ?? '0',
            rating: (propertyData['rating'] as num?)?.toDouble() ?? 0.0,
            locationId: propertyData['locationId'] ?? 'default_location_id',
          ),
          selectedDate: DateTime.parse(orderData['selectedDate']),
          selectedRoom: orderData['selectedRoom'] ?? 'Unknown',
          selectedTime: orderData['selectedTime'] ?? 'Unknown',
          selectedDuration: orderData['selectedDuration'] ?? '0',
          totalPrice: (orderData['totalPrice'] as num?)?.toInt() ?? 0,
        );
      }).toList();
    }).handleError((e) {
      setState(() {
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat pesanan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // Menghapus tombol kembali dengan menghapus properti leading
        title: const Text(
          'Pesanan Saya',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<BookingData>>(
        stream: _fetchOrders(),
        builder: (context, snapshot) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi kesalahan: ${snapshot.error}',
                style: TextStyle(color: Colors.red),
              ),
            );
          }
          _orders = snapshot.data ?? [];
          if (_orders.isEmpty) {
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
                    'Belum ada pesanan',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildTab(
                      'Coworking',
                      _orders
                          .any((order) => order.selectedRoom == 'Co Working'),
                    ),
                    const SizedBox(width: 16),
                    _buildTab(
                      'Meeting Room',
                      _orders
                          .any((order) => order.selectedRoom == 'Meeting Room'),
                    ),
                    const SizedBox(width: 16),
                    _buildTab(
                      'Room Event',
                      _orders
                          .any((order) => order.selectedRoom == 'Room Event'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final bookingData = _orders[index];
                    return _buildOrderCard(context, bookingData);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, BookingData bookingData) {
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
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Booking Aktif',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            bookingData.property.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Text(
            bookingData.property.location,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildDetailChip('Room', bookingData.selectedRoom),
              const SizedBox(width: 12),
              _buildDetailChip('Jam', '${bookingData.selectedTime} AM'),
              const SizedBox(width: 12),
              _buildDetailChip('Durasi', '${bookingData.selectedDuration} Jam'),
              const SizedBox(width: 12),
              _buildDetailChip('Harga', '\$${bookingData.totalPrice}'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Ubah Jadwal',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _showBookingDetail(context, bookingData);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Lihat Detail',
                    style: TextStyle(color: Colors.white),
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
                    bookingData.property.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber.shade800,
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

  void _showBookingDetail(BuildContext context, BookingData bookingData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Detail Booking'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Property: ${bookingData.property.name}'),
              Text('Lokasi: ${bookingData.property.location}'),
              Text(
                'Tanggal: ${DateFormat('MMM d, yyyy').format(bookingData.selectedDate)}',
              ),
              Text('Ruangan: ${bookingData.selectedRoom}'),
              Text('Jam: ${bookingData.selectedTime} AM'),
              Text('Durasi: ${bookingData.selectedDuration} Jam'),
              Text('Total Harga: \$${bookingData.totalPrice}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTab(String title, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.amber : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: isActive ? null : Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.grey.shade600,
          fontSize: 12,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
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
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
