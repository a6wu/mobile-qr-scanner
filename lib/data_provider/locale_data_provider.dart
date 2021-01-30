import 'package:flutter/material.dart';

class LocaleDataProvider extends ChangeNotifier {
  Locale locale;

  LocaleDataProvider() {
    ///DEFAULT STATES
    locale = Locale('en', '');
  }

  void setLocaleEn() {
    locale = Locale('en', '');
    notifyListeners();
  }

  void setLocaleEs() {
    locale = Locale('es', '');
    notifyListeners();
  }
}
