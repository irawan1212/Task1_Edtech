import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/app_theme.dart';

class FacilityItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const FacilityItem({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTheme.contentStyle(size: 12),
        ),
      ],
    );
  }
}
