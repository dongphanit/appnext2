import 'bangla.dart';
import 'english.dart';

class Localization {
  static Map<String, String> _localizedStrings = english; // Default to English

  static void setLanguage(String languageCode) {
    switch (languageCode) {
      case 'bn':
        _localizedStrings = bangla;
        break;
      case 'en':
      default:
        _localizedStrings = english;
        break;
    }
  }

  static String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}