import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:traveler/audio/audio_controller.dart';
import 'package:traveler/components/standart_text_field.dart';
import 'package:traveler/data/ads.dart';
import 'package:traveler/data/audio_files.dart';
import 'package:traveler/data/constants.dart';
import 'package:traveler/data/data_model.dart';
import 'package:traveler/data/database_controller.dart';
import 'package:traveler/data/func.dart';
import 'package:traveler/data/images.dart';
import 'package:traveler/data/report_types.dart';
import 'package:traveler/language/language.dart';
import 'package:traveler/models/city.dart';
import 'package:traveler/models/country.dart';
import 'package:traveler/models/question.dart';
import 'package:traveler/models/state.dart';
import 'package:traveler/pages/main_page.dart';

class SinglePlayerBuildPrediction extends StatefulWidget {
  @override
  _SinglePlayerBuildPredictionState createState() =>
      _SinglePlayerBuildPredictionState();
}

class _SinglePlayerBuildPredictionState
    extends State<SinglePlayerBuildPrediction> {
  TextEditingController reportController = TextEditingController();

  InterstitialAd playGameInterstitial;
  BannerAd playGameBannerAd;

  DateTime currentBackPressTime;

  List<Question> questions = [];

  Timer timer;

  int round = 0;
  int point = 0;

  int time = 0;
  int roundTimer = 0;
  int freezeCounter = 0;

  int indexOfSelected = 0;
  int trueAnswerIndex = 0;

  bool isLoading = true;
  bool freeze = false;
  bool reportFreeze = false;
  bool reportSending = false;
  bool roundReportSendStatus = false;

  bool onlyOne = true;

  int trueCount = 0;
  int falseCount = 0;

  String selectedReportType = ReportTypes.getList()[0];

  Future loadAd() async {
    if (Constants.canRemoveAds) {
      return;
    }

    InterstitialAd.load(
      adUnitId: Ads.getPlayGameInterstitialId(),
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          this.playGameInterstitial = ad;
          showAd();
        },
        onAdFailedToLoad: (LoadAdError error) {
          print("AD Error: " + error.message);
        },
      ),
    );
  }

  Future<void> loadBannerAd() async {
    int height = 60;
    int width = MediaQuery.of(context).size.width.truncate();
    final BannerAd banner = BannerAd(
      size: AdSize(height: height, width: width),
      request: AdRequest(),
      adUnitId: Ads.getInGameBannerId(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            playGameBannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
        },
        // onAdOpened: (Ad ad) => print('$BannerAd onAdOpened.'),
        // onAdClosed: (Ad ad) => print('$BannerAd onAdClosed.'),
      ),
    );
    onlyOne = false;
    return banner.load();
  }

  Future showAd() async {
    if (this.playGameInterstitial != null) {
      await this.playGameInterstitial.show();
    }
  }

  @override
  void dispose() {
    if (playGameBannerAd != null) playGameBannerAd.dispose();
    if (playGameInterstitial != null) playGameInterstitial.dispose();
    if (timer != null) timer.cancel();
    timer = null;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    this.loadAd();
    loadQuestions();
    AudioController.stopBackgroundMusic();
  }

  bool isEnded() =>
      this.round >= Constants.BuildPredictionSinglePlayerRoundCount;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (onlyOne && !Constants.canRemoveAds) loadBannerAd();

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        backgroundColor: Color(0xff1D85F8),
        body: SafeArea(
          child: Column(
            children: [
              if (!isEnded())
                Container(
                  padding: EdgeInsets.only(
                    top: 3,
                    bottom: 3,
                  ),
                  width: width,
                  height: 62.5,
                  decoration: BoxDecoration(
                    color: Color(0xff066DBC),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(
                        100,
                      ),
                      bottomRight: Radius.circular(
                        100,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            if (!isEnded())
                              Expanded(
                                flex: 2,
                                child: Icon(
                                  MdiIcons.star,
                                  color: Colors.white,
                                ),
                              ),
                            if (!isEnded())
                              Expanded(
                                child: Icon(
                                  MdiIcons.timerSand,
                                  color: Colors.white,
                                ),
                              ),
                            Expanded(
                              flex: 2,
                              child: Icon(
                                MdiIcons.chevronTripleUp,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!isEnded())
                              Expanded(
                                flex: 2,
                                child: Text(
                                  (round + 1).toString() +
                                      "/" +
                                      questions.length.toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            if (!isEnded())
                              Expanded(
                                child: Text(
                                  (roundTimer - time).toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 25,
                                  ),
                                ),
                              ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                point.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: Container(
                  child: getBody(),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: Images.playGameBackground,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  getBody() {
    double width = MediaQuery.of(context).size.width;

    if (isLoading || !(this.questions != null))
      return Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );

    if (this.questions.length == 0) {
      return Center(
        child: Text(
          Language.noDataFound,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
      );
    }

    if (isEnded())
      return Center(
        child: Container(
          width: width / 1.35,
          padding: EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 8,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                Language.pointBig,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 50,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                point.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                height: 35,
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        returnMainPage();
                      },
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(
                          MdiIcons.home,
                          color: Color(0xff066DBC),
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    else {
      return Column(
        children: [
          SizedBox(
            height: playGameBannerAd != null ? 3.75 : 0,
          ),
          if (playGameBannerAd != null)
            Container(
              color: Colors.white,
              width: playGameBannerAd.size.width.toDouble(),
              height: playGameBannerAd.size.height.toDouble(),
              child: AdWidget(
                ad: playGameBannerAd,
              ),
            ),
          SizedBox(
            height: playGameBannerAd != null ? 3.75 : 35,
          ),
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                Container(
                  width: width / 1.1,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xff066DBC),
                      width: 5,
                    ),
                    color: Color(0xff066DBC),
                    borderRadius: BorderRadius.circular(
                      20,
                    ),
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: NetworkImage(
                        this
                            .questions[min(round, this.questions.length - 1)]
                            .photoUrl,
                      ),
                    ),
                  ),
                ),
                if (!roundReportSendStatus)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: GestureDetector(
                      onTap: () {
                        if (reportFreeze || reportSending) return;

                        setState(() {
                          reportFreeze = true;
                        });

                        AwesomeDialog(
                          btnOkText: "Gönder",
                          btnCancelText: Language.cancel,
                          context: context,
                          dismissOnTouchOutside: false,
                          dismissOnBackKeyPress: false,
                          dialogType: DialogType.QUESTION,
                          animType: AnimType.BOTTOMSLIDE,
                          title: Language.contract,
                          body: StatefulBuilder(
                            builder: (context, newSetState) {
                              return Column(
                                children: [
                                  Text(
                                    "SORU RAPORLAMA",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 23,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          "Reason: ",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: DropdownButton<String>(
                                            value: selectedReportType,
                                            underline: Container(
                                              height: 2,
                                              color: Colors.black,
                                            ),
                                            iconSize: 0,
                                            elevation: 16,
                                            style: const TextStyle(
                                              color: Colors.black,
                                            ),
                                            onChanged: (String newValue) {
                                              newSetState(() {
                                                selectedReportType = newValue;
                                              });
                                            },
                                            items: ReportTypes.getList()
                                                .map<DropdownMenuItem<String>>(
                                                    (String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (selectedReportType ==
                                      ReportTypes.getName(ReportTypes.OTHER))
                                    SizedBox(
                                      height: 15,
                                    ),
                                  if (selectedReportType ==
                                      ReportTypes.getName(ReportTypes.OTHER))
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      child: StandartTextField(
                                        color: Colors.black,
                                        editingController: reportController,
                                        borderBool: true,
                                        hintText: "Description",
                                        maxLength: 500,
                                        maxLines: 5,
                                        minLines: 3,
                                        counter: true,
                                        textStyle: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                          btnOkOnPress: () {
                            sendReport();

                            setState(() {
                              reportFreeze = false;
                            });
                          },
                          btnCancelOnPress: () {
                            setState(() {
                              reportFreeze = false;
                            });
                          },
                        )..show();
                      },
                      child: CircleAvatar(
                        backgroundColor: Color(0xffff9900),
                        radius: 19,
                        child: Icon(
                          MdiIcons.alertDecagram,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Image(
                    height: 50,
                    image: Images.playGameGallery,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Image(
                    height: 35,
                    image: Images.playGameCamera,
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Image(
                    height: 35,
                    image: Images.playGameMarker,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(
              10,
            ),
            child: Text(
              Language.whereIsHere,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 40,
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: EdgeInsets.all(
                10,
              ),
              child: Column(
                children: getAnswers(),
              ),
            ),
          ),
        ],
      );
    }
  }

  List<Widget> getAnswers() {
    List<Widget> widgetList = [];

    Question question = this.questions[round];
    int i = 0;
    for (City answer in question.allAnswers) {
      bool isTrueAnswer = answer.id == question.city.id;
      if (isTrueAnswer) {
        trueAnswerIndex = i;
      }
      widgetList.add(getAnswer(
          i,
          isTrueAnswer,
          answer.name +
              " / " +
              answer.state.name +
              " / " +
              answer.country.name));
      if (i != question.allAnswers.length - 1)
        widgetList.add(SizedBox(
          height: 15,
        ));
      i++;
    }

    return widgetList;
  }

  getAnswer(int index, bool isTrue, String name) {
    double width = MediaQuery.of(context).size.width;
    return Expanded(
      child: InkWell(
        splashColor: Colors.white,
        borderRadius: BorderRadius.circular(
          21,
        ),
        onTap: () {
          if (freeze) return;
          setState(() {
            indexOfSelected = index;
            freeze = true;
          });
          if (indexOfSelected == trueAnswerIndex) {
            trueCount++;
          } else {
            falseCount++;
          }
        },
        child: Container(
          width: width / 1.2,
          padding: EdgeInsets.symmetric(
            horizontal: 10,
          ),
          decoration: BoxDecoration(
            border: freeze
                ? indexOfSelected == index
                    ? Border.all(
                        color: Colors.white,
                        width: 5,
                      )
                    : null
                : null,
            // image: DecorationImage(
            //   image: Images.answerBackground,
            //   fit: BoxFit.fill,
            // ),
            color: Color(0xff00EAD3),
            borderRadius: BorderRadius.circular(
              21,
            ),
          ),
          height: 50,
          child: Center(
            child: AutoSizeText(
              name,
              maxLines: 1,
              minFontSize: 15,
              maxFontSize: 20,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                // freeze
                //     ? indexOfSelected == index
                //         ? Colors.white
                //         : Color(0xff066DBC)
                //     : Color(0xff066DBC),
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future loadQuestions() async {
    String firstQuery =
        "SELECT questions.*, cities.*, states.name as stateName, countries.name as countryName FROM "
                "questions, states, countries, cities, (SELECT questionId AS qid FROM questions ORDER BY RAND() LIMIT " +
            Constants.BuildPredictionSinglePlayerRoundCount.toString() +
            ") as random WHERE "
                "questions.cityId = cities.id AND questions.questionId = random.qid AND cities.state_id = states.id AND cities.country_id = countries.id AND questions.status = true";

    DataModel dataModel = await DatabaseController.query(firstQuery);
    this.questions = [];

    String query =
        "SELECT cities.*, states.name as stateName, countries.name as countryName FROM "
                "states, countries, cities, (SELECT id AS cid FROM cities ORDER BY RAND() LIMIT " +
            (Constants.TotalWrongAnswerCount *
                    Constants.BuildPredictionSinglePlayerRoundCount)
                .toString() +
            ") as random WHERE "
                "cities.id = random.cid AND cities.state_id = states.id AND cities.country_id = countries.id";

    int j = 0;
    List list = dataModel.data;
    for (Map m in list) {
      if (j == 0) query += " AND ";
      query += ("cities.id != " + m["id"]);
      if (j != list.length - 1) query += " AND ";

      this.questions.add(
            Question.fromMap(
              m,
              city: City.fromMap(
                m,
                state: Province(
                  name: m["stateName"],
                ),
                country: Country(
                  name: m["countryName"],
                ),
              ),
            ),
          );

      j++;
    }

    DataModel subDataModel = await DatabaseController.query(query);
    List<City> cities = [];
    int i = 0;
    for (Map map in subDataModel.data) {
      cities.add(
        City.fromMap(
          map,
          country: Country(
            name: map["countryName"],
          ),
          state: Province(
            name: map["stateName"],
          ),
        ),
      );

      if (cities.length == Constants.TotalWrongAnswerCount) {
        if (i >= questions.length) {
          continue;
        }
        List<City> cityList = [];
        cityList.addAll(cities);
        questions[i].addOtherAnswers(cityList);
        cities.clear();
        i++;
      }
    }

    loadTimer();
    if (mounted)
      setState(() {
        this.isLoading = false;
      });
  }

  void nextRound({bool isTrue}) {
    if (isTrue != null) {
      if (isTrue) {
        AudioController.playSoundEffect(AudioFiles.TrueSound);
        // Increase point
        point += roundTimer - time;
      } else {
        AudioController.playSoundEffect(AudioFiles.FalseSound);
        // Dont edit point
      }
    } else {
      Fluttertoast.showToast(
        msg: Language.noMoreTimes,
      );
      AudioController.playSoundEffect(AudioFiles.FalseSound);
    }

    roundTimer = time + Constants.BuildPredictionSinglePlayerQuestionTimer;
    setState(() {
      round++;
      roundReportSendStatus = false;
      reportFreeze = false;
      reportSending = false;
    });

    if (round == Constants.BuildPredictionSinglePlayerRoundCount) {
      AudioController.playSoundEffect(AudioFiles.LevelEnd);

      FirebaseAuth.instance.authStateChanges().listen((user) async {
        if (user != null) {
          DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
              await FirebaseFirestore.instance
                  .collection("userdata")
                  .doc(user.uid)
                  .get();
          Map map = documentSnapshot.data();

          int playCount = map["play_count"];
          int maxPoint = map["maximum_point"];
          int totalPoint = map["total_point"];
          int countOfTrue = map["true_answers"];
          int countOfFalse = map["false_answers"];

          if (point > maxPoint) {
            maxPoint = point;
          }
          countOfTrue += trueCount;
          countOfFalse += falseCount;
          playCount++;
          totalPoint += point;
          map["play_count"] = playCount;
          map["maximum_point"] = maxPoint;
          map["total_point"] = totalPoint;
          map["true_answers"] = countOfTrue;
          map["false_answers"] = countOfFalse;

          await FirebaseFirestore.instance
              .collection("userdata")
              .doc(user.uid)
              .update(map);
        }
      });
    }
  }

  void loadTimer() {
    if (timer == null)
      timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (reportFreeze) return;

        if (freeze) {
          if (freezeCounter == 0) {
            freezeCounter = 4;
          }

          freezeCounter--;

          if (freezeCounter == 0) {
            Functions.showCorrectAnswers().then((value) {
              bool isTrue = indexOfSelected == trueAnswerIndex;
              if (value && !isTrue) {
                AwesomeDialog(
                  btnOkText: Language.okey,
                  context: context,
                  dialogType: DialogType.QUESTION,
                  animType: AnimType.BOTTOMSLIDE,
                  title: Language.information,
                  desc: Language.emailOrPasswordSyntaxError,
                  btnOkOnPress: () {},
                )..show();
              } else {
                freeze = false;
                nextRound(isTrue: isTrue);
              }
            });
          }

          return;
        }

        if (!isEnded()) {
          if (mounted)
            setState(() {
              time++;
            });

          if (roundTimer - time <= 0) {
            nextRound();
          }
        } else {
          timer.cancel();
        }
      });

    roundTimer = time + Constants.BuildPredictionSinglePlayerQuestionTimer;
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 3)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: Language.exitTwoTap);
      return Future.value(false);
    }
    returnMainPage();
    return Future.value(false);
  }

  void returnMainPage() {
    Navigator.pushAndRemoveUntil(
      context,
      CupertinoPageRoute(
        builder: (context) => ParentMainPage(),
      ),
      (Route<dynamic> route) => false,
    );
  }

  void sendReport() async {
    setState(() {
      reportSending = true;
    });

    String description = reportController.text;
    int reportTypeId = ReportTypes.getIndex(selectedReportType);
    if (ReportTypes.OTHER == reportTypeId) {
      if (description.length <= 10) {
        Fluttertoast.showToast(
          msg:
              "Diğer seçeneğini seçtiğinizde en az 10 karakter açıklama girmeniz gereklidir.",
          timeInSecForIosWeb: 3,
        );
        setState(() {
          reportSending = false;
        });
        return;
      }
    }

    Question question = questions[round];

    Response response = await post(
      Uri.parse(
        Constants.userSendReportUrl,
      ),
      body: {
        "description": description,
        "securityToken": Constants.securityToken,
        "uploader": await Functions.getDeviceDetails(),
        "reportTypeId": reportTypeId.toString(),
        "questionId": question.questionId.toString(),
      },
    );

    if (response.statusCode == 200 &&
        (response.body == "1" || response.body == "true")) {
      Fluttertoast.showToast(
        msg:
            "Rapor başarılı bir şekilde gönderildi! Yardımınız için teşekkür ederiz :)",
        timeInSecForIosWeb: 3,
      );
      setState(() {
        roundReportSendStatus = true;
      });
    } else {
      Fluttertoast.showToast(
        msg: "Sanırım birşeyler ters gitti, rapor gönderilemedi.",
        timeInSecForIosWeb: 3,
      );
    }

    setState(() {
      reportSending = false;
    });
    reportController.clear();
  }
}
