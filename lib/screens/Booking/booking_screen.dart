import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/utils/firebase_data.dart';
import 'package:flutter_application_1/screens/Order/order_screen.dart';
import 'package:flutter_application_1/screens/Auth/login_screen.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/utils/app_localizations.dart';
import 'package:flutter_application_1/utils/app_theme.dart';

class BookingScreen extends StatefulWidget {
  final Property property;

  const BookingScreen({super.key, required this.property});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final CollectionReference _bookings =
      FirebaseFirestore.instance.collection('bookings');
  DateTime _selectedDate = DateTime.now();
  RoomType? _selectedRoom;
  String _selectedTime = '00:00';
  String _selectedDuration = '1';
  List<Room> _rooms = [];
  bool _isLoading = true;
  List<Map<String, dynamic>> _existingBookings = [];

  List<String> _times =
      List.generate(24, (index) => '${index.toString().padLeft(2, '0')}:00');
  final List<String> _durations =
      List.generate(24, (index) => (index + 1).toString());

  @override
  void initState() {
    super.initState();
    _fetchRooms();
    _fetchExistingBookings();
  }

  Future<void> _fetchRooms() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (widget.property.idRoom != null) {
        final doc = await FirebaseFirestore.instance
            .collection('rooms')
            .doc(widget.property.idRoom)
            .get();
        if (doc.exists) {
          setState(() {
            _rooms = [Room.fromJson(widget.property.idRoom!, doc.data()!)];
            _selectedRoom = _rooms.first.typeRoom;
          });
        } else {
          setState(() {
            _rooms = [
              Room(id: 'default', typeRoom: RoomType.coWorking, imageRoom: [])
            ];
            _selectedRoom = RoomType.coWorking;
          });
        }
      }
    } catch (e) {
      print('Error fetching rooms: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load rooms: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchExistingBookings() async {
    try {
      final now = DateTime.now();
      final previousDay = _selectedDate.subtract(const Duration(days: 1));
      final snapshot = await _bookings
          .where('property.id', isEqualTo: widget.property.id)
          .get();

      final relevantBookings = <Map<String, dynamic>>[];
      for (var doc in snapshot.docs) {
        final booking = {'id': doc.id, ...doc.data() as Map<String, dynamic>};
        final startDate = DateTime.parse(booking['selectedDate']);
        final duration = int.parse(booking['selectedDuration']);
        final endDate = startDate.add(Duration(hours: duration));

        // Ambil pemesanan yang aktif atau memengaruhi tanggal yang dipilih
        if (endDate.isAfter(now.subtract(const Duration(days: 30))) &&
            (startDate.isBefore(_selectedDate.add(const Duration(days: 1))) ||
                (startDate.isAfter(previousDay) &&
                    endDate.isAfter(_selectedDate)))) {
          relevantBookings.add(booking);
        }
      }

      setState(() {
        _existingBookings = relevantBookings;
        _updateAvailableTimes();
      });
    } catch (e) {
      print('Error fetching bookings: $e');
    }
  }

  void _updateAvailableTimes() {
    final newTimes = List<String>.from(
        List.generate(24, (index) => '${index.toString().padLeft(2, '0')}:00'));
    newTimes.removeWhere((time) =>
        !_isTimeSlotAvailable(time, _selectedDuration, _selectedDate));
    setState(() {
      _times = newTimes;
      _selectedTime = _times.contains(_selectedTime)
          ? _selectedTime
          : _times.firstOrNull ?? '00:00';
    });
  }

  bool _isDateFullyBooked(DateTime date) {
    final dateStart = DateTime(date.year, date.month, date.day, 0, 0);
    final dateEnd = dateStart.add(const Duration(days: 1));

    final dateBookings = _existingBookings.where((booking) {
      final bookingStartDate = DateTime.parse(booking['selectedDate']);
      final bookingTime = DateFormat('HH:mm').parse(booking['selectedTime']);
      final bookingDuration = int.parse(booking['selectedDuration']);
      final bookingStartDateTime = DateTime(bookingStartDate.year,
          bookingStartDate.month, bookingStartDate.day, bookingTime.hour);
      final bookingEndDateTime =
          bookingStartDateTime.add(Duration(hours: bookingDuration));
      return (bookingStartDateTime.isBefore(dateEnd) &&
              bookingEndDateTime.isAfter(dateStart)) &&
          booking['selectedRoom'] == _selectedRoom?.displayName;
    }).toList();

    int bookedHours = 0;
    for (var booking in dateBookings) {
      final bookingStartDate = DateTime.parse(booking['selectedDate']);
      final bookingTime = DateFormat('HH:mm').parse(booking['selectedTime']);
      final bookingDuration = int.parse(booking['selectedDuration']);
      final bookingStartDateTime = DateTime(bookingStartDate.year,
          bookingStartDate.month, bookingStartDate.day, bookingTime.hour);
      final bookingEndDateTime =
          bookingStartDateTime.add(Duration(hours: bookingDuration));

      final start = bookingStartDateTime.isBefore(dateStart)
          ? dateStart
          : bookingStartDateTime;
      final end =
          bookingEndDateTime.isAfter(dateEnd) ? dateEnd : bookingEndDateTime;

      bookedHours += end.difference(start).inHours;
      if (bookedHours >= 24) return true;
    }

    return bookedHours >= 24;
  }

  bool _isTimeSlotAvailable(String time, String duration, DateTime date) {
    final selectedTime = DateFormat('HH:mm').parse(time);
    final selectedDuration = int.parse(duration);
    final selectedStartDateTime = DateTime(date.year, date.month, date.day,
        selectedTime.hour, selectedTime.minute);
    final selectedEndDateTime =
        selectedStartDateTime.add(Duration(hours: selectedDuration));
    final restrictedEndDateTime = selectedEndDateTime
        .add(const Duration(hours: 1)); // Jeda 1 jam untuk pembersihan

    for (var booking in _existingBookings) {
      final bookingStartDate = DateTime.parse(booking['selectedDate']);
      final bookingTime = DateFormat('HH:mm').parse(booking['selectedTime']);
      final bookingDuration = int.parse(booking['selectedDuration']);
      final bookingStartDateTime = DateTime(
          bookingStartDate.year,
          bookingStartDate.month,
          bookingStartDate.day,
          bookingTime.hour,
          bookingTime.minute);
      final bookingEndDateTime =
          bookingStartDateTime.add(Duration(hours: bookingDuration));
      final bookingRestrictedEndDateTime =
          bookingEndDateTime.add(const Duration(hours: 1)); // Jeda 1 jam

      if (booking['selectedRoom'] != _selectedRoom?.displayName) {
        continue;
      }

      if ((selectedStartDateTime.isBefore(bookingRestrictedEndDateTime) &&
              selectedEndDateTime.isAfter(bookingStartDateTime)) ||
          selectedStartDateTime.isAtSameMomentAs(bookingStartDateTime)) {
        return false;
      }
    }
    return true;
  }

  bool _isDateBeforeToday(DateTime date) {
    final now = DateTime.now();
    return date.isBefore(DateTime(now.year, now.month, now.day));
  }

  void _selectDate(int day) {
    final newDate = DateTime(_selectedDate.year, _selectedDate.month, day);
    if (_isDateBeforeToday(newDate)) return;
    setState(() {
      _selectedDate = newDate;
      _fetchExistingBookings();
    });
  }

  void _goToNextMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
      _fetchExistingBookings();
    });
  }

  void _goToPreviousMonth() {
    final newDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
    if (_isDateBeforeToday(newDate)) return;
    setState(() {
      _selectedDate = newDate;
      _fetchExistingBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.translate('book'),
          style: AppTheme.headingStyle(size: 18),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.translate('select_date'),
                    style: AppTheme.headingStyle(size: 16),
                  ),
                  const SizedBox(height: 16),
                  _buildCalendarWidget(l10n),
                  const SizedBox(height: 24),
                  Text(
                    l10n.translate('select_room'),
                    style: AppTheme.headingStyle(size: 16),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<RoomType>(
                        value: _selectedRoom,
                        isExpanded: true,
                        items: _rooms.map((Room room) {
                          return DropdownMenuItem<RoomType>(
                            value: room.typeRoom,
                            child: Text(room.typeRoom.displayName),
                          );
                        }).toList(),
                        onChanged: (RoomType? newValue) {
                          setState(() {
                            _selectedRoom = newValue!;
                            _fetchExistingBookings();
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.translate('select_time'),
                    style: AppTheme.headingStyle(size: 16),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _times.contains(_selectedTime)
                            ? _selectedTime
                            : _times.firstOrNull,
                        isExpanded: true,
                        items: _times.map((String time) {
                          return DropdownMenuItem<String>(
                            value: time,
                            child: Text(time),
                            enabled: _isTimeSlotAvailable(
                                time, _selectedDuration, _selectedDate),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null &&
                              _isTimeSlotAvailable(
                                  newValue, _selectedDuration, _selectedDate)) {
                            setState(() {
                              _selectedTime = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.translate('select_duration'),
                    style: AppTheme.headingStyle(size: 16),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedDuration,
                        isExpanded: true,
                        items: _durations.map((String duration) {
                          return DropdownMenuItem<String>(
                            value: duration,
                            child: Text(l10n
                                .translate('hours', args: {'count': duration})),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedDuration = newValue!;
                            _updateAvailableTimes();
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isTimeSlotAvailable(
                              _selectedTime, _selectedDuration, _selectedDate)
                          ? _continueToBooking
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(45),
                        ),
                      ),
                      child: Text(
                        l10n.translate('continue_booking'),
                        style: AppTheme.headingStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCalendarWidget(AppLocalizations l10n) {
    final daysInMonth =
        DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    final firstDayOfMonth =
        DateTime(_selectedDate.year, _selectedDate.month, 1);
    final startingWeekday = firstDayOfMonth.weekday % 7;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _goToPreviousMonth,
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                DateFormat('MMMM yyyy').format(_selectedDate),
                style: AppTheme.headingStyle(size: 16),
              ),
              IconButton(
                onPressed: _goToNextMonth,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: l10n
                .translate('weekdays')
                .split(',')
                .map((day) => Text(
                      day.trim(),
                      style: AppTheme.contentStyle(
                        size: 12,
                        color: Colors.grey.shade600,
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          ...List.generate(6, (weekIndex) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (dayIndex) {
                final dayNumber =
                    weekIndex * 7 + dayIndex - startingWeekday + 1;

                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const SizedBox(width: 32, height: 32);
                }

                final currentDate = DateTime(
                    _selectedDate.year, _selectedDate.month, dayNumber);
                final isSelected = dayNumber == _selectedDate.day;
                final isToday = dayNumber == DateTime.now().day &&
                    _selectedDate.month == DateTime.now().month &&
                    _selectedDate.year == DateTime.now().year;
                final isFullyBooked = _isDateFullyBooked(currentDate);
                final isPastDate = _isDateBeforeToday(currentDate);

                return GestureDetector(
                  onTap: isFullyBooked || isPastDate
                      ? null
                      : () => _selectDate(dayNumber),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.amber
                          : isFullyBooked
                              ? Colors.red.shade100
                              : isPastDate
                                  ? Colors.grey.shade200
                                  : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: isToday &&
                              !isSelected &&
                              !isFullyBooked &&
                              !isPastDate
                          ? Border.all(color: Colors.amber)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        dayNumber.toString(),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : isFullyBooked
                                  ? Colors.red
                                  : isPastDate
                                      ? Colors.grey
                                      : Colors.black,
                          fontWeight: isSelected || isToday
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }

  void _continueToBooking() {
    final user = FirebaseAuth.instance.currentUser;
    final l10n = AppLocalizations.of(context);
    final currentDateTime = DateTime.now();

    print(
        'DEBUG [${currentDateTime.toIso8601String()}]: _continueToBooking called');
    print('DEBUG: User: ${user?.uid ?? "Not authenticated"}');
    print('DEBUG: Selected Date: $_selectedDate');
    print('DEBUG: Selected Time: $_selectedTime');
    print('DEBUG: Selected Duration: $_selectedDuration');
    print(
        'DEBUG: Is Time Slot Available: ${_isTimeSlotAvailable(_selectedTime, _selectedDuration, _selectedDate)}');

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.translate('please_login') ?? 'Please login'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      print('DEBUG: Redirecting to login screen');
      return;
    }

    if (!_isTimeSlotAvailable(
        _selectedTime, _selectedDuration, _selectedDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.translate('time_slot_unavailable') ??
              'Time slot unavailable'),
          backgroundColor: Colors.red,
        ),
      );
      print('DEBUG: Time slot unavailable, showing snackbar');
      return;
    }

    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingDetailScreen(
            property: widget.property,
            selectedDate: _selectedDate,
            selectedRoom: _selectedRoom!,
            selectedTime: _selectedTime,
            selectedDuration: _selectedDuration,
          ),
        ),
      );
      print('DEBUG: Navigating to BookingDetailScreen');
    } catch (e) {
      print('DEBUG: Error during navigation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error navigating to booking details: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class BookingDetailScreen extends StatefulWidget {
  final Property property;
  final DateTime selectedDate;
  final RoomType selectedRoom;
  final String selectedTime;
  final String selectedDuration;

  const BookingDetailScreen({
    super.key,
    required this.property,
    required this.selectedDate,
    required this.selectedRoom,
    required this.selectedTime,
    required this.selectedDuration,
  });

  @override
  _BookingDetailScreenState createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final CollectionReference _bookings =
      FirebaseFirestore.instance.collection('bookings');
  bool _isBookingConfirmed = false;
  bool _isLoading = false;

  void _confirmBooking() async {
    final user = FirebaseAuth.instance.currentUser;
    final l10n = AppLocalizations.of(context);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.translate('please_login') ?? 'Please login'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final totalPrice = _calculateTotalPrice();
    final selectedTime = DateFormat('HH:mm').parse(widget.selectedTime);
    final selectedDuration = int.parse(widget.selectedDuration);
    final selectedStartDateTime = DateTime(widget.selectedDate.year,
        widget.selectedDate.month, widget.selectedDate.day, selectedTime.hour);
    final selectedEndDateTime =
        selectedStartDateTime.add(Duration(hours: selectedDuration));

    try {
      final snapshot = await _bookings
          .where('property.id', isEqualTo: widget.property.id)
          .get();

      bool hasConflict = false;
      for (var doc in snapshot.docs) {
        final booking = doc.data() as Map<String, dynamic>;
        final bookingStartDate = DateTime.parse(booking['selectedDate']);
        final bookingTime = DateFormat('HH:mm').parse(booking['selectedTime']);
        final bookingDuration = int.parse(booking['selectedDuration']);
        final bookingStartDateTime = DateTime(bookingStartDate.year,
            bookingStartDate.month, bookingStartDate.day, bookingTime.hour);
        final bookingEndDateTime =
            bookingStartDateTime.add(Duration(hours: bookingDuration));
        final bookingRestrictedEndDateTime =
            bookingEndDateTime.add(const Duration(hours: 1)); // Jeda 1 jam

        if (booking['selectedRoom'] != widget.selectedRoom.displayName) {
          continue;
        }

        if ((selectedStartDateTime.isBefore(bookingRestrictedEndDateTime) &&
                selectedEndDateTime.isAfter(bookingStartDateTime)) ||
            selectedStartDateTime.isAtSameMomentAs(bookingStartDateTime)) {
          hasConflict = true;
          break;
        }
      }

      if (hasConflict) {
        throw Exception('Time slot already booked or within cleaning period');
      }

      await _bookings.add({
        'userId': user.uid,
        'property': {
          'id': widget.property.id,
          'name': widget.property.nameProperty,
          'location': widget.property.addressProperty,
          'description': widget.property.description,
          'imageUrl': widget.property.urlimageProperty,
          'rating': widget.property.rating,
        },
        'selectedDate': widget.selectedDate.toIso8601String(),
        'endDate': selectedEndDateTime.toIso8601String(),
        'selectedRoom': widget.selectedRoom.displayName,
        'selectedTime': widget.selectedTime,
        'selectedDuration': widget.selectedDuration,
        'totalPrice': totalPrice,
        'createdAt': DateTime.now().toIso8601String(),
      });

      setState(() {
        _isBookingConfirmed = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.translate('failed_to_save_order',
                    args: {'error': e.toString()}) ??
                'Failed to save order: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: l10n.translate('try_again') ?? 'Try again',
              onPressed: _confirmBooking,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  int _calculateTotalPrice() {
    int basePrice = (widget.property.price ?? 1000000).toInt();
    int duration = int.tryParse(widget.selectedDuration) ?? 1;
    return (basePrice / 30 / 24 * duration).round();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_isBookingConfirmed) {
      return _buildSuccessScreen(l10n);
    }

    int totalPrice = _calculateTotalPrice();
    final selectedTime = DateFormat('HH:mm').parse(widget.selectedTime);
    final selectedDuration = int.parse(widget.selectedDuration);
    final selectedStartDateTime = DateTime(widget.selectedDate.year,
        widget.selectedDate.month, widget.selectedDate.day, selectedTime.hour);
    final selectedEndDateTime =
        selectedStartDateTime.add(Duration(hours: selectedDuration));
    final endDateText = selectedEndDateTime.day == widget.selectedDate.day
        ? DateFormat('HH:mm').format(selectedEndDateTime)
        : DateFormat('MMM d, yyyy HH:mm').format(selectedEndDateTime);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.translate('booking_details') ?? 'Booking Details',
          style: AppTheme.headingStyle(size: 18),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.translate('room') ?? 'Room',
                    style: AppTheme.contentStyle(
                        size: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(
                                widget.property.urlimageProperty ??
                                    'https://via.placeholder.com/50',
                              ),
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) =>
                                  const AssetImage(
                                      'assets/images/default_property.png'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.selectedRoom.displayName,
                                style: AppTheme.headingStyle(size: 16),
                              ),
                              Text(
                                widget.property.description ??
                                    (l10n.translate('no_description') ??
                                        'No description'),
                                style: AppTheme.contentStyle(
                                  size: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.translate('location') ?? 'Location',
                    style: AppTheme.contentStyle(
                        size: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.property.nameProperty,
                              style: AppTheme.headingStyle(size: 16),
                            ),
                            Text(
                              widget.property.addressProperty ??
                                  (l10n.translate('unknown_location') ??
                                      'Unknown location'),
                              style: AppTheme.contentStyle(
                                size: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow(
                    l10n.translate('booking_date') ?? 'Booking Date',
                    DateFormat('MMM d, yyyy').format(widget.selectedDate),
                  ),
                  _buildDetailRow(
                      l10n.translate('booking_time') ?? 'Booking Time',
                      widget.selectedTime),
                  _buildDetailRow(
                    l10n.translate('booking_end') ?? 'Booking End',
                    endDateText,
                  ),
                  _buildDetailRow(
                    l10n.translate('booking_duration') ?? 'Booking Duration',
                    l10n.translate('hours',
                            args: {'count': widget.selectedDuration}) ??
                        '${widget.selectedDuration} hours',
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    l10n.translate('room_cost') ?? 'Room Cost',
                    'Rp${totalPrice.toString()}',
                  ),
                  _buildDetailRow(l10n.translate('tax') ?? 'Tax',
                      l10n.translate('free') ?? 'Free'),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    l10n.translate('total') ?? 'Total',
                    'Rp${totalPrice.toString()}',
                    isTotal: true,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _confirmBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(45),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.translate('pay_order') ?? 'Pay Order',
                            style: AppTheme.headingStyle(
                              size: 16,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Rp${totalPrice.toString()}',
                            style: AppTheme.headingStyle(
                              size: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.contentStyle(
              size: isTotal ? 16 : 14,
              color: isTotal ? Colors.black : Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: AppTheme.contentStyle(
              size: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessScreen(AppLocalizations l10n) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.amber,
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.translate('payment_success') ?? 'Payment Success',
              style: AppTheme.headingStyle(size: 20),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OrderScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                l10n.translate('view_my_orders') ?? 'View My Orders',
                style: AppTheme.headingStyle(size: 14, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(45),
                ),
              ),
              child: Text(
                l10n.translate('back_to_home') ?? 'Back to Home',
                style: AppTheme.headingStyle(size: 14, color: Colors.black)
              ),
            ),
          ],
        ),
      ),
    );
  }
}
