import 'package:flutter/material.dart';

import '../../../services/localization_service.dart';
import '../../common_package.dart';
import '../../provider/language_provider.dart';

class LanguageHelper {
  convertLangNameToLocale(String langNameToConvert) {
    Locale convertedLocale;

    switch (langNameToConvert) {
      case 'Français':
        convertedLocale = Locale('fr');
        break;
      case 'Español':
        convertedLocale = Locale('es');
        break;
      case 'Русский':
        convertedLocale = Locale('ru');
        break;
      case '한국어':
        convertedLocale = Locale('ko');
        break;
      default:
        convertedLocale = Locale('en');
    }

    return convertedLocale;
  }

  convertLocaleToLangName(String localeToConvert) {
    String langName;

    switch (localeToConvert) {
      case 'fr':
        langName = "Français";
        break;
      case 'es':
        langName = "Español";
        break;
      case 'ru':
        langName = "Русский";
        break;
      case 'ko':
        langName = "한국어";
        break;
      default:
        langName = "English";
    }

    return langName;
  }


  convertLocaleToLocale(String localeToConvert) {
    return convertLangNameToLocale(convertLocaleToLangName(localeToConvert));
  }

  static List<Locale> get supportedLocales {
    return [
      const Locale('en'),
      const Locale('ko'),
    ];
  }

  getLocaleName(int index) {
    return convertLocaleToLangName(supportedLocales[index].languageCode);
  }
}

String TR(BuildContext context, String text) {
  return AppLocalization.of(context)!.translate(text);
}

