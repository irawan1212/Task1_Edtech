import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/home/data/promo_data.dart';

class PromoCard extends StatelessWidget {
  final PromoData promo;

  const PromoCard({super.key, required this.promo});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        promo.image,
        width: 280, 
        height: 120,
        fit: BoxFit.cover,
      ),
    );
  }
}
