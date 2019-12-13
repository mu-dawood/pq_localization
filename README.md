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
      # what ever locales you want
      supportedLocales: <String>["ar","en"],
    );
```

now to access the localizer you cand do this

```python
PQLocalization.of(context).translate("Key");
# or you can use this

LocalizationBuilder(
      builder: (PQLocalization localizer) {
        Text(localizer.translate("app-name"));
      },
    );
```

I think you now need to change your locale so you can do like that

```python
  LocaleChanger(
      builder: (Function(Locale locale) setLocaleCallBack) {
       return Row(
          children: <Widget>[
            RaisedButton(
              onPressed: () {setLocaleCallBack(Locale("ar"));},
              child: Text("العربية"),
            ),
             RaisedButton(
              onPressed: () {setLocaleCallBack(Locale("en"));},
              child: Text("الإنجليزية"),
            ),
          ],
        );
      },
    );
```

## Note

You must use the defualt delgates like as this package will translate only your strings
https://flutter.dev/docs/development/accessibility-and-localization/internationalization
