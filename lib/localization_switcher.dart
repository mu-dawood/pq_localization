part of pa_localization;

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
