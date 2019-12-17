import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
export 'package:shared_preferences/shared_preferences.dart';

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

//! builder
class LocalizedMaterialAppBuilder extends StatelessWidget {
  ///The dfault locale to  be used until load locale from shared prefrences
  final Locale defualtLocale;

  /// when locale changed it will fade out then fade in
  final bool fadeAnimation;

  final Duration duration;

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
    this.fadeAnimation = true,
    this.duration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getLocale(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return _InnerAppBuilder(
              snapshot.data, builder, delegate, fadeAnimation, duration);
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
  final bool fadeAnimation;
  final Duration duration;
  final MaterialApp Function(
      Locale locale, LocalizationsDelegate<PQLocalization> delegate) builder;

  const _InnerAppBuilder(this.locale, this.builder, this.delegate,
      this.fadeAnimation, this.duration);
  @override
  __InnerAppBuilderState createState() => __InnerAppBuilderState();
}

class __InnerAppBuilderState extends State<_InnerAppBuilder> {
  ValueNotifier<Locale> locale;
  bool _visible = true;
  Locale _oldLocale;
  @override
  void initState() {
    locale = ValueNotifier(widget.locale);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fadeAnimation == true)
      return AnimatedOpacity(
        onEnd: () {
          if (_visible == false) {
            setState(() {
              _visible = true;
              _oldLocale = null;
            });
          }
        },
        duration: widget.duration ?? Duration(milliseconds: 300),
        opacity: _visible ? 1.0 : 0.0,
        child: widget.builder(_oldLocale ?? locale.value, widget.delegate),
      );
    else
      return widget.builder(locale.value, widget.delegate);
  }

  void setLocale(Locale newLocale) {
    if (widget.fadeAnimation == true) {
      setState(() {
        _visible = false;
        _oldLocale = locale.value;
        locale.value = newLocale;
      });
    } else {
      setState(() {
        locale.value = newLocale;
        _visible = true;
      });
    }
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

class LocalizedWidgetBuilder extends StatefulWidget {
  final Widget Function(PQLocalization localizer) builder;
  final Function(Locale newLOcale) onLocaleChange;
  const LocalizedWidgetBuilder(
      {Key key, @required this.builder, this.onLocaleChange})
      : super(key: key);

  @override
  _LocalizedWidgetBuilderState createState() => _LocalizedWidgetBuilderState();
}

class _LocalizedWidgetBuilderState extends State<LocalizedWidgetBuilder> {
  __InnerAppBuilderState _state;
  @override
  Widget build(BuildContext context) {
    return widget.builder(PQLocalization.of(context));
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 100)).then((d) {
      _state = context.findAncestorStateOfType<__InnerAppBuilderState>();
      if (_state == null) {
        throw Exception(
            "You should wrap  your  material app   with LocalizedMaterialAppBuilder");
      }
      _state.locale.addListener(onChange);
    });
  }

  @override
  void dispose() {
    if (_state != null) _state.locale.removeListener(onChange);
    super.dispose();
  }

  void onChange() {
    if (!mounted) return;
    widget.onLocaleChange(_state?.locale?.value);
  }
}
