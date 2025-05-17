class Property {
  final int id;
  final String name;
  final String location;
  final String imageUrl;
  final String price;
  final double rating;
  final int locationId;
  final String description;

  Property({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.price,
    required this.rating,
    required this.locationId,
    required this.description,
  });
}

final List<Property> propertyPages = [
  Property(
    id: 1,
    name: 'Modern Loft',
    location: 'Downtown',
    imageUrl: 'assets/images/Gedung-Tertinggi-di-Asia-Tenggara-1024x688.jpg',
    price: '\$1200/month',
    rating: 4.5,
    locationId: 101,
    description: 'A beautiful loft in the heart of the city.',
  ),
  Property(
    id: 2,
    name: 'Luxury Condo',
    location: 'Uptown',
    imageUrl: 'assets/images/Gedung-Tertinggi-di-Asia-Tenggara-1024x688.jpg',
    price: '\$2500/month',
    rating: 4.8,
    locationId: 102,
    description: 'Spacious condo with all modern amenities.',
  ),
  Property(
    id: 3,
    name: 'Cozy Apartment',
    location: 'Suburbs',
    imageUrl: 'assets/images/Gedung-Tertinggi-di-Asia-Tenggara-1024x688.jpg',
    price: '\$800/month',
    rating: 4.2,
    locationId: 103,
    description: 'Affordable and comfortable apartment unit.',
  ),
];
