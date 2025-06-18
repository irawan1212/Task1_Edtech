class PromoData {
  final String image;
  final String title;

  PromoData({
    required this.image,
    required this.title,
  });
}

final List<PromoData> promoPages = [
  PromoData(
    image: 'assets/images/bannerpromo.png',
    title: 'Promo 1',
  ),
  PromoData(
    image: 'assets/images/bannerpromo.png',
    title: 'Promo 2',
  ),
  PromoData(
    image: 'assets/images/bannerpromo.png',
    title: 'Promo 3',
  ),
];
