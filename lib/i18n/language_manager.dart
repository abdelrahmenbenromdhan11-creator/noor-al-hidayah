import 'package:flutter/material.dart';
import 'translations.dart';
import 'translations_extra.dart';

class LanguageManager {
  static final ValueNotifier<String> currentLanguage = ValueNotifier<String>('ar');

  static String t(String key) {
    final lang = currentLanguage.value;
    return extraTranslations[lang]?[key]
        ?? extraTranslations['en']?[key]
        ?? translations[lang]?[key]
        ?? translations['ar']?[key]
        ?? key;
  }

  static bool isRTL() {
    return ['ar', 'ur'].contains(currentLanguage.value);
  }

  static void setLanguage(String code) {
    currentLanguage.value = code;
  }
}
