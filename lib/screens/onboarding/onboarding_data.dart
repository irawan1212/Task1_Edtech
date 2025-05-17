

class OnboardingData {
  final String image;
  final String title;
  final String subtitle;

  OnboardingData({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}

final List<OnboardingData> onboardingPages = [
  OnboardingData(
    image: 'assets/images/image 1.png',
    title: 'Mulai Hari Produktifmu Sekarang!',
    subtitle:
        'Temukan tempat kerja langsung mengakses, pengaruh untuk masa keberhasilan. Define and design space sekarang',
  ),
  OnboardingData(
    image: 'assets/images/image 6.png',
    title: 'Ruangmu. Gayamu. Bisnismu.',
    subtitle:
        'Menawarkan fleksibilitas dan personalisasi yang disesuaikan oleh UnionSpace',
  ),
  OnboardingData(
    image: 'assets/images/image 7.png',
    title: 'Terhubung. Berkembang. Bersama',
    subtitle:
        'Memiliki rangkaian keuntungan dan pertumbuhan kolaborasi profesional di Indonesia',
  ),
];
