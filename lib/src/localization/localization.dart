import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ecommerce_app/src/utils/string_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Localization {
  Localization(
    this.locale, {
    required this.isTest,
  });

  final bool isTest;
  final Locale? locale;

  static String of(BuildContext context, String key) {
    return Localizations.of<Localization>(context, Localization)
            ?.translate(key)
            .replaceAll("\\n", "\n") ??
        "";
  }

  Map<String, String> _sentences = {};

  Future<Localization> loadTest(Locale locale) async {
    return Localization(locale, isTest: false);
  }

  Future<bool> load() async {
    String data = await rootBundle
        .loadString('assets/localizations/${this.locale?.languageCode}.json');
    Map<String, dynamic> _result = json.decode(data);

    this._sentences = new Map();
    _result.forEach((String key, dynamic value) {
      this._sentences[key] = value.toString();
    });

    return true;
  }

  String translate(String key) {
    if (isTest) return key;
    return this._sentences[key] ?? key;
  }
}

class LocalizationDelegate extends LocalizationsDelegate<Localization> {
  const LocalizationDelegate({
    this.isTest = false,
  });

  final bool isTest;

  static final supportedCodes = ['en', 'ar'];
  static final supportedLocales = supportedCodes.map((c) => Locale(c));

  @override
  bool isSupported(Locale locale) =>
      supportedCodes.contains(locale.languageCode);

  @override
  Future<Localization> load(Locale locale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? language = prefs.getString("swiftShop_language");
    Locale? locale = isNotEmpty(language ?? "") ? Locale(language ?? "ar") : null;

    Localization localization =
        new Localization(locale ?? Locale("ar"), isTest: isTest);
    if (isTest) {
      await localization.loadTest(locale!);
    } else {
      await localization.load();
    }

    print("Loaded language: ${locale?.languageCode}");

    return localization;
  }

  @override
  bool shouldReload(LocalizationDelegate old) => false;
}
