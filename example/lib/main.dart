import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pq_localization/pq_localization.dart';

void main() => runApp(
      LocalizedMaterialAppBuilder(
        builder: (Locale locale, LocalizationsDelegate delegate) {
          return MaterialApp(
            locale: locale, // Important
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              delegate //Important
            ],
            supportedLocales: [
              const Locale('ar'),
              const Locale('en'),
            ],
            home: LocalizedWidgetBuilder(
              builder: (PQLocalization localizer) {
                return Scaffold(
                  appBar: AppBar(
                    title: Text(localizer.translate("title")),
                  ),
                  body: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(localizer.translate("content")),
                        Text(localizer.translate("UnknownKey")),
                        LocaleSwitcher(
                          builder: (LocaleController controller) {
                            return Padding(
                              padding: EdgeInsets.only(top: 50),
                              child: Row(
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
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        defualtLocale: Locale("ar"),
        getResources: (Locale locale) async {
          if (locale.languageCode == "ar")
            return {
              "title": "عنوان التطبيق",
              "content": "محتوى التطبيق",
            };
          else
            return {
              "title": "App  title",
              "content": "App content",
            };
        },
        supportedLocales: <String>["ar", "en"],
      ),
    );
