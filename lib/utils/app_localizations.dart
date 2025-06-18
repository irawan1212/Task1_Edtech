import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Map<String, String> _localizedStrings = {};

  Future<void> load() async {
    _localizedStrings = await _loadStrings(locale.languageCode);
  }

  Future<Map<String, String>> _loadStrings(String languageCode) async {
    switch (languageCode) {
      case 'id':
        return {
          // Existing keys...
          'frequently_visited': 'Paling Sering Dikunjungi',
          'maximize_business': 'Maksimalkan Bisnis Anda bersama Union Space',
          'promo': 'Promo',
          'Orders': 'Pesanan',
          'promo_subtitle': 'Kemudahan Dengan Promo',
          'articles': 'Artikel',
          'view_all': 'Lihat Semua',
          'start_now': 'Mulai Sekarang',
          'next': 'Selanjutnya',
          'profile': 'Profil',
          'manage_account': 'Kelola Akun Anda',
          'language': 'Bahasa',
          'contact': 'Hubungi Kami',
          'Isi_privacy_policy2': 'Informasi Anda',
          'Isi_privacy_policy1':
              'kami dapat mengumpulkan informasi pribadi seperti nama, alamat email, nomor telepon, dan detail pembayaran saat Anda mendaftar akun atau melakukan pemesanan.',
          'Isi_privacy_policy':'Di Unionspace, kami berkomitmen untuk melindungi privasi Anda. Kebijakan Privasi ini menjelaskan bagaimana kami mengumpulkan, menggunakan, mengungkapkan, dan melindungi informasi Anda saat Anda menggunakan layanan kami.',
          'privacy_policy': 'Kebijakan Privasi',
          'terms_conditions': 'Syarat & Ketentuan',
          'logout': 'Keluar',
          'delete_account': 'Hapus Akun',
          'language_indonesian': 'Bahasa Indonesia',
          'language_english': 'English',
          'home': 'Beranda',
          'about': 'Tentang UnionSpace',
          'contact_us': 'Hubungi Kami',
          'contact_unionspace':'Kontak UnionSpace',
          'kalimat_tentang_aplikasi':
              'UnionSpace adalah virtual office premium, ruang pertemuan yang nyaman, ruang kantor pribadi, serta area event serbaguna yang bisa menunjang segala aktivitas bisnis anda.',
          'about profile': 'Tentang UnionSpace',
          'Manage': 'Pengaturan Akun',
          'promos': 'Promo',
          'account': 'Akun',

          'location_terdekat': 'Terdekat',
          'location_yogyakarta': 'Yogyakarta',
          'location_bali': 'Bali',
          'location_semarang': 'Semarang',
          'location_medan': 'Medan',
          'location_kalimantan': 'Kalimantan',

          'back': 'Kembali',
          'favorite': 'Favorit',
          'search': 'Cari',
          'filter': 'Filter',
          'sort': 'Urutkan',
          'no_data': 'Tidak ada data',
          'loading': 'Memuat...',
          'error': 'Terjadi kesalahan',
          'try_again': 'Coba Lagi',
          'Email': 'Alamat Surel',
          'Phone': 'Telepon',
          'Address': 'Alamat',
          // Onboarding specific keys
          'onboarding_title_1': 'Mulai Hari Produktifmu Sekarang!',
          'onboarding_subtitle_1':
              'Temukan tempat kerja langsung mengakses, pengaruh untuk masa keberhasilan. Define and design space sekarang',
          'onboarding_title_2': 'Ruangmu. Gayamu. Bisnismu.',
          'onboarding_subtitle_2':
              'Menawarkan fleksibilitas dan personalisasi yang disesuaikan oleh UnionSpace',
          'onboarding_title_3': 'Terhubung. Berkembang. Bersama',
          'onboarding_subtitle_3':
              'Memiliki rangkaian keuntungan dan pertumbuhan kolaborasi profesional di Indonesia',

          // Dynamic keys for data
          'location_title_{id}': '{title_id}',
          'property_title_{id}': '{title_id}',
          'promo_title_{id}': '{title_id}',
          'article_title_{id}': '{title_id}',
          'onboarding_title_{id}': '{title_id}',
          'onboarding_description_{id}': '{description_id}',
        };
      case 'en':
        return {
          // Existing keys...
          'frequently_visited': 'Most Frequently Visited',
          'maximize_business': 'Maximize Your Business with Union Space',
          'promo': 'Promo',
          'promo_subtitle': 'Convenience with Promos',
          'articles': 'Articles',
          'view_all': 'View All',
          'start_now': 'Start Now',
          'next': 'Next',
          'profile': 'Profile',
          'manage_account': 'Manage Your Account',
          'language': 'Language',
          'contact': 'Contact Us',
          'kalimat_tentang_aplikasi':
              'UnionSpace is a premium virtual office, with comfortable meeting rooms, private office spaces, and versatile event areas that support all your business activities.',
          'contact_unionspace': 'Contact UnionSpace',
          'about profile': 'About UnionSpace',
          'about': 'About UnionSpace',
          'Email': 'Email',
          'Phone': 'Phone',
          'Address': 'Address',
          'Isi_privacy_policy2':'Your Information',
          'Isi_privacy_policy1':'we may collect personal information such as your name, email address, phone number, and payment details when you register for an account or make a booking.',
          'Isi_privacy_policy':
              'At UnionSpace, we are committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and protect your information when you use our services.',
          'privacy_policy': 'Privacy Policy',
          'terms_conditions': 'Terms & Conditions',
          'logout': 'Log Out',
          'delete_account': 'Delete Account',
          'language_indonesian': 'Indonesian',
          'language_english': 'English',
          'home': 'Home',
          'contact_us': 'Contact Us',
          'Manage': 'Manage Account',
          'Orders': 'Orders',
          'promos': 'Promos',
          'account': 'Account',

          'location_terdekat': 'Nearest',
          'location_yogyakarta': 'Yogyakarta',
          'location_bali': 'Bali',
          'location_semarang': 'Semarang',
          'location_medan': 'Medan',
          'location_kalimantan': 'Kalimantan',

          'back': 'Back',
          'favorite': 'Favorite',
          'search': 'Search',
          'filter': 'Filter',
          'sort': 'Sort',
          'no_data': 'No data available',
          'loading': 'Loading...',
          'error': 'An error occurred',
          'try_again': 'Try Again',

          // Onboarding specific keys
          'onboarding_title_1': 'Start Your Productive Day Now!',
          'onboarding_subtitle_1':
              'Discover workspaces with direct access, influence for future success. Define and design your space now',
          'onboarding_title_2': 'Your Space. Your Style. Your Business.',
          'onboarding_subtitle_2':
              'Offering flexibility and personalization tailored by UnionSpace',
          'onboarding_title_3': 'Connected. Growing. Together',
          'onboarding_subtitle_3':
              'Have a range of benefits and professional collaboration growth in Indonesia',

          // Dynamic keys for data
          'location_title_{id}': '{title_en}',
          'property_title_{id}': '{title_en}',
          'promo_title_{id}': '{title_en}',
          'article_title_{id}': '{title_en}',
          'onboarding_title_{id}': '{title_en}',
          'onboarding_description_{id}': '{description_en}',
        };
      default:
        return {};
    }
  }

  String translate(String key, {Map<String, String> args = const {}}) {
    String value = _localizedStrings[key] ?? key;
    args.forEach((k, v) => value = value.replaceAll('{$k}', v));
    return value;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'id'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
