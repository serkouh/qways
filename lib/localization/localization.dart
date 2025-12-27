import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Localization {
  Locale? locale;
  Localization(this.locale);

  static Localization of(BuildContext context) {
    return Localizations.of<Localization>(context, Localization)!;
  }

  Map<dynamic, dynamic>? _locaizedValue;

  Map flattedValue(Map<dynamic, dynamic> json, [String prifix = '']) {
    Map<dynamic, dynamic> transaction = {};
    json.forEach((dynamic key, dynamic value) {
      if (value is Map) {
        transaction.addAll(flattedValue(value, '$prifix$key.'));
      } else {
        transaction['$prifix$key'] = value.toString();
      }
    });
    return transaction;
  }

  Future load() async {
    String jsonStringValue = await rootBundle
        .loadString('assets/languages/${locale?.languageCode}.json');

    Map mappedValue = json.decode(jsonStringValue);

    _locaizedValue = flattedValue(mappedValue);
  }

  String getTranslation(String key) {
    return _locaizedValue![key] ?? key;
  }

  static LocalizationsDelegate<Localization> delegate =
      const DemoLocalizationsDelegate();

  static Localization get instance => DemoLocalizationsDelegate.instance!;
}

class DemoLocalizationsDelegate extends LocalizationsDelegate<Localization> {
  const DemoLocalizationsDelegate();

  static Localization? instance;

  @override
  bool isSupported(Locale locale) =>
      ['en', 'hi', 'id', 'zh', 'ar'].contains(locale.languageCode);

  @override
  Future<Localization> load(Locale locale) async {
    Localization localization = Localization(locale);
    await localization.load();
    instance = localization;

    return localization;
  }

  @override
  bool shouldReload(DemoLocalizationsDelegate old) => false;
}
