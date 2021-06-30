import 'package:flutter/widgets.dart';

enum LanguageEnum { tr_TR, en_US }

extension LanguageEnumClass on LanguageEnum {
  static LanguageEnum getByName(String name) {
    if (name != null) {
      for (LanguageEnum l in LanguageEnum.values) {
        if (l.getName == name ||
            l.getName.toLowerCase() == name ||
            l.getName.toUpperCase() == name) {
          return l;
        }
      }
    }
    return LanguageEnum.tr_TR;
  }

  static LanguageEnum getByIndex(int i) {
    for (LanguageEnum l in LanguageEnum.values) {
      if (l.index == i) {
        return l;
      }
    }
    return null;
  }

  String get getName {
    switch (this) {
      case LanguageEnum.en_US:
        return "en_US";
      default:
        return "tr_TR";
    }
  }

  static Locale getLocaleByName(LanguageEnum enuma) {
    switch (enuma) {
      case LanguageEnum.en_US:
        return Locale("en", "US");
      default:
        return Locale("tr", "TR");
    }
  }
}
