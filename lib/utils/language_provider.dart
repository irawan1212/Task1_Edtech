import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale = const Locale('id'); // Default language
  static const String _languageKey = 'selected_language';

  LanguageProvider() {
    _loadLanguage(); // Load saved language on initialization
  }

  Locale get locale => _locale;

  Future<void> setLocale(Locale locale) async {
    if (_locale != locale) {
      _locale = locale;
      await _saveLanguage(locale.languageCode); // Save to SharedPreferences
      notifyListeners();
    }
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode =
        prefs.getString(_languageKey) ?? 'id'; // Default to 'id'
    _locale = Locale(languageCode);
    notifyListeners();
  }

  Future<void> _saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }
}
