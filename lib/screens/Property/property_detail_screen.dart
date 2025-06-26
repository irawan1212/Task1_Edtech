import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/utils/firebase_data.dart';
import 'package:flutter_application_1/screens/Booking/booking_screen.dart';
import 'package:flutter_application_1/screens/Auth/login_screen.dart';
import 'package:flutter_application_1/utils/app_theme.dart';
import 'package:flutter_application_1/screens/Property/facility_item.dart';
import 'package:flutter_application_1/utils/location_currency_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geo;

class PropertyDetailScreen extends StatefulWidget {
  final Property property;

  const PropertyDetailScreen({super.key, required this.property});

  @override
  _PropertyDetailScreenState createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  final CollectionReference _facilities =
      FirebaseFirestore.instance.collection('facilities');
  final CollectionReference _rooms =
      FirebaseFirestore.instance.collection('rooms');

  // Map related variables
  GoogleMapController? mapController;
  LatLng? propertyLocation;
  Set<Marker> markers = {};
  bool isLoadingLocation = true;
  String? locationError;

  Facility? facility;
  List<String>? roomImages;
  bool isLoadingRoomImages = true;

  // Currency related variables
  String? userCurrency;
  String? userCountry;
  String? userLocation;
  double? convertedPrice;
  bool isLoadingCurrency = true;
  bool showOriginalPrice = false;

  @override
  void initState() {
    super.initState();
    _fetchFacility();
    _fetchRoomImages();
    _initializeUserCurrency();
    _initializePropertyLocation();
  }

  Future<void> _initializePropertyLocation() async {
    setState(() {
      isLoadingLocation = true;
      locationError = null;
    });

    if (widget.property.addressProperty == null ||
        widget.property.addressProperty!.trim().isEmpty) {
      _setDefaultLocation('No address provided');
      return;
    }

    try {
      String cleanAddress = _cleanAddress(widget.property.addressProperty!);
      List<geo.Location>? locations =
          await _tryMultipleGeocodingApproaches(cleanAddress);

      if (locations != null && locations.isNotEmpty) {
        final location = locations.first;
        await _setPropertyLocation(location);
      } else {
        _setDefaultLocation('Location not found for this address');
      }
    } catch (e) {
      print('Error getting location coordinates: $e');
      _setDefaultLocation('Failed to get location coordinates');
    }
  }

  String _cleanAddress(String address) {
    String cleaned = address.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (!cleaned.toLowerCase().contains('indonesia') &&
        !cleaned.toLowerCase().contains('jakarta') &&
        !cleaned.toLowerCase().contains('surabaya') &&
        !cleaned.toLowerCase().contains('bandung') &&
        !cleaned.toLowerCase().contains('medan') &&
        !cleaned.toLowerCase().contains('semarang')) {
      cleaned += ', Indonesia';
    }
    return cleaned;
  }

  Future<List<geo.Location>?> _tryMultipleGeocodingApproaches(
      String address) async {
    List<String> addressVariations = [
      address,
      address.replaceAll(',', ''),
      '$address, Indonesia',
      address.split(',').first,
    ];

    for (String variation in addressVariations) {
      try {
        List<geo.Location> locations = await geo
            .locationFromAddress(variation)
            .timeout(const Duration(seconds: 10));
        if (locations.isNotEmpty) {
          print('Successfully geocoded with variation: $variation');
          return locations;
        }
      } catch (e) {
        print('Failed geocoding with variation "$variation": $e');
        continue;
      }
    }
    return null;
  }

