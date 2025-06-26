// lib/utils/app_localizations.dart
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
          // Existing keys
          'orders_bottonNav':'Pesanan',
          'Properties_nearest':'Properti Terdekat',
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
          'Isi_privacy_policy':
              'Di Unionspace, kami berkomitmen untuk melindungi privasi Anda. Kebijakan Privasi ini menjelaskan bagaimana kami mengumpulkan, menggunakan, mengungkapkan, dan melindungi informasi Anda saat Anda menggunakan layanan kami.',
          'privacy_policy': 'Kebijakan Privasi',
          'terms_conditions': 'Syarat & Ketentuan',
          'logout': 'Keluar',
          'delete_account': 'Hapus Akun',
          'language_indonesian': 'Bahasa Indonesia',
          'language_english': 'English',
          'home': 'Beranda',
          'about': 'Tentang UnionSpace',
          'contact_us': 'Hubungi Kami',
          'contact_unionspace': 'Kontak UnionSpace',
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
          'onboarding_title_1': 'Mulai Hari Produktifmu Sekarang!',
          'onboarding_subtitle_1':
              'Temukan tempat kerja langsung mengakses, pengaruh untuk masa keberhasilan. Define and design space sekarang',
          'onboarding_title_2': 'Ruangmu. Gayamu. Bisnismu.',
          'onboarding_subtitle_2':
              'Menawarkan fleksibilitas dan personalisasi yang disesuaikan oleh UnionSpace',
          'onboarding_title_3': 'Terhubung. Berkembang. Bersama',
          'onboarding_subtitle_3':
              'Memiliki rangkaian keuntungan dan pertumbuhan kolaborasi profesional di Indonesia',
          'location_title_{id}': '{title_id}',
          'property_title_{id}': '{title_id}',
          'promo_title_{id}': '{title_id}',
          'article_title_{id}': '{title_id}',
          'onboarding_title_{id}': '{title_id}',
          'onboarding_description_{id}': '{description_id}',
          // New keys added
          'hours': '{count} Jam',
          'failed_to_save_order': 'Gagal menyimpan pesanan: {error}',
          'failed_to_load_orders': 'Gagal memuat pesanan: {error}',
          'failed_to_load_promos': 'Gagal memuat promo: {error}',
          'my_orders': 'Pesanan Saya',
          'no_orders': 'Belum ada pesanan',
          'active_booking': 'Booking Aktif',
          'reschedule': 'Ubah Jadwal',
          'view_details': 'Lihat Detail',
          'reschedule_not_implemented':
              'Fungsi ubah jadwal belum diimplementasikan',
          'date': 'Tanggal',
          'total_price': 'Total Harga',
          'close': 'Tutup',
          'error_loading_orders': 'Kesalahan memuat pesanan',
          'retry': 'Coba Lagi',
          'login': 'Masuk',
          'co_working': 'Co Working',
          'meeting_room': 'Meeting Room',
          'room_event': 'Room Event',
          'all': 'Semua',
          'error_loading_promos': 'Kesalahan memuat promo',
          'no_promos': 'Tidak ada promo tersedia',
          'please_login': 'Silakan login untuk melanjutkan.',
          'booking_details': 'Detail Pesanan',
          'room': 'Ruangan',
          'location': 'Lokasi',
          'booking_date': 'Tanggal Booking',
          'booking_time': 'Jam Booking',
          'booking_duration': 'Durasi Pemesanan',
          'room_cost': 'Biaya Ruangan',
          'tax': 'Pajak',
          'free': 'Gratis',
          'total': 'Total',
          'pay_order': 'Bayar Pesanan',
          'jarak':'Terdekat',
          'payment_success': 'Pembayaran Berhasil',
          'view_my_orders': 'Lihat Pesanan Saya',
          'back_to_home': 'Kembali ke Beranda',
          'untitled': 'Tanpa Judul',
          'unknown_date': 'Tanggal Tidak Diketahui',
          'unknown_author': 'Penulis Tidak Diketahui',
          'no_description': 'Tidak ada deskripsi tersedia',
          'no_content': 'Tidak ada konten tersedia',
          'special_promo': 'Promo Spesial',
          'save_more': 'Hemat Lebih!',
          'free_wifi': 'WiFi Gratis',
          'no_wifi': 'Tidak Ada WiFi',
          'elevator': 'Lift',
          'no_elevator': 'Tidak Ada Lift',
          'parking': 'Parkir',
          'no_parking': 'Tidak Ada Parkir',
          'ac': 'AC',
          'weekdays': 'Min,Sen,Sel,Rab,Kam,Jum,Sab',
          'article': 'Artikel',
          'book': 'Pemesanan kamar',
          'select_date': 'Pilih Tanggal',
          'select_room': 'Pilih Ruangan',
          'select_time': 'Pilih Jam',
          'select_duration': 'Pilih Durasi',
          'continue_booking': 'Lanjutkan Pemesanan',
          'unknown_location': 'Lokasi Tidak Diketahui',
        };
      case 'en':
        return {
          // Existing keys
          'orders_bottonNav':'Orders',
          'frequently_visited': 'Most Frequently Visited',
          'maximize_business': 'Maximize Your Business with Union Space',
          'promo': 'Promo',
          'promo_subtitle': 'Convenience with Promos',
          'articles': 'Articles',
          'view_all': 'View All',
          'start_now': 'Start Now',
          'next': 'Next',
          'jarak':'Nearest',
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
          'Isi_privacy_policy2': 'Your Information',
          'Isi_privacy_policy1':
              'we may collect personal information such as your name, email address, phone number, and payment details when you register for an account or make a booking.',
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
          'Orders': 'Pesanan',
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
          'onboarding_title_1': 'Start Your Productive Day Now!',
          'onboarding_subtitle_1':
              'Discover workspaces with direct access, influence for future success. Define and design your space now',
          'onboarding_title_2': 'Your Space. Your Style. Your Business.',
          'onboarding_subtitle_2':
              'Offering flexibility and personalization tailored by UnionSpace',
          'onboarding_title_3': 'Connected. Growing. Together',
          'onboarding_subtitle_3':
              'Have a range of benefits and professional collaboration growth in Indonesia',
          'location_title_{id}': '{title_en}',
          'property_title_{id}': '{title_en}',
          'promo_title_{id}': '{title_en}',
          'article_title_{id}': '{title_en}',
          'onboarding_title_{id}': '{title_en}',
          'onboarding_description_{id}': '{description_en}',
          // New keys added
          'hours': '{count} Hour(s)',
          'failed_to_save_order': 'Failed to save order: {error}',
          'failed_to_load_orders': 'Failed to load orders: {error}',
          'failed_to_load_promos': 'Failed to load promos: {error}',
          'my_orders': 'My Orders',
          'no_orders': 'No orders yet',
          'active_booking': 'Active Booking',
          'reschedule': 'Reschedule',
          'view_details': 'View Details',
          'reschedule_not_implemented':
              'Reschedule functionality not implemented yet',
          'date': 'Date',
          'total_price': 'Total Price',
          'close': 'Close',
          'error_loading_orders': 'Error loading orders',
          'retry': 'Retry',
          'login': 'Login',
          'co_working': 'Co Working',
          'meeting_room': 'Meeting Room',
          'room_event': 'Room Event',
          'all': 'All',
          'error_loading_promos': 'Error loading promos',
          'no_promos': 'No promos available',
          'please_login': 'Please login to continue.',
          'booking_details': 'Booking Details',
          'room': 'Room',
          'location': 'Location',
          'booking_date': 'Booking Date',
          'booking_time': 'Booking Time',
          'booking_duration': 'Booking Duration',
          'room_cost': 'Room Cost',
          'tax': 'Tax',
          'free': 'Free',
          'total': 'Total',
          'pay_order': 'Pay Order',
          'payment_success': 'Payment Successful',
          'view_my_orders': 'View My Orders',
          'back_to_home': 'Back to Home',
          'untitled': 'Untitled',
          'unknown_date': 'Unknown Date',
          'unknown_author': 'Unknown Author',
          'no_description': 'No description available',
          'no_content': 'No content available',
          'special_promo': 'Special Promo',
          'save_more': 'Save More!',
          'free_wifi': 'Free WiFi',
          'no_wifi': 'No WiFi',
          'elevator': 'Elevator',
          'no_elevator': 'No Elevator',
          'parking': 'Parking',
          'no_parking': 'No Parking',
          'ac': 'AC',
          'weekdays': 'Sun,Mon,Tue,Wed,Thu,Fri,Sat',
          'article': 'Article',
          'book': 'Booking room',
          'select_date': 'Select Date',
          'select_room': 'Select Room',
          'select_time': 'Select Time',
          'select_duration': 'Select Duration',
          'continue_booking': 'Continue Booking',
          'unknown_location': 'Unknown Location',
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
