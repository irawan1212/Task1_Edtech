// location_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/utils/app_theme.dart';
import 'package:flutter_application_1/utils/firebase_data.dart';
import 'package:flutter_application_1/screens/Property/property_detail_screen.dart';
import 'package:flutter_application_1/screens/Property/property_grid_item.dart';
import 'package:flutter_application_1/utils/app_localizations.dart';

class LocationScreen extends StatefulWidget {
  final Location location;

  const LocationScreen({super.key, required this.location});

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Property> properties = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    print('LocationScreen initState: ID Lokasi = ${widget.location.id}');
    _fetchProperties();
  }

  Future<void> _fetchProperties() async {
    try {
      print('Fetching properties for idLocation: ${widget.location.id}');

      final QuerySnapshot querySnapshot = await _firestore
          .collection('properties')
          .where('idLocation', isEqualTo: widget.location.id)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        print('Found ${querySnapshot.docs.length} properties');
        final List<Property> fetchedProperties = querySnapshot.docs
            .map((doc) {
              try {
                final data = doc.data() as Map<String, dynamic>;
                return Property.fromJson(doc.id, data);
              } catch (e) {
                print('Error parsing property ${doc.id}: $e');
                return null;
              }
            })
            .where((property) => property != null)
            .cast<Property>()
            .toList();

        setState(() {
          properties = fetchedProperties;
          isLoading = false;
          print('Properties fetched: ${properties.length}');
        });
      } else {
        print('No properties found for idLocation: ${widget.location.id}');
        setState(() {
          isLoading = false;
          errorMessage = 'No properties available for this location.';
        });
      }
    } catch (e, stackTrace) {
      print('Error fetching properties: $e\n$stackTrace');
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load properties. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.location.nameCity,
          style: AppTheme.headingStyle(size: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        errorMessage!,
                        style:
                            AppTheme.contentStyle(size: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                            errorMessage = null;
                          });
                          _fetchProperties();
                        },
                        child: Text(l10n.translate('Retry')),
                      ),
                    ],
                  ),
                )
              : properties.isEmpty
                  ? Center(
                      child: Text(
                        l10n.translate('No properties available'),
                        style:
                            AppTheme.contentStyle(size: 14, color: Colors.grey),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: properties.length,
                      itemBuilder: (context, index) {
                        final property = properties[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PropertyDetailScreen(property: property),
                              ),
                            );
                          },
                          child: PropertyGridItem(property: property),
                        );
                      },
                    ),
    );
  }
}
