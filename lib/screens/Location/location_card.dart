import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/app_theme.dart';
import 'package:flutter_application_1/utils/firebase_data.dart';
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
                child: Image.network(
                  location.urlimageCity?.isNotEmpty == true
                      ? location.urlimageCity!
                      : 'https://via.placeholder.com/70',
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 30,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          location.nameCity.isNotEmpty ? location.nameCity : 'Unknown City',
          style: AppTheme.headingStyle(size: 14),
        ),
      ],
    );
  }
}
