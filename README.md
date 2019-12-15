# PQ_Localization

Simple Package to handle localization for flutter

## Installation

add this line to your pubspec.yaml

```bash
pq_localization: any
```

## Usage

```python
import 'package:pq_localization/pq_localization.dart';

  LocalizedMaterialAppBuilder(
      # This method must return material app
      builder: (Locale locale, LocalizationsDelegate delegate) {
        return MaterialApp(
          locale: locale,
          localizationsDelegates: [
            //...other delegates
            delegate,
          ],
        );
      },
      # default locale that will be used if no locales saved in shared prefrences
      defualtLocale: Locale("ar"),

      getResources: (Locale locale) async {
       # this method return Furure so you can get your resources on any way.
       # json files or internet or any thing its your choice
        if (locale.countryCode == "ar")
          return {"app_name": "إسم التطبيق"};
        else
          return {"app_name": "app name"};
      },
      # What ever locales you want
      # Note that this property is not mapped to default one of material apps
      # These locales are to define which locales will be used for our delegate
      supportedLocales: <String>["ar","en"],
    );
```

now to access the localizer you cand do this

```python
PQLocalization.of(context).translate("Key");
# or you can use this

LocalizedWidgetBuilder(
      builder: (PQLocalization localizer) {
        Text(localizer.translate("title"));
      },
    );
```

I think you now need to change your locale so you can do like that

```python
        LocaleSwitcher(
                          builder: (LocaleController controller) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ChoiceChip(
                                  onSelected: (bool v) {
                                    controller.setLocale(Locale("ar"));
                                  },
                                  label: Text("العربية"),
                                  selected: controller.localeCode == "ar",
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                ChoiceChip(
                                  onSelected: (bool v) {
                                    controller.setLocale(Locale("en"));
                                  },
                                  label: Text("English"),
                                  selected: controller.localeCode == "en",
                                ),
                              ],
                            );
                          },
                        )
```

## Note

You must use the defualt delgates like as this package will translate only your strings
https://flutter.dev/docs/development/accessibility-and-localization/internationalization
