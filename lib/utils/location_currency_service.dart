// services/location_currency_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class LocationCurrencyService {
  static const String _ipApiUrl = 'http://ip-api.com/json';
  static const String _exchangeApiUrl =
      'https://api.exchangerate-api.com/v4/latest';

  // Cache untuk menghindari multiple API calls
  static String? _cachedCountry;
  static String? _cachedCurrency;
  static Map<String, double>? _cachedRates;
  static DateTime? _lastFetch;

  // Mendapatkan informasi lokasi berdasarkan IP
  static Future<Map<String, String>> getUserLocation() async {
    try {
      // Cek cache (valid untuk 1 jam)
      if (_cachedCountry != null &&
          _cachedCurrency != null &&
          _lastFetch != null &&
          DateTime.now().difference(_lastFetch!).inHours < 1) {
        return {
          'country': _cachedCountry!,
          'currency': _cachedCurrency!,
        };
      }

      final response = await http.get(Uri.parse(_ipApiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final countryCode = data['countryCode'] as String;
        final currency = _getCurrencyFromCountry(countryCode);

        // Cache hasil
        _cachedCountry = countryCode;
        _cachedCurrency = currency;
        _lastFetch = DateTime.now();

        return {
          'country': countryCode,
          'currency': currency,
          'city': data['city'] ?? '',
          'region': data['regionName'] ?? '',
        };
      }
    } catch (e) {
      print('Error getting user location: $e');
    }

    // Default ke Indonesia jika gagal
    return {
      'country': 'ID',
      'currency': 'IDR',
    };
  }

  // Mapping country code ke currency
  static String _getCurrencyFromCountry(String countryCode) {
    final currencyMap = {
      'ID': 'IDR', // Indonesia
      'US': 'USD', // United States
      'GB': 'GBP', // United Kingdom
      'JP': 'JPY', // Japan
      'CN': 'CNY', // China
      'KR': 'KRW', // South Korea
      'TH': 'THB', // Thailand
      'MY': 'MYR', // Malaysia
      'SG': 'SGD', // Singapore
      'PH': 'PHP', // Philippines
      'VN': 'VND', // Vietnam
      'IN': 'INR', // India
      'AU': 'AUD', // Australia
      'CA': 'CAD', // Canada
      'EU': 'EUR', // European Union
      'DE': 'EUR', // Germany
      'FR': 'EUR', // France
      'IT': 'EUR', // Italy
      'ES': 'EUR', // Spain
      'NL': 'EUR', // Netherlands
      'BR': 'BRL', // Brazil
      'MX': 'MXN', // Mexico
      'AR': 'ARS', // Argentina
      'CL': 'CLP', // Chile
      'CO': 'COP', // Colombia
      'PE': 'PEN', // Peru
      'ZA': 'ZAR', // South Africa
      'EG': 'EGP', // Egypt
      'SA': 'SAR', // Saudi Arabia
      'AE': 'AED', // UAE
      'TR': 'TRY', // Turkey
      'RU': 'RUB', // Russia
      'UA': 'UAH', // Ukraine
      'PL': 'PLN', // Poland
      'CZ': 'CZK', // Czech Republic
      'HU': 'HUF', // Hungary
      'RO': 'RON', // Romania
      'BG': 'BGN', // Bulgaria
      'HR': 'HRK', // Croatia
      'RS': 'RSD', // Serbia
      'BA': 'BAM', // Bosnia and Herzegovina
      'AL': 'ALL', // Albania
      'MK': 'MKD', // North Macedonia
      'ME': 'EUR', // Montenegro
      'SI': 'EUR', // Slovenia
      'SK': 'EUR', // Slovakia
      'LV': 'EUR', // Latvia
      'LT': 'EUR', // Lithuania
      'EE': 'EUR', // Estonia
      'FI': 'EUR', // Finland
      'SE': 'SEK', // Sweden
      'NO': 'NOK', // Norway
      'DK': 'DKK', // Denmark
      'IS': 'ISK', // Iceland
      'CH': 'CHF', // Switzerland
      'AT': 'EUR', // Austria
      'BE': 'EUR', // Belgium
      'LU': 'EUR', // Luxembourg
      'IE': 'EUR', // Ireland
      'PT': 'EUR', // Portugal
      'GR': 'EUR', // Greece
      'CY': 'EUR', // Cyprus
      'MT': 'EUR', // Malta
    };

    return currencyMap[countryCode.toUpperCase()] ?? 'USD';
  }

  // Mendapatkan exchange rates
  static Future<Map<String, double>> getExchangeRates(
      String baseCurrency) async {
    try {
      // Cek cache (valid untuk 1 jam)
      if (_cachedRates != null &&
          _lastFetch != null &&
          DateTime.now().difference(_lastFetch!).inHours < 1) {
        return _cachedRates!;
      }

      final response =
          await http.get(Uri.parse('$_exchangeApiUrl/$baseCurrency'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = Map<String, double>.from(
            data['rates'].map((key, value) => MapEntry(key, value.toDouble())));

        // Cache hasil
        _cachedRates = rates;

        return rates;
      }
    } catch (e) {
      print('Error getting exchange rates: $e');
    }

    // Return default rates jika gagal
    return {
      'USD': 1.0,
      'IDR': 15000.0,
      'SGD': 1.35,
      'MYR': 4.2,
      'THB': 33.0,
      'EUR': 0.85,
      'GBP': 0.75,
      'JPY': 110.0,
    };
  }

  // Konversi mata uang
  static Future<double> convertCurrency(
    double amount,
    String fromCurrency,
    String toCurrency,
  ) async {
    if (fromCurrency == toCurrency) return amount;

    try {
      final rates = await getExchangeRates(fromCurrency);
      final rate = rates[toCurrency] ?? 1.0;
      return amount * rate;
    } catch (e) {
      print('Error converting currency: $e');
      return amount;
    }
  }

  // Format mata uang berdasarkan locale
  static String formatCurrency(double amount, String currencyCode) {
    final locale = _getLocaleFromCurrency(currencyCode);
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: _getCurrencySymbol(currencyCode),
      decimalDigits: _getDecimalDigits(currencyCode),
    );

    return formatter.format(amount);
  }

  static String _getLocaleFromCurrency(String currencyCode) {
    final localeMap = {
      'IDR': 'id_ID',
      'USD': 'en_US',
      'SGD': 'en_SG',
      'MYR': 'ms_MY',
      'THB': 'th_TH',
      'EUR': 'de_DE',
      'GBP': 'en_GB',
      'JPY': 'ja_JP',
      'CNY': 'zh_CN',
      'KRW': 'ko_KR',
      'PHP': 'fil_PH',
      'VND': 'vi_VN',
      'INR': 'hi_IN',
      'AUD': 'en_AU',
      'CAD': 'en_CA',
      'BRL': 'pt_BR',
      'MXN': 'es_MX',
    };

    return localeMap[currencyCode] ?? 'en_US';
  }

  static String _getCurrencySymbol(String currencyCode) {
    final symbolMap = {
      'IDR': 'Rp',
      'USD': '\$',
      'SGD': 'S\$',
      'MYR': 'RM',
      'THB': '฿',
      'EUR': '€',
      'GBP': '£',
      'JPY': '¥',
      'CNY': '¥',
      'KRW': '₩',
      'PHP': '₱',
      'VND': '₫',
      'INR': '₹',
      'AUD': 'A\$',
      'CAD': 'C\$',
      'BRL': 'R\$',
      'MXN': '\$',
      'ARS': '\$',
      'CLP': '\$',
      'COP': '\$',
      'PEN': 'S/',
      'ZAR': 'R',
      'EGP': 'E£',
      'SAR': 'SR',
      'AED': 'د.إ',
      'TRY': '₺',
      'RUB': '₽',
      'PLN': 'zł',
      'SEK': 'kr',
      'NOK': 'kr',
      'DKK': 'kr',
      'CHF': 'CHF',
    };

    return symbolMap[currencyCode] ?? currencyCode;
  }

  static int _getDecimalDigits(String currencyCode) {
    // Mata uang yang tidak menggunakan desimal
    final noDecimalCurrencies = ['JPY', 'KRW', 'VND', 'IDR'];
    return noDecimalCurrencies.contains(currencyCode) ? 0 : 2;
  }

  // Mendapatkan informasi lengkap mata uang
  static Future<Map<String, dynamic>> getUserCurrencyInfo() async {
    final location = await getUserLocation();
    final currency = location['currency']!;

    return {
      'country': location['country'],
      'currency': currency,
      'symbol': _getCurrencySymbol(currency),
      'locale': _getLocaleFromCurrency(currency),
      'city': location['city'],
      'region': location['region'],
    };
  }

  // Clear cache (untuk testing atau refresh)
  static void clearCache() {
    _cachedCountry = null;
    _cachedCurrency = null;
    _cachedRates = null;
    _lastFetch = null;
  }
}
