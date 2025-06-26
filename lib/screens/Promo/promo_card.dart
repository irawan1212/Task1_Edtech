// promo_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/firebase_data.dart';
import 'package:flutter_application_1/utils/app_theme.dart';
import 'package:flutter_application_1/utils/app_localizations.dart';

class PromoCard extends StatelessWidget {
  final Promo promo;

  const PromoCard({super.key, required this.promo});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 280,
        height: 300,
        child: Stack(
          children: [
            // Image container with fixed dimensions
            SizedBox(
              width: 280,
              height: 300,
              child: promo.urlimagePromo?.isNotEmpty == true
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        promo.urlimagePromo!,
                        width: 280,
                        height: 120,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 280,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 280,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.local_offer,
                              color: AppTheme.primaryColor,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      width: 280,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.primaryColor,
                            Colors.amber.shade700,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.local_offer,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
