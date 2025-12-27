import 'package:qways/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

String getTranslation(BuildContext context, String key) {
  return Localization.of(context).getTranslation(key);
}

String translation(String key) {
  return Localization.instance.getTranslation(key);
}

const String english = 'en';
const String hindi = 'hi';
const String indinesian = 'id';
const String chinese = 'zh';
const String arabic = 'ar';
const String languageKey = 'languageCode';

Future setLocale(String languageCode) async {
  SharedPreferences pref = await SharedPreferences.getInstance();

  await pref.setString(languageKey, languageCode);
  return Locale(languageCode);
}

Future getLocale() async {
  SharedPreferences pref = await SharedPreferences.getInstance();

  String languageCode = pref.getString(languageKey) ?? english;
  return Locale(languageCode);
}

Locale locale(String languageCode) {
  Locale temp;
  switch (languageCode) {
    case english:
      temp = Locale(languageCode);
      break;
    case hindi:
      temp = Locale(languageCode);
      break;
    case indinesian:
      temp = Locale(languageCode);
      break;

    case chinese:
      temp = Locale(languageCode);
      break;
    case arabic:
      temp = Locale(languageCode);
      break;
    default:
      temp = const Locale(english);
  }
  return temp;
}
