import 'package:traveler/language/language.dart';

class ReportTypes {
  static const int LOW_RESOLUTION = 1,
      WRONG_DATA = 2,
      OTHER = 3;

  static String getName(int id) {
    switch (id) {
      case LOW_RESOLUTION:
        return Language.reportTypeLowResolution;
      case WRONG_DATA:
        return Language.reportTypeWrongData;
      case OTHER:
        return Language.reportTypeOther;
    }
    return null.toString();
  }

  static List<String> getList() {
    return [
      Language.reportTypeLowResolution,
      Language.reportTypeWrongData,
      Language.reportTypeOther
    ];
  }

  static int getIndex(String string) {
    if (string == Language.reportTypeLowResolution) {
      return LOW_RESOLUTION;
    } else if (string == Language.reportTypeWrongData) {
      return WRONG_DATA;
    }
    return OTHER;
  }
}
