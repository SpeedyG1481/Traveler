import 'dart:convert';

import 'package:devicelocale/devicelocale.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traveler/data/constants.dart';
import 'package:traveler/language/language_enum.dart';

class Language {
  static LanguageEnum languageEnum = LanguageEnum.tr_TR;
  static Locale locale = Locale("tr", "TR");

  static String playButton;
  static String promoteCity;
  static String rankings;
  static String settings;
  static String okey;
  static String contract;
  static String attention;
  static String pickImage;
  static String termsOfUsage;
  static String whereIsHere;
  static String uploadPhotoSuccess;
  static String uploadPhotoUnsuccess;
  static String chooseCity;
  static String singlePlayer;
  static String multiPlayer;
  static String full;
  static String wantToShareName;
  static String sfxSound;
  static String musicSound;
  static String checkDistance;
  static String cancel;
  static String doYouWantToSaveScore;
  static String noDataFound;
  static String exitTwoTap;
  static String noMoreTimes;
  static String accuary;
  static String noHealthForGame;
  static String takePhoto;
  static String done;
  static String introTitle1;
  static String introContent1;
  static String introTitle2;
  static String introContent2;
  static String introTitle3;
  static String introContent3;
  static String typeName;
  static String success;
  static String saveSuccessToTable;
  static String error;
  static String saveErrorToTable;
  static String minimumThreeCharacterForSaveToTable;
  static String tourInfo;
  static String cityName;
  static String stateName;
  static String countryName;
  static String mistakeCount;
  static String wonPoint;
  static String debugModeError;

  static String warningSelectProvince;
  static String warningMaximumUploadSize;
  static String warningMultiplayerComingSoon;
  static String warningReadTermsOfUsage;
  static String warningUploadPhotoMustPortrait;





  static void changeLocale(LanguageEnum languageEnum) async {
    (await SharedPreferences.getInstance())
        .setString("Language", languageEnum.getName);
  }

  static void changeLanguage(LanguageEnum languageEnum) async {
    SharedPreferences preferences = (await SharedPreferences.getInstance());
    await preferences.setString("Language", languageEnum.getName);
    await loadLocale();
  }

  static Future<bool> loadLocale() async {
    SharedPreferences preferences = (await SharedPreferences.getInstance());
    String locale;
    if (preferences.containsKey("Language")) {
      locale = preferences.getString("Language");
    } else {
      locale = await Devicelocale.currentLocale;
    }

    Language.languageEnum = LanguageEnumClass.getByName(locale);
    Language.locale = LanguageEnumClass.getLocaleByName(languageEnum);
    Constants.userContractUrl = Constants.siteUrl +
        "/api/games/traveler/privacy/?lang=" +
        languageEnum.getName.replaceAll("_", "-");

    ByteData jsonData =
        await rootBundle.load("assets/locale/${languageEnum.getName}.json");
    final jsonBuffer = jsonData.buffer;
    var jsonList =
        jsonBuffer.asUint8List(jsonData.offsetInBytes, jsonData.lengthInBytes);
    String jsonSTR = utf8.decode(jsonList);
    Map m = jsonDecode(jsonSTR);
    loadData(m);
    return Future.value(true);
  }

  static void loadData(Map map) {
    playButton = map["PlayButton"];
    promoteCity = map["PromoteCity"];
    rankings = map["Rankings"];
    settings = map["Settings"];
    okey = map["Okey"];
    contract = map["Contract"];
    attention = map["Attention"];
    pickImage = map["PickImage"];
    termsOfUsage = map["TermsOfUsage"];
    whereIsHere = map["WhereIsHere"];
    uploadPhotoSuccess = map["UploadPhotoSuccess"];
    uploadPhotoUnsuccess = map["UploadPhotoUnsuccess"];
    chooseCity = map["ChooseCity"];
    singlePlayer = map["SinglePlayer"];
    multiPlayer = map["MultiPlayer"];
    full = map["Full"];
    wantToShareName = map["WantToShareName"];
    sfxSound = map["SfxSound"];
    musicSound = map["MusicSound"];
    checkDistance = map["CheckDistance"];
    cancel = map["Cancel"];
    doYouWantToSaveScore = map["DoYouWantToSaveScore"];
    noDataFound = map["NoDataFound"];
    exitTwoTap = map["ExitTwoTap"];
    noMoreTimes = map["MoMoreTimes"];
    accuary = map["Accuary"];
    noHealthForGame = map["NoHealthForGame"];
    takePhoto = map["TakePhoto"];
    done = map["Done"];
    introTitle1 = map["IntroTitle1"];
    introContent1 = map["IntroContent1"];
    introTitle2 = map["IntroTitle2"];
    introContent2 = map["IntroContent2"];
    introTitle3 = map["IntroTitle3"];
    introContent3 = map["IntroContent3"];
    typeName = map["TypeName"];
    success = map["Success"];
    saveSuccessToTable = map["SaveSuccessToTable"];
    error = map["Error"];
    saveErrorToTable = map["SaveErrorToTable"];
    minimumThreeCharacterForSaveToTable = map["MinimumThreeCharacterForSaveToTable"];
    tourInfo = map["TourInfo"];
    cityName = map["CityName"];
    stateName = map["StateName"];
    countryName = map["CountryName"];
    mistakeCount = map["MistakeCount"];
    wonPoint = map["WonPoint"];
    debugModeError = map["DebugModeError"];

    warningSelectProvince = map["WarningSelectProvince"];
    warningMaximumUploadSize = map["WarningMaximumUploadSize"];
    warningReadTermsOfUsage = map["WarningReadTermsOfUsage"];
    warningMultiplayerComingSoon = map["WarningMultiplayerComingSoon"];
    warningUploadPhotoMustPortrait = map["WarningUploadPhotoMustPortrait"];
  }

  static void checkNull() {
    List<dynamic> objects = [
      playButton,
    ];
    int countOfNull = 0;
    for (Object o in objects) {
      if (o == null) countOfNull++;
    }

    print("Null language değeri sayısı: " + countOfNull.toString());
  }
}