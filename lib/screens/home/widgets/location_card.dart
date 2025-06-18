import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/app_theme.dart';
import 'package:flutter_application_1/screens/home/data/location_data.dart';
import 'package:flutter_application_1/utils/app_localizations.dart';

class LocationCard extends StatelessWidget {
  final Location location;

  const LocationCard({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        SizedBox(
          width: 70,
          height: 70,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(35),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: location.id == 1
                    ? Image.asset(
                        location.imageUrl,
                        width: 35,
                        height: 35,
                        fit: BoxFit.contain,
                        color: Colors.amber,
                      )
                    : Image.asset(
                        location.imageUrl,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          location.getLocalizedName(
              l10n.translate), // Menggunakan method untuk translate
          style: AppTheme.headingStyle(size: 14),
        ),
      ],
    );
  }
}
