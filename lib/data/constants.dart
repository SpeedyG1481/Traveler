import 'package:traveler/language/language.dart';

class Constants {
  static const bool debugMode = true;
  static const int BuildPredictionSinglePlayerRoundCount = 10;

  static const int BuildPredictionSinglePlayerQuestionTimer = 45;
  static const int HealthPerMinute = 12;
  static const int TotalWrongAnswerCount = 4;

  static bool canRemoveAds = false;

  static const int MaximumUploadSizeBytes = MaximumUploadSizeKiloBytes * 1024;
  static const int MaximumUploadSizeKiloBytes =
      MaximumUploadSizeMegaBytes * 1024;
  static const int MaximumUploadSizeMegaBytes = 10;

  static const String securityToken =
      "009b40a9f620361b7348824601d85fa8ae62fc9a6fd11dc1d02c2d589458526664fcac2c994c4a019bbfd28c6cfb671e3a7e8f783b7a50a1982360eacbbbe7c8";

  static const String siteUrl = "https://studio.megalowofficial.com";

  static const String apiURL =
      siteUrl + "/api/games/traveler/fetch_data_from_mobile.php";

  //LANG ADD
  static String userContractUrl = siteUrl +
      "/api/games/traveler/privacy/?lang=" +
      Language.locale.languageCode;

  static String timeUrl = siteUrl + "/api/games/traveler/time.php";

  static const String rankingSiteUrl =
      siteUrl + "/rankings/index.php?game=traveler";

  static String userImageUploadURL =
      siteUrl + "/api/games/traveler/upload_new_image.php";

  static String userSendReportUrl =
      siteUrl + "/api/games/traveler/new_report.php";

  static String fullOverText = "FULLOVERTEXT";
}
