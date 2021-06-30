import 'package:traveler/language/language.dart';

class Constants {
  static const bool debugMode = true;

  static const int BuildPredictionSinglePlayerRoundCount = 5;
  static const int BuildPredictionSinglePlayerQuestionTimer = 90;
  static const int HealthPerMinute = 12;

  static const List<int> BuildPredictionSuccessLevels = [10, 100, 1000];

  static const int MaximumUploadSizeBytes = MaximumUploadSizeKiloBytes * 1024;
  static const int MaximumUploadSizeKiloBytes =
      MaximumUploadSizeMegaBytes * 1024;
  static const int MaximumUploadSizeMegaBytes = 10;

  static const String securityToken =
      "d2c7f149e689cb9b436871de001d66feae1d8b7798b8605765a3db52cbf728b3";

  static const String siteUrl = "https://studio.megalowofficial.com";

  static const String apiURL =
      siteUrl + "/api/games/traveler/fetch_data_from_mobile.php";

  static const String newScoreUrl =
      siteUrl + "/api/games/traveler/new_score.php";

  //LANG ADD
  static String userContractUrl = siteUrl +
      "/api/games/traveler/privacy/?lang=" +
      Language.locale.languageCode;

  static String timeUrl = siteUrl + "/api/games/traveler/time.php";

  static const String rankingSiteUrl = siteUrl + "/api/games/traveler/rankings";

  static String userImageUploadURL =
      siteUrl + "/api/games/traveler/upload_new_image.php";

  static String fullOverText = "FULLOVERTEXT";
}
