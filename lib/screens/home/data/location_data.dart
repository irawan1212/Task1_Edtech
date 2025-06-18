class Location {
  final int id;
  final String name;
  final String imageUrl;
  final String? nameKey; // Key untuk translate

  Location({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.nameKey,
  });

  String getLocalizedName(Function translate) {
    return nameKey != null ? translate(nameKey!) : name;
  }
}

final List<Location> locationPages = [
  Location(
    id: 1,
    name: 'Terdekat',
    nameKey: 'location_terdekat', // Key untuk translate
    imageUrl: 'assets/images/Send.png',
  ),
  Location(
    id: 2,
    name: 'Yogyakarta',
    nameKey: 'location_yogyakarta',
    imageUrl: 'assets/images/monas-jakarta-batiqa-hotels-horizontal_q1ba0.jpg',
  ),
  Location(
    id: 3,
    name: 'Bali',
    nameKey: 'location_bali',
    imageUrl: 'assets/images/monas-jakarta-batiqa-hotels-horizontal_q1ba0.jpg',
  ),
  Location(
    id: 4,
    name: 'Semarang',
    nameKey: 'location_semarang',
    imageUrl: 'assets/images/monas-jakarta-batiqa-hotels-horizontal_q1ba0.jpg',
  ),
  Location(
    id: 5,
    name: 'Medan',
    nameKey: 'location_medan',
    imageUrl: 'assets/images/monas-jakarta-batiqa-hotels-horizontal_q1ba0.jpg',
  ),
  Location(
    id: 6,
    name: 'Kalimantan',
    nameKey: 'location_kalimantan',
    imageUrl: 'assets/images/monas-jakarta-batiqa-hotels-horizontal_q1ba0.jpg',
  ),
];
