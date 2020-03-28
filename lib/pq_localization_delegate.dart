part of pa_localization;

class _PQLocalizationDelegate extends LocalizationsDelegate<PQLocalization> {
  final Iterable<Locale> supportedLocale;
  final Future<Map<String, String>> Function(Locale locale) getResources;
  final bool reload;
  const _PQLocalizationDelegate(
      this.supportedLocale, this.getResources, this.reload);

  @override
  bool isSupported(Locale locale) =>
      (supportedLocale ?? []).any((a) => a.languageCode == locale.languageCode);

  @override
  Future<PQLocalization> load(Locale locale) async {
    var strings = await getResources(locale);
    PQLocalization localizer = PQLocalization(locale, strings);
    return localizer;
  }

  @override
  bool shouldReload(_PQLocalizationDelegate old) => reload;
}
