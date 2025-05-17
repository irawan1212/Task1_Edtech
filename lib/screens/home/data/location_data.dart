class Location {
  final int id;
  final String name;
  final String imageUrl;

  Location({
    required this.id,
    required this.name,
    required this.imageUrl,
  });
}

final List<Location> locationPages = [
  Location(
    id: 1,
    name: 'Terdekat',
    imageUrl: 'assets/images/Send.png',
  ),
  Location(
    id: 2,
    name: 'Yogyakarta',
    imageUrl: 'assets/images/monas-jakarta-batiqa-hotels-horizontal_q1ba0.jpg',
  ),
  Location(
    id: 3,
    name: 'Bali',
    imageUrl: 'assets/images/monas-jakarta-batiqa-hotels-horizontal_q1ba0.jpg',
  ),
  Location(
    id: 4,
    name: 'Semarang',
    imageUrl: 'assets/images/monas-jakarta-batiqa-hotels-horizontal_q1ba0.jpg',
  ),
  Location(
    id: 5,
    name: 'Medan',
    imageUrl: 'assets/images/monas-jakarta-batiqa-hotels-horizontal_q1ba0.jpg',
  ),
  Location(
    id: 6,
    name: 'Kalimantan',
    imageUrl: 'assets/images/monas-jakarta-batiqa-hotels-horizontal_q1ba0.jpg',
  ),
];
