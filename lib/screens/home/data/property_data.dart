class Property {
  final String? id; // Optional
  final String name;
  final String location;
  final String description;
  final String imageUrl;
  final String price;
  final double? rating; 
  final String? locationId; 

  Property({
    this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.rating,
    this.locationId,
  });
}

final List<Property> propertyPages = [
  Property(
    
    name: 'Modern Loft',
    location: 'Downtown',
    imageUrl: 'assets/images/Gedung-Tertinggi-di-Asia-Tenggara-1024x688.jpg',
    price: '\$1200/month',
    rating: 4.5,
    description: 'A beautiful loft in the heart of the city.',
  ),
  Property(
    name: 'Luxury Condo',
    location: 'Uptown',
    imageUrl: 'assets/images/Gedung-Tertinggi-di-Asia-Tenggara-1024x688.jpg',
    price: '\$2500/month',
    rating: 4.8,
    description: 'Spacious condo with all modern amenities.',
  ),
  Property(
    name: 'Cozy Apartment',
    location: 'Suburbs',
    imageUrl: 'assets/images/Gedung-Tertinggi-di-Asia-Tenggara-1024x688.jpg',
    price: '\$800/month',
    rating: 4.2,
    description: 'Affordable and comfortable apartment unit.',
  ),
];
