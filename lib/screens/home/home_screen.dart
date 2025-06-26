import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:flutter_application_1/utils/app_theme.dart';
import 'package:flutter_application_1/utils/firebase_data.dart';
import 'package:flutter_application_1/screens/Location/location_screen.dart';
import 'package:flutter_application_1/screens/Property/property_detail_screen.dart';
import 'package:flutter_application_1/screens/Article/article_detail_screen.dart';
import 'package:flutter_application_1/screens/Location/location_card.dart';
import 'package:flutter_application_1/screens/Promo/promo_card.dart';
import 'package:flutter_application_1/screens/Property/property_card.dart';
import 'package:flutter_application_1/screens/Article/article_card.dart';
import 'package:flutter_application_1/utils/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Country> countries = [];
  List<Location> locations = [];
  List<Property> properties = [];
  List<Promo> promos = [];
  List<Article> articles = [];
  String? selectedCountryId;
  bool isLoading = true;
  bool isLocationLoading = true;
  Position? userPosition;
  String? userLocationName;
  String? locationError;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      _fetchUserLocation(),
      _fetchData(),
    ]);
  }

  Future<void> _fetchUserLocation() async {
    setState(() {
      isLocationLoading = true;
      locationError = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          locationError =
              'Location services are disabled. Please enable location services.';
          isLocationLoading = false;
        });
        _showLocationServiceDialog();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            locationError = 'Location permissions are denied.';
            isLocationLoading = false;
          });
          _showLocationPermissionDialog();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          locationError = 'Location permissions are permanently denied.';
          isLocationLoading = false;
        });
        _showLocationPermissionPermanentDialog();
        return;
      }

      userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
        timeLimit: const Duration(seconds: 15),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () async {
          return await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
            timeLimit: const Duration(seconds: 5),
          );
        },
      );

      await _getUserLocationName();

      setState(() {
        isLocationLoading = false;
      });
    } catch (e) {
      setState(() {
        locationError = 'Failed to get location: ${e.toString()}';
        isLocationLoading = false;
      });
      print('Location fetch error: $e');
    }
  }

  Future<void> _getUserLocationName() async {
    if (userPosition == null) return;

    try {
      List<geocoding.Placemark> placemarks =
          await geocoding.placemarkFromCoordinates(
        userPosition!.latitude,
        userPosition!.longitude,
      );

      if (placemarks.isNotEmpty) {
        geocoding.Placemark place = placemarks[0];
        setState(() {
          userLocationName =
              '${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}';
        });
      }
    } catch (e) {
      print('Error getting location name: $e');
    }
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Service Disabled'),
          content: const Text(
              'Location services are disabled. Please enable location services to get personalized content based on your location.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Continue Without Location'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openLocationSettings();
                Future.delayed(const Duration(seconds: 2), () {
                  _fetchUserLocation();
                });
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text(
              'This app needs location permission to show you nearby properties and locations. Please grant location permission.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Continue Without Location'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _fetchUserLocation();
              },
              child: const Text('Grant Permission'),
            ),
          ],
        );
      },
    );
  }

  void _showLocationPermissionPermanentDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Denied'),
          content: const Text(
              'Location permissions are permanently denied. Please enable location permission in app settings to get personalized content.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Continue Without Location'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openAppSettings();
              },
              child: const Text('Open App Settings'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      await Future.wait([
        _firestore.collection('countries').get().then((querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            countries = querySnapshot.docs
                .map((doc) => Country.fromJson(doc.id, doc.data()))
                .toList();
          }
        }),
        _firestore.collection('locations').get().then((querySnapshot) async {
          if (querySnapshot.docs.isNotEmpty) {
            locations = querySnapshot.docs
                .map((doc) => Location.fromJson(doc.id, doc.data()))
                .toList();

            await _geocodeLocations();
          }
        }),
        _firestore.collection('properties').get().then((querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            properties = querySnapshot.docs
                .map((doc) => Property.fromJson(doc.id, doc.data()))
                .toList();
          }
        }),
        _firestore.collection('promos').get().then((querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            promos = querySnapshot.docs
                .map((doc) => Promo.fromJson(doc.id, doc.data()))
                .toList();
          }
        }),
        _firestore.collection('articles').get().then((querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            articles = querySnapshot.docs
                .map((doc) => Article.fromJson(doc.id, doc.data()))
                .toList();
          }
        }),
      ]);
    } catch (e) {
      print('Error fetching data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _geocodeLocations() async {
    List<Future<void>> geocodingTasks = [];

    for (var location in locations) {
      if (location.latitude == null || location.longitude == null) {
        geocodingTasks.add(_geocodeLocation(location));
      }
    }

    if (geocodingTasks.isNotEmpty) {
      await Future.wait(geocodingTasks);
    }
  }

  Future<void> _geocodeLocation(Location location) async {
    try {
      List<geocoding.Location> geoLocations =
          await geocoding.locationFromAddress(location.nameCity);
      if (geoLocations.isNotEmpty) {
        location.latitude = geoLocations.first.latitude;
        location.longitude = geoLocations.first.longitude;

        await _firestore.collection('locations').doc(location.id).update({
          'latitude': location.latitude,
          'longitude': location.longitude,
        });
      }
    } catch (e) {
      print('Error geocoding ${location.nameCity}: $e');
    }
  }

  List<Location> _sortLocationsByDistance(List<Location> locations) {
    if (userPosition == null) return locations;

    List<Location> validLocations = locations
        .where((loc) => loc.latitude != null && loc.longitude != null)
        .toList();

    validLocations.sort((a, b) {
      double distanceA = Geolocator.distanceBetween(
        userPosition!.latitude,
        userPosition!.longitude,
        a.latitude!,
        a.longitude!,
      );
      double distanceB = Geolocator.distanceBetween(
        userPosition!.latitude,
        userPosition!.longitude,
        b.latitude!,
        b.longitude!,
      );
      return distanceA.compareTo(distanceB);
    });

    validLocations.addAll(locations
        .where((loc) => loc.latitude == null || loc.longitude == null));
    return validLocations;
  }

  Location? _getNearestLocation(List<Location> locations) {
    if (locations.isEmpty || userPosition == null) return null;

    List<Location> validLocations = locations
        .where((loc) => loc.latitude != null && loc.longitude != null)
        .toList();
    if (validLocations.isEmpty) return null;

    return validLocations.reduce((a, b) {
      double distanceA = Geolocator.distanceBetween(
        userPosition!.latitude,
        userPosition!.longitude,
        a.latitude!,
        a.longitude!,
      );
      double distanceB = Geolocator.distanceBetween(
        userPosition!.latitude,
        userPosition!.longitude,
        b.latitude!,
        b.longitude!,
      );
      return distanceA <= distanceB ? a : b;
    });
  }

  String _getDistanceText(Location location) {
    if (userPosition == null ||
        location.latitude == null ||
        location.longitude == null) {
      return '';
    }

    double distance = Geolocator.distanceBetween(
      userPosition!.latitude,
      userPosition!.longitude,
      location.latitude!,
      location.longitude!,
    );

    if (distance < 1000) {
      return '${distance.round()}m away';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km away';
    }
  }

  Widget _buildLocationStatus() {
    if (isLocationLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Getting your location...'),
          ],
        ),
      );
    }

    if (locationError != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.location_off, color: Colors.orange.shade700, size: 16),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Location unavailable - showing all locations',
                style: TextStyle(color: Colors.orange.shade700, fontSize: 12),
              ),
            ),
            TextButton(
              onPressed: _fetchUserLocation,
              child: const Text('Retry', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      );
    }

    if (userLocationName != null) {
      }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    final l10n = AppLocalizations.of(context);

    if (isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Loading...',
                style: AppTheme.contentStyle(size: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final filteredLocations = selectedCountryId == null
        ? _sortLocationsByDistance(locations)
        : _sortLocationsByDistance(locations
            .where((location) => location.idCountry == selectedCountryId)
            .toList());

    final nearestLocation = _getNearestLocation(filteredLocations);
    final filteredProperties = nearestLocation == null
        ? []
        : properties
            .where((property) => property.idLocation == nearestLocation.id)
            .toList();

    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).padding.top + 250,
                      color: Colors.white,
                    ),
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).padding.top + 180,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFC107),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(45),
                          bottomRight: Radius.circular(45),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).padding.top + 80,
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 16,
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Image.asset(
                                  'assets/images/cropped-Logo-US-Header-1 1.png',
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              'assets/images/Group 3.png',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          width: double.infinity,
                          height: 150,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            image: const DecorationImage(
                              image: AssetImage(
                                  'assets/images/Frame 1000001269.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildLocationStatus(),
                    const SizedBox(height: 20),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      color: Colors.white,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 110,
                            child: filteredLocations.isEmpty
                                ? Center(
                                    child: Text(
                                      l10n.translate('No locations available'),
                                      style: AppTheme.contentStyle(
                                          size: 14, color: Colors.grey),
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: filteredLocations.length,
                                    itemBuilder: (context, index) {
                                      final location = filteredLocations[index];
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 12),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    LocationScreen(
                                                        location: location),
                                              ),
                                            );
                                          },
                                          child: Stack(
                                            children: [
                                              LocationCard(location: location),
                                              if (userPosition != null &&
                                                  index == 0)
                                                Positioned(
                                                  top: 8,
                                                  right: 8,
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Text(
                                                    l10n.translate('jarak'),
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      color: Colors.white,
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nearestLocation != null
                                          ? l10n
                                              .translate('Properties_nearest')
                                          : l10n
                                              .translate('frequently_visited'),
                                      style: AppTheme.headingStyle(size: 16),
                                    ),
                                    Text(
                                      nearestLocation != null
                                          ? ' ${nearestLocation.nameCity}'
                                          : l10n.translate('maximize_business'),
                                      style: AppTheme.contentStyle(
                                          size: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 240,
                            child: filteredProperties.isEmpty
                                ? Center(
                                    child: Text(
                                      nearestLocation != null
                                          ? 'No properties available in ${nearestLocation.nameCity}'
                                          : l10n.translate(
                                              'No properties available'),
                                      style: AppTheme.contentStyle(
                                          size: 14, color: Colors.grey),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: filteredProperties.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 12),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PropertyDetailScreen(
                                                        property:
                                                            filteredProperties[
                                                                index]),
                                              ),
                                            );
                                          },
                                          child: PropertyCard(
                                              property:
                                                  filteredProperties[index]),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.translate('promo'),
                                      style: AppTheme.headingStyle(size: 18),
                                    ),
                                    Text(
                                      l10n.translate('promo_subtitle'),
                                      style: AppTheme.contentStyle(
                                          size: 14, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                Text(
                                  l10n.translate('View All'),
                                  style: AppTheme.contentStyle(
                                      size: 14, color: Colors.amber),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                          SizedBox(
                            height: 150,
                            child: promos.isEmpty
                                ? Center(
                                    child: Text(
                                      l10n.translate('No promos available'),
                                      style: AppTheme.contentStyle(
                                          size: 14, color: Colors.grey),
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: promos.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 12),
                                        child: PromoCard(promo: promos[index]),
                                      );
                                    },
                                  ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      color: Colors.white,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.translate('articles'),
                                      style: AppTheme.headingStyle(size: 18),
                                    ),
                                    Text(
                                      l10n.translate('articles_subtitle'),
                                      style: AppTheme.contentStyle(
                                          size: 14, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                Text(
                                  l10n.translate('View All'),
                                  style: AppTheme.contentStyle(
                                      size: 14, color: Colors.amber),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                          SizedBox(
                            height: 250,
                            child: articles.isEmpty
                                ? Center(
                                    child: Text(
                                      l10n.translate('No articles available'),
                                      style: AppTheme.contentStyle(
                                          size: 14, color: Colors.grey),
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: articles.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 12),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ArticleDetailScreen(
                                                        article:
                                                            articles[index]),
                                              ),
                                            );
                                          },
                                          child: ArticleCard(
                                              article: articles[index]),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
