import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/app_theme.dart';
import 'package:flutter_application_1/screens/home/data/location_data.dart';
import 'package:flutter_application_1/screens/home/data/property_data.dart';
import 'package:flutter_application_1/screens/home/widgets/property_detail_screen.dart';
import 'package:flutter_application_1/screens/home/widgets/property_grid_item.dart';
import 'package:flutter_application_1/utils/app_localizations.dart'; // Tambahkan import ini

class LocationScreen extends StatelessWidget {
  final Location location;

  const LocationScreen({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    final l10n =
        AppLocalizations.of(context); // Tambahkan ini untuk akses translate

    final properties = propertyPages
        .where((property) => property.locationId == location.id)
        .toList();
    final displayProperties =
        properties.isNotEmpty ? properties : propertyPages;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          location
              .name, // Atau bisa gunakan l10n.translate jika nama lokasi juga perlu diterjemahkan
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
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: displayProperties.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PropertyDetailScreen(
                    property: displayProperties[index],
                  ),
                ),
              );
            },
            child: PropertyGridItem(property: displayProperties[index]),
          );
        },
      ),
    );
  }
}
