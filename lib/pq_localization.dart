import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef SetLocaleCallBack = void Function(Locale locale);

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
}

//! delegate

class _PQLocalizationDelegate extends LocalizationsDelegate<PQLocalization> {
  final List<String> supportedLocale;
  final Future<Map<String, String>> Function(Locale locale) getResources;
  final bool reload;
  const _PQLocalizationDelegate(
      this.supportedLocale, this.getResources, this.reload);

  @override
  bool isSupported(Locale locale) =>
      (supportedLocale ?? []).contains(locale.languageCode);

  @override
  Future<PQLocalization> load(Locale locale) async {
    var strings = await getResources(locale);
    PQLocalization localizer = PQLocalization(locale, strings);
    return localizer;
  }

  @override
  bool shouldReload(_PQLocalizationDelegate old) => reload;
}

class LocalizedMaterialAppBuilder extends StatelessWidget {
  ///The dfault locale to  be used until load locale from shared prefrences
  final Locale defualtLocale;

  /// Default widget until  loading locale
  final Widget splashScreen;

  /// Builder that return materiaal app  with spacified locale
  final MaterialApp Function(
      Locale locale, LocalizationsDelegate<PQLocalization> delegate) builder;

  ///  The Supported locales For the delegate
  final List<String> supportedLocales;

  /// This is an Important function the loads the strings it will called every time the locale changed
  final Future<Map<String, String>> Function(Locale locale) getResources;

  /// this property is useful in debug mode it will reload resources defualt to false and must be false in release mode
  final bool reloadResources;

  LocalizationsDelegate<PQLocalization> get delegate =>
      _PQLocalizationDelegate(supportedLocales, getResources, reloadResources);
  const LocalizedMaterialAppBuilder({
    Key key,
    @required this.builder,
    @required this.defualtLocale,
    this.splashScreen,
    @required this.supportedLocales,
    @required this.getResources,
    this.reloadResources = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getLocale(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return _InnerAppBuilder(snapshot.data, builder, delegate);
        }
        return splashScreen ?? Center(child: CircularProgressIndicator());
      },
    );
  }

  Future<Locale> getLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("PQ_Language_Code")) {
      var locale = Locale(prefs.getString("PQ_Language_Code"));
      if (locale != null) return locale;
    }
    return defualtLocale;
  }
}

class _InnerAppBuilder extends StatefulWidget {
  final Locale locale;
  final LocalizationsDelegate<PQLocalization> delegate;
  final MaterialApp Function(
      Locale locale, LocalizationsDelegate<PQLocalization> delegate) builder;

  const _InnerAppBuilder(this.locale, this.builder, this.delegate);
  @override
  __InnerAppBuilderState createState() => __InnerAppBuilderState();
}

class __InnerAppBuilderState extends State<_InnerAppBuilder> {
  ValueNotifier<Locale> locale;
  @override
  void initState() {
    locale = ValueNotifier(widget.locale);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(locale.value, widget.delegate);
  }

  void setLocale(Locale newLocale) {
    setState(() {
      locale.value = newLocale;
    });
  }
}

class LocaleController {
  BuildContext context;
  Locale get locale => PQLocalization.of(context)?.locale;
  String get localeCode => locale?.languageCode;

  LocaleController._(this.context);

  void setLocale(Locale newLocale) {
    __InnerAppBuilderState state =
        context.findAncestorStateOfType<__InnerAppBuilderState>();
    if (state == null) {
      throw Exception(
          "You should wrap  your  material app   with LocalizedMaterialAppBuilder");
    }
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString("PQ_Language_Code", newLocale.languageCode);
      state.setLocale(newLocale);
    });
  }
}

class LocaleSwitcher extends StatelessWidget {
  final Widget Function(LocaleController controller) builder;
  const LocaleSwitcher({Key key, @required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return builder(LocaleController._(context));
  }
}

mixin LocalizationNotifierMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 100)).then((d) {
      __InnerAppBuilderState state =
          context.findAncestorStateOfType<__InnerAppBuilderState>();
      if (state == null) {
        throw Exception(
            "You should wrap  your  material app   with LocalizedMaterialAppBuilder");
      }
      state.locale.addListener(onChange);
    });
  }

  @override
  void dispose() {
    __InnerAppBuilderState state =
        context.findAncestorStateOfType<__InnerAppBuilderState>();
    if (state != null) state.locale.removeListener(onChange);
    super.dispose();
  }

  void onChange() {
    if (!mounted) return;
    onLocaleChanged();
  }

  void onLocaleChanged();
}
