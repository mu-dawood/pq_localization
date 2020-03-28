library pa_localization;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
export 'package:shared_preferences/shared_preferences.dart';

part 'pq_localization_delegate.dart';
part 'pq_localization_app.dart';
part 'pq_localization_app_builder.dart';
part 'localized_widget_builder.dart';
part 'localization_switcher.dart';

class PQLocalization {
  final Locale _locale;
  final Map<String, String> _localizedStrings;
  String get currentLanguage => locale.languageCode;
  Locale get locale => _locale;
  PQLocalization(this._locale, this._localizedStrings);

  static PQLocalization of(BuildContext context) {
    return Localizations.of<PQLocalization>(context, PQLocalization);
  }

  String translate(String key, [Map<String, String> args]) {
    Map<String, String> strings = _localizedStrings ?? {};
    var result = strings[key] ??
        strings[key.toLowerCase()] ??
        strings[key.toUpperCase()] ??
        key;
    if (args != null)
      args.forEach((key, value) {
        result = result.replaceAll(key, value);
      });
    return result;
  }

  String translatePattern(RegExp regex, [Map<String, String> args]) {
    Map<String, String> strings = _localizedStrings ?? {};
    var key = strings.keys
        .firstWhere((w) => regex.hasMatch(w), orElse: () => regex.pattern);
    return translate(key, args);
  }

  Map<String, String> translateManyPattern(List<RegExp> regexs,
      [Map<String, String> args]) {
    Map<String, String> strings = _localizedStrings ?? {};
    Map<String, String> results = {};
    regexs.forEach((regex) {
      var key = strings.keys
          .firstWhere((w) => regex.hasMatch(w), orElse: () => regex.pattern);
      results[key] = translate(key, args);
    });
    return results;
  }

  Map<String, String> translateMany(List<String> keys,
      [Map<String, String> args]) {
    Map<String, String> results = {};
    keys.forEach((key) {
      results[key] = translate(key, args);
    });
    return results;
  }
}