  Future<void> _setPropertyLocation(geo.Location location) async {
    if (_isValidIndonesianCoordinates(location.latitude, location.longitude)) {
      setState(() {
        propertyLocation = LatLng(location.latitude, location.longitude);
        markers = {
          Marker(
            markerId: const MarkerId('property_location'),
            position: LatLng(location.latitude, location.longitude),
            infoWindow: InfoWindow(
              title: widget.property.nameProperty,
              snippet: widget.property.addressProperty,
            ),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        };
        isLoadingLocation = false;
        locationError = null;
      });

      if (mapController != null) {
        await mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(location.latitude, location.longitude),
              zoom: 15.0,
            ),
          ),
        );
      }
    } else {
      _setDefaultLocation('Invalid coordinates received');
    }
  }

  bool _isValidIndonesianCoordinates(double lat, double lng) {
    return lat >= -11.0 && lat <= 6.0 && lng >= 95.0 && lng <= 141.0;
  }

  void _setDefaultLocation(String error) {
    setState(() {
      propertyLocation = const LatLng(-6.2088, 106.8456);
      markers = {
        Marker(
          markerId: const MarkerId('property_location_default'),
          position: const LatLng(-6.2088, 106.8456),
          infoWindow: InfoWindow(
            title: widget.property.nameProperty,
            snippet: widget.property.addressProperty ?? 'Location approximated',
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        ),
      };
      isLoadingLocation = false;
      locationError = error;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (propertyLocation != null) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: propertyLocation!,
            zoom: 15.0,
          ),
        ),
      );
    }
  }

  Future<void> _retryLocationGeocode() async {
    await _initializePropertyLocation();
  }

  Future<void> _initializeUserCurrency() async {
    try {
      setState(() => isLoadingCurrency = true);
      final currencyInfo = await LocationCurrencyService.getUserCurrencyInfo();
      setState(() {
        userCurrency = currencyInfo['currency'];
        userCountry = currencyInfo['country'];
        userLocation = currencyInfo['city'] ?? currencyInfo['region'] ?? '';
      });
      await _convertPrice();
    } catch (e) {
      print('Error initializing currency: $e');
      setState(() {
        userCurrency = 'IDR';
        userCountry = 'ID';
        convertedPrice = widget.property.price;
      });
    } finally {
      setState(() => isLoadingCurrency = false);
    }
  }

  Future<void> _convertPrice() async {
    if (widget.property.price != null && userCurrency != null) {
      try {
        final converted = await LocationCurrencyService.convertCurrency(
          widget.property.price!,
          'IDR',
          userCurrency!,
        );
        setState(() {
          convertedPrice = converted;
        });
      } catch (e) {
        print('Error converting price: $e');
        setState(() {
          convertedPrice = widget.property.price;
        });
      }
    }
  }

  Future<void> _refreshCurrency() async {
    LocationCurrencyService.clearCache();
    await _initializeUserCurrency();
  }

  String _formatPrice() {
    if (isLoadingCurrency) {
      return 'Loading price...';
    }
    if (convertedPrice == null || userCurrency == null) {
      return '${widget.property.price?.toStringAsFixed(0) ?? '0'}/bulan';
    }

    return '${LocationCurrencyService.formatCurrency(convertedPrice!, userCurrency!)}/bulan';
  }

  Widget _buildCurrencyInfo() {
    if (isLoadingCurrency) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const SizedBox(
          width: 60,
          height: 16,
          child: LinearProgressIndicator(
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: () {
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 2),
            Text(
              userCurrency ?? 'IDR',
              style: AppTheme.contentStyle(
                size: 10,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationErrorBanner() {
    if (locationError == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_outlined,
              color: Colors.orange.shade600, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$locationError. Menampilkan lokasi perkiraan.',
              style: AppTheme.contentStyle(
                size: 12,
                color: Colors.orange.shade800,
              ),
            ),
          ),
          GestureDetector(
            onTap: _retryLocationGeocode,
            child: Icon(Icons.refresh, color: Colors.orange.shade600, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Lokasi', style: AppTheme.headingStyle(size: 16)),
            const Spacer(),
            if (propertyLocation != null)
              TextButton.icon(
                onPressed: () {
                  _showFullScreenMap();
                },
                icon: const Icon(Icons.fullscreen, size: 16),
                label: const Text('View larger map'),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        _buildLocationErrorBanner(),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade300,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: isLoadingLocation
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text('Mencari lokasi...'),
                      ],
                    ),
                  )
                : propertyLocation != null
                    ? GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: propertyLocation!,
                          zoom: 15.0,
                        ),
                        markers: markers,
                        mapType: MapType.normal,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        scrollGesturesEnabled: true,
                        zoomGesturesEnabled: true,
                        rotateGesturesEnabled: true,
                        tiltGesturesEnabled: true,
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_off,
                                color: Colors.blue,
                                size: 40,
                              ),
                              SizedBox(height: 8),
                              Text('Lokasi tidak tersedia'),
                            ],
                          ),
                        ),
                      ),
          ),
        ),
      ],
    );
  }

  void _showFullScreenMap() {
    if (propertyLocation == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(widget.property.nameProperty),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 1,
          ),
          body: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: propertyLocation!,
              zoom: 15.0,
            ),
            markers: markers,
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
          ),
        ),
      ),
    );
  }

  Future<void> _fetchFacility() async {
    try {
      final snapshot = await _facilities
          .where('idProperty', isEqualTo: widget.property.id)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          facility = Facility.fromJson(snapshot.docs.first.id,
              snapshot.docs.first.data() as Map<String, dynamic>);
        });
      }
    } catch (e) {
      print('Error fetching facility: $e');
    }
  }

  // PERBAIKAN: Mengambil data imageRoom dari Firestore bukan Realtime Database
  Future<void> _fetchRoomImages() async {
    if (widget.property.idRoom == null) {
      setState(() {
        isLoadingRoomImages = false;
        roomImages = [];
      });
      return;
    }

    try {
      setState(() {
        isLoadingRoomImages = true;
      });

      print('Fetching room images for idRoom: ${widget.property.idRoom}');

      final snapshot = await _rooms.doc(widget.property.idRoom!).get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        print('Room data found: $data');

        // Mengambil imageRoom dari data Firestore
        final imageRoomData = data['imageRoom'];
        List<String> images = [];

        if (imageRoomData != null) {
          if (imageRoomData is List) {
            // Jika imageRoom adalah List
            images = List<String>.from(imageRoomData);
          } else if (imageRoomData is Map) {
            // Jika imageRoom adalah Map (seperti yang terlihat di gambar)
            images = imageRoomData.values.cast<String>().toList();
          }
        }

        setState(() {
          roomImages = images;
          isLoadingRoomImages = false;
        });

        print('Found ${images.length} room images');
      } else {
        print('Room document not found for ID: ${widget.property.idRoom}');
        setState(() {
          roomImages = [];
          isLoadingRoomImages = false;
        });
      }
    } catch (e) {
      print('Error fetching room images: $e');
      setState(() {
        roomImages = [];
        isLoadingRoomImages = false;
      });
    }
  }

  void _handleBooking() {
    if (FirebaseAuth.instance.currentUser != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingScreen(property: widget.property),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Diperlukan'),
          content: const Text(
              'Anda harus login terlebih dahulu untuk melakukan pemesanan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('Login'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Image.network(
                        widget.property.urlimageProperty ??
                            'https://via.placeholder.com/300',
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(
                          'assets/images/default_property.png',
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 50,
                        left: 16,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_back),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 50,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.favorite_border),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.property.nameProperty,
                          style: AppTheme.headingStyle(size: 20),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.blue,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.property.addressProperty ??
                                    'Unknown Location',
                                style: AppTheme.contentStyle(
                                  size: 12,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.property.rating?.toStringAsFixed(1) ??
                                  'N/A',
                              style: AppTheme.contentStyle(size: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _formatPrice(),
                                style: AppTheme.contentStyle(size: 14),
                              ),
                            ),
                            _buildCurrencyInfo(),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Tersedia',
                                style: AppTheme.contentStyle(
                                  size: 10,
                                  color: Colors.green.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Fasilitas',
                          style: AppTheme.headingStyle(size: 16),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            FacilityItem(
                              icon: Icons.wifi,
                              label: facility?.freeWifi == true
                                  ? 'Free WiFi'
                                  : 'No WiFi',
                            ),
                            FacilityItem(
                              icon: Icons.elevator,
                              label: facility?.elevator == true
                                  ? 'Elevator'
                                  : 'No Elevator',
                            ),
                            FacilityItem(
                              icon: Icons.local_parking,
                              label: facility?.parkingArea == 'Yes'
                                  ? 'Parking'
                                  : 'No Parking',
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text('Galeri', style: AppTheme.headingStyle(size: 16)),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 80,
                          child: isLoadingRoomImages
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : (roomImages == null || roomImages!.isEmpty)
                                  ? Center(
                                      child: Text(
                                        'No images available',
                                        style: AppTheme.contentStyle(
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: roomImages!.length,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          width: 80,
                                          height: 80,
                                          margin:
                                              const EdgeInsets.only(right: 8),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.network(
                                              roomImages![index],
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Container(
                                                  color: Colors.grey.shade200,
                                                  child: const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                            strokeWidth: 2),
                                                  ),
                                                );
                                              },
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Container(
                                                color: Colors.grey.shade200,
                                                child: const Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Deskripsi',
                          style: AppTheme.headingStyle(size: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.property.description ??
                              'No description available',
                          style: AppTheme.contentStyle(size: 14),
                        ),
                        const SizedBox(height: 24),
                        _buildMapSection(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoadingCurrency ? null : _handleBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  isLoadingCurrency ? 'Loading...' : 'Pesan Sekarang',
                  style: AppTheme.headingStyle(size: 16, color: Colors.black),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
