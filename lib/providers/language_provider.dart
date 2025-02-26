import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageCodeKey = 'language_code';
  
  Locale _locale = const Locale('en');
  
  LanguageProvider() {
    _loadSavedLanguage();
  }
  
  Locale get locale => _locale;
  
  bool get isEnglish => _locale.languageCode == 'en';
  bool get isVietnamese => _locale.languageCode == 'vi';
  
  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguageCode = prefs.getString(_languageCodeKey);
    
    if (savedLanguageCode != null) {
      _locale = Locale(savedLanguageCode);
      notifyListeners();
    }
  }
  
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    
    _locale = locale;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, locale.languageCode);
    
    notifyListeners();
  }
  
  Future<void> toggleLanguage() async {
    final newLocale = isEnglish ? const Locale('vi') : const Locale('en');
    await setLocale(newLocale);
  }
} 