import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/firebase_data.dart';
import 'package:flutter_application_1/utils/app_theme.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  final double width;
  final double height;

  const PropertyCard({
    super.key,
    required this.property,
    this.width = 180,
    this.height = 230,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  property.urlimageProperty ??
                      'https://via.placeholder.com/180',
                  height: height,
                  width: width,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/default_property.png',
                    height: height,
                    width: width,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
               
                
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                    
                  ),
                  child: Text(
                    property.nameProperty,
                    style: AppTheme.headingStyle(color: Colors.white, size: 14,),
                    
                  ),
                  
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
