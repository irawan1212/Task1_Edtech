

class Article {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String date;
  final String author;
  final String content;

  const Article({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.date,
    required this.author,
    required this.content,
  });
}

final List<Article> articlePages = [
  const Article(
    id: '1',
    title: 'Tips Memilih Hotel Yang Nyaman',
    description: 'Temukan rahasia memilih hotel yang tepat untuk liburan Anda',
    imageUrl: 'assets/images/images.png',
    date: '12 Mei 2025',
    author: 'Amanda Putri',
    content:
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam euismod, nibh a congue tempus, quam nunc eleifend nisl, vitae lacinia arcu nisi id mi. Nulla facilisi. Donec auctor, nisl ac ultricies faucibus, orci elit volutpat libero, in bibendum nisl lectus id magna.',
  ),
  const Article(
    id: '2',
    title: 'Destinasi Wisata Terbaik 2025',
    description: 'Jelajahi tempat-tempat wisata terbaik tahun ini',
    imageUrl: 'assets/images/images.png',
    date: '5 Mei 2025',
    author: 'Budi Santoso',
    content:
        'Phasellus ac nisi at nisl dignissim efficitur ut a elit. Nunc volutpat, lacus vel hendrerit convallis, dui risus tincidunt purus, quis condimentum felis nulla vel dui. Proin ac magna euismod, fermentum nisi id, imperdiet dui.',
  ),
  const Article(
    id: '3',
    title: 'Cara Hemat Liburan Ke Bali',
    description: 'Panduan lengkap liburan ke Bali dengan budget terbatas',
    imageUrl: 'assets/images/images.png',
    date: '28 April 2025',
    author: 'Citra Dewi',
    content:
        'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Praesent eget tortor eu dui aliquam pellentesque. Proin dictum erat vel tortor eleifend, at dictum magna faucibus. Nulla facilisi.',
  ),
  const Article(
    id: '4',
    title: 'Kuliner Wajib Coba di Yogyakarta',
    description: 'Daftar makanan lezat yang harus dicoba saat ke Yogyakarta',
    imageUrl: 'assets/images/images.png',
    date: '20 April 2025',
    author: 'Denny Mahendra',
    content:
        'Fusce vulputate, nibh non pretium varius, ligula nisl feugiat arcu, sit amet ultrices mi augue at est. Donec et ultricies orci. Cras rhoncus purus in mauris facilisis volutpat. Etiam blandit lacus vel risus varius, in vehicula nibh finibus.',
  ),
];
