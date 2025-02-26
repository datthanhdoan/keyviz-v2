import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'translations.dart';

class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
  
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  
  late Map<String, String> _localizedStrings;
  
  Future<bool> load() async {
    // Load the language JSON file from the translations
    _localizedStrings = locale.languageCode == 'vi'
        ? vietnameseTranslations
        : englishTranslations;
    return true;
  }
  
  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
  
  bool get isVietnamese => locale.languageCode == 'vi';
  bool get isEnglish => locale.languageCode == 'en';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    return ['en', 'vi'].contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }
  
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// Extension method for easier access to translations
extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  
  String tr(String key) => AppLocalizations.of(this).translate(key);
} 